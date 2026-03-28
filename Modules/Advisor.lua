local L = MRTE_L

local ADVISOR_WIDTH = 650
local ADVISOR_HEIGHT = 492
local SECTION_WIDTH = 300
local SECTION_HEIGHT = 172
local SECTION_GAP_X = 14
local SECTION_GAP_Y = 14
local SECTION_MARGIN_X = 18
local SECTION_START_Y = -54

local WeeklyRewardTypes = Enum and Enum.WeeklyRewardChestThresholdType
local ADVISOR_VAULT_TYPE_DUNGEONS = WeeklyRewardTypes and WeeklyRewardTypes.Activities or 2
local ADVISOR_VAULT_THRESHOLDS = { 1, 4, 8 }

local advisorEvents = CreateFrame("Frame")
local keystoneLootSourceLookup
local advisorRaidLockoutCache
local EMBEDDED_SECTION_GLOBALS = {
 today = "MRTE_AdvisorTodayPanel",
 vault = "MRTE_AdvisorVaultPanel",
 group = "MRTE_AdvisorGroupPanel",
 alts = "MRTE_AdvisorAltsPanel",
}

local function RegisterForEscape(frame)
 local frameName = frame and frame:GetName()
 if not frameName then
  return
 end

 for _, registeredName in ipairs(UISpecialFrames) do
  if registeredName == frameName then
   return
  end
 end

 table.insert(UISpecialFrames, frameName)
end

local function FormatScore(score)
 score = tonumber(score) or 0
 if score <= 0 then
  return "0"
 end

 local rounded = math.floor((score * 10) + 0.5) / 10
 if rounded == math.floor(rounded) then
  return tostring(math.floor(rounded))
 end

 return string.format("%.1f", rounded)
end

local function FormatCount(value)
 value = tonumber(value) or 0
 if math.abs(value - math.floor(value + 0.5)) < 0.05 then
  return tostring(math.floor(value + 0.5))
 end

 return string.format("%.1f", value)
end

local function FormatPercent(count, totalCount)
 count = tonumber(count) or 0
 totalCount = tonumber(totalCount) or 0
 if totalCount <= 0 then
  return "0.0%"
 end

 return string.format("%.1f%%", (count / totalCount) * 100)
end

local function TrimLines(lines, maxLines)
 local result = {}
 for _, line in ipairs(lines or {}) do
  if type(line) == "string" and line ~= "" then
   result[#result + 1] = line
   if maxLines and #result >= maxLines then
    break
   end
  end
 end
 return result
end

local function GetSelectedProfile()
 return MRTE_GetSelectedCharacterProfile and MRTE_GetSelectedCharacterProfile() or nil
end

local function IsCurrentProfile(profile)
 local currentCharacterKey = MRTE_GetCurrentCharacterKey and MRTE_GetCurrentCharacterKey()
 return profile and currentCharacterKey and profile.key == currentCharacterKey or false
end

local function GetAllProfiles()
 local profiles = {}
 local characters = MRTE_GlobalDB and MRTE_GlobalDB.characters or {}

 for _, profile in pairs(characters) do
  if type(profile) == "table" and profile.key then
   profiles[#profiles + 1] = profile
  end
 end

 table.sort(profiles, function(left, right)
  local leftSeen = tonumber(left.lastSeen) or 0
  local rightSeen = tonumber(right.lastSeen) or 0
  if leftSeen ~= rightSeen then
   return leftSeen > rightSeen
  end

  return (left.displayName or left.name or "") < (right.displayName or right.name or "")
 end)

 return profiles
end

local function GetCharacterLogs(profile)
 if not profile or not profile.key then
  return {}
 end

 local logsByCharacter = MRTE_GlobalDB and MRTE_GlobalDB.logsByCharacter or {}
 return logsByCharacter[profile.key] or {}
end

local function GetProfileDisplayName(profile)
 if not profile then
  return L.UNKNOWN
 end

 return profile.displayName or profile.name or profile.fullName or profile.key or L.UNKNOWN
end

local function GetChallengeMapName(mapID)
 mapID = tonumber(mapID) or 0
 if mapID <= 0 then
  return L.UNKNOWN
 end

 if C_ChallengeMode and C_ChallengeMode.GetMapUIInfo then
  local mapName = C_ChallengeMode.GetMapUIInfo(mapID)
  if type(mapName) == "string" and mapName ~= "" then
   return mapName
  end
 end

 return MRTE_T("BIS_DUNGEON_FALLBACK", mapID)
end

local function GetBossName(bossID)
 bossID = tonumber(bossID) or 0
 if bossID <= 0 then
  return L.UNKNOWN
 end

 if EJ_GetEncounterInfo then
  local bossName = EJ_GetEncounterInfo(bossID)
  if type(bossName) == "string" and bossName ~= "" then
   return bossName
  end
 end

 return MRTE_T("BIS_BOSS_FALLBACK", bossID)
end

local function IsItemEquipped(profile, itemID)
 itemID = tonumber(itemID)
 if not profile or not itemID or itemID <= 0 then
  return false
 end

 for _, equippedItemID in pairs(profile.equipment or {}) do
  if tonumber(equippedItemID) == itemID then
   return true
  end
 end

 return false
end

local function GetKeystoneLootSourceLookup()
 if keystoneLootSourceLookup then
  return keystoneLootSourceLookup
 end

 local lookup = {}
 local data = MRTE_KeystoneLootImportData or {}

 for _, dungeonData in ipairs(data.dungeons or {}) do
  for _, itemID in ipairs(dungeonData.items or {}) do
   lookup[tonumber(itemID)] = {
    sourceType = "dungeon",
    sourceID = tonumber(dungeonData.challengeModeId),
   }
  end
 end

 for _, bossData in ipairs(data.raidBosses or {}) do
  for _, itemID in ipairs(bossData.items or {}) do
   lookup[tonumber(itemID)] = {
    sourceType = "raid",
    sourceID = tonumber(bossData.bossId),
   }
  end
 end

 keystoneLootSourceLookup = lookup
 return keystoneLootSourceLookup
end

local function GetSelectedImportItemList(profile)
 local importData = profile and profile.raidbotsImport
 if type(importData) ~= "table" or type(importData.specItems) ~= "table" then
  return nil
 end

 local selectedSpecID = tonumber(profile and profile.specID) or 0
 local itemList = importData.specItems[selectedSpecID]

 if type(itemList) ~= "table" then
  local specIDs = {}
  for specID in pairs(importData.specItems) do
   specIDs[#specIDs + 1] = tonumber(specID)
  end

  table.sort(specIDs)
  selectedSpecID = specIDs[1]
  itemList = selectedSpecID and importData.specItems[selectedSpecID] or nil
 end

 if type(itemList) ~= "table" then
  return nil
 end

 return itemList, selectedSpecID
end

local function NormalizeBossName(name)
 if type(name) ~= "string" or name == "" then
  return nil
 end

 return string.lower(name)
end

local function BuildLiveRaidLockoutData()
 local lockoutData = {
  isKnown = true,
  killedBossIDs = {},
  killedBossNames = {},
 }

 if not GetNumSavedInstances or not GetSavedInstanceInfo or not GetSavedInstanceEncounterInfo then
  return lockoutData
 end

 local bossNameToID = {}
 for _, bossData in ipairs((MRTE_KeystoneLootImportData and MRTE_KeystoneLootImportData.raidBosses) or {}) do
  local bossID = tonumber(bossData and bossData.bossId) or 0
  if bossID > 0 then
   local normalizedName = NormalizeBossName(GetBossName(bossID))
   if normalizedName then
    bossNameToID[normalizedName] = bossID
   end
  end
 end

 local savedInstanceCountValue = GetNumSavedInstances()
 local savedInstanceCount = tonumber(savedInstanceCountValue or 0) or 0
 for savedInstanceIndex = 1, savedInstanceCount do
  local _, _, _, _, _, _, _, isRaid, _, _, numEncounters = GetSavedInstanceInfo(savedInstanceIndex)
  if isRaid then
   local encounterCount = tonumber(numEncounters) or 0
   for encounterIndex = 1, encounterCount do
    local bossName, _, isKilled = GetSavedInstanceEncounterInfo(savedInstanceIndex, encounterIndex)
    if isKilled then
     local normalizedName = NormalizeBossName(bossName)
     if normalizedName then
      lockoutData.killedBossNames[normalizedName] = true
      local mappedBossID = bossNameToID[normalizedName]
      if mappedBossID then
       lockoutData.killedBossIDs[mappedBossID] = true
      end
     end
    end
   end
  end
 end

 return lockoutData
end

local function GetProfileRaidLockout(profile)
 if IsCurrentProfile(profile) then
  if not advisorRaidLockoutCache then
   advisorRaidLockoutCache = BuildLiveRaidLockoutData()
   if MRTE_SaveCharacterSection then
    MRTE_SaveCharacterSection("raidLockout", advisorRaidLockoutCache)
   end
  end

  return advisorRaidLockoutCache
 end

 local raidLockout = profile and profile.raidLockout
 return type(raidLockout) == "table" and raidLockout or nil
end

local function IsRaidBossLocked(profile, bossID)
 bossID = tonumber(bossID) or 0
 if bossID <= 0 then
  return false
 end

 local raidLockout = GetProfileRaidLockout(profile)
 if type(raidLockout) ~= "table" then
  return false
 end

 if type(raidLockout.killedBossIDs) == "table" and raidLockout.killedBossIDs[bossID] then
  return true
 end

 local normalizedName = NormalizeBossName(GetBossName(bossID))
 return normalizedName and type(raidLockout.killedBossNames) == "table" and raidLockout.killedBossNames[normalizedName] or false
end

local function FindDungeonVaultSlotIndex(row, activity)
 local activityIndex = tonumber(activity and activity.index)
 if activityIndex and row[activityIndex] then
  return activityIndex
 end

 local threshold = tonumber(activity and activity.threshold)
 for index, slotData in ipairs(row) do
  if tonumber(slotData and slotData.threshold) == threshold then
   return index
  end
 end
end

local function CreateDefaultDungeonVaultRow()
 local row = {}

 for slotIndex, threshold in ipairs(ADVISOR_VAULT_THRESHOLDS) do
  row[slotIndex] = {
   threshold = threshold,
   progress = 0,
   unlocked = false,
   source = "default",
  }
 end

 return row
end

local function ApplyDungeonVaultFallback(row, profile)
 local levels = {}
 for _, entry in ipairs(GetCharacterLogs(profile)) do
  local level = tonumber(entry and entry.level)
  if level and level > 0 then
   levels[#levels + 1] = level
  end
 end

 table.sort(levels, function(left, right)
  return left > right
 end)

 local runCount = #levels
 for slotIndex, threshold in ipairs(ADVISOR_VAULT_THRESHOLDS) do
  local rewardLevel = levels[threshold]
  row[slotIndex] = {
   threshold = threshold,
   progress = math.min(runCount, threshold),
   unlocked = rewardLevel ~= nil,
   level = rewardLevel,
   source = "fallback",
  }
 end
end

local function BuildLiveDungeonVaultRow(profile)
 local row = CreateDefaultDungeonVaultRow()

 if C_WeeklyRewards and C_WeeklyRewards.GetActivities then
  local activities = C_WeeklyRewards.GetActivities()
  if type(activities) == "table" and #activities > 0 then
   local foundDungeonActivity = false

   for _, activity in ipairs(activities) do
    if type(activity) == "table" and tonumber(activity.type) == ADVISOR_VAULT_TYPE_DUNGEONS then
     local slotIndex = FindDungeonVaultSlotIndex(row, activity)
     if slotIndex then
      local threshold = tonumber(activity.threshold) or tonumber(row[slotIndex].threshold) or 0
      local progress = tonumber(activity.progress) or 0

      row[slotIndex] = {
       activity = activity,
       threshold = threshold,
       progress = progress,
       unlocked = threshold > 0 and progress >= threshold,
       level = tonumber(activity.level),
       source = "api",
      }
      foundDungeonActivity = true
     end
    end
   end

   if foundDungeonActivity then
    return row
   end
  end
 end

 ApplyDungeonVaultFallback(row, profile)
 return row
end
local function BuildImportSummary(profile)
 local itemList = GetSelectedImportItemList(profile)
 if not itemList then
  return {
   hasImport = false,
   openItemsCount = 0,
   dungeonTargets = {},
   raidTargets = {},
   dungeonCountByMap = {},
   raidCountByBoss = {},
  }
 end

 local sourceLookup = GetKeystoneLootSourceLookup()
 local dungeonBuckets = {}
 local raidBuckets = {}
 local openItemsCount = 0

 for _, rawItemID in ipairs(itemList) do
  local itemID = tonumber(rawItemID)
  if itemID and itemID > 0 and not IsItemEquipped(profile, itemID) then
   local sourceData = sourceLookup[itemID]
   openItemsCount = openItemsCount + 1

   if sourceData and sourceData.sourceType == "dungeon" then
    local mapID = tonumber(sourceData.sourceID) or 0
    local bucket = dungeonBuckets[mapID] or {
     id = mapID,
     name = GetChallengeMapName(mapID),
     count = 0,
    }
    bucket.count = bucket.count + 1
    dungeonBuckets[mapID] = bucket
   elseif sourceData and sourceData.sourceType == "raid" then
    local bossID = tonumber(sourceData.sourceID) or 0
    if not IsRaidBossLocked(profile, bossID) then
     local bucket = raidBuckets[bossID] or {
      id = bossID,
      name = GetBossName(bossID),
      count = 0,
     }
     bucket.count = bucket.count + 1
     raidBuckets[bossID] = bucket
    end
   end
  end
 end

 local function ToSortedList(bucketTable)
  local list = {}
  for _, entry in pairs(bucketTable) do
   list[#list + 1] = entry
  end

  table.sort(list, function(left, right)
   if left.count == right.count then
    return (left.name or "") < (right.name or "")
   end

   return left.count > right.count
  end)

  return list
 end

 local dungeonTargets = ToSortedList(dungeonBuckets)
 local raidTargets = ToSortedList(raidBuckets)
 local dungeonCountByMap = {}
 local raidCountByBoss = {}

 for _, entry in ipairs(dungeonTargets) do
  dungeonCountByMap[entry.id] = entry.count
 end

 for _, entry in ipairs(raidTargets) do
  raidCountByBoss[entry.id] = entry.count
 end

 return {
  hasImport = true,
  openItemsCount = openItemsCount,
  dungeonTargets = dungeonTargets,
  raidTargets = raidTargets,
  dungeonCountByMap = dungeonCountByMap,
  raidCountByBoss = raidCountByBoss,
  topDungeon = dungeonTargets[1],
  topRaid = raidTargets[1],
 }
end

local function GetDungeonVaultRow(profile)
 if IsCurrentProfile(profile) then
  return BuildLiveDungeonVaultRow(profile)
 end

 local vault = profile and profile.vault
 local rows = vault and vault.rows
 local dungeonRow = rows and rows[2]
 if type(dungeonRow) == "table" then
  return dungeonRow
 end

 local row = CreateDefaultDungeonVaultRow()
 ApplyDungeonVaultFallback(row, profile)
 return row
end

local function GetNextVaultUnlock(profile)
 local dungeonRow = GetDungeonVaultRow(profile)
 if type(dungeonRow) ~= "table" then
  return nil, nil, nil
 end

 for slotIndex, slotData in ipairs(dungeonRow) do
  if not slotData.unlocked then
   local threshold = tonumber(slotData.threshold) or 0
   local progress = tonumber(slotData.progress) or 0
   local missing = math.max(threshold - progress, 0)
   return slotIndex, missing, slotData
  end
 end

 return nil, 0, dungeonRow[#dungeonRow]
end

local function GetSortedLoggedLevels(profile)
 local levels = {}
 for _, entry in ipairs(GetCharacterLogs(profile)) do
  local level = tonumber(entry and entry.level)
  if level and level > 0 then
   levels[#levels + 1] = level
  end
 end

 table.sort(levels, function(left, right)
  return left > right
 end)

 return levels
end

local ADVISOR_MAX_DUNGEON_KEY_LEVEL = 10

local function GetStrictNextDungeonVaultLevel(currentLevel)
 currentLevel = tonumber(currentLevel) or 0
 if currentLevel <= 0 then
  return nil, false
 end

 if currentLevel >= ADVISOR_MAX_DUNGEON_KEY_LEVEL then
  return nil, true
 end

 if WeeklyRewardsUtil and WeeklyRewardsUtil.GetNextMythicLevel then
  local nextLevel = WeeklyRewardsUtil.GetNextMythicLevel(currentLevel)
  if type(nextLevel) == "number" then
   if nextLevel > ADVISOR_MAX_DUNGEON_KEY_LEVEL then
    return nil, true
   end

   if nextLevel > currentLevel then
    return nextLevel, true
   end
  end

  return nil, true
 end

 local fallbackNextLevel = currentLevel + 1
 if fallbackNextLevel > ADVISOR_MAX_DUNGEON_KEY_LEVEL then
  return nil, true
 end

 return fallbackNextLevel, true
end

local function GetConfiguredRaidDifficulty()
 local raidSettings
 if MRTE_GetRaidDifficultySettings then
  raidSettings = MRTE_GetRaidDifficultySettings()
 else
  local uiSettings = MRTE_GetUISettings and MRTE_GetUISettings() or nil
  raidSettings = uiSettings and uiSettings.raidDifficulties or nil
 end

 if type(raidSettings) ~= "table" then
  return nil, nil
 end

 if raidSettings.mythic then
  return "mythic", L.DIFFICULTY_MYTHIC
 end

 if raidSettings.heroic then
  return "heroic", L.DIFFICULTY_HEROIC
 end

 if raidSettings.normal then
  return "normal", L.DIFFICULTY_NORMAL or "Normal"
 end

 return nil, nil
end

local function CountLockedPortals(profile)
 local portals = profile and profile.portals and profile.portals.portals
 if type(portals) ~= "table" then
  return 0, nil, {}
 end

 local count = 0
 local locked = {}
 for _, portalData in ipairs(portals) do
  if type(portalData) == "table" and not portalData.isUnlocked then
   count = count + 1
   locked[#locked + 1] = portalData
  end
 end

 table.sort(locked, function(left, right)
  return (left.name or "") < (right.name or "")
 end)

 return count, locked[1], locked
end

local function IsPortalLockedForMap(profile, mapID)
 local portals = profile and profile.portals and profile.portals.portals
 if type(portals) ~= "table" then
  return false
 end

 for _, portalData in ipairs(portals) do
  if tonumber(portalData.challengeMapID) == tonumber(mapID) then
   return not not (not portalData.isUnlocked)
  end
 end

 return false
end

local function GetMythicRows(profile)
 local mythic = profile and profile.mythic
 local rows = mythic and mythic.rows
 return type(rows) == "table" and rows or {}
end

local function BuildMythicRowLookup(profile)
 local lookup = {}
 for _, row in ipairs(GetMythicRows(profile)) do
  local mapID = tonumber(row.challengeMapID)
  if mapID and mapID > 0 then
   lookup[mapID] = row
  end
 end
 return lookup
end

local function BuildActiveGroupMemberLookup()
 local members = {}
 local normalizeName = MRTE_NormalizeGuildMemberName

 local function AddUnit(unit)
  if not normalizeName or not UnitExists or not UnitExists(unit) or not GetUnitName then
   return
  end

  local fullName = GetUnitName(unit, true)
  local memberKey = fullName and normalizeName(fullName)
  if memberKey then
   members[memberKey] = true
  end
 end

 AddUnit("player")

 if IsInRaid and IsInRaid() then
  for index = 1, GetNumGroupMembers() do
   AddUnit("raid" .. index)
  end
 elseif IsInGroup and IsInGroup() then
  for index = 1, GetNumSubgroupMembers() do
   AddUnit("party" .. index)
  end
 end

 return members
end

local function BuildPartyKeyEntries()
 local entries = {}
 local normalizeName = MRTE_NormalizeGuildMemberName
 if type(normalizeName) ~= "function" then
  return entries
 end

 local activeMembers = BuildActiveGroupMemberLookup()
 local groupKeys = MRTE_CharDB and MRTE_CharDB.groupKeys or {}

 for memberKey, entry in pairs(groupKeys) do
  if activeMembers[memberKey] and type(entry) == "table" then
   local keyLevel = tonumber(entry.keyLevel) or 0
   local keyMapID = tonumber(entry.keyMapID) or 0
   if keyLevel > 0 and keyMapID > 0 then
    entries[#entries + 1] = {
     memberKey = memberKey,
     displayName = entry.displayName or entry.name or memberKey,
     keyLevel = keyLevel,
     keyMapID = keyMapID,
     isPlayer = memberKey == normalizeName(GetUnitName and GetUnitName("player", true) or ""),
    }
   end
  end
 end

 if C_MythicPlus and C_MythicPlus.GetOwnedKeystoneLevel and C_MythicPlus.GetOwnedKeystoneChallengeMapID and GetUnitName then
  local ownLevelValue = C_MythicPlus.GetOwnedKeystoneLevel()
  local ownMapIDValue = C_MythicPlus.GetOwnedKeystoneChallengeMapID()
  local ownLevel = tonumber(ownLevelValue or 0) or 0
  local ownMapID = tonumber(ownMapIDValue or 0) or 0
  local ownMemberKey = normalizeName(GetUnitName("player", true))
  if ownLevel > 0 and ownMapID > 0 and ownMemberKey then
   local found = false
   for _, entry in ipairs(entries) do
    if entry.memberKey == ownMemberKey then
     entry.keyLevel = ownLevel
     entry.keyMapID = ownMapID
     entry.isPlayer = true
     found = true
     break
    end
   end

   if not found then
    entries[#entries + 1] = {
     memberKey = ownMemberKey,
     displayName = L.CURRENT_KEYS_YOU,
     keyLevel = ownLevel,
     keyMapID = ownMapID,
     isPlayer = true,
    }
   end
  end
 end

 table.sort(entries, function(left, right)
  if left.isPlayer ~= right.isPlayer then
   return left.isPlayer
  end

  if left.keyLevel ~= right.keyLevel then
   return left.keyLevel > right.keyLevel
  end

  return (left.displayName or "") < (right.displayName or "")
 end)

 return entries
end

local function GetNextVaultReason(profile)
 local slotIndex, missing = GetNextVaultUnlock(profile)
 if slotIndex and missing and missing > 0 then
  return MRTE_T("ADVISOR_ALT_REASON_VAULT", slotIndex, missing, missing == 1 and L.DUNGEON or L.DUNGEONS)
 end

 return nil
end

local function BuildBestGroupKey(profile, importSummary)
 local entries = BuildPartyKeyEntries()
 if #entries == 0 then
  return nil, entries
 end

 local rowLookup = BuildMythicRowLookup(profile)
 local bestEntry

 for _, entry in ipairs(entries) do
  local score = (tonumber(entry.keyLevel) or 0) * 4
  local reasons = {}
  local runData = rowLookup[entry.keyMapID]
  local bestLevel = tonumber(runData and runData.level) or 0
  local targetCount = tonumber(importSummary and importSummary.dungeonCountByMap and importSummary.dungeonCountByMap[entry.keyMapID]) or 0

  if bestLevel <= 0 then
   score = score + 90
   reasons[#reasons + 1] = L.ADVISOR_REASON_NEW_SCORE
  elseif entry.keyLevel > bestLevel then
   score = score + 50 + ((entry.keyLevel - bestLevel) * 8)
   reasons[#reasons + 1] = L.ADVISOR_REASON_SCORE_UPGRADE
  end

  if targetCount > 0 then
   score = score + (targetCount * 35)
   reasons[#reasons + 1] = MRTE_T("ADVISOR_REASON_TARGET_ITEMS", targetCount, targetCount == 1 and L.ADVISOR_ITEM or L.ADVISOR_ITEMS)
  end

  if IsPortalLockedForMap(profile, entry.keyMapID) then
   score = score + 25
   reasons[#reasons + 1] = L.ADVISOR_REASON_PORTAL
  end

  local slotIndex, missing = GetNextVaultUnlock(profile)
  if slotIndex and missing and missing > 0 then
   score = score + 15
   reasons[#reasons + 1] = L.ADVISOR_REASON_VAULT
  end

  entry.scoreValue = score
  entry.reasonText = #reasons > 0 and table.concat(reasons, ", ") or L.ADVISOR_REASON_PUSH
  entry.label = MRTE_T("ADVISOR_GROUP_KEY_LABEL", entry.displayName or L.PLAYER, entry.keyLevel, GetChallengeMapName(entry.keyMapID))

  if not bestEntry or entry.scoreValue > bestEntry.scoreValue then
   bestEntry = entry
  end
 end

 return bestEntry, entries
end

local function BuildAltPriorityEntries()
 local entries = {}

 for _, profile in ipairs(GetAllProfiles()) do
  local importSummary = BuildImportSummary(profile)
  local score = 0
  local reasons = {}
  local nextVaultReason = GetNextVaultReason(profile)
  local lockedPortalCount = CountLockedPortals(profile)
  local openItems = tonumber(importSummary.openItemsCount) or 0

  if nextVaultReason then
   local slotIndex = GetNextVaultUnlock(profile)
   if slotIndex == 1 then
    score = score + 100
   elseif slotIndex == 2 then
    score = score + 70
   else
    score = score + 45
   end
   reasons[#reasons + 1] = nextVaultReason
  end

  if lockedPortalCount > 0 then
   score = score + (math.min(lockedPortalCount, 4) * 18)
   reasons[#reasons + 1] = MRTE_T("ADVISOR_ALT_REASON_PORTALS", lockedPortalCount, lockedPortalCount == 1 and L.ADVISOR_PORTAL or L.ADVISOR_PORTALS)
  end

  if openItems > 0 then
   score = score + (math.min(openItems, 6) * 14)
   reasons[#reasons + 1] = MRTE_T("ADVISOR_ALT_REASON_LOOT", openItems, openItems == 1 and L.ADVISOR_ITEM or L.ADVISOR_ITEMS)
  end

  local totalScore = tonumber(profile.mythic and profile.mythic.totalScore) or 0
  if totalScore > 0 and totalScore < 1200 then
   score = score + 10
   reasons[#reasons + 1] = MRTE_T("ADVISOR_ALT_REASON_SCORE", FormatScore(totalScore))
  end

  if score > 0 then
   entries[#entries + 1] = {
    profile = profile,
    scoreValue = score,
    reasonText = reasons[1] or L.ADVISOR_NOTHING_URGENT,
    extraReason = reasons[2],
   }
  end
 end

 table.sort(entries, function(left, right)
  if left.scoreValue == right.scoreValue then
   return GetProfileDisplayName(left.profile) < GetProfileDisplayName(right.profile)
  end

  return left.scoreValue > right.scoreValue
 end)

 return entries
end

local function BuildTodayLines(profile, importSummary, bestGroupEntry, altEntries)
 local lines = {}
 local slotIndex, missing = GetNextVaultUnlock(profile)
 local _, firstLockedPortal = CountLockedPortals(profile)

 if slotIndex and missing and missing > 0 then
  lines[#lines + 1] = MRTE_T("ADVISOR_RUNS_FOR_SLOT", missing, missing == 1 and "" or "s", slotIndex)
 end

 if importSummary and importSummary.topDungeon then
  local itemCount = tonumber(importSummary.topDungeon.count) or 0
  lines[#lines + 1] = MRTE_T("ADVISOR_FARM_DUNGEON", importSummary.topDungeon.name, itemCount, itemCount == 1 and "" or "s")
 end

 if firstLockedPortal and firstLockedPortal.name then
  lines[#lines + 1] = MRTE_T("ADVISOR_UNLOCK_PORTAL", firstLockedPortal.name)
 end

 if bestGroupEntry then
  lines[#lines + 1] = MRTE_T("ADVISOR_GROUP_RUN", bestGroupEntry.label)
 end

 if altEntries and altEntries[1] and altEntries[1].profile and altEntries[1].profile.key ~= profile.key then
  lines[#lines + 1] = MRTE_T("ADVISOR_ALT_FOCUS", GetProfileDisplayName(altEntries[1].profile), altEntries[1].reasonText)
 end

 lines = TrimLines(lines, 4)
 if #lines == 0 then
  lines[1] = L.ADVISOR_NOTHING_URGENT
 end

 return lines
end

local function BuildVaultPlannerLines(profile)
 local dungeonRow = GetDungeonVaultRow(profile)
 local levels = GetSortedLoggedLevels(profile)
 local lines = {}

 if type(dungeonRow) ~= "table" then
  return { L.ADVISOR_VAULT_NO_DATA }
 end

 for slotIndex, threshold in ipairs(ADVISOR_VAULT_THRESHOLDS) do
  local slotData = dungeonRow[slotIndex]
  local progress = tonumber(slotData and slotData.progress) or 0
  local weakestRun = levels[threshold]
  local unlocked = not not (slotData and slotData.unlocked)
  local currentLevel = tonumber(weakestRun) or tonumber(slotData and slotData.level) or 0
  local nextLevel, knowsCap = GetStrictNextDungeonVaultLevel(currentLevel)
  if not unlocked then
   local missing = math.max(threshold - progress, 0)
   lines[#lines + 1] = MRTE_T("ADVISOR_UNLOCK_SLOT", slotIndex, missing, missing == 1 and L.DUNGEON or L.DUNGEONS)
  elseif knowsCap and currentLevel > 0 and not nextLevel then
   local raidDifficultyKey, raidDifficultyLabel = GetConfiguredRaidDifficulty()
   if raidDifficultyKey == "mythic" and raidDifficultyLabel then
    lines[#lines + 1] = MRTE_T("ADVISOR_VAULT_SLOT_MAXED_RAID", slotIndex, raidDifficultyLabel)
   else
    lines[#lines + 1] = MRTE_T("ADVISOR_VAULT_SLOT_MAXED", slotIndex)
   end
  elseif currentLevel > 0 and nextLevel then
   lines[#lines + 1] = MRTE_T("ADVISOR_REPLACE_SLOT", slotIndex, currentLevel, nextLevel)
  elseif weakestRun and weakestRun > 0 then
   lines[#lines + 1] = MRTE_T("ADVISOR_REPLACE_SLOT", slotIndex, weakestRun, weakestRun + 1)
  else
   lines[#lines + 1] = MRTE_T("ADVISOR_IMPROVE_SLOT_GENERIC", slotIndex, threshold, threshold == 1 and L.DUNGEON or L.DUNGEONS)
  end
 end

 return TrimLines(lines, 4)
end

local function BuildGroupKeyLines(profile, importSummary)
 local bestEntry, entries = BuildBestGroupKey(profile, importSummary)
 if not bestEntry then
  return { L.ADVISOR_NO_GROUP_KEYS }
 end

 local lines = {
  bestEntry.label,
  MRTE_T("ADVISOR_WHY_LINE", bestEntry.reasonText),
 }

 if entries[2] then
  lines[#lines + 1] = MRTE_T("ADVISOR_BACKUP_LINE", entries[2].label)
 end

 return TrimLines(lines, 4)
end

local function BuildAltPriorityLines(entries)
 if not entries or not entries[1] then
  return { L.ADVISOR_NO_ALT_DATA }
 end

 local lines = {}

 for index = 1, math.min(#entries, 3) do
  local entry = entries[index]
  lines[#lines + 1] = MRTE_T("ADVISOR_ALT_LINE", index, GetProfileDisplayName(entry.profile), entry.reasonText)
 end

 return lines
end

local function CreateAdvisorSection(parent, titleText, anchorPoint, anchorX, anchorY)
 local section = CreateFrame("Frame", nil, parent, "BackdropTemplate")
 section:SetSize(SECTION_WIDTH, SECTION_HEIGHT)
 section:SetPoint(anchorPoint, anchorX, anchorY)
 MRTE_Style(section)

 section.title = section:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
 section.title:SetPoint("TOPLEFT", 14, -10)
 section.title:SetPoint("TOPRIGHT", -14, -10)
 section.title:SetJustifyH("LEFT")
 section.title:SetText(titleText)
 MRTE_StyleTitle(section.title, 15)

 section.body = section:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
 section.body:SetPoint("TOPLEFT", section.title, "BOTTOMLEFT", 0, -10)
 section.body:SetPoint("BOTTOMRIGHT", -14, 12)
 section.body:SetJustifyH("LEFT")
 section.body:SetJustifyV("TOP")
 section.body:SetSpacing(4)
 section.body:SetText("")
 MRTE_StyleStatus(section.body)

 return section
end

local function SetSectionLines(section, lines)
 if not section or not section.body then
  return
 end

 lines = TrimLines(lines, 4)
 if #lines == 0 then
  lines = { L.ADVISOR_NOTHING_URGENT }
 end

 section.body:SetText(table.concat(lines, "\n"))
end

local function SetAdvisorSectionLines(sectionKey, lines)
 if MRTE_AdvisorFrame and MRTE_AdvisorFrame.sections and MRTE_AdvisorFrame.sections[sectionKey] then
  SetSectionLines(MRTE_AdvisorFrame.sections[sectionKey], lines)
 end

 local globalName = EMBEDDED_SECTION_GLOBALS[sectionKey]
 local embeddedPanel = globalName and _G[globalName]
 if embeddedPanel then
  SetSectionLines(embeddedPanel, lines)
 end
end

local function HasAdvisorRenderTargets()
 if MRTE_AdvisorFrame then
  return true
 end

 for _, globalName in pairs(EMBEDDED_SECTION_GLOBALS) do
  if _G[globalName] then
   return true
  end
 end

 return false
end

function MRTE_UpdateAdvisorPanel()
 if not HasAdvisorRenderTargets() then
  return
 end

 local profile = GetSelectedProfile()
 if not profile then
  if MRTE_AdvisorFrame and MRTE_AdvisorFrame.characterLabel then
   MRTE_AdvisorFrame.characterLabel:SetText(L.ADVISOR_NO_SELECTED_CHARACTER)
  end

  SetAdvisorSectionLines("today", { L.ADVISOR_NO_SELECTED_CHARACTER })
  SetAdvisorSectionLines("vault", { L.ADVISOR_NO_SELECTED_CHARACTER })
  SetAdvisorSectionLines("group", { L.ADVISOR_NO_SELECTED_CHARACTER })
  SetAdvisorSectionLines("alts", { L.ADVISOR_NO_SELECTED_CHARACTER })
  return
 end

 local importSummary = BuildImportSummary(profile)
 local altEntries = BuildAltPriorityEntries()
 local bestGroupEntry = BuildBestGroupKey(profile, importSummary)
 local totalScore = tonumber(profile.mythic and profile.mythic.totalScore) or 0

 if MRTE_AdvisorFrame and MRTE_AdvisorFrame.characterLabel then
  MRTE_AdvisorFrame.characterLabel:SetText(MRTE_T("ADVISOR_CHARACTER_LINE", GetProfileDisplayName(profile), FormatScore(totalScore), importSummary.openItemsCount or 0))
 end

 SetAdvisorSectionLines("today", BuildTodayLines(profile, importSummary, bestGroupEntry, altEntries))
 SetAdvisorSectionLines("vault", BuildVaultPlannerLines(profile))
 SetAdvisorSectionLines("group", BuildGroupKeyLines(profile, importSummary))
 SetAdvisorSectionLines("alts", BuildAltPriorityLines(altEntries))
end

function MRTE_OpenAdvisorWindow()
 if not MRTE_AdvisorFrame then
  return
 end

 MRTE_AdvisorFrame:Show()
 if MRTE_AdvisorFrame.Raise then
  MRTE_AdvisorFrame:Raise()
 end

 MRTE_UpdateAdvisorPanel()
end

function MRTE_ToggleAdvisorWindow()
 if not MRTE_AdvisorFrame then
  return
 end

 if MRTE_AdvisorFrame:IsShown() then
  MRTE_AdvisorFrame:Hide()
 else
  MRTE_OpenAdvisorWindow()
 end
end

function MRTE_CreateAdvisorUI()
 if MRTE_AdvisorFrame then
  return
 end

 local frame = CreateFrame("Frame", "MRTE_AdvisorFrame", UIParent, "BackdropTemplate")
 frame:SetSize(ADVISOR_WIDTH, ADVISOR_HEIGHT)
 frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
 frame:SetFrameStrata("DIALOG")
 frame:SetToplevel(true)
 frame:SetClampedToScreen(true)
 frame:SetMovable(true)
 frame:EnableMouse(true)
 frame:RegisterForDrag("LeftButton")
 frame:SetScript("OnDragStart", frame.StartMoving)
 frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
 MRTE_Style(frame)
 RegisterForEscape(frame)
 frame:Hide()

 frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
 frame.title:SetPoint("TOPLEFT", 18, -12)
 frame.title:SetText(L.ADVISOR_TITLE)
 MRTE_StyleTitle(frame.title, 18)

 frame.closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
 frame.closeButton:SetPoint("TOPRIGHT", -5, -5)
 frame.closeButton:SetSize(24, 24)

 frame.characterLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
 frame.characterLabel:SetPoint("TOPLEFT", frame.title, "BOTTOMLEFT", 0, -6)
 frame.characterLabel:SetPoint("TOPRIGHT", -18, -36)
 frame.characterLabel:SetJustifyH("LEFT")
 frame.characterLabel:SetText("")
 MRTE_StyleStatus(frame.characterLabel)

 frame.sections = {}
 frame.sections.today = CreateAdvisorSection(frame, L.PANEL_ADVISOR_TODAY, "TOPLEFT", SECTION_MARGIN_X, SECTION_START_Y)
 frame.sections.vault = CreateAdvisorSection(frame, L.PANEL_ADVISOR_VAULT, "TOPLEFT", SECTION_MARGIN_X + SECTION_WIDTH + SECTION_GAP_X, SECTION_START_Y)
 frame.sections.group = CreateAdvisorSection(frame, L.PANEL_ADVISOR_GROUP, "TOPLEFT", SECTION_MARGIN_X, SECTION_START_Y - SECTION_HEIGHT - SECTION_GAP_Y)
 frame.sections.alts = CreateAdvisorSection(frame, L.PANEL_ADVISOR_ALTS, "TOPLEFT", SECTION_MARGIN_X + SECTION_WIDTH + SECTION_GAP_X, SECTION_START_Y - SECTION_HEIGHT - SECTION_GAP_Y)

 frame.footer = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
 frame.footer:SetPoint("BOTTOMLEFT", 18, 16)
 frame.footer:SetPoint("BOTTOMRIGHT", -18, 16)
 frame.footer:SetJustifyH("LEFT")
 frame.footer:SetText(L.ADVISOR_PROTOTYPE_NOTE)
 MRTE_StyleStatus(frame.footer)

 MRTE_AdvisorFrame = frame
 MRTE_UpdateAdvisorPanel()
end

advisorEvents:RegisterEvent("PLAYER_ENTERING_WORLD")
advisorEvents:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
advisorEvents:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
advisorEvents:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
advisorEvents:RegisterEvent("CHALLENGE_MODE_MAPS_UPDATE")
advisorEvents:RegisterEvent("CHALLENGE_MODE_COMPLETED")
advisorEvents:RegisterEvent("WEEKLY_REWARDS_UPDATE")
advisorEvents:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
advisorEvents:RegisterEvent("GROUP_ROSTER_UPDATE")
advisorEvents:RegisterEvent("SPELLS_CHANGED")
advisorEvents:RegisterEvent("SCENARIO_UPDATE")
advisorEvents:RegisterEvent("SCENARIO_CRITERIA_UPDATE")
advisorEvents:RegisterEvent("UPDATE_INSTANCE_INFO")
advisorEvents:RegisterEvent("BOSS_KILL")
advisorEvents:RegisterEvent("ENCOUNTER_END")
advisorEvents:SetScript("OnEvent", function(_, event)
 if event == "PLAYER_ENTERING_WORLD" or event == "UPDATE_INSTANCE_INFO" or event == "BOSS_KILL" or event == "ENCOUNTER_END" then
  advisorRaidLockoutCache = nil
 end

 if (event == "PLAYER_ENTERING_WORLD" or event == "BOSS_KILL" or event == "ENCOUNTER_END") and RequestRaidInfo then
  RequestRaidInfo()
 end

 if MRTE_UpdateAdvisorPanel then
  MRTE_UpdateAdvisorPanel()
 end
end)




