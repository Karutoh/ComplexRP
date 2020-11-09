local function TextEntryBox(frame, tmpText, task)
    frame:SetMouseInputEnabled(false)
    frame:SetKeyboardInputEnabled(false)

    local group = vgui.Create("DFrame", frame)
    group:SetSize(300, 80)
    group:Show()
    group:Center()
    group:MakePopup()
    group:SetBackgroundBlur(true)
    group:SetFocusTopLevel(true)
    group.OnClose = function ()
        frame:SetMouseInputEnabled(true)
        frame:SetKeyboardInputEnabled(true)
    end

    local text = vgui.Create("DTextEntry", group)
    text:SetPlaceholderText(tmpText)
    text:SetWidth(group:GetWide() - 10)
    text:SetPos(group:GetWide() / 2 - text:GetWide() / 2, 30)

    local submit = vgui.Create("DButton", group)
    submit:SetText("Submit")
    submit:SetWide(group:GetWide() / 4)
    submit:SetPos(group:GetWide() / 4, group:GetTall() - submit:GetTall() - 5)
    submit.DoClick = function(p)
        task(text:GetText())

        frame:SetMouseInputEnabled(true)
        frame:SetKeyboardInputEnabled(true)
        group:Close()
    end

    local cancel = vgui.Create("DButton", group)
    cancel:SetText("Cancel")
    cancel:SetWide(group:GetWide() / 4)
    cancel:SetPos(group:GetWide() / 2, group:GetTall() - submit:GetTall() - 5)
    cancel.DoClick = function(p)
        frame:SetMouseInputEnabled(true)
        frame:SetKeyboardInputEnabled(true)
        group:Close()
    end
end

function GM:AddMenuTabRanks(frame, tabs)
    local rankName = player_manager.RunClass(LocalPlayer(), "GetRank")
    if rankName == nil then
        return
    end

    local rankT = rank.Get(rankName)
    if rankT == nil then
        return
    end

    if !rankT.permissions.ranksVisible then
        return
    end

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
    addRank.DoClick = function (p)
        TextEntryBox(frame, "Rank Name", function (text)
            local newRank = rank.Create(text)
            if newRank then
                rank.Add(newRank)
            end
        end)
    end

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