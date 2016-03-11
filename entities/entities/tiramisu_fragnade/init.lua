AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

function ENT:Initialize()
	self:SetModel("models/Items/AR2_Grenade.mdl")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:DrawShadow( false )
	self:SetCollisionGroup( COLLISION_GROUP_WEAPON )

	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
end

function ENT:PhysicsCollide( data, physobj )
	util.BlastDamage(self, self:GetOwner(), self:GetPos(), 525, 150)
	
	local effectdata = EffectData()
	effectdata:SetOrigin(self:GetPos())			// Where is hits
	effectdata:SetScale(1)			// Size of explosion
	effectdata:SetRadius(1)		// What texture it hits
		util.Effect( "st_staticboom", effectdata )
		util.ScreenShake(self:GetPos(), 10, 5, 1, 650)
	self:Remove()
end