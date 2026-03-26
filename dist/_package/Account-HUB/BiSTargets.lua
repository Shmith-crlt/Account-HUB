local L = MRTE_L

local KNOWN_CHALLENGE_MAP_SOURCES = {
 [378] = "Halls of Atonement",
 [391] = "Tazavesh, the Veiled Market",
 [392] = "Tazavesh, the Veiled Market",
 [499] = "Priory of the Sacred Flame",
 [503] = "Ara-Kara, City of Echoes",
 [505] = "The Dawnbreaker",
 [525] = "Operation: Floodgate",
 [542] = "Eco-Dome Al'dani",
}
local SOURCE_NAME_ALIASES = {
 arakara = "Ara-Kara, City of Echoes",
 arakaracityofechoes = "Ara-Kara, City of Echoes",
 arakarastadtderechos = "Ara-Kara, City of Echoes",
 ecodomealdani = "Eco-Dome Al'dani",
 biokuppelaldani = "Eco-Dome Al'dani",
 hallsofatonement = "Halls of Atonement",
 hallendersuehne = "Halls of Atonement",
 liberationofundermine = "Liberation of Undermine",
 manaforgeomega = "Manaforge Omega",
 manaschmiedeomega = "Manaforge Omega",
 nerubarpalace = "Nerub-ar Palace",
 nerubarpalast = "Nerub-ar Palace",
 operationfloodgate = "Operation: Floodgate",
 operationschleuse = "Operation: Floodgate",
 prioryofsacredflame = "Priory of the Sacred Flame",
 prioryofthesacredflame = "Priory of the Sacred Flame",
 prioratderheiligenflamme = "Priory of the Sacred Flame",
 tazaveshderverhuelltemarkt = "Tazavesh, the Veiled Market",
 tazaveshtheveiledmarket = "Tazavesh, the Veiled Market",
 tazaveshstreetsofwonder = "Tazavesh, the Veiled Market",
 tazaveshsoleahsgambit = "Tazavesh, the Veiled Market",
 tazaveshwundersamestrassen = "Tazavesh, the Veiled Market",
 tazaveshsoleahsschachzug = "Tazavesh, the Veiled Market",
 thedawnbreaker = "The Dawnbreaker",
 diemorgenbringer = "The Dawnbreaker",
}
local LOCALIZED_SOURCE_NAMES = {
 enUS = {},
 deDE = {
  ["Ara-Kara, City of Echoes"] = "Ara-Kara, Stadt der Echos",
  ["Eco-Dome Al'dani"] = "Biokuppel Al'dani",
  ["Halls of Atonement"] = "Hallen der Suehne",
  ["Manaforge Omega"] = "Manaschmiede Omega",
  ["Nerub-ar Palace"] = "Nerub-ar-Palast",
  ["Operation: Floodgate"] = "Operation: Schleuse",
  ["Priory of the Sacred Flame"] = "Priorat der Heiligen Flamme",
  ["Tazavesh, the Veiled Market"] = "Tazavesh, der Verhuellte Markt",
  ["The Dawnbreaker"] = "Die Morgenbringer",
 },
}
local SHORT_SOURCE_NAMES = {
 enUS = {
  ["Ara-Kara, City of Echoes"] = "Ara-Kara",
  ["Eco-Dome Al'dani"] = "Eco-Dome",
  ["Halls of Atonement"] = "HoA",
  ["Liberation of Undermine"] = "Undermine",
  ["Manaforge Omega"] = "Manaforge",
  ["Nerub-ar Palace"] = "Nerub-ar",
  ["Operation: Floodgate"] = "Floodgate",
  ["Priory of the Sacred Flame"] = "Priory",
  ["Tazavesh, the Veiled Market"] = "Tazavesh",
  ["The Dawnbreaker"] = "Dawnbreaker",
 },
 deDE = {
  ["Ara-Kara, City of Echoes"] = "Ara-Kara",
  ["Eco-Dome Al'dani"] = "Biokuppel",
  ["Halls of Atonement"] = "HdS",
  ["Liberation of Undermine"] = "Undermine",
  ["Manaforge Omega"] = "Manaschmiede",
  ["Nerub-ar Palace"] = "Nerub-ar",
  ["Operation: Floodgate"] = "Schleuse",
  ["Priory of the Sacred Flame"] = "Priorat",
  ["Tazavesh, the Veiled Market"] = "Tazavesh",
  ["The Dawnbreaker"] = "Morgenbringer",
 },
}
local SOURCE_COLORS = {
 dungeon = { r = 0.90, g = 0.94, b = 1.00 },
 raid = { r = 1.00, g = 0.90, b = 0.78 },
 other = { r = 0.88, g = 0.88, b = 0.88 },
 }

local function Trim(text)
 if type(text) ~= "string" then
  return ""
 end

 return strtrim(text)
end

local function NormalizeSourceKey(source)
 if type(source) ~= "string" then
  return ""
 end

 local normalized = string.lower(source)
 normalized = normalized:gsub("\195\164", "ae")
 normalized = normalized:gsub("\195\182", "oe")
 normalized = normalized:gsub("\195\188", "ue")
 normalized = normalized:gsub("\195\159", "ss")
 normalized = normalized:gsub("\195\169", "e")
 normalized = normalized:gsub("[^%a%d]", "")
 return normalized
end

local function CanonicalizeSourceName(source)
 if type(source) ~= "string" or source == "" then
  return nil
 end

 local normalized = NormalizeSourceKey(source)
 if normalized == "" then
  return nil
 end

 return SOURCE_NAME_ALIASES[normalized] or source
end

local function GetLocalizedSourceName(source)
 if type(source) ~= "string" or source == "" then
  return L.BIS_UNKNOWN_SOURCE
 end

 local localeSources = LOCALIZED_SOURCE_NAMES[MRTE_Locale] or LOCALIZED_SOURCE_NAMES.enUS
 return (localeSources and localeSources[source]) or source
end

local function GetShortSourceName(source)
 if type(source) ~= "string" or source == "" then
  return L.BIS_UNKNOWN_SOURCE
 end

 local localeSources = SHORT_SOURCE_NAMES[MRTE_Locale] or SHORT_SOURCE_NAMES.enUS
 return (localeSources and localeSources[source]) or GetLocalizedSourceName(source)
end

local function ApplySimpleSectionStyle(frame)
 frame:SetBackdrop({
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
 frame:SetBackdropColor(0.05, 0.05, 0.06, 0.96)
 frame:SetBackdropBorderColor(0.23, 0.18, 0.10, 1)
end

local function ApplyBiSRowStyle(frame, sourceType)
 local accent = SOURCE_COLORS[sourceType or "other"] or SOURCE_COLORS.other

 frame:SetBackdrop({
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
 frame:SetBackdropColor(0.06, 0.06, 0.07, 0.94)
 frame:SetBackdropBorderColor((accent.r or 0.7) * 0.6, (accent.g or 0.7) * 0.6, (accent.b or 0.7) * 0.6, 0.95)
end

local function ApplyIconFrameStyle(frame)
 frame:SetBackdrop({
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
 frame:SetBackdropColor(0.01, 0.01, 0.02, 1)
 frame:SetBackdropBorderColor(0.38, 0.30, 0.14, 1)
end

local function DisableTextWrap(fontString)
 if not fontString then
  return
 end

 if fontString.SetWordWrap then
  fontString:SetWordWrap(false)
 end

 if fontString.SetNonSpaceWrap then
  fontString:SetNonSpaceWrap(false)
 end

 if fontString.SetMaxLines then
  fontString:SetMaxLines(1)
 end
end

local function GetSelectedBiSProfile()
 return MRTE_GetSelectedCharacterProfile and MRTE_GetSelectedCharacterProfile() or nil
end

local function GetSelectedBiSCharacterKey()
 return MRTE_GetSelectedCharacterKey and MRTE_GetSelectedCharacterKey() or nil
end

local function GetNow()
 if GetServerTime then
  return GetServerTime()
 end

 if time then
  return time()
 end

 return 0
end

local function GetBiSImportProfile()
 local characterKey = GetSelectedBiSCharacterKey()
 if MRTE_GetCharacterProfile and characterKey then
  local profile = MRTE_GetCharacterProfile(characterKey)
  if profile then
   return profile
  end
 end

 return GetSelectedBiSProfile()
end

local function SaveSelectedRaidbotsImport(importData)
 local profile = GetBiSImportProfile()
 if not profile or type(importData) ~= "table" then
  return false, nil
 end

 profile.raidbotsImport = MRTE_CopyTable and MRTE_CopyTable(importData) or importData
 profile.lastSeen = GetNow()
 return true, profile
end

local function ClearSelectedRaidbotsImport()
 local profile = GetBiSImportProfile()
 if not profile then
  return false, nil
 end

 profile.raidbotsImport = nil
 profile.lastSeen = GetNow()
 return true, profile
end

local function GetSelectedRaidbotsImport()
 local profile = GetSelectedBiSProfile()
 local importData = profile and profile.raidbotsImport

 if type(importData) ~= "table" or type(importData.items) ~= "table" or #importData.items == 0 then
  return nil
 end

 return importData
end

local keystoneLootSourceLookup

local function GetKeystoneLootSourceLookup()
 if keystoneLootSourceLookup then
  return keystoneLootSourceLookup
 end

 local lookup = {}
 local data = MRTE_KeystoneLootImportData or {}

 for _, dungeonData in ipairs(data.dungeons or {}) do
  for _, itemID in ipairs(dungeonData.items or {}) do
   lookup[itemID] = {
    sourceType = "dungeon",
    sourceID = dungeonData.challengeModeId,
   }
  end
 end

 for _, bossData in ipairs(data.raidBosses or {}) do
  for _, itemID in ipairs(bossData.items or {}) do
   lookup[itemID] = {
    sourceType = "raid",
    sourceID = bossData.bossId,
   }
  end
 end

 keystoneLootSourceLookup = lookup
 return keystoneLootSourceLookup
end

local function GetItemNameFromID(itemID)
 itemID = tonumber(itemID)
 if not itemID or itemID <= 0 then
  return nil
 end

 local itemName = GetItemInfo and GetItemInfo(itemID)
 if itemName then
  return itemName
 end

 if C_Item and C_Item.GetItemNameByID then
  itemName = C_Item.GetItemNameByID(itemID)
  if itemName then
   return itemName
  end
 end

 if C_Item and C_Item.RequestLoadItemDataByID then
  pcall(C_Item.RequestLoadItemDataByID, itemID)
 end

 return nil
end

local function GetItemIconFromID(itemID)
 itemID = tonumber(itemID)
 if not itemID or itemID <= 0 then
  return 134400
 end

 if GetItemInfoInstant then
  local iconFileID = select(5, GetItemInfoInstant(itemID))
  if iconFileID then
   return iconFileID
  end
 end

 if C_Item and C_Item.GetItemIconByID then
  local iconFileID = C_Item.GetItemIconByID(itemID)
  if iconFileID then
   return iconFileID
  end
 end

 return 134400
end

local function GetItemLinkFromID(itemID)
 itemID = tonumber(itemID)
 if not itemID or itemID <= 0 then
  return nil
 end

 if GetItemInfo then
  local _, itemLink = GetItemInfo(itemID)
  if itemLink then
   return itemLink
  end
 end

 return "item:" .. itemID
end

local function GetItemQualityColorData(itemID)
 local quality
 if GetItemInfo then
  quality = select(3, GetItemInfo(itemID))
 end

 if quality == nil and C_Item and C_Item.GetItemQualityByID then
  quality = C_Item.GetItemQualityByID(itemID)
 end

 if type(quality) ~= "number" then
  return 1, 0.62, 0.62, 0.62
 end

 local red, green, blue = GetItemQualityColor(quality)
 return quality, red or 0.62, green or 0.62, blue or 0.62
end

local function GetSourceIcon(sourceType, sourceID)
 if sourceType == "dungeon" and sourceID and C_ChallengeMode and C_ChallengeMode.GetMapUIInfo then
  local _, _, _, texture = C_ChallengeMode.GetMapUIInfo(tonumber(sourceID) or 0)
  if texture then
   return texture
  end
 end

 return 134400
end

local function ResolveImportedSource(sourceData)
 if type(sourceData) ~= "table" then
  return nil, L.BIS_UNKNOWN_SOURCE, L.BIS_UNKNOWN_SOURCE, "other"
 end

 if sourceData.sourceType == "dungeon" then
  local challengeModeId = tonumber(sourceData.sourceID) or 0
  local dungeonName = C_ChallengeMode and C_ChallengeMode.GetMapUIInfo and C_ChallengeMode.GetMapUIInfo(challengeModeId)
  local canonicalName = CanonicalizeSourceName(dungeonName) or dungeonName
  if canonicalName and canonicalName ~= "" then
   return canonicalName, GetLocalizedSourceName(canonicalName), GetShortSourceName(canonicalName), "dungeon"
  end

  local fallbackName = MRTE_T("BIS_DUNGEON_FALLBACK", challengeModeId)
  return fallbackName, fallbackName, fallbackName, "dungeon"
 end

 if sourceData.sourceType == "raid" then
  local bossId = tonumber(sourceData.sourceID) or 0
  local bossName = EJ_GetEncounterInfo and EJ_GetEncounterInfo(bossId)
  bossName = bossName or MRTE_T("BIS_BOSS_FALLBACK", bossId)
  return bossName, bossName, bossName, "raid"
 end

 return nil, L.BIS_UNKNOWN_SOURCE, L.BIS_UNKNOWN_SOURCE, "other"
end

local function GetCurrentSeasonDungeonLookup()
 local lookup = {}
 local displayNames = {}

 if not C_ChallengeMode or not C_ChallengeMode.GetMapTable or not C_ChallengeMode.GetMapUIInfo then
  return lookup, displayNames
 end

 local challengeMaps = C_ChallengeMode.GetMapTable()
 if type(challengeMaps) ~= "table" then
  return lookup, displayNames
 end

 for _, challengeMapID in ipairs(challengeMaps) do
  local dungeonName = C_ChallengeMode.GetMapUIInfo(challengeMapID)
  local canonicalName = KNOWN_CHALLENGE_MAP_SOURCES[challengeMapID] or CanonicalizeSourceName(dungeonName)
  if type(canonicalName) == "string" and canonicalName ~= "" then
   lookup[canonicalName] = true
   displayNames[canonicalName] = GetLocalizedSourceName(canonicalName)
  end
 end

 return lookup, displayNames
end

local function IsIgnoredSource(source)
 return not source
  or source == ""
  or source == "Crafted"
  or source == "Tier / Catalyst"
  or source == "Tier Set"
  or source == "Catalyst"
end

local function GetPriorityWeight(priority)
 priority = tonumber(priority) or 3
 return math.max(25, 105 - (priority * 20))
end

local function SortTargetItems(left, right)
 if (left.rawScore or 0) ~= (right.rawScore or 0) then
  return (left.rawScore or 0) > (right.rawScore or 0)
 end

 if (left.priority or 99) ~= (right.priority or 99) then
  return (left.priority or 99) < (right.priority or 99)
 end

 if left.sourceType ~= right.sourceType then
  return left.sourceType == "dungeon"
 end

 if (left.source or "") ~= (right.source or "") then
  return (left.source or "") < (right.source or "")
 end

 return (left.slotID or 0) < (right.slotID or 0)
end

local function NormalizeActivityTargets(targetMap)
 local entries = {}
 local highestRaw = 0

 for _, entry in pairs(targetMap or {}) do
  entries[#entries + 1] = entry
  highestRaw = math.max(highestRaw, tonumber(entry.rawScore) or 0)
 end

 table.sort(entries, function(left, right)
  if (left.rawScore or 0) ~= (right.rawScore or 0) then
   return (left.rawScore or 0) > (right.rawScore or 0)
  end

  return (left.name or "") < (right.name or "")
 end)

 if highestRaw <= 0 then
  return entries
 end

 for _, entry in ipairs(entries) do
  local normalized = math.floor(((entry.rawScore or 0) / highestRaw) * 95 + 0.5)
  entry.score = math.max(25, normalized)
 end

 return entries
end

local function GetDungeonVaultRunsRemaining(profile)
 local dungeonRow = profile and profile.vault and profile.vault.rows and profile.vault.rows[2]
 local finalSlot = dungeonRow and dungeonRow[3]
 if not finalSlot then
  return 0
 end

 local threshold = tonumber(finalSlot.threshold) or 8
 local progress = tonumber(finalSlot.progress) or 0
 return math.max(threshold - progress, 0)
end

local function IsVaultWorthFilling(profile)
 local dungeonRow = profile and profile.vault and profile.vault.rows and profile.vault.rows[2]
 if type(dungeonRow) ~= "table" then
  return false
 end

 for _, slotData in ipairs(dungeonRow) do
  if not slotData.unlocked then
   return true
  end
 end

 return false
end

local function JoinActivityNames(targets, maxCount)
 local names = {}

 for index = 1, math.min(#targets, maxCount or #targets) do
  names[#names + 1] = targets[index].name
 end

 if #names == 0 then
  return nil
 end

 return table.concat(names, ", ")
end

local function BuildWeeklyTargetText(profile, dungeonTargets, raidTargets)
 local dungeonCount = #dungeonTargets
 local raidCount = #raidTargets

 if dungeonCount > 0 and raidCount > 0 then
  local runsRemaining = GetDungeonVaultRunsRemaining(profile)
  local suggestedRuns = math.max(2, math.min(4, runsRemaining > 0 and runsRemaining or 2))
  return MRTE_T("BIS_WEEKLY_TARGET_BALANCED", suggestedRuns, 1)
 end

 if dungeonCount > 0 then
  local runsRemaining = GetDungeonVaultRunsRemaining(profile)
  local suggestedRuns = math.max(4, runsRemaining)
  return MRTE_T("BIS_WEEKLY_TARGET_DUNGEONS", suggestedRuns)
 end

 if raidCount > 0 then
  return MRTE_T("BIS_WEEKLY_TARGET_RAID", 1)
 end

 return L.BIS_WEEKLY_TARGET_NONE
end

local function BuildRecommendationText(dungeonTargets, raidTargets)
 local topDungeon = dungeonTargets[1] and dungeonTargets[1].name or nil
 local raidSummary = JoinActivityNames(raidTargets, 2)

 if topDungeon and raidSummary then
  return MRTE_T("BIS_RECOMMENDATION_RUN_THEN", topDungeon, raidSummary)
 end

 if topDungeon then
  return MRTE_T("BIS_RECOMMENDATION_RUN_ONLY", topDungeon)
 end

 if raidSummary then
  return MRTE_T("BIS_RECOMMENDATION_RAID_ONLY", raidSummary)
 end

 return L.BIS_RECOMMENDATION_NONE
end

local function CleanImportLine(line)
 line = Trim((line or ""):gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""))
 line = line:gsub("^[-*%s]+", "")
 line = line:gsub("^%d+[.)]%s*", "")
 line = line:gsub("%s+$", "")
 return line
end

local function ExtractNumericScore(value)
 if type(value) ~= "string" then
  return nil
 end

 local normalized = value:lower()
 normalized = normalized:gsub(",", "")
 normalized = normalized:gsub("dps", "")
 normalized = normalized:gsub("score", "")
 normalized = normalized:gsub("upgrade", "")
 normalized = normalized:gsub("%%", "")

 local numberText = normalized:match("([%+%-]?%d+%.?%d*)")
 return numberText and tonumber(numberText) or nil
end

local function StripKnownPrefix(value)
 value = Trim(value)

 for _, prefix in ipairs({
  "boss:",
  "source:",
  "raid:",
  "dungeon:",
  "encounter:",
  "item:",
 }) do
  if value:lower():find(prefix, 1, true) == 1 then
   return Trim(value:sub(#prefix + 1))
  end
 end

 return value
end

local function SplitImportFields(line)
 local fields = {}
 local delimiter

 if line:find("|", 1, true) then
  delimiter = "|"
 elseif line:find("\t", 1, true) then
  delimiter = "\t"
 elseif line:find(";", 1, true) then
  delimiter = ";"
 end

 if not delimiter then
  return fields
 end

 local pattern
 if delimiter == "|" then
  pattern = "([^|]+)"
 elseif delimiter == "\t" then
  pattern = "([^\t]+)"
 else
  pattern = "([^;]+)"
 end

 for field in line:gmatch(pattern) do
  field = StripKnownPrefix(field)
  if field ~= "" then
   fields[#fields + 1] = field
  end
 end

 return fields
end

local function NormalizeReportTitle(line)
 line = CleanImportLine(line)
 if line == "" then
  return nil
 end

 local lowered = line:lower()
 if lowered:find("raidbots", 1, true) or lowered:find("droptimizer", 1, true) or lowered:find("top gear", 1, true) then
  return line
 end

 return nil
end

local function ParseImportRow(line, currentSource)
 local fields = SplitImportFields(line)

 if #fields == 0 then
  local itemName, scoreText = line:match("^(.-)%s+([%+%-]?[%d,%.]+%%?%s*[Dd][Pp][Ss]?)$")
  local parsedScore = ExtractNumericScore(scoreText or "")
  if currentSource and itemName and parsedScore then
   return {
    source = currentSource,
    itemName = StripKnownPrefix(itemName),
    rawScore = parsedScore,
   }
  end

  return nil, line
 end

 local scoreIndex
 local parsedScore
 local textFields = {}

 for index, field in ipairs(fields) do
  local numericScore = ExtractNumericScore(field)
  if numericScore and not scoreIndex then
   scoreIndex = index
   parsedScore = numericScore
  else
   textFields[#textFields + 1] = field
  end
 end

 if #textFields == 1 and currentSource and parsedScore then
  return {
   source = currentSource,
   itemName = textFields[1],
   rawScore = parsedScore,
  }
 end

 if #textFields < 2 then
  return nil, line
 end

 local source
 local itemName

 if scoreIndex == 1 then
  itemName = textFields[1]
  source = table.concat(textFields, " ", 2)
 elseif scoreIndex == #fields then
  source = textFields[1]
  itemName = table.concat(textFields, " ", 2)
 else
  source = textFields[1]
  itemName = table.concat(textFields, " ", 2)
 end

 if scoreIndex == #fields and #textFields >= 2 then
  local secondField = textFields[2]
  local canonicalSecond = CanonicalizeSourceName(secondField)
  if (canonicalSecond and canonicalSecond ~= secondField) or (#textFields[1] > (#secondField + 8)) then
   source = secondField
   itemName = textFields[1]
  end
 end

 source = StripKnownPrefix(source)
 itemName = StripKnownPrefix(itemName)

 if source == "" or itemName == "" then
  return nil, line
 end

 return {
  source = source,
  itemName = itemName,
  rawScore = parsedScore,
 }, source
end

local function ParseRaidbotsImportText(text)
 local dataStr = tostring(text or ""):gsub("%s+", "")
 if not dataStr:match("^KeystoneLoot:v1") then
  return nil
 end

 dataStr = dataStr:gsub("^KeystoneLoot:v1,?", "")

 local importData = {
  source = "keystoneloot",
  importedAt = GetNow(),
  reportTitle = "KeystoneLoot",
  specItems = {},
  items = {},
 }

 for specSection in dataStr:gmatch("([^,]+)") do
  local specID, itemsStr = specSection:match("^(%d+):(.+)$")
  if specID and itemsStr then
   specID = tonumber(specID)
   importData.specItems[specID] = importData.specItems[specID] or {}

   for itemID in itemsStr:gmatch("([^:]+)") do
    itemID = tonumber(itemID)
    if itemID then
     importData.specItems[specID][#importData.specItems[specID] + 1] = itemID
     importData.items[#importData.items + 1] = {
      specID = specID,
      itemID = itemID,
     }
    end
   end
  end
 end

 if not next(importData.specItems) then
  return nil
 end

 return importData
end

local function IsImportedItemEquipped(profile, itemID)
 itemID = tonumber(itemID)
 if not itemID or itemID <= 0 then
  return false
 end

 for _, equippedItemID in pairs(profile and profile.equipment or {}) do
  if tonumber(equippedItemID) == itemID then
   return true
  end
 end

 return false
end

local function GetImportedSpecID(profile, importData)
 local preferredSpecID = tonumber(profile and profile.specID) or 0
 if importData.specItems and importData.specItems[preferredSpecID] then
  return preferredSpecID
 end

 local availableSpecs = {}
 for specID in pairs(importData.specItems or {}) do
  availableSpecs[#availableSpecs + 1] = specID
 end

 table.sort(availableSpecs)
 return availableSpecs[1]
end

local function RebuildImportedItemEntries(importData)
 importData.items = {}

 for specID, itemList in pairs(importData.specItems or {}) do
  for _, itemID in ipairs(itemList or {}) do
   importData.items[#importData.items + 1] = {
    specID = tonumber(specID),
    itemID = tonumber(itemID),
   }
  end
 end
end

local function RemoveSelectedImportedItem(itemData)
 local profile = GetBiSImportProfile()
 local importData = profile and profile.raidbotsImport
 local itemID = tonumber(itemData and itemData.itemID)
 if not profile or type(importData) ~= "table" or type(importData.specItems) ~= "table" or not itemID then
  return false, nil, nil
 end

 local specID = tonumber(itemData and itemData.specID) or GetImportedSpecID(profile, importData)
 local itemList = specID and importData.specItems[specID]
 if type(itemList) ~= "table" then
  return false, nil, nil
 end

 for index = #itemList, 1, -1 do
  if tonumber(itemList[index]) == itemID then
   table.remove(itemList, index)
   break
  end
 end

 if #itemList == 0 then
  importData.specItems[specID] = nil
 end

 RebuildImportedItemEntries(importData)

 if not next(importData.specItems) or #importData.items == 0 then
  profile.raidbotsImport = nil
 else
  profile.raidbotsImport = importData
 end

 profile.lastSeen = GetNow()
 return true, profile, itemID
end

local function BuildImportedBiSTargetData(profile, importData)
 local targetItems = {}
 local activityBuckets = {
  dungeon = {},
  raid = {},
 }
 local selectedSpecID = GetImportedSpecID(profile, importData)
 local itemList = selectedSpecID and importData.specItems and importData.specItems[selectedSpecID] or {}
 local selectedSpecName
 local selectedSpecIcon
 if GetSpecializationInfoByID and selectedSpecID then
  local _, name, _, icon = GetSpecializationInfoByID(selectedSpecID)
  selectedSpecName = name
  selectedSpecIcon = icon
 end

 for index, itemID in ipairs(itemList or {}) do
  if not IsImportedItemEquipped(profile, itemID) then
   local sourceData = GetKeystoneLootSourceLookup()[itemID]
   local sourceKey, displaySource, shortSource, sourceType = ResolveImportedSource(sourceData)
   local _, qualityRed, qualityGreen, qualityBlue = GetItemQualityColorData(itemID)
   local targetItem = {
    slotID = 0,
    itemID = itemID,
    itemName = GetItemNameFromID(itemID) or ("Item " .. itemID),
    itemLink = GetItemLinkFromID(itemID),
    icon = GetItemIconFromID(itemID),
    specID = selectedSpecID,
    source = sourceKey,
    sourceID = sourceData and tonumber(sourceData.sourceID) or 0,
    displaySource = displaySource,
    shortSource = shortSource,
    sourceType = sourceType,
    priority = index,
    rawScore = GetPriorityWeight(index),
    qualityRed = qualityRed,
    qualityGreen = qualityGreen,
    qualityBlue = qualityBlue,
   }

   targetItems[#targetItems + 1] = targetItem

   local bucket = sourceKey and activityBuckets[sourceType]
   if bucket then
    local targetEntry = bucket[sourceKey] or {
     name = displaySource or sourceKey,
     rawScore = 0,
     sourceType = sourceType,
      sourceID = sourceData and tonumber(sourceData.sourceID) or 0,
      icon = GetSourceIcon(sourceType, sourceData and sourceData.sourceID),
      itemCount = 0,
      items = {},
    }

    targetEntry.rawScore = targetEntry.rawScore + GetPriorityWeight(index)
    targetEntry.itemCount = (targetEntry.itemCount or 0) + 1
    targetEntry.items[#targetEntry.items + 1] = itemID
    bucket[sourceKey] = targetEntry
   end
  end
 end

 table.sort(targetItems, SortTargetItems)
 local dungeonTargets = NormalizeActivityTargets(activityBuckets.dungeon)
 local raidTargets = NormalizeActivityTargets(activityBuckets.raid)

 return {
  error = nil,
  profile = profile,
  openItemsCount = #targetItems,
  targetItems = targetItems,
  dungeonTargets = dungeonTargets,
  raidTargets = raidTargets,
  topDungeon = dungeonTargets[1] and dungeonTargets[1].name or "-",
  topRaid = raidTargets[1] and raidTargets[1].name or "-",
  bestWeeklyTarget = BuildWeeklyTargetText(profile, dungeonTargets, raidTargets),
  recommendation = BuildRecommendationText(dungeonTargets, raidTargets),
  vaultWorthFilling = IsVaultWorthFilling(profile),
  selectedSpecID = selectedSpecID,
  selectedSpecName = selectedSpecName,
  selectedSpecIcon = selectedSpecIcon,
  reportTitle = selectedSpecName and ("KeystoneLoot - " .. selectedSpecName) or "KeystoneLoot",
  reportURL = nil,
 }
end

local function BuildBiSTargetData()
 local profile = GetSelectedBiSProfile()
 if not profile then
  return {
   error = L.BIS_NO_CHARACTER_DATA,
  }
 end

 local importData = GetSelectedRaidbotsImport()
 if not importData or type(importData.specItems) ~= "table" then
  return {
   error = L.BIS_NO_DATA,
  }
 end

 return BuildImportedBiSTargetData(profile, importData)
end

local function SetBiSRowAccent(frame, sourceType)
 local accent = SOURCE_COLORS[sourceType or "other"] or SOURCE_COLORS.other
 frame:SetBackdropBorderColor((accent.r or 0.7) * 0.6, (accent.g or 0.7) * 0.6, (accent.b or 0.7) * 0.6, 0.95)
end

local function ScrollBiSItemList(panel, delta)
 if not panel or not panel.itemRows then
  return
 end

 local visibleCount = #panel.itemRows
 local totalCount = tonumber(panel.itemTotalCount) or 0
 local maxOffset = math.max(totalCount - visibleCount, 0)
 local nextOffset = math.min(math.max((panel.itemScrollOffset or 0) + delta, 0), maxOffset)

 if nextOffset == (panel.itemScrollOffset or 0) then
  return
 end

 panel.itemScrollOffset = nextOffset
 if MRTE_UpdateBiSTargetsPanel then
  MRTE_UpdateBiSTargetsPanel()
 end
end

local function FormatBiSItemCount(count)
 count = tonumber(count) or 0
 if count == 1 then
  return L.BIS_ITEM_COUNT_ONE
 end

 return MRTE_T("BIS_ITEMS_COUNT", count)
end

local function ResetBiSItemRow(row)
 if not row then
  return
 end

 row.itemData = nil
 row.icon:SetTexture(134400)
 row.icon:SetDesaturated(true)
 row.iconFrame:SetBackdropBorderColor(0.30, 0.24, 0.12, 1)
 row.name:SetText("")
 row.source:SetText("")
 row.rank:SetText("")
 SetBiSRowAccent(row, "other")
end

local function ResetBiSActivityRow(row)
 if not row then
  return
 end

 row.targetData = nil
 row.icon:SetTexture(134400)
 row.icon:SetDesaturated(true)
 row.iconFrame:SetBackdropBorderColor(0.30, 0.24, 0.12, 1)
 row.name:SetText("")
 row.meta:SetText("")
 row.badge:SetText("")
 row.badgeFrame:SetBackdropBorderColor(0.38, 0.30, 0.14, 0.95)
 row.badgeFrame:SetBackdropColor(0.10, 0.08, 0.03, 0.92)
 SetBiSRowAccent(row, "other")
end

local function ShowBiSItemTooltip(row)
 local itemData = row and row.itemData
 if not itemData or not itemData.itemID then
  return
 end

 GameTooltip:SetOwner(row, "ANCHOR_RIGHT")
 GameTooltip:ClearLines()
 GameTooltip:SetHyperlink(itemData.itemLink or ("item:" .. itemData.itemID))
 GameTooltip:AddLine(" ")
 GameTooltip:AddDoubleLine(L.BIS_SOURCE_LABEL, itemData.displaySource or itemData.shortSource or L.BIS_UNKNOWN_SOURCE, 0.82, 0.82, 0.82, 1, 1, 1)
 GameTooltip:AddDoubleLine(L.BIS_PRIORITY_LABEL, tostring(itemData.priority or 0), 0.82, 0.82, 0.82, 1.00, 0.86, 0.10)
 GameTooltip:AddLine(L.BIS_REMOVE_ITEM_HINT, 0.80, 0.80, 0.80, true)
 GameTooltip:Show()
end

local function ShowBiSActivityTooltip(row)
 local targetData = row and row.targetData
 if not targetData then
  return
 end

 local color = SOURCE_COLORS[targetData.sourceType] or SOURCE_COLORS.other

 GameTooltip:SetOwner(row, "ANCHOR_RIGHT")
 GameTooltip:ClearLines()
 GameTooltip:AddLine(targetData.name or L.BIS_UNKNOWN_SOURCE, color.r or 1, color.g or 1, color.b or 1)
 GameTooltip:AddDoubleLine(L.BIS_SCORE_LABEL, tostring(tonumber(targetData.score) or 0), 0.82, 0.82, 0.82, 1, 1, 1)
 GameTooltip:AddDoubleLine(L.BIS_OPEN_ITEMS, tostring(tonumber(targetData.itemCount) or 0), 0.82, 0.82, 0.82, 1.00, 0.86, 0.10)

 for index = 1, math.min(#(targetData.items or {}), 5) do
  local itemID = targetData.items[index]
  local itemName = GetItemNameFromID(itemID) or ("Item " .. itemID)
  local _, red, green, blue = GetItemQualityColorData(itemID)
  GameTooltip:AddLine("- " .. itemName, red or 1, green or 1, blue or 1)
 end

 GameTooltip:Show()
end

local function UpdateBiSItemRow(row, itemData)
 if not row then
  return
 end

 if not itemData then
  ResetBiSItemRow(row)
  return
 end

 row.itemData = itemData
 row.icon:SetTexture(itemData.icon or 134400)
 row.icon:SetDesaturated(false)
 row.iconFrame:SetBackdropBorderColor(itemData.qualityRed or 0.62, itemData.qualityGreen or 0.62, itemData.qualityBlue or 0.62, 1)
 row.name:SetText(itemData.itemName or ("Item " .. (itemData.itemID or "")))
 row.name:SetTextColor(itemData.qualityRed or 1, itemData.qualityGreen or 1, itemData.qualityBlue or 1)
 row.source:SetText(itemData.displaySource or itemData.shortSource or itemData.source or L.BIS_UNKNOWN_SOURCE)
 local sourceColor = SOURCE_COLORS[itemData.sourceType] or SOURCE_COLORS.other
 row.source:SetTextColor(sourceColor.r or 1, sourceColor.g or 1, sourceColor.b or 1)
 row.rank:SetText("#" .. tostring(itemData.priority or 0))
 SetBiSRowAccent(row, itemData.sourceType)
end

local function UpdateBiSActivityRow(row, targetData)
 if not row then
  return
 end

 if not targetData then
  ResetBiSActivityRow(row)
  return
 end

 local accent = SOURCE_COLORS[targetData.sourceType] or SOURCE_COLORS.other

 row.targetData = targetData
 row.icon:SetTexture(targetData.icon or 134400)
 row.icon:SetDesaturated(false)
 row.iconFrame:SetBackdropBorderColor(accent.r or 0.62, accent.g or 0.62, accent.b or 0.62, 1)
 row.name:SetText(targetData.name or L.BIS_UNKNOWN_SOURCE)
 row.name:SetTextColor(1, 1, 1)
 row.meta:SetText(FormatBiSItemCount(targetData.itemCount))
 row.meta:SetTextColor(accent.r or 1, accent.g or 1, accent.b or 1)
 row.badge:SetText(tostring(tonumber(targetData.score) or 0))
 row.badge:SetTextColor(1.00, 0.90, 0.15)
 row.badgeFrame:SetBackdropBorderColor(accent.r or 0.62, accent.g or 0.62, accent.b or 0.62, 0.95)
 row.badgeFrame:SetBackdropColor((accent.r or 0.62) * 0.12, (accent.g or 0.62) * 0.12, (accent.b or 0.62) * 0.12, 0.92)
 SetBiSRowAccent(row, targetData.sourceType)
end

local function UpdateBiSPanelState(panel, data)
 if not panel then
  return
 end

 if panel.clearImportButton then
  local importData = GetSelectedRaidbotsImport()
  panel.clearImportButton:SetEnabled(importData ~= nil)
 end

 if data.error then
  panel.itemTotalCount = 0
  panel.itemScrollOffset = 0
  panel.specIcon:SetTexture(134400)
  panel.specIcon:SetDesaturated(true)
  panel.specName:SetText(L.PANEL_BIS_TARGETS)
  panel.specMeta:SetText(L.BIS_IMPORT_KIND)
  panel.summaryLine1:SetText(data.error)
  panel.summaryLine2:SetText("")
  panel.summaryLine3:SetText("")
  panel.recommendationLine:SetText(L.BIS_RECOMMENDATION .. ": " .. L.BIS_RECOMMENDATION_NONE)
  panel.vaultLine:SetText(L.BIS_VAULT_WORTH_FILLING .. ": " .. L.BIS_NO)

  for _, row in ipairs(panel.itemRows) do
   ResetBiSItemRow(row)
  end

  for _, row in ipairs(panel.dungeonRows) do
   ResetBiSActivityRow(row)
  end

  for _, row in ipairs(panel.raidRows) do
   ResetBiSActivityRow(row)
  end

  if panel.itemRows[1] then
   panel.itemRows[1].name:SetText(data.error)
   panel.itemRows[1].name:SetTextColor(0.78, 0.78, 0.78)
  end

  return
 end

 panel.specIcon:SetTexture(data.selectedSpecIcon or 134400)
 panel.specIcon:SetDesaturated(data.selectedSpecIcon == nil)
 panel.specName:SetText(data.selectedSpecName or L.PANEL_BIS_TARGETS)
 panel.specMeta:SetText(L.BIS_IMPORT_KIND .. " | " .. MRTE_T("BIS_IMPORTED_FOR", data.selectedSpecName or L.UNKNOWN))
 panel.summaryLine1:SetText(string.format(
  "%s: %d | %s: %s",
  L.BIS_OPEN_ITEMS,
  tonumber(data.openItemsCount) or 0,
  L.BIS_TOP_DUNGEON,
  data.topDungeon or "-"
 ))
 panel.summaryLine2:SetText(string.format("%s: %s", L.BIS_TOP_RAID, data.topRaid or "-"))
 panel.summaryLine3:SetText(string.format("%s: %s", L.BIS_BEST_WEEKLY_TARGET, data.bestWeeklyTarget or L.BIS_WEEKLY_TARGET_NONE))

 panel.itemTotalCount = #data.targetItems
 panel.itemScrollOffset = math.min(math.max(panel.itemScrollOffset or 0, 0), math.max(panel.itemTotalCount - #panel.itemRows, 0))

 local baseTitle = L.BIS_IMPORTED_FAVORITES or L.BIS_TARGET_ITEMS
 if panel.itemTotalCount > #panel.itemRows then
  local rangeStart = (panel.itemScrollOffset or 0) + 1
  local rangeEnd = math.min((panel.itemScrollOffset or 0) + #panel.itemRows, panel.itemTotalCount)
  panel.leftTitle:SetText(string.format("%s %d-%d/%d", baseTitle, rangeStart, rangeEnd, panel.itemTotalCount))
 else
  panel.leftTitle:SetText(baseTitle)
 end

 local emptyItemShown = true
 for index, row in ipairs(panel.itemRows) do
  local itemData = data.targetItems[(panel.itemScrollOffset or 0) + index]
  if itemData then
   UpdateBiSItemRow(row, itemData)
   emptyItemShown = false
  else
   ResetBiSItemRow(row)
  end
 end

 if emptyItemShown and panel.itemRows[1] then
  panel.itemRows[1].name:SetText(L.BIS_NO_TARGET_ITEMS)
  panel.itemRows[1].name:SetTextColor(0.72, 0.72, 0.72)
  panel.itemRows[1].source:SetText("")
  panel.itemRows[1].rank:SetText("")
 end

 local dungeonEmpty = true
 for index, row in ipairs(panel.dungeonRows) do
  local targetData = data.dungeonTargets[index]
  if targetData then
   UpdateBiSActivityRow(row, targetData)
   dungeonEmpty = false
  else
   ResetBiSActivityRow(row)
  end
 end

 if dungeonEmpty and panel.dungeonRows[1] then
  panel.dungeonRows[1].name:SetText(L.BIS_NO_ACTIVITY_TARGETS)
  panel.dungeonRows[1].name:SetTextColor(0.72, 0.72, 0.72)
 end

 local raidEmpty = true
 for index, row in ipairs(panel.raidRows) do
  local targetData = data.raidTargets[index]
  if targetData then
   UpdateBiSActivityRow(row, targetData)
   raidEmpty = false
  else
   ResetBiSActivityRow(row)
  end
 end

 if raidEmpty and panel.raidRows[1] then
  panel.raidRows[1].name:SetText(L.BIS_NO_ACTIVITY_TARGETS)
  panel.raidRows[1].name:SetTextColor(0.72, 0.72, 0.72)
 end

 panel.recommendationLine:SetText(L.BIS_RECOMMENDATION .. ": " .. (data.recommendation or L.BIS_RECOMMENDATION_NONE))
 panel.vaultLine:SetText(L.BIS_VAULT_WORTH_FILLING .. ": " .. (data.vaultWorthFilling and L.BIS_YES or L.BIS_NO))
end

function MRTE_UpdateBiSTargetsPanel()
 if not MRTE_BiSTargetsPanel then
  return
 end

 local data = BuildBiSTargetData()
 UpdateBiSPanelState(MRTE_BiSTargetsPanel, data)
end

local function SetBiSToggleState(isActive)
 if not MRTE_BiSTargetsToggle then
  return
 end

 if isActive then
  MRTE_BiSTargetsToggle:SetBackdropColor(0.17, 0.13, 0.05, 0.98)
  MRTE_BiSTargetsToggle:SetBackdropBorderColor(0.86, 0.68, 0.20, 1)
 else
  MRTE_BiSTargetsToggle:SetBackdropColor(0.08, 0.08, 0.09, 0.96)
  MRTE_BiSTargetsToggle:SetBackdropBorderColor(0.24, 0.19, 0.10, 1)
 end
end

function MRTE_ShowBiSTargetsPanel()
 if not MRTE_BiSTargetsPanel then
  return false
 end

 MRTE_UpdateBiSTargetsPanel()
 MRTE_BiSTargetsPanel:Show()
 SetBiSToggleState(true)
 return true
end

function MRTE_ToggleBiSTargetsPanel()
 if not MRTE_BiSTargetsPanel then
  return
 end

 if MRTE_BiSTargetsPanel:IsShown() then
  MRTE_BiSTargetsPanel:Hide()
  if MRTE_BiSTargetsImportFrame then
   MRTE_BiSTargetsImportFrame:Hide()
  end
  SetBiSToggleState(false)
  return
 end

 MRTE_ShowBiSTargetsPanel()
end

local function RegisterEscapeFrame(frame)
 local frameName = frame and frame:GetName()
 if not frameName then
  return
 end

 UISpecialFrames = UISpecialFrames or {}

 for _, registeredName in ipairs(UISpecialFrames) do
  if registeredName == frameName then
   return
  end
 end

 table.insert(UISpecialFrames, frameName)
end

local function SetImportBoxText(text)
 if MRTE_BiSTargetsImportFrame and MRTE_BiSTargetsImportFrame.editBox then
  MRTE_BiSTargetsImportFrame.editBox:SetText(text or "")
  MRTE_BiSTargetsImportFrame.editBox:HighlightText(0, 0)
  MRTE_BiSTargetsImportFrame.scrollFrame:SetVerticalScroll(0)
 end
end

local function OpenRaidbotsImportFrame()
 if not MRTE_BiSTargetsPanel or not MRTE_BiSTargetsImportFrame then
  return
 end

 MRTE_ShowBiSTargetsPanel()
 local importData = GetSelectedRaidbotsImport()
 SetImportBoxText(importData and importData.rawText or "")
 MRTE_BiSTargetsImportFrame:Show()
 MRTE_BiSTargetsImportFrame.editBox:SetFocus()
end

local function ImportRaidbotsFromEditBox()
 if not MRTE_BiSTargetsImportFrame or not MRTE_BiSTargetsImportFrame.editBox then
  return
 end

 local rawText = MRTE_BiSTargetsImportFrame.editBox:GetText() or ""
 if Trim(rawText) == "" then
  MRTE_SetStatus(L.BIS_IMPORT_EMPTY)
  return
 end

 if not tostring(rawText or ""):gsub("%s+", ""):match("^KeystoneLoot:v1") then
  MRTE_SetStatus(L.BIS_IMPORT_URL_ONLY)
  return
 end

 local importData = ParseRaidbotsImportText(rawText)
 if not importData then
  MRTE_SetStatus(L.BIS_IMPORT_FAILED)
  return
 end

 importData.rawText = rawText

 local saved, profile = SaveSelectedRaidbotsImport(importData)
 if not saved then
  MRTE_SetStatus(L.BIS_IMPORT_FAILED)
  return
 end

 MRTE_UpdateBiSTargetsPanel()
 MRTE_BiSTargetsImportFrame:Hide()
 MRTE_SetStatus(MRTE_T("BIS_IMPORT_SUCCESS", #importData.items, profile.displayName or profile.name or L.ADDON_TITLE))
end

local function ClearSelectedRaidbotsImportData()
 local cleared, profile = ClearSelectedRaidbotsImport()
 if not cleared then
  MRTE_SetStatus(L.BIS_IMPORT_FAILED)
  return
 end

 SetImportBoxText("")
 MRTE_UpdateBiSTargetsPanel()
 if MRTE_BiSTargetsImportFrame then
  MRTE_BiSTargetsImportFrame:Hide()
 end
 MRTE_SetStatus(MRTE_T("BIS_IMPORT_CLEARED", profile.displayName or profile.name or L.ADDON_TITLE))
end

function MRTE_OpenRaidbotsImport()
 if MRTE_MainFrame and not MRTE_MainFrame:IsShown() then
  MRTE_MainFrame:Show()
 end

 OpenRaidbotsImportFrame()
end

function MRTE_CreateBiSTargetsPanel()
 if not MRTE_MainFrame or MRTE_BiSTargetsPanel then
  return
 end

 local parent = MRTE_MainFrame

 local toggle = CreateFrame("Button", nil, parent, "BackdropTemplate")
 toggle:SetSize(36, 108)
 toggle:SetPoint("TOPRIGHT", parent, "TOPLEFT", 1, -138)
 toggle:SetBackdrop({
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
 toggle:SetBackdropColor(0.08, 0.08, 0.09, 0.96)
 toggle:SetBackdropBorderColor(0.24, 0.19, 0.10, 1)

 toggle.textTop = toggle:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
 toggle.textTop:SetPoint("TOP", 0, -20)
 toggle.textTop:SetText(L.BIS_TAB_LABEL)
 toggle.textTop:SetTextColor(1.00, 0.86, 0.10)

 toggle.textBottom = toggle:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
 toggle.textBottom:SetPoint("TOP", toggle.textTop, "BOTTOM", 0, -6)
 toggle.textBottom:SetText(L.BIS_TAB_SUBLABEL)
 toggle.textBottom:SetTextColor(0.84, 0.84, 0.84)

 local panel = CreateFrame("Frame", nil, parent, "BackdropTemplate")
 panel:SetSize(548, 676)
 panel:SetPoint("TOPLEFT", parent, "TOPRIGHT", 8, -48)
 MRTE_Style(panel)
 panel:Hide()

 panel.title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
 panel.title:SetPoint("TOPLEFT", 18, -12)
 panel.title:SetText(L.PANEL_BIS_TARGETS)
 MRTE_StyleTitle(panel.title, 20)

 panel.importButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
 panel.importButton:SetSize(82, 22)
 panel.importButton:SetPoint("TOPRIGHT", -18, -10)
 panel.importButton:SetText(L.BIS_IMPORT_BUTTON)

 panel.clearImportButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
 panel.clearImportButton:SetSize(82, 22)
 panel.clearImportButton:SetPoint("RIGHT", panel.importButton, "LEFT", -8, 0)
 panel.clearImportButton:SetText(L.BIS_CLEAR_BUTTON)

 panel.header = CreateFrame("Frame", nil, panel, "BackdropTemplate")
 panel.header:SetSize(510, 122)
 panel.header:SetPoint("TOPLEFT", 18, -42)
 ApplySimpleSectionStyle(panel.header)

 panel.specIconFrame = CreateFrame("Frame", nil, panel.header, "BackdropTemplate")
 panel.specIconFrame:SetSize(42, 42)
 panel.specIconFrame:SetPoint("TOPLEFT", 12, -12)
 ApplyIconFrameStyle(panel.specIconFrame)

 panel.specIcon = panel.specIconFrame:CreateTexture(nil, "ARTWORK")
 panel.specIcon:SetAllPoints()
 panel.specIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
 panel.specIcon:SetTexture(134400)

 panel.specName = panel.header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
 panel.specName:SetPoint("TOPLEFT", panel.specIconFrame, "TOPRIGHT", 12, -2)
 panel.specName:SetPoint("TOPRIGHT", -12, -14)
 panel.specName:SetJustifyH("LEFT")
 MRTE_StyleTitle(panel.specName, 17)
 panel.specName:SetText(L.PANEL_BIS_TARGETS)

 panel.specMeta = panel.header:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
 panel.specMeta:SetPoint("TOPLEFT", panel.specName, "BOTTOMLEFT", 0, -4)
 panel.specMeta:SetPoint("TOPRIGHT", -12, -34)
 panel.specMeta:SetJustifyH("LEFT")
 MRTE_StyleStatus(panel.specMeta)
 panel.specMeta:SetText(L.BIS_IMPORT_KIND)

 panel.summaryLine1 = panel.header:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
 panel.summaryLine1:SetPoint("TOPLEFT", 12, -64)
 panel.summaryLine1:SetPoint("TOPRIGHT", -12, -64)
 panel.summaryLine1:SetJustifyH("LEFT")
 panel.summaryLine1:SetText(L.BIS_NO_DATA)
 MRTE_StyleStatus(panel.summaryLine1)

 panel.summaryLine2 = panel.header:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
 panel.summaryLine2:SetPoint("TOPLEFT", panel.summaryLine1, "BOTTOMLEFT", 0, -6)
 panel.summaryLine2:SetPoint("TOPRIGHT", -12, -82)
 panel.summaryLine2:SetJustifyH("LEFT")
 MRTE_StyleStatus(panel.summaryLine2)
 panel.summaryLine2:SetText("")

 panel.summaryLine3 = panel.header:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
 panel.summaryLine3:SetPoint("TOPLEFT", panel.summaryLine2, "BOTTOMLEFT", 0, -4)
 panel.summaryLine3:SetPoint("TOPRIGHT", -12, -102)
 panel.summaryLine3:SetJustifyH("LEFT")
 MRTE_StyleStatus(panel.summaryLine3)
 panel.summaryLine3:SetText("")

 panel.leftSection = CreateFrame("Frame", nil, panel, "BackdropTemplate")
 panel.leftSection:SetSize(246, 370)
 panel.leftSection:SetPoint("TOPLEFT", 18, -174)
 ApplySimpleSectionStyle(panel.leftSection)

 panel.leftTitle = panel.leftSection:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
 panel.leftTitle:SetPoint("TOPLEFT", 12, -12)
 panel.leftTitle:SetText(L.BIS_IMPORTED_FAVORITES or L.BIS_TARGET_ITEMS)
 MRTE_StyleTitle(panel.leftTitle, 16)
 panel.leftSection:EnableMouseWheel(true)
 panel.leftSection:SetScript("OnMouseWheel", function(_, delta)
  ScrollBiSItemList(panel, -delta)
 end)

 panel.rightSection = CreateFrame("Frame", nil, panel, "BackdropTemplate")
 panel.rightSection:SetSize(246, 370)
 panel.rightSection:SetPoint("TOPRIGHT", -18, -174)
 ApplySimpleSectionStyle(panel.rightSection)

 panel.rightTitle = panel.rightSection:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
 panel.rightTitle:SetPoint("TOPLEFT", 12, -12)
 panel.rightTitle:SetText(L.BIS_BEST_SOURCES or L.BIS_ACTIVITY_TARGETS)
 MRTE_StyleTitle(panel.rightTitle, 16)

 panel.itemRows = {}
 for index = 1, 8 do
  local row = CreateFrame("Button", nil, panel.leftSection, "BackdropTemplate")
  row:SetSize(220, 40)
  row:SetPoint("TOPLEFT", 12, -42 - ((index - 1) * 40))
  ApplyBiSRowStyle(row, "other")
  row:RegisterForClicks("LeftButtonUp", "RightButtonUp")
  row:EnableMouseWheel(true)

  row.iconFrame = CreateFrame("Frame", nil, row, "BackdropTemplate")
  row.iconFrame:SetSize(30, 30)
  row.iconFrame:SetPoint("LEFT", 4, 0)
  ApplyIconFrameStyle(row.iconFrame)

  row.icon = row.iconFrame:CreateTexture(nil, "ARTWORK")
  row.icon:SetAllPoints()
  row.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
  row.icon:SetTexture(134400)

  row.name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  row.name:SetPoint("TOPLEFT", row.iconFrame, "TOPRIGHT", 8, -3)
  row.name:SetPoint("RIGHT", -42, 0)
  row.name:SetJustifyH("LEFT")
  row.name:SetFont(STANDARD_TEXT_FONT, 11, "OUTLINE")
  DisableTextWrap(row.name)

  row.source = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  row.source:SetPoint("TOPLEFT", row.name, "BOTTOMLEFT", 0, -2)
  row.source:SetPoint("RIGHT", -42, 0)
  row.source:SetJustifyH("LEFT")
  row.source:SetFont(STANDARD_TEXT_FONT, 10, "")
  DisableTextWrap(row.source)

  row.rank = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  row.rank:SetPoint("TOPRIGHT", -8, -4)
  row.rank:SetJustifyH("RIGHT")
  row.rank:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
  row.rank:SetTextColor(1.00, 0.86, 0.10)

  row:SetScript("OnEnter", function(self)
   ShowBiSItemTooltip(self)
  end)
  row:SetScript("OnLeave", function()
   GameTooltip:Hide()
  end)
  row:SetScript("OnMouseWheel", function(_, delta)
   ScrollBiSItemList(panel, -delta)
  end)
  row:SetScript("OnClick", function(self, button)
   local itemData = self.itemData
   if not itemData then
    return
   end

   if button == "RightButton" then
    local removed, _, removedItemID = RemoveSelectedImportedItem(itemData)
    if removed then
     MRTE_UpdateBiSTargetsPanel()
     MRTE_SetStatus(MRTE_T("BIS_ITEM_REMOVED", GetItemNameFromID(removedItemID) or ("Item " .. removedItemID)))
    end
    return
   end

   if itemData.itemLink and IsModifierKeyDown and IsModifierKeyDown() and HandleModifiedItemClick then
    HandleModifiedItemClick(itemData.itemLink)
   end
  end)

  ResetBiSItemRow(row)
  panel.itemRows[index] = row
 end

 panel.dungeonHeader = panel.rightSection:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
 panel.dungeonHeader:SetPoint("TOPLEFT", 12, -40)
 panel.dungeonHeader:SetText(L.BIS_DUNGEONS)
 panel.dungeonHeader:SetTextColor(0.90, 0.94, 1.00)

 panel.dungeonRows = {}
 for index = 1, 3 do
  local row = CreateFrame("Button", nil, panel.rightSection, "BackdropTemplate")
  row:SetSize(220, 42)
  row:SetPoint("TOPLEFT", 12, -62 - ((index - 1) * 44))
  ApplyBiSRowStyle(row, "dungeon")

  row.iconFrame = CreateFrame("Frame", nil, row, "BackdropTemplate")
  row.iconFrame:SetSize(28, 28)
  row.iconFrame:SetPoint("LEFT", 4, 0)
  ApplyIconFrameStyle(row.iconFrame)

  row.icon = row.iconFrame:CreateTexture(nil, "ARTWORK")
  row.icon:SetAllPoints()
  row.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
  row.icon:SetTexture(134400)

  row.badgeFrame = CreateFrame("Frame", nil, row, "BackdropTemplate")
  row.badgeFrame:SetSize(42, 20)
  row.badgeFrame:SetPoint("RIGHT", -8, 0)
  ApplyIconFrameStyle(row.badgeFrame)

  row.badge = row.badgeFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  row.badge:SetPoint("CENTER")

  row.name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  row.name:SetPoint("TOPLEFT", row.iconFrame, "TOPRIGHT", 8, -3)
  row.name:SetPoint("RIGHT", row.badgeFrame, "LEFT", -8, 0)
  row.name:SetJustifyH("LEFT")
  row.name:SetFont(STANDARD_TEXT_FONT, 11, "OUTLINE")
  DisableTextWrap(row.name)

  row.meta = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  row.meta:SetPoint("TOPLEFT", row.name, "BOTTOMLEFT", 0, -2)
  row.meta:SetPoint("RIGHT", row.badgeFrame, "LEFT", -8, 0)
  row.meta:SetJustifyH("LEFT")
  row.meta:SetFont(STANDARD_TEXT_FONT, 10, "")
  DisableTextWrap(row.meta)

  row:SetScript("OnEnter", function(self)
   ShowBiSActivityTooltip(self)
  end)
  row:SetScript("OnLeave", function()
   GameTooltip:Hide()
  end)

  ResetBiSActivityRow(row)
  panel.dungeonRows[index] = row
 end

 panel.raidHeader = panel.rightSection:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
 panel.raidHeader:SetPoint("TOPLEFT", 12, -204)
 panel.raidHeader:SetText(L.BIS_RAID)
 panel.raidHeader:SetTextColor(1.00, 0.90, 0.78)

 panel.raidRows = {}
 for index = 1, 3 do
  local row = CreateFrame("Button", nil, panel.rightSection, "BackdropTemplate")
  row:SetSize(220, 42)
  row:SetPoint("TOPLEFT", 12, -226 - ((index - 1) * 44))
  ApplyBiSRowStyle(row, "raid")

  row.iconFrame = CreateFrame("Frame", nil, row, "BackdropTemplate")
  row.iconFrame:SetSize(28, 28)
  row.iconFrame:SetPoint("LEFT", 4, 0)
  ApplyIconFrameStyle(row.iconFrame)

  row.icon = row.iconFrame:CreateTexture(nil, "ARTWORK")
  row.icon:SetAllPoints()
  row.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
  row.icon:SetTexture(134400)

  row.badgeFrame = CreateFrame("Frame", nil, row, "BackdropTemplate")
  row.badgeFrame:SetSize(42, 20)
  row.badgeFrame:SetPoint("RIGHT", -8, 0)
  ApplyIconFrameStyle(row.badgeFrame)

  row.badge = row.badgeFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  row.badge:SetPoint("CENTER")

  row.name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  row.name:SetPoint("TOPLEFT", row.iconFrame, "TOPRIGHT", 8, -3)
  row.name:SetPoint("RIGHT", row.badgeFrame, "LEFT", -8, 0)
  row.name:SetJustifyH("LEFT")
  row.name:SetFont(STANDARD_TEXT_FONT, 11, "OUTLINE")
  DisableTextWrap(row.name)

  row.meta = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  row.meta:SetPoint("TOPLEFT", row.name, "BOTTOMLEFT", 0, -2)
  row.meta:SetPoint("RIGHT", row.badgeFrame, "LEFT", -8, 0)
  row.meta:SetJustifyH("LEFT")
  row.meta:SetFont(STANDARD_TEXT_FONT, 10, "")
  DisableTextWrap(row.meta)

  row:SetScript("OnEnter", function(self)
   ShowBiSActivityTooltip(self)
  end)
  row:SetScript("OnLeave", function()
   GameTooltip:Hide()
  end)

  ResetBiSActivityRow(row)
  panel.raidRows[index] = row
 end

 panel.footer = CreateFrame("Frame", nil, panel, "BackdropTemplate")
 panel.footer:SetSize(510, 108)
 panel.footer:SetPoint("BOTTOMLEFT", 18, 18)
 ApplySimpleSectionStyle(panel.footer)

 panel.recommendationLine = panel.footer:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
 panel.recommendationLine:SetPoint("TOPLEFT", 12, -14)
 panel.recommendationLine:SetPoint("TOPRIGHT", -12, -14)
 panel.recommendationLine:SetJustifyH("LEFT")
 panel.recommendationLine:SetJustifyV("TOP")
 panel.recommendationLine:SetText(L.BIS_RECOMMENDATION .. ": " .. L.BIS_RECOMMENDATION_NONE)
 MRTE_StyleStatus(panel.recommendationLine)

 panel.vaultLine = panel.footer:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
 panel.vaultLine:SetPoint("TOPLEFT", panel.recommendationLine, "BOTTOMLEFT", 0, -14)
 panel.vaultLine:SetPoint("TOPRIGHT", -12, -56)
 panel.vaultLine:SetJustifyH("LEFT")
 panel.vaultLine:SetText(L.BIS_VAULT_WORTH_FILLING .. ": " .. L.BIS_NO)
 MRTE_StyleStatus(panel.vaultLine)

 local importFrame = CreateFrame("Frame", "MRTE_BiSTargetsImportFrame", UIParent, "BackdropTemplate")
 importFrame:SetSize(436, 360)
 importFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
 importFrame:SetFrameStrata("FULLSCREEN_DIALOG")
 importFrame:SetToplevel(true)
 importFrame:SetClampedToScreen(true)
 MRTE_Style(importFrame)
 importFrame:Hide()
 RegisterEscapeFrame(importFrame)

 importFrame.title = importFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
 importFrame.title:SetPoint("TOPLEFT", 16, -12)
 importFrame.title:SetText(L.BIS_IMPORT_TITLE)
 MRTE_StyleTitle(importFrame.title, 18)

 importFrame.closeButton = CreateFrame("Button", nil, importFrame, "UIPanelCloseButton")
 importFrame.closeButton:SetPoint("TOPRIGHT", -4, -4)
 importFrame.closeButton:SetSize(24, 24)

 importFrame.hint = importFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
 importFrame.hint:SetPoint("TOPLEFT", 16, -38)
 importFrame.hint:SetPoint("TOPRIGHT", -16, -38)
 importFrame.hint:SetJustifyH("LEFT")
 importFrame.hint:SetText(L.BIS_IMPORT_HINT)

 importFrame.example = importFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
 importFrame.example:SetPoint("TOPLEFT", importFrame.hint, "BOTTOMLEFT", 0, -6)
 importFrame.example:SetPoint("TOPRIGHT", -16, -58)
 importFrame.example:SetJustifyH("LEFT")
 importFrame.example:SetText(L.BIS_IMPORT_EXAMPLE)
 importFrame.example:SetTextColor(0.80, 0.80, 0.80)

 importFrame.scrollBackdrop = CreateFrame("Frame", nil, importFrame, "BackdropTemplate")
 importFrame.scrollBackdrop:SetPoint("TOPLEFT", 16, -86)
 importFrame.scrollBackdrop:SetPoint("BOTTOMRIGHT", -16, 52)
 ApplySimpleSectionStyle(importFrame.scrollBackdrop)

 importFrame.scrollFrame = CreateFrame("ScrollFrame", nil, importFrame.scrollBackdrop, "UIPanelScrollFrameTemplate")
 importFrame.scrollFrame:SetPoint("TOPLEFT", 8, -8)
 importFrame.scrollFrame:SetPoint("BOTTOMRIGHT", -28, 8)

 importFrame.editBox = CreateFrame("EditBox", nil, importFrame.scrollFrame)
 importFrame.editBox:SetMultiLine(true)
 importFrame.editBox:SetAutoFocus(false)
 importFrame.editBox:SetFontObject(ChatFontNormal)
 importFrame.editBox:SetWidth(372)
 importFrame.editBox:SetHeight(236)
 importFrame.editBox:SetTextInsets(4, 4, 4, 4)

 importFrame.measureText = importFrame:CreateFontString(nil, "ARTWORK")
 importFrame.measureText:SetFontObject(ChatFontNormal)
 importFrame.measureText:SetWidth(364)
 importFrame.measureText:SetJustifyH("LEFT")
 importFrame.measureText:SetJustifyV("TOP")
 importFrame.measureText:SetText(" ")
 importFrame.measureText:Hide()

 importFrame.editBox:SetScript("OnEscapePressed", function(self)
  self:ClearFocus()
  importFrame:Hide()
 end)
 importFrame.editBox:SetScript("OnTextChanged", function(self)
  local measureText = importFrame.measureText
  if measureText then
   local text = self:GetText()
   if text == nil or text == "" then
    text = " "
   end

   measureText:SetText(text)
   self:SetHeight(math.max(236, measureText:GetStringHeight() + 24))
  else
   self:SetHeight(236)
  end

  importFrame.scrollFrame:UpdateScrollChildRect()
 end)
 importFrame.scrollFrame:SetScrollChild(importFrame.editBox)

 importFrame.importButton = CreateFrame("Button", nil, importFrame, "UIPanelButtonTemplate")
 importFrame.importButton:SetSize(88, 22)
 importFrame.importButton:SetPoint("BOTTOMRIGHT", -16, 16)
 importFrame.importButton:SetText(L.BIS_IMPORT_BUTTON)

 importFrame.clearButton = CreateFrame("Button", nil, importFrame, "UIPanelButtonTemplate")
 importFrame.clearButton:SetSize(88, 22)
 importFrame.clearButton:SetPoint("RIGHT", importFrame.importButton, "LEFT", -8, 0)
 importFrame.clearButton:SetText(L.BIS_CLEAR_TEXT_BUTTON)

 importFrame.cancelButton = CreateFrame("Button", nil, importFrame, "UIPanelButtonTemplate")
 importFrame.cancelButton:SetSize(88, 22)
 importFrame.cancelButton:SetPoint("RIGHT", importFrame.clearButton, "LEFT", -8, 0)
 importFrame.cancelButton:SetText(L.BIS_CLOSE_BUTTON)

 toggle:SetScript("OnClick", function()
  MRTE_ToggleBiSTargetsPanel()
 end)

 panel.importButton:SetScript("OnClick", function()
  OpenRaidbotsImportFrame()
 end)

 panel.clearImportButton:SetScript("OnClick", function()
  ClearSelectedRaidbotsImportData()
 end)

 importFrame.importButton:SetScript("OnClick", function()
  ImportRaidbotsFromEditBox()
 end)

 importFrame.clearButton:SetScript("OnClick", function()
  SetImportBoxText("")
 end)

 importFrame.cancelButton:SetScript("OnClick", function()
  importFrame:Hide()
 end)

 MRTE_BiSTargetsToggle = toggle
 MRTE_BiSTargetsPanel = panel
 MRTE_BiSTargetsImportFrame = importFrame

 MRTE_UpdateBiSTargetsPanel()
end

local bisEvents = CreateFrame("Frame")
bisEvents:RegisterEvent("PLAYER_ENTERING_WORLD")
bisEvents:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
bisEvents:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
bisEvents:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
bisEvents:RegisterEvent("GET_ITEM_INFO_RECEIVED")
bisEvents:SetScript("OnEvent", function()
 if MRTE_UpdateBiSTargetsPanel then
  MRTE_UpdateBiSTargetsPanel()
 end
end)
