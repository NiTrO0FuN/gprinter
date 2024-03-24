include("shared.lua")

local black_color = Color(15,15,15)
local white_color = Color(255,255,255)
local green_color = Color(30,200,30)
local light_green_color = Color(30,200,30,100)
local dark_green_color = Color(15,130,15)
local dark_grey_color = Color(20,20,20,230)
local light_grey_color = Color(35,35,35,240)
local red_color = Color(200,30,30)
local DrawColor={Color(36,36,36),Color(255,223,127)}

surface.CreateFont( "PrintMoney", {
	font		= "Roboto Condensed",
	size		= 30,
	weight		= 500,
	antialias = true,
	extended = true,
})

surface.CreateFont( "PrintMoneyBig", {
	font		= "Roboto Condensed",
	size		= 50,
	weight		= 500,
	antialias = true,
	extended = true,
})

local function RespX(x)
    return x/1920 * ScrW()
end

local function RespY(y)
    return y/1080 * ScrH()
end

local function stringRandom( length )
	local length = tonumber( length )
    if length < 1 then return end

    local result = {}

    for i = 1, length do
        result[i] = string.char( math.random(32, 126) )
    end

    return table.concat(result)

end

local lastRandomDraw = CurTime()
local interval = 0.5
local randomString = stringRandom(math.random(20, 23))
local randomColor = HSVToColor(math.random(1,360),1,1)

function ENT:Draw()
    self:DrawModel()
    self:SetColor(DrawColor[self:GetpType()])

    cam.Start3D2D(self:LocalToWorld(Vector(-24,-0.4,4)),self:LocalToWorldAngles(Angle(0,0,90)), 0.1)
        draw.NoTexture()
        surface.SetDrawColor(35, 35, 35)
        surface.DrawRect(0, 0, 300, 80)
        surface.SetFont("PrintMoney")
        
        local moneyAmount = self:GetMoneyAmount()
        local moneySize = surface.GetTextSize(moneyAmount)
        if moneyAmount >0 then
            surface.SetTextColor(30, 200, 30)
        else
            surface.SetTextColor(200, 30, 30)
        end
        surface.SetTextPos(150-moneySize/2, 10)
        
        surface.DrawText(DarkRP.formatMoney(moneyAmount))

        surface.SetDrawColor(200, 200, 200)
        surface.DrawOutlinedRect(14, 44, 272, 22, 1)
        surface.SetDrawColor(30, 200, 30)
        surface.DrawRect(15, 45, 270*self:GetProgress(), 20)

        surface.SetTextPos(20, 20)
        surface.SetFont("ChatFont")
        if self:GetActive() then
            surface.SetTextColor(30, 200, 30)
            surface.DrawText("Printing ...")
        else
            surface.SetTextColor(200, 30, 30)
            surface.DrawText("Paused")
        end

    cam.End3D2D()
    cam.Start3D2D(self:LocalToWorld(Vector(-23,11,4.5)),self:LocalToWorldAngles(Angle(0,0,0)), 0.1)
    draw.NoTexture()
    surface.SetDrawColor(35, 35, 35)
    surface.DrawRect(0, 0, 190, 105)

    draw.SimpleText("C:\\Users\\Maxou: find bestdev ", "Default", 10, 10, light_green_color, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    draw.SimpleText("nitro_fun","Default", 20, 30, light_green_color, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

    draw.SimpleText("C:\\Users\\Maxou: gg_hash.exe ", "Default", 10, 60, light_green_color, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    if CurTime()>lastRandomDraw+interval then
        randomColor = HSVToColor(math.random(1,360),1,1)
        randomString=stringRandom(math.random(20,23))
        lastRandomDraw=CurTime()
    end
    if self:GetActive() then
        draw.SimpleText(randomString, "Default", 20, 80, randomColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end
    cam.End3D2D()
end

local Frame
net.Receive("g_printer_use", function()
    local print_ent = net.ReadEntity()
    net.Receive("g_printer_destroyed", function()
        if print_ent == net.ReadEntity() and IsValid(Frame) then
            Frame:Close()
            gui.EnableScreenClicker(false)
        end
    end)
    if IsValid(Frame) then return end
    Frame = vgui.Create("DFrame")
    Frame:Center()
    Frame:SetSize( 0, 0 ) 
    Frame:SizeTo(RespX(800),RespY(400),0.2)
    Frame.OnSizeChanged = function()
        Frame:Center()
    end
    Frame:SetVisible( true ) 
    Frame:SetDraggable( false )
    Frame:SetTitle('') 
    Frame:ShowCloseButton( false ) 

    gui.EnableScreenClicker(true)

    Frame.info = vgui.Create("DPanel", Frame)
    local md = markup.Parse("<font=Info_Text>".. language.GetPhrase("printer.be_careful") .."</font>", RespX(700))
    Frame.info:SetSize(RespX(700),RespY(100))
    Frame.info:SetPos(RespX(50),RespY(20))
    Frame.info.Paint = function(s,w,h)

        md:Draw(RespX(350),0,TEXT_ALIGN_CENTER)
    end

    Frame.closeBtn = vgui.Create("DButton", Frame)
    Frame.closeBtn.DoClick = function() Frame:Close() gui.EnableScreenClicker(false) end
    Frame.closeBtn:SetSize(RespX(35),RespY(35))
    Frame.closeBtn:SetPos(RespX(800-35),0)
    Frame.closeBtn.Paint = function(s, w,h)
        draw.NoTexture()
        surface.SetDrawColor(200, 30, 30, 200)
        if s:IsHovered() then
            surface.SetDrawColor(255, 70, 70, 200)
        end
        surface.DrawRect(0, 0, w, h)
    end
    Frame.closeBtn:SetText("X")
    Frame.closeBtn:SetTextColor(Color(255,255,255))

    Frame.Paint = function(s, w, h)
        draw.NoTexture()
        surface.SetDrawColor(20,20,20,200)
        surface.DrawRect(0, 0, w, h)
    end

    Frame.moneyAmount = vgui.Create("DPanel", Frame)
    Frame.moneyAmount:SetSize(RespX(800),RespY(50))
    Frame.moneyAmount:SetPos(0,RespY(50))
    Frame.moneyAmount.Paint = function(s,w,h)

        draw.SimpleText(DarkRP.formatMoney(print_ent:GetMoneyAmount()), "PrintMoneyBig", RespX(400), RespY(25), print_ent:GetMoneyAmount()>0 and green_color or red_color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    Frame.progressBar = vgui.Create("DPanel", Frame)
    Frame.progressBar:SetPos(RespX(50),RespY(150))
    Frame.progressBar:SetSize(RespX(700),RespY(60))
    Frame.progressBar.Paint = function(s,w, h)
        draw.RoundedBox(0, 0, 0, w, h, white_color)
        draw.RoundedBox(0, 0, 0, w*print_ent:GetProgress(), h, green_color)
    end

    Frame.takeMoneyBtn = vgui.Create("DButton", Frame)
    Frame.takeMoneyBtn:SetSize(RespX(300),RespY(50))
    Frame.takeMoneyBtn:SetPos(RespX(400-300-25),RespY(300))
    Frame.takeMoneyBtn.DoClick = function()
        net.Start("g_printer_take")
            net.WriteEntity(print_ent)
        net.SendToServer()
    end
    Frame.takeMoneyBtn.Paint = function(s,w,h)
        draw.RoundedBox(5, 0, 0, w, h, dark_green_color)
    end
    Frame.takeMoneyBtn:SetText("#printer.take_money")
    Frame.takeMoneyBtn:SetTextColor(white_color)
    Frame.takeMoneyBtn:SetFont("Trebuchet24")

    Frame.pauseBtn = vgui.Create("DButton", Frame)
    Frame.pauseBtn:SetSize(RespX(300),RespY(50))
    Frame.pauseBtn:SetPos(RespX(400+25),RespY(300))
    Frame.pauseBtn.DoClick = function()
        net.Start("g_printer_pause")
            net.WriteEntity(print_ent)
        net.SendToServer()
        timer.Simple(0.2, function() Frame.pauseBtn:SetText(print_ent:GetActive() and "#printer.pause_action" or "#printer.start_action") end)
    end
    Frame.pauseBtn.Paint = function(s,w,h)
        local color = dark_grey_color
        if print_ent:GetActive() then color=light_grey_color end
        draw.RoundedBox(5, 0, 0, w, h, color)
    end
    Frame.pauseBtn:SetText(print_ent:GetActive() and "#printer.pause_action" or "#printer.start_action")
    Frame.pauseBtn:SetTextColor(white_color)
    Frame.pauseBtn:SetFont("Trebuchet24")

end)