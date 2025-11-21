// Variables that are used on both client and server
SWEP.Base = "st_base"
SWEP.HoldType = "ar2"

SWEP.ViewModel = "models/ryan7259/starshiptroopers/weapons/v_railgun.mdl"
SWEP.WorldModel = "models/ryan7259/starshiptroopers/weapons/w_railgun.mdl"
SWEP.ViewModelFlip = true

SWEP.Spawnable = true
SWEP.AdminOnly = true

SWEP.Primary.Sound = Sound("sfx_railgun_fire.wav")
SWEP.Primary.RPM = 80
SWEP.Primary.ClipSize = 6
SWEP.Primary.DefaultClip = 6
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "XBowBolt"

SWEP.Secondary.ScopeZoom = 10

SWEP.ScopeScale = 0.5

function SWEP:Initialize()
	self.Weapon:SetNWBool("Reloading", false)
	self:SetHoldType(self.HoldType)
end

function SWEP:Precache()
	util.PrecacheSound(self.Primary.Sound)
	util.PrecacheSound("sfx_railgun_zoom_out.wav")
	util.PrecacheSound("sfx_railgun_zoom_in.wav")
	util.PrecacheSound("sfx_railgun_reload.wav")
	util.PrecacheSound("sfx_railgun_empty.wav")
end

function SWEP:Holster()
	self.Owner:SetFOV(0, 0.2)
		return true
end

function SWEP:PrimaryAttack()
	local user = self:GetOwner()

	if user:IsPlayer() and user:GetAmmoCount( "Grenade" ) > 0 and user:KeyDown(IN_USE) then
		self:ThrowGrenade()

		return
	end

	if self:CanPrimaryAttack() then
		self:ExplodeShot()
		self.Weapon:EmitSound(self.Primary.Sound)
		self.Weapon:TakePrimaryAmmo(1)
		self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)

		self.Owner:SetAnimation(PLAYER_ATTACK1)
		self.Owner:MuzzleFlash()
		self.Owner:ViewPunch(Angle(-3, 1, 0))
		
		self.Weapon:SetNextPrimaryFire(CurTime() + 1 / (self.Primary.RPM / 60))
	else
		self.Weapon:EmitSound(Sound("sfx_railgun_empty.wav"))
	end
end

function SWEP:ExplodeShot()
	if (CLIENT) then return end
	
	local ExplodeShot = ents.Create("env_explosion")
	local eyetrace = self.Owner:GetEyeTrace()

	ExplodeShot:SetOwner(self.Owner)
	ExplodeShot:SetPos(eyetrace.HitPos)
	ExplodeShot:SetKeyValue("iMagnitude", "90")
	ExplodeShot:Fire("Explode", 0, 0)
	ExplodeShot:Spawn()
end

function SWEP:Reload()
	if self.Owner:KeyDown(IN_USE) then return end
	
	self.Weapon:DefaultReload(ACT_VM_RELOAD) 

	if (self.Weapon:Clip1() < self.Primary.ClipSize) then
		self.Owner:SetFOV(0, 0.2)
		self.Weapon:SetNWBool("Reloading", true)
	if CLIENT then return end
		self.Owner:DrawViewModel(true)
	end

	local waitdammit
	if self.Owner:GetViewModel() == nil then 
		waitdammit = 3
	else
		waitdammit = (self.Owner:GetViewModel():SequenceDuration())
	end
	
	timer.Simple(waitdammit + .1, function()
		if self.Weapon != nil then 
			self.Weapon:SetNWBool("Reloading", false)
			self:PostReloadScopeCheck()
		end 
	end)
end

function SWEP:PostReloadScopeCheck()
	if self.Weapon != nil then 
		self.Weapon:SetNWBool("Reloading", false)
		if self.Owner:KeyDown(IN_ATTACK2) and not self.Weapon:GetNWBool("Reloading") then
			self.Owner:SetFOV(75/self.Secondary.ScopeZoom, 0.15)
			self.Primary.Spread = 0.002
			self.Weapon:EmitSound(Sound("sfx_railgun_zoom_in.wav"))
		if CLIENT then return end
			self.Owner:DrawViewModel(false)
		end
	end
end

function SWEP:Think()
	self:IronSight()
end

function SWEP:IronSight()
	if not IsValid(self) then return end
	
	if self.Owner:KeyPressed(IN_ATTACK2) and not self.Weapon:GetNWBool("Reloading") then
		self.Owner:SetFOV(75/self.Secondary.ScopeZoom, 0.15)
			self.Primary.Spread = 0.002
			self.Weapon:EmitSound(Sound("sfx_railgun_zoom_in.wav"))
	if CLIENT then return end
		self.Owner:DrawViewModel(false)
	end

	if self.Owner:KeyReleased(IN_ATTACK2) then
		self.Owner:SetFOV(0, 0.2)
			self.Primary.Spread = 0.03
			self.Weapon:EmitSound(Sound("sfx_railgun_zoom_out.wav"))
	if CLIENT then return end
		self.Owner:DrawViewModel(true)
	end
end
