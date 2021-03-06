AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

ENT.NumLevels = 2

ENT.Levels = {
{Model("models/buildables/sentry1_heavy.mdl"), Model("models/buildables/sentry1.mdl")},
{Model("models/buildables/sentry2_heavy.mdl"), Model("models/buildables/sentry2.mdl")}
}

ENT.Sound_Idle = Sound("Building_Sentrygun.Idle")
ENT.Sound_Idle2 = Sound("Building_Sentrygun.Idle2")
ENT.Sound_Idle3 = Sound("Building_Sentrygun.Idle3")
ENT.Sound_Alert = Sound("Building_Sentrygun.Alert")

ENT.Sound_Fire = Sound("Building_Sentrygun.Fire")
ENT.Sound_Fire2 = Sound("Building_Sentrygun.Fire2")

ENT.Sound_Empty = Sound("Building_Sentrygun.Empty")

ENT.Sound_DoneBuilding = Sound("Building_Sentrygun.Built")

ENT.Sound_Down = Sound("vo/engineer_autodestroyedsentry01.mp3")

ENT.MaxAmmo1 = 120

local SentryGibs1 = {
Model("models/buildables/Gibs/sentry1_Gib1.mdl"),
Model("models/buildables/Gibs/sentry1_Gib2.mdl"),
Model("models/buildables/Gibs/sentry1_Gib3.mdl"),
Model("models/buildables/Gibs/sentry1_Gib4.mdl"),
}

local SentryGibs2 = {
Model("models/buildables/Gibs/sentry2_Gib1.mdl"),
Model("models/buildables/Gibs/sentry2_Gib2.mdl"),
Model("models/buildables/Gibs/sentry2_Gib3.mdl"),
Model("models/buildables/Gibs/sentry2_Gib4.mdl"),
}

ENT.Gibs = SentryGibs1
ENT.Sound_Explode = Sound("Building_Sentry.Explode")

ENT.BaseDamage = 2

ENT.OriginZOffset = 40

local function sign(n)
	if n<0 then return -1
	elseif n>0 then return 1
	end
	return 0
end

local function angnorm(n)
	while n<=-180 do n=n+360 end
	while n>180 do n=n-360 end
	return n
end

local function dangnorm(a,b)
	a,b=angnorm(a),angnorm(b)
	local r = a-b
	
	if r<0 then
		local d = r+360
		if d<-r then return d
		else return r end
	else
		local d = r-360
		if d>-r then return d
		else return r end
	end
end

-- Target position retrieving methods

-- default
local function targetpos_default(t)
	return t:BodyTarget(t:GetPos())
end

-- from bounding box
local function targetpos_bb(t)
	return t:LocalToWorld(t:OBBCenter())
end

local targetmethods = {targetpos_default, targetpos_bb}

local CURRENT_SELF

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self.TurretPitch = 0
	self.VisualTurretPitch = 0
	self.TurretYaw = 0
end

-- Find the most suitable target position retrieving method for a given entity
-- (returns nil if the entity cannot be reached)

function ENT:GetTargetMethod(ent, strict)
	local startpos = self:TargetOrigin()

	for i, method in ipairs(targetmethods) do
		local pos = method(ent)
		if pos then
			CURRENT_SELF = self
			local tr = util.TraceLine({
				start=startpos, 
				endpos=pos, 
				filter=self
			})
			CURRENT_SELF = nil
			if tr.Entity == ent or (not strict and tr.StartSolid) then
				return method
			--else
			end
		--else
		end
	end
end

function ENT:SetAmmo1(a)
	self.Ammo1 = a
	self:SetAmmo1Percentage(self.Ammo1 / self.MaxAmmo1)
end

function ENT:AddAmmo1(a)
	self.Ammo1 = self.Ammo1 + a
	self:SetAmmo1Percentage(self.Ammo1 / self.MaxAmmo1)
end

function ENT:TakeAmmo1(a)
	if self.Ammo1 >= a then
		self.Ammo1 = self.Ammo1 - a
		self:SetAmmo1Percentage(self.Ammo1 / self.MaxAmmo1)
		return true
	end
	return false
end

function ENT:OnStartBuilding()
	self.BaseDamage = 2
	self.UpgradeRate = 15
end

function ENT:OnDoneBuilding()
	self:EmitSound(self.Sound_DoneBuilding)
	
	self.Target = nil
	
	self.TurretPitch = 0
	self.TurretYaw = 0
	self.TargetPitch = 0
	self.TargetYaw = 0
	self.DPitch = 0
	self.DYaw = 0
	
	self.IdlePitchSpeed = 0.3
	self.IdleYawSpeed = 0.6
	
	self.AimSpeedMultiplier = 0.5 -- !!!!!! 0.8
	self.FireRateMultiplier = 1.25 -- !!!!!!
	
	self.ActiveSpeed = 4 * self.AimSpeedMultiplier
	self.FireRate = 0.25 * self.FireRateMultiplier
	
	self:SetAmmo1(self.MaxAmmo1)
	
	self.BulletSpread = 0

	self:SetSentryState(1)
	
	self.Idle_Sound = CreateSound(self, self.Sound_Idle)
	
	self.Shoot_Sound = self.Sound_Fire
	self.SoundPitch = 100
end

function ENT:SetSentryState(st)
	if st==1 then
		self.TargetPitch = 0
		self.TargetYaw = 50
		self.Target = nil
		self.NextSearch = CurTime()+0.1
	else
		self.NextSearch = CurTime()+0.1
	end
	self.SentryState = st
end

function ENT:SetAimTarget(p, y)
	self.TargetPitch = p
	self.TargetYaw = y
end

function ENT:OnStartUpgrade()
	self:EmitSound(self.Sound_DoneBuilding, 100, 100)
	
	self.Idle_Sound:Stop()
	if self:GetLevel() == 2 then
		self.Gibs = SentryGibs2
		self.FireRate = 0.125
		self.Shoot_Sound = self.Sound_Fire2
		self.Idle_Sound = CreateSound(self, self.Sound_Idle2)
		
		local health_frac = self:Health() / self:GetMaxHealth()
		self:SetMaxHealth(self:GetObjectHealth())
		self:SetHealth(self:GetObjectHealth() * health_frac)
		
		self.MaxAmmo1 = 120
		self:SetAmmo1(self.MaxAmmo1)
	end
end

function ENT:OnThink()
	self:SetPoseParameter("aim_pitch", self.VisualTurretPitch)
	self:SetPoseParameter("aim_yaw", self.TurretYaw)
	self.Model:SetPoseParameter("aim_pitch", self.VisualTurretPitch)
	self.Model:SetPoseParameter("aim_yaw", self.TurretYaw)
end

function ENT:StartFiring()
	self.Firing = true
	self.NextFire = nil
end

function ENT:ShootPos(right)
	local p
	
	if self:GetLevel() == 1 then
		p = self:GetAttachment(self:LookupAttachment("muzzle"))
		ParticleEffectAttach("weapon_muzzle_flash_assaultrifle", PATTACH_POINT_FOLLOW, self, self:LookupAttachment("muzzle"))
		ParticleEffectAttach("weapon_muzzle_smoke_b", PATTACH_POINT_FOLLOW, self, self:LookupAttachment("muzzle"))
	else
		if right then
			p = self:GetAttachment(self:LookupAttachment("muzzle_r"))
			ParticleEffectAttach("weapon_muzzle_flash_assaultrifle", PATTACH_POINT_FOLLOW, self, self:LookupAttachment("muzzle_r"))
			ParticleEffectAttach("weapon_muzzle_smoke_b", PATTACH_POINT_FOLLOW, self, self:LookupAttachment("muzzle_r"))
		else
			p = self:GetAttachment(self:LookupAttachment("muzzle_l"))
			ParticleEffectAttach("weapon_muzzle_flash_assaultrifle", PATTACH_POINT_FOLLOW, self, self:LookupAttachment("muzzle_l"))
			ParticleEffectAttach("weapon_muzzle_smoke_b", PATTACH_POINT_FOLLOW, self, self:LookupAttachment("muzzle_l"))
		end
	end
	
	return p.Pos
end

function ENT:TargetOrigin()
	return self:GetPos() + self.OriginZOffset * vector_up
end

function ENT:ShootBullets()
	if self:GetState() != 3 then return end
	local dir = (self:GetAngles() + Angle(self.TurretPitch, self.TurretYaw, 0)):Forward()
	
	if self.GunCounter then
		self.GunCounter = 1 - self.GunCounter
	else
		self.GunCounter = 0
	end
	
	local pos = self:ShootPos(self.GunCounter > 0)
	local tarpos = self.TargetPos
	
	if not self.SoundCounter or self.SoundCounter == 0 then
		if self.ShootSoundEnt then
			self.ShootSoundEnt:Stop()
		end
		self.ShootSoundEnt = CreateSound(self, self.Shoot_Sound)
		
		if self:GetLevel() == 1 then
			self.SoundCounter = 1
			self.ShootSoundEnt:Play()
		else
			self.SoundCounter = 2
			self.ShootSoundEnt:PlayEx(1, self.SoundPitch)
		end
	end
	
	self:FireBullets{
		Src = pos,
		Dir = (tarpos - pos):GetNormal(),
		Spread = Vector(0.05, 0.05, 0),
		Attacker = self:GetBuilder(),
		Damage = self.BaseDamage,
	}

	self.SoundCounter = self.SoundCounter - 1
	
	return true
end

local enemylist = {
	["npc_antlion"]=true,
	["npc_antlion_worker"]=true,
	["npc_antlionguard"]=true,
	["bug_tanker"]=true
}

function ENT:FindTarget()
	local Target, MinDist, Method
	for _, v in pairs(ents.FindInSphere(self:GetPos(), self.Range)) do
		if v:IsNPC() and v:Health() > 0 and enemylist[v:GetClass()] then
			local d = self:GetPos():Distance(v:GetPos())
			if not MinDist or d<MinDist then
				local method = self:GetTargetMethod(v, true)
				if method then
					Target = v
					MinDist = d
					Method = method
				end
			end
		end
	end
	
	return Target, Method
end

function ENT:ThinkIdle()
	local dp, dy = sign(self.TargetPitch-self.TurretPitch), sign(self.TargetYaw-self.TurretYaw)
		
	self.TurretPitch = angnorm(self.TurretPitch + dp*self.IdlePitchSpeed)
	if dp * self.TurretPitch >= dp * self.TargetPitch then
		self.TurretPitch = self.TargetPitch
	end
		
	self.TurretYaw = angnorm(self.TurretYaw + dy*self.IdleYawSpeed)
	if dy * self.TurretYaw >= dy * self.TargetYaw then
		self.TargetYaw = -self.TargetYaw
		self.Idle_Sound:Stop()
		
		self.Idle_Sound:PlayEx(1, self.SoundPitch)
		
		self.TargetPitch = 5 * math.random(-2, 2)
	end
	
	self.VisualTurretPitch = self.TurretPitch
	
	if not self.NextSearch or CurTime()>=self.NextSearch then
		self.Target, self.TargetMethod = self:FindTarget()
		if self.Target and self.TargetMethod and self.Target:IsValid() then
			if self.AlertSoundEnt then
				self.AlertSoundEnt:Stop()
			end
			self.AlertSoundEnt = CreateSound(self, self.Sound_Alert)
			self.AlertSoundEnt:PlayEx(1, self.SoundPitch)

			self:SetSentryState(2)
			return
		end
		self.NextSearch = CurTime() + 0.5
	end
end

function ENT:ThinkTarget()
	-- If the target gets too far away, forget about it
	if IsValid(self.Target) and self.Target:Health()>0 and (not self.NextDistanceCheck or CurTime() > self.NextDistanceCheck) then
		local dist = self:GetPos():Distance(self.Target:GetPos())
		--print(self.Target)
		if dist > self.Range then
			self.Target = nil
		end
		self.NextDistanceCheck = CurTime() + 0.25
	end
	
	-- Lost target, find another one, or go back to idle
	if not self.Target or not self.Target:IsValid() or self.Target:Health()<=0 then
		self.Target, self.TargetMethod = self:FindTarget()
		if not self.Target or not self.TargetMethod then
			self.Firing = false
			self:SetSentryState(1)
			return
		end
		
		if self.AlertSoundEnt then
			self.AlertSoundEnt:Stop()
		end
		self.AlertSoundEnt = CreateSound(self, self.Sound_Alert)
		self.AlertSoundEnt:PlayEx(1, self.SoundPitch)
	end
	
	self.TargetPos = self.TargetMethod(self.Target)
	
	-- Tracking
	local ang = self:GetAngles()-(self.TargetPos - self:TargetOrigin()):Angle()
	self.TargetPitch = angnorm(ang.p)
	self.TargetYaw = angnorm(ang.y)
	
	local dp = math.Clamp(0.2*dangnorm(self.TargetPitch,self.TurretPitch), -self.ActiveSpeed, self.ActiveSpeed)
	local dy = math.Clamp(0.2*dangnorm(self.TargetYaw,self.TurretYaw), -self.ActiveSpeed, self.ActiveSpeed)

	self.TurretPitch = math.Clamp(angnorm(self.TurretPitch + dp),-89.9, 89.9)
	self.VisualTurretPitch = math.Clamp(self.TurretPitch, -50, 50)
	self.TurretYaw = angnorm(self.TurretYaw + dy)
	--/*
	-- Firing
	if self.Firing then
		if not self.NextFire or CurTime()>=self.NextFire then
			local ok = self:TakeAmmo1(1)
			
			self.ShootAnimCounter = (self.ShootAnimCounter or 1) - 1
			if self.ShootAnimCounter == 0 then
				self.ShootAnimCounter = 4
				if ok then
					self:RestartGesture(ACT_RANGE_ATTACK1)
				elseif self:GetLevel() > 1 then
					self:RestartGesture(ACT_RANGE_ATTACK1_LOW)
				end
			end
			
			if ok then
				self:ShootBullets()
			else
				self:EmitSound(self.Sound_Empty)
			end
			
			self.NextFire = CurTime() + self.FireRate
		end
	else
		self.ShootAnimCounter = nil
		--self:RestartGesture(ACT_INVALID)
	end
	--*/
	-- Check visibility and decide whether to shoot or not
	if not self.NextCheckVis or CurTime()>=self.NextCheckVis then
		local firestate = self.Firing
		
		if math.abs(dangnorm(self.TurretPitch,self.TargetPitch)) < 5 and math.abs(dangnorm(self.TurretYaw,self.TargetYaw)) < 5 then
			firestate = true
		else
			firestate = false
		end
		
		if firestate then
			self.TargetMethod = self:GetTargetMethod(self.Target)
			
			if not self.TargetMethod then
				firestate = false
				self.Target = nil
			end
		end
		
		if firestate ~= self.Firing then
			if firestate then
				self:StartFiring()
			else
				self.Firing = false
			end
		end
		
		self.NextCheckVis = CurTime() + 0.25
	end
	
	-- Update target, if someone gets closer than the current target, switch
	if not self.NextSearch or CurTime()>=self.NextSearch then
		self.Target, self.TargetMethod = self:FindTarget()
		self.NextSearch = CurTime() + 1
	end
end

function ENT:OnThinkActive()
	if self.SentryState == 1 then -- Idling
		self:ThinkIdle()
	elseif self.SentryState == 2 then -- Targeting
		self:ThinkTarget()
	end
end

function ENT:NeedsResupply()
	return self.Ammo1 < self.MaxAmmo1
end

function ENT:Resupply(max)
	local max0 = max
	local metal_spent

	-- bullets
	local num_bullets = math.min(self.MaxAmmo1 - self.Ammo1, math.min(max, 45))	-- +40 bullets per wrench hit
	metal_spent = num_bullets
	if metal_spent > 0 then
		max = max - metal_spent
		self:AddAmmo1(num_bullets)
	end
	
	return max0 - max
end

function ENT:OnRemove()
	if self.Idle_Sound then
		self.Idle_Sound:Stop()
	end
end