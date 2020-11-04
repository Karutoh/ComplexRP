RANK = {}

local ranks = {}

function RANK:Create(name, template = nil)
    local tmp = {
        Name = name,
        PrintName = "",
        Permissions = {
            ToolsVisible = true,
            PropsVisible = true,
            RanksVisible = false,
            CanVoteKick = false,
            CanKick = false,
            CanBan = false,
            AutoPromoteEnabled = false,
            AutoPromoteTo = "",
            AutoPromoteTime = 0
        }
    }

    if template == nil then
        return tmp
    end

    for i = 1, #ranks, 1 do
        if string.lower(ranks[i].Name) == string.lower(template) then
            tmp = table.Copy(ranks[i])
            break
        end
    end

    return tmp
end

function RANK:Exists(name)
    local nameL = string.lower(name)

    for i = 1, #ranks, 1 do
        if string.lower(ranks[i].Name) == nameL then
            return true
        end
    end

    return false
end

function RANK:SetPermissions(index, permissions)
    if index < 0 && index > #ranks then
        return false
    end

    ranks[index].Permissions = permissions

    if CLIENT then
        net.Start("UpdateRank")
        net.WriteString(ranks[index].Name)
        net.WriteTable(permissions)
        net.SendToServer()
    end

    return true
end

function RANK:GetAll()
    return table.Copy(ranks)
end

function RANK:GetByIndex(index)
    return table.Copy(ranks[index])
end

function RANK:Get(name)
    local nameL = string.lower(name)

    for i = 1, #ranks, 1 do
        if string.lower(ranks[i].Name) == nameL then
            return table.Copy(ranks[i]), i
        end
    end

    return nil, 0
end

function RANK:Remove(name)
    local nameL = string.lower(name)

    for i = 1, #ranks, 1 do
        if string.lower(ranks[i].Name) == nameL then
            table.remove(ranks, i)

            if CLIENT then
                net.Start("RemoveRank")
                net.WriteString(ranks[i].Name)
                net.SendToServer()
            end

            return true
        end
    end

    return false
end

function RANK:Add(rank)
    if self:Exists(rank.Name) then
        return false
    end

    table.insert(ranks, rank)

    if CLIENT then
        net.Start("AddRank")
        net.WriteTable(rank)
        net.SendToServer()
    end

    return true
end

if SERVER then
    util.AddNetworkString("UpdateRank")
    util.AddNetworkString("ClientUpdateRank")
    util.AddNetworkString("RemoveRank")
    util.AddNetworkString("ClientRemoveRank")
    util.AddNetworkString("AddRank")
    util.AddNetworkString("ClientAddRank")

    net.Receive("UpdateRank", function (len, ply)
        local rank = net.ReadString()
        local permissions = net.ReadTable()

        net.Start("ClientUpdateRank")
        net.WriteString(rank)
        net.WriteTable(permissions)
        net.SendOmit(ply)
    end)

    net.Receive("RemoveRank", function (len, ply)
        local rank = net.ReadString()

        local removed = RANK:Remove(rank)
        if removed then
            net.Start("ClientRemoveRank")
            net.WriteTable(rank)
            net.SendOmit(ply)
        end
    end)

    net.Receive("AddRank", function (len, ply)
        local rank = net.ReadTable()

        local accepted = RANK:Add(rank)
        if accepted == true then
            net.Start("ClientAddRank")
            net.WriteTable(rank)
            net.SendOmit(ply)
        else
            net.Start("ClientRemoveRank")
            net.SendString(rank.Name)
            net.Send(ply)
        end
    end)
end

if CLIENT then
    net.Receive("ClientUpdateRank", function (len, ply)
        local rank = string.lower(net.ReadString())
        local permissions = net.ReadTable()

        for i = 1, #ranks, 1 do
            if string.lower(ranks[i].Name) == rank then
                ranks[i].Permissions = permissions
                break
            end
        end
    end)

    net.Receive("ClientRemoveRank", function (len, ply)
        local rank = net.ReadString()

        for i = 1, #ranks, 1 do
            if string.lower(ranks[i].Name) == string.lower(name) then
                table.remove(ranks, i)
                break
            end
        end
    end)

    net.Receive("ClientAddRank", function (len, ply)
        table.insert(RANK.List, net.ReadTable())
    end)
end