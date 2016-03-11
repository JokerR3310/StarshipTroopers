include('shared.lua')

SWEP.PrintName			= "Binoculars"
SWEP.Slot				= 5
SWEP.SlotPos			= 1
SWEP.Category			= "SST Weapons 2"

SWEP.DrawAmmo			= false
SWEP.WepSelectIcon		= surface.GetTextureID("weapons/st_binoculars")

function SWEP:DrawHUD() end

function SWEP:FreezeMovement()
	-- Don't aim if we're holding the right mouse button
	if ( self.Owner:KeyDown( IN_ATTACK2 ) || self.Owner:KeyReleased( IN_ATTACK2 ) ) then
		return true
	end

	return false
end

function SWEP:AdjustMouseSensitivity()
	if ( self.Owner:KeyDown( IN_ATTACK2 ) ) then return 1 end
	
	return self:GetZoom() / 80
end

SWEP.Offset = {
    Pos = {
        Right = -3.5,
        Forward = 5,
    },
    Ang = {
        Right = -20,
        Forward = 10,
    },
}

function SWEP:DrawWorldModel( )
    if not IsValid( self.Owner ) then
        return self:DrawModel( )
    end
    
    local offset, hand
    
    self.Hand2 = self.Hand2 or self.Owner:LookupAttachment( "anim_attachment_rh" )
    
    hand = self.Owner:GetAttachment( self.Hand2 )
    
    if not hand then return end
    
    offset = hand.Ang:Right( ) * self.Offset.Pos.Right + hand.Ang:Forward( ) * self.Offset.Pos.Forward + hand.Ang:Up( ) * self.Offset.Pos.Up
    
    hand.Ang:RotateAroundAxis( hand.Ang:Right( ), self.Offset.Ang.Right )
    hand.Ang:RotateAroundAxis( hand.Ang:Forward( ), self.Offset.Ang.Forward )
    
    self:SetRenderOrigin( hand.Pos + offset )
    self:SetRenderAngles( hand.Ang )
    
    self:SetModelScale( 1.1, 0 )
    
    self:DrawModel( )
end