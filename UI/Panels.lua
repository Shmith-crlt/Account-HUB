local L = MRTE_L

local function CreateVaultCell(parent, width, height)
 local cell = CreateFrame("Frame", nil, parent, "BackdropTemplate")
 cell:SetSize(width, height)
 cell:EnableMouse(true)
 cell:SetBackdrop({
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
 cell:SetBackdropColor(0.05, 0.05, 0.05, 0.95)
 cell:SetBackdropBorderColor(0.23, 0.18, 0.10, 1)

 cell.text = cell:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
 cell.text:SetPoint("CENTER", 0, 1)
 MRTE_SetFont(cell.text, 14, "OUTLINE")
 cell.text:SetTextColor(0.62, 0.58, 0.50)

 cell:SetScript("OnEnter", function(self)
  if MRTE_ShowVaultSlotTooltip then
   MRTE_ShowVaultSlotTooltip(self)
  end
 end)

 cell:SetScript("OnLeave", function()
  GameTooltip_Hide()
 end)

 cell:SetScript("OnMouseUp", function(_, button)
  if button == "LeftButton" and MRTE_OpenGreatVaultUI then
   MRTE_OpenGreatVaultUI()
  end
 end)

 return cell
end

local function CreateMythicDungeonRow(parent)
 local row = CreateFrame("Button", nil, parent, "BackdropTemplate")
 row:SetSize(264, 27)
 row:SetBackdrop({
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
 row:SetBackdropColor(0.08, 0.08, 0.08, 0.92)
 row:SetBackdropBorderColor(0.21, 0.17, 0.11, 1)

 row.icon = row:CreateTexture(nil, "ARTWORK")
 row.icon:SetSize(22, 22)
 row.icon:SetPoint("LEFT", 4, 0)
 row.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
 row.icon:SetTexture(134400)

 row.name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
 row.name:SetPoint("LEFT", row.icon, "RIGHT", 8, 0)
 row.name:SetWidth(130)
 row.name:SetJustifyH("LEFT")
 row.name:SetText(L.DUNGEON)

 row.level = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
 row.level:SetPoint("RIGHT", -58, 0)
 row.level:SetWidth(44)
 row.level:SetJustifyH("RIGHT")
 row.level:SetText("-")

 row.score = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
 row.score:SetPoint("RIGHT", -10, 0)
 row.score:SetWidth(42)
 row.score:SetJustifyH("RIGHT")
 row.score:SetText("0")

 row:SetScript("OnEnter", function(self)
  if MRTE_ShowMythicDungeonTooltip then
   MRTE_ShowMythicDungeonTooltip(self)
  end
 end)

 row:SetScript("OnLeave", function()
  GameTooltip_Hide()
 end)

 row:SetScript("OnClick", function(_, button)
  if button == "LeftButton" and MRTE_OpenMythicPlusUI then
   MRTE_OpenMythicPlusUI()
  end
 end)

 return row
end

local function CreateCurrentKeyRow(parent)
 local row = CreateFrame("Button", nil, parent, "BackdropTemplate")
 row:SetSize(238, 24)
 row:SetBackdrop({
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
 row:SetBackdropColor(0.08, 0.08, 0.08, 0.92)
 row:SetBackdropBorderColor(0.20, 0.16, 0.10, 1)

 row.name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
 row.name:SetPoint("LEFT", 8, 0)
 row.name:SetWidth(86)
 row.name:SetJustifyH("LEFT")
 row.name:SetText(L.PLAYER)

 row.key = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
 row.key:SetPoint("RIGHT", -8, 0)
 row.key:SetWidth(138)
 row.key:SetJustifyH("RIGHT")
 row.key:SetText(L.NO_KEY)

 row:SetScript("OnEnter", function(self)
  if MRTE_ShowCurrentKeyTooltip then
   MRTE_ShowCurrentKeyTooltip(self)
  end
 end)

 row:SetScript("OnLeave", function()
  GameTooltip_Hide()
 end)

 row:SetScript("OnClick", function(_, button)
  if button == "LeftButton" and MRTE_OpenMythicPlusUI then
   MRTE_OpenMythicPlusUI()
  end
 end)

 return row
end

local function CreateGuildMemberRow(parent)
 local row = CreateFrame("Button", nil, parent, "BackdropTemplate")
 row:SetSize(238, 24)
 row:SetBackdrop({
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
 row:SetBackdropColor(0.08, 0.08, 0.08, 0.92)
 row:SetBackdropBorderColor(0.20, 0.16, 0.10, 1)

 row.classIcon = row:CreateTexture(nil, "ARTWORK")
 row.classIcon:SetSize(16, 16)
 row.classIcon:SetPoint("LEFT", 6, 0)
 row.classIcon:SetTexture("Interface/GLUES/CHARACTERCREATE/UI-CHARACTERCREATE-CLASSES")

 row.name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
 row.name:SetPoint("LEFT", row.classIcon, "RIGHT", 8, 0)
 row.name:SetWidth(110)
 row.name:SetJustifyH("LEFT")
 row.name:SetText(L.PLAYER)

 row.key = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
 row.key:SetPoint("RIGHT", -8, 0)
 row.key:SetWidth(100)
 row.key:SetJustifyH("RIGHT")
 row.key:SetText(L.NO_KEY)

 row:SetScript("OnEnter", function(self)
  if MRTE_ShowGuildMemberTooltip then
   MRTE_ShowGuildMemberTooltip(self)
  end
 end)

 row:SetScript("OnLeave", function()
  GameTooltip_Hide()
 end)

 return row
end

local function CreateNextPullCard(parent, width, height)
 local card = CreateFrame("Button", nil, parent, "BackdropTemplate")
 card:SetSize(width, height)
 card:EnableMouse(true)
 card:SetBackdrop({
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
 card:SetBackdropColor(0.08, 0.08, 0.08, 0.95)
 card:SetBackdropBorderColor(0.24, 0.19, 0.11, 1)

 card.title = card:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
 card.title:SetPoint("TOPLEFT", 8, -6)
 card.title:SetJustifyH("LEFT")
 card.title:SetText(L.PANEL_MDT_OVERLAY)
 MRTE_SetFont(card.title, 12, "OUTLINE")

 card.number = card:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
 card.number:SetPoint("TOPRIGHT", -8, -6)
 card.number:SetJustifyH("RIGHT")
 card.number:SetText("")
 MRTE_SetFont(card.number, 11, "OUTLINE")

 card.detail = card:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
 card.detail:SetPoint("TOPLEFT", card.title, "BOTTOMLEFT", 0, -6)
 card.detail:SetPoint("RIGHT", -8, 0)
 card.detail:SetJustifyH("LEFT")
 card.detail:SetText(L.OVERLAY_WAITING)
 MRTE_SetFont(card.detail, 10, "OUTLINE")

 card.enemies = card:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
 card.enemies:SetPoint("TOPLEFT", card.detail, "BOTTOMLEFT", 0, -4)
 card.enemies:SetPoint("RIGHT", -8, 0)
 card.enemies:SetJustifyH("LEFT")
 card.enemies:SetJustifyV("TOP")
 card.enemies:SetText("")
 MRTE_SetFont(card.enemies, 10, "OUTLINE")
 card.enemies:SetTextColor(0.78, 0.78, 0.78)

 card:SetScript("OnEnter", function(self)
  if MRTE_ShowNextPullTooltip then
   MRTE_ShowNextPullTooltip(self)
  end
 end)

 card:SetScript("OnLeave", function()
  GameTooltip_Hide()
 end)

 card:SetScript("OnMouseUp", function(self, button)
  if MRTE_HandleNextPullCardClick and MRTE_HandleNextPullCardClick(self, button) then
   return
  end

  if button == "MiddleButton" and MRTE_OpenMDTUI then
   MRTE_OpenMDTUI()
  end
 end)

 return card
end

local function CreateSeasonCurrencyRow(parent)
 local row = CreateFrame("Button", nil, parent, "BackdropTemplate")
 row:SetSize(264, 16)
 row:SetBackdrop({
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
 row:SetBackdropColor(0.08, 0.08, 0.08, 0.92)
 row:SetBackdropBorderColor(0.21, 0.17, 0.11, 1)

 row.icon = row:CreateTexture(nil, "ARTWORK")
 row.icon:SetSize(14, 14)
 row.icon:SetPoint("LEFT", 4, 0)
 row.icon:SetTexture(134400)

 row.name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
 row.name:SetPoint("LEFT", row.icon, "RIGHT", 6, 0)
 row.name:SetWidth(118)
 row.name:SetJustifyH("LEFT")
 row.name:SetText(L.CURRENCY)

 row.owned = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
 row.owned:SetPoint("RIGHT", -72, 0)
 row.owned:SetWidth(44)
 row.owned:SetJustifyH("RIGHT")
 row.owned:SetText("0")

 row.cap = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
 row.cap:SetPoint("RIGHT", -8, 0)
 row.cap:SetWidth(58)
 row.cap:SetJustifyH("RIGHT")
 row.cap:SetText("-")

 row:SetScript("OnEnter", function(self)
  if MRTE_ShowSeasonCurrencyTooltip then
   MRTE_ShowSeasonCurrencyTooltip(self)
  end
 end)

 row:SetScript("OnLeave", function()
  GameTooltip_Hide()
 end)

 return row
end

local function CreateDungeonInfoHeaderCell(parent, width, height, text)
 local cell = CreateFrame("Frame", nil, parent, "BackdropTemplate")
 cell:SetSize(width, height)
 cell:SetBackdrop({
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
 cell:SetBackdropColor(0.02, 0.24, 0.46, 0.96)
 cell:SetBackdropBorderColor(0.01, 0.01, 0.01, 1)

 cell.text = cell:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
 cell.text:SetPoint("CENTER", 0, 0)
 MRTE_SetFont(cell.text, 12, "OUTLINE")
 cell.text:SetTextColor(1, 1, 1)
 cell.text:SetText(text or "")

 return cell
end

local function CreateDungeonInfoRow(parent, width, height, columnWidths)
 local row = CreateFrame("Button", nil, parent)
 row:SetSize(width, height)
 row.cells = {}
 row.texts = {}

 local offsetX = 0

 for index, columnWidth in ipairs(columnWidths) do
  local cell = CreateFrame("Frame", nil, row, "BackdropTemplate")
  cell:SetSize(columnWidth, height)
  cell:SetPoint("TOPLEFT", offsetX, 0)
  cell:SetBackdrop({
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
  cell:SetBackdropColor(0.08, 0.08, 0.08, 0.94)
  cell:SetBackdropBorderColor(0.01, 0.01, 0.01, 1)

  local text = cell:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  text:SetPoint("CENTER", 0, 0)
  MRTE_SetFont(text, 12, "OUTLINE")
  text:SetTextColor(1, 1, 1)

  row.cells[index] = cell
  row.texts[index] = text
  offsetX = offsetX + columnWidth
 end

 row.level = row.texts[1]
 row.loot = row.texts[2]
 row.vault = row.texts[3]

 row:SetScript("OnEnter", function(self)
  if MRTE_ShowDungeonItemLevelTooltip then
   MRTE_ShowDungeonItemLevelTooltip(self)
  end
 end)

 row:SetScript("OnLeave", function()
  GameTooltip_Hide()
 end)

 return row
end

local function CreateDungeonInfoRewardBand(parent, width, height)
 local band = CreateFrame("Frame", nil, parent, "BackdropTemplate")
 band:SetSize(width, height)
 band:SetBackdrop({
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
 band:SetBackdropColor(0.08, 0.08, 0.08, 0.94)
 band:SetBackdropBorderColor(0.01, 0.01, 0.01, 1)

 band.text = band:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
 band.text:SetPoint("CENTER", 0, 0)
 MRTE_SetFont(band.text, 14, "OUTLINE")
 band.text:SetTextColor(0.62, 0.58, 0.50)

 return band
end

local function CreateAdvisorSummaryPanel(parent, titleText)
 local panel = CreateFrame("Frame", nil, parent, "BackdropTemplate")
 panel:SetSize(300, 172)
 panel:EnableMouse(true)
 MRTE_Style(panel)

 panel.title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
 panel.title:SetPoint("TOPLEFT", 14, -10)
 panel.title:SetPoint("TOPRIGHT", -14, -10)
 panel.title:SetJustifyH("LEFT")
 panel.title:SetText(titleText or "")
 MRTE_StyleTitle(panel.title, 15)

 panel.body = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
 panel.body:SetPoint("TOPLEFT", panel.title, "BOTTOMLEFT", 0, -10)
 panel.body:SetPoint("BOTTOMRIGHT", -14, 12)
 panel.body:SetJustifyH("LEFT")
 panel.body:SetJustifyV("TOP")
 panel.body:SetSpacing(4)
 panel.body:SetText("")
 MRTE_StyleStatus(panel.body)

 return panel
end

function MRTE_CreatePanels()
 local parent = MRTE_MainFrame

 local mythic = CreateFrame("Frame", nil, parent, "BackdropTemplate")
 mythic:SetSize(300, 330)
 mythic:SetPoint("TOPLEFT", 20, -66)
 mythic:EnableMouse(true)
 MRTE_Style(mythic)

 mythic.title = mythic:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
 mythic.title:SetPoint("TOP", 0, -10)
 mythic.title:SetText(L.PANEL_MYTHIC_STATS)
 MRTE_StyleTitle(mythic.title)

 mythic.totalScore = mythic:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
 mythic.totalScore:SetPoint("TOPLEFT", 18, -38)
 MRTE_SetFont(mythic.totalScore, 28, "OUTLINE")
 mythic.totalScore:SetText("0")

 mythic.totalScoreLabel = mythic:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
 mythic.totalScoreLabel:SetPoint("TOPLEFT", mythic.totalScore, "BOTTOMLEFT", 0, -2)
 mythic.totalScoreLabel:SetText(L.TOTAL_SCORE)

 mythic.progressText = mythic:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
 mythic.progressText:SetPoint("TOPRIGHT", -18, -42)
 mythic.progressText:SetJustifyH("RIGHT")
 mythic.progressText:SetText(MRTE_T("MYTHIC_DUNGEONS_PROGRESS", 0, 0))

 mythic.logsText = mythic:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
 mythic.logsText:SetPoint("TOPRIGHT", -18, -58)
 mythic.logsText:SetJustifyH("RIGHT")
 mythic.logsText:SetText(MRTE_T("MYTHIC_RUNS_LOGGED", 0))

 mythic.emptyText = mythic:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
 mythic.emptyText:SetPoint("TOP", 0, -162)
 mythic.emptyText:SetWidth(240)
 mythic.emptyText:SetJustifyH("CENTER")
 mythic.emptyText:SetText(L.LOADING_MYTHIC_DATA)

 mythic.rows = {}

 for index = 1, 8 do
  local row = CreateMythicDungeonRow(mythic)
  row:SetPoint("TOPLEFT", 18, -86 - ((index - 1) * 29))
  mythic.rows[index] = row
 end

 MRTE_MythicPanel = mythic

 mythic:SetScript("OnMouseUp", function(_, button)
  if button == "LeftButton" and MRTE_OpenMythicPlusUI then
   MRTE_OpenMythicPlusUI()
  end
 end)

 local currentKeys = CreateFrame("Frame", nil, parent, "BackdropTemplate")
 currentKeys:SetSize(300, 116)
 currentKeys:SetPoint("TOPLEFT", mythic, "BOTTOMLEFT", 0, -8)
 MRTE_Style(currentKeys)

 currentKeys.title = currentKeys:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
 currentKeys.title:SetPoint("TOP", 0, -10)
 currentKeys.title:SetText(L.PANEL_CURRENT_KEYS)
 MRTE_StyleTitle(currentKeys.title)

 currentKeys.emptyText = currentKeys:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
 currentKeys.emptyText:SetPoint("CENTER")
 currentKeys.emptyText:SetWidth(240)
 currentKeys.emptyText:SetJustifyH("CENTER")
 currentKeys.emptyText:SetText(L.NO_CURRENT_KEYS)

 currentKeys.scrollFrame = CreateFrame("ScrollFrame", nil, currentKeys, "UIPanelScrollFrameTemplate")
 currentKeys.scrollFrame:SetPoint("TOPLEFT", 16, -36)
 currentKeys.scrollFrame:SetPoint("BOTTOMRIGHT", -28, 12)

 currentKeys.content = CreateFrame("Frame", nil, currentKeys.scrollFrame)
 currentKeys.content:SetSize(240, 1)
 currentKeys.scrollFrame:SetScrollChild(currentKeys.content)

 currentKeys.rows = {}

 for index = 1, 5 do
  local row = CreateCurrentKeyRow(currentKeys.content)
  row:SetPoint("TOPLEFT", 0, -((index - 1) * 28))
  currentKeys.rows[index] = row
 end

 MRTE_CurrentKeysPanel = currentKeys

 local portals = CreateFrame("Frame", nil, parent, "BackdropTemplate")
 portals:SetSize(320, 300)
 portals:SetPoint("TOP", 0, -66)
 MRTE_Style(portals)

 portals.title = portals:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
 portals.title:SetPoint("TOP", 0, -10)
 portals.title:SetText(L.PANEL_SEASON_PORTALS)
 MRTE_StyleTitle(portals.title)

 portals.emptyText = portals:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
 portals.emptyText:SetPoint("CENTER")
 portals.emptyText:SetWidth(260)
 portals.emptyText:SetJustifyH("CENTER")
 portals.emptyText:SetJustifyV("MIDDLE")
 portals.emptyText:SetText(L.LOADING_CURRENT_SEASON_DUNGEONS)

 portals.buttons = {}

 for index = 1, 8 do
  local button = CreateFrame("Button", nil, portals, "InsecureActionButtonTemplate, BackdropTemplate")
  button:RegisterForClicks("AnyUp", "AnyDown")
  button:SetSize(280, 26)
  button:SetPoint("TOPLEFT", 20, -42 - ((index - 1) * 31))
  button:SetBackdrop({
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
  button:SetBackdropColor(0.08, 0.08, 0.08, 0.95)
  button:SetBackdropBorderColor(0.24, 0.19, 0.11, 1)

  button.icon = button:CreateTexture(nil, "ARTWORK")
  button.icon:SetSize(18, 18)
  button.icon:SetPoint("LEFT", 8, 0)

  button.text = button:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  button.text:SetPoint("LEFT", button.icon, "RIGHT", 8, 0)
  button.text:SetPoint("RIGHT", -10, 0)
  button.text:SetJustifyH("LEFT")
  button.text:SetText(L.LOADING_DUNGEON)

  button:SetScript("OnEnter", function(self)
   if MRTE_ShowSeasonPortalTooltip then
    MRTE_ShowSeasonPortalTooltip(self)
   end
  end)

  button:SetScript("OnLeave", function()
   GameTooltip_Hide()
  end)

  portals.buttons[index] = button
 end

 MRTE_SeasonPortalsPanel = portals

 local dungeonInfo = CreateFrame("Frame", nil, parent, "BackdropTemplate")
 dungeonInfo:SetSize(320, 292)
 dungeonInfo:SetPoint("TOP", portals, "BOTTOM", 0, -16)
 MRTE_Style(dungeonInfo)

 dungeonInfo.title = dungeonInfo:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
 dungeonInfo.title:SetPoint("TOP", 0, -10)
 dungeonInfo.title:SetText(L.PANEL_DUNGEON_ITEM_LEVELS)
 MRTE_StyleTitle(dungeonInfo.title)

 dungeonInfo.headerCells = {}
 dungeonInfo.rows = {}
 dungeonInfo.rewardBands = {}

 local tableLeft = 18
 local tableTop = -34
 local headerHeight = 22
 local rowHeight = 17
 local levelWidth = 54
 local lootWidth = 48
 local vaultWidth = 58
 local crestWidth = 124
 local leftRowWidth = levelWidth + lootWidth + vaultWidth

 local headers = {
  { key = "level", width = levelWidth, label = L.LEVEL },
  { key = "loot", width = lootWidth, label = L.LOOT },
  { key = "vault", width = vaultWidth, label = L.VAULT },
  { key = "crest", width = crestWidth, label = L.CREST_REWARD },
 }

 local headerX = tableLeft

 for _, header in ipairs(headers) do
  local cell = CreateDungeonInfoHeaderCell(dungeonInfo, header.width, headerHeight, header.label)
  cell:SetPoint("TOPLEFT", headerX, tableTop)
  dungeonInfo.headerCells[header.key] = cell
  headerX = headerX + header.width
 end

 for index = 1, 13 do
  local row = CreateDungeonInfoRow(dungeonInfo, leftRowWidth, rowHeight, { levelWidth, lootWidth, vaultWidth })
  row:SetPoint("TOPLEFT", tableLeft, tableTop - headerHeight - ((index - 1) * rowHeight))
  dungeonInfo.rows[index] = row
 end

 local rewardBands = {
  { key = "heroic", startRow = 1, span = 1 },
  { key = "champ", startRow = 2, span = 3 },
  { key = "hero", startRow = 5, span = 5 },
  { key = "myth", startRow = 10, span = 4 },
 }

 for _, definition in ipairs(rewardBands) do
  local band = CreateDungeonInfoRewardBand(dungeonInfo, crestWidth, rowHeight * definition.span)
  band:SetPoint(
   "TOPLEFT",
   tableLeft + leftRowWidth,
   tableTop - headerHeight - ((definition.startRow - 1) * rowHeight)
  )
  dungeonInfo.rewardBands[definition.key] = band
 end

 MRTE_DungeonItemLevelPanel = dungeonInfo

 local vault = CreateFrame("Frame", nil, parent, "BackdropTemplate")
 vault:SetSize(300, 190)
 vault:SetPoint("TOPRIGHT", -20, -66)
 vault:EnableMouse(true)
 MRTE_Style(vault)

 vault.title = vault:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
 vault.title:SetPoint("TOP", 0, -10)
 vault.title:SetText(L.PANEL_GREAT_VAULT)
 MRTE_StyleTitle(vault.title)

 vault.cells = {}

 local cellWidth = 72
 local cellHeight = 28
 local cellGapX = 12
 local cellGapY = 10
 local startX = 30
 local startY = -48

 for row = 1, 3 do
  vault.cells[row] = {}

  for column = 1, 3 do
   local cell = CreateVaultCell(vault, cellWidth, cellHeight)
   cell:SetPoint(
    "TOPLEFT",
    startX + ((column - 1) * (cellWidth + cellGapX)),
    startY - ((row - 1) * (cellHeight + cellGapY))
   )
   cell.text:SetText("0/0")
   vault.cells[row][column] = cell
  end
 end

 MRTE_VaultPanel = vault

 vault:SetScript("OnMouseUp", function(_, button)
  if button == "LeftButton" and MRTE_OpenGreatVaultUI then
   MRTE_OpenGreatVaultUI()
  end
 end)

 local currencies = CreateFrame("Frame", nil, parent, "BackdropTemplate")
 currencies:SetSize(300, 200)
 currencies:SetPoint("TOPRIGHT", -20, -264)
 MRTE_Style(currencies)

 currencies.title = currencies:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
 currencies.title:SetPoint("TOP", 0, -10)
 currencies.title:SetText(L.PANEL_SEASON_CURRENCIES)
 MRTE_StyleTitle(currencies.title)

 currencies.emptyText = currencies:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
 currencies.emptyText:SetPoint("CENTER")
 currencies.emptyText:SetWidth(250)
 currencies.emptyText:SetJustifyH("CENTER")
 currencies.emptyText:SetText(L.NO_SEASON_CURRENCIES_FOUND)

 currencies.rows = {}

 for index = 1, 9 do
  local row = CreateSeasonCurrencyRow(currencies)
  row:SetPoint("TOPLEFT", 18, -34 - ((index - 1) * 17))
  currencies.rows[index] = row
 end

 MRTE_SeasonCurrenciesPanel = currencies

 local guild = CreateFrame("Frame", nil, parent, "BackdropTemplate")
 guild:SetSize(300, 204)
 guild:SetPoint("BOTTOMLEFT", 20, 64)
 MRTE_Style(guild)

 guild.title = guild:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
 guild.title:SetPoint("TOP", 0, -10)
 guild.title:SetText(L.PANEL_GUILD_STATS)
 MRTE_StyleTitle(guild.title)

 guild.emptyText = guild:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
 guild.emptyText:SetPoint("CENTER")
 guild.emptyText:SetWidth(240)
 guild.emptyText:SetJustifyH("CENTER")
 guild.emptyText:SetText(L.NO_ONLINE_GUILD_MEMBERS)

 guild.scrollFrame = CreateFrame("ScrollFrame", nil, guild, "UIPanelScrollFrameTemplate")
 guild.scrollFrame:SetPoint("TOPLEFT", 16, -36)
 guild.scrollFrame:SetPoint("BOTTOMRIGHT", -28, 12)

 guild.content = CreateFrame("Frame", nil, guild.scrollFrame)
 guild.content:SetSize(240, 1)
 guild.scrollFrame:SetScrollChild(guild.content)

 guild.rows = {}

 for index = 1, 18 do
  local row = CreateGuildMemberRow(guild.content)
  row:SetPoint("TOPLEFT", 0, -((index - 1) * 28))
  guild.rows[index] = row
 end

 MRTE_GuildPanel = guild

 local advisorToday = CreateAdvisorSummaryPanel(parent, L.PANEL_ADVISOR_TODAY)
 advisorToday:SetPoint("TOPLEFT", 20, -66)
 MRTE_AdvisorTodayPanel = advisorToday

 local advisorGroup = CreateAdvisorSummaryPanel(parent, L.PANEL_ADVISOR_GROUP)
 advisorGroup:SetPoint("TOP", 0, -66)
 MRTE_AdvisorGroupPanel = advisorGroup

 local advisorAlts = CreateAdvisorSummaryPanel(parent, L.PANEL_ADVISOR_ALTS)
 advisorAlts:SetPoint("TOP", 0, -256)
 MRTE_AdvisorAltsPanel = advisorAlts

 local advisorVault = CreateAdvisorSummaryPanel(parent, L.PANEL_ADVISOR_VAULT)
 advisorVault:SetPoint("TOPRIGHT", -20, -66)
 MRTE_AdvisorVaultPanel = advisorVault

 local overlay = CreateFrame("Frame", nil, parent, "BackdropTemplate")
 overlay:SetSize(300, 244)
 overlay:SetPoint("BOTTOMRIGHT", -20, 64)
 overlay:EnableMouse(true)
 MRTE_Style(overlay)

 overlay.title = overlay:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
 overlay.title:SetPoint("TOP", 0, -10)
 overlay.title:SetText(L.PANEL_MDT_OVERLAY)
 MRTE_StyleTitle(overlay.title)

 overlay.info = overlay:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
 overlay.info:SetPoint("TOP", overlay.title, "BOTTOM", 0, -12)
 overlay.info:SetWidth(250)
 overlay.info:SetJustifyH("CENTER")
 overlay.info:SetJustifyV("TOP")
 overlay.info:SetText(L.OVERLAY_WAITING)
 MRTE_SetFont(overlay.info, 11, "OUTLINE")

 overlay.status = overlay:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
 overlay.status:SetPoint("TOP", overlay.info, "BOTTOM", 0, -4)
 overlay.status:SetWidth(250)
 overlay.status:SetJustifyH("CENTER")
 overlay.status:SetJustifyV("TOP")
 overlay.status:SetText(L.OVERLAY_INFO)
 MRTE_SetFont(overlay.status, 10, "OUTLINE")

 overlay.routeInfo = overlay:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
 overlay.routeInfo:SetPoint("TOPLEFT", 20, -212)
 overlay.routeInfo:SetPoint("RIGHT", -20, 0)
 overlay.routeInfo:SetJustifyH("LEFT")
 overlay.routeInfo:SetJustifyV("TOP")
 overlay.routeInfo:SetSpacing(3)
 overlay.routeInfo:SetText("")
 MRTE_SetFont(overlay.routeInfo, 10, "OUTLINE")
 MRTE_StyleStatus(overlay.routeInfo)
 overlay.routeInfo:Hide()

 overlay.dragHandle = CreateFrame("Frame", nil, overlay)
 overlay.dragHandle:SetPoint("TOPLEFT", 12, -6)
 overlay.dragHandle:SetPoint("TOPRIGHT", -36, -6)
 overlay.dragHandle:SetHeight(50)
 overlay.dragHandle:EnableMouse(false)

 overlay.currentCard = CreateNextPullCard(overlay, 260, 62)
 overlay.currentCard:SetPoint("TOPLEFT", 20, -76)

 overlay.nextCard = CreateNextPullCard(overlay, 260, 62)
 overlay.nextCard:SetPoint("TOPLEFT", 20, -144)

 local refreshBtn = CreateFrame("Button", nil, overlay, "UIPanelButtonTemplate")
 refreshBtn:SetSize(74, 28)
 refreshBtn:SetPoint("BOTTOMLEFT", 20, 12)
 refreshBtn:SetText(L.OVERLAY_REFRESH)
 refreshBtn:SetScript("OnClick", function()
  if MRTE_RefreshNextPullPanel then
   MRTE_RefreshNextPullPanel(true, true)
  end
 end)
 overlay.refreshButton = refreshBtn

 local resetBtn = CreateFrame("Button", nil, overlay, "UIPanelButtonTemplate")
 resetBtn:SetSize(74, 28)
 resetBtn:SetPoint("BOTTOM", 0, 12)
 resetBtn:SetText(L.NEXT_PULL_RESET)
 resetBtn:SetScript("OnClick", function()
  if MRTE_ResetNextPullManualState then
   MRTE_ResetNextPullManualState(true)
  end
 end)
 overlay.resetButton = resetBtn

 local toggleBtn = CreateFrame("Button", nil, overlay, "UIPanelButtonTemplate")
 toggleBtn:SetSize(96, 28)
 toggleBtn:SetPoint("BOTTOMRIGHT", -20, 12)
 toggleBtn:SetText(L.NEXT_PULL_DETACH)
 toggleBtn:SetScript("OnClick", function()
  if MRTE_ToggleNextPullDetached then
   MRTE_ToggleNextPullDetached()
  elseif MRTE_ToggleNextPull then
   MRTE_ToggleNextPull()
  end
 end)
 overlay.toggleButton = toggleBtn

 local overlayPlaceholder = CreateFrame("Frame", nil, parent, "BackdropTemplate")
 overlayPlaceholder:SetSize(300, 244)
 overlayPlaceholder:SetPoint("BOTTOMRIGHT", -20, 64)
 overlayPlaceholder:EnableMouse(true)
 MRTE_Style(overlayPlaceholder)

 overlayPlaceholder.title = overlayPlaceholder:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
 overlayPlaceholder.title:SetPoint("TOP", 0, -10)
 overlayPlaceholder.title:SetText(L.PANEL_MDT_OVERLAY)
 MRTE_StyleTitle(overlayPlaceholder.title)

 overlayPlaceholder.info = overlayPlaceholder:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
 overlayPlaceholder.info:SetPoint("TOP", overlayPlaceholder.title, "BOTTOM", 0, -54)
 overlayPlaceholder.info:SetWidth(240)
 overlayPlaceholder.info:SetJustifyH("CENTER")
 overlayPlaceholder.info:SetJustifyV("MIDDLE")
 overlayPlaceholder.info:SetText(L.NEXT_PULL_POPOUT_ACTIVE)
 MRTE_SetFont(overlayPlaceholder.info, 12, "OUTLINE")

 overlayPlaceholder.status = overlayPlaceholder:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
 overlayPlaceholder.status:SetPoint("TOP", overlayPlaceholder.info, "BOTTOM", 0, -18)
 overlayPlaceholder.status:SetWidth(240)
 overlayPlaceholder.status:SetJustifyH("CENTER")
 overlayPlaceholder.status:SetJustifyV("TOP")
 overlayPlaceholder.status:SetText(L.NEXT_PULL_POPOUT_HINT)
 MRTE_SetFont(overlayPlaceholder.status, 10, "OUTLINE")

 overlayPlaceholder:SetScript("OnMouseUp", function(_, button)
  if button == "LeftButton" and MRTE_BringNextPullPopoutToFront then
   MRTE_BringNextPullPopoutToFront()
  end
 end)
 overlayPlaceholder:Hide()

 MRTE_NextPullPanel = overlay
 MRTE_NextPullPanelSummaryText = overlay.info
 MRTE_NextPullPanelStatusText = overlay.status
 MRTE_NextPullPanelRouteInfoText = overlay.routeInfo
 MRTE_NextPullCurrentCard = overlay.currentCard
 MRTE_NextPullNextCard = overlay.nextCard
 MRTE_OverlayPanel = overlay
 MRTE_OverlayPanelText = overlay.status
 MRTE_NextPullPlaceholderPanel = overlayPlaceholder

 overlay:SetScript("OnMouseUp", function(_, button)
  if button == "LeftButton" and MRTE_OpenMDTUI then
   MRTE_OpenMDTUI()
  end
 end)

 if MRTE_RegisterPanel then
  MRTE_RegisterPanel("mythic", mythic)
  MRTE_RegisterPanel("party_keys", currentKeys)
  MRTE_RegisterPanel("portals", portals)
  MRTE_RegisterPanel("dungeon_info", dungeonInfo)
  MRTE_RegisterPanel("vault", vault)
  MRTE_RegisterPanel("currencies", currencies)
  MRTE_RegisterPanel("guild", guild)
  MRTE_RegisterPanel("next_pull", overlay)
  MRTE_RegisterPanel("advisor_today", advisorToday)
  MRTE_RegisterPanel("advisor_group", advisorGroup)
  MRTE_RegisterPanel("advisor_alts", advisorAlts)
  MRTE_RegisterPanel("advisor_vault", advisorVault)
  MRTE_RegisterPanelPlaceholder("next_pull", overlayPlaceholder)
 end
end




