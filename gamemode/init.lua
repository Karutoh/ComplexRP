util.AddNetworkString("ClientLoadedPlayerClass")
util.AddNetworkString("GiveTool")

--Player Info
AddCSLuaFile("player_class/player_crp.lua")
include("player_class/player_crp.lua")

--Root
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

-- Weapon Selection
AddCSLuaFile("weaponsel/cl_init.lua")
AddCSLuaFile("weaponsel/shared.lua")
include("weaponsel/init.lua")
include("weaponsel/shared.lua")

--Menu
AddCSLuaFile("menu/client.lua")
include("menu/server.lua")

net.Receive("ClientLoadedPlayerClass", function ()
    hook.Run("ClientLoadedPlayerClass", player.GetBySteamID64(net.ReadString()), net.ReadInt(32))
end)

--[[
function GM:ClientLoadedPlayerClass(ply, newId)
    local class = util.NetworkIDToString(newId)
    if class == "player_crp" then
        player_manager.RunClass(ply, "SetRank", "owner")
    end
end
]]--

function GM:Initialize()
    rank.Load()
end

function GM:PlayerFullLoad(ply)
    rank.Initialize(ply)
    player_manager.RunClass(ply, "Load")
end

function GM:PlayerInitialSpawn(ply, transition)
    hook.Add("SetupMove", ply, function(self, ply, _, cmd)
		if self == ply and not cmd:IsForced() then
			hook.Run("PlayerFullLoad", self)
			hook.Remove("SetupMove", self)
		end
	end)
end

function GM:PlayerSpawn(ply, transition)
    player_manager.SetPlayerClass(ply, "player_crp")
    ply:SetModel("models/player/alyx.mdl")
    ply:SetupHands()
end

net.Receive("GiveTool", function (len, ply)
    if !ply:HasWeapon("tool") then
        ply:Give("tool")
    end
end)