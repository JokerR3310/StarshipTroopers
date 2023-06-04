AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

function ENT:Initialize()   
	self.flightvector = self:GetUp() * ((115*52.5)/66)
	self.timeleft = CurTime() + 10
	
	self.Owner = self:GetOwner()
	self:SetModel("models/props_junk/garbage_glassbottle001a.mdl")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_NONE )	
	self:SetSolid( SOLID_VPHYSICS ) 

	self:DrawShadow( false )

	local Glow = ents.Create("env_sprite")
	Glow:SetKeyValue("model","orangecore2.vmt")
	Glow:SetKeyValue("rendercolor","255 150 100")
	Glow:SetKeyValue("scale","0.3")
	Glow:SetPos(self:GetPos())
	Glow:SetParent(self)
	Glow:Spawn()
	Glow:Activate()
end   

function ENT:Think()
	if self.timeleft < CurTime() then
		self:Remove()				
	end

	local Table = {} 				//Table name is table name
	Table[1] = self.Owner 	//The person holding the gat
	Table[2] = self 	//The cap

	local trace = {}
		trace.start = self:GetPos()
		trace.endpos = self:GetPos() + self.flightvector
		trace.filter = Table
	local tr = util.TraceLine( trace )
	
	if tr.HitSky then
		self:Remove()
		return true
	end
	
	if tr.Hit then
		util.BlastDamage(self, self:GetOwner(), tr.HitPos, 800, 150)
			local effectdata = EffectData()
				effectdata:SetOrigin(tr.HitPos)			// Where is hits
				effectdata:SetNormal(tr.HitNormal)		// Direction of particles
				effectdata:SetEntity(self)		// Who done it?
				effectdata:SetScale(1.8)			// Size of explosion
				effectdata:SetRadius(tr.MatType)		// What texture it hits
				effectdata:SetMagnitude(18)			// Length of explosion trails
					util.Effect( "st_nadeairburst", effectdata ) -- st_staticboom
					util.ScreenShake( tr.HitPos, 10, 5, 1, 3000 )
					util.Decal( "Scorch", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal )
		self:Remove()	
	end
	
	self:SetPos(self:GetPos() + self.flightvector)
	self.flightvector = self.flightvector - self.flightvector/((147*39.37)/66) + self:GetUp()*2 + Vector(math.Rand(-0.3,0.3), math.Rand(-0.3,0.3),math.Rand(-0.1,0.1)) + Vector(0,0,-0.111)
	self:SetAngles(self.flightvector:Angle() + Angle(90,0,0))
	self:NextThink( CurTime() )
	return true
end