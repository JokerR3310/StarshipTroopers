// Variables that are used on both client and server
SWEP.Base				= "st_base"
SWEP.HoldType			= "shotgun"

SWEP.ViewModelFOV		= 70

SWEP.ViewModel			= "models/ryan7259/starshiptroopers/weapons/v_morita_shotgun.mdl"
SWEP.WorldModel			= "models/ryan7259/starshiptroopers/weapons/w_morita_shotgun.mdl"

SWEP.Spawnable			= true
SWEP.AdminOnly			= true

SWEP.Primary.Sound 			= Sound("sfx_shotgun_primary_fire.wav")			// Sound of the gun
SWEP.Primary.RPM			= 130					// This is in Rounds Per Minute
SWEP.Primary.ClipSize		= 20					// Size of a clip
SWEP.Primary.DefaultClip	= 20				// Default number of bullets in a clip 114
SWEP.Primary.Ammo			= "Buckshot"	
SWEP.Primary.DamageMax 		= 10
SWEP.Primary.DamageMin		= 6
SWEP.Primary.RangeMax		= 40
SWEP.Primary.RangeMin		= 600

function SWEP:FireShotPrim()
	local bullet = {}
    bullet.Num       	= 12
    bullet.Src       	= self.Owner:GetShootPos()           // Source
    bullet.Dir       	= self.Owner:GetAimVector()           // Dir of bullet
    bullet.Spread    	= Vector( 0.07, 0.07, 0 )        // Aim Cone
    bullet.Tracer  	 	= 1                                    // Show a tracer on every x bullets
    bullet.Force    	= 10                                   // Amount of force to give to phys objects
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
   Name: SWEP:Deploy()
   Desc: Whip it out.
---------------------------------------------------------*/
function SWEP:Deploy()
	self:SetHoldType(self.HoldType)
	self.Weapon:SendWeaponAnim(ACT_VM_DRAW)

	self.Weapon:SetNextPrimaryFire(CurTime() + .25)
	self.Weapon:SetNextSecondaryFire(CurTime() + .25)
	self.ActionDelay = (CurTime() + .25)

	return true
end

/*---------------------------------------------------------
   Name: SWEP:Reload()
   Desc: Reload is being pressed.
---------------------------------------------------------*/
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
			self.Owner:SetAmmo(self.Owner:GetAmmoCount("Buckshot") + self.Weapon:Clip1(), "Buckshot")
			self.Weapon:SetClip1(0)
			self.Weapon:SetNextPrimaryFire(CurTime() + 1)
			self.Weapon:SetNextSecondaryFire(CurTime() + 1)
			
			timer.Simple(1, function()
				if IsValid(self.Owner:GetActiveWeapon()) then
					local vm = self.Owner:GetViewModel()-- its a messy way to do it, but holy shit, it works!
					vm:ResetSequence(vm:LookupSequence("after_reload")) -- Fuck you, garry, why the hell can't I reset a sequence in multiplayer?
					vm:SetPlaybackRate(.01) -- or if I can, why does facepunch have to be such a shitty community, and your wiki have to be an unreadable goddamn mess?
				end
			end)
		end
	end
end