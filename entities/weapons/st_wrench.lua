AddCSLuaFile()

SWEP.Base			= "st_base"

SWEP.PrintName		= "Wrench"
SWEP.Author			= "-=JokerR |CMBG|=-"

SWEP.Category		= "SST Weapons 2"
SWEP.HoldType		= "knife"

SWEP.ViewModel		= "models/wrepons/v_crowbar.mdl"
SWEP.WorldModel		= "models/wrepons/w_crowbar.mdl"

SWEP.Spawnable		= true
SWEP.AdminOnly		= true

SWEP.Slot 			= 0
SWEP.SlotPos 		= 1
SWEP.DrawAmmo		= false

if CLIENT then
	SWEP.WepSelectIcon = surface.GetTextureID("weapons/st_wrench")
end

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"

SWEP.Swing = Sound("Weapon_Wrench.Miss")
SWEP.HitFlesh = Sound("Weapon_Wrench.HitFlesh")
SWEP.HitWorld = Sound("Weapon_Wrench.HitWorld")
SWEP.HitBuildingSuccess = Sound("Weapon_Wrench.HitBuilding_Success")
SWEP.HitBuildingFailure = Sound("Weapon_Wrench.HitBuilding_Failure")

SWEP.Npclist = {"npc_antlion", "npc_antlion_worker", "npc_antlionguard", "bug_tanker"}

function SWEP:Holster()
	return true
end

function SWEP:Deploy()
	self:SetHoldType( self.HoldType )
	return true
end

function SWEP:PrimaryAttack(tr)
	if SERVER then
		local tr = util.TraceHull({
			start = self.Owner:GetShootPos(),
			endpos = self.Owner:GetShootPos() + (self.Owner:GetAimVector() * 66),
			mins = self.Mins,
			maxs = self.Maxs,
			filter = self.Owner
		})
		
	local ent = tr.Entity

	local dmginfo = DamageInfo()
		dmginfo:SetDamagePosition(tr.HitPos)
		dmginfo:SetDamageType(DMG_CLUB)
		dmginfo:SetAttacker(self.Owner)
		dmginfo:SetInflictor(self.Owner)
		dmginfo:SetDamage(20) -- 12
	
	if ent and ent:IsValid() then
		if ent.Building then	
			local m = ent:AddMetal(self.Owner, self.Owner:GetAmmoCount("AirboatGun"))
			if m > 0 then
				self.Owner:EmitSound(self.HitBuildingSuccess)
				self.Owner:RemoveAmmo(m, "AirboatGun")
				if game.SinglePlayer() and ent:GetState() == 3 then 
					ent:RestartGesture(ACT_RANGE_ATTACK1) 
				end
			elseif ent:GetState() == 1 then
				self.Owner:EmitSound(self.HitBuildingSuccess)
			else
				self.Owner:EmitSound(self.HitBuildingFailure)
			end
		else
			self.Owner:EmitSound(self.HitFlesh)
			if !ent:IsPlayer() then
				if ent:IsNPC() and (table.HasValue(self.Npclist, ent:GetClass())) then
					ent:TakeDamageInfo(dmginfo)
				end
			end
		end
	elseif ent:IsWorld() then
		self.Owner:EmitSound(self.HitWorld)
	else
		self.Owner:EmitSound(self.Swing)
	end

	self.Weapon:SetNextPrimaryFire(CurTime() + 0.75)
	end
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self.Weapon:SendWeaponAnim(ACT_VM_MISSCENTER)
end

function SWEP:SecondaryAttack(tr)
	if SERVER then
		local tr = util.TraceHull({
			start = self.Owner:GetShootPos(),
			endpos = self.Owner:GetShootPos() + (self.Owner:GetAimVector() * 66),
			mins = self.Mins,
			maxs = self.Maxs,
			filter = self.Owner
		})
		
	local ent = tr.Entity
	
	if self.Owner:KeyDown(IN_USE) then
		if ent and ent:IsValid() then
			if ent.Building then
				local state = ent:GetState()
				if state != 3 then return end
				local builder = ent:GetBuilder()
				if builder == self.Owner then
					ent:Remove()
					self.Owner:ChatPrint("Building has been dismantled!")
					self.Owner:SetAmmo(math.Clamp(self.Owner:GetAmmoCount("AirboatGun") + 100, 0, 200), "AirboatGun")

					self.Owner:EmitSound("vo/engineer_sentrypacking0"..math.random(1,3)..".mp3", 80, 95)
				end
			end
		end
	end
		self.Weapon:SetNextSecondaryFire(CurTime() + 1.2)
	end
end