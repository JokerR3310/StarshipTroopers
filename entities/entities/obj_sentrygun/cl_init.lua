include("shared.lua")

function ENT:Draw()
	if self:GetState() < 2 then return end
	
	self:DrawModel()
end