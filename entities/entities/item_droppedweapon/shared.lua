ENT.Type = "anim"
ENT.Base = "base_anim"

if CLIENT then
	ENT.RenderGroup = RENDERGROUP_BOTH

	function ENT:Draw()
		self:DrawModel()
	end
end

if SERVER then
AddCSLuaFile("shared.lua")

ENT.LifeTime = 30

function ENT:Initialize()
	self.NextDie = CurTime() + self.LifeTime
end

function ENT:Think()
	self:SetTrigger(true)
	
	if self.NextDie and CurTime() >= self.NextDie then
		self:Remove()
		return false
	end
end

function ENT:PlayerTouched(pl)
	self:EmitSound("items/ammo_pickup.wav", 100, 100)
	self:Remove()
end

function ENT:StartTouch(ent)
	if self:GetModel() == "models/weapons/naboje/mk2_ammo.mdl" then return end
	
	if ent:IsPlayer() then
		if ent:GetAmmoCount("buckshot") < 200 then
			ent:SetAmmo( math.Clamp( ent:GetAmmoCount("buckshot") + math.random(4, 16), 0, 200), "buckshot")
			self:PlayerTouched(ent)
		end
		
		if ent:GetAmmoCount("smg1") < 300 then
			ent:SetAmmo( math.Clamp( ent:GetAmmoCount("smg1") + math.random(22, 34), 0, 300), "smg1")
			self:PlayerTouched(ent)
		end
		
		if player_manager.GetPlayerClass( ent ) == "player_engineer" then	
			if ent:GetAmmoCount("AirboatGun") < 200 then 
				ent:SetAmmo( math.Clamp( ent:GetAmmoCount("AirboatGun") + math.random(6, 22), 0, 200), "AirboatGun") self:PlayerTouched(ent)
			end
		end
	end	
end

function ENT:OnTakeDamage(dmginfo)
	self:TakePhysicsDamage(dmginfo)
end
end