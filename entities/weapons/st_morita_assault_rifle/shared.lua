SWEP.Base = "st_base"

SWEP.ViewModel = "models/ryan7259/starshiptroopers/weapons/v_morita_mk4.mdl"
SWEP.WorldModel	= "models/ryan7259/starshiptroopers/weapons/w_morita_mk4.mdl"

SWEP.Spawnable = true
SWEP.AdminOnly = true

SWEP.Primary.Sound = Sound("sfx_mk4_fire.wav")
SWEP.Primary.RPM = 750
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Ammo = "ar2"
SWEP.Primary.DamageMax = 11
SWEP.Primary.DamageMin = 7
SWEP.Primary.TracerName	= "AirboatGunTracer"

SWEP.Secondary.Sound = Sound("sfx_mk4_grenade_launch.wav")
SWEP.Secondary.Cone = 0.2
SWEP.Secondary.RPM = 60
SWEP.Secondary.ClipSize	= 1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Ammo = "smg1_grenade"

function SWEP:Precache()
	util.PrecacheSound(self.Primary.Sound)
	util.PrecacheSound(self.Secondary.Sound)

	util.PrecacheSound("sfx_mk4_reload.wav")
end

function SWEP:DoImpactEffect(tr, nDamageType)
	if (tr.HitSky) then return end
	
	local effectdata = EffectData()
	effectdata:SetOrigin(tr.HitPos + tr.HitNormal)
	effectdata:SetNormal(tr.HitNormal)
	util.Effect("AR2Impact", effectdata)
end

function SWEP:PrimaryAttack()
	if self.Owner:GetAmmoCount("Grenade") > 0 then
		if self.Owner:IsPlayer() and self.Owner:KeyDown(IN_USE) then
			self:ThrowGrenade()
			return 
		end
	end

	local heat = self.Owner:GetNetVar("Heat", 0)

	if heat < 119 then
		self:FireShotPrim()
		self.Weapon:EmitSound(self.Primary.Sound)
		self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
		
		self.Owner:SetAnimation(PLAYER_ATTACK1)
		self.Owner:MuzzleFlash()
		
		self.Weapon:SetNextPrimaryFire(CurTime() + 1 / (self.Primary.RPM / 60))

		if SERVER then
			self.Owner:SetNetVar("Heat", heat + 4.2)
		end
	end
end

function SWEP:FireRocketSec()
	if SERVER then
		local grenade = ents.Create("tiramisu_fragnade")
		grenade:SetPos(self.Owner:GetShootPos() + self.Owner:GetAimVector() * 50)
		grenade:SetOwner(self.Owner)
		grenade:Spawn()
		grenade:Activate()
		
		grenade:GetPhysicsObject():SetVelocity(self.Owner:GetAimVector() * 950)
		self.Owner:ViewPunch(Angle(-8, 2, 0))
	end
end

function SWEP:SecondaryAttack()
	if self:CanSecondaryAttack() then
		self:FireRocketSec()
		self.Weapon:EmitSound(self.Secondary.Sound)
		self.Weapon:TakeSecondaryAmmo(1)
		self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
		
		self.Owner:SetAnimation(PLAYER_ATTACK1)
		self.Owner:MuzzleFlash()
		
		self.Weapon:SetNextSecondaryFire(CurTime() + 1 / (self.Secondary.RPM / 60))
	end
end

function SWEP:Reload()
	if self.Weapon:DefaultReload(ACT_VM_RELOAD) then
		self.Weapon:EmitSound(Sound("sfx_mk4_reload.wav"))
	end
end