print("Inventory Loaded")
local w, h = ScrW(), ScrH()
hook.Add("OnScreenSizeChanged", "FixEdWidTh", function(_, _, nw, nh) w, h = ScrW(), ScrH() end)
local frm = nil
local function FBomb()
    local frame = vgui.Create("DPanel")
    frame:SetSize(w, h)
    frame:Center()
    frame.Paint = function(s, w, h) draw.RoundedBox(0, 0, 0, w, h, Color(65, 65, 65, 100)) end
    return frame
end

GLOBAL = GLOBAL or {}
GLOBAL.tbl = {}
local DataSaverSlot = {}
net.Receive("DragNDropRust", function() GLOBAL.tbl = net.ReadTable() end)
function DoDrop(self, panels, bDoDrop, Command, x, y)
    if bDoDrop and IsValid(panels[1]) and IsValid(self) then
        local csi = self.CodeSortID or -1
        local cso = self.CodeID or -1
        net.Start("gRustWriteSlot")
        net.WriteFloat(csi)
        net.WriteFloat(cso)
        net.WriteString(panels[1].Weap)
        net.WriteFloat(panels[1].OldSlot or -1)
        net.SendToServer()
        panels[1]:SetParent(self)
    end
end

local function fBombDrawBottomBar(frms, data, dataSaver)
    if IsValid(frms) then
        local frame = vgui.Create("DPanel", frms)
        frame:SetSize(500, 90)
        frame:SetPos(w * 0.35, h * 0.85)
        frame.Paint = function(s, ww, hh) draw.RoundedBox(0, 0, 0, ww, hh, Color(65, 65, 65, 100)) end
        local grid = vgui.Create("ThreeGrid", frame)
        grid:Dock(FILL)
        grid:DockMargin(4, 4, 4, 4)
        grid:InvalidateParent(true)
        grid:SetColumns(7)
        grid:SetHorizontalMargin(2)
        grid:SetVerticalMargin(2)
        local pnl1 = {}
        for i = 1, 7 do
            if not IsValid(pnl1[i]) then
                pnl1[i] = vgui.Create("DPanel")
                pnl1[i]:SetTall(80)
                pnl1[i]:SetWide(180)
                pnl1[i].CodeSortID = i
                pnl1[i]:Receiver("DroppableRust", DoDrop)
                grid:AddCell(pnl1[i])
            end
        end

        local frame2 = vgui.Create("DPanel", frm)
        frame2:SetSize(490, 500)
        frame2:SetPos(w * 0.35, h * 0.25)
        frame2.Paint = function(s, ww, hh) draw.RoundedBox(0, 0, 0, ww, hh, Color(65, 65, 65, 100)) end
        local grid2 = vgui.Create("ThreeGrid", frame2)
        grid2:Dock(FILL)
        grid2:DockMargin(4, 4, 4, 4)
        grid2:InvalidateParent(true)
        grid2:SetColumns(7)
        grid2:SetHorizontalMargin(2)
        grid2:SetVerticalMargin(2)
        local pnl2 = {}
        for i = 8, 49 do
            if not IsValid(pnl2[i]) then
                pnl2[i] = vgui.Create("DPanel")
                pnl2[i]:SetTall(80)
                pnl2[i]:SetWide(180)
                pnl2[i].CodeID = i
                pnl2[i]:Receiver("DroppableRust", DoDrop)
                grid2:AddCell(pnl2[i])
            end
        end

        for _, j in pairs(GLOBAL.tbl) do
            if j.Slotz ~= nil and j.Slotz >= 1 and j.Slotz <= 7 then
                local DermaImageButton = vgui.Create("DImageButton", pnl1[j.Slotz])
                DermaImageButton:SetSize(70, 71)
                DermaImageButton:SetPos(0, 4)
                DermaImageButton:SetImage(j.Img)
                DermaImageButton:Droppable("DroppableRust")
                DermaImageButton.DoClick = function() MsgN("You clicked the image!") end
                DermaImageButton.Model_IMG = j.Img
                DermaImageButton.Weap = j.Weapon
                DermaImageButton.OldSlot = j.Slotz
                DermaImageButton.Paint = function(s, w, h) draw.DrawText(tostring(j.Amount), "Default", 0, 0, Color(0, 0, 0), TEXT_ALIGN_LEFT) end
            elseif j.Slotz ~= nil and j.Slotz >= 8 and j.Slotz <= 49 then
                local DermaImageButton = vgui.Create("DImageButton", pnl2[j.Slotz])
                DermaImageButton:SetSize(70, 71)
                DermaImageButton:SetPos(0, 4)
                DermaImageButton:SetImage(j.Img)
                DermaImageButton:Droppable("DroppableRust")
                DermaImageButton.DoClick = function() MsgN("You clicked the image!") end
                DermaImageButton.Model_IMG = j.Img
                DermaImageButton.Weap = j.Weapon
                DermaImageButton.OldSlot = j.Slotz
                DermaImageButton.Paint = function(s, w, h) draw.DrawText(tostring(j.Amount), "Default", 0, 0, Color(0, 0, 0), TEXT_ALIGN_LEFT) end
            end
        end
    end
end

function GM:ScoreboardShow()
    frm = FBomb()
    fBombDrawBottomBar(frm, GLOBAL.tbl, DataSaverSlot)
    gui.EnableScreenClicker(true)
end

function GM:ScoreboardHide()
    if IsValid(frm) then frm:Remove() end
    gui.EnableScreenClicker(false)
end

hook.Add("PlayerBindPress", "Bindpressgturst", function(ply, bind, pressed)
    if not pressed then return end
    local sub = string.gsub(bind, "slot", "")
    local num = tonumber(sub)
    if not num or num <= 0 or num > 6 then return end
    local found = false
    for k, v in pairs(GLOBAL.tbl) do
        if num == v.Slotz then
            net.Start("gRustSelectWep")
            net.WriteString(v.Weapon)
            net.SendToServer()
            found = true
        end
    end

    if not found then
        net.Start("gRustSelectWep")
        net.WriteString("rust_hands")
        net.SendToServer()
    end
end)