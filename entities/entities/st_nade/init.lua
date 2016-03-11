AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

ENT.LifeTime = 2

function ENT:Initialize()
	self:SetModel("models/Items/grenadeAmmo.mdl")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:DrawShadow( false )
	self:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end

	self.NextDie = CurTime() + self.LifeTime
end

function ENT:Think()
	if self.NextDie and CurTime()>=self.NextDie then
		util.BlastDamage(self, self:GetOwner(), self:GetPos(), 400, 150)
			local effectdata = EffectData()
			effectdata:SetOrigin(self:GetPos())
			effectdata:SetScale(1)
			effectdata:SetRadius(1)
				util.Effect("st_staticboom", effectdata)
				util.ScreenShake(self:GetPos(), 10, 5, 1, 650)
			self:Remove()	
		return false
	end
end