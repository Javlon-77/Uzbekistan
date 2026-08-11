# Pitwall Manager — Roblox Luau kodi

Original implementatsiya: F1 uslubidagi pit-wall strategiya o'yini. Siz jamoa strategisi
sifatida haydovchilarga tezlik rejimi, shina tanlash va pit-stop buyruqlarini berasiz,
ob-havoga qarab to'g'ri qaror qilasiz.

> Eslatma: Bu kod **original** — Roblox'dagi "Pitwall Manager" o'yinining yopiq
> manba kodi emas, balki xuddi shu janrdagi o'z o'yiningizni yaratish uchun
> tayyor, to'liq ishlaydigan kod.

---

## O'rnatish (Roblox Studio)

1. **Roblox Studio**'ni oching va `Baseplate` shablonini tanlang.
2. **ServerScriptService** → o'ng tugma → `Insert Object` → `Script` qo'shing.
   - Skript nomini `RaceServer` deb o'zgartiring.
   - `RaceServer.server.lua` faylidagi kodni to'liq ko'chirib joylang.
3. **StarterGui** → o'ng tugma → `Insert Object` → `LocalScript` qo'shing.
   - Nomini `PitWallUI` deb o'zgartiring.
   - `PitWallUI.client.lua` faylidagi kodni to'liq ko'chirib joylang.
4. **Play** tugmasini bosing.

> `ReplicatedStorage`'da `PitWallRemotes` papkasi kod tomonidan avtomatik
> yaratiladi — qo'lda hech narsa qo'shish shart emas.

---

## O'yin qanday ishlaydi

- O'yinga birinchi kirgan o'yinchi 1-jamoada (Velocity Racing) o'ynaydi.
  Jamoa o'zgartirish: poyga boshlanishidan oldin pastki panelda jamoa tanlang.
- Har **6 real sekund** = 1 simulyatsiya qilingan davr (30 davr poyga).
- Sizning vazifangiz:
  - **Pace** — haydovchiga PUSH (tez, shina ko'p eskiradi) / NORMAL / SAVE
    (sekin, shinani tejaydi) buyrug'i.
  - **Shina tanlash** — S / M / H / I / W tugmalari orqali keyingi pit-stopda
    qaysi shina qo'yilishini belgilang.
  - **BOX!** — keyingi davrda pit-stop qilish (taxminan 24 soniya yo'qotiladi).
  - **Ob-havo prognozi** — pastki paneldagi rangli kvadratlar kelgusi davrlar
    uchun prognozni ko'rsatadi (kulrang = quruq, ko'k = yomg'ir). Yomg'ir
    kelganda Inter/Wet shinalarga o'ting!

---

## Nima sozlanadi (RaceServer.server.lua, yuqori qismi)

| O'zgaruvchi | Ma'nosi |
|---|---|
| `RACE.baseLap` | Mos yozuv vaqti (sekund) |
| `RACE.laps` | Poyga davomiyligi (davr) |
| `RACE.pitLoss` | Pit-stopda yo'qotiladigan vaqt |
| `RACE.lapTick` | Har bir davr orasidagi real vaqt (sekund) |
| `COMPOUNDS` | Shinalar tezligi, eskirishi, ho'llik ushlashi |
| `WEATHER_SEGMENTS` | Ob-havo jadvali (qancha davr quruq/yomg'ir) |
| `TEAM_DEFS` | Jamoalar va haydovchi statistikasi |

Haydovchi statistikasi: `skill` (mahorat), `tireSave` (shina tejash),
`aggression` (agressivlik — tezroq lekin shinani ko'p eskiradi).

---

## Fayllar

- `RaceServer.server.lua` — poyga simulyatsiyasi, AI, ob-havo, ball (server)
- `PitWallUI.client.lua` — pit-wall interfeysi (client)

## Keyingi qadamlar (o'zingiz qo'shishingiz mumkin)

- Saralash (qualifying) bosqichi
- Avtomobil yangilanishlari / pul tizimi
- Ko'p o'yinchili liga
- Ovoz effektlari va animatsiyalar
