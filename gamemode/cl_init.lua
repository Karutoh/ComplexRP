--Player Class
include("player_class/player_class.lua")

--Root
include("shared.lua")

--Menu
include("menu/client.lua")

function GM:PostDrawViewModel(vm, ply, weapon)
	if weapon.UseHands || !weapon:IsScripted() then
		local hands = LocalPlayer():GetHands()
        if (IsValid(hands)) then
            hands:DrawModel()
        end
	end
end