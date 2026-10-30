# Changelog

## 1.1.0
- Other voice addons in the family wait while DBM plays your victory or defeat line.
- The 'Job's done!' sound shared with Questie: Job's Done appears only once in LibSharedMedia.
- `/wipewin debug` checks your setup: client version, every game API the addon needs, and which of Kenny's other addons it is working with.
- A loud chat warning if this client is missing an API the addon needs, instead of failing silently.
- English text now lives in `Locales/enUS.lua`, ready for translations.
- Shared code (KennyShared) is identical in every addon of the family and checked in CI, along with every Blizzard API call (against the Forever UI source) and every DBM/BigWigs/Questie API call (against their source).

## 1.0.0 (first release)
- First release. Four victory and six defeat lines, added to DBM's victory/defeat sound lists through DBM's sound-pack loader and to LibSharedMedia.
- `/wipewin` list and preview. Sounds are played by ID from the client; nothing is bundled.
- Game version: WoW: Forever 1.60.1 (Interface 16001).
