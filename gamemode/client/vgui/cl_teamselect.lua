local PANEL = {};

function PANEL:Init()
	self:SetTitle(" ")
	self:SetSize(740, 280)
	self:Center()
	self:ShowCloseButton(false)
	self:SetDraggable(false)
	self:MakePopup()

	local SoldiersModels = {
		"models/mobileinfantry/fmi_01.mdl",
		"models/mobileinfantry/fmi_02.mdl",
		"models/mobileinfantry/fmi_03.mdl",
		"models/mobileinfantry/fmi_04.mdl",
		"models/mobileinfantry/fmi_06.mdl",
		"models/mobileinfantry/fmi_07.mdl",
		"models/mobileinfantry/mi_02.mdl",
		"models/mobileinfantry/mi_03.mdl",
		"models/mobileinfantry/mi_04.mdl",
		"models/mobileinfantry/mi_05.mdl",
		"models/mobileinfantry/mi_06.mdl",
		"models/mobileinfantry/mi_07.mdl",
		"models/mobileinfantry/mi_08.mdl",
		"models/mobileinfantry/mi_09.mdl"
	}

	self.icon = vgui.Create( "DModelPanel", self )
	self.icon:SetModel( SoldiersModels[math.random(#SoldiersModels)] )
	self.icon:SetSize( 256, 256 )
	self.icon:SetPos( -35, -10 )

	self.btn = vgui.Create( "DButton", self )
	self.btn:SetPos( 60, 240 )
	self.btn:SetSize( 60, 20 )
	self.btn:SetText( "Soldier" )
	self.btn.DoClick = function()
		net.Start("TeamSelect")
		net.WriteUInt(1, 3)
		net.SendToServer()

		self:Close()
	end

	self.icon2 = vgui.Create( "DModelPanel", self )
	self.icon2:SetModel( 'models/player/deltaforce/m0'..math.random(1, 8)..'.mdl' )
	self.icon2:SetSize( 256, 256 )
	self.icon2:SetPos( 100, -10 )

	self.btn2 = vgui.Create( "DButton", self )
	self.btn2:SetPos( 200, 240 )
	self.btn2:SetSize( 60, 20 )
	self.btn2:SetText( "Engineer" )
	self.btn2.DoClick = function()
		net.Start("TeamSelect")
		net.WriteUInt(2, 3)
		net.SendToServer()

		self:Close()
	end

	local MedicModels = {
		"models/mobileinfantry/fmi_m_01.mdl",
		"models/mobileinfantry/fmi_m_02.mdl",
		"models/mobileinfantry/fmi_m_03.mdl",
		"models/mobileinfantry/fmi_m_04.mdl",
		"models/mobileinfantry/fmi_m_06.mdl",
		"models/mobileinfantry/fmi_m_07.mdl",
		"models/mobileinfantry/mi_m_02.mdl",
		"models/mobileinfantry/mi_m_03.mdl",
		"models/mobileinfantry/mi_m_04.mdl",
		"models/mobileinfantry/mi_m_05.mdl",
		"models/mobileinfantry/mi_m_06.mdl",
		"models/mobileinfantry/mi_m_07.mdl",
		"models/mobileinfantry/mi_m_08.mdl",
		"models/mobileinfantry/mi_m_09.mdl"
	}

	self.icon3 = vgui.Create( "DModelPanel", self )
	self.icon3:SetModel( MedicModels[math.random(#MedicModels)] )
	self.icon3:SetSize( 256, 256 )
	self.icon3:SetPos( 240, -10 )

	self.btn3 = vgui.Create( "DButton", self )
	self.btn3:SetPos( 340, 240 )
	self.btn3:SetSize( 60, 20 )
	self.btn3:SetText( "Medic" )
	self.btn3.DoClick = function()
		net.Start("TeamSelect")
		net.WriteUInt(3, 3)
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
		net.WriteUInt(4, 3)
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
		net.WriteUInt(5, 3)
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