AddCSLuaFile()

SWEP.Base			= "st_base"

SWEP.PrintName		= "Wrench"
SWEP.Author			= "JokerR"

SWEP.Category		= "SST Weapons 2"
SWEP.HoldType		= "knife"

SWEP.ViewModel		= "models/weapons/v_wrench.mdl"
SWEP.WorldModel		= "models/weapons/w_wrench.mdl"

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

function SWEP:Holster()
	return true
end

function SWEP:Deploy()
	self:SetHoldType( self.HoldType )
	return true
end

function SWEP:PrimaryAttack()
	local user = self:GetOwner()

    if SERVER then
        local tracedata = {}
        tracedata.start = user:GetShootPos()
        tracedata.endpos = user:GetShootPos() + user:GetAimVector() * 66
        tracedata.filter = user
        tracedata.mins = self.Mins
        tracedata.maxs = self.Maxs

        if user:IsPlayer() then
            user:LagCompensation(true)
        end

        local tr = util.TraceHull(tracedata)

        if user:IsPlayer() then
            user:LagCompensation(false)
        end

        local ent = tr.Entity
        local dmginfo = DamageInfo()
        dmginfo:SetDamagePosition(tr.HitPos)
        dmginfo:SetDamageType(DMG_CLUB)
        dmginfo:SetAttacker(user)
        dmginfo:SetInflictor(user)
        dmginfo:SetDamage(20) -- 12

        if IsValid(ent) then
            if ent.Building then
                local m = ent:AddMetal(user, user:GetAmmoCount("AirboatGun"))

                if m > 0 then
                    user:EmitSound(self.HitBuildingSuccess)
                    user:RemoveAmmo(m, "AirboatGun")
                elseif ent:GetState() == 1 then
                    user:EmitSound(self.HitBuildingSuccess)
                else
                    user:EmitSound(self.HitBuildingFailure)
                end
            else
                user:EmitSound(self.HitFlesh)

                ent:TakeDamageInfo(dmginfo)
            end
        elseif ent:IsWorld() then
            user:EmitSound(self.HitWorld)
        else
            user:EmitSound(self.Swing)
        end

        self:SetNextPrimaryFire(CurTime() + 0.8)
    end

    user:SetAnimation(PLAYER_ATTACK1)
    self:SendWeaponAnim(ACT_VM_MISSCENTER)
end

function SWEP:SecondaryAttack()
	local user = self:GetOwner()

    if SERVER then
        local tracedata = {}
        tracedata.start = user:GetShootPos()
        tracedata.endpos = user:GetShootPos() + user:GetAimVector() * 66
        tracedata.filter = user
        tracedata.mins = self.Mins
        tracedata.maxs = self.Maxs

        if user:IsPlayer() then
            user:LagCompensation(true)
        end

        local tr = util.TraceHull(tracedata)

        if user:IsPlayer() then
            user:LagCompensation(false)
        end

        local ent = tr.Entity

        if user:KeyDown(IN_USE) and IsValid(ent) and ent.Building then
            if ent:GetState() ~= 3 then return end

            if ent:GetBuilder() == user then
                ent:Remove()
                user:ChatPrint("Building has been dismantled!")
                user:SetAmmo(math.Clamp(self:GetOwner():GetAmmoCount("AirboatGun") + 100, 0, 200), "AirboatGun")
                user:EmitSound("vo/engineer_sentrypacking0" .. math.random(1, 3) .. ".mp3", 80, 95)
            end
        end

        self:SetNextSecondaryFire(CurTime() + 1.2)
    end
end