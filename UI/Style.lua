local DEFAULT_THEME = {
 accent = { 1.00, 0.86, 0.10 },
 panelBackground = { 0.04, 0.04, 0.05 },
 panelBorder = { 0.25, 0.20, 0.10 },
}

local styledFrames = {}
local styledTitles = {}
local styledStatuses = {}
local styledFonts = {}

local function EnsureTexture(frame, key, layer, subLevel)
 if frame[key] then
  return frame[key]
 end

 local texture = frame:CreateTexture(nil, layer, nil, subLevel or 0)
 texture:SetTexture("Interface/Buttons/WHITE8X8")
 frame[key] = texture
 return texture
end

local function TrackStyledObject(registry, object, meta)
 if not object then
  return
 end

 for _, entry in ipairs(registry) do
  if entry.object == object then
   entry.meta = meta
   return
  end
 end

 registry[#registry + 1] = {
  object = object,
  meta = meta,
 }
end

local function UnpackColor(color, fallback)
 local source = color or fallback or DEFAULT_THEME.accent
 return source[1] or source.r or 1, source[2] or source.g or 1, source[3] or source.b or 1
end

local function GetSharedMediaLibrary()
 if type(LibStub) ~= "function" then
  return nil
 end

 return LibStub("LibSharedMedia-3.0", true)
end

local BUILTIN_MEDIA = {
 font = {
  { name = "Default", path = STANDARD_TEXT_FONT },
  { name = "Friz Quadrata", path = "Fonts\\FRIZQT__.TTF" },
  { name = "Arial Narrow", path = "Fonts\\ARIALN.TTF" },
  { name = "Morpheus", path = "Fonts\\MORPHEUS.TTF" },
  { name = "Skurri", path = "Fonts\\skurri.ttf" },
  { name = "Damage", path = DAMAGE_TEXT_FONT or "Fonts\\MORPHEUS.TTF" },
  { name = "Nameplate", path = NAMEPLATE_FONT or STANDARD_TEXT_FONT },
  { name = "Unit Name", path = UNIT_NAME_FONT or STANDARD_TEXT_FONT },
 },
 statusbar = {
  { name = "Default", path = "Interface/Buttons/WHITE8X8" },
  { name = "StatusBar", path = "Interface/TargetingFrame/UI-StatusBar" },
  { name = "Raid", path = "Interface/RaidFrame/Raid-Bar-Hp-Fill" },
  { name = "Raid Dark", path = "Interface/RaidFrame/Raid-Bar-Hp-Bg" },
  { name = "Tooltip", path = "Interface/Tooltips/UI-Tooltip-Background" },
  { name = "Dialog Dark", path = "Interface/DialogFrame/UI-DialogBox-Background-Dark" },
  { name = "Skill Bar", path = "Interface/PaperDollInfoFrame/UI-Character-Skills-Bar" },
 },
}

local function GetBuiltinMediaPath(mediaType, name)
 for _, entry in ipairs(BUILTIN_MEDIA[mediaType] or {}) do
  if entry.name == name then
   return entry.path
  end
 end

 return nil
end

function MRTE_HasSharedMedia()
 return GetSharedMediaLibrary() ~= nil
end

function MRTE_GetSharedMediaNames(mediaType)
 local names = {}
 local seen = {}

 for _, entry in ipairs(BUILTIN_MEDIA[mediaType] or {}) do
  if entry.name and not seen[entry.name] then
   names[#names + 1] = entry.name
   seen[entry.name] = true
  end
 end

 local lsm = GetSharedMediaLibrary()
 if not lsm then
  return names
 end

 local listed = lsm:List(mediaType) or {}
 for _, name in ipairs(listed) do
  if name and name ~= "" and not seen[name] then
   names[#names + 1] = name
   seen[name] = true
  end
 end

 return names
end

function MRTE_GetFontPath()
 return STANDARD_TEXT_FONT
end

function MRTE_GetPanelTexturePath()
 return "Interface/Buttons/WHITE8X8"
end

function MRTE_SetFont(fontString, size, flags)
 if not fontString then
  return
 end

 TrackStyledObject(styledFonts, fontString, {
  size = size or 12,
  flags = flags or "",
 })

 fontString:SetFont(MRTE_GetFontPath(), size or 12, flags or "")
end

function MRTE_GetThemeColors()
 local settings = MRTE_GetUISettings and MRTE_GetUISettings() or nil
 local colors = settings and settings.colors or nil

 return {
  accent = colors and colors.accent or DEFAULT_THEME.accent,
  panelBackground = colors and colors.panelBackground or DEFAULT_THEME.panelBackground,
  panelBorder = colors and colors.panelBorder or DEFAULT_THEME.panelBorder,
 }
end

local function ApplyFrameStyle(frame, variant)
 if not frame then
  return
 end

 variant = variant or "panel"

 local theme = MRTE_GetThemeColors()
 local accentR, accentG, accentB = UnpackColor(theme.accent, DEFAULT_THEME.accent)
 local bgR, bgG, bgB = UnpackColor(theme.panelBackground, DEFAULT_THEME.panelBackground)
 local borderR, borderG, borderB = UnpackColor(theme.panelBorder, DEFAULT_THEME.panelBorder)
 local texturePath = MRTE_GetPanelTexturePath()

 local edgeSize = variant == "main" and 2 or 1
 local backgroundAlpha = variant == "main" and 0.95 or 0.96
 local innerAlpha = variant == "main" and 0.26 or 0.14
 local shadeAlpha = variant == "main" and 0.24 or 0.15
 local lineAlpha = variant == "main" and 0.60 or 0.34

 local appliedBgR = bgR
 local appliedBgG = bgG
 local appliedBgB = bgB
 local appliedBorderR = borderR
 local appliedBorderG = borderG
 local appliedBorderB = borderB

 if variant == "main" then
  appliedBgR = math.max(0.01, bgR * 0.55)
  appliedBgG = math.max(0.01, bgG * 0.55)
  appliedBgB = math.max(0.02, bgB * 0.65)
  appliedBorderR = math.max(borderR, accentR * 0.55)
  appliedBorderG = math.max(borderG, accentG * 0.55)
  appliedBorderB = math.max(borderB, accentB * 0.55)
 end

 frame:SetBackdrop({
  bgFile = texturePath,
  edgeFile = "Interface/Buttons/WHITE8X8",
  edgeSize = edgeSize,
  insets = {
   left = edgeSize,
   right = edgeSize,
   top = edgeSize,
   bottom = edgeSize,
  },
 })
 frame:SetBackdropColor(appliedBgR, appliedBgG, appliedBgB, backgroundAlpha)
 frame:SetBackdropBorderColor(appliedBorderR, appliedBorderG, appliedBorderB, 1)

 local innerBackground = EnsureTexture(frame, "mrteInnerBackground", "BACKGROUND", -8)
 innerBackground:SetTexture(texturePath)
 innerBackground:SetPoint("TOPLEFT", edgeSize, -edgeSize)
 innerBackground:SetPoint("BOTTOMRIGHT", -edgeSize, edgeSize)
 innerBackground:SetVertexColor(0.01, 0.01, 0.02, innerAlpha)

 local topShade = EnsureTexture(frame, "mrteTopShade", "BACKGROUND", -7)
 topShade:SetTexture(texturePath)
 topShade:SetPoint("TOPLEFT", edgeSize + 1, -(edgeSize + 1))
 topShade:SetPoint("TOPRIGHT", -(edgeSize + 1), -(edgeSize + 1))
 topShade:SetHeight(24)
 topShade:SetVertexColor(accentR * 0.30, accentG * 0.24, accentB * 0.18, shadeAlpha)

 local titleLine = EnsureTexture(frame, "mrteTitleLine", "BORDER", 0)
 titleLine:SetTexture("Interface/Buttons/WHITE8X8")
 titleLine:SetPoint("TOPLEFT", 12, -32)
 titleLine:SetPoint("TOPRIGHT", -12, -32)
 titleLine:SetHeight(1)
 titleLine:SetColorTexture(accentR, accentG, accentB, lineAlpha)
end

local function ApplyTitleStyle(fontString, size)
 if not fontString then
  return
 end

 local theme = MRTE_GetThemeColors()
 local accentR, accentG, accentB = UnpackColor(theme.accent, DEFAULT_THEME.accent)

 fontString:SetFont(MRTE_GetFontPath(), size or 18, "OUTLINE")
 fontString:SetTextColor(accentR, accentG, accentB)
 fontString:SetShadowColor(0, 0, 0, 0.95)
 fontString:SetShadowOffset(1, -1)
end

local function ApplyStatusStyle(fontString)
 if not fontString then
  return
 end

 fontString:SetFont(MRTE_GetFontPath(), 12, "")
 fontString:SetTextColor(0.82, 0.80, 0.74)
 fontString:SetShadowColor(0, 0, 0, 0.90)
 fontString:SetShadowOffset(1, -1)
end

local function ApplyFontToRegion(region)
 if not region or region:GetObjectType() ~= "FontString" then
  return
 end

 local _, size, flags = region:GetFont()
 region:SetFont(MRTE_GetFontPath(), size or 12, flags or "")
end

local function ApplyFontToFrameTree(frame, visited)
 if not frame or (visited and visited[frame]) then
  return
 end

 visited = visited or {}
 visited[frame] = true

 if frame.GetRegions then
  for _, region in ipairs({ frame:GetRegions() }) do
   ApplyFontToRegion(region)
  end
 end

 if frame.GetChildren then
  for _, child in ipairs({ frame:GetChildren() }) do
   ApplyFontToFrameTree(child, visited)
  end
 end
end

function MRTE_Style(frame, variant)
 TrackStyledObject(styledFrames, frame, variant or "panel")
 ApplyFrameStyle(frame, variant)
end

function MRTE_StyleTitle(fontString, size)
 TrackStyledObject(styledTitles, fontString, size or 18)
 ApplyTitleStyle(fontString, size)
end

function MRTE_StyleStatus(fontString)
 TrackStyledObject(styledStatuses, fontString, true)
 ApplyStatusStyle(fontString)
end

function MRTE_RefreshTheme()
 local visited = {}

 for _, entry in ipairs(styledFrames) do
  if entry.object then
   ApplyFrameStyle(entry.object, entry.meta)
   ApplyFontToFrameTree(entry.object, visited)
  end
 end

 for _, entry in ipairs(styledTitles) do
  if entry.object then
   ApplyTitleStyle(entry.object, entry.meta)
  end
 end

 for _, entry in ipairs(styledStatuses) do
  if entry.object then
   ApplyStatusStyle(entry.object)
  end
 end

 for _, entry in ipairs(styledFonts) do
  if entry.object then
   entry.object:SetFont(MRTE_GetFontPath(), entry.meta.size or 12, entry.meta.flags or "")
  end
 end

 if MRTE_ApplyMainFrameTheme then
  MRTE_ApplyMainFrameTheme()
 end
end






