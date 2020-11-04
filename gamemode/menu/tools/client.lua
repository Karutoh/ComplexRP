--Root
include("shared.lua")

function GM:AddMenuTabTools(frame, tabs)
    local tools = vgui.Create("DPanel", tabs)

    tabs:AddSheet("Tools", tools, "icon16/wrench.png")

    local list = vgui.Create("DCategoryList", tools)
    list:Dock(LEFT)
    list:SetWidth(150)

    local properties = vgui.Create("DPanel", tools)
    properties:Dock(FILL)

    local categories = {}

    for i = 1, #TOOLS.list, 1 do
        local cat = nil

        for c = 1, #categories, 1 do
            if categories[c].Name == TOOLS.list[i].Category then
                cat = categories[c].Hdl
                break
            end
        end
        
        if cat == nil then
            cat = list:Add(TOOLS.list[i].Category)
            table.insert(categories, {
                Name = TOOLS.list[i].Category,
                Hdl = cat
            })
        end

        local item = cat:Add(TOOLS.list[i].PrintName)
        item.Tool = i
        item.DoClick = function (p)
            if p:IsSelected() then
                return
            end

            player_manager.RunClass(LocalPlayer(), "SetCurrentTool", p.Tool)

            if LocalPlayer():HasWeapon("tool") then
                input.SelectWeapon(LocalPlayer():GetWeapon("tool"))
            else
                net.Start("GiveTool")
                net.SendToServer()
            end

            local properties = p:GetParent():GetParent():GetParent():GetParent():GetChildren()[2]
            properties:Clear()

            if TOOLS.list[p.Tool].BuildProperties != nil then
                TOOLS.list[p.Tool]:BuildProperties(frame, properties)
            end
        end
    end
end