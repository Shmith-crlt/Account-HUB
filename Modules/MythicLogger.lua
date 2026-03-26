local L = MRTE_L

local floor = math.floor

local function FormatMythicScore(score)
 score = tonumber(score) or 0

 if score <= 0 then
  return "0"
 end

 local rounded = floor((score * 10) + 0.5) / 10
 if rounded == floor(rounded) then
  return tostring(floor(rounded))
 end

 return string.format("%.1f", rounded)
end

local function FormatMythicLevel(level, finishedSuccess)
 level = tonumber(level) or 0
 if level <= 0 then
  return "-"
 end

 return (finishedSuccess and "+" or "-") .. level
end

local function GetScoreColor(score, totalScore)
 if totalScore and C_ChallengeMode and C_ChallengeMode.GetDungeonScoreRarityColor then
  return C_ChallengeMode.GetDungeonScoreRarityColor(score)
 end

 if C_ChallengeMode and C_ChallengeMode.GetSpecificDungeonOverallScoreRarityColor then
  return C_ChallengeMode.GetSpecificDungeonOverallScoreRarityColor(score)
 end

 return HIGHLIGHT_FONT_COLOR
end

local function GetRatingSummary()
 if C_PlayerInfo and C_PlayerInfo.GetPlayerMythicPlusRatingSummary then
  return C_PlayerInfo.GetPlayerMythicPlusRatingSummary("player")
 end
end

local function BuildRunsByMap()
 local summary = GetRatingSummary()
 local runsByMap = {}

 if summary and type(summary.runs) == "table" then
  for _, run in ipairs(summary.runs) do
   if type(run) == "table" and type(run.challengeModeID) == "number" then
    runsByMap[run.challengeModeID] = run
   end
  end
 end

 return summary, runsByMap
end

local function GetNormalizedUnitName(unit)
 if not unit or not UnitExists or not UnitExists(unit) or not GetUnitName or not MRTE_NormalizeGuildMemberName then
  return nil
 end

 return MRTE_NormalizeGuildMemberName(GetUnitName(unit, true))
end

local function BuildActiveGroupMemberLookup()
 local members = {}

 local function AddUnit(unit)
  local memberKey = GetNormalizedUnitName(unit)
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

local function BuildGroupKeyMapLookup()
 local mapLookup = {}
 local groupKeys = (MRTE_CharDB and MRTE_CharDB.groupKeys) or {}
 local activeMembers = BuildActiveGroupMemberLookup()
 local playerKey = GetNormalizedUnitName("player")

 for memberKey, entry in pairs(groupKeys) do
  local keyLevel = tonumber(entry and entry.keyLevel) or 0
  local keyMapID = tonumber(entry and entry.keyMapID) or 0

  if memberKey ~= playerKey and activeMembers[memberKey] and keyLevel > 0 and keyMapID > 0 then
   mapLookup[keyMapID] = math.max(mapLookup[keyMapID] or 0, keyLevel)
  end
 end

 return mapLookup
end

local function BuildEmptyMythicData()
 return {
  totalScore = 0,
  trackedDungeons = 0,
  completedDungeons = 0,
  rows = {},
  logsCount = 0,
 }
end

local function GetCurrentLogCount()
 if MRTE_GetCharacterLogCount and MRTE_GetCurrentCharacterKey then
  return MRTE_GetCharacterLogCount(MRTE_GetCurrentCharacterKey())
 end

 return (MRTE_GlobalDB and #MRTE_GlobalDB.logs) or 0
end

local function BuildMythicSnapshot(data)
 local snapshot = MRTE_CopyTable and MRTE_CopyTable(data) or data
 local rows = snapshot and snapshot.rows

 if type(rows) == "table" then
  for _, row in ipairs(rows) do
   row.hasPartyKey = false
   row.groupKeyLevel = 0

   if not row.isOwnKey then
    row.currentKeyLevel = 0
    row.currentKeyOwner = nil
   end
  end
 end

 snapshot.logsCount = GetCurrentLogCount()
 return snapshot
end

local function GetDisplayMythicData(liveData)
 if MRTE_SaveCharacterSection then
  MRTE_SaveCharacterSection("mythic", BuildMythicSnapshot(liveData))
 end

 if not MRTE_IsViewingCurrentCharacter or MRTE_IsViewingCurrentCharacter() then
  liveData.logsCount = GetCurrentLogCount()
  return liveData
 end

 local profile = MRTE_GetSelectedCharacterProfile and MRTE_GetSelectedCharacterProfile()
 if profile and type(profile.mythic) == "table" then
  return profile.mythic
 end

 return BuildEmptyMythicData()
end

local function GetCurrentSeasonDungeonRows()
 local summary, runsByMap = BuildRunsByMap()
 local rows = {}
 local trackedDungeons = 0
 local completedDungeons = 0
 local totalScore = 0
 local ownKeyLevel = C_MythicPlus and C_MythicPlus.GetOwnedKeystoneLevel and C_MythicPlus.GetOwnedKeystoneLevel() or 0
 local ownKeyMapID = C_MythicPlus and C_MythicPlus.GetOwnedKeystoneChallengeMapID and C_MythicPlus.GetOwnedKeystoneChallengeMapID() or 0
 local groupKeyMaps = BuildGroupKeyMapLookup()

 if summary and type(summary.currentSeasonScore) == "number" then
  totalScore = summary.currentSeasonScore
 elseif C_ChallengeMode and C_ChallengeMode.GetOverallDungeonScore then
  totalScore = C_ChallengeMode.GetOverallDungeonScore() or 0
 end

 if not C_ChallengeMode or not C_ChallengeMode.GetMapTable or not C_ChallengeMode.GetMapUIInfo then
  return {
   totalScore = totalScore,
   trackedDungeons = 0,
   completedDungeons = 0,
   rows = rows,
  }
 end

 local challengeMaps = C_ChallengeMode.GetMapTable()
 if type(challengeMaps) ~= "table" then
  return {
   totalScore = totalScore,
   trackedDungeons = 0,
   completedDungeons = 0,
   rows = rows,
  }
 end

 for _, challengeMapID in ipairs(challengeMaps) do
  local mapName, _, _, mapTexture = C_ChallengeMode.GetMapUIInfo(challengeMapID)
  local run = runsByMap[challengeMapID]
  local mapScore = run and tonumber(run.mapScore) or 0
  local bestRunLevel = run and tonumber(run.bestRunLevel) or 0
  local finishedSuccess = run and run.finishedSuccess and true or false

  if (mapScore <= 0 or bestRunLevel <= 0) and C_MythicPlus then
   local _, bestOverallScore = C_MythicPlus.GetSeasonBestAffixScoreInfoForMap and C_MythicPlus.GetSeasonBestAffixScoreInfoForMap(challengeMapID)
   local bestTimedRun, bestNotTimedRun = C_MythicPlus.GetSeasonBestForMap and C_MythicPlus.GetSeasonBestForMap(challengeMapID)

   if mapScore <= 0 and type(bestOverallScore) == "number" then
    mapScore = bestOverallScore
   end

   if bestRunLevel <= 0 then
    local timedLevel = bestTimedRun and tonumber(bestTimedRun.level) or 0
    local depletedLevel = bestNotTimedRun and tonumber(bestNotTimedRun.level) or 0
    bestRunLevel = math.max(timedLevel, depletedLevel)
    finishedSuccess = timedLevel >= depletedLevel and timedLevel > 0
   end
  end

  trackedDungeons = trackedDungeons + 1
  if bestRunLevel > 0 or mapScore > 0 then
   completedDungeons = completedDungeons + 1
  end

  local hasOwnKey = ownKeyLevel > 0 and ownKeyMapID == challengeMapID
  local groupKeyLevel = tonumber(groupKeyMaps[challengeMapID]) or 0

  rows[#rows + 1] = {
   challengeMapID = challengeMapID,
   name = mapName or (L.DUNGEON .. " " .. challengeMapID),
   texture = mapTexture,
   score = mapScore,
   level = bestRunLevel,
   finishedSuccess = finishedSuccess,
   isOwnKey = hasOwnKey,
   ownKeyLevel = hasOwnKey and ownKeyLevel or 0,
   hasPartyKey = groupKeyLevel > 0,
   groupKeyLevel = groupKeyLevel,
   currentKeyLevel = hasOwnKey and ownKeyLevel or groupKeyLevel,
   currentKeyOwner = hasOwnKey and "player" or (groupKeyLevel > 0 and "group" or nil),
  }
 end

 return {
  totalScore = totalScore,
  trackedDungeons = trackedDungeons,
  completedDungeons = completedDungeons,
  rows = rows,
 }
end

local function TruncateCurrentKeyLabel(text, maxLength)
 text = text or ""
 if #text <= maxLength then
  return text
 end

 return text:sub(1, maxLength - 3) .. "..."
end

local function GetCurrentKeyLabel(entry)
 local keyLevel = tonumber(entry and entry.keyLevel) or 0
 local keyMapID = tonumber(entry and entry.keyMapID) or 0

 if keyLevel < 0 then
  return L.KEY_HIDDEN
 end

 if keyLevel <= 0 or keyMapID <= 0 then
  return L.NO_KEY
 end

 local dungeonName = C_ChallengeMode and C_ChallengeMode.GetMapUIInfo and C_ChallengeMode.GetMapUIInfo(keyMapID)
 if type(dungeonName) == "string" and dungeonName ~= "" then
  return "+" .. keyLevel .. " " .. TruncateCurrentKeyLabel(dungeonName, 16)
 end

 return "+" .. keyLevel
end

local function BuildCurrentKeyEntries()
 local entries = {}
 local groupKeys = (MRTE_CharDB and MRTE_CharDB.groupKeys) or {}
 local activeMembers = BuildActiveGroupMemberLookup()
 local playerKey = GetNormalizedUnitName("player")

 for memberKey, entry in pairs(groupKeys) do
  if activeMembers[memberKey] and type(entry) == "table" then
   entries[#entries + 1] = {
    name = entry.name,
    displayName = memberKey == playerKey and L.CURRENT_KEYS_YOU or (entry.displayName or entry.name or L.PLAYER),
    keyLevel = tonumber(entry.keyLevel) or 0,
    keyMapID = tonumber(entry.keyMapID) or 0,
    isPlayer = memberKey == playerKey,
   }
  end
 end

 table.sort(entries, function(left, right)
  if left.isPlayer ~= right.isPlayer then
   return left.isPlayer
  end

  if left.keyLevel ~= right.keyLevel then
   return left.keyLevel > right.keyLevel
  end

  return (left.displayName or left.name or "") < (right.displayName or right.name or "")
 end)

 return entries
end

function MRTE_ShowCurrentKeyTooltip(row)
 local keyData = row and row.keyData
 if not keyData then
  return
 end

 local keyLevel = tonumber(keyData.keyLevel) or 0
 local keyMapID = tonumber(keyData.keyMapID) or 0
 local dungeonName = keyMapID > 0 and C_ChallengeMode and C_ChallengeMode.GetMapUIInfo and C_ChallengeMode.GetMapUIInfo(keyMapID) or nil

 GameTooltip:SetOwner(row, "ANCHOR_RIGHT")
 GameTooltip:ClearLines()
 GameTooltip:AddLine(keyData.displayName or keyData.name or L.PLAYER, keyData.isPlayer and 0.45 or 1.00, keyData.isPlayer and 1.00 or 0.92, keyData.isPlayer and 0.45 or 0.25)

 if keyLevel < 0 then
  GameTooltip:AddDoubleLine(L.KEY, L.KEY_HIDDEN, 0.82, 0.82, 0.82, 1, 0.82, 0.20)
 elseif keyLevel > 0 and keyMapID > 0 then
  GameTooltip:AddDoubleLine(L.KEY, "+" .. keyLevel, 0.82, 0.82, 0.82, 1, 1, 1)
  if dungeonName then
   GameTooltip:AddDoubleLine(L.DUNGEON, dungeonName, 0.82, 0.82, 0.82, 1, 1, 1)
  end
 else
  GameTooltip:AddDoubleLine(L.KEY, L.NO_KEY, 0.82, 0.82, 0.82, 0.68, 0.68, 0.68)
 end

 GameTooltip:Show()
end

local function ApplyCurrentKeyRowStyle(row, entry)
 if not row or not entry then
  return
 end

 row.keyData = entry
 row.name:SetText(entry.displayName or entry.name or L.PLAYER)
 row.key:SetText(GetCurrentKeyLabel(entry))

 if entry.isPlayer then
  row:SetBackdropColor(0.09, 0.14, 0.10, 0.92)
  row:SetBackdropBorderColor(0.25, 0.55, 0.30, 1)
  row.name:SetTextColor(0.76, 1.00, 0.76)
  row.key:SetTextColor(0.85, 1.00, 0.85)
  return
 end

 if (tonumber(entry.keyLevel) or 0) > 0 then
  row:SetBackdropColor(0.15, 0.12, 0.07, 0.92)
  row:SetBackdropBorderColor(0.55, 0.44, 0.18, 1)
  row.name:SetTextColor(1.00, 0.94, 0.82)
  row.key:SetTextColor(1.00, 0.90, 0.72)
  return
 end

 row:SetBackdropColor(0.08, 0.08, 0.08, 0.92)
 row:SetBackdropBorderColor(0.20, 0.16, 0.10, 1)
 row.name:SetTextColor(0.80, 0.80, 0.80)
 row.key:SetTextColor(0.70, 0.70, 0.70)
end

function MRTE_UpdateCurrentKeysPanel()
 if not MRTE_CurrentKeysPanel or not MRTE_CurrentKeysPanel.rows or not MRTE_CurrentKeysPanel.content then
  return
 end

 local entries = BuildCurrentKeyEntries()

 if #entries == 0 then
  MRTE_CurrentKeysPanel.emptyText:Show()
  MRTE_CurrentKeysPanel.content:SetHeight(1)

  for _, row in ipairs(MRTE_CurrentKeysPanel.rows) do
   row.keyData = nil
   row:Hide()
  end

  return
 end

 MRTE_CurrentKeysPanel.emptyText:Hide()
 MRTE_CurrentKeysPanel.content:SetHeight(math.max(#entries * 28, 1))

 for index, row in ipairs(MRTE_CurrentKeysPanel.rows) do
  local entry = entries[index]

  if entry then
   ApplyCurrentKeyRowStyle(row, entry)
   row:Show()
  else
   row.keyData = nil
   row:Hide()
  end
 end
end

function MRTE_ShowMythicDungeonTooltip(row)
 local runData = row and row.runData
 if not runData then
  return
 end

 local scoreColor = GetScoreColor(runData.score)
 scoreColor = scoreColor or HIGHLIGHT_FONT_COLOR

 GameTooltip:SetOwner(row, "ANCHOR_RIGHT")
 GameTooltip:ClearLines()
 GameTooltip:AddLine(runData.name or L.MYTHIC_DUNGEON, 1, 1, 1)
 GameTooltip:AddDoubleLine(L.DUNGEON_SCORE, FormatMythicScore(runData.score), 0.82, 0.82, 0.82, scoreColor.r, scoreColor.g, scoreColor.b)
 GameTooltip:AddDoubleLine(L.BEST_KEY, FormatMythicLevel(runData.level, runData.finishedSuccess), 0.82, 0.82, 0.82, 1, 1, 1)

 if (runData.ownKeyLevel or 0) > 0 then
  GameTooltip:AddDoubleLine(L.OWN_KEY, "+" .. tostring(runData.ownKeyLevel), 0.82, 0.82, 0.82, 0.45, 1.00, 0.45)
 end

 if (runData.groupKeyLevel or 0) > 0 then
  GameTooltip:AddDoubleLine(L.GROUP_KEY, "+" .. tostring(runData.groupKeyLevel), 0.82, 0.82, 0.82, 1.00, 0.82, 0.25)
 end

 if (runData.level or 0) <= 0 then
  GameTooltip:AddLine(" ")
  GameTooltip:AddLine(L.NO_RATED_RUN_THIS_SEASON, 1, 1, 1, true)
 elseif runData.finishedSuccess then
  GameTooltip:AddLine(" ")
  GameTooltip:AddLine(L.BEST_RUN_TIMED, 0.55, 1.00, 0.55, true)
 else
  GameTooltip:AddLine(" ")
  GameTooltip:AddLine(L.BEST_RUN_DEPLETED, 1.00, 0.65, 0.40, true)
 end

 GameTooltip:Show()
end

local function ApplyMythicKeyOutline(row, runData)
 if not row or not runData then
  return
 end

 if runData.isOwnKey then
  row:SetBackdropBorderColor(0.25, 0.95, 0.35, 1)
  return
 end

 if runData.hasPartyKey then
  row:SetBackdropBorderColor(0.95, 0.78, 0.18, 1)
 end
end

local function ApplyMythicRowStyle(row, runData)
 if not row or not runData then
  return
 end

 local scoreColor = GetScoreColor(runData.score)
 scoreColor = scoreColor or HIGHLIGHT_FONT_COLOR

 row.runData = runData
 row.icon:SetTexture(runData.texture or 134400)
 row.name:SetText(runData.name or L.DUNGEON)
 row.level:SetText(FormatMythicLevel(runData.level, runData.finishedSuccess))
 row.score:SetText(FormatMythicScore(runData.score))
 row.score:SetTextColor(scoreColor.r or 1, scoreColor.g or 1, scoreColor.b or 1)

 if (runData.level or 0) <= 0 then
  row:SetBackdropColor(0.08, 0.08, 0.08, 0.92)
  row:SetBackdropBorderColor(0.21, 0.17, 0.11, 1)
  row.name:SetTextColor(0.70, 0.70, 0.70)
  row.level:SetTextColor(0.62, 0.62, 0.62)
 elseif runData.finishedSuccess then
  row:SetBackdropColor(0.09, 0.16, 0.10, 0.92)
  row:SetBackdropBorderColor(0.28, 0.55, 0.31, 1)
  row.name:SetTextColor(0.90, 1.00, 0.90)
  row.level:SetTextColor(0.65, 1.00, 0.65)
 else
  row:SetBackdropColor(0.16, 0.10, 0.09, 0.92)
  row:SetBackdropBorderColor(0.55, 0.34, 0.24, 1)
  row.name:SetTextColor(1.00, 0.91, 0.85)
  row.level:SetTextColor(1.00, 0.70, 0.55)
 end

 ApplyMythicKeyOutline(row, runData)
end

function MRTE_UpdateMythicPanel()
 if not MRTE_MythicPanel or not MRTE_MythicPanel.rows then
  return
 end

 local liveData = GetCurrentSeasonDungeonRows()
 local data = GetDisplayMythicData(liveData)
 local totalScore = tonumber(data.totalScore) or 0
 local totalColor = GetScoreColor(totalScore, true)
 totalColor = totalColor or HIGHLIGHT_FONT_COLOR

 if MRTE_UpdateCurrentKeysPanel then
  MRTE_UpdateCurrentKeysPanel()
 end

 MRTE_MythicPanel.totalScore:SetText(FormatMythicScore(totalScore))
 MRTE_MythicPanel.totalScore:SetTextColor(totalColor.r or 1, totalColor.g or 1, totalColor.b or 1)
 MRTE_MythicPanel.progressText:SetText(MRTE_T("MYTHIC_DUNGEONS_PROGRESS", data.completedDungeons or 0, data.trackedDungeons or 0))
 MRTE_MythicPanel.logsText:SetText(MRTE_T("MYTHIC_RUNS_LOGGED", tonumber(data.logsCount) or 0))

 if #data.rows == 0 then
  MRTE_MythicPanel.emptyText:SetText(L.NO_MYTHIC_SEASON_DATA)
  MRTE_MythicPanel.emptyText:Show()

  for _, row in ipairs(MRTE_MythicPanel.rows) do
   row:Hide()
  end

  return
 end

 MRTE_MythicPanel.emptyText:Hide()

 for index, row in ipairs(MRTE_MythicPanel.rows) do
  local runData = data.rows[index]

  if runData then
   ApplyMythicRowStyle(row, runData)
   row:Show()
  else
   row.runData = nil
   row:Hide()
  end
 end
end

local mythicEvents = CreateFrame("Frame")
mythicEvents:RegisterEvent("PLAYER_ENTERING_WORLD")
mythicEvents:RegisterEvent("CHALLENGE_MODE_MAPS_UPDATE")
mythicEvents:RegisterEvent("CHALLENGE_MODE_COMPLETED")
mythicEvents:SetScript("OnEvent", function(_, event)
 if event == "CHALLENGE_MODE_COMPLETED" then
  MRTE_GlobalDB.logs = MRTE_GlobalDB.logs or {}

  local mapID = C_ChallengeMode and C_ChallengeMode.GetActiveChallengeMapID and C_ChallengeMode.GetActiveChallengeMapID()
  local level = C_ChallengeMode and C_ChallengeMode.GetActiveKeystoneInfo and select(1, C_ChallengeMode.GetActiveKeystoneInfo())

  if mapID and level then
   table.insert(MRTE_GlobalDB.logs, {
    map = mapID,
    level = level,
   })

   if MRTE_AppendCharacterLog then
    MRTE_AppendCharacterLog({
     map = mapID,
     level = level,
    })
   end

   print(MRTE_T("MYTHIC_LOGGED_DEBUG", mapID, level))
  end

  if MRTE_UpdateVault then
   MRTE_UpdateVault()
  end
 end

 if MRTE_UpdateMythicPanel then
  MRTE_UpdateMythicPanel()
 end
end)
