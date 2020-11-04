if SERVER then
    util.AddNetworkString("SetCurrentTool")

    net.Receive("SetCurrentTool", function (len, ply)
        ply.CurrentTool = net.ReadInt(32)
    end)
end

DEFINE_BASECLASS("player_default")

local PLAYER = {}
PLAYER.CurrentTool = 1

function PLAYER:GetCurrentTool()
    return self.CurrentTool
end

if CLIENT then
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

player_manager.RegisterClass("player_custom", PLAYER, "player_default")