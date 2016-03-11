ENT.Base = "base_entity"
ENT.Type = "ai"  

ENT.AutomaticFrameAdvance = true

ENT.Building = true
ENT.NumLevels = 3
ENT.ObjectHealth = 100
ENT.UpgradeCost = 200

ENT.CollisionBox = {Vector(-22,-22,0), Vector(22,22,75)}

function ENT:SetupDataTables()
	self:DTVar("Int", 0, "BuildingInfo")
	--[[
	0x0TTTLLSS
	T: Building sub-type
	L: Building level
	S: Building status
	]]
	
	self:DTVar("Int", 1, "BuildingInfo2")
	--[[
	0x0MMMUUUU
	M: Building mode
	U: Building upgrade status
	]]
	
	self:DTVar("Vector", 3, "BuildingInfoFloat")
end

function ENT:SetAutomaticFrameAdvance(bUsingAnim)
	self.AutomaticFrameAdvance = bUsingAnim
end

-- The obj_anim entity attached to this building can act as a second datatable just in case we run out of datatable slots
function ENT:CallFromModelEntity(func, default, ...)
	if not self.Model and CLIENT then
		for _,v in pairs(ents.FindByClass("obj_anim")) do
			if v:GetOwner() == self then
				self.Model = v
			end
		end
	end
	
	if IsValid(self.Model) and self.Model[func] then
		return self.Model[func](self.Model, ...)
	else
		return default
	end
end

-----------------------------------------------------------

function ENT:GetBuilder()
	return self:CallFromModelEntity("GetBuilder", NULL)
end

function ENT:SetBuilder(b)
	self:CallFromModelEntity("SetBuilder", nil, b)
end

-----------------------------------------------------------

function ENT:GetState()
	return bit.band(self.dt.BuildingInfo, 0x000000ff)
end

function ENT:SetState(s)
	self.dt.BuildingInfo = bit.bor(bit.band(self.dt.BuildingInfo, 0x7fffff00), bit.band(s, 0xff))
end

-----------------------------------------------------------

function ENT:GetLevel()
	return bit.rshift(bit.band(self.dt.BuildingInfo, 0x0000ff00), 8)
end

function ENT:SetLevel(l)
	self.dt.BuildingInfo = bit.bor(bit.band(self.dt.BuildingInfo, 0x7fff00ff), bit.lshift(bit.band(l, 0xff), 8))
end

function ENT:LevelUp()
	return self:SetLevel(self:GetLevel()+1)
end

-----------------------------------------------------------

function ENT:GetMetal()
	return bit.band(self.dt.BuildingInfo2, 0x0000ffff)
end

function ENT:SetMetal(m)
	self.dt.BuildingInfo2 = bit.bor(bit.band(self.dt.BuildingInfo2, 0x7fff0000), bit.band(m, 0xffff))
end

-----------------------------------------------------------

function ENT:GetBuildProgress()
	return self.dt.BuildingInfoFloat.x
end

function ENT:SetBuildProgress(f)
	local v = self.dt.BuildingInfoFloat
	v.x = f
	self.dt.BuildingInfoFloat = v
end