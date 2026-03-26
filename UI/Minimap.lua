local addonName = ...

function MRTE_CreateMinimapButton()
 if _G.MRTE_MinimapButton then
  return _G.MRTE_MinimapButton
 end

 local texturePath = string.format("Interface\\AddOns\\%s\\Assets\\Branding\\account-hub-icon", addonName or "Account-HUB")
 local btn = CreateFrame("Button", "MRTE_MinimapButton", Minimap)
 btn:SetSize(34, 34)
 btn:SetFrameStrata("MEDIUM")
 btn:SetPoint("TOPLEFT", Minimap, "TOPLEFT", -4, 4)
 btn:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

 local icon = btn:CreateTexture(nil, "ARTWORK")
 icon:SetAllPoints()
 icon:SetTexture(texturePath)
 btn.icon = icon

 local pushed = btn:CreateTexture(nil, "BACKGROUND")
 pushed:SetAllPoints()
 pushed:SetTexture(texturePath)
 pushed:SetVertexColor(0.82, 0.82, 0.82, 1)
 btn:SetPushedTexture(pushed)

 btn:SetScript("OnEnter", function(self)
  GameTooltip:SetOwner(self, "ANCHOR_LEFT")
  GameTooltip:AddLine((MRTE_L and MRTE_L.ADDON_TITLE) or "Account-HUB", 1.00, 0.86, 0.10)
  GameTooltip:AddLine("/hub", 0.82, 0.82, 0.82)
  GameTooltip:Show()
 end)

 btn:SetScript("OnLeave", function()
  GameTooltip_Hide()
 end)

 btn:SetScript("OnClick", function()
  SlashCmdList["ACCOUNTHUB"]()
 end)

 return btn
end

