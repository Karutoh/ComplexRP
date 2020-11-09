--Player Info
include("player_class/player_crp.lua")

--Root
include("shared.lua")

--Weapon Selection
include("weaponsel/cl_init.lua")
include("weaponsel/shared.lua")

--Menu
include("menu/client.lua")

hook.Add("PlayerClassChanged", "ClientLoadedPlayerClass", function (ply, newId)
    net.Start("ClientLoadedPlayerClass")
    net.WriteString(ply:SteamID64())
    net.WriteInt(newId, 32)
    net.SendToServer()
end)

function GM:PostDrawViewModel(vm, ply, weapon)
	if weapon.UseHands || !weapon:IsScripted() then
		local hands = LocalPlayer():GetHands()
        if (IsValid(hands)) then
            hands:DrawModel()
        end
	end
end