--Tools
include("tools/client.lua")
include("tools/shared.lua")

--Ranks
include("ranks/client.lua")
include("ranks/shared.lua")

function GM:AddMenuTabProfile(frame, tabs)
    local profile = vgui.Create("DPanel", tabs)
    tabs:AddSheet("Profile", profile, "icon16/user.png")
end

function GM:AddMenuTabProps(frame, tabs)
    local props = vgui.Create("DPanel", tabs)
    tabs:AddSheet("Props", props, "icon16/brick_add.png")
end

concommand.Add("crp_show_menu", function (ply, cmd, args, argStr)
    local frame = vgui.Create("DFrame")
    frame:SetSize((ScrW() / 8) * 7, (ScrH() / 8) * 7)
    frame:Center()
    frame:SetTitle("Menu")
    frame:SetVisible(true)
    frame:SetDraggable(true)
    frame:SetDrawOnTop(false)
    frame:ShowCloseButton(true)
    frame:MakePopup()

    local tabs = vgui.Create("DPropertySheet", frame)
    tabs:Dock(FILL)

    hook.Run("AddMenuTabProfile", frame, tabs)
    hook.Run("AddMenuTabTools", frame, tabs)
    hook.Run("AddMenuTabProps", frame, tabs)
    hook.Run("AddMenuTabRanks", frame, tabs)

    hook.Run("AddMenuTab", frame, tabs)
end, nil, "Used to open the menu.")