print("Inventory Loaded")
local w, h = ScrW(), ScrH()
hook.Add("OnScreenSizeChanged", "FixEdWidTh", function(_, _, nw, nh) w, h = nw, nh end)
local frm = nil
local function FBomb()
    local frame = vgui.Create("DPanel")
    frame:SetSize(w, h)
    frame:Center()
    frame.Paint = function(s,w,h)
        draw.RoundedBox(0,0,0,w,h,Color(65,65,65,100))
    end
    return frame
end

function GM:ScoreboardShow()
    frm = FBomb()
end

function GM:ScoreboardHide()
    if IsValid(frm) then frm:Remove() end
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