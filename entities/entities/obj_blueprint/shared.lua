ENT.Base = "base_entity"
ENT.Type = "anim"  

ENT.AutomaticFrameAdvance = true

ENT.BuildHull = {Vector(-28,-28,0), Vector(28,28,94)}
ENT.BuildDistance = 70 -- Дистанция: Игрок - Постройка
ENT.BuildYOffset = 30
ENT.BuildYRange = 55 -- Высота: Игрок - Нижняя точка
ENT.HeightTolerancy = 10

ENT.BuildYOffsetStand = 10
ENT.BuildYOffsetDuck = -4

ENT.AddAngle = 0
ENT.NegAngle = 0

function ENT:SetupDataTables()
	self:DTVar("Bool", 0, "Allowed")
	self:DTVar("Int", 0, "Rotation")
	self:DTVar("Float", 0, "Type")
	
	if SERVER then
		self.dt.Allowed = true
	end
end

function ENT:RotateBlueprint()
	self.AddAngle = self.AddAngle + 90
end

function ENT:CalcPos(pl)
	local ang = pl:EyeAngles()
	ang.p = 0
	local dir = ang:Forward()
	
	local origin
	
	if pl:Crouching() then
		origin = pl:GetPos() + self.BuildYOffsetDuck * vector_up
	else
		origin = pl:GetPos() + self.BuildYOffsetStand * vector_up
	end
	
	local pos = origin + self.BuildDistance * dir
	local tr = util.TraceHull{
		start = pos + self.BuildYOffset * vector_up,
		endpos = pos - self.BuildYRange * vector_up,
		mins = self.BuildHull[1],
		maxs = self.BuildHull[2],
		filter = self,
	}
	
	if tr.Hit and not tr.StartSolid then
		pos = tr.HitPos
		local p

		p = pos + Vector(self.BuildHull[1].x, self.BuildHull[1].y, 1)
		tr = util.TraceLine{
			start = p, endpos = p - self.HeightTolerancy * vector_up,
			filter = self,
		}
		if not tr.Hit then return pos, ang, false end
		
		p = pos + Vector(self.BuildHull[1].x, self.BuildHull[2].y, 1)
		tr = util.TraceLine{
			start = p, endpos = p - self.HeightTolerancy * vector_up,
			filter = self,
		}
		if not tr.Hit then return pos, ang, false end
		
		p = pos + Vector(self.BuildHull[2].x, self.BuildHull[1].y, 1)
		tr = util.TraceLine{
			start = p, endpos = p - self.HeightTolerancy * vector_up,
			filter = self,
		}
		if not tr.Hit then return pos, ang, false end
		
		p = pos + Vector(self.BuildHull[2].x, self.BuildHull[2].y, 1)
		tr = util.TraceLine{
			start = p, endpos = p - self.HeightTolerancy * vector_up,
			filter = self,
		}
		if not tr.Hit then return pos, ang, false end
		
		return pos, ang, true
	end
	
	return pos, ang, false
end