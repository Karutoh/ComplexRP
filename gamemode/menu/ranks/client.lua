function GM:AddMenuTabRanks(frame, tabs)
    local ranks = vgui.Create("DPanel", tabs)
    ranks:SetSize(tabs:GetWide(), tabs:GetTall() - 36)

    tabs:AddSheet("Ranks", ranks, "icon16/user_edit.png")

    local rankList = vgui.Create("DListView", ranks)
    rankList:SetSize(ranks:GetWide() / 8, ranks:GetTall() - 40)
    rankList:AddColumn("Ranks")

    local addRank = vgui.Create("DButton", ranks)
    addRank:SetText("Add Rank")
    addRank:SetSize(ranks:GetWide() / 8, 40)
    addRank:SetPos(0, ranks:GetTall() - 40)

    local tabVisibility = vgui.Create("DPanel", ranks)
    tabVisibility:SetWide(ranks:GetWide() / 8)
    tabVisibility:SetPos(ranks:GetWide() / 8, 0)
    tabVisibility:SetBackgroundColor(Color(127, 127, 127))
    tabVisibility:DockPadding(5, 5, 5, 5)
    
    local tabVisibilityL = vgui.Create("DLabel", tabVisibility)
    tabVisibilityL:SetText("Tab Visibility")
    tabVisibilityL:Dock(TOP)

    local toolsVisible = vgui.Create("DCheckBoxLabel", tabVisibility)
    toolsVisible:SetText("Tools Visible")
    toolsVisible:SetValue(true)
    toolsVisible:Dock(TOP)
    toolsVisible:SetDark(true)

    local propsVisible = vgui.Create("DCheckBoxLabel", tabVisibility)
    propsVisible:SetText("Props Visible")
    propsVisible:SetValue(true)
    propsVisible:Dock(TOP)
    propsVisible:SetDark(true)

    local ranksVisible = vgui.Create("DCheckBoxLabel", tabVisibility)
    ranksVisible:SetText("Ranks Visible")
    ranksVisible:SetValue(false)
    ranksVisible:Dock(TOP)
    ranksVisible:SetDark(true)

    tabVisibility:InvalidateLayout(true)
    tabVisibility:SizeToChildren(false, true)

    local autoPromote = vgui.Create("DPanel", ranks)
    autoPromote:SetWide(ranks:GetWide() / 8)
    autoPromote:SetPos(ranks:GetWide() / 8, tabVisibility:GetTall() + 5)
    autoPromote:SetBackgroundColor(Color(127, 127, 127))
    autoPromote:DockPadding(5, 5, 5, 5)
    
    local autoPromoteL = vgui.Create("DLabel", autoPromote)
    autoPromoteL:SetText("Auto Promote")
    autoPromoteL:Dock(TOP)

    local autoPromoteEnabled = vgui.Create("DCheckBoxLabel", autoPromote)
    autoPromoteEnabled:SetText("Auto Promote")
    autoPromoteEnabled:SetValue(false)
    autoPromoteEnabled:Dock(TOP)
    autoPromoteEnabled:SetDark(true)

    local autoPromoteTo = vgui.Create("DComboBox", autoPromote)
    autoPromoteTo:Dock(TOP)
    autoPromoteTo:SetDisabled(autoPromoteEnabled:GetValue())

    local autoPromoteTime = vgui.Create("DNumberWang", autoPromote)
    autoPromoteTime:Dock(TOP)
    autoPromoteTime:SetDisabled(autoPromoteEnabled:GetValue())

    function autoPromoteEnabled:OnChange(value)
        autoPromoteTo:SetDisabled(!value)
        autoPromoteTime:SetDisabled(!value)
    end

    autoPromote:InvalidateLayout(true)
    autoPromote:SizeToChildren(false, true)
end