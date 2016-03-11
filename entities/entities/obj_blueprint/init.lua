AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

function ENT:Initialize()
	local owner = self:GetOwner()
	if not IsValid(owner) then
		self:Remove() return
	end
	
	self.Player = self:GetOwner().Owner
	if not IsValid(self.Player) then
		self:Remove() return
	end
	
	owner:DeleteOnRemove(self)
	self:SetNotSolid(true)
	self:DrawShadow(false)
end

function ENT:Think()
	if(self.NegAngle != self.AddAngle or self.dt.Rotation != self.NegAngle) then
		self.NegAngle = Lerp(FrameTime() * 6, self.NegAngle, self.AddAngle)
		self.dt.Rotation = self.NegAngle
	end
	
	local pos, ang, valid = self:CalcPos(self.Player)
	self:SetPos(pos)
	
	self:SetAngles(Angle(0, ang.y + self.dt.Rotation, 0))
	
	if valid ~= self.dt.Allowed then
		self.dt.Allowed = valid
	end
	
	self:NextThink(CurTime())
	return true
end