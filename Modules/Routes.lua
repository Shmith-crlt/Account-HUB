local L = MRTE_L

local UPDATE_INTERVAL = 1.5
local NEUTRAL_BORDER = { 0.24, 0.19, 0.11, 1 }
local DOCKED_POINT = { point = "BOTTOMRIGHT", relativePoint = "BOTTOMRIGHT", x = -20, y = 64 }
local DETACHED_DEFAULT_POINT = { point = "CENTER", relativePoint = "CENTER", x = 420, y = -30 }

local nextPullDriver = CreateFrame("Frame")
local nextPullElapsed = 0
local lastSignature

local function PrintHubMessage(text)
 print((L.ADDON_TITLE or "Account-HUB") .. ": " .. text)
end

local function GetSortedNumericKeys(tbl)
 local keys = {}

 for key in pairs(tbl or {}) do
  if type(key) == "number" then
   keys[#keys + 1] = key
  end
 end

 table.sort(keys)

 return keys
end

local function ParseHexColor(hex)
 if type(hex) ~= "string" then
  return 0.70, 0.56, 0.18
 end

 hex = hex:gsub("#", "")

 if #hex == 8 then
  hex = hex:sub(3)
 end

 if #hex ~= 6 then
  return 0.70, 0.56, 0.18
 end

 local r = tonumber(hex:sub(1, 2), 16) or 179
 local g = tonumber(hex:sub(3, 4), 16) or 143
 local b = tonumber(hex:sub(5, 6), 16) or 46

 return r / 255, g / 255, b / 255
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

local function ClampIndex(value, minValue, maxValue)
 value = tonumber(value) or minValue
 if value < minValue then
  return minValue
 end

 if value > maxValue then
  return maxValue
 end

 return value
end

local function UpdateSummaryText(text)
 if MRTE_NextPullPanelSummaryText then
  MRTE_NextPullPanelSummaryText:SetText(text or "")
 end
end

local function UpdateStatusText(text)
 if MRTE_NextPullPanelStatusText then
  MRTE_NextPullPanelStatusText:SetText(text or "")
 end
end

local function ResetCardBorder(card)
 if card and card.SetBackdropBorderColor then
  card:SetBackdropBorderColor(NEUTRAL_BORDER[1], NEUTRAL_BORDER[2], NEUTRAL_BORDER[3], NEUTRAL_BORDER[4])
 end
end

local function ClearCard(card, titleText, detailText)
 if not card then
  return
 end

 ResetCardBorder(card)
 card.title:SetText(titleText or "")
 card.number:SetText("")
 card.detail:SetText(detailText or "")
 card.enemies:SetText("")
 card.pullData = nil
 card.totalPulls = nil
 card.totalCount = nil
end

local function GetRouteContext()
 if type(MDT) ~= "table" or type(MDT.GetDB) ~= "function" then
  return nil, L.OVERLAY_MDT_NOT_LOADED
 end

 local db = MDT:GetDB()
 if not db or not db.presets then
  return nil, L.OVERLAY_MDT_DATA_NOT_READY
 end

 local dungeonIdx
 local activeChallengeMapID = C_ChallengeMode and C_ChallengeMode.IsChallengeModeActive and C_ChallengeMode.IsChallengeModeActive()
   and C_ChallengeMode.GetActiveChallengeMapID and C_ChallengeMode.GetActiveChallengeMapID()

 if activeChallengeMapID and db.presets[activeChallengeMapID] and MDT.mapInfo and MDT.mapInfo[activeChallengeMapID] then
  dungeonIdx = activeChallengeMapID
 end

 if not dungeonIdx then
  local uiMapID = C_Map and C_Map.GetBestMapForUnit and C_Map.GetBestMapForUnit("player")
  dungeonIdx = uiMapID and MDT.zoneIdToDungeonIdx and MDT.zoneIdToDungeonIdx[uiMapID]
 end

 if not dungeonIdx and db.currentDungeonIdx and db.presets[db.currentDungeonIdx] and MDT.mapInfo and MDT.mapInfo[db.currentDungeonIdx] then
  dungeonIdx = db.currentDungeonIdx
 end

 if not dungeonIdx then
  return nil, L.NEXT_PULL_NO_DUNGEON
 end

 local presetIndex = db.currentPreset and db.currentPreset[dungeonIdx] or 1
 local presetList = db.presets[dungeonIdx]
 local preset = presetList and presetList[presetIndex]

 if not preset and presetList then
  preset = presetList[1]
  presetIndex = 1
 end

 if not preset or not preset.value then
  return nil, L.OVERLAY_NO_PRESET
 end

 local dungeonName = (MDT.GetDungeonName and MDT:GetDungeonName(dungeonIdx))
  or (MDT.mapInfo and MDT.mapInfo[dungeonIdx] and MDT.mapInfo[dungeonIdx].englishName)
  or (L.DUNGEON .. " " .. dungeonIdx)

 return {
  dungeonIdx = dungeonIdx,
  dungeonName = dungeonName,
  preset = preset,
  presetIndex = presetIndex,
  presetUID = preset.uid,
  presetName = preset.text or (L.CURRENT .. " " .. presetIndex),
  selectedPull = tonumber(preset.value.currentPull) or 1,
  totalCount = MDT.dungeonTotalCount and MDT.dungeonTotalCount[dungeonIdx] and tonumber(MDT.dungeonTotalCount[dungeonIdx].normal) or nil,
  totalPulls = type(preset.value.pulls) == "table" and #preset.value.pulls or 0,
 }
end

local function GetNextPullContextKey(context)
 return table.concat({
  tostring(context.dungeonIdx),
  tostring(context.presetIndex),
  tostring(context.presetUID or context.presetName or ""),
 }, ":")
end

local function BuildEnemySummary(enemyCounts)
 local enemies = {}

 for name, count in pairs(enemyCounts or {}) do
  enemies[#enemies + 1] = {
   name = name,
   count = tonumber(count) or 0,
  }
 end

 table.sort(enemies, function(left, right)
  if left.count == right.count then
   return left.name < right.name
  end

  return left.count > right.count
 end)

 local summaryParts = {}
 local tooltipLines = {}

 for index, enemy in ipairs(enemies) do
  local label = enemy.count > 1 and (enemy.count .. "x " .. enemy.name) or enemy.name
  tooltipLines[#tooltipLines + 1] = label

  if index <= 3 then
   summaryParts[#summaryParts + 1] = label
  end
 end

 if #enemies > 3 then
  summaryParts[#summaryParts + 1] = MRTE_T("NEXT_PULL_MORE", #enemies - 3)
 end

 return table.concat(summaryParts, ", "), tooltipLines
end

local function GetDominantFloor(floorCounts)
 local dominantFloor
 local dominantCount = 0
 local floorTotal = 0

 for floor, count in pairs(floorCounts or {}) do
  floorTotal = floorTotal + count

  if count > dominantCount then
   dominantFloor = floor
   dominantCount = count
  end
 end

 if dominantFloor and dominantCount == floorTotal then
  return dominantFloor
 end

 return nil
end

local function BuildPullEntries(context, signatureParts)
 local pulls = context.preset and context.preset.value and context.preset.value.pulls
 local enemies = MDT.dungeonEnemies and MDT.dungeonEnemies[context.dungeonIdx]
 if type(pulls) ~= "table" or type(enemies) ~= "table" then
  return nil
 end

 local entries = {}
 local cumulativeCount = 0

 for pullIndex, pull in ipairs(pulls) do
  local entry = {
   sourceIndex = pullIndex,
   color = pull.color,
  }
  local enemyCounts = {}
  local floorCounts = {}
  local enemyKeys = GetSortedNumericKeys(pull)

  signatureParts[#signatureParts + 1] = "p" .. pullIndex .. ":" .. (pull.color or "")

  for _, enemyIdx in ipairs(enemyKeys) do
   local clones = pull[enemyIdx]
   local enemy = enemies[enemyIdx]

   if enemy and type(enemy.clones) == "table" and type(clones) == "table" then
    for _, cloneIdx in ipairs(clones) do
     signatureParts[#signatureParts + 1] = enemyIdx .. "-" .. cloneIdx

     local clone = enemy.clones[cloneIdx]
     if clone then
      entry.count = (tonumber(entry.count) or 0) + (tonumber(enemy.count) or 0)
      enemyCounts[enemy.name or (L.UNKNOWN .. " " .. enemyIdx)] = (enemyCounts[enemy.name or (L.UNKNOWN .. " " .. enemyIdx)] or 0) + 1

      local sublevel = tonumber(clone.sublevel) or 1
      floorCounts[sublevel] = (floorCounts[sublevel] or 0) + 1
     end
    end
   end
  end

  if (tonumber(entry.count) or 0) > 0 then
   cumulativeCount = cumulativeCount + entry.count
   entry.cumulativeCount = cumulativeCount
   entry.floor = GetDominantFloor(floorCounts)
   entry.enemySummary, entry.enemyLines = BuildEnemySummary(enemyCounts)
   entries[#entries + 1] = entry
  end
 end

 return entries
end

local function GetScenarioCriteriaInfo(index, getCriteriaInfo)
 local info = getCriteriaInfo(index)
 if type(info) == "table" then
  return info
 end

 local description, criteriaType, completed, quantityString, _, _, _, _, criteriaID, assetID, quantity, totalQuantity, flags = getCriteriaInfo(index)
 return {
  description = description,
  criteriaType = criteriaType,
  completed = completed,
  quantityString = quantityString,
  criteriaID = criteriaID,
  assetID = assetID,
  quantity = quantity,
  totalQuantity = totalQuantity,
  flags = flags,
 }
end

local function GetLiveProgressCount(context)
 if not (C_ChallengeMode and C_ChallengeMode.IsChallengeModeActive and C_ChallengeMode.IsChallengeModeActive()) then
  return nil, nil
 end

 -- MDT uses its own dungeon indices, which do not match Blizzard's challenge map IDs.
 -- If a challenge mode is active, trust the current scenario progress and the route context we already resolved from MDT/player zone.

 if not (C_Scenario and C_Scenario.GetStepInfo) then
  return nil, nil
 end

 local getCriteriaInfo = (C_ScenarioInfo and C_ScenarioInfo.GetCriteriaInfo) or (C_Scenario and C_Scenario.GetCriteriaInfo)
 if type(getCriteriaInfo) ~= "function" then
  return nil, nil
 end

 local _, _, numCriteria = C_Scenario.GetStepInfo()
 if not numCriteria or numCriteria < 1 then
  return nil, nil
 end

 local fallbackInfo
 local progressInfo

 for index = 1, numCriteria do
  local criteriaInfo = GetScenarioCriteriaInfo(index, getCriteriaInfo)
  if criteriaInfo then
   if index == numCriteria then
    fallbackInfo = criteriaInfo
   end

   if criteriaInfo.isWeightedProgress and tonumber(criteriaInfo.totalQuantity) and tonumber(criteriaInfo.totalQuantity) > 0 then
    progressInfo = criteriaInfo
    break
   end
  end
 end

 progressInfo = progressInfo or fallbackInfo
 if not progressInfo then
  return nil, nil
 end

 local totalQuantity = tonumber(progressInfo.totalQuantity) or tonumber(context.totalCount)
 local quantityString = type(progressInfo.quantityString) == "string" and progressInfo.quantityString or nil
 local stringQuantity = quantityString and tonumber(quantityString:match("(%d+)") ) or nil

 if stringQuantity and totalQuantity and totalQuantity > 0 then
  return math.min(stringQuantity, totalQuantity), totalQuantity
 end

 local quantity = tonumber(progressInfo.quantity)
 if quantity and totalQuantity and totalQuantity > 0 then
  return math.min((quantity * totalQuantity) / 100, totalQuantity), totalQuantity
 end

 return nil, totalQuantity
end

local function SelectVisiblePulls(context, entries)
 local progressCount, liveTotalCount = GetLiveProgressCount(context)
 local sourceLabel = L.NEXT_PULL_SOURCE_MDT
 local primaryIndex

 if liveTotalCount and liveTotalCount > 0 then
  context.totalCount = liveTotalCount
 end

 if progressCount then
  sourceLabel = L.NEXT_PULL_SOURCE_LIVE

  for index, entry in ipairs(entries) do
   if (tonumber(entry.cumulativeCount) or 0) > (progressCount + 0.05) then
    primaryIndex = index
    break
   end
  end

  if not primaryIndex then
   primaryIndex = #entries + 1
  end
 end

 if not primaryIndex then
  local selectedPull = tonumber(context.selectedPull) or 1
  local fallbackIndex = 1

  for index, entry in ipairs(entries) do
   fallbackIndex = index
   if entry.sourceIndex >= selectedPull then
    primaryIndex = index
    break
   end
  end

  primaryIndex = primaryIndex or fallbackIndex
 end

 return primaryIndex or 1, sourceLabel, progressCount
end

local function ApplyCard(card, titleText, pullData, context)
 if not card then
  return
 end

 if not pullData then
  ClearCard(card, titleText, titleText == L.NEXT_PULL_CURRENT and L.NEXT_PULL_ROUTE_COMPLETE or L.NEXT_PULL_NO_FOLLOWUP)
  return
 end

 local r, g, b = ParseHexColor(pullData.color)
 card:SetBackdropBorderColor(r, g, b, 1)
 card.title:SetText(titleText)

 local numberText = MRTE_T("NEXT_PULL_PULL_NUMBER", pullData.sourceIndex, context.totalPulls)
 if pullData.floor and pullData.floor > 1 then
  numberText = numberText .. " - " .. MRTE_T("NEXT_PULL_FLOOR", pullData.floor)
 end

 card.number:SetText(numberText)
 card.detail:SetText(MRTE_T(
  "NEXT_PULL_CARD_DETAIL",
  FormatCount(pullData.count),
  FormatPercent(pullData.count, context.totalCount),
  FormatCount(pullData.cumulativeCount),
  FormatPercent(pullData.cumulativeCount, context.totalCount)
 ))
 card.enemies:SetText(pullData.enemySummary or L.NEXT_PULL_NO_ENEMIES)
 card.pullData = pullData
 card.totalPulls = context.totalPulls
 card.totalCount = context.totalCount
end

function MRTE_ShowNextPullTooltip(frame)
 local pullData = frame and frame.pullData
 if not pullData then
  return
 end

 GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
 GameTooltip:AddLine(frame.title:GetText() or L.PANEL_MDT_OVERLAY, 1.0, 0.82, 0.1)
 GameTooltip:AddLine(MRTE_T("NEXT_PULL_PULL_NUMBER", pullData.sourceIndex, frame.totalPulls or pullData.sourceIndex), 0.90, 0.90, 0.90)

 if pullData.floor and pullData.floor > 1 then
  GameTooltip:AddLine(MRTE_T("NEXT_PULL_FLOOR", pullData.floor), 0.75, 0.75, 0.75)
 end

 GameTooltip:AddLine(" ")
 GameTooltip:AddDoubleLine(L.NEXT_PULL_PULL_LABEL, FormatCount(pullData.count) .. " | " .. FormatPercent(pullData.count, frame.totalCount), 0.82, 0.82, 0.82, 1, 1, 1)
 GameTooltip:AddDoubleLine(L.NEXT_PULL_ROUTE_LABEL, FormatCount(pullData.cumulativeCount) .. " | " .. FormatPercent(pullData.cumulativeCount, frame.totalCount), 0.82, 0.82, 0.82, 1, 1, 1)

 if pullData.enemyLines and pullData.enemyLines[1] then
  GameTooltip:AddLine(" ")
  for _, line in ipairs(pullData.enemyLines) do
   GameTooltip:AddLine(line, 0.93, 0.93, 0.93, true)
  end
 end

 if frame.role == "current" then
  GameTooltip:AddLine(" ")
  GameTooltip:AddLine(L.NEXT_PULL_CLICK_DONE, 0.62, 0.86, 0.10, true)
  GameTooltip:AddLine(L.NEXT_PULL_CLICK_BACK, 0.95, 0.82, 0.30, true)
  GameTooltip:AddLine(L.NEXT_PULL_CLICK_MDT, 0.75, 0.75, 0.75, true)
 end

 GameTooltip:Show()
end

local function GetNextPullSettings()
 MRTE_GlobalDB = MRTE_GlobalDB or {}
 MRTE_GlobalDB.mdtOverlay = MRTE_GlobalDB.mdtOverlay or {}

 return MRTE_GlobalDB.mdtOverlay
end

local function GetNextPullManualTable()
 local settings = GetNextPullSettings()
 settings.manualPulls = settings.manualPulls or {}

 return settings.manualPulls
end

local function GetNextPullManualIndex(contextKey)
 if not contextKey or contextKey == "" then
  return nil
 end

 return tonumber(GetNextPullManualTable()[contextKey])
end

local function SetNextPullManualIndex(contextKey, pullIndex)
 if not contextKey or contextKey == "" then
  return
 end

 local manualTable = GetNextPullManualTable()

 if pullIndex == nil then
  manualTable[contextKey] = nil
 else
  manualTable[contextKey] = tonumber(pullIndex)
 end
end

function MRTE_IsNextPullDetached()
 return not not GetNextPullSettings().detached
end

local function SaveNextPullPanelPosition()
 local panel = MRTE_NextPullPanel
 if not panel or not MRTE_IsNextPullDetached() then
  return
 end

 local point, _, relativePoint, x, y = panel:GetPoint(1)
 if not point then
  return
 end

 local settings = GetNextPullSettings()
 settings.position = {
  point = point,
  relativePoint = relativePoint or point,
  x = x or 0,
  y = y or 0,
 }
end

local function ApplyDetachedPoint(panel, keepCurrentPosition)
 local anchorPoint

 if keepCurrentPosition then
  local centerX, centerY = panel:GetCenter()
  if centerX and centerY then
   panel:ClearAllPoints()
   panel:SetPoint("CENTER", UIParent, "BOTTOMLEFT", centerX, centerY)
   return
  end
 end

 local settings = GetNextPullSettings()
 anchorPoint = settings.position or DETACHED_DEFAULT_POINT

 panel:ClearAllPoints()
 panel:SetPoint(
  anchorPoint.point or DETACHED_DEFAULT_POINT.point,
  UIParent,
  anchorPoint.relativePoint or DETACHED_DEFAULT_POINT.relativePoint,
  anchorPoint.x or DETACHED_DEFAULT_POINT.x,
  anchorPoint.y or DETACHED_DEFAULT_POINT.y
 )
end

function MRTE_UpdateNextPullToggleButton()
 if MRTE_NextPullPanel and MRTE_NextPullPanel.toggleButton then
  MRTE_NextPullPanel.toggleButton:SetText(MRTE_IsNextPullDetached() and L.NEXT_PULL_DOCK or L.NEXT_PULL_DETACH)
 end
end

function MRTE_ResetNextPullManualState(verbose)
 local state = MRTE_NextPullPanelState
 if state and state.contextKey then
  SetNextPullManualIndex(state.contextKey, nil)
 end

 lastSignature = nil
 MRTE_RefreshNextPullPanel(true, false)
end

function MRTE_HandleNextPullCardClick(frame, button)
 if not frame or frame.role ~= "current" or not (button == "LeftButton" or button == "RightButton") then
  return false
 end

 local state = MRTE_NextPullPanelState
 if not state or not state.contextKey then
  return false
 end

 local maxIndex = math.max(1, tonumber(state.entryCount) or 1) + 1
 local currentIndex = ClampIndex(state.currentIndex or state.autoIndex or 1, 1, maxIndex)

 if button == "LeftButton" then
  SetNextPullManualIndex(state.contextKey, ClampIndex(currentIndex + 1, 1, maxIndex))
 elseif button == "RightButton" then
  SetNextPullManualIndex(state.contextKey, ClampIndex(currentIndex - 1, 1, maxIndex))
 end

 lastSignature = nil
 MRTE_RefreshNextPullPanel(true, false)
 return true
end

function MRTE_ApplyNextPullPanelMode(keepCurrentPosition)
 local panel = MRTE_NextPullPanel
 if not panel then
  return
 end

 local detached = MRTE_IsNextPullDetached()

 if panel.dragHandle and not panel.dragHandle.mrteConfigured then
  panel.dragHandle.mrteConfigured = true
  panel.dragHandle:RegisterForDrag("LeftButton")
  panel.dragHandle:SetScript("OnDragStart", function()
   if MRTE_IsNextPullDetached() then
    panel:StartMoving()
   end
  end)
  panel.dragHandle:SetScript("OnDragStop", function()
   panel:StopMovingOrSizing()
   SaveNextPullPanelPosition()
  end)
 end

 if detached then
  panel:SetParent(UIParent)
  panel:SetFrameStrata("DIALOG")
  panel:SetMovable(true)
  panel:SetClampedToScreen(true)

  if panel.dragHandle then
   panel.dragHandle:EnableMouse(true)
  end

  ApplyDetachedPoint(panel, keepCurrentPosition)
  panel:Show()
 else
  panel:SetParent(MRTE_MainFrame or UIParent)
  panel:SetFrameStrata((MRTE_MainFrame and MRTE_MainFrame:GetFrameStrata()) or "DIALOG")
  panel:SetMovable(false)

  if panel.dragHandle then
   panel.dragHandle:EnableMouse(false)
  end

 panel:ClearAllPoints()
 panel:SetPoint(DOCKED_POINT.point, panel:GetParent(), DOCKED_POINT.relativePoint, DOCKED_POINT.x, DOCKED_POINT.y)
  panel:Show()
 end

 panel.mrteDetached = detached
 MRTE_UpdateNextPullToggleButton()
end

function MRTE_SetNextPullDetached(detached, verbose)
 local settings = GetNextPullSettings()
 settings.detached = not not detached
 lastSignature = nil

 if not detached and MRTE_MainFrame and not MRTE_MainFrame:IsShown() then
  MRTE_MainFrame:Show()
 end

 MRTE_ApplyNextPullPanelMode(detached)
 MRTE_RefreshNextPullPanel(true, false)

 if verbose then
  PrintHubMessage(detached and L.NEXT_PULL_DETACHED or L.NEXT_PULL_DOCKED)
 end
end

function MRTE_ToggleNextPullDetached()
 MRTE_SetNextPullDetached(not MRTE_IsNextPullDetached(), true)
end

function MRTE_RefreshNextPullPanel(force, verbose)
 if MRTE_NextPullPanel and MRTE_NextPullPanel.mrteDetached ~= MRTE_IsNextPullDetached() then
  MRTE_ApplyNextPullPanelMode(false)
 end

 if not MRTE_NextPullPanel then
  return false
 end

 local context, reason = GetRouteContext()
 if not context then
  lastSignature = nil
  MRTE_NextPullPanelState = nil
  UpdateSummaryText(L.PANEL_MDT_OVERLAY)
  UpdateStatusText(reason)
  ClearCard(MRTE_NextPullCurrentCard, L.NEXT_PULL_CURRENT, reason)
  ClearCard(MRTE_NextPullNextCard, L.NEXT_PULL_NEXT, "")

  if verbose then
   PrintHubMessage(reason)
  end

  return false
 end

 local signatureParts = {
  tostring(context.dungeonIdx),
  tostring(context.presetIndex),
  tostring(context.selectedPull),
  tostring(context.presetName),
  tostring(context.totalPulls),
 }

 local entries = BuildPullEntries(context, signatureParts)
 if not entries or not entries[1] then
  lastSignature = nil
  MRTE_NextPullPanelState = nil
  UpdateSummaryText(context.dungeonName)
  UpdateStatusText(L.OVERLAY_NO_ROUTE_FOUND)
  ClearCard(MRTE_NextPullCurrentCard, L.NEXT_PULL_CURRENT, L.OVERLAY_NO_ROUTE_FOUND)
  ClearCard(MRTE_NextPullNextCard, L.NEXT_PULL_NEXT, "")

  if verbose then
   PrintHubMessage(L.OVERLAY_NO_ROUTE_FOUND)
  end

  return false
 end

 local contextKey = GetNextPullContextKey(context)
 local autoIndex, sourceLabel, progressCount = SelectVisiblePulls(context, entries)
 local entryCount = #entries
 local maxIndex = entryCount + 1
 local storedManualIndex = GetNextPullManualIndex(contextKey)

 if storedManualIndex and progressCount and storedManualIndex < autoIndex then
  SetNextPullManualIndex(contextKey, nil)
  storedManualIndex = nil
 end

 local manualIndex = ClampIndex(storedManualIndex or autoIndex, 1, maxIndex)
 local currentIndex = manualIndex
 local usingManual = storedManualIndex ~= nil
 local primaryPull = entries[currentIndex]
 local nextPull = entries[currentIndex + 1]

 if usingManual then
  sourceLabel = L.NEXT_PULL_SOURCE_MANUAL
 end

 local signatureProgress = progressCount and string.format("%.2f", progressCount) or "none"
 signatureParts[#signatureParts + 1] = signatureProgress
 signatureParts[#signatureParts + 1] = tostring(manualIndex)
 local signature = table.concat(signatureParts, "|")

 if not force and signature == lastSignature then
  return true
 end

 lastSignature = signature

 UpdateSummaryText(context.dungeonName)

 MRTE_NextPullPanelState = {
  contextKey = contextKey,
  autoIndex = autoIndex,
  currentIndex = currentIndex,
  manualIndex = usingManual and manualIndex or nil,
  entryCount = entryCount,
 }

 if currentIndex > entryCount then
  UpdateStatusText(MRTE_T("NEXT_PULL_SELECTED_SUMMARY", sourceLabel, L.NEXT_PULL_ROUTE_COMPLETE))
 elseif progressCount and not usingManual then
  UpdateStatusText(MRTE_T("NEXT_PULL_PROGRESS_SUMMARY", sourceLabel, FormatCount(progressCount), FormatPercent(progressCount, context.totalCount)))
 else
  local displayPull = primaryPull and primaryPull.sourceIndex or math.min(math.max(context.selectedPull, 1), math.max(context.totalPulls, 1))
  UpdateStatusText(MRTE_T("NEXT_PULL_SELECTED_SUMMARY", sourceLabel, MRTE_T("NEXT_PULL_PULL_NUMBER", displayPull, context.totalPulls)))
 end

 ApplyCard(MRTE_NextPullCurrentCard, L.NEXT_PULL_CURRENT, primaryPull, context)
 ApplyCard(MRTE_NextPullNextCard, L.NEXT_PULL_NEXT, nextPull, context)
 if MRTE_NextPullCurrentCard then
  MRTE_NextPullCurrentCard.role = "current"
 end
 if MRTE_NextPullNextCard then
  MRTE_NextPullNextCard.role = "next"
 end

 if verbose then
  local statusText = MRTE_NextPullPanelStatusText and MRTE_NextPullPanelStatusText:GetText() or context.dungeonName
  PrintHubMessage(statusText)
 end

 return true
end

MRTE_IsNextPullEnabled = MRTE_IsNextPullDetached
MRTE_SetNextPullEnabled = MRTE_SetNextPullDetached
MRTE_ToggleNextPull = MRTE_ToggleNextPullDetached

MRTE_IsMDTOverlayEnabled = MRTE_IsNextPullDetached
MRTE_SetMDTOverlayEnabled = MRTE_SetNextPullDetached
MRTE_ToggleMDTOverlay = MRTE_ToggleNextPullDetached
MRTE_RefreshMDTOverlay = MRTE_RefreshNextPullPanel

if MRTE_NextPullPanel then
 MRTE_ApplyNextPullPanelMode(false)
end

nextPullDriver:RegisterEvent("PLAYER_ENTERING_WORLD")
nextPullDriver:RegisterEvent("ZONE_CHANGED")
nextPullDriver:RegisterEvent("ZONE_CHANGED_INDOORS")
nextPullDriver:RegisterEvent("ZONE_CHANGED_NEW_AREA")
nextPullDriver:RegisterEvent("CHALLENGE_MODE_START")
nextPullDriver:RegisterEvent("CHALLENGE_MODE_COMPLETED")
nextPullDriver:RegisterEvent("CHALLENGE_MODE_RESET")
nextPullDriver:RegisterEvent("SCENARIO_UPDATE")
nextPullDriver:RegisterEvent("SCENARIO_CRITERIA_UPDATE")

nextPullDriver:SetScript("OnEvent", function()
 nextPullElapsed = UPDATE_INTERVAL
 MRTE_RefreshNextPullPanel(true, false)
end)

nextPullDriver:SetScript("OnUpdate", function(_, elapsed)
 if not MRTE_NextPullPanel then
  return
 end

 nextPullElapsed = nextPullElapsed + elapsed
 if nextPullElapsed < UPDATE_INTERVAL then
  return
 end

 nextPullElapsed = 0
 MRTE_RefreshNextPullPanel(false, false)
end)

