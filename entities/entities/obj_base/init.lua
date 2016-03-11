AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

ENT.Levels = {}
ENT.Gibs = {}

ENT.Sound_Explode = Sound("Building_Dispenser.Explode")

ENT.DefaultBuildRate = 0.5
ENT.BuildRate = ENT.DefaultBuildRate

ENT.RepairRate = 11
ENT.UpgradeRate = 25

ENT.InitialHealth = 1

function ENT:OnStartBuilding() end
function ENT:OnDoneBuilding() end
function ENT:OnStartUpgrade() end
function ENT:PreUpgradeAnim() end
function ENT:OnDoneUpgrade() end
function ENT:PostEnable() end
function ENT:OnThink() end
function ENT:OnThinkActive() end

function ENT:Initialize()
	self:SetOwner(self.Owner)
	
	self:SetModel(self.Levels[1][1])
	
	self:SetModelScale(0.9, 0, 0)
		
	self:SetHullType(HULL_HUMAN)
	self:SetHullSizeNormal()

	self:CapabilitiesAdd(CAP_FRIENDLY_DMG_IMMUNE)
	
	self:SetMaxHealth(self.ObjectHealth)
	self:SetHealth(self.ObjectHealth)
	
	self:SetCollisionBounds(unpack(self.CollisionBox))
	self:SetCollisionGroup(15)
	self:PhysicsInitBox(unpack(self.CollisionBox))
	self:SetSolid(SOLID_BBOX)
	self:SetMoveType(MOVETYPE_NONE)
	
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(false)
	end
	
	self.Model = ents.Create("obj_anim")
	self.Model:SetOwner(self)
	self.Model:Spawn()
	self.Model:SetNoDraw(true)
	
	--[[
	0 : Undefined
	1 : Building
	2 : Upgrading
	3 : Active
	]]
	self:SetMetal(0)
	self:SetState(0)
	self:SetNPCState(NPC_STATE_IDLE)
	
	self.StartTime = CurTime()
	self.TimeLeft = 0
	self:SetNoDraw(true)
end

function ENT:Build()
	if self:GetState()>0 then return false end
	self:OnStartBuilding()
	self:SetModel(self.Levels[1][1])
	self:SetCollisionBounds(unpack(self.CollisionBox))
	
	self:SetNPCState(NPC_STATE_SCRIPT)
	
	self.Model:SetNoDraw(false)
	self.Model:ResetSequence(self:SelectWeightedSequence(ACT_OBJ_ASSEMBLING))
	self.Model:SetCycle(0)
	self.Model:SetPlaybackRate(self.BuildRate)
	
	self:SetLevel(1)
	self:SetState(1)
	self.StartTime = CurTime()
	
	self.BuildProgress = 0
	self.BuildProgressMax = self.Model:SequenceDuration() / self.BuildRate
	self:SetBuildProgress(0)
end

function ENT:Upgrade()
	if self:GetLevel()>=self.NumLevels then return false end
	self:LevelUp()
	self:OnStartUpgrade()

	self:SetModel(self.Levels[self:GetLevel()][1])
	self.Model:SetModel(self.Levels[self:GetLevel()][1])
	self:SetCollisionBounds(unpack(self.CollisionBox))
		
	self:PreUpgradeAnim()
	self:SetNPCState(NPC_STATE_SCRIPT)
	self:SetNoDraw(true)
	self.Model:SetNoDraw(false)
	self.Model:ResetSequence(self:SelectWeightedSequence(ACT_OBJ_UPGRADING))
	self.Model:SetCycle(0)
	self.Model:SetPlaybackRate(1)
	
	self:SetState(2)
	self.StartTime = CurTime()
	self.Duration = self.Model:SequenceDuration()
	self.TimeLeft = self.Model:SequenceDuration()
end

function ENT:Enable()
	self:SetModel(self.Levels[self:GetLevel()][2])
	self.Model:SetModel(self.Levels[self:GetLevel()][2])
	self:SetCollisionBounds(unpack(self.CollisionBox))
	
	self:SetNPCState(NPC_STATE_IDLE)
	self.Model:SetNoDraw(true)
	self:SetNoDraw(false)
	self:ResetSequence(self:SelectWeightedSequence(ACT_OBJ_RUNNING))
	self:SetCycle(0)
	self:SetPlaybackRate(1)
	
	local prevstate = self:GetState()
	self:SetState(3)
	self:PostEnable(prevstate)
end

function ENT:Explode()
	for _,v in pairs(self.Gibs) do
		if type(v)=="string" then
			local drop = ents.Create("item_droppedweapon")
			drop:SetSolid(SOLID_VPHYSICS)
			drop:SetModel(v)
			drop:PhysicsInit(SOLID_VPHYSICS)
			drop:SetPos(self:GetPos())
			drop:Spawn()
			drop:Activate()
			
			drop:SetMoveType(MOVETYPE_VPHYSICS)
			drop:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
			
			local phys = drop:GetPhysicsObject()
			if phys:IsValid() then
				phys:AddAngleVelocity(Vector(math.random(-100,100),math.random(-100,100),math.random(-100,100)))
				phys:AddVelocity(Vector(math.random(-100,100),math.random(-100,100),math.random(100,300)))
				phys:Wake()
			end
		end
	end
	
	local effectdata = EffectData()
		effectdata:SetOrigin(self:GetPos())			// Where is hits
		effectdata:SetScale(1)			// Size of explosion
		effectdata:SetRadius(1)		// What texture it hits
			util.Effect( "st_staticboom", effectdata )
			util.ScreenShake(self:GetPos(), 10, 5, 1, 650 )
			
	self:EmitSound(self.Sound_Explode, 100, 96)
	
	local builder = self:GetBuilder()
	
	builder:EmitSound(self.Sound_Down)
	
	self:Remove()
end

function ENT:Think()
	local state = self:GetState()
	local deltatime = 0
	
	if self.LastThink then
		deltatime = CurTime() - self.LastThink
	end
	self.LastThink = CurTime()
	
	self:OnThink()
	
	local builder = self:GetBuilder()
	
	if builder:Team() != 2 then self:Remove() end
	
	if state==0 then
		if CurTime()-self.StartTime>=self.TimeLeft then
			self:Build()
		end
	elseif state==1 then
		local time_added = deltatime
		
		if self.BuildBoost then
			local total = 1
			local mul = self.DefaultBuildRate / self.BuildRate
			
			for pl,data in pairs(self.BuildBoost) do
				if CurTime() > data.endtime then
					self.BuildBoost[pl] = nil
				else
					total = total + data.val * mul
				end
			end
			
			self.Model:SetPlaybackRate(self.BuildRate * total)
			time_added = time_added * total
		end
		
		self.BuildProgress = math.Clamp(self.BuildProgress + time_added, 0, self.BuildProgressMax)
		self:SetBuildProgress(self.BuildProgress / self.BuildProgressMax)
		
		local health = math.Clamp((self.BuildProgress / self.BuildProgressMax) * self:GetMaxHealth(), self.InitialHealth, self:GetMaxHealth())
		self:SetHealth(health - (self.BuildSubstractHealth or 0))
		
		if self.BuildProgress >= self.BuildProgressMax then
			self:OnDoneBuilding()
			self:SetHealth(self:GetMaxHealth() - (self.BuildSubstractHealth or 0))
			self:Enable()
		end
	elseif state==2 then
		if CurTime()-self.StartTime>=self.TimeLeft then
			self:OnDoneUpgrade()
			self:Enable()
		end
	elseif state==3 then
		self:OnThinkActive()
	end
	
	self:NextThink(CurTime())
	return true
end

function ENT:OnTakeDamage(dmginfo)
	if dmginfo:GetAttacker():IsPlayer() then 
		dmginfo:SetDamage(0) 
	end
	
	if game.SinglePlayer() and self:GetState() == 3 then self:RestartGesture(ACT_RANGE_ATTACK1) end
	
	self:SetHealth(self:Health() - dmginfo:GetDamage())
	if not self.BuildSubstractHealth then
		self.BuildSubstractHealth = 0
	end
	self.BuildSubstractHealth = self.BuildSubstractHealth + dmginfo:GetDamage()
	if self:Health()<=0 then
		self:Explode()
	end
end

function ENT:NeedsResupply()
	return false
end

function ENT:Resupply(max)
end

function ENT:AddMetal(owner, max)
	if not self.BuildBoost then
		self.BuildBoost = {}
	end
	
	local mult = 1.5
	local w = owner:GetActiveWeapon()
	if IsValid(w) and w.ConstructRateMultiplier then
		mult = w.ConstructRateMultiplier
	end
	
	self.BuildBoost[owner] = {val=mult, endtime=CurTime() + 0.8}
	
	-- Building or upgrading
	if self:GetState()~=3 then return 0 end
	
	local max0 = max
	local metal_spent

	local repaired, resupplied, upgraded
	
	-- Repair
	metal_spent = math.Clamp(math.ceil((self:GetMaxHealth() - self:Health()) * 0.2), 0, math.min(max, self.RepairRate))
	
	if metal_spent > 0 then
		self:SetHealth(math.Clamp(self:Health() + 5 * metal_spent, 0, self:GetMaxHealth()))
		max = max - metal_spent
		repaired = true
	end
	
	-- Upgrade
	if self:GetLevel()<self.NumLevels then
		local current = self:GetMetal()
		metal_spent = math.Clamp(self.UpgradeCost - current, 0, math.min(max, self.UpgradeRate + 10))
		current = current + metal_spent
		
		if current>=self.UpgradeCost then
			self:SetMetal(0)
			self:Upgrade()
			-- Upgrading already resupplies ammo so we don't need to do anything else
			upgraded = true
		elseif not repaired or not self:NeedsResupply() then
			-- Add to the upgrade status only if no metal was spent repairing the building or if the building doesn't need to be resupplied first
			self:SetMetal(current)
		end
		
		max = max - metal_spent
	end
	
	-- Resupply (todo)
	if self:NeedsResupply() and not upgraded then
		metal_spent = self:Resupply(max)
		
		if metal_spent then
			max = max - metal_spent
			resupplied = true
		end
	end
	
	return max0 - max
end