DEFINE_BASECLASS("player_default")

local PLAYER = {}
PLAYER.rank = ""
PLAYER.currentTool = 0

if SERVER then
    util.AddNetworkString("ClientSetRank")
    util.AddNetworkString("SetCurrentTool")
    util.AddNetworkString("ClientSetCurrentTool")

    function PLAYER:SetRank(name)
        if !rank.Exists(name) then
            return
        end
    
        net.Start("ClientSetRank")
        net.WriteString(name)
        net.Send(self.Player)
        
        self.rank = name

        self:Save()
    end

    net.Receive("SetCurrentTool", function (len, ply)
        PLAYER.currentTool = net.ReadInt(32)
    end)
end

if CLIENT then
    net.Receive("ClientSetCurrentTool", function (len, ply)
        PLAYER.currentTool = net.ReadInt(32)
    end)

    net.Receive("ClientSetRank", function (len, ply)
        PLAYER.rank = net.ReadString()
    end)
end

function PLAYER:GetRank()
    return self.rank
end

function PLAYER:SetCurrentTool(index)
    self.currentTool = index

    if SERVER then
        net.Start("ClientSetCurrentTool")
        net.WriteInt(index, 32)
        net.Send(self.Player)
    end

    if CLIENT then
        net.Start("SetCurrentTool")
        net.WriteInt(index, 32)
        net.SendToServer()

        self:Save()
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