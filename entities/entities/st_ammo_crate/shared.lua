ENT.Type = "anim"

ENT.PrintName = "Ammo Crate"
ENT.Author = "-=JokerR |CMBG|=-"

ENT.AutomaticFrameAdvance = true 

function ENT:SetAutomaticFrameAdvance(bUsingAnim)
	self.AutomaticFrameAdvance = bUsingAnim
end