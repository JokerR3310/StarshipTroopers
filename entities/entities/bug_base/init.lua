AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

ENT.BugModel = ""
ENT.iHullCustomCollision = true
ENT.iHullCustomVectorMin = Vector(60, 60, 100)
ENT.iHullCustomVectorMax = Vector(-60, -60, 0)
--ENT.Dissolvable = true
--ENT.bugs = {"bug_sentinel","bug_tanker","bug_blaster","bug_chariot","bug_cliffmite","bug_tiger","bug_tigershard","bug_tigerspit","bug_warrior"} 
/* SOUND section */ 
ENT.t_Sounds = {}
/* COMBAT section */ 
ENT.MeleeAttacking = false
ENT.RangeAttacking = false
ENT.dead = false
--ENT.BallImmune = false /* DEAD section */ 
--ENT.dSkin = 0 
--ENT.dFireSkin = 0 
--ENT.dBodyGroups = {} 

ENT.MaxYawSpeed = 0
ENT.MaxHealth = 0

function ENT:Initialize()  
	self:SetModel(self.BugModel)  
	self:SetHullType(HULL_LARGE)  
	self:SetHullSizeNormal()  
	
	self:SetCustomCollisionCheck()  
	
	if self.iHullCustomCollision then  
		self:SetCollisionBounds(self.iHullCustomVectorMin, self.iHullCustomVectorMax) 
	end  
	self:SetSolid( SOLID_BBOX )  
	self.DamangeOnHitbox = 0  
	self:SetMoveType(3)
	
	local comp = {CAP_MOVE_GROUND, CAP_FRIENDLY_DMG_IMMUNE, CAP_SQUAD} 

	for _, g in pairs(comp) do 
		self:CapabilitiesAdd(g) 
	end

	self:SetMaxYawSpeed(self.MaxYawSpeed)

	local GAME_DIFFICULTY = GetConVar("stg_game_difficulty"):GetInt()
	local playerCount = player.GetCount()

	local result = 45 * (playerCount ^ 2) + 1200 * (0.3 + playerCount / 10)
	result = result * (GAME_DIFFICULTY + 2)
	--print(self.MaxHealth + result)

	self:SetMaxHealth(self.MaxHealth + result)
	self:SetHealth(self.MaxHealth + result)

	self:stb_OnInit() 
end 
/*
function ENT:stb_InitUnburrow() 
	self:SetNoDraw(true) 
	
	timer.Create("burrowed_returnpos".. self:EntIndex(), 0.2, 1, function()
		self:SetNoDraw(false)
	end) 
	
	self.dead = true 
	
	if GetConVarNumber("stb_BurrowRocks") == 1 then 
	for i = 0,3 do for _,v in pairs ({"a","b","c"}) do 
 local gib = ents.Create( "prop_physics" )  
 gib:SetModel( "models/props_debris/concrete_chunk01"..v..".mdl" )  
 gib:SetPos( self:GetPos()  + Vector(math.random(-100,100),math.random(-100,100),0) )  
 gib:Spawn()  gib:stb_Fade(5)  gib:SetCollisionGroup(1) 
 local ph = gib:GetPhysicsObject()  ph:SetMass(200)  
 local direct = gib:GetAngles() + Angle(0,0,0 )  
 direct = direct:Up()  
 ph:AddAngleVelocity(Vector(math.random(0,-180),math.random(-180,-250)  ,0))  
 ph:ApplyForceCenter(direct * 50000 ) 
 end 
 end 
 end 
 self:stb_PlaySequence(ACT_CLIMB_UP) 
 timer.Create("unburrow_end".. self:EntIndex(),1.6,1,function()
	self.dead = false 
 end) 
end 
*/
/*
function ENT:stb_OnInit() 
end

*/
/*
function ENT:Think() 
	if self.dead then return end  
	if GetConVarNumber("ai_disabled") == 0 then 
		self:stb_EnemyRelationships() 	
	end
end 
*/

function ENT:SelectSchedule() 
	if self.dead then return end 
	
	if (!self.MeleeAttacking || !self.RangeAttacking) && self:GetEnemy() != nil then 	
		self:UpdateEnemyMemory(self:GetEnemy(),self:GetEnemy():GetPos()) 	
		self:SetSchedule(SCHED_CHASE_ENEMY)  
	else  
		if math.random(1,100) == 50 then  
			self:SetSchedule(SCHED_IDLE_STAND) 
		else  
			self:SetSchedule(SCHED_IDLE_WANDER) 
		end 	
	end 
end 

function ENT:stb_PlaySequence(pSeq,face) 	
	local PlAct = psf_schedule.New("seq"..pSeq)  
	PlAct:EngTask("TASK_STOP_MOVING", 0)  
	self:StopMoving() 
	if face == true then  
		PlAct:EngTask("TASK_PLAY_SEQUENCE_FACE_ENEMY",pSeq )  
	else  
		PlAct:EngTask("TASK_PLAY_SEQUENCE",pSeq )  
	end 	
	self:StartSchedule(PlAct) 
end 

function ENT:stb_PlaySound(tbl, chance,pitchmin,pitchmax,soundlevel, schedule) 
	if !istable(tbl) then return end

	local random, num, lvl, minp, maxp,pust minp = pitchmin maxp = pitchmax lvl = soundlevel num = table.getn(tbl) 

	if num == 1 then 
		random = num 
	else 
		random = math.random(1,num) 
	end 

	if lvl != nil then
		lvl = soundlevel 
	else 
		lvl = 460 
	end 

	if minp != nil then 
		minp = pitchmin 
	else 
		minp = 80 
	end 

	if maxp != nil then 
		maxp = pitchmax 
	else 
		maxp = 120 
	end 

	if chance == 1 || chance == nil then 
		pust = true 
	else 
		pust = false 
	end  

	if num != 0 then  
		if pust || math.random(1,chance) == 1  then  
			if schedule || schedule != nil then  
				self:SetSchedule(schedule)  
			end  
			self:EmitSound( table.concat(tbl," ",random,random),lvl,math.random(minp,maxp)) 
		end  
	end 
end 

function ENT:Ignitable()
	return 
end 

--function ENT:stb_dmgRTGib(dmginfo,hitgroup)
--end 

function ENT:stb_DmgOrder(dmginfo,hitgroup) 
	self:SetHealth(self:Health() - dmginfo:GetDamage()) 
end 
/*
function ENT:stb_KillOrder(dmginfo,hitgroup) 
	if (dmginfo:GetDamageType() == 67108865 || dmginfo:GetDamageType() == 67108864) && self.Dissolvable then 
		self:SetNPCState(NPC_STATE_DEAD) self:SetSchedule(SCHED_FALL_TO_GROUND) 
	else  
		self:stb_SpawnRagdoll(dmginfo)  
	end 
end 
*/
function ENT:OnTakeDamage(dmginfo) self:stb_SetVel(dmginfo) 
	local hitgroup = self.DamangeOnHitbox 
	self:stb_ScaleDamage(dmginfo, hitgroup) 
	--self:stb_dmgRTGib(dmginfo,hitgroup) 
	self:stb_DmgOrder(dmginfo,hitgroup) 
	--self:stb_SpawnBlood(dmginfo,hitgroup)  
	--self:stb_PlaySound(self.t_Sounds["Hurt"],self.t_Sounds["HurtChance"])
	self:stb_PlaySound(self.t_Sounds["Hurt"],20)
	--self:stb_PlaySound(self.t_Sounds["Impact"],nil,100,100,100)  
	
	if game.SinglePlayer() and (self.nextTransmitHealtCheck or 0) < CurTime() then
		net.Start("SinglePlayerHealthNetwork")
			net.WriteEntity(self)
			net.WriteUInt(self:Health(), 18)
		net.Broadcast()

		self.nextTransmitHealtCheck = CurTime() + 0.2
	end
	
	if self:Health() <= 0 && !self.dead then 
		self.dead = true 
		self:ClearEnemyMemory()	
		/*self:ClearSchedule()  */  
		gamemode.Call("OnNPCKilled", self,dmginfo:GetAttacker(), dmginfo:GetInflictor(), dmginfo)  
		self:stb_PlaySound(self.t_Sounds["Die"])  
		--self:stb_KillOrder(dmginfo,hitgroup)  
		self:stb_SpawnRagdoll(dmginfo)
	end 
end 
/*
function ENT:stb_SpawnBlood(dmginfo,hitgroup) 
	if self:stb_PartName(hitgroup) == "nothing" then return end 
	
	local blood = ents.Create( "info_particle_system" ) 
	
	blood:SetKeyValue( "effect_name", self:stb_PartName(hitgroup))  
	blood:SetPos( dmginfo:GetDamagePosition() ) 	
	blood:Spawn() 	
	blood:Activate() 	
	blood:Fire( "Start", "", 0 ) 	
	blood:Fire( "Kill", "", 0.1 ) 
end 
*/
/*
function ENT:stb_NoCollide(colEnt) 
	if self.BallImmune then 
		if colEnt:GetClass() == "prop_combine_ball" then 
			return false  
		end 
	end 
end 
*/
function ENT:stb_EnemyRelationships()  
	self:stb_PlaySound(self.t_Sounds["Idle"],self.t_Sounds["IdleChance"]) 
	
	local enemy = ents.FindByClass("npc_*")  
	enemy = table.Add(enemy,ents.FindByClass("obj_sentrygun"))
	
	for _, x in pairs(player.GetAll()) do  
		self:AddEntityRelationship( x, 1, 99 )	
	end 
	
	for _, x in pairs(enemy) do 	
		if (!ents) then return end 	
		if (x:GetClass() != self:GetClass() && x:GetClass() !=  "npc_grenade_frag" && x:GetClass() !=  "npc_antlionguard" && x:GetClass() !=  "npc_antlion" && x:GetClass() !=  "npc_antlion_worker" && x:GetClass() !=  "npc_barnacle" && x:IsNPC()) then  
			x:AddEntityRelationship( self, 1, 99 )  
			self:AddEntityRelationship( x, 1, 99 ) 	
		end 	
	end  
	
	local friend = ents.FindByClass("npc_antlion")
	friend = table.Add(friend,ents.FindByClass("npc_antlion_worker"))
	friend = table.Add(friend,ents.FindByClass("npc_antlionguard"))
	friend = table.Add(friend,ents.FindByClass("npc_barnacle"))
	self:AddRelationship( "npc_antlion  D_LI  99" )
	self:AddRelationship( "npc_antlionguard  D_LI  99" )
	self:AddRelationship( "npc_antlion_worker  D_LI  99" )
	self:AddRelationship( "obj_sentrygun  D_HT 99" )

	for _, x in pairs(friend) do
		x:AddEntityRelationship( self, 3, 99 )
	end
end 

function ENT:OnRemove() 
	timer.Remove( "unburrow_end".. self:EntIndex()) 
	timer.Remove( "burrowed_returnpos".. self:EntIndex()) 
	timer.Remove( "melee_attack_timer" .. self:EntIndex()) 
	timer.Remove( "spit_throw_timer" .. self:EntIndex()) 
	timer.Remove( "aStop_timer" .. self:EntIndex())  
end 
/*
function ENT:stb_SpawnRagdoll(dmginfo)  
	local gib = ents.Create( "prop_ragdoll" )  
	
	gib:SetSkin( self.dSkin )  
	gib:SetModel( self:GetModel() )  
	gib:SetPos( self:GetPos() )  
	gib:SetAngles( self:GetAngles() )  
	undo.ReplaceEntity(self,gib)  
	cleanup.ReplaceEntity(self,gib) 
	
	for i = 1,15 do 
		gib:SetBodygroup(i,self:GetBodygroup(i))
	end 
	
	if table.getn(self.dBodyGroups) != 0 then  
		for i = 0,table.getn(self.dBodyGroups)-1 do  
			gib:SetBodygroup( i, table.concat(self.dBodyGroups," ",i+1,i+1) )  
		end 
	end  
	
	gib:Spawn()  
	
	if GetConVarNumber("stb_FadeRagdolls") == 1 then  
		if math.random(0,GetConVarNumber("stb_FadeRagdollChance")) != 1 then  
			gib:Fire("FadeAndRemove","",GetConVarNumber("stb_FadeRagdollTime"))  
		end  
	end  
	
	gib:SetCollisionGroup(  1   )  
	self:Remove()  
	
	local ph = gib:GetPhysicsObject()  
	local direct = self:GetAngles() - Angle(0,self:stb_SetVel(dmginfo),0	) 	
	direct = direct:Forward()  
	
	local adddmg  
	
	if dmginfo:GetAmmoType() == 7 then  
		adddmg = dmginfo:GetDamage() * 5  
	else 
		adddmg = dmginfo:GetDamage() 
	end 	
	
	ph:ApplyForceCenter(-direct * 8000 * adddmg ) 
	
	if self:IsOnFire() then 
		gib:Ignite( math.Rand( 8, 10 ), 0 ) 
		gib:SetSkin( self.dFireSkin ) 
	end 
end 
*/
function ENT:stb_SetVel(dmginfo ) 
	local aimvec = self:GetAimVector() 
	local attacker = (dmginfo:GetAttacker():GetPos() - self:WorldSpaceCenter())  
	attacker.z = 0  attacker:Normalize() 
	
	local angle = aimvec:Dot( attacker )  
	angle = math.deg( math.acos( angle ) ) 
	local angleright =  aimvec:Dot( attacker:Cross( Vector(0,0,1) )  )  
	angleright = math.deg( math.acos( angleright ) ) 
	
	if angleright >= 0 && angleright <= 90 then 
		angle = 0-angle 
	end 
		return angle 
end 
	
--function ENT:stb_ScaleDamage(dmginfo, hitgroup) 
--end 
/*
function ENT:stb_PartName(hitgroup) 
	local str  = "blood_impact_stb_green" 
		return str 
end 
*/
function ENT:stb_AttackMelee(conepos,conesize,velent,angent) 	
	if self.dead then return end 	
	
	local entity = ents.FindInSphere(self:GetPos() + self:GetForward()*conepos,conesize) 	
	local hitentity = false  
	--local m_damage = GetConVarNumber("stb_SetMeleeDMG_"..self.PrintName)
	local m_damage = 60
	
	if entity != nil then 	
		for _,v in pairs(entity) do 	
			if ((v:IsNPC() || (v:IsPlayer() && v:Alive())) && (v != self) && (v:GetClass() != self:GetClass()) && (self:Disposition(v) == 1 || self:Disposition(v) == 2) || (v:GetClass() == "prop_physics")) then 	
				v:TakeDamage( m_damage, self ) 	
				v:SetVelocity(( self:GetForward() * velent ) +Vector(0, 0, angent)) 
					if v:IsPlayer() then  
						v:ViewPunch(Angle(math.random(-1,1)*m_damage/2,math.random(-1,1)*m_damage/2,math.random(-1,1)*m_damage/2))  
					end 	
				hitentity = true 	
			end 	
		end 	
	end 	
	if hitentity then  
		self:stb_PlaySound(self.t_Sounds["Attack"]["Hit"]) 	
	else  
		self:stb_PlaySound(self.t_Sounds["Attack"]["Hit"])  
	end 
end 

function ENT:stb_aDist(maxdist,mindist) 
	local max = self:GetEnemy():GetPos():Distance(self:GetPos()) < maxdist 
	local min = self:GetEnemy():GetPos():Distance(self:GetPos()) > mindist 
	if min && max then 
		return true 
	else 
		return false 
	end  
end 

function ENT:stb_ResetAttackEvent() 	
	if self.dead then return end 	
	
	self.MeleeAttacking = false  
	self.RangeAttacking = false 
end 
/*
function ENT:stb_RangeAttack(vx,vy,vz,proj,pf,pu,pr,vel,num,rad)  
	if self.dead || !IsValid(self:GetEnemy()) then return end 	
	
	local shoot_vector = (self:GetEnemy():GetPos() - self:LocalToWorld(Vector(vx,vy,vz))) 	
	shoot_vector:Normalize()  
	
	for i=1,num do  
		local projectile = ents.Create(proj) 

		if i == 2 then 	
			projectile:SetPos(self:GetPos() + self:GetForward() * pf + self:GetUp() * pu + self:GetRight() * (-pr)  + shoot_vector * 40)  
		else 
			projectile:SetPos(self:GetPos() + self:GetForward() * pf + self:GetUp() * pu + self:GetRight() * pr  + shoot_vector * 40)  
		end 	
		
		projectile:SetAngles(shoot_vector:Angle())  
		
		if proj != "grenade_spit" then 
			projectile:SetKValue(self.bugs,GetConVarNumber("stb_SetRangeDMG_"..self.PrintName),rad)  
		end 	
		
		projectile:Activate() 	
		projectile:Spawn() 	
		
		local phy = projectile:GetPhysicsObject() 	
		
		if phy:IsValid() then  
			phy:ApplyForceCenter((shoot_vector * vel))  
		else 	
			projectile:SetVelocity( self:GetForward() * vel)  
		end  
	end 
	
end

*/