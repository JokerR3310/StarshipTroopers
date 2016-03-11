// Variables that are used on both client and server
SWEP.Base				= "weapon_base"
SWEP.HoldType			= "ar2"

SWEP.ViewModelFOV		= 65		// How big the gun will look
SWEP.ViewModelFlip		= false		// True for CSS models, False for HL2 models
SWEP.ViewModel			= "models/ryan7259/starshiptroopers/weapons/v_moritamk2_pumpshotty.mdl"
SWEP.WorldModel			= "models/ryan7259/starshiptroopers/weapons/w_moritamk2_pumpshotty.mdl"

SWEP.Spawnable			= false
SWEP.AdminOnly			= false

SWEP.Primary.Sound 			= Sound("sfx_mk2_1st_person_tail.wav")	// Sound of the gun
SWEP.Primary.RPM			= 0										// This is in Rounds Per Minute
SWEP.Primary.ClipSize		= 0										// Size of a clip
SWEP.Primary.DefaultClip	= 0										// Default number of bullets in a clip
SWEP.Primary.Automatic		= true									// Automatic/Semi Auto
SWEP.Primary.Ammo			= "none"	
SWEP.Primary.DamageMax		= 0
SWEP.Primary.DamageMin		= 0
SWEP.Primary.Spread			= 0.05
SWEP.Primary.TracerName		= "Tracer"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

function SWEP:Initialize()
	self:SetWeaponHoldType( self.HoldType )
end

function SWEP:Deploy()
	self:SetWeaponHoldType( self.HoldType )
	self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
	return true
end

function SWEP:Precache()
	util.PrecacheSound(self.Primary.Sound)
	util.PrecacheSound(self.Secondary.Sound)
	util.PrecacheSound(Sound("sfx_mk2_reload.wav"))
	util.PrecacheSound(Sound("sfx_gun_empty.wav"))
end

SWEP.NextThrow = 0
function SWEP:ThrowGrenade()
	if CurTime() < self.NextThrow then return end

	local oldclass = self.Owner:GetActiveWeapon():GetClass()
	local oldmodel = self.Owner:GetViewModel():GetModel()

	self.Owner:GetViewModel():SetModel("models/weapons/v_grenade.mdl")

	self.Weapon:SetNextPrimaryFire(CurTime()+1)
	self.Weapon:SetNextSecondaryFire(CurTime()+1)

	self.Weapon:EmitSound("npc/vort/claw_swing" .. math.random(1, 2) .. ".wav")
	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	
	self.Owner:SetAmmo(self.Owner:GetAmmoCount( "Grenade" ) - 1, "Grenade")

	if SERVER then
		local nade = ents.Create( "st_nade" )
		nade:SetPos(self.Owner:GetShootPos()+self.Owner:GetAimVector() / 50)
		nade:SetOwner(self.Owner)

		nade:Spawn()
		nade:Activate()
		nade:GetPhysicsObject():SetVelocity(self.Owner:GetAimVector() * 1000)
	end

	self.Owner:ViewPunch( Angle( -14, 2, 0 ) )

	timer.Simple( 0.4, function()
		if IsValid(self) then
			if IsValid(self.Owner:GetActiveWeapon()) and self.Owner:GetActiveWeapon():GetClass() == oldclass then
				self.Owner:GetViewModel():SetModel(oldmodel)
			end
		end
	end)

	self.NextThrow = CurTime() + 1.5
end

function SWEP:PrimaryAttack()
	if self.Owner:GetAmmoCount( "Grenade" ) > 0 then
		if self.Owner:IsPlayer() and self.Owner:KeyDown(IN_USE) then
			self:ThrowGrenade()
			return 
		end
	end

	if self:Clip1() == 0 then
		self.Weapon:EmitSound(Sound("sfx_gun_empty.wav"), 100, 100)
		self.Weapon:SetNextPrimaryFire(CurTime()+1)
		return
	end

	self:FireShotPrim()
	self.Weapon:EmitSound(self.Primary.Sound)
	self.Weapon:TakePrimaryAmmo(1)
	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)

	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self.Owner:MuzzleFlash()

	self.Weapon:SetNextPrimaryFire(CurTime()+1/(self.Primary.RPM/60))
	self.Weapon:SetNextSecondaryFire(CurTime()+0.1)
end

function SWEP:SecondaryAttack()
	return
end

function SWEP:FireShotPrim()
	local bullet = {}
    bullet.Num      = 1
    bullet.Src      = self.Owner:GetShootPos()        	// Source
    bullet.Dir      = self.Owner:GetAimVector()         // Dir of bullet
    bullet.Spread   = Vector( self.Primary.Spread, self.Primary.Spread, 0 )        // Aim Cone
    bullet.Tracer   = 2									// Show a tracer on every x bullets
	bullet.TracerName = self.Primary.TracerName 
    bullet.Force   	= 10                              	// Amount of force to give to phys objects
    bullet.Damage   = math.random(self.Primary.DamageMin,self.Primary.DamageMax)
    bullet.AmmoType = self.Primary.Ammo
    self.Owner:FireBullets( bullet )
end

function SWEP:Reload()
	if self.Weapon:DefaultReload(ACT_VM_RELOAD) then
		self.Owner:SetFOV( 0, 0.2 )
		self.Weapon:EmitSound(Sound("sfx_mk2_reload.wav"))
		local chance = math.random(5)

		if chance < 3 then
			self.Weapon:EmitSound(Sound("vo/npc/male01/coverwhilereload0"..math.random(1,2)..".wav"))
		end

		local oldclass = self.Owner:GetActiveWeapon():GetClass()

		if IsValid(self.Owner:GetActiveWeapon()) and self.Owner:GetActiveWeapon():GetClass() == oldclass and self.Weapon:Clip1() > 0 then

			self.Owner:SetAmmo(self.Owner:GetAmmoCount("smg1") + self.Weapon:Clip1(), "smg1")
			self.Weapon:SetClip1(0)

			if SERVER then
				self.emptycage = ents.Create( "item_droppedweapon" )

				self.emptycage:SetModel( "models/weapons/naboje/mk2_ammo.mdl" )
				self.emptycage:SetPos(self.Owner:GetShootPos() + self.Owner:GetAimVector() * 10 + Vector(0,0,-10))
				self.emptycage:SetAngles(Angle(math.random(0, 360), math.random(0, 360), math.random(0, 360)))

				self.emptycage:SetCollisionGroup(COLLISION_GROUP_WORLD)
				self.emptycage:SetSolid(SOLID_VPHYSICS)
				self.emptycage:PhysicsInit(SOLID_VPHYSICS)

				self.emptycage:SetModelScale(0.8, 0, 0)
				self.emptycage:SetColor(Color(182, 182, 182, 255))

				self.emptycage:Spawn()
				self.emptycage:Activate()
			end
		end
	end
end