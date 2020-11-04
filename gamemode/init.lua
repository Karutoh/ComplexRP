util.AddNetworkString("GiveTool")

--Player Class
AddCSLuaFile("player_class/player_class.lua")
include("player_class/player_class.lua")

--Root
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

--Menu
AddCSLuaFile("menu/client.lua")
include("menu/server.lua")

function GM:PlayerSpawn(ply, transition)
    player_manager.SetPlayerClass(ply, "player_custom")
    ply:SetModel("models/player/alyx.mdl")
    ply:SetupHands()
end

net.Receive("GiveTool", function (len, ply)
    ply:Give("tool")
end)