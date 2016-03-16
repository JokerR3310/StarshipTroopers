local PANEL = {}

surface.CreateFont( "st_title_n", {
	font = "Roboto",
	size = 26,
	weight = 700
})

function PANEL:Init()
	self:SetTitle(" ")
	self:SetSize(322, 362)
	self:Center()
	self:ShowCloseButton(false)
	self:SetDraggable(false)
	self:MakePopup()
	
	self.PropertySheet = vgui.Create("DPropertySheet", self)
	self.PropertySheet:SetPos(8, 30)
	self.PropertySheet:SetSize(308, 323)
	
	self.settings = vgui.Create( "DPanel" ) -- settings tab start

	self.DCollapsible = vgui.Create("DCollapsibleCategory", self.settings)
	self.DCollapsible:SetPos(2, 2)
	self.DCollapsible:SetSize(290, 100)
	self.DCollapsible:SetExpanded(1)
	self.DCollapsible:SetLabel("General Settings")

	self.GList = vgui.Create("DPanelList", self.DCollapsible)
	self.GList:SetPos(20, 30)
	self.GList:SetSize(250, 250)
	self.GList:SetSpacing(10)
	self.GList:EnableVerticalScrollbar( true )

	self.ClientS = vgui.Create("DLabel") 
	self.ClientS:SetText("Client Settings")
	self.ClientS:SetTextColor(Color(10, 100, 10, 255))
	self.ClientS:SetFont("st_title_n")
	self.GList:AddItem(self.ClientS)
					
	self.mf = vgui.Create("DCheckBoxLabel")
		self.mf:SetText("Movement effect")
		self.mf:SetTextColor(Color(0, 0, 0, 255))
		self.mf:SetConVar("cl_movement")
		self.GList:AddItem(self.mf)
------------------------------------------------------
	self.InterfaceS = vgui.Create("DLabel") 
	self.InterfaceS:SetText("Interface Settings")
	self.InterfaceS:SetTextColor(Color(10, 100, 10, 255))
	self.InterfaceS:SetFont("st_title_n")
	self.GList:AddItem(self.InterfaceS)
					
	self.dtism = vgui.Create("DCheckBoxLabel")
		self.dtism:SetText("Disable interactive tips")
		self.dtism:SetTextColor(Color(10, 10, 10, 255))
		self.dtism:SetConVar("cl_intips")
		self.GList:AddItem(self.dtism)
-----------------------------------------------------	
	self.PerfS = vgui.Create("DLabel") 
	self.PerfS:SetText("Performance Settings")
	self.PerfS:SetTextColor(Color(10, 100, 10, 255))
	self.PerfS:SetFont("st_title_n")
	self.GList:AddItem(self.PerfS)
					
	self.whm = vgui.Create("DCheckBoxLabel")
		self.whm:SetText("Weapon holster mod")
		self.whm:SetTextColor(Color(10, 10, 10, 255))
		self.whm:SetConVar("cl_holsteredguns")
		self.GList:AddItem(self.whm)
					
	self.lm = vgui.Create("DCheckBoxLabel")
		self.lm:SetText("Legs mod")
		self.lm:SetTextColor(Color(0, 0, 0, 255))
		self.lm:SetConVar("cl_legsconvar")
		self.GList:AddItem(self.lm)
--[[--------------------------------------------------	
	self.OtherS = vgui.Create("DLabel") 
	self.OtherS:SetText("Other Settings")
	self.OtherS:SetTextColor(Color(10, 100, 10, 255))
	self.OtherS:SetFont("st_title_n")
	self.GList:AddItem(self.OtherS)
	]]
-- SETTINGS END --

	self.commands = vgui.Create("DPanel")
	
	self.content = vgui.Create("DLabel", self.commands)
		self.content:SetFont("st_title_n")
		self.content:SetText([[            Chat Commands

 /class or !class
 /settings or !settings
 /votemap or !votemap]])
		self.content:SetTextColor(Color(0, 0, 0, 255))
		self.content:SizeToContents()
		
	self.credits = vgui.Create("DPanel") -- credits tab
	
	self.Info = vgui.Create("DLabel", self.credits)
		self.Info:SetText(

[[ • ======= Thanks you for using this mod! ======= •

 •  Starship Troopers Gamemode

 •  Author:  -=JokerR |CMBG|=-

 •  Version: "Open Beta 0.7.8" | 19/12/2015
]])
		self.Info:SetTextColor(Color(0, 0, 0, 255))
		self.Info:SetPos(5, 20)
		self.Info:SizeToContents()
					
-- Menu END Here --
	
	self.PropertySheet:AddSheet("Settings", self.settings, "icon16/wrench.png", false, false, "These settings are saving!")
	self.PropertySheet:AddSheet("Commands", self.commands, "icon16/page_white_text.png", false, false, "All chat and concole commands")
	self.PropertySheet:AddSheet("Credits", self.credits, "icon16/heart.png", false, false, "Just credits")
	
	self.btnc = vgui.Create("DButton", self)
	self.btnc:SetSize(70, 30)
	self.btnc:SetPos(238, 13)
	self.btnc:SetText("")
	self.btnc.Paint = function(s, w, h)
		draw.RoundedBox(0, 1, 1, w-2, h-2, Color(255, 255, 255, 10))
		draw.RoundedBox(0, 2, 2, w-4, h-4, Color(47, 61, 72))
		draw.SimpleText('r', 'marlett', w/2, h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	self.btnc.DoClick = function()
		self:Close()
	end
end

function PANEL:Paint()
	draw.RoundedBox(16, 0, 0, 322, 362, Color(0, 0, 0, 180))
	Derma_DrawBackgroundBlur(self)
	draw.SimpleTextOutlined("Starship Troopers: Settings Menu", "HudHintTextLarge", 11, 12, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT, 1, Color(0, 0, 0, 255))
end

vgui.Register("DHelpMenu", PANEL, "DFrame")