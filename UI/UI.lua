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

function MRTE_CreateMainUI()
 local frame = CreateFrame("Frame", "MRTE_MainFrame", UIParent, "BackdropTemplate")
 local logoIconPath = string.format("Interface\\AddOns\\%s\\Assets\\Branding\\account-hub-icon", addonName or "Account-HUB")
 frame:SetSize(1020, 780)
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
  frame.mrteTopShade:SetColorTexture(0.15, 0.10, 0.03, 0.30)
 end

 frame.headerShade = frame:CreateTexture(nil, "ARTWORK", nil, -1)
 frame.headerShade:SetTexture("Interface/Buttons/WHITE8X8")
 frame.headerShade:SetPoint("TOPLEFT", 2, -2)
 frame.headerShade:SetPoint("TOPRIGHT", -2, -2)
 frame.headerShade:SetHeight(82)
 frame.headerShade:SetColorTexture(0.05, 0.04, 0.02, 0.28)

 if frame.mrteTitleLine then
  frame.mrteTitleLine:ClearAllPoints()
  frame.mrteTitleLine:Hide()
 end

 frame.closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
 frame.closeButton:SetPoint("TOPRIGHT", -6, -6)
 frame.closeButton:SetSize(28, 28)

 frame.logoGlow = frame:CreateTexture(nil, "ARTWORK", nil, -1)
 frame.logoGlow:SetSize(74, 74)
 frame.logoGlow:SetPoint("TOP", 0, -5)
 frame.logoGlow:SetTexture(logoIconPath)
 frame.logoGlow:SetVertexColor(1, 0.84, 0.28, 0.16)

 frame.headerLineLeft = frame:CreateTexture(nil, "BORDER")
 frame.headerLineLeft:SetTexture("Interface/Buttons/WHITE8X8")
 frame.headerLineLeft:SetHeight(1)
 frame.headerLineLeft:SetPoint("LEFT", frame, "TOPLEFT", 20, -44)
 frame.headerLineLeft:SetPoint("RIGHT", frame, "TOP", -52, -44)
 frame.headerLineLeft:SetColorTexture(0.78, 0.64, 0.19, 0.52)

 frame.headerLineRight = frame:CreateTexture(nil, "BORDER")
 frame.headerLineRight:SetTexture("Interface/Buttons/WHITE8X8")
 frame.headerLineRight:SetHeight(1)
 frame.headerLineRight:SetPoint("LEFT", frame, "TOP", 52, -44)
 frame.headerLineRight:SetPoint("RIGHT", frame, "TOPRIGHT", -20, -44)
 frame.headerLineRight:SetColorTexture(0.78, 0.64, 0.19, 0.52)

 frame.headerLineLeftSoft = frame:CreateTexture(nil, "BACKGROUND")
 frame.headerLineLeftSoft:SetTexture("Interface/Buttons/WHITE8X8")
 frame.headerLineLeftSoft:SetHeight(3)
 frame.headerLineLeftSoft:SetPoint("LEFT", frame, "TOPLEFT", 20, -44)
 frame.headerLineLeftSoft:SetPoint("RIGHT", frame, "TOP", -70, -44)
 frame.headerLineLeftSoft:SetColorTexture(0.32, 0.24, 0.08, 0.18)

 frame.headerLineRightSoft = frame:CreateTexture(nil, "BACKGROUND")
 frame.headerLineRightSoft:SetTexture("Interface/Buttons/WHITE8X8")
 frame.headerLineRightSoft:SetHeight(3)
 frame.headerLineRightSoft:SetPoint("LEFT", frame, "TOP", 70, -44)
 frame.headerLineRightSoft:SetPoint("RIGHT", frame, "TOPRIGHT", -20, -44)
 frame.headerLineRightSoft:SetColorTexture(0.32, 0.24, 0.08, 0.18)

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

 frame:Hide()
 MRTE_MainFrame = frame
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

