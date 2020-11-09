net.Receive("dropweapon", function (len, ply)
	local wep = net.ReadInt(9)

	local weps = ply:GetWeapons()

	if weps[wep] == nil then return false end
	
	ply:DropWeapon(weps[wep])
end)

net.Receive("setactiveweapon", function(len, ply)
	local wep = net.ReadInt(9)

	local weps = ply:GetWeapons()

	if weps[wep] == nil then return end

	ply:SelectWeapon(weps[wep])
end)