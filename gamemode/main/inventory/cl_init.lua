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

local tbl = {}
local DataSaverSlot = {}
local Saver = nil
net.Receive("DragNDropRust", function() tbl = net.ReadTable() end)
function DoDrop(self, panels, bDoDrop, Command, x, y)
    if bDoDrop then
        for k, v in pairs(DataSaverSlot) do
            print(v.Enetity)
            if not IsValid(v.Enetity) then table.remove(DataSaverSlot, k) end
        end

        tbl[1] = nil
        table.insert(DataSaverSlot, {
            Enetity = self,
            Slotz = self.CodeSortID,
            SweetSlot = self.CodeID,
            SlotID = {
                x = x,
                y = y
            }
        })

        --PrintTable(DataSaverSlot)
        panels[1]:SetParent(self)
    end
end

local function fBombDrawBottomBar(frm, data, dataSaver)
    if IsValid(frm) then
        local frame = vgui.Create("DPanel", frm)
        frame:SetSize(500, 90)
        frame:SetPos(w * 0.35, h * 0.85)
        frame.Paint = function(s, w, h) draw.RoundedBox(0, 0, 0, w, h, Color(65, 65, 65, 100)) end
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
        frame2.Paint = function(s, w, h) draw.RoundedBox(0, 0, 0, w, h, Color(65, 65, 65, 100)) end
        local grid2 = vgui.Create("ThreeGrid", frame2)
        grid2:Dock(FILL)
        grid2:DockMargin(4, 4, 4, 4)
        grid2:InvalidateParent(true)
        grid2:SetColumns(7)
        grid2:SetHorizontalMargin(2)
        grid2:SetVerticalMargin(2)
        local pnl2 = {}
        for i = 1, 42 do
            if not IsValid(pnl2[i]) then
                pnl2[i] = vgui.Create("DPanel")
                pnl2[i]:SetTall(80)
                pnl2[i]:SetWide(180)
                pnl2[i].CodeID = i
                pnl2[i]:Receiver("DroppableRust", DoDrop)
                grid2:AddCell(pnl2[i])
            end
        end

        for k, v in pairs(tbl) do
            local DermaImageButton = vgui.Create("DImageButton", pnl1[v.Slotz])
            DermaImageButton:SetSize(64, 64)
            DermaImageButton:SetImage("icon16/bomb.png")
            DermaImageButton:Droppable("DroppableRust")
            DermaImageButton.DoClick = function() MsgN("You clicked the image!") end
        end

        for k, v in pairs(dataSaver) do
            if v.Slotz ~= nil then
                local DermaImageButton = vgui.Create("DImageButton", pnl1[v.Slotz])
                DermaImageButton:SetSize(64, 64)
                DermaImageButton:SetImage("icon16/bomb.png")
                DermaImageButton:Droppable("DroppableRust")
                DermaImageButton.DoClick = function() MsgN("You clicked the image!") end
            elseif v.SweetSlot ~= nil then
                local DermaImageButton = vgui.Create("DImageButton", pnl2[v.SweetSlot])
                DermaImageButton:SetSize(64, 64)
                DermaImageButton:SetImage("icon16/bomb.png")
                DermaImageButton:Droppable("DroppableRust")
                DermaImageButton.DoClick = function() MsgN("You clicked the image!") end
            end
        end
    end
end

function GM:ScoreboardShow()
    frm = FBomb()
    fBombDrawBottomBar(frm, tbl, DataSaverSlot)
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