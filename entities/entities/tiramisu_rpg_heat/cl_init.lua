include('shared.lua')     

function ENT:Draw()             
	self.Entity:DrawModel()  
end
 
function ENT:Initialize()
	local pos = self:GetPos()
	self.emitter = ParticleEmitter( pos )
end
 
function ENT:Think()
	local pos = self:GetPos()
	for i=0, (10) do
		local particle = self.emitter:Add( "particle/smokesprites_000"..math.random(1,9), pos + (self:GetUp() * -100 * i))
		if (particle) then
			particle:SetVelocity((self:GetUp() * -2000) )
			particle:SetDieTime( math.Rand( 2, 5 ) )
			particle:SetStartAlpha( math.Rand( 5, 8 ) )
			particle:SetEndAlpha( 0 )
			particle:SetStartSize( math.Rand( 40, 50 ) )
			particle:SetEndSize( math.Rand( 130, 150 ) )
			particle:SetRoll( math.Rand(0, 360) )
			particle:SetRollDelta( math.Rand(-1, 1) )
			particle:SetColor( 200 , 200 , 200 ) 
 			particle:SetAirResistance( 200 ) 
 			particle:SetGravity( Vector( 100, 0, 0 ) ) 	
		end
	end
end