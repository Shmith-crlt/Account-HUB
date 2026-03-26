local L = MRTE_L

local WeeklyRewardTypes = Enum and Enum.WeeklyRewardChestThresholdType

local VAULT_TYPE_RAID = WeeklyRewardTypes and WeeklyRewardTypes.Raid or 1
local VAULT_TYPE_DUNGEONS = WeeklyRewardTypes and WeeklyRewardTypes.Activities or 2
local VAULT_TYPE_WORLD = WeeklyRewardTypes and WeeklyRewardTypes.World or 3
local VAULT_MAX_WORLD_TIER = 8

local VAULT_ROWS = {
 [1] = {
  type = VAULT_TYPE_RAID,
  thresholds = { 2, 4, 6 },
 },
 [2] = {
  type = VAULT_TYPE_DUNGEONS,
  thresholds = { 1, 4, 8 },
 },
 [3] = {
  type = VAULT_TYPE_WORLD,
  thresholds = { 2, 4, 8 },
 },
}

local function GetVaultTypeLabel(activityType)
 if activityType == VAULT_TYPE_RAID then
  return L.RAID
 end

 if activityType == VAULT_TYPE_DUNGEONS then
  return L.DUNGEONS
 end

 if activityType == VAULT_TYPE_WORLD then
  return L.WORLD
 end

 return L.PANEL_GREAT_VAULT
end

local function GetProgressText(progress, threshold)
 return math.min(progress or 0, threshold or 0) .. "/" .. (threshold or 0)
end

local function CreateDefaultRows()
 local rows = {}

 for rowIndex, rowLayout in ipairs(VAULT_ROWS) do
  rows[rowIndex] = {}

  for columnIndex, threshold in ipairs(rowLayout.thresholds) do
   rows[rowIndex][columnIndex] = {
    type = rowLayout.type,
    index = columnIndex,
    threshold = threshold,
    progress = 0,
    unlocked = false,
    source = "default",
    text = GetProgressText(0, threshold),
   }
  end
 end

 return rows
end

local function GetRowIndexForType(activityType)
 if activityType == VAULT_TYPE_RAID then
  return 1
 end

 if activityType == VAULT_TYPE_DUNGEONS then
  return 2
 end

 if activityType == VAULT_TYPE_WORLD then
  return 3
 end
end

local function FindSlotIndex(row, activity)
 local activityIndex = tonumber(activity and activity.index)

 if activityIndex and row[activityIndex] then
  return activityIndex
 end

 local threshold = tonumber(activity and activity.threshold)

 for index, slot in ipairs(row) do
  if slot.threshold == threshold then
   return index
  end
 end
end

local function GetRewardItemLink(activity)
 if not activity or not activity.id or not C_WeeklyRewards or not C_WeeklyRewards.GetExampleRewardItemHyperlinks then
  return nil
 end

 if activity.exampleRewardLink and activity.exampleRewardLink ~= "" then
  return activity.exampleRewardLink
 end

 local itemLink = C_WeeklyRewards.GetExampleRewardItemHyperlinks(activity.id)
 if itemLink and itemLink ~= "" then
  return itemLink
 end
end

local function GetUnlockedSlotText(activity)
 local itemLink = GetRewardItemLink(activity)

 if itemLink and C_Item and C_Item.GetDetailedItemLevelInfo then
  local itemLevel = C_Item.GetDetailedItemLevelInfo(itemLink)
  if type(itemLevel) == "number" and itemLevel > 0 then
   return tostring(itemLevel)
  end
 end

 if type(activity.level) == "number" and activity.level > 0 then
  return tostring(activity.level)
 end

 return L.OPEN
end

local function GetNextDungeonLevel(currentLevel)
 if WeeklyRewardsUtil and WeeklyRewardsUtil.GetNextMythicLevel then
  local nextLevel = WeeklyRewardsUtil.GetNextMythicLevel(currentLevel)
  if type(nextLevel) == "number" and nextLevel > currentLevel then
   return nextLevel
  end
 end

 return currentLevel + 1
end

local function CreateSlotData(activity, rowIndex, slotIndex)
 local threshold = tonumber(activity and activity.threshold) or 0
 local progress = tonumber(activity and activity.progress) or 0
  local unlocked = threshold > 0 and progress >= threshold

 return {
  activity = activity,
  type = activity and activity.type or (VAULT_ROWS[rowIndex] and VAULT_ROWS[rowIndex].type),
  index = tonumber(activity and activity.index) or slotIndex,
  threshold = threshold,
  progress = progress,
  unlocked = unlocked,
  level = tonumber(activity and activity.level),
  source = "api",
  text = unlocked and GetUnlockedSlotText(activity) or GetProgressText(progress, threshold),
 }
end

local function GetWeeklyRewardRows()
 local rows = CreateDefaultRows()

 if not C_WeeklyRewards or not C_WeeklyRewards.GetActivities then
  return rows, false
 end

 local activities = C_WeeklyRewards.GetActivities()
 if type(activities) ~= "table" or #activities == 0 then
  return rows, false
 end

 for _, activity in ipairs(activities) do
  if type(activity) == "table" then
   local rowIndex = GetRowIndexForType(activity.type)
   if rowIndex then
    local slotIndex = FindSlotIndex(rows[rowIndex], activity)
    if slotIndex then
     rows[rowIndex][slotIndex] = CreateSlotData(activity, rowIndex, slotIndex)
    end
   end
  end
 end

 return rows, true
end

local function ApplyDungeonFallback(rows, logs)
 logs = logs or {}
 local levels = {}

 for _, entry in ipairs(logs) do
  if type(entry) == "table" and type(entry.level) == "number" then
   levels[#levels + 1] = entry.level
  end
 end

 table.sort(levels, function(a, b)
  return a > b
 end)

 local runs = #levels
 local dungeonRow = rows[2]

 for columnIndex, slot in ipairs(dungeonRow) do
  local threshold = slot.threshold
  local rewardLevel = levels[threshold]
  local progress = math.min(runs, threshold)

  dungeonRow[columnIndex] = {
   type = VAULT_TYPE_DUNGEONS,
   index = columnIndex,
   threshold = threshold,
   progress = progress,
   unlocked = rewardLevel ~= nil,
   level = rewardLevel,
   source = "fallback",
   text = rewardLevel and tostring(rewardLevel) or (progress .. "/" .. threshold),
  }
 end
end

local function BuildLiveVaultData()
 local rows, hasWeeklyRewardData = GetWeeklyRewardRows()

 if not hasWeeklyRewardData then
  local currentLogs = MRTE_GetCharacterLogs and MRTE_GetCharacterLogs(MRTE_GetCurrentCharacterKey and MRTE_GetCurrentCharacterKey())
  ApplyDungeonFallback(rows, currentLogs)
 end

 return {
  rows = rows,
  hasWeeklyRewardData = hasWeeklyRewardData,
 }
end

local function GetDisplayVaultRows(liveData)
 if MRTE_SaveCharacterSection then
  MRTE_SaveCharacterSection("vault", liveData)
 end

 if not MRTE_IsViewingCurrentCharacter or MRTE_IsViewingCurrentCharacter() then
  return liveData.rows
 end

 local profile = MRTE_GetSelectedCharacterProfile and MRTE_GetSelectedCharacterProfile()
 if profile and type(profile.vault) == "table" and type(profile.vault.rows) == "table" then
  return profile.vault.rows
 end

 local rows = CreateDefaultRows()
 local selectedKey = MRTE_GetSelectedCharacterKey and MRTE_GetSelectedCharacterKey()
 local selectedLogs = MRTE_GetCharacterLogs and MRTE_GetCharacterLogs(selectedKey)
 ApplyDungeonFallback(rows, selectedLogs)

 return rows
end

local function GetNextStepText(slotData)
 if not slotData then
  return nil
 end

 local missing = math.max((slotData.threshold or 0) - (slotData.progress or 0), 0)
 local threshold = slotData.threshold or 0
 local currentLevel = slotData.level or (slotData.activity and tonumber(slotData.activity.level))

 if not slotData.unlocked then
  if slotData.type == VAULT_TYPE_RAID then
   return MRTE_T("VAULT_UNLOCK_RAID_SLOT", missing, missing == 1 and L.BOSS or L.BOSSES)
  end

  if slotData.type == VAULT_TYPE_DUNGEONS then
   return MRTE_T("VAULT_UNLOCK_DUNGEON_SLOT", missing, missing == 1 and L.DUNGEON or L.DUNGEONS)
  end

  if slotData.type == VAULT_TYPE_WORLD then
   return MRTE_T("VAULT_UNLOCK_WORLD_SLOT", missing, missing == 1 and L.DELVE or L.DELVES, L.WORLD_ACTIVITIES)
  end

  return L.VAULT_UNLOCK_GENERIC
 end

 if slotData.type == VAULT_TYPE_RAID then
  if currentLevel and DifficultyUtil and DifficultyUtil.GetNextPrimaryRaidDifficultyID then
   local nextDifficultyID = DifficultyUtil.GetNextPrimaryRaidDifficultyID(currentLevel)
   if nextDifficultyID then
    local nextDifficultyName = GetDifficultyInfo(nextDifficultyID) or L.NEXT_DIFFICULTY
    return MRTE_T("VAULT_IMPROVE_RAID_SLOT", threshold, nextDifficultyName)
   end
  end

  return L.VAULT_RAID_MAXED
 end

 if slotData.type == VAULT_TYPE_DUNGEONS then
  if currentLevel and currentLevel > 0 then
   local nextLevel = GetNextDungeonLevel(currentLevel)
   if nextLevel and nextLevel > currentLevel then
    return MRTE_T("VAULT_IMPROVE_DUNGEON_SLOT", threshold, nextLevel)
   end
  end

  return L.VAULT_IMPROVE_DUNGEON_GENERIC
 end

 if slotData.type == VAULT_TYPE_WORLD then
  if currentLevel and currentLevel < VAULT_MAX_WORLD_TIER then
   return MRTE_T("VAULT_IMPROVE_WORLD_SLOT", threshold, currentLevel + 1)
  end

  return L.VAULT_WORLD_MAXED
 end
end

function MRTE_ShowVaultSlotTooltip(cell)
 local slotData = cell and cell.slotData
 if not slotData then
  return
 end

 GameTooltip:SetOwner(cell, "ANCHOR_LEFT")
 GameTooltip:ClearLines()
 GameTooltip:AddLine(MRTE_T("VAULT_SLOT_TITLE", GetVaultTypeLabel(slotData.type), slotData.index or 0), 1.00, 0.82, 0.20)
 GameTooltip:AddDoubleLine(L.CURRENT, slotData.text or "-", 0.82, 0.82, 0.82, 1, 1, 1)
 GameTooltip:AddDoubleLine(L.PROGRESS, GetProgressText(slotData.progress, slotData.threshold), 0.82, 0.82, 0.82, 1, 1, 1)

 local nextStepText = GetNextStepText(slotData)
 if nextStepText and nextStepText ~= "" then
  GameTooltip:AddLine(" ")
  GameTooltip:AddLine(L.NEXT_HIGHER_TIER, 1.00, 0.82, 0.20)
  GameTooltip:AddLine(nextStepText, 1, 1, 1, true)
 end

 GameTooltip:Show()
end

local function ApplyVaultCellStyle(cell, slotData)
 if not cell or not cell.text or not slotData then
  return
 end

 cell.slotData = slotData
 cell.text:SetText(slotData.text or "")

 if slotData.unlocked then
  cell:SetBackdropColor(0.23, 0.20, 0.14, 0.95)
  cell:SetBackdropBorderColor(0.85, 0.69, 0.32, 1)
  cell.text:SetTextColor(1.00, 0.93, 0.78)
  return
 end

 if (slotData.progress or 0) > 0 then
  cell:SetBackdropColor(0.09, 0.09, 0.09, 0.95)
  cell:SetBackdropBorderColor(0.55, 0.43, 0.20, 1)
  cell.text:SetTextColor(0.90, 0.84, 0.70)
  return
 end

 cell:SetBackdropColor(0.05, 0.05, 0.05, 0.95)
 cell:SetBackdropBorderColor(0.23, 0.18, 0.10, 1)
 cell.text:SetTextColor(0.62, 0.58, 0.50)
end

function MRTE_UpdateVault()
 if not MRTE_VaultPanel or not MRTE_VaultPanel.cells then
  return
 end

 local liveData = BuildLiveVaultData()
 local rows = GetDisplayVaultRows(liveData)

 for rowIndex, row in ipairs(rows) do
  for columnIndex, slotData in ipairs(row) do
   local cell = MRTE_VaultPanel.cells[rowIndex] and MRTE_VaultPanel.cells[rowIndex][columnIndex]
   if cell then
    ApplyVaultCellStyle(cell, slotData)
   end
  end
 end
end

local vaultEvents = CreateFrame("Frame")
vaultEvents:RegisterEvent("WEEKLY_REWARDS_UPDATE")
vaultEvents:SetScript("OnEvent", function()
 if MRTE_UpdateVault then
  MRTE_UpdateVault()
 end
end)
