local L = MRTE_L

local MAIN_FRAME_DEFAULTS = {
 width = 1020,
 height = 780,
}

local AUTO_LAYOUT = {
 leftMargin = 20,
 rightMargin = 20,
 topOffset = 66,
 bottomPadding = 32,
 columnGap = 18,
 rowGap = 12,
}

local PANEL_ORDER = {
 "mythic",
 "party_keys",
 "portals",
 "dungeon_info",
 "vault",
 "currencies",
 "guild",
 "next_pull",
 "advisor_today",
 "advisor_group",
 "advisor_alts",
 "advisor_vault",
}

local PANEL_LAYOUTS = {
 mythic = {
  labelKey = "PANEL_MYTHIC_STATS",
  slotLabelKey = "OPTIONS_SLOT_UPPER_LEFT",
  column = "left",
  order = 1,
 },
 party_keys = {
  labelKey = "PANEL_CURRENT_KEYS",
  slotLabelKey = "OPTIONS_SLOT_MID_LEFT",
  column = "left",
  order = 2,
 },
 portals = {
  labelKey = "PANEL_SEASON_PORTALS",
  slotLabelKey = "OPTIONS_SLOT_UPPER_CENTER",
  column = "center",
  order = 1,
 },
 dungeon_info = {
  labelKey = "PANEL_DUNGEON_ITEM_LEVELS",
  slotLabelKey = "OPTIONS_SLOT_LOWER_CENTER",
  column = "center",
  order = 2,
 },
 vault = {
  labelKey = "PANEL_GREAT_VAULT",
  slotLabelKey = "OPTIONS_SLOT_UPPER_RIGHT",
  column = "right",
  order = 1,
 },
 currencies = {
  labelKey = "PANEL_SEASON_CURRENCIES",
  slotLabelKey = "OPTIONS_SLOT_MID_RIGHT",
  column = "right",
  order = 2,
 },
 guild = {
  labelKey = "PANEL_GUILD_STATS",
  slotLabelKey = "OPTIONS_SLOT_LOWER_LEFT",
  column = "left",
  order = 3,
 },
 next_pull = {
  labelKey = "PANEL_MDT_OVERLAY",
  slotLabelKey = "OPTIONS_SLOT_LOWER_RIGHT",
  column = "right",
  order = 3,
 },
 advisor_today = {
  labelKey = "PANEL_ADVISOR_TODAY",
  slotLabelKey = "OPTIONS_SLOT_EXTRA_CENTER",
  column = "center",
  order = 3,
 },
 advisor_group = {
  labelKey = "PANEL_ADVISOR_GROUP",
  slotLabelKey = "OPTIONS_SLOT_EXTRA_LEFT",
  column = "left",
  order = 4,
 },
 advisor_alts = {
  labelKey = "PANEL_ADVISOR_ALTS",
  slotLabelKey = "OPTIONS_SLOT_EXTRA_CENTER_2",
  column = "center",
  order = 4,
 },
 advisor_vault = {
  labelKey = "PANEL_ADVISOR_VAULT",
  slotLabelKey = "OPTIONS_SLOT_EXTRA_RIGHT",
  column = "right",
  order = 4,
 },
}

local DEFAULT_PANEL_ENABLED = {
 advisor_today = false,
 advisor_group = false,
 advisor_alts = false,
 advisor_vault = false,
}

local DEFAULT_UI_SETTINGS = {
 overview = {
  width = MAIN_FRAME_DEFAULTS.width,
  height = MAIN_FRAME_DEFAULTS.height,
 },
 globalScale = 1,
 raidDifficulties = {
  normal = false,
  heroic = false,
  mythic = false,
 },
 unlockPanels = false,
 colors = {
  accent = { 1.00, 0.86, 0.10 },
  panelBackground = { 0.04, 0.04, 0.05 },
  panelBorder = { 0.25, 0.20, 0.10 },
 },
 layoutSlots = {},
 panels = {},
}

for _, panelId in ipairs(PANEL_ORDER) do
 DEFAULT_UI_SETTINGS.panels[panelId] = {
  enabled = DEFAULT_PANEL_ENABLED[panelId] ~= false,
  scale = 1,
  widthScale = 1,
  heightScale = 1,
 }
 DEFAULT_UI_SETTINGS.layoutSlots[panelId] = panelId
end

local PANEL_REGISTRY = {}
local PANEL_PLACEHOLDERS = {}
local OPTIONS_CONTROLS = {
 raidDifficultyCheckboxes = {},
 panelRows = {},
 colorButtons = {},
}
local sliderCounter = 0
local GetPanelSettings

local function CopyDefaults(target, defaults)
 if type(defaults) ~= "table" then
  return target
 end

 if type(target) ~= "table" then
  target = {}
 end

 for key, value in pairs(defaults) do
  if type(value) == "table" then
   target[key] = CopyDefaults(target[key], value)
  elseif target[key] == nil then
   target[key] = value
  end
 end

 return target
end

local function CopyColorDefaults(key)
 local defaults = DEFAULT_UI_SETTINGS.colors[key]
 return { defaults[1], defaults[2], defaults[3] }
end

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

local function GetPanelLabel(panelId)
 local definition = PANEL_LAYOUTS[panelId]
 if not definition then
  return panelId
 end

 return MRTE_T(definition.labelKey)
end

local function GetAssignedSlot(panelId)
 local settings = MRTE_GetUISettings()
 settings.layoutSlots = CopyDefaults(settings.layoutSlots, DEFAULT_UI_SETTINGS.layoutSlots)

 local slotId = settings.layoutSlots[panelId]
 if type(slotId) ~= "string" or not PANEL_LAYOUTS[slotId] then
  slotId = panelId
  settings.layoutSlots[panelId] = slotId
 end

 return slotId
end

local function GetSlotLabel(slotId)
 local definition = PANEL_LAYOUTS[slotId]
 if not definition then
  return slotId
 end

 return MRTE_T(definition.slotLabelKey or definition.labelKey)
end

local function GetPanelAssignedToSlot(slotId)
 local settings = MRTE_GetUISettings()
 settings.layoutSlots = CopyDefaults(settings.layoutSlots, DEFAULT_UI_SETTINGS.layoutSlots)

 for _, otherPanelId in ipairs(PANEL_ORDER) do
  local currentSlot = settings.layoutSlots[otherPanelId] or otherPanelId
  if currentSlot == slotId then
   return otherPanelId
  end
 end

 return nil
end

local function SetPanelSlot(panelId, targetSlotId)
 if not panelId or not PANEL_LAYOUTS[targetSlotId] then
  return
 end

 local settings = MRTE_GetUISettings()
 settings.layoutSlots = CopyDefaults(settings.layoutSlots, DEFAULT_UI_SETTINGS.layoutSlots)

 local currentSlot = GetAssignedSlot(panelId)
 if currentSlot == targetSlotId then
  return
 end

 local otherPanelId = GetPanelAssignedToSlot(targetSlotId)
 settings.layoutSlots[panelId] = targetSlotId

 if otherPanelId and otherPanelId ~= panelId then
  settings.layoutSlots[otherPanelId] = currentSlot
  GetPanelSettings(otherPanelId).position = nil
 end

 GetPanelSettings(panelId).position = nil
end

local function CyclePanelSlot(panelId, direction)
 local currentSlot = GetAssignedSlot(panelId)
 local currentIndex = 1

 for index, slotId in ipairs(PANEL_ORDER) do
  if slotId == currentSlot then
   currentIndex = index
   break
  end
 end

 local targetIndex = currentIndex + (direction or 1)
 if targetIndex < 1 then
  targetIndex = #PANEL_ORDER
 elseif targetIndex > #PANEL_ORDER then
  targetIndex = 1
 end

 SetPanelSlot(panelId, PANEL_ORDER[targetIndex])
end

local function IsDetachedPanel(panelId)
 return panelId == "next_pull" and MRTE_IsNextPullDetached and MRTE_IsNextPullDetached()
end

GetPanelSettings = function(panelId)
 local settings = MRTE_GetUISettings()
 settings.panels[panelId] = CopyDefaults(settings.panels[panelId], DEFAULT_UI_SETTINGS.panels[panelId] or {
  enabled = DEFAULT_PANEL_ENABLED[panelId] ~= false,
  scale = 1,
  widthScale = 1,
  heightScale = 1,
 })
 return settings.panels[panelId]
end

local function EnsureFrameBaseSize(frame)
 if not frame then
  return
 end

 if not frame.mrteBaseWidth or frame.mrteBaseWidth <= 0 then
  frame.mrteBaseWidth = frame:GetWidth()
 end

 if not frame.mrteBaseHeight or frame.mrteBaseHeight <= 0 then
  frame.mrteBaseHeight = frame:GetHeight()
 end
end

local function GetPanelFrameForLayout(panelId)
 local frame = PANEL_REGISTRY[panelId] or PANEL_PLACEHOLDERS[panelId]
 if not frame then
  return nil
 end

 EnsureFrameBaseSize(frame)
 return frame
end

local function GetPanelLayoutMetrics(panelId)
 local settings = GetPanelSettings(panelId)
 if settings.enabled == false then
  return 0, 0
 end

 local frame = GetPanelFrameForLayout(panelId)
 if not frame then
  return 0, 0
 end

 local panelScale = tonumber(settings.scale) or 1
 local widthScale = tonumber(settings.widthScale) or 1
 local heightScale = tonumber(settings.heightScale) or 1
 local baseWidth = frame.mrteBaseWidth or frame:GetWidth() or 0
 local baseHeight = frame.mrteBaseHeight or frame:GetHeight() or 0

 return baseWidth * widthScale * panelScale, baseHeight * heightScale * panelScale
end

local function BuildAutoLayoutState()
 local state = {
  columns = {
   left = { width = 0, height = 0, slots = {}, slotMap = {} },
   center = { width = 0, height = 0, slots = {}, slotMap = {} },
   right = { width = 0, height = 0, slots = {}, slotMap = {} },
  },
  requiredWidth = AUTO_LAYOUT.leftMargin + AUTO_LAYOUT.rightMargin,
  requiredHeight = AUTO_LAYOUT.topOffset + AUTO_LAYOUT.bottomPadding,
 }

 for _, slotId in ipairs(PANEL_ORDER) do
  local definition = PANEL_LAYOUTS[slotId]
  if definition and state.columns[definition.column] then
   table.insert(state.columns[definition.column].slots, slotId)
  end
 end

 for _, columnId in ipairs({ "left", "center", "right" }) do
  local column = state.columns[columnId]
  table.sort(column.slots, function(a, b)
   return (PANEL_LAYOUTS[a].order or 0) < (PANEL_LAYOUTS[b].order or 0)
  end)

  local offset = 0
  local visibleCount = 0
  for index, slotId in ipairs(column.slots) do
   local panelId = GetPanelAssignedToSlot(slotId)
   local width, height = 0, 0
   if panelId then
    width, height = GetPanelLayoutMetrics(panelId)
   end

   if width > 0 and height > 0 and visibleCount > 0 then
    offset = offset + AUTO_LAYOUT.rowGap
   end

   local entry = {
    slotId = slotId,
    panelId = panelId,
    width = width,
    height = height,
    offset = offset,
   }

   column.slots[index] = entry
   column.slotMap[slotId] = entry

   if width > 0 and height > 0 then
    offset = offset + height
    visibleCount = visibleCount + 1
    column.width = math.max(column.width, width)
   end
  end

  column.height = offset
  if column.height > 0 then
   state.requiredHeight = math.max(state.requiredHeight, AUTO_LAYOUT.topOffset + column.height + AUTO_LAYOUT.bottomPadding)
  end
 end

 local hasPreviousVisibleColumn = false
 for _, columnId in ipairs({ "left", "center", "right" }) do
  local column = state.columns[columnId]
  if column.width > 0 and column.height > 0 then
   if hasPreviousVisibleColumn then
    state.requiredWidth = state.requiredWidth + AUTO_LAYOUT.columnGap
   end

   state.requiredWidth = state.requiredWidth + column.width
   hasPreviousVisibleColumn = true
  end
 end

 return state
end

local function GetAutoLayoutPosition(slotId, layoutState)
 local definition = PANEL_LAYOUTS[slotId]
 if not definition then
  return {
   point = "TOPLEFT",
   relativePoint = "TOPLEFT",
   x = AUTO_LAYOUT.leftMargin,
   y = -AUTO_LAYOUT.topOffset,
  }
 end

 layoutState = layoutState or BuildAutoLayoutState()

 local column = layoutState.columns[definition.column]
 local entry = column and column.slotMap and column.slotMap[slotId] or nil
 local settings = MRTE_GetUISettings()
 local frameWidth = tonumber(settings.overview.width) or MAIN_FRAME_DEFAULTS.width
 local leftWidth = layoutState.columns.left.width or 0
 local centerWidth = layoutState.columns.center.width or 0
 local rightWidth = layoutState.columns.right.width or 0
 local x = AUTO_LAYOUT.leftMargin

 if definition.column == "left" then
  x = AUTO_LAYOUT.leftMargin
 elseif definition.column == "center" then
  local preferred = math.floor((frameWidth - centerWidth) / 2 + 0.5)
  local minX = AUTO_LAYOUT.leftMargin
  if leftWidth > 0 then
   minX = minX + leftWidth + AUTO_LAYOUT.columnGap
  end

  local maxX = frameWidth - AUTO_LAYOUT.rightMargin - centerWidth
  if rightWidth > 0 then
   maxX = maxX - rightWidth - AUTO_LAYOUT.columnGap
  end

  if maxX < minX then
   x = minX
  else
   x = math.min(math.max(preferred, minX), maxX)
  end
 elseif definition.column == "right" then
  x = frameWidth - AUTO_LAYOUT.rightMargin - (column and column.width or 0)
 end

 return {
  point = "TOPLEFT",
  relativePoint = "TOPLEFT",
  x = x,
  y = -AUTO_LAYOUT.topOffset - ((entry and entry.offset) or 0),
 }
end

local function ClampOverviewToLayoutBounds()
 local settings = MRTE_GetUISettings()
 settings.overview = CopyDefaults(settings.overview, DEFAULT_UI_SETTINGS.overview)

 local layoutState = BuildAutoLayoutState()
 settings.overview.width = math.max(
  math.floor((tonumber(settings.overview.width) or MAIN_FRAME_DEFAULTS.width) + 0.5),
  math.ceil(layoutState.requiredWidth or 0)
 )
 settings.overview.height = math.max(
  math.floor((tonumber(settings.overview.height) or MAIN_FRAME_DEFAULTS.height) + 0.5),
  math.ceil(layoutState.requiredHeight or 0)
 )

 return layoutState
end

local function UpdateColorButton(button, color)
 if not button or not button.swatch then
  return
 end

 button.swatch:SetColorTexture(color[1] or 1, color[2] or 1, color[3] or 1, 1)
end

local function CreatePanelHandle(frame)
 local handle = frame.mrteLayoutHandle
 if handle then
  return handle
 end

 handle = CreateFrame("Frame", nil, frame, "BackdropTemplate")
 handle:SetPoint("TOPLEFT", 2, -2)
 handle:SetPoint("TOPRIGHT", -2, -2)
 handle:SetHeight(28)
 handle:SetFrameLevel(frame:GetFrameLevel() + 20)
 handle:RegisterForDrag("LeftButton")

 handle.bg = handle:CreateTexture(nil, "ARTWORK")
 handle.bg:SetAllPoints()

 handle.label = handle:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
 handle.label:SetPoint("CENTER", 0, 0)
 MRTE_SetFont(handle.label, 11, "OUTLINE")
 handle.label:SetText(L.OPTIONS_DRAG_PANEL)

 handle:SetScript("OnDragStart", function()
  if not MRTE_ArePanelsUnlocked() then
   return
  end

  if not frame:IsShown() then
   return
  end

  frame:StartMoving()
 end)

 handle:SetScript("OnDragStop", function()
  frame:StopMovingOrSizing()
  if frame.mrtePanelId then
   MRTE_SavePanelPosition(frame.mrtePanelId)
  end
 end)

 frame.mrteLayoutHandle = handle
 return handle
end

local function UpdatePanelHandle(frame)
 if not frame or not frame.mrteLayoutHandle then
  return
 end

 local unlocked = MRTE_ArePanelsUnlocked()
 if frame.mrtePanelId == "next_pull" and IsDetachedPanel("next_pull") then
  unlocked = false
 end

 local theme = MRTE_GetThemeColors and MRTE_GetThemeColors() or nil
 local accent = theme and theme.accent or { 1.00, 0.86, 0.10 }

 frame.mrteLayoutHandle:EnableMouse(unlocked)
 frame.mrteLayoutHandle.bg:SetColorTexture(accent[1], accent[2], accent[3], 0.18)
 frame.mrteLayoutHandle.label:SetTextColor(accent[1], accent[2], accent[3])
 frame.mrteLayoutHandle.bg:SetShown(unlocked)
 frame.mrteLayoutHandle.label:SetShown(unlocked)
end

local function ApplyPanelPlaceholderLayout(panelId, layoutState)
 local frame = PANEL_PLACEHOLDERS[panelId]
 local slotId = GetAssignedSlot(panelId)
 local definition = PANEL_LAYOUTS[slotId]
 if not frame or not definition then
  return
 end

 EnsureFrameBaseSize(frame)

 local settings = GetPanelSettings(panelId)
 local panelScale = tonumber(settings.scale) or 1
 local widthScale = tonumber(settings.widthScale) or 1
 local heightScale = tonumber(settings.heightScale) or 1
 local position = settings.position or GetAutoLayoutPosition(slotId, layoutState)

 frame:SetScale(1)
 frame:SetSize(frame.mrteBaseWidth * widthScale * panelScale, frame.mrteBaseHeight * heightScale * panelScale)
 frame:ClearAllPoints()
 if MRTE_MainFrame then
  frame:SetPoint(position.point, MRTE_MainFrame, position.relativePoint, position.x, position.y)
 end

 if settings.enabled == false or not IsDetachedPanel(panelId) then
  frame:Hide()
 else
  frame:Show()
 end
end

local function OpenColorPicker(colorKey)
 local settings = MRTE_GetUISettings()
 local color = settings.colors[colorKey] or CopyColorDefaults(colorKey)
 local previous = { r = color[1], g = color[2], b = color[3] }

 local function ApplySelectedColor(red, green, blue)
  settings.colors[colorKey] = { red, green, blue }
  MRTE_ApplyUISettings()
 end

 if not (ColorPickerFrame and ColorPickerFrame.SetupColorPickerAndShow) then
  return
 end

 ColorPickerFrame:SetupColorPickerAndShow({
  r = color[1],
  g = color[2],
  b = color[3],
  hasOpacity = false,
  swatchFunc = function()
   local red, green, blue = ColorPickerFrame:GetColorRGB()
   ApplySelectedColor(red, green, blue)
  end,
  cancelFunc = function(cancelledColor)
   local cancelled = cancelledColor or previous
   ApplySelectedColor(cancelled.r or previous.r, cancelled.g or previous.g, cancelled.b or previous.b)
  end,
 })
end

local function CreateSectionTitle(parent, text, yOffset)
 local title = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
 title:SetPoint("TOPLEFT", 16, yOffset)
 title:SetText(text)
 MRTE_StyleTitle(title, 17)
 return title
end

local function CreateCheckbox(parent, label, x, y, onClick)
 local button = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
 button:SetPoint("TOPLEFT", x, y)
 button.text = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
 button.text:SetPoint("LEFT", button, "RIGHT", 4, 0)
 button.text:SetText(label)
 button:SetScript("OnClick", function(self)
  if onClick then
   onClick(self:GetChecked())
  end
 end)
 return button
end

local function CreateActionButton(parent, text, width, x, y, onClick)
 local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
 button:SetSize(width, 22)
 button:SetPoint("TOPLEFT", x, y)
 button:SetText(text)
 button:SetScript("OnClick", onClick)
 return button
end

local function CreateColorButton(parent, label, x, y, colorKey)
 local labelText = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
 labelText:SetPoint("TOPLEFT", x, y - 4)
 labelText:SetText(label)

 local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
 button:SetSize(110, 22)
 button:SetPoint("TOPLEFT", x + 180, y)
 button:SetText(L.OPTIONS_CHANGE_COLOR)
 button:SetScript("OnClick", function()
  OpenColorPicker(colorKey)
 end)

 button.swatchBorder = CreateFrame("Frame", nil, button, "BackdropTemplate")
 button.swatchBorder:SetSize(20, 14)
 button.swatchBorder:SetPoint("LEFT", 6, 0)
 button.swatchBorder:SetBackdrop({
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
 button.swatchBorder:SetBackdropColor(0.02, 0.02, 0.02, 1)
 button.swatchBorder:SetBackdropBorderColor(0.08, 0.08, 0.08, 1)

 button.swatch = button:CreateTexture(nil, "ARTWORK")
 button.swatch:SetPoint("TOPLEFT", button.swatchBorder, "TOPLEFT", 1, -1)
 button.swatch:SetPoint("BOTTOMRIGHT", button.swatchBorder, "BOTTOMRIGHT", -1, 1)

 OPTIONS_CONTROLS.colorButtons[colorKey] = button
 return button
end

local function FormatSliderValue(value, step)
 local numericValue = tonumber(value) or 0
 local numericStep = tonumber(step) or 0.01

 if numericStep >= 1 then
  return string.format("%d", math.floor(numericValue + 0.5))
 end

 if numericStep >= 0.1 then
  return string.format("%.1f", numericValue)
 end

 return string.format("%.2f", numericValue)
end

local function CreateSlider(parent, label, x, y, width, minValue, maxValue, step, onChanged)
 sliderCounter = sliderCounter + 1
 local sliderName = "MRTE_OptionsSlider" .. sliderCounter
 local slider = CreateFrame("Slider", sliderName, parent, "OptionsSliderTemplate")
 slider:SetPoint("TOPLEFT", x, y)
 slider:SetWidth(width)
 slider:SetMinMaxValues(minValue, maxValue)
 slider:SetValueStep(step)
 slider:SetObeyStepOnDrag(true)
 slider.mrteStep = step

 _G[sliderName .. "Low"]:SetText(FormatSliderValue(minValue, step))
 _G[sliderName .. "High"]:SetText(FormatSliderValue(maxValue, step))
 _G[sliderName .. "Text"]:SetText("")

 slider.label = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
 slider.label:SetPoint("BOTTOMLEFT", slider, "TOPLEFT", 0, 6)
 slider.label:SetText(label)

 slider.valueText = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
 slider.valueText:SetPoint("BOTTOMRIGHT", slider, "TOPRIGHT", 0, 6)
 slider.valueText:SetText("")

 slider:SetScript("OnValueChanged", function(self, value)
  self.valueText:SetText(FormatSliderValue(value, self.mrteStep))
  if self.mrteRefreshing or not onChanged then
   return
  end

  onChanged(value)
 end)

 return slider
end

function MRTE_GetRaidDifficultySettings()
 local settings = MRTE_GetUISettings()
 settings.raidDifficulties = CopyDefaults(settings.raidDifficulties, DEFAULT_UI_SETTINGS.raidDifficulties)
 return settings.raidDifficulties
end

function MRTE_GetUISettings()
 MRTE_GlobalDB = MRTE_GlobalDB or {}
 MRTE_GlobalDB.ui = CopyDefaults(MRTE_GlobalDB.ui, DEFAULT_UI_SETTINGS)
 return MRTE_GlobalDB.ui
end

function MRTE_ArePanelsUnlocked()
 return not not MRTE_GetUISettings().unlockPanels
end

function MRTE_SavePanelPosition(panelId)
 local frame = PANEL_REGISTRY[panelId]
 local parent = IsDetachedPanel(panelId) and UIParent or MRTE_MainFrame
 local settings = GetPanelSettings(panelId)

 if not frame or not parent then
  return
 end

 if not frame:GetLeft() or not frame:GetTop() or not parent:GetLeft() or not parent:GetTop() then
  return
 end

 local parentScale = parent.GetEffectiveScale and parent:GetEffectiveScale() or 1
 if not parentScale or parentScale <= 0 then
  parentScale = 1
 end

 settings.position = {
  point = "TOPLEFT",
  relativePoint = "TOPLEFT",
  x = (frame:GetLeft() - parent:GetLeft()) / parentScale,
  y = (frame:GetTop() - parent:GetTop()) / parentScale,
 }
end

function MRTE_ApplyPanelLayout(panelId, layoutState)
 local frame = PANEL_REGISTRY[panelId]
 local slotId = GetAssignedSlot(panelId)
 local definition = PANEL_LAYOUTS[slotId]
 if not frame or not definition then
  return
 end

 EnsureFrameBaseSize(frame)

 local uiSettings = MRTE_GetUISettings()
 local settings = GetPanelSettings(panelId)
 local detached = IsDetachedPanel(panelId)
 local anchorParent = detached and UIParent or MRTE_MainFrame
 local panelScale = tonumber(settings.scale) or 1
 local widthScale = tonumber(settings.widthScale) or 1
 local heightScale = tonumber(settings.heightScale) or 1
 local globalScale = tonumber(uiSettings.globalScale) or 1
 local effectiveScale = detached and (panelScale * globalScale) or panelScale

 frame:SetMovable(true)
 frame:SetSize(frame.mrteBaseWidth * widthScale, frame.mrteBaseHeight * heightScale)
 frame:SetScale(effectiveScale)

 if not detached and anchorParent then
  local position = settings.position or GetAutoLayoutPosition(slotId, layoutState)
  frame:ClearAllPoints()
  frame:SetPoint(position.point, anchorParent, position.relativePoint, position.x, position.y)
 end

 UpdatePanelHandle(frame)

 if settings.enabled == false then
  frame:Hide()
 else
  frame:Show()
 end

 if panelId == "next_pull" and MRTE_UpdateNextPullPopoutLayout then
  MRTE_UpdateNextPullPopoutLayout()
 end
end

function MRTE_RegisterPanel(panelId, frame)
 if not panelId or not frame then
  return
 end

 EnsureFrameBaseSize(frame)

 PANEL_REGISTRY[panelId] = frame
 frame.mrtePanelId = panelId
 frame:SetClampedToScreen(true)
 frame:SetMovable(true)

 CreatePanelHandle(frame)
 MRTE_ApplyPanelLayout(panelId)
 ApplyPanelPlaceholderLayout(panelId)
end

function MRTE_RegisterPanelPlaceholder(panelId, frame)
 if not panelId or not frame then
  return
 end

 EnsureFrameBaseSize(frame)

 PANEL_PLACEHOLDERS[panelId] = frame
 frame:SetClampedToScreen(true)
 ApplyPanelPlaceholderLayout(panelId)
end

function MRTE_ApplyPanelPlaceholder(panelId)
 ApplyPanelPlaceholderLayout(panelId)
end

local function ResetAllPanels()
 local settings = MRTE_GetUISettings()

 settings.overview.width = MAIN_FRAME_DEFAULTS.width
 settings.overview.height = MAIN_FRAME_DEFAULTS.height
 settings.globalScale = DEFAULT_UI_SETTINGS.globalScale
 settings.unlockPanels = DEFAULT_UI_SETTINGS.unlockPanels

 for _, panelId in ipairs(PANEL_ORDER) do
  settings.panels[panelId] = {
   enabled = DEFAULT_PANEL_ENABLED[panelId] ~= false,
   scale = 1,
   widthScale = 1,
   heightScale = 1,
  }
  settings.layoutSlots[panelId] = panelId
 end
end

local function ResetAllColors()
 local settings = MRTE_GetUISettings()
 settings.colors.accent = CopyColorDefaults("accent")
 settings.colors.panelBackground = CopyColorDefaults("panelBackground")
 settings.colors.panelBorder = CopyColorDefaults("panelBorder")
end

function MRTE_RefreshOptionsControls()
 if not MRTE_OptionsFrame then
  return
 end

 local settings = MRTE_GetUISettings()

 if OPTIONS_CONTROLS.globalScaleSlider then
  OPTIONS_CONTROLS.globalScaleSlider.mrteRefreshing = true
  OPTIONS_CONTROLS.globalScaleSlider:SetValue(settings.globalScale or 1)
  OPTIONS_CONTROLS.globalScaleSlider.mrteRefreshing = false
 end

 if OPTIONS_CONTROLS.overviewWidthSlider then
  OPTIONS_CONTROLS.overviewWidthSlider.mrteRefreshing = true
  OPTIONS_CONTROLS.overviewWidthSlider:SetValue(settings.overview.width or MAIN_FRAME_DEFAULTS.width)
  OPTIONS_CONTROLS.overviewWidthSlider.mrteRefreshing = false
 end

 if OPTIONS_CONTROLS.overviewHeightSlider then
  OPTIONS_CONTROLS.overviewHeightSlider.mrteRefreshing = true
  OPTIONS_CONTROLS.overviewHeightSlider:SetValue(settings.overview.height or MAIN_FRAME_DEFAULTS.height)
  OPTIONS_CONTROLS.overviewHeightSlider.mrteRefreshing = false
 end

 if OPTIONS_CONTROLS.raidDifficultyCheckboxes.normal then
  local raidSettings = MRTE_GetRaidDifficultySettings()
  OPTIONS_CONTROLS.raidDifficultyCheckboxes.normal:SetChecked(not not raidSettings.normal)
  OPTIONS_CONTROLS.raidDifficultyCheckboxes.heroic:SetChecked(not not raidSettings.heroic)
  OPTIONS_CONTROLS.raidDifficultyCheckboxes.mythic:SetChecked(not not raidSettings.mythic)
 end

 if OPTIONS_CONTROLS.unlockCheckbox then
  OPTIONS_CONTROLS.unlockCheckbox:SetChecked(settings.unlockPanels)
 end

 for colorKey, button in pairs(OPTIONS_CONTROLS.colorButtons) do
  UpdateColorButton(button, settings.colors[colorKey] or CopyColorDefaults(colorKey))
 end

 for panelId, row in pairs(OPTIONS_CONTROLS.panelRows) do
  local panelSettings = GetPanelSettings(panelId)

  if row.enabled then
   row.enabled:SetChecked(panelSettings.enabled ~= false)
  end

  if row.scale then
   row.scale.mrteRefreshing = true
   row.scale:SetValue(panelSettings.scale or 1)
   row.scale.mrteRefreshing = false
  end

  if row.widthScale then
   row.widthScale.mrteRefreshing = true
   row.widthScale:SetValue(panelSettings.widthScale or 1)
   row.widthScale.mrteRefreshing = false
  end

  if row.heightScale then
   row.heightScale.mrteRefreshing = true
   row.heightScale:SetValue(panelSettings.heightScale or 1)
   row.heightScale.mrteRefreshing = false
  end

  if row.slotValue then
   row.slotValue:SetText(GetSlotLabel(GetAssignedSlot(panelId)))
  end
 end
end

function MRTE_ApplyUISettings()
 local settings = MRTE_GetUISettings()
 local layoutState = ClampOverviewToLayoutBounds()

 if MRTE_MainFrame then
  MRTE_MainFrame:SetSize(
   tonumber(settings.overview.width) or MAIN_FRAME_DEFAULTS.width,
   tonumber(settings.overview.height) or MAIN_FRAME_DEFAULTS.height
  )
  MRTE_MainFrame:SetScale(tonumber(settings.globalScale) or 1)
 end

 if MRTE_RefreshTheme then
  MRTE_RefreshTheme()
 end

 for _, panelId in ipairs(PANEL_ORDER) do
  MRTE_ApplyPanelLayout(panelId, layoutState)
  ApplyPanelPlaceholderLayout(panelId, layoutState)
 end

 if MRTE_UpdateAdvisorPanel then
  MRTE_UpdateAdvisorPanel()
 end

 MRTE_RefreshOptionsControls()
end

function MRTE_CreateOptionsUI()
 if MRTE_OptionsFrame then
  return MRTE_OptionsFrame
 end

 local frame = CreateFrame("Frame", "MRTE_OptionsFrame", UIParent, "BackdropTemplate")
 frame:SetSize(660, 820)
 frame:SetPoint("CENTER", 40, 0)
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

 frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
 frame.title:SetPoint("TOPLEFT", 16, -12)
 frame.title:SetText(L.OPTIONS_TITLE)
 MRTE_StyleTitle(frame.title, 20)

 frame.closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
 frame.closeButton:SetPoint("TOPRIGHT", -4, -4)

 frame.scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
 frame.scrollFrame:SetPoint("TOPLEFT", 14, -42)
 frame.scrollFrame:SetPoint("BOTTOMRIGHT", -30, 14)

 frame.content = CreateFrame("Frame", nil, frame.scrollFrame)
 frame.content:SetSize(590, 1840)
 frame.scrollFrame:SetScrollChild(frame.content)

 CreateSectionTitle(frame.content, L.OPTIONS_GENERAL, -4)

 OPTIONS_CONTROLS.globalScaleSlider = CreateSlider(
  frame.content,
  L.OPTIONS_GLOBAL_SCALE,
  16,
  -52,
  250,
  0.70,
  1.40,
  0.01,
  function(value)
   MRTE_GetUISettings().globalScale = value
   MRTE_ApplyUISettings()
  end
 )

 OPTIONS_CONTROLS.overviewWidthSlider = CreateSlider(
  frame.content,
  L.OPTIONS_OVERVIEW_WIDTH,
  16,
  -116,
  250,
  960,
  2200,
  10,
  function(value)
   MRTE_GetUISettings().overview.width = math.floor((tonumber(value) or MAIN_FRAME_DEFAULTS.width) + 0.5)
   MRTE_ApplyUISettings()
  end
 )

 OPTIONS_CONTROLS.overviewHeightSlider = CreateSlider(
  frame.content,
  L.OPTIONS_OVERVIEW_HEIGHT,
  300,
  -116,
  250,
  720,
  1600,
  10,
  function(value)
   MRTE_GetUISettings().overview.height = math.floor((tonumber(value) or MAIN_FRAME_DEFAULTS.height) + 0.5)
   MRTE_ApplyUISettings()
  end
 )

 OPTIONS_CONTROLS.unlockCheckbox = CreateCheckbox(
  frame.content,
  L.OPTIONS_UNLOCK_PANELS,
  16,
  -198,
  function(checked)
   MRTE_GetUISettings().unlockPanels = checked and true or false
   MRTE_ApplyUISettings()
  end
 )

 frame.unlockHint = frame.content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
 frame.unlockHint:SetPoint("TOPLEFT", 42, -224)
 frame.unlockHint:SetWidth(520)
 frame.unlockHint:SetJustifyH("LEFT")
 frame.unlockHint:SetText(L.OPTIONS_UNLOCK_HINT)
 MRTE_StyleStatus(frame.unlockHint)
 CreateSectionTitle(frame.content, L.OPTIONS_RAID, -288)

 OPTIONS_CONTROLS.raidDifficultyCheckboxes.normal = CreateCheckbox(
  frame.content,
  L.DIFFICULTY_NORMAL,
  16,
  -322,
  function(checked)
   MRTE_GetRaidDifficultySettings().normal = checked and true or false
   if MRTE_UpdateAdvisorPanel then
    MRTE_UpdateAdvisorPanel()
   end
  end
 )

 OPTIONS_CONTROLS.raidDifficultyCheckboxes.heroic = CreateCheckbox(
  frame.content,
  L.DIFFICULTY_HEROIC,
  156,
  -322,
  function(checked)
   MRTE_GetRaidDifficultySettings().heroic = checked and true or false
   if MRTE_UpdateAdvisorPanel then
    MRTE_UpdateAdvisorPanel()
   end
  end
 )

 OPTIONS_CONTROLS.raidDifficultyCheckboxes.mythic = CreateCheckbox(
  frame.content,
  L.DIFFICULTY_MYTHIC,
  306,
  -322,
  function(checked)
   MRTE_GetRaidDifficultySettings().mythic = checked and true or false
   if MRTE_UpdateAdvisorPanel then
    MRTE_UpdateAdvisorPanel()
   end
  end
 )

 frame.raidHint = frame.content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
 frame.raidHint:SetPoint("TOPLEFT", 42, -352)
 frame.raidHint:SetWidth(520)
 frame.raidHint:SetJustifyH("LEFT")
 frame.raidHint:SetText(L.OPTIONS_RAID_HINT)
 MRTE_StyleStatus(frame.raidHint)

 CreateSectionTitle(frame.content, L.OPTIONS_COLORS, -412)
 CreateColorButton(frame.content, L.OPTIONS_ACCENT_COLOR, 16, -444, "accent")
 CreateColorButton(frame.content, L.OPTIONS_PANEL_BG_COLOR, 16, -480, "panelBackground")
 CreateColorButton(frame.content, L.OPTIONS_PANEL_BORDER_COLOR, 16, -516, "panelBorder")

 CreateActionButton(frame.content, L.OPTIONS_RESET_COLORS, 130, 16, -556, function()
  ResetAllColors()
  MRTE_ApplyUISettings()
 end)

 CreateActionButton(frame.content, L.OPTIONS_RESET_LAYOUT, 150, 160, -556, function()
  ResetAllPanels()
  MRTE_ApplyUISettings()
 end)

 CreateSectionTitle(frame.content, L.OPTIONS_PANELS, -610)

 local rowY = -644
 for _, panelId in ipairs(PANEL_ORDER) do
  local row = {}
  local panelLabel = frame.content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  panelLabel:SetPoint("TOPLEFT", 16, rowY)
  panelLabel:SetText(GetPanelLabel(panelId))
  row.label = panelLabel

  row.enabled = CreateCheckbox(frame.content, L.OPTIONS_PANEL_VISIBLE, 16, rowY - 20, function(checked)
   local panelSettings = GetPanelSettings(panelId)
   panelSettings.enabled = checked and true or false
   MRTE_ApplyUISettings()
  end)

  row.scale = CreateSlider(
   frame.content,
   L.OPTIONS_PANEL_SCALE,
   250,
   rowY - 8,
   220,
   0.70,
   1.40,
   0.01,
   function(value)
    local panelSettings = GetPanelSettings(panelId)
    panelSettings.scale = value
    MRTE_ApplyUISettings()
   end
  )

  row.widthScale = CreateSlider(
   frame.content,
   L.OPTIONS_PANEL_WIDTH,
   250,
   rowY - 52,
   220,
   0.70,
   1.50,
   0.01,
   function(value)
    local panelSettings = GetPanelSettings(panelId)
    panelSettings.widthScale = value
    MRTE_ApplyUISettings()
   end
  )

  row.heightScale = CreateSlider(
   frame.content,
   L.OPTIONS_PANEL_HEIGHT,
   250,
   rowY - 96,
   220,
   0.70,
   1.50,
   0.01,
   function(value)
    local panelSettings = GetPanelSettings(panelId)
    panelSettings.heightScale = value
    MRTE_ApplyUISettings()
   end
  )

  row.slotText = frame.content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  row.slotText:SetPoint("TOPLEFT", 16, rowY - 144)
  row.slotText:SetText(L.OPTIONS_PANEL_SLOT)

  row.slotPrev = CreateActionButton(frame.content, "<", 24, 130, rowY - 138, function()
   CyclePanelSlot(panelId, -1)
   MRTE_ApplyUISettings()
  end)

  row.slotValue = CreateActionButton(frame.content, "", 164, 160, rowY - 138, function()
   CyclePanelSlot(panelId, 1)
   MRTE_ApplyUISettings()
  end)

  row.slotNext = CreateActionButton(frame.content, ">", 24, 330, rowY - 138, function()
   CyclePanelSlot(panelId, 1)
   MRTE_ApplyUISettings()
  end)

  row.reset = CreateActionButton(frame.content, L.OPTIONS_RESET_PANEL, 70, 492, rowY - 138, function()
   local panelSettings = GetPanelSettings(panelId)
   panelSettings.enabled = DEFAULT_UI_SETTINGS.panels[panelId].enabled ~= false
   panelSettings.scale = 1
   panelSettings.widthScale = 1
   panelSettings.heightScale = 1
   panelSettings.position = nil
   SetPanelSlot(panelId, panelId)
   MRTE_ApplyUISettings()
   MRTE_RefreshOptionsControls()
  end)

  OPTIONS_CONTROLS.panelRows[panelId] = row
  rowY = rowY - 196
 end

 frame.content:SetHeight(math.abs(rowY) + 40)
 frame:Hide()

 MRTE_OptionsFrame = frame
 MRTE_RefreshOptionsControls()
 return frame
end

function MRTE_OpenOptionsWindow()
 if not MRTE_OptionsFrame then
  MRTE_CreateOptionsUI()
 end

 if not MRTE_OptionsFrame then
  return
 end

 MRTE_RefreshOptionsControls()
 MRTE_OptionsFrame:Show()
 if MRTE_OptionsFrame.Raise then
  MRTE_OptionsFrame:Raise()
 end
end














