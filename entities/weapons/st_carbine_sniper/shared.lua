// Variables that are used on both client and server
SWEP.Base = "st_base"

SWEP.HoldType = "ar2"

SWEP.ViewModel = "models/ryan7259/starshiptroopers/weapons/v_moritamk2_sniper.mdl"
SWEP.WorldModel = "models/ryan7259/starshiptroopers/weapons/w_moritamk2_sniper.mdl"

SWEP.Spawnable = true
SWEP.AdminOnly = true

SWEP.Primary.Sound = Sound("sfx_mk2_scatter.wav")
SWEP.Primary.RPM = 145
SWEP.Primary.Spread = 0.03
SWEP.Primary.ClipSize = 26
SWEP.Primary.DefaultClip = 86
SWEP.Primary.Ammo = "smg1"
SWEP.Primary.DamageMax = 54
SWEP.Primary.DamageMin = 20

SWEP.Secondary.ScopeZoom = 10

SWEP.ScopeScale = 0.5

function SWEP:Initialize()
	self:SetNWBool("Reloading", false)
	self:SetHoldType(self.HoldType)
end

function SWEP:Precache()
	util.PrecacheSound(self.Primary.Sound)
	util.PrecacheSound("sfx_railgun_zoom_out.wav")
	util.PrecacheSound("sfx_railgun_zoom_in.wav")
	util.PrecacheSound("sfx_mk2_reload.wav")
	util.PrecacheSound("sfx_gun_empty.wav")
end

function SWEP:Holster()
	self.Owner:SetFOV(0, 0.2)

	return true
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
			self.Owner:SetFOV(75 / self.Secondary.ScopeZoom, 0.15)
			self.Primary.Spread = 0.002
			self.Weapon:EmitSound(Sound("sfx_railgun_zoom_in.wav"))
		if CLIENT then return end
			self.Owner:DrawViewModel(false)
		end
	end
end

function SWEP:IronSight()
	if not IsValid(self) then return end

	if self.Owner:KeyPressed(IN_ATTACK2) and not self.Weapon:GetNWBool("Reloading") then
		self.Owner:SetFOV(75 / self.Secondary.ScopeZoom, 0.15)
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
