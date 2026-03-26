local L = MRTE_L

local function NormalizeGuildMemberName(name)
 if type(name) ~= "string" or name == "" then
  return nil
 end

 if Ambiguate then
  return strlower(Ambiguate(name, "short") or name)
 end

 return strlower((name:match("^[^-]+") or name))
end

MRTE_NormalizeGuildMemberName = NormalizeGuildMemberName

local function GetDisplayGuildMemberName(name)
 if type(name) ~= "string" or name == "" then
  return L.UNKNOWN
 end

 if Ambiguate then
  return Ambiguate(name, "short") or name
 end

 return name:match("^[^-]+") or name
end

local function RequestGuildRosterUpdate()
 if C_GuildInfo and C_GuildInfo.GuildRoster then
  C_GuildInfo.GuildRoster()
 elseif GuildRoster then
  GuildRoster()
 end
end

MRTE_RequestGuildRosterUpdate = RequestGuildRosterUpdate

local function GetGuildClassColor(classFileName)
 local classColors = CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS
 local color = classColors and classFileName and classColors[classFileName]
 return color or NORMAL_FONT_COLOR
end

local function TruncateGuildLabel(text, maxLength)
 text = text or ""
 if #text <= maxLength then
  return text
 end

 return text:sub(1, maxLength - 3) .. "..."
end

local function GetGuildKeyLabel(entry)
 local keyLevel = tonumber(entry and entry.keyLevel) or 0
 local keyMapID = tonumber(entry and entry.keyMapID) or 0

 if keyLevel < 0 then
  return L.KEY_HIDDEN
 end

 if keyLevel <= 0 or keyMapID <= 0 then
  return L.NO_KEY
 end

 local dungeonName = C_ChallengeMode and C_ChallengeMode.GetMapUIInfo and C_ChallengeMode.GetMapUIInfo(keyMapID)
 if type(dungeonName) == "string" and dungeonName ~= "" then
  return "+" .. keyLevel .. " " .. TruncateGuildLabel(dungeonName, 12)
 end

 return "+" .. keyLevel
end

local function BuildOnlineGuildEntries()
 local entries = {}
 local guildData = (MRTE_GlobalDB and MRTE_GlobalDB.guild) or {}

 for _, entry in pairs(guildData) do
  if type(entry) == "table" and entry.online then
   entries[#entries + 1] = entry
  end
 end

 table.sort(entries, function(a, b)
  local leftLevel = tonumber(a.keyLevel) or 0
  local rightLevel = tonumber(b.keyLevel) or 0

  if leftLevel ~= rightLevel then
   return leftLevel > rightLevel
  end

  return (a.displayName or a.name or "") < (b.displayName or b.name or "")
 end)

 return entries
end

function MRTE_ShowGuildMemberTooltip(row)
 local memberData = row and row.memberData
 if not memberData then
  return
 end

 local classColor = GetGuildClassColor(memberData.classFileName)
 local keyLevel = tonumber(memberData.keyLevel) or 0
 local keyMapID = tonumber(memberData.keyMapID) or 0
 local dungeonName = keyMapID > 0 and C_ChallengeMode and C_ChallengeMode.GetMapUIInfo and C_ChallengeMode.GetMapUIInfo(keyMapID) or nil

 GameTooltip:SetOwner(row, "ANCHOR_RIGHT")
 GameTooltip:ClearLines()
 GameTooltip:AddLine(memberData.displayName or memberData.name or L.GUILD_MEMBER, classColor.r, classColor.g, classColor.b)

 if memberData.class then
  GameTooltip:AddDoubleLine(L.CLASS, memberData.class, 0.82, 0.82, 0.82, 1, 1, 1)
 end

 if keyLevel < 0 then
  GameTooltip:AddDoubleLine(L.KEY, L.KEY_HIDDEN, 0.82, 0.82, 0.82, 1, 0.82, 0.20)
 elseif keyLevel > 0 and keyMapID > 0 then
  GameTooltip:AddDoubleLine(L.KEY, "+" .. keyLevel, 0.82, 0.82, 0.82, 1, 1, 1)
  if dungeonName then
   GameTooltip:AddDoubleLine(L.DUNGEON, dungeonName, 0.82, 0.82, 0.82, 1, 1, 1)
  end
 else
  GameTooltip:AddDoubleLine(L.KEY, L.NO_KEY_REPORTED, 0.82, 0.82, 0.82, 0.68, 0.68, 0.68)
 end

 GameTooltip:Show()
end

local function ApplyGuildRowStyle(row, entry)
 if not row or not entry then
  return
 end

 local classCoords = entry.classFileName and CLASS_ICON_TCOORDS and CLASS_ICON_TCOORDS[entry.classFileName]
 local classColor = GetGuildClassColor(entry.classFileName)

 row.memberData = entry
 row.name:SetText(entry.displayName or GetDisplayGuildMemberName(entry.name))
 row.name:SetTextColor(classColor.r, classColor.g, classColor.b)
 row.key:SetText(GetGuildKeyLabel(entry))

 if classCoords then
  row.classIcon:SetTexCoord(classCoords[1], classCoords[2], classCoords[3], classCoords[4])
  row.classIcon:SetDesaturated(false)
 else
  row.classIcon:SetTexCoord(0, 1, 0, 1)
  row.classIcon:SetDesaturated(true)
 end

 if (tonumber(entry.keyLevel) or 0) > 0 then
  row:SetBackdropColor(0.09, 0.12, 0.17, 0.92)
  row:SetBackdropBorderColor(0.25, 0.38, 0.60, 1)
  row.key:SetTextColor(0.85, 0.92, 1.00)
  return
 end

 row:SetBackdropColor(0.08, 0.08, 0.08, 0.92)
 row:SetBackdropBorderColor(0.20, 0.16, 0.10, 1)
 row.key:SetTextColor(0.72, 0.72, 0.72)
end

function MRTE_UpdateGuildPanel()
 if not MRTE_GuildPanel or not MRTE_GuildPanel.rows or not MRTE_GuildPanel.content then
  return
 end

 local entries = BuildOnlineGuildEntries()

 if #entries == 0 then
  MRTE_GuildPanel.emptyText:Show()
  MRTE_GuildPanel.content:SetHeight(1)

  for _, row in ipairs(MRTE_GuildPanel.rows) do
   row.memberData = nil
   row:Hide()
  end

  return
 end

 MRTE_GuildPanel.emptyText:Hide()
 MRTE_GuildPanel.content:SetHeight(math.max(#entries * 28, 1))

 for index, row in ipairs(MRTE_GuildPanel.rows) do
  local entry = entries[index]

  if entry then
   ApplyGuildRowStyle(row, entry)
   row:Show()
  else
   row.memberData = nil
   row:Hide()
  end
 end
end

local guildFrame = CreateFrame("Frame")
guildFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
guildFrame:RegisterEvent("PLAYER_GUILD_UPDATE")
guildFrame:RegisterEvent("GUILD_ROSTER_UPDATE")
guildFrame:SetScript("OnEvent", function(_, event)
 MRTE_GlobalDB.guild = MRTE_GlobalDB.guild or {}

 if event ~= "GUILD_ROSTER_UPDATE" then
  RequestGuildRosterUpdate()
  return
 end

 if not IsInGuild or not IsInGuild() then
  for _, entry in pairs(MRTE_GlobalDB.guild) do
   if type(entry) == "table" then
    entry.online = false
   end
  end

  if MRTE_UpdateGuildPanel then
   MRTE_UpdateGuildPanel()
  end

  return
 end

 local seenMembers = {}

 for index = 1, GetNumGuildMembers() do
  local name, _, _, _, classDisplayName, _, _, _, online, _, classFileName = GetGuildRosterInfo(index)
  local memberKey = NormalizeGuildMemberName(name)

  if memberKey then
   local entry = MRTE_GlobalDB.guild[memberKey] or {}
   entry.name = name
   entry.displayName = GetDisplayGuildMemberName(name)
   entry.class = classDisplayName
   entry.classFileName = classFileName
   entry.online = online and true or false

   MRTE_GlobalDB.guild[memberKey] = entry
   seenMembers[memberKey] = true
  end
 end

 for key, entry in pairs(MRTE_GlobalDB.guild) do
  if type(entry) == "table" and not seenMembers[key] then
   entry.online = false
  end
 end

 if MRTE_UpdateGuildPanel then
  MRTE_UpdateGuildPanel()
 end
end)
