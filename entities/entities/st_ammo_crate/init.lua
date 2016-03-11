AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel( "models/Items/ammocrate_smg1.mdl" ) 
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( SIMPLE_USE )
	
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(false)
	end
end

ENT.Sound_Pickup = Sound("items/ammo_pickup.wav")

function ENT:AcceptInput(ply, caller)
	if caller:IsPlayer() && !caller.CantUse then
		caller.CantUse = true
		timer.Simple(2, function() caller.CantUse = false end)
		if caller:IsValid() then
			self:GiveSomeAmmo(caller)
		end
	end
end

function ENT:GiveSomeAmmo(ply)
	if ply:GetAmmoCount("smg1") < 300 then
	self:SetSequence(self:LookupSequence("Close"))
		timer.Simple(1, function()
			ply:SetAmmo(math.Clamp(ply:GetAmmoCount("smg1") + 80, 0, 300), "smg1")
			self:SetSequence(self:LookupSequence("idle"))
			self:EmitSound(self.Sound_Pickup, 100, 100)
		end)
	end
	
	if player_manager.GetPlayerClass( ply ) == "player_engineer" and ply:GetAmmoCount( "AirboatGun" ) < 200 then
	self:SetSequence(self:LookupSequence("Close"))
		timer.Simple(1, function()
			ply:SetAmmo(math.Clamp( ply:GetAmmoCount("AirboatGun") + 10, 0, 200), "AirboatGun")
			self:SetSequence(self:LookupSequence("idle"))
			self:EmitSound(self.Sound_Pickup, 100, 100)
		end)
	end
end