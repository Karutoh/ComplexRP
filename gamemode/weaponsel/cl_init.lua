//Hide Weaponselect
hook.Add("HUDShouldDraw","NoWepSelect",function(e)
	if e == "CHudWeaponSelection" then return false end
end)

//Scrolling, slotnums, lastinv, and clicking.
hook.Add("PlayerBindPress","aWeaponSelect",function(ply,bind,down)
	if not hasWeaponsToSwitch() then return end
	
	if bind == "invprev" then scrollToWeapon('invprev') end
	if bind == "invnext" then scrollToWeapon('invnext') end

end)

local dropHotKeyPressed = false
local dropDelay = 1
local curTime = CurTime()

hook.Add("Think","key Presses",function()
	if not IsValid(vgui.GetKeyboardFocus()) and not gui.IsConsoleVisible() then
		
		if getKeyDown('G') and dropHotKeyPressed == false and LocalPlayer():IsValid() and LocalPlayer():GetActiveWeapon():IsValid() then

			dropWeapon(getCurrentWeaponIndex())
			curTime = CurTime()
			dropHotKeyPressed = true
		end
	end

	if CurTime() > curTime + dropDelay then

		dropHotKeyPressed = false
	end
end)

function getKeyDown(key)
	if input.IsKeyDown(_G["KEY_"..key:upper()]) then
		return true
	end
	return false
end

function getCurrentWeaponIndex()
	for k,v in pairs(LocalPlayer():GetWeapons()) do
		if v == LocalPlayer():GetActiveWeapon() then
			return k
		end
	end
	return 0
end

function setWeapon(wepIndex)
	
	net.Start("setactiveweapon")
		net.WriteInt(wepIndex, 9)
	net.SendToServer()
end

function hasWeaponsToSwitch()
	if #LocalPlayer():GetWeapons() <= 1 then return false end
	return true
end

function dropWeapon(wepIndex)
	net.Start("dropweapon")
		net.WriteInt(wepIndex, 9)
	net.SendToServer()
	if hasWeaponsToSwitch() then scrollToWeapon('invnext') end
end


function scrollToWeapon(bindPressed)
	local index = getCurrentWeaponIndex()

	if bindPressed == "invprev" then
		if index <= 1 then 
			setWeapon(#LocalPlayer():GetWeapons())
			return
		end
		setWeapon(index-1)
	elseif bindPressed == "invnext" then
		if index >= #LocalPlayer():GetWeapons() then
			setWeapon(1)
			return
		end
		
		setWeapon(index+1)
	end
end

