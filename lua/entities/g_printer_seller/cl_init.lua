include("shared.lua")

local color_translucent_gray = Color(30,30,30,200)
local color_translucent_black = Color(0,0,0,200)
local color_green = Color(30,200,30)
local color_white = Color(255,255,255)
local color_yellow = Color(255, 234, 0)

local Frame
local count
local lastTaken

function ENT:Draw()
    self:DrawModel()

    cam.Start3D2D(self:LocalToWorld(Vector(0,-17.5,85)), self:LocalToWorldAngles(Angle(0, 90, 90)), 0.1)
        draw.RoundedBox(25, 0, 0, 350, 100, color_translucent_gray)
        draw.SimpleText("#printer_seller.name", "DermaLarge", 175, 50, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    cam.End3D2D()
end

local function RespX(x)
    return x/1920 * ScrW()
end

local function RespY(y)
    return y/1080 * ScrH()
end

local printer_mat = Material("spawnicons/models/stromic/money_printer.png","noclamp smooth")

surface.CreateFont("Printer_Count", {
    font = "Tahoma",
    size = RespY(75),
    weight = 350,
})

surface.CreateFont("Info_Text", {
    font = "Arial",
    size = RespY(20),
    weight = 200,
})

surface.CreateFont( "DermaLargeResp", {
	font		= "Roboto",
	size		= RespY(32),
	weight		= 300,
	antialias = true,
	extended = true,
})

surface.CreateFont( "Trebuchet24Resp", {
	font		= "Trebuchet",
	size		= RespY(24),
	weight		= 400,
	antialias = true,
	extended = true,
})

net.Receive("g_printer_seller_open", function()
    if IsValid(Frame) then return end

    count = net.ReadInt(4)
    lastTaken = net.ReadFloat()
    local npc = net.ReadEntity()

    Frame = vgui.Create("DFrame")
    Frame:Center()
    Frame:SetSize( 0, 0 ) 
    Frame:SizeTo(RespX(800),RespY(400),0.5)
    Frame.OnSizeChanged = function()
        Frame:Center()
    end 
    Frame:SetDraggable( false )
    Frame:SetTitle("#printer_seller.name") 
    Frame:ShowCloseButton( true ) 
    Frame:MakePopup()

    Frame.Paint = function(s,w,h)
        while count<2 and CurTime()-lastTaken>npc:GetWaitTime() do
            count = count+1
            lastTaken = lastTaken + npc:GetWaitTime()
        end
        draw.RoundedBox(10, 0, 0, RespX(800), RespY(400), color_translucent_black)
    end

    Frame.infoImage = vgui.Create("DImage", Frame)
    Frame.infoImage:SetImage("icon16/information.png")
    Frame.infoImage:SetSize(RespX(40),RespY(40))
    Frame.infoImage:SetPos(RespX(60),RespY(80))

    Frame.infoText = vgui.Create("DPanel", Frame)
    Frame.infoText:SetSize(RespX(670),RespY(100))
    Frame.infoText:SetPos(RespX(100),RespY(55))
    Frame.infoText.Paint = function(s,w,h)
        -- draw.RoundedBox(10, 0, 0, w, h, Color(255,255,255,100))
        draw.SimpleText("#printer_seller.tip1",
        "Info_Text", RespX(10), RespY(10), color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText("#printer_seller.tip2",
        "Info_Text", RespX(10), RespY(40), color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText("#printer_seller.tip3",
        "Info_Text", RespX(10), RespY(60), color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end
    

    Frame.printer = vgui.Create("DModelPanel", Frame)
    Frame.printer:SetPos(0,RespY(50))
    Frame.printer:SetSize(RespX(300),RespY(300))
    Frame.printer:SetModel("models/stromic/money_printer.mdl")
    Frame.printer:SetCamPos(Vector(10,-35,25))
    Frame.printer:SetLookAt(Vector(-5,0,5))
    Frame.printer.LayoutEntity= function() return end

    Frame.prt_count = vgui.Create("DPanel", Frame)
    Frame.prt_count:SetPos(RespX(325),RespX(150))
    Frame.prt_count:SetSize(RespX(150),RespY(100))
    Frame.prt_count.Paint = function(s,w,h)
        draw.SimpleText(count.."/2", "Printer_Count", w/2, h/2, color_yellow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    Frame.refill_time = vgui.Create("DPanel", Frame)
    Frame.refill_time:SetPos(RespX(500),RespX(125))
    Frame.refill_time:SetSize(RespX(250),RespY(150))
    Frame.refill_time.Paint = function(s,w,h)
        if count ~= 2 then
            draw.SimpleText("#printer_seller.next_printer_in", "Trebuchet24Resp", w/2, RespY(20), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            local timeToGo =  math.Round(npc:GetWaitTime() - (CurTime()-lastTaken))
            local secToGo = timeToGo%60
            local minToGo = (timeToGo-secToGo)/60
            draw.SimpleText(string.format("%02d", minToGo)..":".. string.format("%02d", secToGo), "Trebuchet24Resp", w/2, h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end


    Frame.buyBtn = vgui.Create("DButton", Frame)
    Frame.buyBtn:SetPos(RespX(200),RespY(300))
    Frame.buyBtn:SetSize(RespX(400),RespY(75))
    Frame.buyBtn:SetText(language.GetPhrase("printer_seller.buy") .. " " ..DarkRP.formatMoney(npc:GetPrice()))
    Frame.buyBtn:SetFont("DermaLargeResp")
    Frame.buyBtn:SetTextColor(color_white)
    Frame.buyBtn.Paint = function(s,w,h)
        if count==0 then s:SetEnabled(false) else s:SetEnabled(true) end
        if not s:IsEnabled() then
            draw.RoundedBox(5, 0, 0, w, h, color_translucent_gray)
        else 
            draw.RoundedBox(5, 0, 0, w, h, color_green)
        end
    end
    Frame.buyBtn.DoClick = function()
        net.Start("g_printer_buy")
            net.WriteEntity(npc)
        net.SendToServer()
    end
end)

net.Receive("g_printer_update", function()
    count = net.ReadInt(4)
    lastTaken = net.ReadFloat()
end)