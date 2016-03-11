ENT.Base = "base_ai"
ENT.Type = "ai"

ENT.PrintName 	= "Bug Base"
ENT.Author 		= "Predator cz"

ENT.Spawnable 	= false
ENT.AdminOnly 	= false

ENT.Category 	= "Starship Troopers"

ENT.AutomaticFrameAdvance = true

function ENT:PhysicsCollide( data, physobj )
end

function ENT:PhysicsUpdate( physobj )
end

function ENT:SetAutomaticFrameAdvance( bUsingAnim )
	self.AutomaticFrameAdvance = bUsingAnim
end 