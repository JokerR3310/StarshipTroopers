include('shared.lua')

SWEP.PrintName			= ""
SWEP.Slot				= 0
SWEP.SlotPos			= 0
SWEP.Category			= "SST Weapons 2"

SWEP.Author				= "-=JokerR |CMBG|=-"
SWEP.Contact			= "http://steamcommunity.com/id/Joker-UA/"

SWEP.DrawCrosshair		= false
SWEP.DrawWeaponInfoBox 	= false

SWEP.CSMuzzleFlashes = true
SWEP.CSMuzzleX = true

function SWEP:DrawHUD()
	surface.SetDrawColor(Color(210, 210, 210, 235))
	
	surface.DrawLine(ScrW() / 2 + 5, ScrH() / 2, ScrW() / 2 + 15 , ScrH() / 2)
	surface.DrawLine(ScrW() / 2 - 15, ScrH() / 2, ScrW() / 2 - 5 , ScrH() / 2)
	
	surface.DrawLine(ScrW() / 2 - 0, ScrH() / 2 + 5, ScrW() / 2 - 0 , ScrH() / 2 + 15)
	surface.DrawLine(ScrW() / 2 - 0, ScrH() / 2 - 5, ScrW() / 2 - 0 , ScrH() / 2 - 15)
end