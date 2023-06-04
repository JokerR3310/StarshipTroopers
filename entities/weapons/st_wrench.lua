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

local Npclist = {
    ["npc_antlion"] = true,
    ["npc_antlion_worker"] = true,
    ["npc_antlionguard"] = true,
    ["bug_tanker"] = true
}

function SWEP:Holster()
	return true
end

function SWEP:Deploy()
	self:SetHoldType( self.HoldType )
	return true
end

function SWEP:PrimaryAttack()
    if SERVER then
        local tracedata = {}
        tracedata.start = self:GetOwner():GetShootPos()
        tracedata.endpos = self:GetOwner():GetShootPos() + self:GetOwner():GetAimVector() * 66
        tracedata.filter = self:GetOwner()
        tracedata.mins = self.Mins
        tracedata.maxs = self.Maxs

        if self:GetOwner():IsPlayer() then
            self:GetOwner():LagCompensation(true)
        end

        local tr = util.TraceHull(tracedata)

        if self:GetOwner():IsPlayer() then
            self:GetOwner():LagCompensation(false)
        end

        local ent = tr.Entity
        local dmginfo = DamageInfo()
        dmginfo:SetDamagePosition(tr.HitPos)
        dmginfo:SetDamageType(DMG_CLUB)
        dmginfo:SetAttacker(self:GetOwner())
        dmginfo:SetInflictor(self:GetOwner())
        dmginfo:SetDamage(20) -- 12

        if IsValid(ent) then
            if ent.Building then
                local m = ent:AddMetal(self:GetOwner(), self:GetOwner():GetAmmoCount("AirboatGun"))

                if m > 0 then
                    self:GetOwner():EmitSound(self.HitBuildingSuccess)
                    self:GetOwner():RemoveAmmo(m, "AirboatGun")

                    if game.SinglePlayer() and ent:GetState() == 3 then
                        ent:RestartGesture(ACT_RANGE_ATTACK1)
                    end
                elseif ent:GetState() == 1 then
                    self:GetOwner():EmitSound(self.HitBuildingSuccess)
                else
                    self:GetOwner():EmitSound(self.HitBuildingFailure)
                end
            else
                self:GetOwner():EmitSound(self.HitFlesh)

                if Npclist[ent:GetClass()] then
                    ent:TakeDamageInfo(dmginfo)
                end
            end
        elseif ent:IsWorld() then
            self:GetOwner():EmitSound(self.HitWorld)
        else
            self:GetOwner():EmitSound(self.Swing)
        end

        self:SetNextPrimaryFire(CurTime() + 0.8)
    end

    self:GetOwner():SetAnimation(PLAYER_ATTACK1)
    self:SendWeaponAnim(ACT_VM_MISSCENTER)
end

function SWEP:SecondaryAttack()
    if SERVER then
        local tracedata = {}
        tracedata.start = self:GetOwner():GetShootPos()
        tracedata.endpos = self:GetOwner():GetShootPos() + self:GetOwner():GetAimVector() * 66
        tracedata.filter = self:GetOwner()
        tracedata.mins = self.Mins
        tracedata.maxs = self.Maxs

        if self:GetOwner():IsPlayer() then
            self:GetOwner():LagCompensation(true)
        end

        local tr = util.TraceHull(tracedata)

        if self:GetOwner():IsPlayer() then
            self:GetOwner():LagCompensation(false)
        end

        local ent = tr.Entity

        if self:GetOwner():KeyDown(IN_USE) and IsValid(ent) and ent.Building then
            if ent:GetState() ~= 3 then return end

            if ent:GetBuilder() == self:GetOwner() then
                ent:Remove()
                self:GetOwner():ChatPrint("Building has been dismantled!")
                self:GetOwner():SetAmmo(math.Clamp(self:GetOwner():GetAmmoCount("AirboatGun") + 100, 0, 200), "AirboatGun")
                self:GetOwner():EmitSound("vo/engineer_sentrypacking0" .. math.random(1, 3) .. ".mp3", 80, 95)
            end
        end

        self:SetNextSecondaryFire(CurTime() + 1.2)
    end
end