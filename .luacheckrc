std = "lua51"
max_line_length = false
exclude_files = { "tests/**", "tools/**", ".release/**", ".lua/**", ".luarocks/**" }
-- Our own globals.
globals = { "WipeAndWin_AddVictory", "WipeAndWin_AddDefeat", "SLASH_WIPEANDWIN1", "SlashCmdList" }
-- WoW API (checked against Blizzard's UI source by tools/verify_api.py) and host-addon globals (tools/host_api.py).
read_globals = { "CreateFrame", "InCombatLockdown", "PlaySoundFile", "strtrim", "DBM", "LibStub" }
