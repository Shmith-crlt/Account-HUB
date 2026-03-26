local L = MRTE_L

local SEASON_CURRENCIES = {
 [13] = {
  { id = 2914, label = "Weathered", useTotalEarnedForCap = true },
  { id = 2915, label = "Carved", useTotalEarnedForCap = true },
  { id = 2916, label = "Runed", useTotalEarnedForCap = true },
  { id = 2917, label = "Gilded", useTotalEarnedForCap = true },
  { id = 3008, label = "Valorstones", useTotalEarnedForCap = false },
  { id = 3028, label = "Coffer Keys", useTotalEarnedForCap = false },
 },
 [14] = {
  { id = 3107, label = "Weathered", useTotalEarnedForCap = true },
  { id = 3108, label = "Carved", useTotalEarnedForCap = true },
  { id = 3109, label = "Runed", useTotalEarnedForCap = true },
  { id = 3110, label = "Gilded", useTotalEarnedForCap = true },
  { id = 3008, label = "Valorstones", useTotalEarnedForCap = false },
  { id = 3028, label = "Coffer Keys", useTotalEarnedForCap = false },
 },
 [15] = {
  { id = 3284, label = "Weathered", useTotalEarnedForCap = true },
  { id = 3286, label = "Carved", useTotalEarnedForCap = true },
  { id = 3288, label = "Runed", useTotalEarnedForCap = true },
  { id = 3290, label = "Gilded", useTotalEarnedForCap = true },
  { id = 3008, label = "Valorstones", useTotalEarnedForCap = false },
  { id = 3028, label = "Coffer Keys", useTotalEarnedForCap = false },
 },
 [17] = {
  { id = 3383, label = "Adventurer", useTotalEarnedForCap = true },
  { id = 3341, label = "Veteran", useTotalEarnedForCap = true },
  { id = 3343, label = "Champion", useTotalEarnedForCap = true },
  { id = 3345, label = "Hero", useTotalEarnedForCap = true },
  { id = 3347, label = "Myth", useTotalEarnedForCap = true },
  { id = 3212, label = "Spark Dust", useTotalEarnedForCap = true },
  { id = 3378, label = "Manaflux", useTotalEarnedForCap = true },
  { id = 3310, label = "Key Shards", useTotalEarnedForCap = false },
  { id = 3028, label = "Coffer Keys", useTotalEarnedForCap = false },
 },
}

local function FormatCurrencyValue(value)
 value = tonumber(value) or 0
 return BreakUpLargeNumbers and BreakUpLargeNumbers(value) or tostring(value)
end

local function GetCurrentSeasonCurrencyList()
 local seasonID = C_MythicPlus and C_MythicPlus.GetCurrentSeason and C_MythicPlus.GetCurrentSeason() or 0
 return seasonID, SEASON_CURRENCIES[seasonID] or {}
end

local function ResolveCurrencyCap(entry, info, quantity, totalEarned)
 local maxQuantity = tonumber(info.maxQuantity) or 0
 local maxWeeklyQuantity = tonumber(info.maxWeeklyQuantity) or 0
 local hasWeeklyProgress = info.quantityEarnedThisWeek ~= nil
 local quantityEarnedThisWeek = tonumber(info.quantityEarnedThisWeek) or 0
 local useTotalEarnedForCap = entry.useTotalEarnedForCap or info.useTotalEarnedForMaxQty or false
 local hasCap = false
 local capProgress = 0
 local capMaximum = 0
 local capType
 local capText = "-"

 if useTotalEarnedForCap and maxQuantity > 0 then
  hasCap = true
  capProgress = totalEarned
  capMaximum = maxQuantity
  capType = "totalEarned"
 elseif maxWeeklyQuantity > 0 then
  hasCap = true
  capProgress = hasWeeklyProgress and quantityEarnedThisWeek or quantity
  capMaximum = maxWeeklyQuantity
  capType = "weekly"
 elseif maxQuantity > 0 then
  hasCap = true
  capProgress = quantity
  capMaximum = maxQuantity
  capType = "quantity"
 end

 if hasCap then
  capText = FormatCurrencyValue(capProgress) .. "/" .. FormatCurrencyValue(capMaximum)
 elseif quantity > 0 then
  capText = FormatCurrencyValue(quantity)
 end

 return {
  useTotalEarnedForCap = useTotalEarnedForCap,
  maxQuantity = maxQuantity,
  maxWeeklyQuantity = maxWeeklyQuantity,
  quantityEarnedThisWeek = quantityEarnedThisWeek,
  hasCap = hasCap,
  capProgress = capProgress,
  capMaximum = capMaximum,
  capType = capType,
  capText = capText,
 }
end

local function BuildSeasonCurrencyRows()
 local seasonID, currencyList = GetCurrentSeasonCurrencyList()
 local rows = {}

 for _, entry in ipairs(currencyList) do
  local info = C_CurrencyInfo and C_CurrencyInfo.GetCurrencyInfo and C_CurrencyInfo.GetCurrencyInfo(entry.id)
  if info then
   local quantity = tonumber(info.quantity) or 0
   local totalEarned = tonumber(info.totalEarned) or 0
   local capData = ResolveCurrencyCap(entry, info, quantity, totalEarned)

   rows[#rows + 1] = {
    id = entry.id,
    label = entry.label,
    name = info.name or entry.label,
    description = info.description,
    iconFileID = info.iconFileID,
    quantity = quantity,
    totalEarned = totalEarned,
    maxQuantity = capData.maxQuantity,
    maxWeeklyQuantity = capData.maxWeeklyQuantity,
    quantityEarnedThisWeek = capData.quantityEarnedThisWeek,
    hasCap = capData.hasCap,
    capProgress = capData.capProgress,
    capMaximum = capData.capMaximum,
    capType = capData.capType,
    capText = capData.capText,
    seasonID = seasonID,
    useTotalEarnedForCap = capData.useTotalEarnedForCap,
   }
  end
 end

 return seasonID, rows
end

local function BuildLiveSeasonCurrencyData()
 local seasonID, rows = BuildSeasonCurrencyRows()

 return {
  seasonID = seasonID,
  rows = rows,
 }
end

local function GetDisplaySeasonCurrencyData(liveData)
 if MRTE_SaveCharacterSection then
  MRTE_SaveCharacterSection("currencies", liveData)
 end

 if not MRTE_IsViewingCurrentCharacter or MRTE_IsViewingCurrentCharacter() then
  return liveData
 end

 local profile = MRTE_GetSelectedCharacterProfile and MRTE_GetSelectedCharacterProfile()
 if profile and type(profile.currencies) == "table" then
  return profile.currencies
 end

 return {
  seasonID = 0,
  rows = {},
 }
end

function MRTE_ShowSeasonCurrencyTooltip(row)
 local currencyData = row and row.currencyData
 if not currencyData then
  return
 end

 GameTooltip:SetOwner(row, "ANCHOR_LEFT")
 GameTooltip:ClearLines()
 GameTooltip:AddLine(currencyData.name or currencyData.label or L.SEASON_CURRENCY, 1, 1, 1)
 GameTooltip:AddDoubleLine(L.CURRENT, FormatCurrencyValue(currencyData.quantity), 0.82, 0.82, 0.82, 1, 1, 1)

 if currencyData.capType == "totalEarned" or currencyData.capType == "weekly" then
  GameTooltip:AddDoubleLine(
   L.CAP_PROGRESS,
   FormatCurrencyValue(currencyData.capProgress) .. "/" .. FormatCurrencyValue(currencyData.capMaximum),
   0.82,
   0.82,
   0.82,
   1,
   1,
   1
  )
 elseif currencyData.capType == "quantity" then
  GameTooltip:AddDoubleLine(L.CAP, FormatCurrencyValue(currencyData.capMaximum), 0.82, 0.82, 0.82, 1, 1, 1)
 else
  GameTooltip:AddDoubleLine(L.CAP, L.NO_LIMIT, 0.82, 0.82, 0.82, 1, 1, 1)
 end

 if currencyData.description and currencyData.description ~= "" then
  GameTooltip:AddLine(" ")
  GameTooltip:AddLine(currencyData.description, 1, 1, 1, true)
 end

 GameTooltip:Show()
end

local function ApplySeasonCurrencyRowStyle(row, currencyData)
 if not row or not currencyData then
  return
 end

 row.currencyData = currencyData
 row.icon:SetTexture(currencyData.iconFileID or 134400)
 row.name:SetText(currencyData.label or currencyData.name or L.CURRENCY)
 row.owned:SetText(FormatCurrencyValue(currencyData.quantity))
 row.cap:SetText(currencyData.capText or "-")

 if currencyData.hasCap and currencyData.capProgress >= currencyData.capMaximum then
  row:SetBackdropColor(0.18, 0.10, 0.10, 0.92)
  row:SetBackdropBorderColor(0.60, 0.28, 0.28, 1)
  row.name:SetTextColor(1.00, 0.86, 0.86)
  row.owned:SetTextColor(1.00, 0.86, 0.86)
  row.cap:SetTextColor(1.00, 0.70, 0.70)
  return
 end

 if currencyData.quantity > 0 then
  row:SetBackdropColor(0.09, 0.11, 0.15, 0.92)
  row:SetBackdropBorderColor(0.27, 0.34, 0.52, 1)
  row.name:SetTextColor(0.90, 0.94, 1.00)
  row.owned:SetTextColor(1.00, 1.00, 1.00)
  row.cap:SetTextColor(0.84, 0.91, 1.00)
  return
 end

 row:SetBackdropColor(0.08, 0.08, 0.08, 0.92)
 row:SetBackdropBorderColor(0.21, 0.17, 0.11, 1)
 row.name:SetTextColor(0.72, 0.72, 0.72)
 row.owned:SetTextColor(0.72, 0.72, 0.72)
 row.cap:SetTextColor(0.72, 0.72, 0.72)
end

function MRTE_UpdateSeasonCurrencies()
 if not MRTE_SeasonCurrenciesPanel or not MRTE_SeasonCurrenciesPanel.rows then
  return
 end

 local liveData = BuildLiveSeasonCurrencyData()
 local displayData = GetDisplaySeasonCurrencyData(liveData)
 local seasonID = tonumber(displayData.seasonID) or 0
 local rows = type(displayData.rows) == "table" and displayData.rows or {}

 if seasonID and seasonID > 0 then
  MRTE_SeasonCurrenciesPanel.title:SetText(MRTE_T("PANEL_SEASON_CURRENCIES_WITH_SEASON", seasonID))
 else
  MRTE_SeasonCurrenciesPanel.title:SetText(L.PANEL_SEASON_CURRENCIES)
 end

 if #rows == 0 then
  MRTE_SeasonCurrenciesPanel.emptyText:Show()

  for _, row in ipairs(MRTE_SeasonCurrenciesPanel.rows) do
   row.currencyData = nil
   row:Hide()
  end

  return
 end

 MRTE_SeasonCurrenciesPanel.emptyText:Hide()

 for index, row in ipairs(MRTE_SeasonCurrenciesPanel.rows) do
  local currencyData = rows[index]

  if currencyData then
   ApplySeasonCurrencyRowStyle(row, currencyData)
   row:Show()
  else
   row.currencyData = nil
   row:Hide()
  end
 end
end

local currencyEvents = CreateFrame("Frame")
currencyEvents:RegisterEvent("PLAYER_ENTERING_WORLD")
currencyEvents:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
currencyEvents:SetScript("OnEvent", function()
 if MRTE_UpdateSeasonCurrencies then
  MRTE_UpdateSeasonCurrencies()
 end
end)
