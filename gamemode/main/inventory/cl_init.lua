print("Inventory Loaded")
local w, h = ScrW(), ScrH()
hook.Add("OnScreenSizeChanged", "FixEdWidTh", function(_, _, nw, nh) w, h = nw, nh end)

local frame, frame2, Frame = nil, nil, nil -- Globals for inventory state
local pnl = {} -- hotbar panels
local pnln = {} -- inventory panels (7..36)
local pnln2 = {} -- left-panel quick slots (37..42)
local btn = {} -- item buttons
local slotData = {} -- slot data received from server

local LeftWidth = ScrW() * 0.280
local LeftShift = ScrW() * 0.0055

-- Helper function to update stack display
local function UpdateStackDisplay(button, itemData)
    if button and itemData and itemData.Amount then
        -- This function can be expanded based on your needs
    end
end

net.Receive("SendSlots", function()
    slotData = net.ReadTable()
    local oldslot = net.ReadFloat()
    local ns = net.ReadFloat()
    
    if oldslot ~= -1 then
        if IsValid(btn[oldslot]) then btn[oldslot]:Remove() end
        slotData[oldslot] = nil
    end

    -- Populate inventory items (slots 7-36) - now 30 slots total
    for k, v in pairs(slotData) do
        if istable(v) and v.Slot and v.Slot >= 7 and v.Slot <= 36 and v.model ~= nil then
            if IsValid(pnln[v.Slot]) then
                if IsValid(btn[k]) then btn[k]:Remove() end
                
                btn[k] = vgui.Create("DImageButton")
                btn[k]:SetImage(v.model)
                btn[k]:Dock(FILL)
                btn[k].TypeWep = v.Name
                btn[k].Class = v.Class
                btn[k].SlotID = v.Slot
                btn[k]:Droppable("myDNDname")
                btn[k]:SetParent(pnln[v.Slot])
                btn[k].Active = true
                btn[k].Paint = function(s, w, h) 
                    draw.DrawText(v.Amount or "1", "DermaDefault", 0, 0, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT) 
                end
            end
        end

        -- Populate hotbar items (slots 1-6)
        if istable(v) and v.Slot and v.Slot >= 1 and v.Slot <= 6 and v.model ~= nil then
            if IsValid(pnl[v.Slot]) then
                if IsValid(btn[k]) then btn[k]:Remove() end
                
                btn[k] = vgui.Create("DImageButton")
                btn[k]:SetImage(v.model)
                btn[k]:Dock(FILL)
                btn[k].TypeWep = v.Name
                btn[k].Class = v.Class
                btn[k].SlotID = v.Slot
                btn[k]:Droppable("myDNDname")
                btn[k]:SetParent(pnl[v.Slot])
                btn[k].Active = true
                btn[k].Paint = function(s, w, h) 
                    draw.DrawText(v.Amount or "1", "DermaDefault", 0, 0, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT) 
                end
            end
        end
    end
end)

function DoDrop(self, panels, dropped, _, x, y)
    if dropped and panels[1] then
        net.Start("DragNDropRust")
        net.WriteFloat(panels[1].SlotID)
        net.WriteFloat(self.SlotID)
        net.WriteString(panels[1].TypeWep or "")
        net.WriteString(panels[1].Class or "")
        net.SendToServer()
        panels[1]:SetParent(self)
        panels[1]:Dock(FILL)
    end
end

function DoDropWear(self, panels, dropped, _, x, y)
    if dropped and panels[1] then
        -- Add wear slot logic here if needed
        panels[1]:SetParent(self)
        panels[1]:Dock(FILL)
    end
end

local function LeftPanel(data)
    if IsValid(Frame) then Frame:Remove() end
    Frame = vgui.Create("DPanel")
    Frame:SetSize(530, 858)
    Frame:SetPos(w * 0.01, h * 0.01)
    Frame.Paint = function(_, fw, fh) end
    
    local Panel = Frame:Add("DPanel")
    Panel:Dock(TOP)
    Panel:SetWide(LeftWidth - LeftShift)
    Panel:SetTall(h - 150) -- Adjusted to leave room for bottom panel
    Panel.Paint = function(_, fw, fh) end
    
    local Panel2 = Frame:Add("DPanel")
    Panel2:Dock(BOTTOM)
    Panel2:SetWide(LeftWidth - LeftShift)
    Panel2:SetTall(100)
    Panel2.Paint = function(_, fw, fh) end
    
    local grid = vgui.Create("DIconLayout", Panel2)
    grid:Dock(FILL)
    grid:DockMargin(30, 4, 4, 4)
    grid:SetSpaceY(2)
    grid:SetSpaceX(2)
    
    -- Clear existing left panel buttons
    for i = 37, 43 do
        if btn[i] and IsValid(btn[i]) then
            btn[i]:Remove()
            btn[i] = nil
        end
    end

    -- Create quick slots
    for i = 37, 43 do
        pnln2[i] = vgui.Create("DPanel")
        pnln2[i]:SetSize(80, 80)
        pnln2[i].SlotID = i
        pnln2[i].RealSlotID = i
        pnln2[i].Paint = function(_, pw, ph)
            surface.SetDrawColor(0, 0, 0, 100)
            surface.DrawRect(0, 0, pw, ph)
            surface.SetDrawColor(94, 94, 94, 150)
            surface.DrawOutlinedRect(0, 0, pw, ph)
        end

        pnln2[i]:Receiver("myDNDname", DoDropWear)
        grid:Add(pnln2[i])
    end

    -- Populate quick slot items
    for k, v in pairs(data or {}) do
        if istable(v) and v.Slot and v.Slot >= 37 and v.Slot <= 43 then
            local parentPanel = pnln2[v.Slot]
            if IsValid(parentPanel) then
                if IsValid(btn[k]) then btn[k]:Remove() end
                
                btn[k] = vgui.Create("DImageButton")
                btn[k]:SetImage(v.model or "")
                btn[k]:Dock(FILL)
                btn[k].TypeWep = v.Name
                btn[k].Class = v.Class
                btn[k].SlotID = v.Slot
                btn[k]:Droppable("myDNDname")
                btn[k]:SetParent(parentPanel)
                btn[k].Active = true
                btn[k].Paint = function(s, w, h) 
                    draw.DrawText(v.Amount or "1", "DermaDefault", 0, 0, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT) 
                end
                UpdateStackDisplay(btn[k], v)
            end
        end
    end

    local PlayerModel = Panel:Add("DModelPanel")
    PlayerModel:Dock(FILL)
    PlayerModel:SetModel(LocalPlayer():GetModel())
    PlayerModel.DropPanel = true
    
    function PlayerModel:LayoutEntity(ent)
        if IsValid(ent) then
            ent:SetAngles(Angle(0, 55, 0))
            ent:SetPos(Vector(20, 10, 0))
            ent:SetBodygroup(3, 1)
        end
    end

    PlayerModel.Think = function(me) 
        if IsValid(LocalPlayer()) then
            me:SetModel(LocalPlayer():GetModel()) 
        end
    end
end

local function COD(data)
    if IsValid(frame2) then frame2:Remove() end
    frame2 = vgui.Create("DPanel")
    frame2:SetSize(500, 100)
    frame2:SetPos(ScrW() * 0.29 + 93, ScrH() * 0.85)
    frame2.Paint = function(_, w, h) end
    
    local grid2 = vgui.Create("DIconLayout", frame2)
    grid2:Dock(FILL)
    grid2:DockMargin(4, 4, 4, 4)
    grid2:SetSpaceY(2)
    grid2:SetSpaceX(2)
    
    -- Clear existing hotbar buttons
    for i = 1, 6 do
        if btn[i] and IsValid(btn[i]) then
            btn[i]:Remove()
            btn[i] = nil
        end
    end

    -- Create empty slots
    for i = 1, 6 do
        pnl[i] = vgui.Create("DPanel")
        pnl[i]:SetSize(80, 80)
        pnl[i].SlotID = i
        pnl[i].Paint = function(_, pw, ph)
            surface.SetDrawColor(0, 0, 0, 100)
            surface.DrawRect(0, 0, pw, ph)
            surface.SetDrawColor(94, 94, 94, 150)
            surface.DrawOutlinedRect(0, 0, pw, ph)
        end

        pnl[i]:Receiver("myDNDname", DoDrop)
        grid2:Add(pnl[i])
    end
    
    -- Populate hotbar items
    if data then
        for k, v in pairs(data) do
            if istable(v) and v.Slot and v.Slot >= 1 and v.Slot <= 6 then
                local parentPanel = pnl[v.Slot]
                if IsValid(parentPanel) then
                    if IsValid(btn[k]) then btn[k]:Remove() end
                    
                    btn[k] = vgui.Create("DImageButton")
                    btn[k]:SetImage(v.model or "")
                    btn[k]:Dock(FILL)
                    btn[k].TypeWep = v.Name
                    btn[k].Class = v.Class
                    btn[k].SlotID = v.Slot
                    btn[k]:Droppable("myDNDname")
                    btn[k]:SetParent(parentPanel)
                    btn[k].Active = true
                    btn[k].Paint = function(s, w, h) 
                        draw.DrawText(v.Amount or "1", "DermaDefault", 0, 0, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT) 
                    end
                end
            end
        end
    end
end

net.Receive("gRust_COD", function() COD(slotData) end)

function GM:ScoreboardShow()
    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:Alive() then return end
    
    LeftPanel(slotData)
    gui.EnableScreenClicker(true)
    
    if IsValid(frame) then frame:Remove() end
    
    frame = vgui.Create("DPanel")
    -- Adjusted size to accommodate 6x5 grid properly
    frame:SetSize(520, 440) -- Wider for 6 columns, taller for 5 rows
    frame:SetPos(w * 0.351, h * 0.38)
    frame.Paint = function(_, fw, fh)
        surface.SetDrawColor(0, 0, 0, 200)
        surface.DrawRect(0, 0, fw, fh)
    end

    -- Using DGrid for precise 6x5 layout control
    local grid = vgui.Create("DGrid", frame)
    grid:Dock(FILL)
    grid:DockMargin(8, 8, 8, 8)
    grid:SetCols(6) -- 6 columns
    grid:SetColWide(80) -- Each slot is 80 units wide
    grid:SetRowHeight(80) -- Each slot is 80 units tall
    
    -- Clear existing inventory buttons
    for i = 7, 36 do
        if btn[i] and IsValid(btn[i]) then
            btn[i]:Remove()
            btn[i] = nil
        end
        if pnln[i] and IsValid(pnln[i]) then
            pnln[i] = nil
        end
    end

    -- Create inventory slots (7-36 = 30 slots for 6x5 grid)
    for i = 7, 36 do
        pnln[i] = vgui.Create("DPanel")
        pnln[i]:SetSize(80, 80)
        pnln[i].SlotID = i
        pnln[i].Paint = function(_, pw, ph)
            surface.SetDrawColor(0, 0, 0, 100)
            surface.DrawRect(0, 0, pw, ph)
            surface.SetDrawColor(94, 94, 94, 150)
            surface.DrawOutlinedRect(0, 0, pw, ph)
            
            -- Optional: Draw slot number for debugging
            -- draw.SimpleText(i, "DermaDefault", pw/2, ph/2, Color(100, 100, 100, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        pnln[i]:Receiver("myDNDname", DoDrop)
        grid:AddItem(pnln[i])
    end

    -- Populate inventory items
    for k, v in pairs(slotData) do
        if istable(v) and v.Slot and v.Slot >= 7 and v.Slot <= 36 then
            local parentPanel = pnln[v.Slot]
            if IsValid(parentPanel) then
                if IsValid(btn[k]) then btn[k]:Remove() end
                
                btn[k] = vgui.Create("DImageButton")
                btn[k]:SetImage(v.model or "")
                btn[k]:Dock(FILL)
                btn[k].TypeWep = v.Name
                btn[k].Class = v.Class
                btn[k].SlotID = v.Slot
                btn[k]:Droppable("myDNDname")
                btn[k]:SetParent(parentPanel)
                btn[k].Active = true
                btn[k].Paint = function(s, w, h) 
                    -- Draw item amount in bottom-right corner
                    local amount = v.Amount or "1"
                    draw.SimpleText(amount, "DermaDefault", w-2, h-2, Color(255, 255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
                end
                
                -- Optional: Add tooltip with item info
                btn[k].DoClick = function()
                    -- Could add item use/split functionality here
                end
                
                btn[k].OnCursorEntered = function()
                    -- Could add tooltip showing item details
                end
            end
        end
    end
end

function GM:ScoreboardHide()
    if not IsValid(LocalPlayer()) or not LocalPlayer():Alive() then return end
    
    if IsValid(frame) then
        frame:Remove()
        frame = nil
    end

    if IsValid(Frame) then
        Frame:Remove()
        Frame = nil
    end

    gui.EnableScreenClicker(false)
end

hook.Add("PlayerBindPress", "Bindpressgturst", function(ply, bind, pressed)
    if not pressed then return end
    local sub = string.gsub(bind, "slot", "")
    local num = tonumber(sub)
    if not num or num <= 0 or num > 6 then return end
    
    local found = false
    if IsValid(btn[num]) then
        net.Start("gRustWriteSlot")
        net.WriteString(btn[num].Class or "")
        net.SendToServer()
        found = true
    end

    if not found then
        net.Start("gRustWriteSlot")
        net.WriteString("rust_hands")
        net.SendToServer()
    end
end)