function EFFECT:Init( data )

local Pos = data:GetOrigin()
local Scale = data:GetScale()	
local Radius = data:GetRadius()
local DirVec = data:GetNormal()

local Angle = DirVec:Angle()

self.Scale = data:GetScale()

self.emitter = ParticleEmitter( Pos )
self.Origin = Pos	

	sound.Play( "weapons/explode" .. math.random(3, 5) .. ".wav", Pos, 100, 100 )

	for i=1,6 do 
		local Flash = self.emitter:Add( "effects/muzzleflash"..math.random(1,4), Pos )
		if (Flash) then
			Flash:SetDieTime( 0.15 )
			Flash:SetStartSize( 600 )
		end
	end

	for i=1, 10 do
		local Dust = self.emitter:Add( "particle/particle_composite", Pos )
		if (Dust) then
			Dust:SetVelocity( DirVec * math.random( 100,400)*Scale + ((VectorRand():GetNormalized()*300/Radius)*Scale) )
			Dust:SetDieTime( math.Rand( 2 , 3 ) )
			Dust:SetStartAlpha( 230-((-1+Radius)*120) )
			Dust:SetEndAlpha( 0 )
			Dust:SetStartSize( (60*Scale)/Radius )
			Dust:SetEndSize( (100*Scale)/Radius )
			Dust:SetRoll( math.Rand(150, 360) )
			Dust:SetRollDelta( math.Rand(-1, 1) )			
			Dust:SetAirResistance( 150 ) 			 
			Dust:SetGravity( Vector( 0, 0, math.Rand(-100, -400) ) ) 			
			Dust:SetColor( 80,75,70 )
		end
	end

	for i=1, 15 do
		local Dust = self.emitter:Add( "particle/smokesprites_000"..math.random(1,9), Pos )
		if (Dust) then
			Dust:SetVelocity( DirVec * math.random( 100,400)*Scale + ((VectorRand():GetNormalized()*400/Radius)*Scale) )
			Dust:SetDieTime( math.Rand( 1 , 5 )*Scale )
			Dust:SetStartAlpha( 50 )
			Dust:SetEndAlpha( 0 )
			Dust:SetStartSize( (80*Scale) )
			Dust:SetEndSize( (100*Scale) )
			Dust:SetRoll( math.Rand(150, 360) )
			Dust:SetRollDelta( math.Rand(-1, 1) )			
			Dust:SetAirResistance( 250 ) 			 
			Dust:SetGravity( Vector( math.Rand( -200 , 200 ), math.Rand( -200 , 200 ), math.Rand( 10 , 100 ) ) )		
			Dust:SetColor( 80,77,74 )
		end
	end

	for i=1, 25 do
		local Debris = self.emitter:Add( "effects/fleck_cement"..math.random(1,2), Pos )
		if (Debris) then
			Debris:SetVelocity ( DirVec * math.random(0,500)*Scale + VectorRand():GetNormalized() * math.random(0,400)*Scale )
			Debris:SetDieTime( math.random(1, 2))
			Debris:SetStartAlpha( 255 )
			Debris:SetEndAlpha( 0 )
			Debris:SetStartSize( math.random(5,10))
			Debris:SetRoll( math.Rand(0, 360) )
			Debris:SetRollDelta( math.Rand(-5, 5) )			
			Debris:SetAirResistance( 40 ) 			 			
			Debris:SetColor( 53,50,45 )
			Debris:SetGravity( Vector( 0, 0, -600) ) 	
		end
	end
end

function EFFECT:Think( )
	return false
end
function EFFECT:Render()
end