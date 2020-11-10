if SERVER then
    util.AddNetworkString("RemoveDoor")
    util.AddNetworkString("AddDoor")
end

local TOOL = tool.Create("Door Grouper")
TOOL.category = "Map"
TOOL.adminOnly = false

TOOL.primary.delay = 0.5

TOOL.secondary.delay = 0.5

TOOL.groups = {}
TOOL.selected = {}

if CLIENT then
    function TOOL:TextEntryBox(frame, tmpText, task)
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

    function TOOL:BuildProperties(frame, panel)
        panel:InvalidateParent(true)

        local groupsLast = 0
        local groups = vgui.Create("DListView", panel)
        groups:SetMultiSelect(true)
        groups:AddColumn("Door Groups")
        groups:AddColumn("Owner")
        groups:AddColumn("Steam Id 64")
        groups:SetSize(panel:GetWide() / 2, panel:GetTall())
        groups:SetPos(0, 0)
        groups.Populate = function ()
            for i = 1, #self.groups, 1 do
                local ply = player.GetBySteamID64(self.groups[i].Owner)
                if IsValid(ply) then
                    groups:AddLine(self.groups[i].name, ply:GetName(), self.groups[i].owner)
                else
                    groups:AddLine(self.groups[i].name, "", self.groups[i].owner)
                end
            end
        end
        groups.OnRowSelected = function (line, lineId)
            if groupsLast == lineId then
                return
            end

            groupsLast = lineId

            local d = panel:GetChildren()[2]
            d:Clear()
            d:Populate()
            d:SelectFirstItem()
        end
        groups.OnRowRightClick = function (line, lineId)
            local selectedMenu = DermaMenu()
            selectedMenu:AddOption("Rename")
            local owner, opt = selectedMenu:AddSubMenu("Owner")
            owner:AddOption("Set SteamId")
            owner:AddOption("Set Username")
            owner:AddOption("Remove")
            selectedMenu:AddOption("Remove", function()
                panel:GetChildren()[2]:Clear()
                panel:GetChildren()[3]:Clear()

                local sGroups = groups:GetSelected()

                if #sGroups == #groups:GetLines() then
                    groups:Clear()
                    table.Empty(self.groups)
                else
                    local newGroups = {}
                    for d = 1, #self.groups, 1 do
                        local found = false

                        for i = 1, #sGroups, 1 do
                            if self.groups[d].Name == sGroups[i]:GetColumnText(1) then
                                found = true
                                break
                            end
                        end

                        if !found then
                            table.insert(newGroups, self.groups[d])
                        end
                    end

                    local lines = groups:GetLines()
                    for l = #lines, 0, -1 do
                        for i = 1, #sGroups, 1 do
                            if lines[l] == sGroups[i] then
                                groups:RemoveLine(l)
                            end
                        end
                    end

                    self.groups = newGroups
                end
            end)
            selectedMenu:Open()
        end

        local doorsLast = 0
        local doors = vgui.Create("DListView", panel)
        doors:SetMultiSelect(true)
        doors:AddColumn("Doors")
        doors:AddColumn("Id"):SetWidth(doors:GetWide() / 4)
        doors:SetSize(panel:GetWide() / 4, panel:GetTall())
        doors:SetPos(panel:GetWide() / 2, 0)
        doors.Populate = function ()
            if groups:GetSelectedLine() == nil then
                return
            end

            for i = 1, #self.groups[groups:GetSelectedLine()].Doors, 1 do
                doors:AddLine(self.groups[groups:GetSelectedLine()].Doors[i].Name, self.groups[groups:GetSelectedLine()].Doors[i].Id)
            end
        end
        doors.OnRowSelected = function (line, lineId)
            if doorsLast == lineId then
                return
            end

            doorsLast = lineId

            local d = panel:GetChildren()[3]
            d:Clear()

            local group = self.groups[groups:GetSelectedLine()]
            local door = group.doors[lineId]
            for i = 1, #door.coOwners, 1 do
                d:AddLine(player.GetBySteamID64(door.coOwners[i]):GetName(), door.coOwners[i])
            end
        end
        doors.OnRowRightClick = function (line, lineId)
            local selectedMenu = DermaMenu()
            selectedMenu:AddOption("Rename", function ()
                self:TextEntryBox(frame, "Door Name", function (text)
                    self.groups[groups:GetSelectedLine()].doors[lineId].name = text
                    line:GetLine(lineId):SetColumnText(1, text)
                end)
            end)
            selectedMenu:AddOption("Remove", function ()
                panel:GetChildren()[3]:Clear()

                local sDoors = doors:GetSelected()

                if #sDoors == #doors:GetLines() then
                    doors:Clear()
                    table.remove(self.groups, groups:GetSelectedLine())
                    groups:RemoveLine(groups:GetSelectedLine())
                else
                    local newDoors = {}
                    for d = 1, #self.groups[groups:GetSelectedLine()].doors, 1 do
                        local found = false

                        for i = 1, #sDoors, 1 do
                            if self.groups[groups:GetSelectedLine()].doors[d].Id == sDoors[i]:GetColumnText(2) then
                                found = true
                                break
                            end
                        end

                        if !found then
                            table.insert(newDoors, self.groups[groups:GetSelectedLine()].doors[d])
                        end
                    end

                    local lines = doors:GetLines()
                    for l = #lines, 0, -1 do
                        for i = 1, #sDoors, 1 do
                            if lines[l] == sDoors[i] then
                                doors:RemoveLine(l)
                            end
                        end
                    end

                    self.groups[groups:GetSelectedLine()].doors = newDoors
                end
            end)
            selectedMenu:Open()
        end

        local coOwners = vgui.Create("DListView", panel)
        coOwners:SetMultiSelect(true)
        coOwners:AddColumn("CoOwners")
        coOwners:AddColumn("Steam Id 64")
        coOwners:SetSize(panel:GetWide() / 4, panel:GetTall() - 120)
        coOwners:SetPos((panel:GetWide() / 4) * 3 , 0)
        coOwners.OnRowRightClick = function (line, lineId)
            local selectedMenu = DermaMenu()
            selectedMenu:AddOption("Remove", function ()
                local sCoOwners = doors:GetSelected()

                if #sCoOwners == #coOwners:GetLines() then
                    table.Empty(self.groups[groups:GetSelectedLine()].doors[doors:GetSelectedLine()].coOwners)
                    coOwners:Clear()
                else
                    local newCoOwners = {}
                    for d = 1, #self.groups[groups:GetSelectedLine()].doors[doors:GetSelectedLine()].coOwners, 1 do
                        local found = false

                        for i = 1, #sCoOwners, 1 do
                            if self.groups[groups:GetSelectedLine()].doors[doors:GetSelectedLine()].coOwners[d] == sCoOwners[i]:GetColumnText(2) then
                                found = true
                                break
                            end
                        end

                        if !found then
                            table.insert(newCoOwners, self.groups[groups:GetSelectedLine()].doors[doors:GetSelectedLine()].coOwners)
                        end
                    end

                    local lines = coOwners:GetLines()
                    for l = #lines, 0, -1 do
                        for i = 1, #sCoOwners, 1 do
                            if lines[l] == sCoOwners[i] then
                                coOwners:RemoveLine(l)
                            end
                        end
                    end

                    self.groups[groups:GetSelectedLine()].doors[doors:GetSelectedLine()].coOwners = newCoOwners
                end
            end)
            selectedMenu:Open()
        end
        
        groups:Populate()
        groups:SelectFirstItem()

        local addCoOwner = vgui.Create("DButton", panel)
        addCoOwner:SetText("Add Co-Owner")
        addCoOwner:SetSize(panel:GetWide() / 4, 40)
        addCoOwner:SetPos((panel:GetWide() / 4) * 3, panel:GetTall() - 120)
        addCoOwner.DoClick = function (p)
            if groups:GetSelectedLine() == nil || doors:GetSelectedLine() == nil then
                return
            end

            self:TextEntryBox(frame, "Co-Owner's Steam Id 64", function (text)
                if table.HasValue(self.groups[groups:GetSelectedLine()].doors[doors:GetSelectedLine()].coOwners, text) then
                    return
                end

                local ply = player.GetBySteamID64(text)
                if !IsValid(ply) then
                    return
                end

                table.insert(self.groups[groups:GetSelectedLine()].doors[doors:GetSelectedLine()].coOwners, text)
                coOwners:AddLine(ply:GetName(), text)
            end)
        end

        local add = vgui.Create("DButton", panel)
        add:SetText("Add Selected Door(s)")
        add:SetSize(panel:GetWide() / 4, 40)
        add:SetPos((panel:GetWide() / 4) * 3, panel:GetTall() - 80)
        add.DoClick = function (p)
            if #self.Selected == 0 || groups:GetSelectedLine() == nil then
                return
            end

            for i = 1, #self.Selected, 1 do
                local found = false

                for d = 1, #self.groups[groups:GetSelectedLine()].doors, 1 do
                    if self.groups[groups:GetSelectedLine()].doors[d].Id == self.selected[i] then
                        found = true
                        break
                    end
                end

                if !found then
                    table.insert(self.groups[groups:GetSelectedLine()].doors, {
                        Name = "",
                        Id = self.selected[i],
                        CoOwners = {}
                    })
                end
            end

            table.Empty(self.selected)

            doors:Clear()
            coOwners:Clear()

            for i = 1, #self.groups[groups:GetSelectedLine()].doors, 1 do
                doors:AddLine(self.groups[groups:GetSelectedLine()].doors[i].name, self.groups[groups:GetSelectedLine()].doors[i].id)
            end
        end

        local create = vgui.Create("DButton", panel)
        create:SetText("Group Selected Door(s)")
        create:SetSize(panel:GetWide() / 4, 40)
        create:SetPos((panel:GetWide() / 4) * 3, panel:GetTall() - 40)
        create.DoClick = function (p)
            if #self.selected == 0 then
                return
            end

            self:TextEntryBox(frame, "Group Name", function (text)
                local door = {
                    Name = text,
                    Owner = "",
                    Doors = {}
                }
    
                for i = 1, #self.selected, 1 do
                    table.insert(door.doors, {
                        Name = "",
                        Id = self.selected[i],
                        CoOwners = {}
                    })
                end
    
                table.Empty(self.selected)
    
                table.insert(self.groups, door)
    
                groups:Clear()
                doors:Clear()
                coOwners:Clear()
    
                for i = 1, #self.groups, 1 do
                    local ply = player.GetBySteamID64(self.groups[i].owner)
                    if IsValid(ply) then
                        groups:AddLine(self.groups[i].name, ply:GetName(), self.groups[i].owner)
                    else
                        groups:AddLine(self.groups[i].name, "", self.groups[i].owner)
                    end
                end
            end)
        end
    end
end

function TOOL:Deploy(newOwner)
end

function TOOL:Holster(weapon)
end

function TOOL:OnDrop()
end

function TOOL:Reload()
end

function TOOL:PrimaryAttack(ply)
    local ent = ply:GetEyeTrace().Entity
    if !IsValid(ent) then
        return
    end

    if ent:GetClass() != "prop_door_rotating" then
        return
    end

    if SERVER then
        if table.HasValue(self.selected, ent:MapCreationID()) then
            return
        end

        table.insert(self.selected, ent:MapCreationID())

        net.Start("AddDoor")
        net.WriteInt(ent:MapCreationID(), 32)
        net.Send(ply)
    end
end

function TOOL:SecondaryAttack(ply)
    if SERVER then
        local ent = ply:GetEyeTrace().Entity
        if !IsValid(ent) then
            return
        end

        if ent:GetClass() != "prop_door_rotating" then
            return
        end

        table.RemoveByValue(self.selected, ent:MapCreationID())

        net.Start("RemoveDoor")
        net.WriteInt(ent:MapCreationID(), 32)
        net.Send(ply)
    end
end

--Hooks
if CLIENT then


    hook.Add("PreDrawHalos", "DoorGroupHalos", function ()
        local wep = LocalPlayer():GetActiveWeapon()
        if !IsValid(wep) then
            return
        end

        if wep:GetClass() != "tool" then
            return
        end
        
        local t = player_manager.RunClass(LocalPlayer(), "GetCurrentTool")
        if t == nil then
            return
        end

        if t.name != TOOL.name then
            return
        end

        local entities = ents.GetAll()

        local highlighted = {}
        for e = 1, #entities, 1 do
            for s = 1, #TOOL.selected, 1 do
                if entities[e]:GetNWInt("MapCreationId") == TOOL.selected[s] then
                    table.insert(highlighted, entities[e])
                end
            end
        end

        halo.Add(highlighted, Color(255, 255, 0))
    end)

    net.Receive("AddDoor", function (len, ply)
        table.insert(TOOL.selected, net.ReadInt(32))
    end)

    net.Receive("RemoveDoor", function (len, ply)
        table.RemoveByValue(TOOL.selected, net.ReadInt(32))
    end)
end

if SERVER then
    hook.Add("InitPostEntity", "ShareMapCreationId", function ()
        local entities = ents.GetAll()
        for e = 1, #entities, 1 do
            if entities[e]:GetClass() == "prop_door_rotating" then
                entities[e]:SetNWInt("MapCreationId", entities[e]:MapCreationID());
            end
        end
    end)
end

tool.Add(TOOL)