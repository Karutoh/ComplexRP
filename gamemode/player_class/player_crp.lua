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
    else
        net.Start("SetCurrentTool")
        net.WriteInt(index, 32)
        net.SendToServer()
    end
end

function PLAYER:GetCurrentTool()
    return self.currentTool
end

player_manager.RegisterClass("player_crp", PLAYER, "player_default")