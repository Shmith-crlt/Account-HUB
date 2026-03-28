local addonName = ...
local L = MRTE_L

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

local function GetThemeColorSet()
 return MRTE_GetThemeColors and MRTE_GetThemeColors() or {
  accent = { 1.00, 0.86, 0.10 },
  panelBackground = { 0.04, 0.04, 0.05 },
  panelBorder = { 0.25, 0.20, 0.10 },
 }
end

function MRTE_ApplyMainFrameTheme()
 local frame = MRTE_MainFrame
 if not frame then
  return
 end

 local theme = GetThemeColorSet()
 local accent = theme.accent or { 1.00, 0.86, 0.10 }
 local panelBackground = theme.panelBackground or { 0.04, 0.04, 0.05 }

 if frame.headerShade then
  frame.headerShade:SetColorTexture(panelBackground[1] * 0.65, panelBackground[2] * 0.65, math.max(0.03, panelBackground[3] * 0.80), 0.34)
 end

 if frame.logoGlow then
  frame.logoGlow:SetVertexColor(accent[1], accent[2], accent[3], 0.18)
 end

 if frame.headerLineLeft then
  frame.headerLineLeft:SetColorTexture(accent[1], accent[2], accent[3], 0.58)
 end

 if frame.headerLineRight then
  frame.headerLineRight:SetColorTexture(accent[1], accent[2], accent[3], 0.58)
 end

 if frame.headerLineLeftSoft then
  frame.headerLineLeftSoft:SetColorTexture(accent[1] * 0.40, accent[2] * 0.34, accent[3] * 0.25, 0.20)
 end

 if frame.headerLineRightSoft then
  frame.headerLineRightSoft:SetColorTexture(accent[1] * 0.40, accent[2] * 0.34, accent[3] * 0.25, 0.20)
 end

 if frame.status then
  MRTE_StyleStatus(frame.status)
 end
end

function MRTE_CreateMainUI()
 local frame = CreateFrame("Frame", "MRTE_MainFrame", UIParent, "BackdropTemplate")
 local logoIconPath = string.format("Interface\\AddOns\\%s\\Assets\\Branding\\account-hub-icon", addonName or "Account-HUB")
 frame:SetSize(1020, 780)
 frame.mrteBaseWidth = 1020
 frame.mrteBaseHeight = 780
 frame:SetPoint("CENTER")
 frame:SetFrameStrata("DIALOG")
 frame:SetClampedToScreen(true)
 frame:SetMovable(true)
 frame:EnableMouse(true)
 frame:RegisterForDrag("LeftButton")

 frame:SetScript("OnDragStart", frame.StartMoving)
 frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

 MRTE_Style(frame, "main")
 RegisterForEscape(frame)

 if frame.mrteTopShade then
  frame.mrteTopShade:ClearAllPoints()
  frame.mrteTopShade:SetPoint("TOPLEFT", 2, -2)
  frame.mrteTopShade:SetPoint("TOPRIGHT", -2, -2)
  frame.mrteTopShade:SetHeight(78)
 end

 frame.headerShade = frame:CreateTexture(nil, "ARTWORK", nil, -1)
 frame.headerShade:SetTexture("Interface/Buttons/WHITE8X8")
 frame.headerShade:SetPoint("TOPLEFT", 2, -2)
 frame.headerShade:SetPoint("TOPRIGHT", -2, -2)
 frame.headerShade:SetHeight(82)

 if frame.mrteTitleLine then
  frame.mrteTitleLine:ClearAllPoints()
  frame.mrteTitleLine:Hide()
 end

 frame.closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
 frame.closeButton:SetPoint("TOPRIGHT", -6, -6)
 frame.closeButton:SetSize(28, 28)

 frame.optionsButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
 frame.optionsButton:SetSize(90, 22)
 frame.optionsButton:SetPoint("TOPLEFT", 18, -10)
 frame.optionsButton:SetText(L.OPTIONS_BUTTON)
 frame.optionsButton:SetScript("OnClick", function()
  if MRTE_OpenOptionsWindow then
   MRTE_OpenOptionsWindow()
  end
 end)

 frame.advisorButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
 frame.advisorButton:SetSize(90, 22)
 frame.advisorButton:SetPoint("LEFT", frame.optionsButton, "RIGHT", 8, 0)
 frame.advisorButton:SetText(L.ADVISOR_BUTTON)
 frame.advisorButton:SetScript("OnClick", function()
  if MRTE_OpenAdvisorWindow then
   MRTE_OpenAdvisorWindow()
  end
 end)

 frame.logoGlow = frame:CreateTexture(nil, "ARTWORK", nil, -1)
 frame.logoGlow:SetSize(74, 74)
 frame.logoGlow:SetPoint("TOP", 0, -5)
 frame.logoGlow:SetTexture(logoIconPath)

 frame.headerLineLeft = frame:CreateTexture(nil, "BORDER")
 frame.headerLineLeft:SetTexture("Interface/Buttons/WHITE8X8")
 frame.headerLineLeft:SetHeight(1)
 frame.headerLineLeft:SetPoint("LEFT", frame, "TOPLEFT", 20, -44)
 frame.headerLineLeft:SetPoint("RIGHT", frame, "TOP", -52, -44)

 frame.headerLineRight = frame:CreateTexture(nil, "BORDER")
 frame.headerLineRight:SetTexture("Interface/Buttons/WHITE8X8")
 frame.headerLineRight:SetHeight(1)
 frame.headerLineRight:SetPoint("LEFT", frame, "TOP", 52, -44)
 frame.headerLineRight:SetPoint("RIGHT", frame, "TOPRIGHT", -20, -44)

 frame.headerLineLeftSoft = frame:CreateTexture(nil, "BACKGROUND")
 frame.headerLineLeftSoft:SetTexture("Interface/Buttons/WHITE8X8")
 frame.headerLineLeftSoft:SetHeight(3)
 frame.headerLineLeftSoft:SetPoint("LEFT", frame, "TOPLEFT", 20, -44)
 frame.headerLineLeftSoft:SetPoint("RIGHT", frame, "TOP", -70, -44)

 frame.headerLineRightSoft = frame:CreateTexture(nil, "BACKGROUND")
 frame.headerLineRightSoft:SetTexture("Interface/Buttons/WHITE8X8")
 frame.headerLineRightSoft:SetHeight(3)
 frame.headerLineRightSoft:SetPoint("LEFT", frame, "TOP", 70, -44)
 frame.headerLineRightSoft:SetPoint("RIGHT", frame, "TOPRIGHT", -20, -44)

 frame.logoMark = frame:CreateTexture(nil, "ARTWORK")
 frame.logoMark:SetSize(56, 56)
 frame.logoMark:SetPoint("TOP", 0, -10)
 frame.logoMark:SetTexture(logoIconPath)

 frame.logoWordmark = frame:CreateTexture(nil, "ARTWORK")
 frame.logoWordmark:SetSize(1, 1)
 frame.logoWordmark:SetPoint("TOPLEFT", 0, 0)
 frame.logoWordmark:SetTexture(nil)
 frame.logoWordmark:Hide()

 frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
 frame.title:SetPoint("TOP", 0, -8)
 frame.title:SetText("")
 MRTE_StyleTitle(frame.title, 24)
 frame.title:Hide()

 frame.status = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
 frame.status:SetPoint("BOTTOM", 0, 60)
 frame.status:SetWidth(640)
 frame.status:SetJustifyH("CENTER")
 frame.status:SetText("")
 MRTE_StyleStatus(frame.status)

 MRTE_MainFrame = frame
 MRTE_ApplyMainFrameTheme()
 frame:Hide()
end

function MRTE_SetStatus(text)
 if MRTE_MainFrame and MRTE_MainFrame.status then
  MRTE_MainFrame.status:SetText(text or "")
 end
end

local function PrintHubMessage(text)
 print((L.ADDON_TITLE or "Account-HUB") .. ": " .. text)
end

local function CallSafely(func, ...)
 if type(func) ~= "function" then
  return false
 end

 return pcall(func, ...)
end

local function ShowUIPanelSafely(frame)
 if frame and type(ShowUIPanel) == "function" then
  local ok = pcall(ShowUIPanel, frame)
  if ok and frame.IsShown and frame:IsShown() then
   return true
  end
 end

 if frame and type(frame.Show) == "function" then
  local ok = pcall(frame.Show, frame)
  if ok then
   return true
  end
 end

 return false
end

function MRTE_OpenMythicPlusUI()
 if type(PVEFrame_LoadUI) == "function" then
  CallSafely(PVEFrame_LoadUI)
 end

 if not ChallengesFrame and type(UIParentLoadAddOn) == "function" then
  CallSafely(UIParentLoadAddOn, "Blizzard_ChallengesUI")
 end

 if type(PVEFrame_ShowFrame) == "function" then
  local ok = pcall(PVEFrame_ShowFrame, "ChallengesFrame")
  if ok and (not ChallengesFrame or (ChallengesFrame.IsShown and ChallengesFrame:IsShown())) then
   return true
  end
 end

 if ShowUIPanelSafely(ChallengesFrame) then
  return true
 end

 MRTE_SetStatus(L.ERROR_OPEN_MYTHIC)
 PrintHubMessage(L.ERROR_OPEN_MYTHIC)
 return false
end

function MRTE_OpenGreatVaultUI()
 if type(UIParentLoadAddOn) == "function" then
  CallSafely(UIParentLoadAddOn, "Blizzard_WeeklyRewards")
 end

 if type(WeeklyRewards_ShowUI) == "function" then
  local ok = pcall(WeeklyRewards_ShowUI)
  if ok then
   return true
  end
 end

 if ShowUIPanelSafely(WeeklyRewardsFrame) then
  return true
 end

 MRTE_SetStatus(L.ERROR_OPEN_VAULT)
 PrintHubMessage(L.ERROR_OPEN_VAULT)
 return false
end

function MRTE_OpenMDTUI()
 if type(MDT) ~= "table" then
  MRTE_SetStatus(L.MDT_NOT_LOADED)
  PrintHubMessage(L.MDT_NOT_LOADED)
  return false
 end

 if type(MDT.Async) == "function" and type(MDT.ShowInterfaceInternal) == "function" then
  local ok = pcall(MDT.Async, MDT, function()
   MDT:ShowInterfaceInternal()
  end, "showInterface")

  if ok then
   return true
  end
 end

 if type(MDT.ShowInterfaceInternal) == "function" and pcall(MDT.ShowInterfaceInternal, MDT) then
  return true
 end

 if type(MDT.OpenInterface) == "function" and pcall(MDT.OpenInterface, MDT) then
  return true
 end

 if MDT.main_frame and ShowUIPanelSafely(MDT.main_frame) then
  return true
 end

 MRTE_SetStatus(L.ERROR_OPEN_MDT)
 PrintHubMessage(L.ERROR_OPEN_MDT)
 return false
end

local function ToggleMainFrame()
 if not MRTE_MainFrame then
  return
 end

 if MRTE_MainFrame:IsShown() then
  MRTE_MainFrame:Hide()
 else
  MRTE_MainFrame:Show()
  if MRTE_IsViewingCurrentCharacter and not MRTE_IsViewingCurrentCharacter() then
   local profile = MRTE_GetSelectedCharacterProfile and MRTE_GetSelectedCharacterProfile()
   local displayName = profile and (profile.displayName or profile.name) or ""
   MRTE_SetStatus(MRTE_T("VIEWING_CHARACTER", displayName))
  else
   MRTE_SetStatus("")
  end
 end
end

local function HandleOverlaySlashCommand(action)
 action = strlower(strtrim(action or ""))

 if action == "" or action == "toggle" then
  if MRTE_ToggleNextPullDetached then
   MRTE_ToggleNextPullDetached()
  else
   MRTE_ToggleMDTOverlay()
  end
  return
 end

 if action == "refresh" then
  if MRTE_RefreshNextPullPanel then
   MRTE_RefreshNextPullPanel(true, true)
  else
   MRTE_RefreshMDTOverlay(true, true)
  end
  return
 end

 if action == "on" or action == "detach" or action == "popout" then
  if MRTE_SetNextPullDetached then
   MRTE_SetNextPullDetached(true, true)
  else
   MRTE_SetMDTOverlayEnabled(true, true)
  end
  return
 end

 if action == "off" or action == "dock" or action == "embed" then
  if MRTE_SetNextPullDetached then
   MRTE_SetNextPullDetached(false, true)
  else
   MRTE_SetMDTOverlayEnabled(false, true)
  end
  return
 end

 print(L.SLASH_OVERLAY_HELP)
 MRTE_SetStatus(L.UNKNOWN_OVERLAY_COMMAND)
end

SLASH_ACCOUNTHUB1 = "/hub"

SlashCmdList["ACCOUNTHUB"] = function(msg)
 msg = strtrim(msg or "")

 if msg == "" then
  ToggleMainFrame()
  return
 end

 local command, rest = msg:match("^(%S+)%s*(.*)$")
 command = command and strlower(command) or ""

 if command == "options" or command == "config" or command == "settings" then
  if MRTE_OpenOptionsWindow then
   MRTE_OpenOptionsWindow()
   return
  end
 end

 if command == "advisor" or command == "plan" or command == "guide" then
  if MRTE_MainFrame and not MRTE_MainFrame:IsShown() then
   MRTE_MainFrame:Show()
  end

  if MRTE_OpenAdvisorWindow then
   MRTE_OpenAdvisorWindow()
   return
  end
 end

 if command == "pull" or command == "nextpull" or command == "overlay" then
  HandleOverlaySlashCommand(rest)
  return
 end

 if command == "ksl" or command == "keystoneloot" or command == "bisimport" then
  if MRTE_OpenRaidbotsImport then
   MRTE_OpenRaidbotsImport()
   return
  end
 end

 print(L.SLASH_HELP)
 MRTE_SetStatus(L.UNKNOWN_COMMAND)
end




