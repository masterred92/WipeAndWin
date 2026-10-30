-- Wipe & Win Lines: puts in-game voice lines into the victory and wipe sound lists that DBM and BigWigs already have.
-- DBM: through its own sound-pack loader (## X-DBM-VictoryPack / ## X-DBM-DefeatPack in the TOC, which calls the
--      global functions below). BigWigs (Victory and Wipe plugins) and every other LibSharedMedia user: through LSM.
-- Every sound is already in the WoW: Forever client and is played by FileDataID. Nothing is bundled.
local _, ns = ...

ns.Victory = {
  { "Peon: Job's done!", 558132 },
  { "PvP: Horde victory", 568480 },
  { "PvP: Alliance victory", 569678 },
  { "Level up", 569593 },
}
ns.Defeat = {
  { "Ragnaros: DIE, INSECT!", 558795 },
  { "C'Thun: You will die.", 546633 },
  { "VanCleef: None may challenge the Brotherhood!", 547946 },
  { "Murloc: Mrglglglgl!", 555997 },
  { "Kobold: You no take candle!", 553311 },
  { "Peon: grumbling", 558133 },
}
local PREFIX = "Wipe & Win: "
local LENGTH = 4 -- DBM uses this to space out back-to-back sounds; all of these lines are shorter

local added = { victory = false, defeat = false, lsm = false }
ns.added = added

local function addToDBM(list, method)
  if type(DBM) ~= "table" or type(DBM[method]) ~= "function" then return false end
  for _, s in ipairs(list) do
    local ok = pcall(DBM[method], DBM, PREFIX .. s[1], s[2], LENGTH)
    if not ok then return false end
  end
  return true
end

-- Called by DBM-Core 0.01 s after it loads this addon (X-DBM-VictoryPack-GlobalName / X-DBM-DefeatPack-GlobalName).
function WipeAndWin_AddVictory()
  if added.victory then return end
  added.victory = addToDBM(ns.Victory, "AddVictorySound")
end
function WipeAndWin_AddDefeat()
  if added.defeat then return end
  added.defeat = addToDBM(ns.Defeat, "AddDefeatSound")
end

function ns.RegisterLSM()
  if added.lsm or type(LibStub) ~= "table" then return added.lsm end
  local LSM = LibStub("LibSharedMedia-3.0", true)
  if not LSM then return false end
  local SOUND = LSM.MediaType and LSM.MediaType.SOUND or "sound"
  for _, list in ipairs({ ns.Victory, ns.Defeat }) do
    for _, s in ipairs(list) do
      -- one LibSharedMedia entry per sound across our addons (QuestieJobsDone also offers "Job's done!")
      if ns.Hub.ClaimSound(s[2], PREFIX .. s[1]) then pcall(LSM.Register, LSM, SOUND, PREFIX .. s[1], s[2]) end
    end
  end
  added.lsm = true
  return true
end

ns.Core.Setup({ cmd = "/wipewin", required = { "PlaySoundFile" },
  optional = { "DBM.AddVictorySound", "DBM.AddDefeatSound", "LibStub" },
  debugLines = function()
    return { ("added to DBM: victory %s, defeat %s; LibSharedMedia (BigWigs): %s"):format(tostring(added.victory), tostring(added.defeat), tostring(added.lsm)) }
  end })

local function say(msg) print("|cffffd200Wipe & Win|r: " .. msg) end

SLASH_WIPEANDWIN1 = "/wipewin"
SlashCmdList.WIPEANDWIN = function(msg)
  msg = strtrim((msg or ""):lower())
  if msg == "debug" then ns.Core.PrintDebug() return end
  local which, n = msg:match("^(%a+)%s*(%d*)$")
  local list = (which == "win" and ns.Victory) or (which == "wipe" and ns.Defeat)
  if list then
    if InCombatLockdown() then say("not in combat.") return end
    local s = list[tonumber(n) or 1]
    if not s then say(("pick 1-%d."):format(#list)) return end
    if not ns.Hub.PlayVoice(s[2], "Master", LENGTH) then say("another voice line is playing; try again in a moment.") return end
    say(s[1])
    return
  end
  say("lines are in DBM > Options > Event sounds and in BigWigs > Victory / Wipe (pick a \"Wipe & Win:\" sound).")
  for i, s in ipairs(ns.Victory) do say(("win %d: %s"):format(i, s[1])) end
  for i, s in ipairs(ns.Defeat) do say(("wipe %d: %s"):format(i, s[1])) end
  say("/wipewin win 1 or /wipewin wipe 3 plays one.")
  say(("added to DBM: %s, LibSharedMedia/BigWigs: %s"):format((added.victory and added.defeat) and "yes" or "no", added.lsm and "yes" or "no"))
end

local ev = CreateFrame("Frame")
ev:RegisterEvent("ADDON_LOADED")
ev:RegisterEvent("PLAYER_LOGIN")
ev:RegisterEvent("ENCOUNTER_END")
ev:SetScript("OnEvent", function(self, event)
  -- DBM plays its victory/defeat sound now: our other addons' voice lines wait until it is over.
  if event == "ENCOUNTER_END" then if added.victory or added.defeat or added.lsm then ns.Hub.MarkVoiceBusy(LENGTH) end return end
  -- LSM may come in with a later addon (BigWigs, a load-on-demand host), so keep trying until it is there.
  if ns.RegisterLSM() then self:UnregisterEvent("ADDON_LOADED") end
  if event == "PLAYER_LOGIN" then self:UnregisterEvent("PLAYER_LOGIN") end
end)
