TOOLS = {}

TOOLS.list = {}

function TOOLS:Create(name)
    return {
        Name = name,
        PrintName = "",
        Category = "",
        AdminOnly = false,
        Primary = {
            Sound = Sound("Airboat.FireGunRevDown"),
            Delay = 1
        },
        Secondary = {
            Sound = Sound("Airboat.FireGunRevDown"),
            Delay = 1
        }
    }
end

function TOOLS:Exists(name)
    for i = 1, #self.list, 1 do
        if string.lower(self.list[i].Name) == string.lower(name) then
            return true
        end
    end

    return false
end

function TOOLS:Get(name)
    for i = 1, #self.list, 1 do
        if string.lower(self.list[i].Name) == string.lower(tool.Name) then
            return self.list[i]
        end
    end

    return nil
end

function TOOLS:Add(tool)
    if self:Exists(tool.Name) then
        return false
    end

    table.insert(self.list, tool)
end

AddCSLuaFile("door_group/shared.lua")
include("door_group/shared.lua")