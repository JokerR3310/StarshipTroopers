// Variables that are used on both client and server
SWEP.Base				= "st_base"
SWEP.HoldType			= "rpg"

SWEP.ViewModel			= "models/ryan7259/starshiptroopers/weapons/v_m136_launcher.mdl"
SWEP.WorldModel			= "models/ryan7259/starshiptroopers/weapons/w_m136_launcher.mdl"

SWEP.Spawnable			= true
SWEP.AdminOnly			= true

SWEP.Primary.Sound 			= Sound("sfx_rocket_fire.wav")				// Sound of the gun
SWEP.Primary.RPM			= 60					// This is in Rounds Per Minute
SWEP.Primary.ClipSize		= 1				// Size of a clip
SWEP.Primary.DefaultClip	= 0					// Default number of bullets in a clip
SWEP.Primary.Automatic		= false					// Automatic/Semi Auto
SWEP.Primary.Ammo			= "RPG_Round"

function SWEP:Precache()
	util.PrecacheSound(self.Primary.Sound)
	util.PrecacheSound("sfx_rocket_empty.wav")
	util.PrecacheSound("sfx_rocket_reload.wav")
end

function SWEP:PrimaryAttack()
	if self:Clip1() == 0 then
		self.Weapon:EmitSound(Sound("sfx_rocket_empty.wav"))
		self.Weapon:SetNextPrimaryFire(CurTime()+1)
		return
	end

	self:FireRocket()
	self.Weapon:EmitSound(self.Primary.Sound)
	self.Weapon:TakePrimaryAmmo(1)
	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )

	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	self.Owner:MuzzleFlash()
	self.Owner:ViewPunch( Angle( -26, 2, 0 ) )
		
	self.Weapon:SetNextPrimaryFire(CurTime()+1/(self.Primary.RPM/60))
end

function SWEP:FireRocket()	
	local aim = self.Owner:GetAimVector()
	local side = aim:Cross(Vector(0,0,1))
	local up = side:Cross(aim)
	local pos = self.Owner:GetShootPos() +  aim * 50 + side * 4 + up * -1	--offsets the rocket so it spawns from the muzzle (hopefully)
	if SERVER then
		local rocket = ents.Create("tiramisu_rpg_heat")
		if !rocket:IsValid() then return false end
		rocket:SetAngles(aim:Angle()+Angle(90,0,0))
		rocket:SetPos(pos)
		rocket:SetOwner(self.Owner)
	rocket:Spawn()
	rocket:Activate()
	end
end

function SWEP:Reload()
	if self.Weapon:DefaultReload(ACT_VM_RELOAD) then
		self.Weapon:EmitSound(Sound("sfx_rocket_reload.wav"))
		self.Weapon:EmitSound(Sound("vo/npc/male01/coverwhilereload0"..math.random(1,2)..".wav"))
	end
end
