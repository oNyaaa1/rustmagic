

gRust.Notifications = gRust.Notifications or {}
gRust.NotificationQueue = gRust.NotificationQueue or {}

local function CreateNotify(text, notificationType, icon, side)
    local typeData = gRust.NotificationTypes[notificationType]
    if not typeData then return end

    local w, h = ScrW(), ScrH()
    local panel = vgui.Create("DPanel")
    panel:SetSize(w * 0.15, h * 0.035)
    panel:SetPos(ScrW() - (w * 0.1), ScrH() + (h * 0.01))

    panel.StartTime = CurTime()
    panel.LifeTime = typeData.Time or 5
    panel.Alpha = 0
    panel.TargetAlpha = 255
    panel.SideText = side or ""
    panel.CurrentY = ScrH() + (h * 0.001)

    panel.Color = typeData.Color
    panel.IconColor = typeData.IconColor
    panel.IconMat = typeData.Icon

    function panel:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, self.Alpha))
        draw.RoundedBox(0, 0, 0, w, h, Color(self.Color.r, self.Color.g, self.Color.b, self.Alpha))

        if self.IconMat then
            surface.SetDrawColor(self.IconColor.r, self.IconColor.g, self.IconColor.b, self.Alpha)
            surface.SetMaterial(self.IconMat)
            surface.DrawTexturedRect(4, h/2 - 15, 28, 28)
        end

        surface.SetFont("RUST.25px")
        surface.SetTextColor(255, 255, 255, self.Alpha)
        surface.SetTextPos(32, h/2 - 12)
        surface.DrawText(text)

        if self.SideText ~= "" then
            surface.SetFont("RUST.25px")
            surface.SetTextColor(255, 255, 255, self.Alpha)
            surface.SetTextPos(w - surface.GetTextSize(self.SideText) - 10, h/2 - 12)
            surface.DrawText(self.SideText)
        end
    end

    function panel:Think()
        local timeAlive = CurTime() - self.StartTime

        local stackIndex = 0
        for i, p in ipairs(gRust.NotificationQueue) do
            if p == self then
                stackIndex = i
                break
            end
        end

        local targetY = ScrH() - (h * 0.20) - ((stackIndex - 1) * (h * 0.04))

        self.CurrentY = Lerp(FrameTime() * 10, self.CurrentY, targetY)
        self:SetPos(ScrW() - (w * 0.16), self.CurrentY)

        if timeAlive < 0.5 then
            self.Alpha = math.Approach(self.Alpha, self.TargetAlpha, FrameTime() * 500)
        elseif timeAlive > self.LifeTime - 0.5 then
            self.TargetAlpha = 0
            self.Alpha = math.Approach(self.Alpha, self.TargetAlpha, FrameTime() * 500)
            if self.Alpha <= 0 then
                self:Remove()
                table.RemoveByValue(gRust.NotificationQueue, self)
            end
        end

        if typeData.Think then
            typeData.Think(self)
        end
    end

    table.insert(gRust.NotificationQueue, panel)
    return panel
end

net.Receive("gRust.Notify", function()
    local text = net.ReadString()
    local notificationType = net.ReadUInt(4)
    local icon = net.ReadString()
    local side = net.ReadString()

    CreateNotify(text, notificationType, icon, side)
end)
