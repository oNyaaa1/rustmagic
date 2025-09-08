print("Inventory Loaded")
local w, h = ScrW(), ScrH()
hook.Add("OnScreenSizeChanged", "FixEdWidTh", function(_, _, nw, nh) w, h = nw, nh end)
local frame, frame2 = nil, nil -- Globals for inventory state
local pnl = {} -- hotbar panels
local pnln = {} -- inventory panels (7..36)
local pnln2 = {} -- left-panel quick slots (37..42)
local btn = {} -- item buttons
local slotData = {} -- slot data received from server
local LeftWidth = ScrW() * 0.280
local LeftShift = ScrW() * 0.0055
local Frame = nil
net.Receive("SendSlots", function()
    slotData = net.ReadTable()
    local oldslot = net.ReadFloat()
    local ns = net.ReadFloat()
    local data = {}
    for k, v in pairs(slotData) do
        if ns == v.Slot then data = v end
    end

    if oldslot ~= -1 then
        if IsValid(btn[oldslot]) then btn[oldslot]:Remove() end
        slotData[oldslot] = nil
    end

    if data and IsValid(pnl[ns]) then
        btn[ns] = vgui.Create("DImageButton")
        btn[ns]:SetImage(data.model)
        btn[ns]:Dock(FILL)
        btn[ns].TypeWep = data.Name
        --btn[k].GetnImage = v.model
        btn[ns].SlotID = data.Slot
        btn[ns]:Droppable("myDNDname")
        btn[ns]:SetParent(pnl[ns])
        btn[ns].Active = true
        net.Start("gRustWriteSlot")
        net.WriteString(btn[ns].TypeWep)
        net.SendToServer()
    end

    if data and IsValid(pnln[ns]) then
        btn[ns] = vgui.Create("DImageButton")
        btn[ns]:SetImage(data.model)
        btn[ns]:Dock(FILL)
        btn[ns].TypeWep = data.Name
        --btn[k].GetnImage = v.model
        btn[ns].SlotID = data.Slot
        btn[ns]:Droppable("myDNDname")
        btn[ns]:SetParent(pnln[ns])
        btn[ns].Active = true
        net.Start("gRustWriteSlot")
        net.WriteString("rust_hands")
        net.SendToServer()
        -- Update display with stack info
    end
end)

function DoDrop(self, panels, dropped, _, x, y)
    if dropped then
        net.Start("DragNDropRust")
        net.WriteFloat(panels[1].SlotID)
        net.WriteFloat(self.SlotID)
        net.WriteString(panels[1].TypeWep)
        net.SendToServer()
        panels[1]:SetParent(self)
        panels[1]:SetPos(x - 25, y - 25)
    end
end

function PossibleWear(self, panels, dropped, _, x, y)
    if dropped then end
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
    Panel:SetTall(h - 50)
    Panel.Paint = function(_, fw, fh) end
    local Panel2 = Frame:Add("DPanel")
    Panel2:Dock(BOTTOM)
    Panel2:SetWide(LeftWidth - LeftShift)
    Panel2:SetTall(100)
    Panel2.Paint = function(_, fw, fh) end
    local grid = vgui.Create("ThreeGrid", Panel2)
    grid:Dock(FILL)
    grid:DockMargin(30, 4, 4, 4)
    grid:SetColumns(7)
    grid:SetHorizontalMargin(2)
    grid:SetVerticalMargin(2)
    grid:InvalidateLayout(true)
    grid:InvalidateParent(true)
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
        pnln2[i]:SetTall(80)
        pnln2[i].SlotID = i
        pnln2[i].RealSlotID = i
        pnln2[i].Paint = function(_, pw, ph)
            surface.SetDrawColor(0, 0, 0, 100)
            surface.DrawRect(0, 0, pw, ph)
            surface.SetDrawColor(94, 94, 94, 150)
            surface.DrawRect(0, 0, pw, ph)
        end

        pnln2[i]:Receiver("myDNDname", DoDropWear)
        grid:AddCell(pnln2[i])
    end

    -- Populate items
    for k, v in pairs(data) do
        if not istable(v) then continue end
        if not isnumber(v.Slot) then continue end
        local parentPanel = nil
        local realSlotID = nil
        if parentPanel then
            if not IsValid(btn[k]) then
                btn[k] = vgui.Create("DImageButton")
                local matPath = v.model or "materials/items/tools/rock.png"
                if not file.Exists(matPath, "GAME") then matPath = "materials/items/tools/rock.png" end
                btn[k]:SetImage(matPath)
                btn[k]:Dock(FILL)
                btn[k].TypeWep = v.Name
                --btn[k].GetnImage = matPath
                btn[k].SlotID = realSlotID
                btn[k]:Droppable("myDNDname")
                btn[k]:SetParent(parentPanel)
                btn[k].Active = true
                -- Update display with stack info
                UpdateStackDisplay(btn[k], v)
            else
                btn[k]:SetParent(parentPanel)
                btn[k].SlotID = realSlotID
                local matPath = v.model or "materials/items/tools/rock.png"
                if not file.Exists(matPath, "GAME") then matPath = "materials/items/tools/rock.png" end
                btn[k]:SetImage(matPath)
                -- Update display with stack info
                UpdateStackDisplay(btn[k], v)
            end
        end
    end

    local PlayerModel = Panel:Add("DModelPanel")
    PlayerModel:Dock(FILL)
    PlayerModel:SetModel(LocalPlayer():GetModel())
    PlayerModel.DropPanel = true
    PlayerModel.LayoutEntity = function(me, ent)
        ent:SetAngles(Angle(0, 55, 0))
        ent:SetPos(Vector(20, 10, 0))
    end

    function PlayerModel:LayoutEntity(ent)
        ent:SetBodygroup(3, 1)
    end

    PlayerModel.Think = function(me) me:SetModel(LocalPlayer():GetModel()) end
end

local function COD(data)
    if IsValid(frame2) then frame2:Remove() end
    frame2 = vgui.Create("DPanel")
    frame2:SetSize(500, 100)
    frame2:SetPos(ScrW() * 0.29 + 93, ScrH() * 0.85)
    frame2.Paint = function(_, w, h) end
    local grid2 = vgui.Create("ThreeGrid", frame2)
    grid2:Dock(FILL)
    grid2:DockMargin(4, 4, 4, 4)
    grid2:SetColumns(6)
    grid2:SetHorizontalMargin(2)
    grid2:SetVerticalMargin(2)
    grid2:InvalidateParent(true)
    grid2:InvalidateLayout(true)
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
            surface.DrawRect(0, 0, pw, ph)
        end

        pnl[i]:Receiver("myDNDname", DoDrop)
        grid2:AddCell(pnl[i])
    end
end

net.Receive("gRust_COD", function() COD() end)
function GM:ScoreboardShow()
    local ply = LocalPlayer()
    if not ply:Alive() then return end
    LeftPanel(slotData)
    gui.EnableScreenClicker(true)
    if not IsValid(frame) then
        frame = vgui.Create("DPanel")
        frame:SetSize(488, 418)
        frame:SetPos(w * 0.351, h * 0.38)
        frame.Paint = function(_, fw, fh)
            surface.SetDrawColor(0, 0, 0, 200)
            surface.DrawRect(0, 0, fw, fh)
        end

        local grid = vgui.Create("ThreeGrid", frame)
        grid:Dock(FILL)
        grid:DockMargin(4, 4, 4, 4)
        grid:SetColumns(6)
        grid:SetHorizontalMargin(2)
        grid:SetVerticalMargin(2)
        grid:InvalidateParent(true)
        grid:InvalidateLayout(true)
        -- Clear existing inventory buttons
        for i = 7, 36 do
            if btn[i] and IsValid(btn[i]) then
                btn[i]:Remove()
                btn[i] = nil
            end
        end

        -- Create inventory slots
        for i = 7, 36 do
            pnln[i] = vgui.Create("DPanel")
            pnln[i]:SetTall(80)
            pnln[i].SlotID = i
            pnln[i].Paint = function(_, pw, ph)
                surface.SetDrawColor(0, 0, 0, 100)
                surface.DrawRect(0, 0, pw, ph)
                surface.SetDrawColor(94, 94, 94, 150)
                surface.DrawRect(0, 0, pw, ph)
            end

            pnln[i]:Receiver("myDNDname", DoDrop)
            grid:AddCell(pnln[i])
        end

        for k, v in pairs(slotData) do
            if IsValid(pnln[v.Slot]) and istable(v) and v.Slot and v.Slot >= 1 and v.Slot <= 36 then
                btn[k] = vgui.Create("DImageButton")
                btn[k]:SetImage(v.model)
                btn[k]:Dock(FILL)
                btn[k].TypeWep = v.Name
                --btn[k].GetnImage = v.model
                btn[k].SlotID = v.Slot
                btn[k]:Droppable("myDNDname")
                btn[k]:SetParent(pnln[v.Slot])
                btn[k].Active = true
                -- Update display with stack info
            end
        end

        -- Populate inventory items
        for k, v in pairs(slotData) do
            if IsValid(pnl[v.Slot]) and istable(v) and v.Slot and v.Slot >= 1 and v.Slot <= 36 and v.model ~= nil then
                btn[k] = vgui.Create("DImageButton")
                btn[k]:SetImage(v.model)
                btn[k]:Dock(FILL)
                btn[k].TypeWep = v.Name
                --btn[k].GetnImage = v.model
                btn[k].SlotID = v.Slot
                btn[k]:Droppable("myDNDname")
                btn[k]:SetParent(pnl[v.Slot])
                btn[k].Active = true
                -- Update display with stack info
            end
        end
    end
end

function GM:ScoreboardHide()
    if not LocalPlayer():Alive() then return end
    if IsValid(frame) then
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
end

hook.Add("PlayerBindPress", "Bindpressgturst", function(ply, bind, pressed)
    if not pressed then return end
    local sub = string.gsub(bind, "slot", "")
    local num = tonumber(sub)
    if not num or num <= 0 or num > 6 then return end
    local found = false
    if IsValid(btn[num]) then
        net.Start("gRustWriteSlot")
        net.WriteString(btn[num].TypeWep)
        net.SendToServer()
        found = true
    end

    if not found then
        net.Start("gRustWriteSlot")
        net.WriteString("rust_hands")
        net.SendToServer()
    end
end)