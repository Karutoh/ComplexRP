rank = {}

local ranks = {}

rank.Create = function (name, template)
    local tmp = {
        name = name,
        permissions = {
            toolsVisible = true,
            propsVisible = true,
            ranksVisible = false,
            canVoteKick = false,
            canKick = false,
            canBan = false,
            autoPromoteEnabled = false,
            autoPromoteTo = "",
            autoPromoteTime = 0
        }
    }

    if template == nil then
        return tmp
    end

    for i = 1, #ranks, 1 do
        if string.lower(ranks[i].name) == string.lower(template) then
            tmp = table.Copy(ranks[i])
            break
        end
    end

    return tmp
end

rank.Exists = function (name)
    local nameL = string.lower(name)

    for i = 1, #ranks, 1 do
        if string.lower(ranks[i].name) == nameL then
            return true
        end
    end

    return false
end

rank.SetPermissions = function (index, permissions)
    if index < 0 && index > #ranks then
        return false
    end

    ranks[index].permissions = permissions

    if CLIENT then
        net.Start("UpdateRank")
        net.WriteString(ranks[index].name)
        net.WriteTable(permissions)
        net.SendToServer()
    end

    return true
end

rank.GetAll = function ()
    return table.Copy(ranks)
end

rank.GetByIndex = function (index)
    if index < 0 && index > #ranks then
        return nil
    end

    return table.Copy(ranks[index])
end

rank.Get = function (name)
    local nameL = string.lower(name)

    for i = 1, #ranks, 1 do
        if string.lower(ranks[i].name) == nameL then
            return table.Copy(ranks[i]), i
        end
    end

    return nil, 0
end

rank.Remove = function (name)
    local nameL = string.lower(name)

    for i = 1, #ranks, 1 do
        if string.lower(ranks[i].name) == nameL then
            table.remove(ranks, i)

            if CLIENT then
                net.Start("RemoveRank")
                net.WriteString(ranks[i].name)
                net.SendToServer()
            end

            return true
        end
    end

    return false
end

rank.Add = function (newRank)
    PrintTable(newRank)
    if self.Exists(newRank.name) then
        return false
    end

    table.insert(ranks, newRank)

    if CLIENT then
        net.Start("AddRank")
        net.WriteTable(newRank)
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
        local rankName = net.ReadString()
        local permissions = net.ReadTable()

        net.Start("ClientUpdateRank")
        net.WriteString(rankName)
        net.WriteTable(permissions)
        net.SendOmit(ply)
    end)

    net.Receive("RemoveRank", function (len, ply)
        local rankName = net.ReadString()

        local removed = rank.Remove(rankName)
        if removed then
            net.Start("ClientRemoveRank")
            net.WriteString(rankName)
            net.SendOmit(ply)
        end
    end)

    net.Receive("AddRank", function (len, ply)
        local newRank = net.ReadTable()

        local accepted = rank.Add(newRank)
        if accepted == true then
            net.Start("ClientAddRank")
            net.WriteTable(rank)
            net.SendOmit(ply)
        else
            net.Start("ClientRemoveRank")
            net.SendString(newRank.name)
            net.Send(ply)
        end
    end)
end

if CLIENT then
    net.Receive("ClientUpdateRank", function (len, ply)
        local rankName = string.lower(net.ReadString())
        local permissions = net.ReadTable()

        for i = 1, #ranks, 1 do
            if string.lower(ranks[i].name) == rankName then
                ranks[i].permissions = permissions
                break
            end
        end
    end)

    net.Receive("ClientRemoveRank", function (len, ply)
        local rankName = net.ReadString()

        for i = 1, #ranks, 1 do
            if string.lower(ranks[i].name) == string.lower(rankName) then
                table.remove(ranks, i)
                break
            end
        end
    end)

    net.Receive("ClientAddRank", function (len, ply)
        table.insert(ranks, net.ReadTable())
    end)
end