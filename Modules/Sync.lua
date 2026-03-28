local lastSentKeyLevel = nil
local lastSentKeyMapID = nil
local lastSentRating = nil

if C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix then
 C_ChatInfo.RegisterAddonMessagePrefix("LibKS")
end

local function GetOwnGuildMemberName()
 return GetUnitName and GetUnitName("player", true)
end

local function GetActiveGroupChannel()
 if IsInGroup and LE_PARTY_CATEGORY_INSTANCE and IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
  return "INSTANCE_CHAT"
 end

 if IsInRaid and IsInRaid() then
  return "RAID"
 end

 if IsInGroup and IsInGroup() then
  return "PARTY"
 end
end

local function IsGroupChannel(channel)
 return channel == "PARTY" or channel == "RAID" or channel == "INSTANCE_CHAT"
end

local function GetOwnKeystoneData()
 local keyLevel = C_MythicPlus and C_MythicPlus.GetOwnedKeystoneLevel and C_MythicPlus.GetOwnedKeystoneLevel() or 0
 local keyMapID = C_MythicPlus and C_MythicPlus.GetOwnedKeystoneChallengeMapID and C_MythicPlus.GetOwnedKeystoneChallengeMapID() or 0
 local ratingSummary = C_PlayerInfo and C_PlayerInfo.GetPlayerMythicPlusRatingSummary and C_PlayerInfo.GetPlayerMythicPlusRatingSummary("player")
 local playerRating = ratingSummary and ratingSummary.currentSeasonScore or 0

 if type(keyLevel) ~= "number" then
  keyLevel = 0
 end

 if type(keyMapID) ~= "number" then
  keyMapID = 0
 end

 if type(playerRating) ~= "number" then
  playerRating = 0
 end

 return keyLevel, keyMapID, playerRating
end

local function UpsertGroupKeystone(sender, keyLevel, keyMapID, playerRating)
 MRTE_CharDB.groupKeys = MRTE_CharDB.groupKeys or {}

 local memberKey = MRTE_NormalizeGuildMemberName and MRTE_NormalizeGuildMemberName(sender)
 if not memberKey then
  return
 end

 local entry = MRTE_CharDB.groupKeys[memberKey] or {}
 entry.name = entry.name or sender
 entry.displayName = entry.displayName or (Ambiguate and Ambiguate(sender, "short") or sender)
 entry.keyLevel = tonumber(keyLevel) or 0
 entry.keyMapID = tonumber(keyMapID) or 0
 entry.rating = tonumber(playerRating) or 0
 entry.lastSync = GetTime and GetTime() or 0

 MRTE_CharDB.groupKeys[memberKey] = entry

 if MRTE_UpdateMythicPanel then
  MRTE_UpdateMythicPanel()
 end
 if MRTE_UpdateAdvisorPanel then
  MRTE_UpdateAdvisorPanel()
 end
end

local function UpsertGuildKeystone(sender, keyLevel, keyMapID, playerRating)
 MRTE_GlobalDB.guild = MRTE_GlobalDB.guild or {}

 local memberKey = MRTE_NormalizeGuildMemberName and MRTE_NormalizeGuildMemberName(sender)
 if not memberKey then
  return
 end

 local entry = MRTE_GlobalDB.guild[memberKey] or {}
 entry.name = entry.name or sender
 entry.displayName = entry.displayName or (Ambiguate and Ambiguate(sender, "short") or sender)
 entry.keyLevel = tonumber(keyLevel) or 0
 entry.keyMapID = tonumber(keyMapID) or 0
 entry.rating = tonumber(playerRating) or 0
 entry.lastSync = GetTime and GetTime() or 0

 MRTE_GlobalDB.guild[memberKey] = entry

 if MRTE_UpdateGuildPanel then
  MRTE_UpdateGuildPanel()
 end
end

local function PruneGroupKeystones()
 MRTE_CharDB.groupKeys = MRTE_CharDB.groupKeys or {}

 local activeMembers = {}

 local function MarkUnit(unit)
  if not UnitExists or not UnitExists(unit) or not GetUnitName then
   return
  end

  local memberKey = MRTE_NormalizeGuildMemberName and MRTE_NormalizeGuildMemberName(GetUnitName(unit, true))
  if memberKey then
   activeMembers[memberKey] = true
  end
 end

 MarkUnit("player")

 if IsInRaid and IsInRaid() then
  for index = 1, GetNumGroupMembers() do
   MarkUnit("raid" .. index)
  end
 elseif IsInGroup and IsInGroup() then
  for index = 1, GetNumSubgroupMembers() do
   MarkUnit("party" .. index)
  end
 end

 local changed = false

 for memberKey in pairs(MRTE_CharDB.groupKeys) do
  if not activeMembers[memberKey] then
   MRTE_CharDB.groupKeys[memberKey] = nil
   changed = true
  end
 end

 if changed and MRTE_UpdateMythicPanel then
  MRTE_UpdateMythicPanel()
 end
 if changed and MRTE_UpdateAdvisorPanel then
  MRTE_UpdateAdvisorPanel()
 end
end

local function UpdateOwnKeystoneCaches(keyLevel, keyMapID, playerRating)
 local playerName = GetOwnGuildMemberName()
 if not playerName then
  return
 end

 if IsInGuild and IsInGuild() then
  UpsertGuildKeystone(playerName, keyLevel, keyMapID, playerRating)
 end

 UpsertGroupKeystone(playerName, keyLevel, keyMapID, playerRating)
end

local function SendOwnKeystoneToChannel(channel, force)
 if not channel or not C_ChatInfo or not C_ChatInfo.SendAddonMessage then
  return
 end

 local keyLevel, keyMapID, playerRating = GetOwnKeystoneData()
 if force or keyLevel ~= lastSentKeyLevel or keyMapID ~= lastSentKeyMapID or playerRating ~= lastSentRating then
  lastSentKeyLevel = keyLevel
  lastSentKeyMapID = keyMapID
  lastSentRating = playerRating
 end

 C_ChatInfo.SendAddonMessage("LibKS", string.format("%d,%d,%d", keyLevel, keyMapID, playerRating), channel)
 UpdateOwnKeystoneCaches(keyLevel, keyMapID, playerRating)
end

local function BroadcastOwnKeystone(force)
 if not C_ChatInfo or not C_ChatInfo.SendAddonMessage then
  return
 end

 local keyLevel, keyMapID, playerRating = GetOwnKeystoneData()
 if not force and keyLevel == lastSentKeyLevel and keyMapID == lastSentKeyMapID and playerRating == lastSentRating then
  UpdateOwnKeystoneCaches(keyLevel, keyMapID, playerRating)
  return
 end

 lastSentKeyLevel = keyLevel
 lastSentKeyMapID = keyMapID
 lastSentRating = playerRating

 if IsInGuild and IsInGuild() then
  C_ChatInfo.SendAddonMessage("LibKS", string.format("%d,%d,%d", keyLevel, keyMapID, playerRating), "GUILD")
 end

 local groupChannel = GetActiveGroupChannel()
 if groupChannel then
  C_ChatInfo.SendAddonMessage("LibKS", string.format("%d,%d,%d", keyLevel, keyMapID, playerRating), groupChannel)
 end

 UpdateOwnKeystoneCaches(keyLevel, keyMapID, playerRating)
end

local function RequestGuildKeystones()
 if not IsInGuild or not IsInGuild() or not C_ChatInfo or not C_ChatInfo.SendAddonMessage then
  return
 end

 C_ChatInfo.SendAddonMessage("LibKS", "R", "GUILD")
end

local function RequestGroupKeystones()
 local groupChannel = GetActiveGroupChannel()
 if not groupChannel or not C_ChatInfo or not C_ChatInfo.SendAddonMessage then
  return
 end

 C_ChatInfo.SendAddonMessage("LibKS", "R", groupChannel)
end

local syncFrame = CreateFrame("Frame")
syncFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
syncFrame:RegisterEvent("PLAYER_GUILD_UPDATE")
syncFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
syncFrame:RegisterEvent("BAG_UPDATE_DELAYED")
syncFrame:RegisterEvent("CHALLENGE_MODE_COMPLETED")
syncFrame:RegisterEvent("CHAT_MSG_ADDON")
syncFrame:SetScript("OnEvent", function(_, event, prefix, message, channel, sender)
 if event == "CHAT_MSG_ADDON" then
  if prefix ~= "LibKS" or (channel ~= "GUILD" and not IsGroupChannel(channel)) then
   return
  end

  if message == "R" then
   SendOwnKeystoneToChannel(channel, true)
   return
  end

  local keyLevel, keyMapID, playerRating = string.match(message or "", "^(-?%d+),(-?%d+),(-?%d+)$")
  if keyLevel and keyMapID and sender then
   if channel == "GUILD" then
    UpsertGuildKeystone(sender, keyLevel, keyMapID, playerRating)
   else
    UpsertGroupKeystone(sender, keyLevel, keyMapID, playerRating)
   end
  end

  return
 end

 if event == "GROUP_ROSTER_UPDATE" then
  PruneGroupKeystones()
 end

 if event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_GUILD_UPDATE" or event == "GROUP_ROSTER_UPDATE" then
  if MRTE_RequestGuildRosterUpdate and IsInGuild and IsInGuild() then
   MRTE_RequestGuildRosterUpdate()
  end

  if C_Timer and C_Timer.After then
   C_Timer.After(1, function()
    RequestGuildKeystones()
    RequestGroupKeystones()
    BroadcastOwnKeystone(true)
   end)
  else
   RequestGuildKeystones()
   RequestGroupKeystones()
   BroadcastOwnKeystone(true)
  end

  return
 end

 BroadcastOwnKeystone(false)
end)


