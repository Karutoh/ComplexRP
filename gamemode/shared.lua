GM.Name = "Complex RP"
GM.Author = "Arron David Nelson"
GM.Email = "NelsonArron@outlook.com"
GM.Website = "N/A"

hook.Add("PlayerNoClip", "NoClip", function (ply, desiredState)
    if !desiredState then
        return true
    end

    local rankName = player_manager.RunClass(ply, "GetRank")
    local r = rank.Get(rankName)
    if r == nil then
        return false
    end

    PrintTable(r)

    if !r.permissions.canNoClip then
        return false
    end

    return true
end)