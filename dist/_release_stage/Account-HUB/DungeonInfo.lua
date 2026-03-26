local L = MRTE_L

local DUNGEON_ITEM_LEVEL_ROWS = {
 { labelKey = "DIFFICULTY_HEROIC", loot = 230, vault = 243, crestKey = "" },
 { labelKey = "DIFFICULTY_MYTHIC", loot = 246, vault = 256, crestKey = "UPGRADE_CHAMP" },
 { label = "M2", loot = 250, vault = 259, crestKey = "UPGRADE_CHAMP" },
 { label = "M3", loot = 250, vault = 259, crestKey = "UPGRADE_CHAMP" },
 { label = "M4", loot = 253, vault = 263, crestKey = "UPGRADE_HERO" },
 { label = "M5", loot = 256, vault = 263, crestKey = "UPGRADE_HERO" },
 { label = "M6", loot = 259, vault = 266, crestKey = "UPGRADE_HERO" },
 { label = "M7", loot = 259, vault = 269, crestKey = "UPGRADE_HERO" },
 { label = "M8", loot = 263, vault = 269, crestKey = "UPGRADE_HERO" },
 { label = "M9", loot = 263, vault = 269, crestKey = "UPGRADE_MYTH" },
 { label = "M10", loot = 266, vault = 272, crestKey = "UPGRADE_MYTH" },
 { label = "M11", loot = 266, vault = 272, crestKey = "UPGRADE_MYTH" },
 { label = "M12", loot = 266, vault = 272, crestKey = "UPGRADE_MYTH" },
}

local REWARD_BAND_STYLES = {
 heroic = {
  text = "",
  textColor = { 0.62, 0.58, 0.50 },
  background = { 0.08, 0.08, 0.08, 0.94 },
 },
 champ = {
  textKey = "UPGRADE_CHAMP",
  textColor = { 0.86, 0.20, 1.00 },
  background = { 0.12, 0.05, 0.16, 0.94 },
 },
 hero = {
  textKey = "UPGRADE_HERO",
  textColor = { 1.00, 0.63, 0.10 },
  background = { 0.16, 0.09, 0.03, 0.94 },
 },
 myth = {
  textKey = "UPGRADE_MYTH",
  textColor = { 1.00, 0.82, 0.18 },
  background = { 0.18, 0.14, 0.03, 0.94 },
 },
}

local function GetRowLabel(rowData)
 if rowData.labelKey and rowData.labelKey ~= "" then
  return L[rowData.labelKey] or rowData.labelKey
 end

 return rowData.label or ""
end

local function GetCrestLabel(rowData)
 if rowData.crestKey and rowData.crestKey ~= "" then
  return L[rowData.crestKey] or rowData.crestKey
 end

 return ""
end

local function GetItemLevelColor(itemLevel)
 if itemLevel >= 263 then
  return 1.00, 0.82, 0.18
 end

 if itemLevel >= 253 then
  return 1.00, 0.58, 0.10
 end

 if itemLevel >= 246 then
  return 0.86, 0.20, 1.00
 end

 if itemLevel >= 243 then
  return 0.18, 0.80, 1.00
 end

 return 0.35, 0.92, 0.35
end

function MRTE_ShowDungeonItemLevelTooltip(row)
 if not row or not row.data then
  return
 end

 GameTooltip:SetOwner(row, "ANCHOR_RIGHT")
 GameTooltip:SetText(GetRowLabel(row.data), 1, 1, 1)
 GameTooltip:AddLine(L.DUNGEON_LOOT .. ": " .. tostring(row.data.loot), 0.90, 0.82, 0.65)
 GameTooltip:AddLine(L.PANEL_GREAT_VAULT .. ": " .. tostring(row.data.vault), 0.90, 0.82, 0.65)

 local crestLabel = GetCrestLabel(row.data)
 if crestLabel ~= "" then
  GameTooltip:AddLine(L.CREST_REWARD .. ": " .. crestLabel, 0.90, 0.82, 0.65)
 else
  GameTooltip:AddLine(L.NO_CREST_TRACK_FOR_ROW, 0.62, 0.58, 0.50)
 end

 GameTooltip:Show()
end

function MRTE_UpdateDungeonItemLevelPanel()
 local panel = MRTE_DungeonItemLevelPanel

 if not panel or not panel.rows then
  return
 end

 for index, rowData in ipairs(DUNGEON_ITEM_LEVEL_ROWS) do
  local row = panel.rows[index]

  if row then
   local stripeShade = (index % 2 == 0) and 0.10 or 0.07
   row.data = rowData
   row:Show()

   if row.cells and row.cells[1] then
    row.cells[1]:SetBackdropColor(0.02, 0.24, 0.46, 0.94)
   end

   if row.cells and row.cells[2] then
    row.cells[2]:SetBackdropColor(stripeShade, stripeShade, stripeShade, 0.94)
   end

   if row.cells and row.cells[3] then
    row.cells[3]:SetBackdropColor(stripeShade, stripeShade, stripeShade, 0.94)
   end

   row.level:SetText(GetRowLabel(rowData))
   row.level:SetTextColor(1, 1, 1)

   row.loot:SetText(tostring(rowData.loot))
   row.loot:SetTextColor(GetItemLevelColor(rowData.loot))

   row.vault:SetText(tostring(rowData.vault))
   row.vault:SetTextColor(GetItemLevelColor(rowData.vault))
  end
 end

 for key, style in pairs(REWARD_BAND_STYLES) do
  local band = panel.rewardBands and panel.rewardBands[key]

  if band and band.text then
   band:SetBackdropColor(style.background[1], style.background[2], style.background[3], style.background[4])
   band.text:SetText(style.textKey and (L[style.textKey] or style.textKey) or (style.text or ""))
   band.text:SetTextColor(style.textColor[1], style.textColor[2], style.textColor[3])
  end
 end
end
