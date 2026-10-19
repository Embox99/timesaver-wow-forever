-- Group invites, resurrections and summons from friends/guild; declining duels,
-- guild invites and trades from strangers. "Trusted" = friend, Battle.net
-- friend or guild member.
local _, ns = ...
local L = ns.L

local function IsTrustedGUID(guid)
    if C_FriendList.IsFriend(guid) then return true end
    if IsGuildMember(guid) then return true end
    if C_BattleNet and C_BattleNet.GetGameAccountInfoByGUID
        and C_BattleNet.GetGameAccountInfoByGUID(guid) then
        return true
    end
    return false
end

local function IsTrustedName(name)
    local short = Ambiguate(name, "none")
    if C_FriendList.GetFriendInfo(short) then return true end
    if IsInGuild() then
        for i = 1, GetNumGuildMembers() do
            local member = GetGuildRosterInfo(i)
            if member and Ambiguate(member, "none") == short then return true end
        end
    end
    return false
end

-- true / false, or nil when the game would not tell us (e.g. protected
-- values): then the addon does nothing and leaves the choice to you.
local function Trusted(name, guid)
    local ok, result = pcall(function()
        if guid and IsTrustedGUID(guid) then return true end
        if name and IsTrustedName(name) then return true end
        return false
    end)
    if ok then return result end
    return nil
end

-- Blizzard shows its own dialog for the same event, possibly after us,
-- so dialogs are closed on the next frame. popups: one name or a list.
local function HideLater(popups, frame)
    if type(popups) ~= "table" then popups = { popups } end
    C_Timer.After(0, function()
        for _, popup in ipairs(popups) do StaticPopup_Hide(popup) end
        if frame and frame:IsShown() then frame:Hide() end
    end)
end

-- keep the guild roster fresh for name lookups
ns.On("PLAYER_ENTERING_WORLD", function()
    if IsInGuild() and C_GuildInfo and C_GuildInfo.GuildRoster then
        C_GuildInfo.GuildRoster()
    end
end)

ns.On("PARTY_INVITE_REQUEST", function(name, _, _, _, _, _, guid)
    if not ns.db.acceptInvites then return end
    if Trusted(name, guid) == true then
        AcceptGroup()
        HideLater("PARTY_INVITE")
        ns.Print(string.format(L.ACCEPTED_INVITE, name))
    end
end)

-- resurrection cast on you by a friend or guild member
ns.On("RESURRECT_REQUEST", function(name)
    if not ns.db.acceptRes then return end
    if Trusted(name) == true then
        AcceptResurrect()
        HideLater({ "RESURRECT", "RESURRECT_NO_SICKNESS", "RESURRECT_NO_TIMER" })
        ns.Print(string.format(L.ACCEPTED_RES, name))
    end
end)

-- summon (warlock ritual, meeting stone) by a friend or guild member;
-- the game doesn't allow accepting a summon in combat
ns.On("CONFIRM_SUMMON", function()
    if not ns.db.acceptRes or UnitAffectingCombat("player") then return end
    local info = C_SummonInfo
    local getSummoner = info and info.GetSummonConfirmSummoner or GetSummonConfirmSummoner
    local confirm = info and info.ConfirmSummon or ConfirmSummon
    if not getSummoner or not confirm then return end
    local name = getSummoner()
    if name and Trusted(name) == true then
        confirm()
        HideLater("CONFIRM_SUMMON")
        ns.Print(string.format(L.ACCEPTED_SUMMON, name))
    end
end)

ns.On("DUEL_REQUESTED", function(name)
    if not ns.db.declineDuels then return end
    if Trusted(name) == false then
        CancelDuel()
        HideLater("DUEL_REQUESTED")
        ns.Print(string.format(L.DECLINED_DUEL, name))
    end
end)

ns.On("GUILD_INVITE_REQUEST", function(inviter, guildName)
    if not ns.db.declineGuild then return end
    if Trusted(inviter) == false then
        DeclineGuild()
        HideLater("GUILD_INVITE", GuildInviteFrame)
        ns.Print(string.format(L.DECLINED_GUILD, inviter, guildName or "?"))
    end
end)

-- A trade window opens both when someone trades us and when we trade them.
-- Trades we start ourselves (InitiateTrade) are never cancelled.
local lastOwnTrade = 0
if InitiateTrade then
    hooksecurefunc("InitiateTrade", function()
        lastOwnTrade = GetTime()
    end)
end

ns.On("TRADE_SHOW", function()
    if not ns.db.declineTrades or GetTime() - lastOwnTrade < 5 then return end
    local name = UnitName("NPC")
    if Trusted(name, UnitGUID("NPC")) == false then
        CancelTrade()
        ns.Print(string.format(L.DECLINED_TRADE, name or "?"))
    end
end)
