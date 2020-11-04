--Tools
AddCSLuaFile("tools/client.lua")
AddCSLuaFile("tools/shared.lua")
include("tools/server.lua")
include("tools/shared.lua")

--Ranks
AddCSLuaFile("ranks/client.lua")
AddCSLuaFile("ranks/shared.lua")
include("ranks/server.lua")
include("ranks/shared.lua")

function GM:ShowSpare2(ply)
    ply:ConCommand("crp_show_menu")
end