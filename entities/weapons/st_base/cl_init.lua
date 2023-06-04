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

local surfaceDrawLine, ScrW, ScrH, renderOverrideBlend, surfaceSetDrawColor = surface.DrawLine, ScrW, ScrH, render.OverrideBlend, surface.SetDrawColor

function SWEP:DrawHUD()	
	renderOverrideBlend(true, 3, 1, 1) -- BLEND_ONE_MINUS_DST_COLOR, BLEND_ONE, BLENDFUNC_SUBTRACT
	surfaceSetDrawColor(255, 0, 127)

		local CW, CH = (ScrW() * 0.5) - 0.5, (ScrH() * 0.5) - 0.5
		local CWP, CHP = (ScrW() * 0.5) + 0.5, (ScrH() * 0.5) + 0.5

		surfaceDrawLine(CW - 0.5, CH + 0.5, CW + 1.5, CH + 0.5)
		surfaceDrawLine(CW - 0.5, CH, CW + 1.5, CH)

		surfaceDrawLine(CW + 10, CH, CW + 25 , CH)
		surfaceDrawLine(CW + 10, CHP, CW + 25 , CHP)

		surfaceDrawLine(CW - 25, CH, CW - 10 , CH)
		surfaceDrawLine(CW - 25, CHP, CW - 10 , CHP)

		surfaceDrawLine(CW, CH + 10, CW, CH + 25)
		surfaceDrawLine(CWP, CH + 10, CWP, CH + 25)

		surfaceDrawLine(CW - 0, CH - 10, CW, CH - 25)
		surfaceDrawLine(CWP - 0, CH - 10, CWP, CH - 25)

	renderOverrideBlend(false)
end