AddCSLuaFile( "shared.lua" ) 
include('shared.lua') 

ENT.BugModel = "models/ryan7259_predatorcz/STbugs/tanker_bug/tanker_bug.mdl" 
ENT.t_Sounds = {
	["Attack"] = {["Hit"] = {"tanker/SFX_tanker_walk_footstep.mp3"}}, 
	["Die"] = {"tanker/SFX_tanker_death_roar.mp3"}, 
	["Hurt"] = {"tanker/SFX_tanker_roar.mp3"}, 
	--["HurtChance"]= 20,
} 
ENT.iHullCustomCollision = true 
ENT.iHullCustomVectorMin = Vector(150, 150, 200) 
ENT.iHullCustomVectorMax = Vector(-150, -150, 0) 

ENT.MaxYawSpeed = 8
ENT.MaxHealth = 8000

function ENT:stb_OnInit() 
	self.flame_effect = ents.Create( "info_particle_system" ) 
	self.flame_effect:SetKeyValue( "effect_name", "tanker_flame" ) 
	self.flame_effect:SetParent( self ) 
	self.flame_effect:Spawn() 
	self.flame_effect:Activate() 
	self.flame_effect:Fire( "SetParentAttachment", "flame" , 0 ) 
end 

function ENT:STB_Tsprite() 
	local svetlo = ents.Create("env_sprite") 
	svetlo:SetKeyValue("model", "sprites/stb_spalo.spr") 
	svetlo:SetKeyValue("rendermode", "5") 
	svetlo:SetKeyValue("rendercolor", "50 70 100") 
	svetlo:SetKeyValue("scale", "0.2") 
	svetlo:SetKeyValue("spawnflags", "1") 
	svetlo:SetParent(self) 
	svetlo:Fire("SetParentAttachment", "Electric") 
	svetlo:Spawn()
	svetlo:Activate()
	svetlo:Fire("Kill", "", 1)
end 

function ENT:Think()
	local function stb_RangeAttack()
	local entity = ents.FindInBox(self:LocalToWorld(Vector(50, -70, -8.5)), self:LocalToWorld(Vector(800, 74, 105)))
		for k, v in pairs(entity) do
			if(((( v:IsPlayer() && v:Alive()) || v:IsNPC()) && (self:Disposition(v) == 1 || self:Disposition(v) == 2))) then
				if(v:GetClass() != "prop_physics") then
					v:Ignite(6,0)
				end
			end
		end
	end
	self:stb_EnemyRelationships() 	
	if self:GetEnemy() != nil then 	
		if self:stb_aDist(800,245) && !self.RangeAttacking then  
			self.RangeAttacking = true 	
			self.MeleeAttacking = false  
			self:SetSchedule(SCHED_RANGE_ATTACK1) 	
			self:STB_Tsprite()  
			self.idl = CreateSound(self, "tanker/SFX_tanker_fire.mp3")  
			timer.Create( "flame_timer" .. self.Entity:EntIndex( ), 1, 1, function() 
				self.flame_effect:Fire( "Start", "", 0 )
			end)  
			timer.Create ( "idl_timer" .. self.Entity:EntIndex( ), 1, 1, function ()       	
				self.idl:Play() 	
					timer.Create( "rangeattack_timer" .. self.Entity:EntIndex( ), 0.05, 0, stb_RangeAttack ) end)  
						timer.Create("aStop_timer"..self.Entity:EntIndex(),3, 1, function()
							self:stb_ResetAttackEvent()
						end)  
			timer.Remove( "melee_attack_timer" .. self:EntIndex() ) 	
		end						
	if self:stb_aDist(250,0) && !self.MeleeAttacking then  
		self.RangeAttacking = false 	
		self.MeleeAttacking = true 	
		self:SetSchedule(SCHED_MELEE_ATTACK1) 	
		timer.Remove( "rangeattack_timer" .. self:EntIndex() )  
		timer.Remove( "flame_timer" .. self:EntIndex() )  
		timer.Remove( "idl_timer" .. self:EntIndex() )  
		timer.Remove( "aStop_timer" .. self:EntIndex() )  
		timer.Create( "melee_attack_timer" .. self.Entity:EntIndex( ), 1.7, 1, function() 
			self:stb_AttackMelee(200,100,500,360) 
		end)  
	self.flame_effect:Fire( "Stop", "", 0 )  
	timer.Create("aStop_timer"..self.Entity:EntIndex(),2, 1, function()
		self:stb_ResetAttackEvent()
	end)  
		if self.idl then 	
			self.idl:Stop() 
		end 	
	end 	
	else 	
		self.MeleeAttacking = false  
		self.RangeAttacking = false 	
	end  
end

function ENT:stb_ResetAttackEvent() 	
	if self.dead then return end 
	
	self.MeleeAttacking = false  
	self.RangeAttacking = false  
	self.flame_effect:Fire( "Stop", "", 0 ) 
	
	if self.idl then 	
		self.idl:Stop() 
	end  
	timer.Remove( "rangeattack_timer" .. self:EntIndex() ) 
end 

function ENT:OnRemove() 
	timer.Remove( "melee_attack_timer" .. self:EntIndex() ) 
	timer.Remove( "aStop_timer" .. self:EntIndex() ) 
	timer.Remove( "rangeattack_timer" .. self:EntIndex() ) 
	timer.Remove( "flame_timer" .. self:EntIndex() ) 
	timer.Remove( "idl_timer" .. self:EntIndex() ) 
	
	if self.idl then 	
		self.idl:Stop()  
	end 
end

function ENT:stb_SpawnRagdoll() 
	self:Remove() 	

	local ragdoll = ents.Create( "prop_ragdoll" )
	ragdoll:SetModel("models/ryan7259_predatorcz/STbugs/tanker_bug/tanker_bug_ragdoll.mdl")
	ragdoll:SetPos(self:GetPos())
	ragdoll:SetAngles(self:GetAngles() + Angle(0, -90, 0))
	ragdoll:Spawn() 	
	ragdoll:SetCollisionGroup(1) 

	--if math.random(1,5) != 2 then  
	--	ragdoll:Fire( "FadeAndRemove", "", 7 )
	--end
end

function ENT:stb_ScaleDamage(dmginfo, hitgroup) 
	if hitgroup == 10 then 
		dmginfo:ScaleDamage(0.01) 
	elseif hitgroup == 0 then 
		dmginfo:ScaleDamage(2) 
	end
end