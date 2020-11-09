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
    if CLIENT then
        local output = util.TableToJSON({
            currentTool = self.currentTool
        })

        file.CreateDir("complexrp")

        if !file.Exists("complexrp/localplayer.txt", "DATA") then
            file.Write("complexrp/localplayer.txt", "")
        end
    
        local playerFile = file.Open("complexrp/localplayer.txt", "w", "DATA")
        playerFile:Write(output)
        playerFile:Flush()
        playerFile:Close()
    end

    if SERVER then
        local output = util.TableToJSON({
            rank = self.rank
        })

        file.CreateDir("complexrp")
        file.CreateDir("complexrp/players")

        if !file.Exists("complexrp/players/" .. self.Player:SteamID64() .. ".txt", "DATA") then
            file.Write("complexrp/players/" .. self.Player:SteamID64() .. ".txt", "")
        end
    
        local plyFile = file.Open("complexrp/players/" .. self.Player:SteamID64() .. ".txt", "w", "DATA")
        plyFile:Write(output)
        plyFile:Flush()
        plyFile:Close()
    end
end

function PLAYER:Load()
    if CLIENT then
        local plyFile = file.Open("complexrp/localplayer.txt", "r", "DATA")
        if plyFile == nil then
            return
        end

        local plyData = util.JSONToTable(plyFile:Read(plyFile:Size()))
        plyFile:Close()

        self:SetCurrentTool(plyData.currentTool)
    end

    if SERVER then
        local plyFile = file.Open("complexrp/players/" .. self.Player:SteamID64() .. ".txt", "r", "DATA")
        if plyFile == nil then
            return
        end

        local plyData = util.JSONToTable(plyFile:Read(plyFile:Size()))
        plyFile:Close()

        self:SetRank(plyData.rank)
    end
end

player_manager.RegisterClass("player_crp", PLAYER, "player_default")