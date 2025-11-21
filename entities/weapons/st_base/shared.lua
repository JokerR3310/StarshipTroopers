SWEP.Base = "weapon_base"
SWEP.HoldType = "ar2"

SWEP.ViewModelFOV = 65
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/ryan7259/starshiptroopers/weapons/v_moritamk2_pumpshotty.mdl"
SWEP.WorldModel	= "models/ryan7259/starshiptroopers/weapons/w_moritamk2_pumpshotty.mdl"

SWEP.Spawnable = false
SWEP.AdminOnly = false

SWEP.Primary.Sound 			= Sound("sfx_mk4_fire.wav")
SWEP.Primary.RPM			= 690
SWEP.Primary.ClipSize		= 0
SWEP.Primary.DefaultClip	= 0
SWEP.Primary.Automatic		= true
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
	self:SetHoldType(self.HoldType)
end

function SWEP:GetNPCRestTimes()
	-- Handles the time between bursts
	-- Min rest time in seconds, max rest time in seconds

	return 0.33, 1
end

function SWEP:GetNPCBurstSettings()
	-- Handles the burst settings
	-- Minimum amount of shots, maximum amount of shots, and the delay between each shot
	-- The amount of shots can end up lower than specificed

	return 1, 15, 0.05
end

function SWEP:GetNPCBulletSpread( proficiency )
	-- Handles the bullet spread based on the given proficiency
	-- return value is in degrees

	return 0.25
end

function SWEP:Deploy()
	self:SendWeaponAnim(ACT_VM_DRAW)
	self:SetHoldType(self.HoldType)

	return true
end

function SWEP:Think()
	self:IronSight()
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

	local user = self:GetOwner()
	local oldclass = user:GetActiveWeapon():GetClass()
	local oldmodel = user:GetViewModel():GetModel()

	user:GetViewModel():SetModel("models/weapons/v_grenade.mdl")

	self:SetNextPrimaryFire(CurTime() + 1)
	self:SetNextSecondaryFire(CurTime() + 1)

	self:EmitSound("npc/vort/claw_swing" .. math.random(1, 2) .. ".wav")
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )

	user:SetAmmo(user:GetAmmoCount( "Grenade" ) - 1, "Grenade")

	if SERVER then
		local nade = ents.Create( "st_nade" )
		nade:SetPos(user:GetShootPos() + user:GetAimVector() / 50)
		nade:SetOwner(user)

		nade:Spawn()
		nade:Activate()
		nade:GetPhysicsObject():SetVelocity(user:GetAimVector() * 1000)
	end

	user:ViewPunch(Angle( -14, 2, 0 ))

	timer.Simple(0.4, function()
		if IsValid(self) and IsValid(user:GetActiveWeapon()) and user:GetActiveWeapon():GetClass() == oldclass then
			user:GetViewModel():SetModel(oldmodel)
		end
	end)

	self.NextThrow = CurTime() + 1.5
end

function SWEP:PrimaryAttack()
	local user = self:GetOwner()

	if user:IsPlayer() and user:GetAmmoCount( "Grenade" ) > 0 and user:KeyDown(IN_USE) then
		self:ThrowGrenade()

		return
	end

	if self:Clip1() == 0 then
		self:EmitSound(Sound("sfx_gun_empty.wav"), 100, 100)
		self:SetNextPrimaryFire(CurTime() + 1)

		return
	end

	self:FireShotPrim()

	self:EmitSound(self.Primary.Sound, 120)
	self:TakePrimaryAmmo(1)
	user:SetAnimation(PLAYER_ATTACK1)

	user:MuzzleFlash()

	if user:IsPlayer() then
		self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)

		user:ViewPunch(Angle(math.Rand(-1, 1), math.Rand(-1, 1), 0))
	end

	self:SetNextPrimaryFire(CurTime() + 1 / (self.Primary.RPM / 60))
	self:SetNextSecondaryFire(CurTime() + 0.1)
end

function SWEP:SecondaryAttack()
	return
end

function SWEP:FireShotPrim()
	local user = self:GetOwner()

	local bullet = {}
	bullet.Num = 1
	bullet.Src = user:GetShootPos()
	bullet.Dir = user:GetAimVector()
	bullet.Tracer = 2
	bullet.TracerName = self.Primary.TracerName
	bullet.Force = 10
	bullet.Damage = math.random(self.Primary.DamageMin, self.Primary.DamageMax)
	bullet.AmmoType = self.Primary.Ammo

	if user:IsNPC() then
		local npcSpread = self:GetNPCBulletSpread()
		bullet.Spread = Vector(npcSpread, npcSpread, 0)
	else
		bullet.Spread = Vector(self.Primary.Spread, self.Primary.Spread, 0)
	end

	user:FireBullets( bullet )
end

local female_snd = {
	"vo/npc/female01/coverwhilereload01.wav",
	"vo/npc/female01/coverwhilereload02.wav",
	"vo/npc/female01/gottareload01.wav",
	"vo/npc/female01/gottareload01.wav",
	"vo/npc/female01/gottareload01.wav",
	"vo/npc/female01/gottareload01.wav"
}

local male_snd = {
	"vo/npc/male01/coverwhilereload01.wav",
	"vo/npc/male01/coverwhilereload02.wav",
	"vo/npc/male01/gottareload01.wav",
	"vo/npc/male01/gottareload01.wav",
	"vo/npc/male01/gottareload01.wav",
	"vo/npc/male01/gottareload01.wav"
}

function SWEP:Reload()
	local user = self:GetOwner()

	if self:DefaultReload(ACT_VM_RELOAD) then
		user:SetFOV( 0, 0.2 )
		self:EmitSound(Sound("sfx_mk2_reload.wav"))

		if SERVER and math.random(10) > 2 and not user:GetNetVar("Taunt", false) then
			local getgender = string.find(string.lower(user:GetModel()), "mobileinfantry/fmi")

			if getgender then
				user:EmitSound(Sound(female_snd[math.random(#female_snd)]))
			else
				user:EmitSound(Sound(male_snd[math.random(#male_snd)]))
			end

			user:SetNetVar("Taunt", true)
		end

		local oldclass = user:GetActiveWeapon():GetClass()

		if IsValid(user:GetActiveWeapon()) and user:GetActiveWeapon():GetClass() == oldclass and self:Clip1() > 0 then

			user:SetAmmo(user:GetAmmoCount("smg1") + self:Clip1(), "smg1")
			self:SetClip1(0)

			if SERVER then
				self.emptycage = ents.Create( "item_droppedweapon" )

				self.emptycage:SetModel( "models/weapons/naboje/mk2_ammo.mdl" )
				self.emptycage:SetPos(user:GetShootPos() + user:GetAimVector() * 10 + Vector(0, 0, -10))
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

function SWEP:IronSight()
end