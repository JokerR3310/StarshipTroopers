// Variables that are used on both client and server
SWEP.Base				= "st_base"
SWEP.HoldType			= "shotgun"

SWEP.ViewModelFOV		= 70

SWEP.ViewModel			= "models/ryan7259/starshiptroopers/weapons/v_morita_shotgun.mdl"
SWEP.WorldModel			= "models/ryan7259/starshiptroopers/weapons/w_morita_shotgun.mdl"

SWEP.Spawnable			= true
SWEP.AdminOnly			= true

SWEP.Primary.Sound 			= Sound("sfx_shotgun_primary_fire.wav")			// Sound of the gun
SWEP.Primary.RPM			= 120					// This is in Rounds Per Minute
SWEP.Primary.ClipSize		= 20					// Size of a clip
SWEP.Primary.DefaultClip	= 114				// Default number of bullets in a clip 114
SWEP.Primary.Ammo			= "Buckshot"	
SWEP.Primary.DamageMax 		= 20
SWEP.Primary.DamageMin		= 2
SWEP.Primary.RangeMax		= 40
SWEP.Primary.RangeMin		= 600

SWEP.ShotgunReloading		= false
SWEP.ShotgunFinish			= 0.5
SWEP.ShellTime				= 0.35
SWEP.InsertingShell			= false

SWEP.NextReload				= 0

function SWEP:PrimaryAttack()
	self.Reloading = false
	
	if self:Clip1() == 0 then
		self.Weapon:EmitSound(Sound("sfx_gun_empty.wav"))
		self.Weapon:SetNextPrimaryFire(CurTime()+1)
		return
	end

	self:FireRocketPrim()
	self.Weapon:EmitSound(self.Primary.Sound)
	self.Weapon:TakePrimaryAmmo(1)
	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
		
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	self.Owner:MuzzleFlash()
		
	self.Weapon:SetNextPrimaryFire(CurTime()+1/(self.Primary.RPM/60))
	self.Weapon:SetNextSecondaryFire(CurTime()+1)
end

function SWEP:FireRocketPrim()
	local bullet = {}
    bullet.Num       	= 6
    bullet.Src       	= self.Owner:GetShootPos()           // Source
    bullet.Dir       	= self.Owner:GetAimVector()           // Dir of bullet
    bullet.Spread    	= Vector( 0.1, 0.1, 0.1 )        // Aim Cone
    bullet.Tracer  	 	= 1                                    // Show a tracer on every x bullets
    bullet.Force    	= 1                                   // Amount of force to give to phys objects
    bullet.Damage   	= 0
    bullet.AmmoType 	= self.Primary.Ammo
	bullet.Callback	= function( attack, trace, dmginfo )
		local dist = math.Distance( bullet.Src.x, bullet.Src.y, trace.HitPos.x, trace.HitPos.y )
		local dmg = math.Round( math.Clamp((( self.Primary.DamageMax - self.Primary.DamageMin ) / ( self.Primary.RangeMax - self.Primary.RangeMin ) * ( dist - self.Primary.RangeMin )) + self.Primary.DamageMin, self.Primary.DamageMin, self.Primary.DamageMax ))
			dmginfo:SetDamage( dmg )
	end
    self.Owner:FireBullets( bullet )
end

/*---------------------------------------------------------
   Name: SWEP:Think()
   Desc: Called every frame.
---------------------------------------------------------*/
function SWEP:Think()
	if self.Owner.NextReload == nil then self.Owner.NextReload = CurTime() + 1 end
	local timerName = "ShotgunReload_" ..  self.Owner:UniqueID()
	--if the owner presses shoot while the timer is in effect, then...
	if (self.Owner:KeyPressed(IN_ATTACK)) and (self.Weapon:GetNextPrimaryFire() <= CurTime()) and (timer.Exists(timerName)) and not (self.Owner:KeyDown(IN_SPEED)) then
		if self:CanPrimaryAttack() then --well first, if we actually can attack, then...
		
			timer.Remove(timerName) -- kill the timer, and
			self:PrimaryAttack()-- ATTAAAAACK!
			
		end
	end
	
	if self.InsertingShell == true and self.Owner:Alive() then
		local vm = self.Owner:GetViewModel()-- its a messy way to do it, but holy shit, it works!
		vm:ResetSequence(vm:LookupSequence("after_reload")) -- Fuck you, garry, why the hell can't I reset a sequence in multiplayer?
		vm:SetPlaybackRate(.01) -- or if I can, why does facepunch have to be such a shitty community, and your wiki have to be an unreadable goddamn mess?
		self.InsertingShell = false -- You get paid for this, what's your excuse?
	end
end

/*---------------------------------------------------------
   Name: SWEP:Deploy()
   Desc: Whip it out.
---------------------------------------------------------*/
function SWEP:Deploy()
	self:SetHoldType(self.HoldType)
	
	local timerName = "ShotgunReload_" ..  self.Owner:UniqueID()
	if (timer.Exists(timerName)) then
		timer.Remove(timerName)
	end

	self.Weapon:SendWeaponAnim(ACT_VM_DRAW)

	self.Weapon:SetNextPrimaryFire(CurTime() + .25)
	self.Weapon:SetNextSecondaryFire(CurTime() + .25)
	self.ActionDelay = (CurTime() + .25)
	
	self.Owner.NextReload = CurTime() + 1

	return true
end

/*---------------------------------------------------------
   Name: SWEP:Reload()
   Desc: Reload is being pressed.
---------------------------------------------------------*/
function SWEP:Reload()
	local maxcap = self.Primary.ClipSize
	local spaceavail = self.Weapon:Clip1()
	local shellz = (maxcap) - (spaceavail) + 1

	if (timer.Exists("ShotgunReload_" ..  self.Owner:UniqueID())) or self.Owner.NextReload > CurTime() or maxcap == spaceavail then return end
	
	if self.Owner:IsPlayer() then 

		if self.Weapon:GetNextPrimaryFire() <= (CurTime()+2) then
			self.Weapon:SetNextPrimaryFire(CurTime() + 2) -- wait TWO seconds before you can shoot again
		end

		self.Owner.NextReload = CurTime() + 1

		if SERVER and self.Owner:Alive() then
			local timerName = "ShotgunReload_" ..  self.Owner:UniqueID()
			timer.Create(timerName, 
			(self.ShellTime + .05), 
			shellz,
			function() if not IsValid(self) then return end 
			if IsValid(self.Owner) and IsValid(self.Weapon) then 
				if self.Owner:Alive() then 
					self:InsertShell()
				end 
			end end)
		end
	end
end

SWEP.NextAnimPlay = 0
function SWEP:InsertShell()

	if not IsValid(self) then return end
	
	local timerName = "ShotgunReload_" ..  self.Owner:UniqueID()
	if self.Owner:Alive() then
		local curwep = self.Owner:GetActiveWeapon()
		if curwep:GetClass() != "st_morita_shotgun" then 
			timer.Remove(timerName)
		return end
	
		if (self.Weapon:Clip1() >= self.Primary.ClipSize or self.Owner:GetAmmoCount(self.Primary.Ammo) <= 0) then
		-- if clip is full or ammo is out, then...
			self.Weapon:SendWeaponAnim(ACT_SHOTGUN_RELOAD_FINISH) -- send the pump anim
			timer.Remove(timerName) -- kill the timer
		elseif (self.Weapon:Clip1() <= self.Primary.ClipSize and self.Owner:GetAmmoCount(self.Primary.Ammo) >= 0) then
			self.InsertingShell = true --well, I tried!
			timer.Simple( .05, function() self:ShellAnimCaller() end)
			self.Owner:RemoveAmmo(1, self.Primary.Ammo, false) -- out of the frying pan
			self.Weapon:SetClip1(self.Weapon:Clip1() + 1) --  into the fire
			self.Weapon:EmitSound("weapons/insert.wav")
			self.Owner:ViewPunch(Angle(0.5, -0.5, 0.5))
			self.Weapon:SendWeaponAnim(ACT_SHOTGUN_RELOAD_START) -- sending start reload anim
		end
	else
		timer.Remove(timerName) -- kill the timer
	end
	
	if CurTime() < self.NextAnimPlay or self.Owner:GetAmmoCount(self.Primary.Ammo) <= 0 then return end
		self.Owner:SetAnimation( PLAYER_RELOAD )
	self.NextAnimPlay = CurTime() + 1.2
end

function SWEP:ShellAnimCaller()
	self.Weapon:SendWeaponAnim(ACT_VM_RELOAD)
end