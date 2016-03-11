ENT.Type = "ai" 
ENT.Base = "obj_base" 

ENT.PrintName = "Dispenser"

ENT.Building = true

ENT.AutomaticFrameAdvance = true

game.AddParticles("particles/MEDICGUN_BEAM.pcf")
PrecacheParticleSystem("medicgun_beam_red")

ENT.ObjectHealth = 150
ENT.MaxMetal = 400

ENT.CollisionBox = {Vector(-24,-24,0), Vector(24,24,63)}
ENT.BuildHull = {Vector(-24,-24,0), Vector(24,24,82)}

function ENT:GetObjectHealth()
	local l = self:GetLevel()
	local m = 1
	
	if l==3 then
		return math.ceil(215 * m)
	elseif l==2 then
		return math.ceil(180 * m)
	else
		return math.ceil(150 * m)
	end
end

function ENT:SetAutomaticFrameAdvance(bUsingAnim)
	self.AutomaticFrameAdvance = bUsingAnim
end

function ENT:SetMetalAmount(m)
	self.MetalAmount = m
	self:SetAmmoPercentage(m / self.MaxMetal)
end

function ENT:GetMetalAmount()
	return self.MetalAmount
end

function ENT:AddMetalAmount(m)
	local a = self:GetMetalAmount()
	if a+m>self.MaxMetal then
		self:SetMetalAmount(self.MaxMetal)
		return self.MaxMetal - a
	elseif a+m<0 then
		self:SetMetalAmount(0)
		return a
	else
		self:SetMetalAmount(a+m)
		return m
	end
end

function ENT:GetAmmoPercentage()
	return self.dt.BuildingInfoFloat.y
end

function ENT:SetAmmoPercentage(p)
	local v = self.dt.BuildingInfoFloat
	v.y = p
	self.dt.BuildingInfoFloat = v
end