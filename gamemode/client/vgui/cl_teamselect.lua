local PANEL = {};

function PANEL:Init()
	self:SetTitle(" ")
	self:SetSize(740, 280)
	self:Center()
	self:ShowCloseButton(false)
	self:SetDraggable(false)
	self:MakePopup()

	self.icon = vgui.Create( "DModelPanel", self )
	self.icon:SetModel( 'models/player/deltaforce/m0'..math.random(1, 8)..'.mdl' )
	self.icon:SetSize( 256, 256 )
	self.icon:SetPos( -35, -10 )

	self.btn = vgui.Create( "DButton", self )
	self.btn:SetPos( 60, 240 )
	self.btn:SetSize( 60, 20 )
	self.btn:SetText( "Soldier" )
	self.btn.DoClick = function()
		net.Start("TeamSelect")
		net.WriteInt(1, 4)
		net.SendToServer()
		self:Close()
	end

	self.icon2 = vgui.Create( "DModelPanel", self )
	self.icon2:SetModel( 'models/player/combine_soldier_prisonguard.mdl' )
	self.icon2:SetSize( 256, 256 )
	self.icon2:SetPos( 100, -10 )

	self.btn2 = vgui.Create( "DButton", self )
	self.btn2:SetPos( 200, 240 )
	self.btn2:SetSize( 60, 20 )
	self.btn2:SetText( "Engineer" )
	self.btn2.DoClick = function()
		net.Start("TeamSelect")
		net.WriteInt(2, 4)
		net.SendToServer()
		self:Close()
	end

	self.icon3 = vgui.Create( "DModelPanel", self )
	self.icon3:SetModel( 'models/player/group03m/male_0'..math.random(1, 9)..'.mdl' )
	self.icon3:SetSize( 256, 256 )
	self.icon3:SetPos( 240, -10 )

	self.btn3 = vgui.Create( "DButton", self )
	self.btn3:SetPos( 340, 240 )
	self.btn3:SetSize( 60, 20 )
	self.btn3:SetText( "Medic" )
	self.btn3.DoClick = function()
		net.Start("TeamSelect")
		net.WriteInt(3, 4)
		net.SendToServer()
		self:Close()
	end

	self.icon4 = vgui.Create( "DModelPanel", self )
	self.icon4:SetModel( 'models/player/group03/male_0'..math.random(1, 9)..'.mdl' )
	self.icon4:SetSize( 256, 256 )
	self.icon4:SetPos( 380, -10 )

	self.btn4 = vgui.Create( "DButton", self )
	self.btn4:SetPos( 480, 240 )
	self.btn4:SetSize( 60, 20 )
	self.btn4:SetText( "Sniper" )
	self.btn4.DoClick = function()
		net.Start("TeamSelect")
		net.WriteInt(4, 4)
		net.SendToServer()
		self:Close()
	end

	self.iconr = vgui.Create( "DModelPanel", self )
	self.iconr:SetModel( 'models/editor/playerstart.mdl' )
	self.iconr:SetSize( 256, 256 )
	self.iconr:SetPos( 520, -10 )

	self.btnr = vgui.Create( "DButton", self )
	self.btnr:SetPos( 620, 240 )
	self.btnr:SetSize( 60, 20 )
	self.btnr:SetText( "Spectator" )
	self.btnr.DoClick = function()
		net.Start("TeamSelect")
		net.WriteInt(5, 4)
		net.SendToServer()
		self:Close()
	end
	
	self.btnc = vgui.Create( "DButton", self )
	self.btnc:SetSize( 30, 30 )
	self.btnc:SetPos( 694, 10 )
	self.btnc:SetText( "" )
	self.btnc.Paint = function( s, w, h )
		draw.RoundedBox( 0, 1, 1, w-2, h-2, Color(255, 255, 255, 10))
		draw.RoundedBox( 0, 2, 2, w-4, h-4, Color(47, 61, 72))
		draw.SimpleText( 'r', 'marlett', w/2, h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	self.btnc.DoClick = function()
		self:Close()
	end
end

function PANEL:Paint()
	draw.RoundedBox(16, 0, 0, 740, 280, Color(0,0,0,180))
	Derma_DrawBackgroundBlur( self )
	draw.SimpleTextOutlined("Change Class", "DermaLarge", 376, 12, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0,0,0,255))
end

vgui.Register( "DTeamSelect", PANEL, "DFrame" )