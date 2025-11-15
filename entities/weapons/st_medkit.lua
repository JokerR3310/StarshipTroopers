AddCSLuaFile()

SWEP.PrintName		= "Medkit"
SWEP.Author			= "robotboy655 & MaxOfS2D"
SWEP.Purpose    	= "Heal people with your primary attack, or yourself with the secondary."

SWEP.Spawnable			= true
SWEP.UseHands			= false

SWEP.ViewModel			= "models/Items/HealthKit.mdl"
SWEP.WorldModel			= "models/weapons/w_medkit.mdl"

SWEP.ViewModelFOV		= 54
SWEP.Slot				= 5
SWEP.SlotPos			= 3

SWEP.Primary.ClipSize		= 100
SWEP.Primary.DefaultClip	= 100
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"
SWEP.Primary.RPM			= 120

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.HealAmount = 20 -- Maximum heal amount per use
SWEP.MaxAmmo = 100 -- Maxumum ammo

if ( CLIENT ) then
	SWEP.WepSelectIcon = surface.GetTextureID("weapons/st_medkit")
end

local HealSound = Sound( "items/smallmedkit1.wav" )
local DenySound = Sound( "items/medshotno1.wav" )

function SWEP:Initialize()

	self:SetHoldType( "slam" )

	if ( CLIENT ) then return end

	timer.Create( "medkit_ammo" .. self:EntIndex(), 1, 0, function()
		if ( self:Clip1() < self.MaxAmmo ) then self:SetClip1( math.min( self:Clip1() + 2, self.MaxAmmo ) ) end
	end )

end

function SWEP:PrimaryAttack()

	if CLIENT then return end
	
	local user = self:GetOwner()

	user:LagCompensation( true )

	local tr = util.TraceLine({
		start = user:GetShootPos(),
		endpos = user:GetShootPos() + user:GetAimVector() * 64,
		filter = user
	})

	local ent = tr.Entity

	user:LagCompensation( false )

	local need = self.HealAmount

	if IsValid( ent ) and (ent:IsPlayer() or ent:IsNPC()) then 
		need = math.min( ent:GetMaxHealth() - ent:Health(), self.HealAmount ) 
	end

	if ( IsValid( ent ) && self:Clip1() >= need && ( ent:IsPlayer() || ent:IsNPC() ) && ent:Health() < ent:GetMaxHealth() and ent:GetClass() == "npc_citizen" ) then

		self:TakePrimaryAmmo( need )

		ent:SetHealth( math.min( ent:GetMaxHealth(), ent:Health() + need ) )
		user:EmitSound( "vo/npc/male01/health0" .. math.random(1, 5) .. ".wav" )
		ent:EmitSound( HealSound )

		self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )

		self:SetNextPrimaryFire( CurTime() + self:SequenceDuration() + 1 )
		user:SetAnimation( PLAYER_ATTACK1 )

		-- Even though the viewmodel has looping IDLE anim at all times, we need this to make fire animation work in multiplayer
		timer.Create( "weapon_idle" .. self:EntIndex(), self:SequenceDuration(), 1, function() if ( IsValid( self ) ) then self:SendWeaponAnim( ACT_VM_IDLE ) end end )

	else

		user:EmitSound( DenySound )
		self:SetNextPrimaryFire( CurTime() + 1 )

	end

end

function SWEP:SecondaryAttack()

	if CLIENT then return end

	local user = self:GetOwner()
	local need = self.HealAmount

	if IsValid( user ) then 
		need = math.min( user:GetMaxHealth() - user:Health(), self.HealAmount )
	end

	if ( IsValid( user ) && self:Clip1() >= need && user:Health() < user:GetMaxHealth() ) then

		self:TakePrimaryAmmo( need )

		user:SetHealth( math.min( user:GetMaxHealth(), user:Health() + need ) )
		user:EmitSound( HealSound )

		self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )

		self:SetNextSecondaryFire( CurTime() + self:SequenceDuration() + 0.5 )
		self.Owner:SetAnimation( PLAYER_ATTACK1 )

		timer.Create( "weapon_idle" .. self:EntIndex(), self:SequenceDuration(), 1, function() if ( IsValid( self ) ) then self:SendWeaponAnim( ACT_VM_IDLE ) end end )

	else

		user:EmitSound( DenySound )
		self:SetNextSecondaryFire( CurTime() + 1 )

	end

end

function SWEP:OnRemove()

	timer.Stop( "medkit_ammo" .. self:EntIndex() )
	timer.Stop( "weapon_idle" .. self:EntIndex() )

end

function SWEP:Holster()

	timer.Stop( "weapon_idle" .. self:EntIndex() )
	
	return true

end

function SWEP:CustomAmmoDisplay()

	self.AmmoDisplay = self.AmmoDisplay or {} 
	self.AmmoDisplay.Draw = true
	self.AmmoDisplay.PrimaryClip = self:Clip1()

	return self.AmmoDisplay

end

function SWEP:GetViewModelPosition( pos , ang)
	pos,ang = LocalToWorld(Vector(38,-12,-10),Angle(60,-190,20),pos,ang)
	
	return pos, ang
end