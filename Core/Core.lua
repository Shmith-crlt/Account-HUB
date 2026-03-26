MRTE_GlobalDB = MRTE_GlobalDB or {}
MRTE_CharDB = MRTE_CharDB or {}

MidnightRaidToolsElite = {}
local MRTE = MidnightRaidToolsElite

function MRTE:InitDB()
 MRTE_GlobalDB.logs = MRTE_GlobalDB.logs or {}
 MRTE_GlobalDB.logsByCharacter = MRTE_GlobalDB.logsByCharacter or {}
 MRTE_GlobalDB.characters = MRTE_GlobalDB.characters or {}
 MRTE_GlobalDB.guild = MRTE_GlobalDB.guild or {}
 MRTE_GlobalDB.mdtOverlay = MRTE_GlobalDB.mdtOverlay or {}
 if MRTE_GlobalDB.mdtOverlay.detached == nil then
  MRTE_GlobalDB.mdtOverlay.detached = false
 end
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")

f:SetScript("OnEvent", function()
 MRTE:InitDB()
 if MRTE_EnsureCurrentCharacterProfile then
  MRTE_EnsureCurrentCharacterProfile()
 end

 MRTE_CreateMainUI()
 MRTE_CreatePanels()
 if MRTE_CreateBiSTargetsPanel then
  MRTE_CreateBiSTargetsPanel()
 end
 if MRTE_CreateCharacterTabs then
  MRTE_CreateCharacterTabs()
 end

 if MRTE_SelectCurrentCharacter then
  MRTE_SelectCurrentCharacter(true)
 end

 MRTE_CreateMinimapButton()

 if MRTE_UpdateMythicPanel then
  MRTE_UpdateMythicPanel()
 end

 if MRTE_UpdateVault then
  MRTE_UpdateVault()
 end

 if MRTE_UpdateSeasonCurrencies then
  MRTE_UpdateSeasonCurrencies()
 end

 if MRTE_UpdateSeasonPortals then
  MRTE_UpdateSeasonPortals()
 end

 if MRTE_UpdateBiSTargetsPanel then
  MRTE_UpdateBiSTargetsPanel()
 end

 if MRTE_UpdateDungeonItemLevelPanel then
  MRTE_UpdateDungeonItemLevelPanel()
 end

 if MRTE_UpdateGuildPanel then
  MRTE_UpdateGuildPanel()
 end

 if MRTE_RefreshMDTOverlay then
  MRTE_RefreshMDTOverlay(true, false)
 end
end)

local dungeonFrame = CreateFrame("Frame")
dungeonFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

dungeonFrame:SetScript("OnEvent", function()
 if MRTE_RefreshMDTOverlay then
  MRTE_RefreshMDTOverlay(true, false)
 end
end)
