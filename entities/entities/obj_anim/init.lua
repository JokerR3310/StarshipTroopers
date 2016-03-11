AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

function ENT:Initialize()
	local owner = self:GetOwner()
	if not IsValid(owner) then
		self:Remove()
		return
	end
	
	self:SetModelScale(0.9, 0, 0)
	
	self:SetBuilder(owner.Player)
	self:SetModel(owner:GetModel())
	self:SetPos(owner:GetPos())
	self:SetAngles(owner:GetAngles())
	self:SetParent(owner)
end