package.path = "./tests/?.lua;" .. package.path
local M = require("mock_wow")
M.install()
local libs = M.installLDB()
local vic, def = {}, {}
DBM = { AddVictorySound = function(_, t, v, l) vic[#vic + 1] = { t, v, l } end,
  AddDefeatSound = function(_, t, v, l) def[#def + 1] = { t, v, l } end }
local ns = M.loadAddon(".", "WipeAndWin")
M.check(not ns.added.lsm, "no LSM yet")
-- LSM shows up with a later addon (BigWigs)
local reg = {}
libs["LibSharedMedia-3.0"] = { MediaType = { SOUND = "sound" }, Register = function(_, t, k, v) reg[#reg + 1] = { t, k, v } end }
M.fire("ADDON_LOADED", "BigWigs")
M.check(ns.added.lsm and #reg == #ns.Victory + #ns.Defeat, "registered with LSM when it appears")
M.check(reg[1][1] == "sound" and reg[1][2]:find("^Wipe & Win: ") and type(reg[1][3]) == "number", "LSM entries are FileDataIDs")
-- DBM pack loader: reads the TOC fields then calls the globals
local toc = io.open("WipeAndWin.toc"):read("*a")
local vg = toc:match("## X%-DBM%-VictoryPack%-GlobalName: (%S+)")
local dg = toc:match("## X%-DBM%-DefeatPack%-GlobalName: (%S+)")
M.check(toc:find("## X%-DBM%-VictoryPack: 1") and toc:find("## X%-DBM%-DefeatPack: 1"), "pack flags in TOC")
_G[vg](); _G[dg](); _G[vg]()
M.check(#vic == #ns.Victory and #def == #ns.Defeat, "added once to DBM lists")
M.check(vic[1][2] == 558132 and vic[1][3] == 4, "Job's done is the first victory line")
-- no later-expansion sounds (DBM ships file copies for those on Forever, we only use vanilla-era IDs)
for _, l in ipairs({ ns.Victory, ns.Defeat }) do for _, s in ipairs(l) do
  M.check(s[2] ~= 552503 and s[2] ~= 553193 and s[2] ~= 543587 and s[2] ~= 552035, "vanilla-era id " .. s[1]) end end
M.slash("/wipewin", "win 1")
M.check(M.sounds[1][1] == 558132, "/wipewin win 1 previews")
M.slash("/wipewin", "wipe 9")
M.check(M.printed("pick 1-"), "range check")
M.combat = true; M.slash("/wipewin", "wipe 1"); M.combat = false
M.check(#M.sounds == 1, "no preview in combat")
-- 1.1.0: our other addons' voice lines wait while DBM plays the victory/defeat sound
local hub = KennyAddonsHub
hub.voiceUntil = 0
M.fire("ENCOUNTER_END", 1, "Boss", 1, 10, 1)
M.check(hub.voiceUntil > GetTime(), "quiet for other voice lines after a boss")
M.check(hub.PlayVoice(558132) == false, "a Job's done! line now waits")
local claimed = 0
for _ in pairs(hub.sounds) do claimed = claimed + 1 end
M.check(claimed == 0 or hub.sounds[558132] ~= nil, "LibSharedMedia sounds claimed once across our addons")
M.done("WipeAndWin")
