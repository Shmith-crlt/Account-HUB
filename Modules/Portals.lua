local L = MRTE_L

local PORTAL_UNLOCK_LEVEL = 10

local DUNGEON_PORTALS = {
 [161] = { 1254557, 159898 },
 [168] = { 159901 },
 [198] = { 424163 },
 [199] = { 424153 },
 [200] = { 393764 },
 [206] = { 410078 },
 [210] = { 393766 },
 [227] = { 373262 },
 [234] = { 373262 },
 [239] = { 1254551 },
 [244] = { 424187 },
 [245] = { 410071 },
 [247] = { 467553, 467555 },
 [248] = { 424167 },
 [251] = { 410074 },
 [353] = { 445418, 464256 },
 [370] = { 373274 },
 [375] = { 354464 },
 [376] = { 354462 },
 [378] = { 354465 },
 [382] = { 354467 },
 [391] = { 367416 },
 [392] = { 367416 },
 [399] = { 393256 },
 [400] = { 393262 },
 [401] = { 393279 },
 [402] = { 393273 },
 [403] = { 393222 },
 [404] = { 393276 },
 [405] = { 393267 },
 [406] = { 393283 },
 [438] = { 410080 },
 [456] = { 424142 },
 [463] = { 424197 },
 [464] = { 424197 },
 [499] = { 445444 },
 [500] = { 445443 },
 [501] = { 445269 },
 [502] = { 445416 },
 [503] = { 445417 },
 [504] = { 445441 },
 [505] = { 445414 },
 [506] = { 445440 },
 [507] = { 445424 },
 [525] = { 1216786 },
 [542] = { 1237215 },
 [556] = { 1254555 },
 [557] = { 1254400 },
 [558] = { 1254572 },
 [559] = { 1254563 },
 [560] = { 1254559 },
 [583] = { 1254551 },
}

local pendingPortalRefresh = false

local function IsPortalSpellKnown(spellID)
 if not spellID then
  return false
 end

 if C_SpellBook then
  if C_SpellBook.IsSpellInSpellBook and C_SpellBook.IsSpellInSpellBook(spellID) then
   return true
  end

  if C_SpellBook.IsSpellKnown and C_SpellBook.IsSpellKnown(spellID) then
   return true
  end
 end

 if IsSpellKnown and IsSpellKnown(spellID) then
  return true
 end

 if IsPlayerSpell and IsPlayerSpell(spellID) then
  return true
 end

 return false
end

local function GetKnownPortalSpellID(challengeMapID)
 local spellIDs = DUNGEON_PORTALS[challengeMapID]
 if not spellIDs then
  return nil
 end

 for _, spellID in ipairs(spellIDs) do
  if IsPortalSpellKnown(spellID) then
   return spellID
  end
 end
end

local function ComparePortalNames(a, b)
 local left = a and a.name or ""
 local right = b and b.name or ""

 if strcmputf8i then
  return strcmputf8i(left, right) < 0
 end

 return left < right
end

local function GetSeasonPortals()
 local portals = {}

 if not C_ChallengeMode or not C_ChallengeMode.GetMapTable or not C_ChallengeMode.GetMapUIInfo then
  return portals
 end

 local challengeMaps = C_ChallengeMode.GetMapTable()
 if type(challengeMaps) ~= "table" then
  return portals
 end

 for _, challengeMapID in ipairs(challengeMaps) do
  local dungeonName, _, _, dungeonTexture = C_ChallengeMode.GetMapUIInfo(challengeMapID)
  local knownTeleportSpellID = GetKnownPortalSpellID(challengeMapID)
  portals[#portals + 1] = {
   challengeMapID = challengeMapID,
   name = dungeonName or (L.DUNGEON .. " " .. challengeMapID),
   texture = dungeonTexture,
   teleports = DUNGEON_PORTALS[challengeMapID],
   knownTeleportSpellID = knownTeleportSpellID,
   isUnlocked = knownTeleportSpellID and true or false,
  }
 end

 table.sort(portals, ComparePortalNames)

 return portals
end

local function SetPortalButtonSpell(button, spellID)
 if not button or InCombatLockdown() then
  pendingPortalRefresh = true
  return
 end

 if spellID then
  button:SetAttribute("type", "spell")
  button:SetAttribute("spell", spellID)
  return
 end

 button:SetAttribute("type", nil)
 button:SetAttribute("spell", nil)
end

local function ApplyPortalButtonStyle(button, portalData)
 if not button then
  return
 end

 button.portalData = portalData
 button.icon:SetTexture((portalData and portalData.texture) or 134400)
 button.text:SetText((portalData and portalData.name) or "")

 if portalData and (portalData.knownTeleportSpellID or portalData.isUnlocked) then
  button:SetBackdropColor(0.13, 0.21, 0.13, 0.95)
  button:SetBackdropBorderColor(0.31, 0.62, 0.31, 1)
  button.text:SetTextColor(0.86, 1.00, 0.86)
  SetPortalButtonSpell(button, portalData.knownTeleportSpellID)
  button:Show()
  return
 end

 if portalData and portalData.teleports then
  button:SetBackdropColor(0.09, 0.09, 0.09, 0.95)
  button:SetBackdropBorderColor(0.52, 0.39, 0.18, 1)
  button.text:SetTextColor(0.92, 0.84, 0.70)
 else
  button:SetBackdropColor(0.07, 0.07, 0.07, 0.95)
  button:SetBackdropBorderColor(0.25, 0.25, 0.25, 1)
  button.text:SetTextColor(0.68, 0.68, 0.68)
 end

 SetPortalButtonSpell(button, nil)
 button:Show()
end

function MRTE_ShowSeasonPortalTooltip(button)
 local portalData = button and button.portalData
 if not portalData then
  return
 end

 GameTooltip:SetOwner(button, "ANCHOR_RIGHT")

 if portalData.knownTeleportSpellID and GameTooltip.SetSpellByID then
  GameTooltip:SetSpellByID(portalData.knownTeleportSpellID)
  GameTooltip:AddLine(" ")
  GameTooltip:AddLine(L.CLICK_TO_TELEPORT, GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)

  local title = GameTooltip:GetName() and _G[GameTooltip:GetName() .. "TextLeft1"]
  if title and portalData.name then
   title:SetText(portalData.name)
  end
 elseif portalData.isUnlocked then
  GameTooltip:ClearLines()
  GameTooltip:AddLine(portalData.name or L.DUNGEON, 1, 1, 1)
  GameTooltip:AddLine(L.OPEN, GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
 else
  GameTooltip:ClearLines()
  GameTooltip:AddLine(portalData.name or L.DUNGEON, 1, 1, 1)

  if portalData.teleports and #portalData.teleports > 0 then
   GameTooltip:AddLine(L.PORTAL_NOT_UNLOCKED, 1.00, 0.82, 0.20)
   GameTooltip:AddLine(MRTE_T("PORTAL_UNLOCK_HINT", PORTAL_UNLOCK_LEVEL), 1, 1, 1, true)
  else
   GameTooltip:AddLine(L.NO_PORTAL_MAPPING, 1, 0.4, 0.4, true)
  end
 end

 GameTooltip:Show()
end

local function BuildLiveSeasonPortalData()
 local portals = GetSeasonPortals()
 local knownCount = 0

 for _, portalData in ipairs(portals) do
  if portalData.knownTeleportSpellID then
   knownCount = knownCount + 1
  end
 end

 return {
  portals = portals,
  knownCount = knownCount,
 }
end

local function BuildSeasonPortalSnapshot(liveData)
 local snapshot = MRTE_CopyTable and MRTE_CopyTable(liveData) or liveData

 if type(snapshot.portals) == "table" then
  for _, portalData in ipairs(snapshot.portals) do
   portalData.isUnlocked = portalData.isUnlocked or (portalData.knownTeleportSpellID and true or false)
   portalData.knownTeleportSpellID = nil
  end
 end

 return snapshot
end

local function GetDisplaySeasonPortalData(liveData)
 if MRTE_SaveCharacterSection then
  MRTE_SaveCharacterSection("portals", BuildSeasonPortalSnapshot(liveData))
 end

 if not MRTE_IsViewingCurrentCharacter or MRTE_IsViewingCurrentCharacter() then
  return liveData
 end

 local profile = MRTE_GetSelectedCharacterProfile and MRTE_GetSelectedCharacterProfile()
 if profile and type(profile.portals) == "table" then
  return profile.portals
 end

 return {
  portals = {},
  knownCount = 0,
 }
end

function MRTE_UpdateSeasonPortals()
 if not MRTE_SeasonPortalsPanel or not MRTE_SeasonPortalsPanel.buttons then
  return
 end

 local liveData = BuildLiveSeasonPortalData()
 local displayData = GetDisplaySeasonPortalData(liveData)
 local portals = type(displayData.portals) == "table" and displayData.portals or {}
 local knownCount = tonumber(displayData.knownCount) or 0

 MRTE_SeasonPortalsPanel.title:SetText(L.PANEL_SEASON_PORTALS)

 if #portals == 0 then
  MRTE_SeasonPortalsPanel.emptyText:SetText(L.NO_SEASON_DUNGEONS_FOUND)
  MRTE_SeasonPortalsPanel.emptyText:Show()

  for _, button in ipairs(MRTE_SeasonPortalsPanel.buttons) do
   button.portalData = nil
   SetPortalButtonSpell(button, nil)
   button:Hide()
  end

  return
 end

 MRTE_SeasonPortalsPanel.emptyText:Hide()

 for index, button in ipairs(MRTE_SeasonPortalsPanel.buttons) do
  local portalData = portals[index]

  if portalData then
   ApplyPortalButtonStyle(button, portalData)
  else
   button.portalData = nil
   SetPortalButtonSpell(button, nil)
   button:Hide()
  end
 end

 MRTE_SeasonPortalsPanel.title:SetText(MRTE_T("PANEL_SEASON_PORTALS_COUNT", knownCount, #portals))
end

local portalEvents = CreateFrame("Frame")
portalEvents:RegisterEvent("PLAYER_ENTERING_WORLD")
portalEvents:RegisterEvent("CHALLENGE_MODE_MAPS_UPDATE")
portalEvents:RegisterEvent("SPELLS_CHANGED")
portalEvents:RegisterEvent("PLAYER_REGEN_ENABLED")
portalEvents:SetScript("OnEvent", function(_, event)
 if event == "PLAYER_REGEN_ENABLED" then
  if not pendingPortalRefresh then
   return
  end

  pendingPortalRefresh = false
 end

 if MRTE_UpdateSeasonPortals then
  MRTE_UpdateSeasonPortals()
 end
end)
