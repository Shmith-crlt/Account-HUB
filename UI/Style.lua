local function EnsureTexture(frame, key, layer, subLevel)
 if frame[key] then
  return frame[key]
 end

 local texture = frame:CreateTexture(nil, layer, nil, subLevel or 0)
 texture:SetTexture("Interface/Buttons/WHITE8X8")
 frame[key] = texture
 return texture
end

function MRTE_Style(frame, variant)
 variant = variant or "panel"

 local edgeSize = variant == "main" and 2 or 1
 local borderColor
 local backgroundColor
 local shadeColor
 local lineAlpha

 if variant == "main" then
  borderColor = { 0.44, 0.36, 0.16, 1 }
  backgroundColor = { 0.02, 0.02, 0.03, 0.95 }
  shadeColor = { 0.12, 0.09, 0.03, 0.24 }
  lineAlpha = 0.55
 else
  borderColor = { 0.25, 0.20, 0.10, 1 }
  backgroundColor = { 0.04, 0.04, 0.05, 0.96 }
  shadeColor = { 0.12, 0.09, 0.03, 0.15 }
  lineAlpha = 0.32
 end

 frame:SetBackdrop({
  bgFile = "Interface/Buttons/WHITE8X8",
  edgeFile = "Interface/Buttons/WHITE8X8",
  edgeSize = edgeSize,
  insets = {
   left = edgeSize,
   right = edgeSize,
   top = edgeSize,
   bottom = edgeSize,
  },
 })
 frame:SetBackdropColor(backgroundColor[1], backgroundColor[2], backgroundColor[3], backgroundColor[4])
 frame:SetBackdropBorderColor(borderColor[1], borderColor[2], borderColor[3], borderColor[4])

 local innerBackground = EnsureTexture(frame, "mrteInnerBackground", "BACKGROUND", -8)
 innerBackground:SetPoint("TOPLEFT", edgeSize, -edgeSize)
 innerBackground:SetPoint("BOTTOMRIGHT", -edgeSize, edgeSize)
 innerBackground:SetColorTexture(0.01, 0.01, 0.02, variant == "main" and 0.26 or 0.14)

 local topShade = EnsureTexture(frame, "mrteTopShade", "BACKGROUND", -7)
 topShade:SetPoint("TOPLEFT", edgeSize + 1, -(edgeSize + 1))
 topShade:SetPoint("TOPRIGHT", -(edgeSize + 1), -(edgeSize + 1))
 topShade:SetHeight(24)
 topShade:SetColorTexture(shadeColor[1], shadeColor[2], shadeColor[3], shadeColor[4])

 local titleLine = EnsureTexture(frame, "mrteTitleLine", "BORDER", 0)
 titleLine:SetPoint("TOPLEFT", 12, -32)
 titleLine:SetPoint("TOPRIGHT", -12, -32)
 titleLine:SetHeight(1)
 titleLine:SetColorTexture(0.78, 0.64, 0.19, lineAlpha)
end

function MRTE_StyleTitle(fontString, size)
 if not fontString then
  return
 end

 fontString:SetFont(STANDARD_TEXT_FONT, size or 18, "OUTLINE")
 fontString:SetTextColor(1.00, 0.86, 0.10)
 fontString:SetShadowColor(0, 0, 0, 0.95)
 fontString:SetShadowOffset(1, -1)
end

function MRTE_StyleStatus(fontString)
 if not fontString then
  return
 end

 fontString:SetFont(STANDARD_TEXT_FONT, 12, "")
 fontString:SetTextColor(0.82, 0.80, 0.74)
 fontString:SetShadowColor(0, 0, 0, 0.90)
 fontString:SetShadowOffset(1, -1)
end
