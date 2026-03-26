local L = MRTE_L

local TAB_WIDTH = 132
local TAB_HEIGHT = 22
local TAB_GAP_X = 6
local TAB_GAP_Y = 4
local TABS_PER_ROW = 7
local MAX_TAB_ROWS = 2
local MAX_VISIBLE_TABS = TABS_PER_ROW * MAX_TAB_ROWS
local EQUIPPED_SLOT_IDS = { 1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17 }

local function GetNow()
 if GetServerTime then
  return GetServerTime()
 end

 if time then
  return time()
 end

 return 0
end

local function GetCharacterClassColor(classFileName)
 local classColors = CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS
 local color = classColors and classFileName and classColors[classFileName]
 return color or HIGHLIGHT_FONT_COLOR
end

local function GetPlayerCharacterIdentity()
 local name
 local realm

 if UnitFullName then
  name, realm = UnitFullName("player")
 end

 if not name or name == "" then
  local fullName = GetUnitName and GetUnitName("player", true)
  if type(fullName) == "string" and fullName ~= "" then
   name, realm = fullName:match("^([^-]+)%-(.+)$")
   name = name or fullName
  end
 end

 if not realm or realm == "" then
  realm = GetRealmName and GetRealmName() or ""
 end

 if not name or name == "" then
  return nil
 end

 local fullName = realm ~= "" and (name .. "-" .. realm) or name

 return {
  key = fullName,
  name = name,
  realm = realm,
  fullName = fullName,
 }
end

local function EnsureCharacterStorage()
 MRTE_GlobalDB.characters = MRTE_GlobalDB.characters or {}
 MRTE_GlobalDB.logsByCharacter = MRTE_GlobalDB.logsByCharacter or {}
end

function MRTE_CopyTable(value)
 if type(value) ~= "table" then
  return value
 end

 local copy = {}

 for key, nestedValue in pairs(value) do
  copy[key] = MRTE_CopyTable(nestedValue)
 end

 return copy
end

function MRTE_GetCurrentCharacterKey()
 local identity = GetPlayerCharacterIdentity()
 return identity and identity.key or nil
end

function MRTE_GetCharacterProfile(characterKey)
 EnsureCharacterStorage()

 if not characterKey then
  return nil
 end

 return MRTE_GlobalDB.characters[characterKey]
end

function MRTE_EnsureCurrentCharacterProfile()
 EnsureCharacterStorage()

 local identity = GetPlayerCharacterIdentity()
 if not identity then
  return nil
 end

 local classDisplayName, classFileName, classID = UnitClass and UnitClass("player")
 local specIndex = GetSpecialization and GetSpecialization()
 local specID
 local specName
 local equipment = {}

 if specIndex and GetSpecializationInfo then
  specID, specName = GetSpecializationInfo(specIndex)
 end

 for _, slotID in ipairs(EQUIPPED_SLOT_IDS) do
  equipment[slotID] = GetInventoryItemID and GetInventoryItemID("player", slotID) or 0
 end

 local profile = MRTE_GlobalDB.characters[identity.key] or {}

 profile.key = identity.key
 profile.name = identity.name
 profile.realm = identity.realm
 profile.fullName = identity.fullName
 profile.displayName = identity.name
 profile.class = classDisplayName
 profile.classFileName = classFileName
 profile.classID = classID
 profile.specID = specID
 profile.specName = specName
 profile.equipment = equipment
 profile.lastSeen = GetNow()

 MRTE_GlobalDB.characters[identity.key] = profile
 MRTE_CharDB.currentCharacterKey = identity.key

 return profile
end

function MRTE_GetSelectedCharacterKey()
 EnsureCharacterStorage()

 if MRTE_SelectedCharacterKey and MRTE_GlobalDB.characters[MRTE_SelectedCharacterKey] then
  return MRTE_SelectedCharacterKey
 end

 return MRTE_GetCurrentCharacterKey()
end

function MRTE_GetSelectedCharacterProfile()
 return MRTE_GetCharacterProfile(MRTE_GetSelectedCharacterKey())
end

function MRTE_IsViewingCurrentCharacter()
 return MRTE_GetSelectedCharacterKey() == MRTE_GetCurrentCharacterKey()
end

function MRTE_GetCharacterLogs(characterKey)
 EnsureCharacterStorage()
 characterKey = characterKey or MRTE_GetSelectedCharacterKey()
 return MRTE_GlobalDB.logsByCharacter[characterKey] or {}
end

function MRTE_GetCharacterLogCount(characterKey)
 local logs = MRTE_GetCharacterLogs(characterKey)
 return type(logs) == "table" and #logs or 0
end

function MRTE_AppendCharacterLog(entry)
 EnsureCharacterStorage()

 local characterKey = MRTE_GetCurrentCharacterKey()
 if not characterKey then
  return
 end

 local logs = MRTE_GlobalDB.logsByCharacter[characterKey] or {}
 logs[#logs + 1] = MRTE_CopyTable(entry)
 MRTE_GlobalDB.logsByCharacter[characterKey] = logs

 local profile = MRTE_GetCharacterProfile(characterKey)
 if profile then
  profile.lastSeen = GetNow()
 end
end

function MRTE_SaveCharacterSection(sectionKey, data)
 if type(sectionKey) ~= "string" or sectionKey == "" then
  return
 end

 local profile = MRTE_EnsureCurrentCharacterProfile()
 if not profile then
  return
 end

 profile[sectionKey] = MRTE_CopyTable(data)
 profile.lastSeen = GetNow()
end

function MRTE_UpdateAllCharacterViews()
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
end

local function BuildSortedCharacterProfiles()
 EnsureCharacterStorage()

 local currentCharacterKey = MRTE_GetCurrentCharacterKey()
 local profiles = {}

 for _, profile in pairs(MRTE_GlobalDB.characters) do
  if type(profile) == "table" and profile.key then
   profiles[#profiles + 1] = profile
  end
 end

 table.sort(profiles, function(left, right)
  local leftIsCurrent = left.key == currentCharacterKey
  local rightIsCurrent = right.key == currentCharacterKey

  if leftIsCurrent ~= rightIsCurrent then
   return leftIsCurrent
  end

  local leftSeen = tonumber(left.lastSeen) or 0
  local rightSeen = tonumber(right.lastSeen) or 0

  if leftSeen ~= rightSeen then
   return leftSeen > rightSeen
  end

  return (left.displayName or left.name or "") < (right.displayName or right.name or "")
 end)

 return profiles
end

local function ApplyCharacterTabStyle(tab, profile, isSelected, isCurrentCharacter)
 if not tab or not profile then
  return
 end

 local classColor = GetCharacterClassColor(profile.classFileName)

 tab.characterKey = profile.key
 tab.text:SetText(profile.displayName or profile.name or L.UNKNOWN)
 tab.text:SetTextColor(classColor.r or 1, classColor.g or 1, classColor.b or 1)

 if isSelected then
  tab:SetBackdropColor(0.17, 0.13, 0.05, 0.98)
  tab:SetBackdropBorderColor(0.86, 0.68, 0.20, 1)
 elseif isCurrentCharacter then
  tab:SetBackdropColor(0.08, 0.12, 0.09, 0.96)
  tab:SetBackdropBorderColor(0.28, 0.58, 0.31, 1)
 else
  tab:SetBackdropColor(0.07, 0.07, 0.08, 0.96)
  tab:SetBackdropBorderColor(0.24, 0.19, 0.10, 1)
 end

 if isCurrentCharacter then
  tab.removeButton:Hide()
 else
  tab.removeButton:Show()
 end

 tab:Show()
end

local function CreateCharacterTab(parent)
 local tab = CreateFrame("Button", nil, parent, "BackdropTemplate")
 tab:SetSize(TAB_WIDTH, TAB_HEIGHT)
 tab:RegisterForClicks("LeftButtonUp", "RightButtonUp")
 tab:SetBackdrop({
  bgFile = "Interface/Buttons/WHITE8X8",
  edgeFile = "Interface/Buttons/WHITE8X8",
  edgeSize = 1,
  insets = {
   left = 1,
   right = 1,
   top = 1,
   bottom = 1,
  },
 })
 tab:SetBackdropColor(0.07, 0.07, 0.08, 0.96)
 tab:SetBackdropBorderColor(0.24, 0.19, 0.10, 1)

 tab.text = tab:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
 tab.text:SetPoint("LEFT", 10, 0)
 tab.text:SetPoint("RIGHT", -24, 0)
 tab.text:SetJustifyH("LEFT")

 tab.removeButton = CreateFrame("Button", nil, tab, "BackdropTemplate")
 tab.removeButton:SetSize(14, 14)
 tab.removeButton:SetPoint("RIGHT", -5, 0)
 tab.removeButton:SetBackdrop({
  bgFile = "Interface/Buttons/WHITE8X8",
  edgeFile = "Interface/Buttons/WHITE8X8",
  edgeSize = 1,
  insets = {
   left = 1,
   right = 1,
   top = 1,
   bottom = 1,
  },
 })
 tab.removeButton:SetBackdropColor(0.16, 0.08, 0.08, 0.98)
 tab.removeButton:SetBackdropBorderColor(0.58, 0.22, 0.22, 1)

 tab.removeButton.text = tab.removeButton:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
 tab.removeButton.text:SetPoint("CENTER", 0, 0)
 tab.removeButton.text:SetText("x")
 tab.removeButton.text:SetTextColor(1.00, 0.90, 0.90)

 tab.removeButton:SetScript("OnClick", function(self)
  local parentTab = self:GetParent()
  if parentTab and parentTab.characterKey then
   MRTE_RemoveCharacterProfile(parentTab.characterKey)
  end
 end)

 tab.removeButton:SetScript("OnEnter", function(self)
  GameTooltip:SetOwner(self, "ANCHOR_TOP")
  GameTooltip:ClearLines()
  GameTooltip:AddLine(L.REMOVE_CHARACTER_DATA, 1, 1, 1)
  GameTooltip:Show()
 end)

 tab.removeButton:SetScript("OnLeave", function()
  GameTooltip_Hide()
 end)

 tab:SetScript("OnClick", function(self, button)
  if button == "RightButton" then
   MRTE_RemoveCharacterProfile(self.characterKey)
   return
  end

  MRTE_SelectCharacter(self.characterKey)
 end)

 return tab
end

function MRTE_UpdateCharacterTabs()
 local bar = MRTE_CharacterTabBar
 if not bar then
  return
 end

 local profiles = BuildSortedCharacterProfiles()
 local currentCharacterKey = MRTE_GetCurrentCharacterKey()
 local selectedCharacterKey = MRTE_GetSelectedCharacterKey()

 for index = 1, MAX_VISIBLE_TABS do
  local tab = bar.tabs[index]
  if not tab then
   tab = CreateCharacterTab(bar)
   bar.tabs[index] = tab
  end

  local profile = profiles[index]

  if profile then
   local row = math.floor((index - 1) / TABS_PER_ROW)
   local column = (index - 1) % TABS_PER_ROW

   tab:ClearAllPoints()
   tab:SetPoint("TOPLEFT", column * (TAB_WIDTH + TAB_GAP_X), -(row * (TAB_HEIGHT + TAB_GAP_Y)))
   ApplyCharacterTabStyle(tab, profile, profile.key == selectedCharacterKey, profile.key == currentCharacterKey)
  else
   tab.characterKey = nil
   tab:Hide()
  end
 end
end

function MRTE_SelectCharacter(characterKey, skipRefresh)
 EnsureCharacterStorage()

 if not characterKey or not MRTE_GlobalDB.characters[characterKey] then
  characterKey = MRTE_GetCurrentCharacterKey()
 end

 if not characterKey then
  return false
 end

 MRTE_SelectedCharacterKey = characterKey
 MRTE_UpdateCharacterTabs()

 if MRTE_IsViewingCurrentCharacter() then
  MRTE_SetStatus("")
 else
  local profile = MRTE_GetCharacterProfile(characterKey)
  local displayName = profile and (profile.displayName or profile.name) or characterKey
  MRTE_SetStatus(MRTE_T("VIEWING_CHARACTER", displayName))
 end

 if not skipRefresh then
  MRTE_UpdateAllCharacterViews()
 end

 return true
end

function MRTE_SelectCurrentCharacter(skipRefresh)
 return MRTE_SelectCharacter(MRTE_GetCurrentCharacterKey(), skipRefresh)
end

function MRTE_RemoveCharacterProfile(characterKey)
 EnsureCharacterStorage()

 local currentCharacterKey = MRTE_GetCurrentCharacterKey()
 if not characterKey or not MRTE_GlobalDB.characters[characterKey] then
  return false
 end

 if characterKey == currentCharacterKey then
  MRTE_SetStatus(L.CANNOT_REMOVE_CURRENT_CHARACTER)
  return false
 end

 local profile = MRTE_GlobalDB.characters[characterKey]
 MRTE_GlobalDB.characters[characterKey] = nil
 MRTE_GlobalDB.logsByCharacter[characterKey] = nil

 if MRTE_SelectedCharacterKey == characterKey then
  MRTE_SelectedCharacterKey = currentCharacterKey
 end

 MRTE_UpdateCharacterTabs()
 MRTE_UpdateAllCharacterViews()
 MRTE_SetStatus(MRTE_T("CHARACTER_DATA_REMOVED", (profile and (profile.displayName or profile.name)) or characterKey))

 return true
end

function MRTE_CreateCharacterTabs()
 if not MRTE_MainFrame then
  return
 end

 if MRTE_CharacterTabBar then
  MRTE_UpdateCharacterTabs()
  return
 end

 local bar = CreateFrame("Frame", nil, MRTE_MainFrame)
 bar:SetSize((TAB_WIDTH * TABS_PER_ROW) + (TAB_GAP_X * (TABS_PER_ROW - 1)), (TAB_HEIGHT * MAX_TAB_ROWS) + TAB_GAP_Y)
 bar:SetPoint("BOTTOM", 0, 12)
 bar.tabs = {}

 bar.background = bar:CreateTexture(nil, "BACKGROUND")
 bar.background:SetAllPoints()
 bar.background:SetColorTexture(0.03, 0.03, 0.04, 0.20)

 bar.topLine = bar:CreateTexture(nil, "BORDER")
 bar.topLine:SetPoint("TOPLEFT", 0, 0)
 bar.topLine:SetPoint("TOPRIGHT", 0, 0)
 bar.topLine:SetHeight(1)
 bar.topLine:SetColorTexture(0.72, 0.58, 0.18, 0.35)

 MRTE_MainFrame.characterTabBar = bar
 MRTE_CharacterTabBar = bar

 MRTE_UpdateCharacterTabs()
end
