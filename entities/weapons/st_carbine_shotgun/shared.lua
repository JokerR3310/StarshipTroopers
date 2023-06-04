// Variables that are used on both client and server
SWEP.Base				= "st_base"

SWEP.ViewModel			= "models/ryan7259/starshiptroopers/weapons/v_moritamk2_pumpshotty.mdl"
SWEP.WorldModel			= "models/ryan7259/starshiptroopers/weapons/w_moritamk2_pumpshotty.mdl"

SWEP.Spawnable			= true
SWEP.AdminOnly			= true

SWEP.Primary.Sound 			= Sound("sfx_mk4_fire.wav")	// Sound of the gun
SWEP.Primary.RPM			= 690							// This is in Rounds Per Minute
SWEP.Primary.ClipSize		= 160							// Size of a clip
SWEP.Primary.DefaultClip	= 460							// Default number of bullets in a clip
SWEP.Primary.Ammo			= "SMG1"	
SWEP.Primary.DamageMax		= 14
SWEP.Primary.DamageMin		= 10

SWEP.Secondary.Sound 		= Sound("sfx_shotgun_primary_fire.wav")	// Sound of the gun
SWEP.Secondary.RPM			= 60							// This is in Rounds Per Minute
SWEP.Secondary.ClipSize		= 16							// Size of a clip
SWEP.Secondary.DefaultClip	= 1								// Default number of bullets in a clip
SWEP.Secondary.Ammo			= "SMG1"
SWEP.Secondary.DamageMax	= 20
SWEP.Secondary.DamageMin	= 10

function SWEP:FireBuckshotSec()
	local bullet = {}
    bullet.Num      = 10
    bullet.Src      = self.Owner:GetShootPos()         	// Source
    bullet.Dir      = self.Owner:GetAimVector()        	// Dir of bullet
    bullet.Spread   = Vector( 0.15, 0.15, 0 )        	// Aim Cone
    bullet.Tracer   = 1                               	// Show a tracer on every x bullets
    bullet.Force    = 10                              	// Amount of force to give to phys objects
    bullet.Damage   = math.Rand(self.Secondary.DamageMin,self.Secondary.DamageMax)
    bullet.AmmoType = self.Primary.Ammo
    self.Owner:FireBullets( bullet )
end

function SWEP:SecondaryAttack()
	if self:Clip1() >= 10 then
			self:FireBuckshotSec()
		self.Weapon:EmitSound(self.Secondary.Sound)
		self.Weapon:TakePrimaryAmmo(10)
		self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )

		self.Owner:SetAnimation( PLAYER_ATTACK1 )
		self.Owner:MuzzleFlash()
		self.Owner:ViewPunch( Angle( -4, 2, 0 ))

		self.Weapon:SetNextSecondaryFire(CurTime()+1/(self.Secondary.RPM/60))
	else
		self.Weapon:EmitSound(Sound("sfx_gun_empty.wav"))
	end
end