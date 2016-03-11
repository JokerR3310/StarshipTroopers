ENT.Base = "base_entity"
ENT.Type = "anim"  

function ENT:SetupDataTables()
	self:DTVar("Entity", 0, "Builder")
end

function ENT:GetBuilder()
	return self.dt.Builder
end

function ENT:SetBuilder(pl)
	self.dt.Builder = pl
end