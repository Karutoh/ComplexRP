--Root
include("shared.lua")

function GM:AddMenuTabTools(frame, tabs)
    local tools = vgui.Create("DPanel", tabs)
    tools:SetSize(tabs:GetWide(), tabs:GetTall() - 36)

    tabs:AddSheet("Tools", tools, "icon16/wrench.png")

    local list = vgui.Create("DCategoryList", tools)
    list:Dock(LEFT)
    list:SetWidth(150)

    local properties = vgui.Create("DPanel", tools)
    properties:Dock(FILL)

    local categories = {}

    local toolList = tool.GetAll()
    for i = 1, #toolList, 1 do
        local cat = nil

        for c = 1, #categories, 1 do
            if categories[c].name == toolList[i].category then
                cat = categories[c].Hdl
                break
            end
        end
        
        if cat == nil then
            cat = list:Add(toolList[i].category)
            table.insert(categories, {
                Name = toolList[i].category,
                Hdl = cat
            })
        end

        local item = cat:Add(toolList[i].name)
        item.Tool = i
        item.DoClick = function (p)
            if p:IsSelected() then
                return
            end

            player_manager.RunClass(LocalPlayer(), "SetCurrentTool", toolList[p.Tool].name)

            net.Start("GiveTool")
            net.SendToServer()
            --input.SelectWeapon(LocalPlayer():GetWeapon("tool"))

            local properties = p:GetParent():GetParent():GetParent():GetParent():GetChildren()[2]
            properties:Clear()

            if toolList[p.Tool].BuildProperties != nil then
                toolList[p.Tool]:BuildProperties(frame, properties)
            end
        end
    end
end