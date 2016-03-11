include("shared.lua")

ENT.RenderGroup = RENDERGROUP_BOTH

local ScreenTexture = surface.GetTextureID("vgui/dispenser_meter_bg_red")
local ArrowTexture = surface.GetTextureID("vgui/dispenser_meter_arrow")
local Offset = Vector(-1.13, -11.2, -0.6)
local Scale = 0.0425
local DialSpeed = 1
local AngleStart = 85
local AngleEnd = -85

function ENT:CalcAngle(m)
	return Lerp(m, AngleStart, AngleEnd)
end

function ENT:Draw()
	if self:GetState() < 2 then return end
	
	self:DrawModel()
	
	if not self.Model then
		for _,v in pairs(ents.FindByClass("obj_anim")) do
			if v:GetOwner() == self then
				self.Model = v
				break
			end
		end
	end
	
	if not IsValid(self.Model) then return end
	
	local metal = self:GetAmmoPercentage()
	if metal and metal~=self.LastMetalAmount then
		if not self.Ang then
			self.Ang = self:CalcAngle(metal)
		else
			if metal>self.LastMetalAmount then
				self.DAng = -DialSpeed
			else
				self.DAng = DialSpeed
			end
			self.TargetAngle = self:CalcAngle(metal)
		end
		self.LastMetalAmount = metal
	elseif self.TargetAngle then
		if self.Ang*self.DAng > self.TargetAngle*self.DAng then
			self.Ang = self.TargetAngle
			self.TargetAngle = nil
		else
			self.Ang = self.Ang + self.DAng
		end
	end
	
	local cp0_ll = self.Model:GetAttachment(self:LookupAttachment("controlpanel0_ll"))
	local cp1_ll = self.Model:GetAttachment(self:LookupAttachment("controlpanel1_ll"))
	
	cam.Start3D2D(cp0_ll.Pos
		+ Offset.x * cp0_ll.Ang:Forward()
		+ Offset.y * cp0_ll.Ang:Right()
		+ Offset.z * cp0_ll.Ang:Up(), cp0_ll.Ang, Scale)
		self:DrawScreen()
	cam.End3D2D()
	
	cam.Start3D2D(cp1_ll.Pos
		+ Offset.x * cp1_ll.Ang:Forward()
		+ Offset.y * cp1_ll.Ang:Right()
		+ Offset.z * cp1_ll.Ang:Up(), cp1_ll.Ang, Scale)
		self:DrawScreen()
	cam.End3D2D()
end

function ENT:DrawScreen()
	surface.SetDrawColor(255,255,255,255)

	surface.SetTexture(ScreenTexture)
	
	surface.DrawTexturedRect(0, 0, 480, 289)
	surface.SetTexture(ArrowTexture)
	
	local a = self.Ang
	local r = math.rad(a)
	local s, c = math.sin(r), math.cos(r)
	
	surface.DrawTexturedRectRotated(480*0.5 - math.floor(81*s), 288*0.90625 - math.floor(81*c), 50, 200, a)
end