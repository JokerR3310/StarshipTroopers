include('shared.lua')

SWEP.PrintName		= "MK55 Tactical Launcher"	
SWEP.Slot			= 4
SWEP.SlotPos		= 1
SWEP.Category		= "SST Weapons 2"

SWEP.Author			= "-=JokerR |CMBG|=-"
SWEP.WepSelectIcon	= surface.GetTextureID("weapons/st_tactical_launcher")

function SWEP:DrawHUD()
	surface.DrawCircle(ScrW() / 2, ScrH() / 2, 4, Color( 235, 55, 55, 255 ))
    surface.DrawCircle(ScrW() / 2, ScrH() / 2, 25, Color( 110, 210, 110, 235 ))
end