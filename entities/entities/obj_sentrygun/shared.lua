ENT.Type = "ai"  
ENT.Base = "obj_base"

ENT.PrintName = "Sentry"

ENT.Building = true

ENT.AutomaticFrameAdvance = true

game.AddParticles("particles/DEVTEST.PCF")
PrecacheParticleSystem("weapon_muzzle_smoke_b")
PrecacheParticleSystem("weapon_muzzle_flash_assaultrifle")

ENT.ObjectHealth = 150
ENT.Range = 1100

ENT.CollisionBox = {Vector(-24,-24,0), Vector(24,24,50)}
ENT.BuildHull = {Vector(-24,-24,0), Vector(24,24,86)}

function ENT:GetObjectHealth()
	local l = self:GetLevel()
	local m = 1
	
	if l==2 then
		return math.ceil(180 * m)
	else
		return math.ceil(150 * m)
	end
end

function ENT:SetAutomaticFrameAdvance(bUsingAnim)
	self.AutomaticFrameAdvance = bUsingAnim
end

function ENT:SetupDataTables()
	self.BaseClass.SetupDataTables(self)
end

function ENT:GetAmmo1Percentage()
	return self.dt.BuildingInfoFloat.y
end

function ENT:SetAmmo1Percentage(p)
	local v = self.dt.BuildingInfoFloat
	v.y = p
	self.dt.BuildingInfoFloat = v
end