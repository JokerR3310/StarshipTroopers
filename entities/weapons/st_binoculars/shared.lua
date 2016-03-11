// Variables that are used on both client and server
SWEP.Base			= "st_base"
SWEP.HoldType		= "camera"

SWEP.ViewModel		= "models/weapons/v_binoculars.mdl"
SWEP.WorldModel		= "models/weapons/w_binoculars.mdl"

SWEP.Spawnable		= true
SWEP.AdminOnly		= true

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

--
-- Network`/Data Tables
--
function SWEP:SetupDataTables()
	self:NetworkVar( "Float", 0, "Zoom" )

	if ( SERVER ) then
		self:SetZoom( 70 )
	end
end

--
-- Reload resets the FOV and Roll
--
function SWEP:Reload()
	if ( !self.Owner:KeyDown( IN_ATTACK2 ) ) then self:SetZoom( self.Owner:IsBot() && 75 || self.Owner:GetInfoNum( "fov_desired", 75 ) ) end
end

--
-- PrimaryAttack - make a screenshot
--
function SWEP:PrimaryAttack()
	return
end

--
-- Mouse 2 action
--
function SWEP:Tick()

	if ( CLIENT && self.Owner != LocalPlayer() ) then return end -- If someone is spectating a player holding this weapon, bail

	local cmd = self.Owner:GetCurrentCommand()

	if ( !cmd:KeyDown( IN_ATTACK2 ) ) then return end -- Not holding Mouse 2, bail

	self:SetZoom( math.Clamp( self:GetZoom() + cmd:GetMouseY() * 0.1, 4, 90 ) ) -- Handles zooming
	
	if self:GetZoom() < 88 and self:GetZoom() > 4 then
		self.Owner:EmitSound( "binoculars/binoculars_zoomin.wav" )
	end
end

function SWEP:Think()
	if self:GetZoom() > 88 then
		self.Owner:DrawViewModel(true)
	else
		self.Owner:DrawViewModel(false)
	end
end
--
-- Override players Field Of View
--
function SWEP:TranslateFOV( current_fov )
	return self:GetZoom()
end

--
-- Deploy - Allow lastinv
--
function SWEP:Deploy()
	self:Reload() return true
end

--
-- Set FOV to players desired FOV
--
function SWEP:Equip()
	if ( self:GetZoom() == 70 && self.Owner:IsPlayer() && !self.Owner:IsBot() ) then
		self:SetZoom( self.Owner:GetInfoNum( "fov_desired", 75 ) )
	end
end