DEFINE_BASECLASS("player_default")

local PLAYER = {}
PLAYER.Rank = ""
PLAYER.CurrentTool = 1

if SERVER then
    util.AddNetworkString("SetRank")
    util.AddNetworkString("SetCurrentTool")

    net.Receive("SetCurrentTool", function (len, ply)
        ply.CurrentTool = net.ReadInt(32)
    end)
end

function PLAYER:SetRank(name)
    if SERVER then
        if !RANK:Exists(name) then
            return
        end

        net.Start("SetRank")
        net.WriteString(name)
        net.Send(self)
    end
    
    self.Rank = name
end

function PLAYER:GetRank()
    return self.Rank
end

if CLIENT then
    net.Receive("SetRank", function (len, ply)
        ply.
    end)

    function PLAYER:SetCurrentTool(index)
        if SERVER then
            return
        end

        self.CurrentTool = index

        net.Start("SetCurrentTool")
        net.WriteInt(index, 32)
        net.SendToServer()
    end
end

function PLAYER:GetCurrentTool()
    return self.CurrentTool
end

player_manager.RegisterClass("player_custom", PLAYER, "player_default")