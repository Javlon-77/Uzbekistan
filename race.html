--[[
	PITWALL MANAGER — client UI (LocalScript)

	O'rnatish:
	  - StarterGui'ga LocalScript qo'shing va shu kodni joylang.
	    (ScreenGui kod ichida avtomatik yaratiladi)
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

local remotes = ReplicatedStorage:WaitForChild("PitWallRemotes")
local syncEvent    = remotes:WaitForChild("SyncState")
local commandEvent = remotes:WaitForChild("PitCommand")
local startEvent   = remotes:WaitForChild("StartRace")
local chooseEvent  = remotes:WaitForChild("ChooseTeam")

-- ============================================================
--  UI YORDAMCHILARI
-- ============================================================
local COLORS = {
	bg      = Color3.fromRGB(12, 12, 16),
	panel   = Color3.fromRGB(24, 26, 34),
	row     = Color3.fromRGB(32, 35, 45),
	accent  = Color3.fromRGB(255, 200, 60),
	green   = Color3.fromRGB(70, 200, 110),
	yellow  = Color3.fromRGB(240, 190, 60),
	red     = Color3.fromRGB(230, 70, 70),
	gray    = Color3.fromRGB(140, 145, 155),
}

local function frame(parent, size, pos, color, transparency)
	local f = Instance.new("Frame")
	f.Size = size
	f.Position = pos
	f.BackgroundColor3 = color or COLORS.panel
	f.BackgroundTransparency = transparency or 0
	f.BorderSizePixel = 0
	f.Parent = parent
	return f
end

local function label(parent, text, size, pos, textSize, color, align)
	local l = Instance.new("TextLabel")
	l.Size = size
	l.Position = pos
	l.BackgroundTransparency = 1
	l.Text = text
	l.TextColor3 = color or Color3.new(1, 1, 1)
	l.TextSize = textSize or 14
	l.Font = Enum.Font.Gotham
	l.TextXAlignment = align or Enum.TextXAlignment.Left
	l.Parent = parent
	return l
end

local function button(parent, text, size, pos, bg, cb, textSize)
	local b = Instance.new("TextButton")
	b.Size = size
	b.Position = pos
	b.BackgroundColor3 = bg
	b.Text = text
	b.TextColor3 = Color3.new(1, 1, 1)
	b.TextSize = textSize or 12
	b.Font = Enum.Font.GothamBold
	b.BorderSizePixel = 0
	b.Parent = parent
	b.Activated:Connect(cb)
	return b
end

local function clear(container)
	for _, child in ipairs(container:GetChildren()) do
		child:Destroy()
	end
end

local function wearColor(wear)
	if wear < 45 then return COLORS.green end
	if wear < 75 then return COLORS.yellow end
	return COLORS.red
end

-- ============================================================
--  ASOSIY UI QURISH
-- ============================================================
local screen = Instance.new("ScreenGui")
screen.Name = "PitWallUI"
screen.IgnoreGuiInset = true
screen.Parent = player:WaitForChild("PlayerGui")

local root = frame(screen, UDim2.fromScale(1, 1), UDim2.fromScale(0, 0), COLORS.bg)
local uiScale = Instance.new("UIScale")
uiScale.Parent = root

-- Header
local header = frame(root, UDim2.fromScale(0.96, 0.06), UDim2.fromScale(0.02, 0.02), COLORS.panel)
label(header, "PITWALL MANAGER", UDim2.fromScale(0.4, 1), UDim2.fromScale(0.02, 0), 20, COLORS.accent, Enum.TextXAlignment.Left)
local statusLabel = label(header, "LAP 0/30 | DRY", UDim2.fromScale(0.4, 1), UDim2.fromScale(0.58, 0), 18, nil, Enum.TextXAlignment.Right)

-- Toast (ob-havo xabari)
local toast = label(root, "", UDim2.fromScale(0.6, 0.07), UDim2.fromScale(0.2, 0.10), 22, COLORS.accent, Enum.TextXAlignment.Center)
toast.TextTransparency = 1

-- Chap panel: natijalar
local standingsPanel = frame(root, UDim2.fromScale(0.50, 0.70), UDim2.fromScale(0.02, 0.10))
label(standingsPanel, "STANDINGS", UDim2.fromScale(0.96, 0.06), UDim2.fromScale(0.02, 0.01), 16, COLORS.accent)
local standingsList = frame(standingsPanel, UDim2.fromScale(0.96, 0.90), UDim2.fromScale(0.02, 0.08), COLORS.bg)
label(standingsPanel, "POS  DRIVER                       GAP     TYRE   WEAR   LAST", UDim2.fromScale(0.96, 0.04), UDim2.fromScale(0.02, 0.965), 10, COLORS.gray)

-- O'ng panel: jamoa (haydovchi kartalari)
local teamPanel = frame(root, UDim2.fromScale(0.44, 0.70), UDim2.fromScale(0.54, 0.10))
label(teamPanel, "YOUR TEAM", UDim2.fromScale(0.96, 0.06), UDim2.fromScale(0.02, 0.01), 16, COLORS.accent)
local teamCards = frame(teamPanel, UDim2.fromScale(0.96, 0.90), UDim2.fromScale(0.02, 0.08), COLORS.bg)

-- Pastki panel: prognoz + boshqaruv
local bottomPanel = frame(root, UDim2.fromScale(0.96, 0.15), UDim2.fromScale(0.02, 0.83))
label(bottomPanel, "WEATHER FORECAST", UDim2.fromScale(0.2, 0.2), UDim2.fromScale(0.02, 0.03), 12, COLORS.gray)
local forecastStrip = frame(bottomPanel, UDim2.fromScale(0.96, 0.10), UDim2.fromScale(0.02, 0.22), COLORS.bg)
local controlsArea = frame(bottomPanel, UDim2.fromScale(0.96, 0.6), UDim2.fromScale(0.02, 0.38), COLORS.bg)

-- ============================================================
--  RENDER FUNKSIYALARI
-- ============================================================
local function renderForecast(state)
	clear(forecastStrip)
	local n = state.laps
	local cellW = 1 / n
	for lap = 1, n do
		local wet = state.forecast[lap] or 0.05
		local color = COLORS.gray
		if wet > 0.45 then color = Color3.fromRGB(40, 90, 160)
		elseif wet > 0.2 then color = Color3.fromRGB(120, 160, 220) end

		local cell = frame(forecastStrip, UDim2.fromScale(cellW * 0.8, 1), UDim2.fromScale((lap - 1) * cellW, 0), color)
		if lap == state.lap then
			cell.BorderSizePixel = 2
			cell.BorderColor3 = Color3.new(1, 1, 1)
		end
	end
end

local function renderStandings(state)
	clear(standingsList)
	for i, d in ipairs(state.drivers) do
		local rowY = (i - 1) * 0.098
		local rowBg = d.playerControlled and Color3.fromRGB(45, 40, 25) or (i % 2 == 1 and COLORS.row or COLORS.bg)
		local row = frame(standingsList, UDim2.fromScale(1, 0.092), UDim2.fromScale(0, rowY), rowBg)

		local tireColor = {
			Soft = Color3.fromRGB(200, 40, 40),
			Medium = Color3.fromRGB(220, 220, 80),
			Hard = Color3.fromRGB(220, 220, 220),
			Inter = Color3.fromRGB(60, 200, 60),
			Wet = Color3.fromRGB(60, 120, 220),
		}[d.compound] or COLORS.gray

		label(row, tostring(d.position), UDim2.fromScale(0.06, 1), UDim2.fromScale(0.02, 0), 13, COLORS.accent)
		label(row, d.name .. " (" .. d.team .. ")", UDim2.fromScale(0.37, 1), UDim2.fromScale(0.09, 0), 12)
		local gapText = d.position == 1 and "LEADER" or string.format("+%.2f", d.gap)
		label(row, gapText, UDim2.fromScale(0.12, 1), UDim2.fromScale(0.47, 0), 12, d.position == 1 and COLORS.green or nil)
		label(row, d.compound, UDim2.fromScale(0.10, 1), UDim2.fromScale(0.60, 0), 11, tireColor)

		local wearBg = frame(row, UDim2.fromScale(0.17, 0.16), UDim2.fromScale(0.71, 0.42), Color3.fromRGB(10, 10, 12))
		local wearFill = frame(wearBg, UDim2.fromScale(d.wear / 100, 1), UDim2.fromScale(0, 0), wearColor(d.wear))
		label(row, tostring(d.wear) .. "%", UDim2.fromScale(0.09, 1), UDim2.fromScale(0.72, 0), 10, COLORS.gray)

		local lastText = d.lastLap > 0 and string.format("%.2f", d.lastLap) or "--"
		if d.pitPending then lastText = "BOX!" end
		label(row, lastText, UDim2.fromScale(0.10, 1), UDim2.fromScale(0.85, 0), 11,
			d.pitPending and COLORS.red or nil)

		if state.status == "finished" and d.points > 0 then
			label(row, "+" .. tostring(d.points) .. " PTS", UDim2.fromScale(0.20, 1), UDim2.fromScale(0.06, 0), 12, COLORS.green)
		end
	end
end

local PACE_LABELS = { "PUSH", "NORMAL", "SAVE" }

local function sendCommand(driverName, command, value)
	commandEvent:FireServer(driverName, command, value)
end

local function renderDriverCard(container, d, index)
	local card = frame(container, UDim2.fromScale(0.98, 0.45), UDim2.fromScale(0.01, 0.47 * (index - 1)), COLORS.panel)

	label(card, d.name .. " — " .. d.team, UDim2.fromScale(0.5, 0.16), UDim2.fromScale(0.03, 0.02), 15, COLORS.accent)

	-- Shina + eskirish
	label(card, "TYRES: " .. d.compound, UDim2.fromScale(0.2, 0.16), UDim2.fromScale(0.03, 0.18), 12)
	local wearBg = frame(card, UDim2.fromScale(0.35, 0.10), UDim2.fromScale(0.25, 0.22), Color3.fromRGB(10, 10, 12))
	local wearFill = frame(wearBg, UDim2.fromScale(d.wear / 100, 1), UDim2.fromScale(0, 0), wearColor(d.wear))
	label(card, tostring(d.wear) .. "%", UDim2.fromScale(0.1, 0.16), UDim2.fromScale(0.62, 0.18), 12, COLORS.gray)

	local lastText = d.lastLap > 0 and string.format("LAST %.2f", d.lastLap) or "LAST --"
	label(card, lastText, UDim2.fromScale(0.3, 0.16), UDim2.fromScale(0.68, 0.02), 11, COLORS.gray)

	-- Tezlik rejimi tugmalari
	local paceBg = frame(card, UDim2.fromScale(0.94, 0.20), UDim2.fromScale(0.03, 0.38), COLORS.bg)
	for i, paceName in ipairs(PACE_LABELS) do
		local active = d.pace == paceName
		local b = button(paceBg, paceName,
			UDim2.fromScale(0.315, 0.8), UDim2.fromScale(0.01 + (i - 1) * 0.34, 0.1),
			active and COLORS.accent or COLORS.row,
			function()
				sendCommand(d.name, "pace", paceName)
			end)
		b.TextColor3 = active and Color3.fromRGB(20, 20, 20) or Color3.new(1, 1, 1)
	end

	-- Pit-stop tugmalari
	local pitBg = frame(card, UDim2.fromScale(0.94, 0.24), UDim2.fromScale(0.03, 0.62), COLORS.bg)
	local compounds = { "Soft", "Medium", "Hard", "Inter", "Wet" }
	for i, compound in ipairs(compounds) do
		button(pitBg, string.sub(compound, 1, 1),
			UDim2.fromScale(0.185, 0.8), UDim2.fromScale(0.01 + (i - 1) * 0.198, 0.1),
			d.compound == compound and COLORS.accent or COLORS.row,
			function()
				sendCommand(d.name, "pit", compound)
			end)
	end
	button(pitBg, "BOX!",
		UDim2.fromScale(0.185, 0.8), UDim2.fromScale(0.79, 0.1), COLORS.red,
		function()
			sendCommand(d.name, "pit", d.compound) -- hozirgi shina bilan box
		end)
end

local function renderTeamCards(state)
	clear(teamCards)
	local controlled = {}
	for _, d in ipairs(state.drivers) do
		if d.playerControlled then table.insert(controlled, d) end
	end
	for i, d in ipairs(controlled) do
		renderDriverCard(teamCards, d, i)
	end
end

local function renderControls(state)
	clear(controlsArea)
	if state.status == "waiting" then
		label(controlsArea, "SELECT YOUR TEAM:", UDim2.fromScale(0.2, 0.4), UDim2.fromScale(0.02, 0.05), 13, COLORS.gray)
		local teamNames = {}
		for _, d in ipairs(state.drivers) do
			if not teamNames[d.team] then
				table.insert(teamNames, d.team)
			end
		end
		for i, teamName in ipairs(teamNames) do
			local active = state.teamIndex == i
			button(controlsArea, teamName,
				UDim2.fromScale(0.15, 0.6), UDim2.fromScale(0.22 + (i - 1) * 0.155, 0.05),
				active and COLORS.accent or COLORS.row,
				function()
					chooseEvent:FireServer(i)
				end)
		end
		button(controlsArea, "START RACE",
			UDim2.fromScale(0.18, 0.7), UDim2.fromScale(0.78, 0.05), COLORS.green,
			function()
				startEvent:FireServer()
			end, 16)
	else
		label(controlsArea, "RACE " .. (state.status == "finished" and "FINISHED" or "IN PROGRESS"),
			UDim2.fromScale(0.4, 0.5), UDim2.fromScale(0.02, 0.1), 16,
			state.status == "finished" and COLORS.green or COLORS.accent)
	end
end

-- ============================================================
--  SYNC QABUL QILISH
-- ============================================================
local toastTime = 0
local toastStart = 0
local toastActive = false

local function showToast(text)
	toast.Text = text
	toast.TextTransparency = 0
	toastActive = true
	toastStart = os.clock()
end

task.spawn(function()
	while true do
		task.wait(0.1)
		if toastActive and (os.clock() - toastStart > 4) then
			toast.TextTransparency = 1
			toastActive = false
		end
	end
end)

syncEvent.OnClientEvent:Connect(function(state)
	statusLabel.Text = string.format("LAP %d/%d | %s", state.lap, state.laps, state.weather)

	if state.weatherNote and state.weatherNote ~= "" then
		showToast(state.weatherNote)
	end

	renderStandings(state)
	renderTeamCards(state)
	renderForecast(state)
	renderControls(state)
end)
