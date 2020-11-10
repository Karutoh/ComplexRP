tool = {}

local tools = {}

tool.Create = function (name)
    return {
        name = name,
        category = "",
        adminOnly = false,
        primary = {
            sound = Sound("Airboat.FireGunRevDown"),
            delay = 1
        },
        secondary = {
            sound = Sound("Airboat.FireGunRevDown"),
            delay = 1
        }
    }
end

tool.Exists = function (name)
    local lName = string.lower(name)
    
    for i = 1, #tools, 1 do
        if string.lower(tools[i].name) == lName then
            return true
        end
    end

    return false
end

tool.GetAll = function ()
    return table.Copy(tools)
end

tool.GetByIndex = function (index)
    if index < 0 && index > #tools then
        return nil
    end

    return table.Copy(tools[index])
end

tool.Get = function (name)
    local lName = string.lower(name)

    for i = 1, #tools, 1 do
        if string.lower(tools[i].name) == lName then
            return table.Copy(tools[i]), i
        end
    end

    return nil, 0
end

tool.Add = function (newTool)
    if tool.Exists(newTool.name) then
        return false
    end

    table.insert(tools, newTool)
end

AddCSLuaFile("door_group/shared.lua")
include("door_group/shared.lua")