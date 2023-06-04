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

local WorldModel = ClientsideModel(SWEP.WorldModel)

-- Settings...
WorldModel:SetNoDraw(true)

function SWEP:DrawWorldModel()
	local _Owner = self:GetOwner()

	if (IsValid(_Owner)) then
           -- Specify a good position
		local offsetVec = Vector(6, -5.7, -1)
		local offsetAng = Angle(-20, -3, 190)
			
		local boneid = _Owner:LookupBone("ValveBiped.Bip01_R_Hand") -- Right Hand
		if !boneid then return end

		local matrix = _Owner:GetBoneMatrix(boneid)
		if !matrix then return end

		local newPos, newAng = LocalToWorld(offsetVec, offsetAng, matrix:GetTranslation(), matrix:GetAngles())

		WorldModel:SetPos(newPos)
		WorldModel:SetAngles(newAng)

		WorldModel:SetupBones()
	else
		WorldModel:SetPos(self:GetPos())
		WorldModel:SetAngles(self:GetAngles())
	end

	WorldModel:DrawModel()
end