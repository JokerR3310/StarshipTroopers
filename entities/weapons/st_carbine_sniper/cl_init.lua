include('shared.lua')

SWEP.PrintName		= "Morita Mk I Sniper Rifle"	
SWEP.Slot			= 2
SWEP.SlotPos		= 2
SWEP.Category		= "SST Weapons 2"

SWEP.Author			= "-=JokerR |CMBG|=-"
SWEP.WepSelectIcon	= surface.GetTextureID("weapons/st_carbine_sniper")

function SWEP:Initialize()
	-- We need to get these so we can scale everything to the player's current resolution.
	local iScreenWidth = surface.ScreenWidth()
	local iScreenHeight = surface.ScreenHeight()

	self.ScopeTable = {}
	self.ScopeTable.l = iScreenHeight*self.ScopeScale

	self.ScopeTable.l = (iScreenHeight + 1)*self.ScopeScale -- I don't know why this works, but it does.

	self.QuadTable = {}
	self.QuadTable.h1 = 0.5*iScreenHeight - self.ScopeTable.l
	self.QuadTable.w3 = 0.5*iScreenWidth - self.ScopeTable.l

	self.LensTable = {}
	self.LensTable.x = self.QuadTable.w3
	self.LensTable.y = self.QuadTable.h1
	self.LensTable.w = 2*self.ScopeTable.l
	self.LensTable.h = 2*self.ScopeTable.l	
end

local elcansight = surface.GetTextureID("scope/gdcw_elcansight")
local svdsight = surface.GetTextureID("scope/gdcw_svdsight")

function SWEP:DrawHUD()
	if self.Owner:KeyDown(IN_ATTACK2) and not self.Weapon:GetNWBool("Reloading") then
		render.OverrideBlend( false )
		surface.SetTexture(elcansight)
		surface.DrawTexturedRect(self.LensTable.x, self.LensTable.y, self.LensTable.w, self.LensTable.h)
		
		surface.SetTexture(svdsight)
		surface.DrawTexturedRect(self.LensTable.x, self.LensTable.y, self.LensTable.w, self.LensTable.h)
	else
		self.BaseClass.DrawHUD(self)
	end
end

function SWEP:AdjustMouseSensitivity()
	if self.Owner:KeyDown(IN_ATTACK2) and not self.Weapon:GetNWBool("Reloading") then
		return 0.1
    end
end