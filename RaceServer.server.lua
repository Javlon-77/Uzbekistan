--[[
	PITWALL MANAGER — original Luau implementatsiya (server tomoni)

	O'rnatish:
	  - Bu skriptni ServerScriptService'ga Script sifatida joylang.
	  - ReplicatedStorage'da "PitWallRemotes" papkasi avtomatik yaratiladi.

	O'yin g'oyasi:
	  - Siz bitta jamoaning pit-wall strategisi bo'lasiz.
	  - Haydovchilarga tezlik rejimi (Push/Normal/Save), shina tanlash
	    va pit-stop buyruqlarini berasiz.
	  - Ob-havo o'zgaradi — to'g'ri shinani to'g'ri vaqtda qo'yish g'alaba keltiradi.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- ============================================================
--  REMOTES (avtomatik yaratiladi)
-- ============================================================
local remotesFolder = ReplicatedStorage:FindFirstChild("PitWallRemotes")
if not remotesFolder then
	remotesFolder = Instance.new("Folder")
	remotesFolder.Name = "PitWallRemotes"
	remotesFolder.Parent = ReplicatedStorage
end

local function ensureRemote(name, className)
	local remote = remotesFolder:FindFirstChild(name)
	if not remote then
		remote = Instance.new(className)
		remote.Name = name
		remote.Parent = remotesFolder
	end
	return remote
end

local syncEvent    = ensureRemote("SyncState", "RemoteEvent")
local commandEvent = ensureRemote("PitCommand", "RemoteEvent")
local startEvent   = ensureRemote("StartRace", "RemoteEvent")
local chooseEvent  = ensureRemote("ChooseTeam", "RemoteEvent")

-- ============================================================
--  KONFIGURATSIYA
-- ============================================================
local RACE = {
	baseLap  = 95,  -- mos yozuv vaqti (sekund)
	laps     = 30,  -- poyga davomiyligi
	pitLoss  = 24,  -- pit-stopda yo'qotiladigan vaqt (sekund)
	lapTick  = 6,   -- har bir simulyatsiya qilingan davr orasidagi real vaqt (sekund)
	variance = 0.6, -- har davr uchun tasodifiy tebranish (sekund)
}

-- Shinalar: speed = qanchalik sekin (0 = eng tez), wetGrip = yomg'irda qanchalik yaxshi
local COMPOUNDS = {
	Soft   = { speed = 0.000, wear = 1.55, wetGrip = 0.30 },
	Medium = { speed = 0.006, wear = 1.00, wetGrip = 0.42 },
	Hard   = { speed = 0.012, wear = 0.62, wetGrip = 0.52 },
	Inter  = { speed = 0.028, wear = 0.72, wetGrip = 0.80 },
	Wet    = { speed = 0.055, wear = 0.95, wetGrip = 1.00 },
}

-- Har bir shina turi uchun davr boshiga eskirish foizi
local BASE_WEAR = { Soft = 6.5, Medium = 4.2, Hard = 2.8, Inter = 3.5, Wet = 4.5 }

local PACE_MULT = {
	Push   = { time = 0.993, wearMult = 1.35 },
	Normal = { time = 1.000, wearMult = 1.00 },
	Save   = { time = 1.009, wearMult = 0.65 },
}

-- Ob-havo jadvali: har segment necha davr davom etadi va ho'llik darajasi (0..1)
local WEATHER_SEGMENTS = {
	{ laps = 10, wet = 0.05 },  -- quruq start
	{ laps = 6,  wet = 0.65 },  -- yomg'ir
	{ laps = 5,  wet = 0.30 },  -- quriy boshlaydi
	{ laps = 9,  wet = 0.05 },  -- quruq finish
}

local POINTS = { 25, 18, 15, 12, 10, 8, 6, 4, 2, 1 }

-- Jamoalar va haydovchilar (fiktiv ismlar)
local TEAM_DEFS = {
	{ name = "Velocity Racing", color = Color3.fromRGB(220, 40, 40), drivers = {
		{ name = "Liam Carter",  skill = 90, tireSave = 78, aggression = 55 },
		{ name = "Niko Berg",    skill = 84, tireSave = 70, aggression = 65 },
	} },
	{ name = "Apex Motorsport", color = Color3.fromRGB(30, 120, 220), drivers = {
		{ name = "Dante Rossi",  skill = 88, tireSave = 72, aggression = 72 },
		{ name = "Yuki Tanaka",  skill = 82, tireSave = 80, aggression = 45 },
	} },
	{ name = "Falcon GP", color = Color3.fromRGB(240, 180, 30), drivers = {
		{ name = "Marcus Webb",  skill = 86, tireSave = 66, aggression = 60 },
		{ name = "Sofia Marin",  skill = 83, tireSave = 74, aggression = 58 },
	} },
	{ name = "Nova Engineering", color = Color3.fromRGB(80, 200, 120), drivers = {
		{ name = "Alex Petrov",  skill = 85, tireSave = 68, aggression = 62 },
		{ name = "Jules Moreau", skill = 80, tireSave = 76, aggression = 50 },
	} },
	{ name = "Titan Racing", color = Color3.fromRGB(160, 90, 200), drivers = {
		{ name = "Omar Haddad",  skill = 87, tireSave = 60, aggression = 75 },
		{ name = "Leo Fischer",  skill = 81, tireSave = 71, aggression = 55 },
	} },
}

-- ============================================================
--  POYGA HOLATI
-- ============================================================
local race = {
	status = "waiting",    -- "waiting" | "running" | "finished"
	lap = 0,
	weather = "Dry",
	weatherNote = "",
	wet = 0.05,
	forecast = {},         -- davr bo'yicha ho'llik prognozi
	drivers = {},          -- haydovchilarning runtime holati
	controller = nil,      -- o'yinni boshqarayotgan Player
	teamIndex = 1,
}

local function buildDrivers()
	race.drivers = {}
	for ti, team in ipairs(TEAM_DEFS) do
		for _, def in ipairs(team.drivers) do
			table.insert(race.drivers, {
				name = def.name,
				team = team.name,
				teamIndex = ti,
				color = team.color,
				skill = def.skill,
				tireSave = def.tireSave,
				aggression = def.aggression,
				playerControlled = false,
				compound = "Soft",
				wear = 0,
				pace = "Normal",
				pitOrder = nil,   -- { compound = "Hard" } kabi bo'lsa, keyingi davr box
				lastLap = 0,
				totalTime = 0,
				fastest = math.huge,
				lapTimes = {},
				position = 0,
				gap = 0,
				finished = false,
				points = 0,
			})
		end
	end
end

buildDrivers()

-- ============================================================
--  YORDAMCHI FUNKSIYALAR
-- ============================================================
local function weatherLabel(wet)
	if wet > 0.5 then return "RAIN" end
	if wet > 0.25 then return "DRIZZLE" end
	return "DRY"
end

local function buildForecast()
	local forecast = {}
	local lap = 0
	for _, seg in ipairs(WEATHER_SEGMENTS) do
		for _ = 1, seg.laps do
			lap += 1
			forecast[lap] = seg.wet
		end
	end
	for i = lap + 1, RACE.laps do
		forecast[i] = 0.05
	end
	return forecast
end

local function findDriver(name)
	for _, d in ipairs(race.drivers) do
		if d.name == name then return d end
	end
	return nil
end

local function findTeammate(d)
	for _, other in ipairs(race.drivers) do
		if other ~= d and other.teamIndex == d.teamIndex then
			return other
		end
	end
	return nil
end

-- Bir davr vaqtini hisoblash
local function calcLapTime(d, lap)
	local compound = COMPOUNDS[d.compound]
	local pace = PACE_MULT[d.pace]

	-- Yomg'ir: ho'lik trackda yomon wetGrip'li shina sekinlashtiradi
	local wetPenalty = (1 - compound.wetGrip) * race.wet * 0.9
	-- Yomg'irda hamma sekinroq
	local weatherSlowdown = race.wet * 1.2

	local t = RACE.baseLap
	t += (100 - d.skill) * 0.05            -- haydovchi mahorati
	t += compound.speed * RACE.baseLap     -- shina tezligi
	t += (d.wear / 100) * 0.4              -- shina eskirishi
	t += wetPenalty
	t += weatherSlowdown
	t *= pace.time
	t -= (d.aggression - 50) * 0.004       -- agressiv haydovchilar biroz tezroq
	t += (math.random() * 2 - 1) * RACE.variance -- tasodifiy tebranish

	return math.max(50, t)
end

-- Shina eskirishini qo'llash
local function applyWear(d)
	local wearRate = BASE_WEAR[d.compound]
		* PACE_MULT[d.pace].wearMult
		* (1 - d.tireSave / 100 * 0.3)      -- shinani tejaydigan haydovchilar kamroq eskiradi
		* (1 + (d.aggression - 50) / 100 * 0.3)
	d.wear = math.min(100, d.wear + wearRate)
end

-- AI haydovchi qarorlari
local function aiDecide(d)
	if race.status ~= "running" or d.finished then return end

	-- Ob-havoga mos shina tanlash
	if race.wet > 0.5 and d.compound ~= "Wet" then
		d.pitOrder = { compound = "Wet" }
	elseif race.wet > 0.25 and d.compound ~= "Inter" and d.compound ~= "Wet" then
		d.pitOrder = { compound = "Inter" }
	elseif race.wet <= 0.15 and (d.compound == "Inter" or d.compound == "Wet") then
		d.pitOrder = { compound = "Medium" }
	end

	-- Shina juda eskirgan bo'lsa — box
	if d.wear > 75 and not d.pitOrder then
		local nextCompound = race.wet > 0.25 and (race.wet > 0.5 and "Wet" or "Inter") or "Medium"
		d.pitOrder = { compound = nextCompound }
	end

	-- Tezlik rejimi
	if d.position <= 2 then
		d.pace = "Normal"
	elseif d.position > 8 then
		d.pace = "Push"
	else
		d.pace = "Normal"
	end
	if math.random() < 0.05 then
		d.pace = "Push"
	end
end

-- Bitta davrni simulyatsiya qilish
local function simulateLap(d, lap)
	local t = calcLapTime(d, lap)

	-- Pit-stop: buyruq berilgan bo'lsa, shu davrda box qiladi
	if d.pitOrder then
		t += RACE.pitLoss
		d.compound = d.pitOrder.compound
		d.wear = 0
		d.pitOrder = nil
	end

	d.lastLap = t
	d.totalTime += t
	d.lapTimes[lap] = t
	if t < d.fastest then d.fastest = t end

	applyWear(d)
end

-- O'rinlarni yangilash
local function updatePositions()
	table.sort(race.drivers, function(a, b)
		if a.finished ~= b.finished then return a.finished end
		return a.totalTime < b.totalTime
	end)
	local leader = race.drivers[1]
	for i, d in ipairs(race.drivers) do
		d.position = i
		d.gap = math.floor((d.totalTime - leader.totalTime) * 100) / 100
	end
end

-- ============================================================
--  BROADCAST (client'ga yuborish)
-- ============================================================
local function serialize()
	local out = {
		status = race.status,
		lap = race.lap,
		laps = RACE.laps,
		weather = race.weather,
		weatherNote = race.weatherNote,
		forecast = race.forecast,
		teamIndex = race.teamIndex,
		drivers = {},
	}
	for _, d in ipairs(race.drivers) do
		table.insert(out.drivers, {
			name = d.name,
			team = d.team,
			color = { d.color.R, d.color.G, d.color.B },
			playerControlled = d.playerControlled,
			compound = d.compound,
			wear = math.floor(d.wear),
			pace = d.pace,
			pitPending = d.pitOrder ~= nil,
			lastLap = math.floor(d.lastLap * 100) / 100,
			fastest = d.fastest == math.huge and 0 or math.floor(d.fastest * 100) / 100,
			gap = d.gap,
			position = d.position,
			finished = d.finished,
			points = d.points,
		})
	end
	return out
end

local function broadcast()
	syncEvent:FireAllClients(serialize())
end

-- ============================================================
--  POYGA BOSHQARUVI
-- ============================================================
local function startRace()
	if race.status ~= "waiting" then return end

	race.status = "running"
	race.lap = 0
	race.wet = 0.05
	race.weather = "Dry"
	race.weatherNote = ""
	race.forecast = buildForecast()

	for _, d in ipairs(race.drivers) do
		d.compound = "Soft"
		d.wear = 0
		d.pace = "Normal"
		d.pitOrder = nil
		d.lastLap = 0
		d.totalTime = 0
		d.fastest = math.huge
		d.lapTimes = {}
		d.position = 0
		d.gap = 0
		d.finished = false
		d.points = 0
	end

	broadcast()
end

-- ============================================================
--  ASOSIY SIMULYATSIYA SIKLI
-- ============================================================
task.spawn(function()
	while true do
		task.wait(RACE.lapTick)

		if race.status ~= "running" then continue end

		race.lap += 1
		race.wet = race.forecast[race.lap] or 0.05

		local newWeather = weatherLabel(race.wet)
		if newWeather ~= race.weather then
			race.weather = newWeather
			race.weatherNote = "WEATHER CHANGE: " .. newWeather .. "!"
		else
			race.weatherNote = ""
		end

		for _, d in ipairs(race.drivers) do
			if d.finished then continue end
			if not d.playerControlled then aiDecide(d) end
			simulateLap(d, race.lap)
			if race.lap >= RACE.laps then d.finished = true end
		end

		updatePositions()

		if race.lap >= RACE.laps then
			race.status = "finished"
			for i, d in ipairs(race.drivers) do
				d.points = POINTS[i] or 0
				d.finished = true
			end
		end

		broadcast()
	end
end)

-- ============================================================
--  REMOTE EVENT LAR
-- ============================================================
chooseEvent.OnServerEvent:Connect(function(plr, teamIndex)
	if race.status ~= "waiting" then return end
	teamIndex = math.clamp(teamIndex or 1, 1, #TEAM_DEFS)

	race.controller = plr
	race.teamIndex = teamIndex
	for _, d in ipairs(race.drivers) do
		d.playerControlled = (d.teamIndex == teamIndex)
	end
	broadcast()
end)

startEvent.OnServerEvent:Connect(function(plr)
	if plr ~= race.controller then return end
	startRace()
end)

commandEvent.OnServerEvent:Connect(function(plr, driverName, command, value)
	if race.status ~= "running" then return end
	local d = findDriver(driverName)
	if not d or not d.playerControlled then return end

	if command == "pace" then
		if value == "Push" or value == "Normal" or value == "Save" then
			d.pace = value
		end
	elseif command == "pit" then
		if COMPOUNDS[value] then
			d.pitOrder = { compound = value }
		end
	elseif command == "swap" then
		-- Jamoa buyrug'i: yaqin bo'lgan haydovchilar o'rin almashadi
		local mate = findTeammate(d)
		if mate and not mate.finished and not d.finished then
			local diff = d.totalTime - mate.totalTime
			if math.abs(diff) < 3 then
				local leader, follower = d, mate
				if diff < 0 then leader, follower = mate, d end
				leader.totalTime += 0.5
				follower.totalTime -= 0.4
				updatePositions()
			end
		end
	end

	broadcast()
end)

-- Yangi o'yinchi kelganda holatni yuborish
Players.PlayerAdded:Connect(function(plr)
	if race.status == "waiting" and not race.controller then
		-- Birinchi kelgan o'yinchi avtomatik 1-jamoani boshqaradi
		race.controller = plr
		race.teamIndex = 1
		for _, d in ipairs(race.drivers) do
			d.playerControlled = (d.teamIndex == 1)
		end
	end
	task.wait(1)
	syncEvent:FireClient(plr, serialize())
end)
