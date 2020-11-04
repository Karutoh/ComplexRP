function GM:AddMenuTabRanks(frame, tabs)
    frame:InvalidateParent(true)
    tabs:InvalidateParent(true)

    local ranks = vgui.Create("DPanel", tabs)
    tabs:AddSheet("Ranks", ranks, "icon16/user_edit.png")
    ranks:InvalidateParent(true)
    print(ranks:GetSize())

    local rankList = vgui.Create("DListView", ranks)
    rankList:SetSize(ranks:GetWide(), ranks:GetTall())
    rankList:AddColumn("Ranks")
    rankList:Dock(LEFT)
end