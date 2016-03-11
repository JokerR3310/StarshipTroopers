include("shared.lua")

ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:Initialize()
	self.Model = ClientsideModel("models/hunter/blocks/cube025x025x025.mdl")
	self.Model:SetNoDraw(true)
	self.Model:DrawShadow(false)
	self.Model:SetModelScale(0.9, 0, 0)
end

function ENT:DrawTranslucent()
	if not IsValid(self.Player) then
		self.Player = self:GetOwner().Owner
	end

	if IsValid(self.Player) then
		local pos, ang = self:CalcPos(self.Player)
		self.Model:SetRenderOrigin(pos)
		self.Model:SetRenderAngles(Angle(0, ang.y + self.dt.Rotation, 0))
		self.Model:DrawModel()
	end
end

function ENT:Think()
	if not IsValid(self.Player) then
		self.Player = self:GetOwner().Owner
	end

	if self.dt.Type == 1 then
		self.Model:SetModel("models/buildables/sentry1_blueprint.mdl")
	else
		self.Model:SetModel("models/buildables/dispenser_blueprint.mdl")
	end

	if self.dt.Allowed then
		self.Model:ResetSequence(self.Model:SelectWeightedSequence(ACT_OBJ_PLACING))
		--if self.Player == LocalPlayer() then
			--self.Model:SetBodygroup(1, 1)
		--else
			--self.Model:SetBodygroup(1, 0)
		--end
	else
		self.Model:ResetSequence(self.Model:SelectWeightedSequence(ACT_OBJ_IDLE))
		self.Model:SetBodygroup(1, 0)
	end
end

function ENT:OnRemove()
	if IsValid(self.Model) then
		self.Model:Remove()
	end
end