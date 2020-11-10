rank = {}

local ranks = {}

if SERVER then
    rank.Initialize = function (ply)
        net.Start("ClientLoadRanks")
        net.WriteTable(ranks)
        net.Send(ply)
    end
end

rank.Create = function (name, template)
    local tmp = {
        name = name,
        permissions = {
            toolsVisible = true,
            propsVisible = true,
            ranksVisible = false,
            canEditPlayerRank = false,
            canEditRanks = false,
            canNoClip = false,
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

    local templateL = string.lower(template)

    for i = 1, #ranks, 1 do
        if string.lower(ranks[i].name) == templateL then
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

    if CLIENT then
        local rankName = player_manager.RunClass(LocalPlayer(), "GetRank")
        if rankName == nil then
            return false
        end

        local rankT = rank.Get(rankName)
        if rankT == nil then
            return false
        end

        if !rankT.permissions.canEditRanks then
            return false
        end

        net.Start("UpdateRank")
        net.WriteString(ranks[index].name)
        net.WriteTable(permissions)
        net.SendToServer()
    end

    ranks[index].permissions = permissions

    if SERVER then
        net.Start("ClientUpdateRank")
        net.WriteString(ranks[index].name)
        net.WriteTable(permissions)
        net.Broadcast()
        
        rank.Save()
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
                local rankName = player_manager.RunClass(LocalPlayer(), "GetRank")
                if rankName == nil then
                    return false
                end
        
                local rankT = rank.Get(rankName)
                if rankT == nil then
                    return false
                end

                if !rankT.permissions.canEditRanks then
                    return false
                end

                net.Start("RemoveRank")
                net.WriteString(ranks[i].name)
                net.SendToServer()
            end

            if SERVER then
                net.Start("ClientRemoveRank")
                net.WriteString(ranks[i].name)
                net.Broadcast()

                rank.Save()
            end

            return true
        end
    end

    return false
end

rank.Add = function (newRank)
    if rank.Exists(newRank.name) then
        return false
    end

    if CLIENT then
        local rankName = player_manager.RunClass(LocalPlayer(), "GetRank")
        if rankName == nil then
            return false
        end

        local rankT = rank.Get(rankName)
        if rankT == nil then
            return false
        end

        if !rankT.permissions.canEditRanks then
            return false
        end

        net.Start("AddRank")
        net.WriteTable(newRank)
        net.SendToServer()
    end

    table.insert(ranks, newRank)

    if SERVER then
        net.Start("ClientAddRank")
        net.WriteTable(newRank)
        net.Broadcast()

        rank.Save()
    end

    return true
end

if SERVER then
    rank.Save = function()
        local output = util.TableToJSON(ranks)

        file.CreateDir("complexrp")

        if !file.Exists("complexrp/ranks.txt", "DATA") then
            file.Write("complexrp/ranks.txt", "")
        end

        local ranksFile = file.Open("complexrp/ranks.txt", "w", "DATA")
        ranksFile:Write(output)
        ranksFile:Flush()
        ranksFile:Close()
    end

    rank.Load = function()
        local ranksFile = file.Open("complexrp/ranks.txt", "r", "DATA")
        if ranksFile == nil then
            return
        end

        ranks = util.JSONToTable(ranksFile:Read(ranksFile:Size()))
        ranksFile:Close()
    end

    util.AddNetworkString("ClientLoadRanks")
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

        local rankName = player_manager.RunClass(ply, "GetRank")
        if rankName == nil then
            net.Start("ClientRemoveRank")
            net.SendString(newRank.name)
            net.Send(ply)

            return
        end

        local rankT = rank.Get(rankName)
        if !rankT.permissions.ranksVisible then
            net.Start("ClientRemoveRank")
            net.SendString(newRank.name)
            net.Send(ply)

            return
        end

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
    net.Receive("ClientLoadRanks", function (len, ply)
        ranks = net.ReadTable()
    end)

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