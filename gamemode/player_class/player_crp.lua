DEFINE_BASECLASS("player_default")

local PLAYER = {}
PLAYER.rank = nil
PLAYER.currentTool = nil

if SERVER then
    util.AddNetworkString("SetRank")
    util.AddNetworkString("RequestRank")
    util.AddNetworkString("SetCurrentTool")
    util.AddNetworkString("RequestCurrentTool")

    net.Receive("RequestRank", function (len, ply)
        local tar = player.GetBySteamID64(net.ReadString())
        if tar == nil then
            return
        end

        local reqRank = rank.Get(player_manager.RunClass(ply, "GetRank"))
        if reqRank == nil then
            return
        end

        if !reqRank.permissions.canEditPlayerRank then
            return
        end

        player_manager.RunClass(tar, "SetRank", net.ReadString())
    end)

    net.Receive("RequestCurrentTool", function (len, ply)
        local tar = player.GetBySteamID64(net.ReadString())
        if tar == nil then
            return
        end

        player_manager.RunClass(tar, "SetCurrentTool", net.ReadString())
    end)
end

if CLIENT then
    net.Receive("SetRank", function (len, ply)
        PLAYER.rank = net.ReadString()
    end)

    net.Receive("SetCurrentTool", function (len, ply)
        local t = tool.Get(net.ReadString())
        if t == nil then
            return
        end

        PLAYER.currentTool = t
    end)
end

function PLAYER:SetRank(name)
    if SERVER then
        if !rank.Exists(name) then
            return
        end

        self.rank = name

        net.Start("SetRank")
        net.WriteString(name)
        net.Send(self.Player)

        self:Save()
    end

    if CLIENT then
        net.Start("RequestRank")
        net.WriteString(self.Player:SteamID64())
        net.WriteString(name)
        net.SendToServer()
    end
end

function PLAYER:GetRank()
    return self.rank
end

function PLAYER:SetCurrentTool(name)
    if SERVER then
        local t = tool.Get(name)
        if t == nil then
            return
        end

        self.currentTool = t

        net.Start("SetCurrentTool")
        net.WriteString(name)
        net.Send(self.Player)

        --self:Save()
    end

    if CLIENT then
        net.Start("RequestCurrentTool")
        net.WriteString(self.Player:SteamID64())
        net.WriteString(name)
        net.SendToServer()
    end
end

function PLAYER:GetCurrentTool()
    return self.currentTool
end

function PLAYER:Save()
    local output = nil
    local path = "complexrp/localplayer.txt"

    file.CreateDir("complexrp")

    if SERVER then
        output = util.TableToJSON({
            rank = self.rank
        })

        file.CreateDir("complexrp/players")

        path = "complexrp/players/" .. self.Player:SteamID64() .. ".txt"
    end

    if CLIENT then
        output = util.TableToJSON({
            currentTool = self.currentTool
        })

        return
    end

    if !file.Exists(path, "DATA") then
        file.Write(path, "")
    end

    local playerFile = file.Open(path, "w", "DATA")
    playerFile:Write(output)
    playerFile:Flush()
    playerFile:Close()
end

function PLAYER:Load()
    local path = "complexrp/localplayer.txt"

    if SERVER then
        file.CreateDir("complexrp/players")

        path = "complexrp/players/" .. self.Player:SteamID64() .. ".txt"
    end

    if CLIENT then
        return
    end

    local plyFile = file.Open("complexrp/localplayer.txt", "r", "DATA")
    if plyFile == nil then
        return
    end

    local plyData = util.JSONToTable(plyFile:Read(plyFile:Size()))
    plyFile:Close()

    if SERVER then
        self:SetRank(plyData.rank)
    end

    if CLIENT then
        self:SetCurrentTool(plyData.currentTool)
    end
end

player_manager.RegisterClass("player_crp", PLAYER, "player_default")