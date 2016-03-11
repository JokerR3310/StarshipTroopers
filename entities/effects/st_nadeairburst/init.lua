function EFFECT:Init( data )
local Pos 		= data:GetOrigin()
local Scale 		= data:GetScale()	
local Radius 		= data:GetRadius()
local DirVec 		= Vector(0,0,0)
local Particles 	= data:GetMagnitude()
local Angle 		= DirVec:Angle()
local DebrizzlemyNizzle = 20+data:GetScale()	

	self.Particles 		= data:GetMagnitude()
	self.Scale 		= data:GetScale()	
	self.Size 		= 5*self.Scale
	self.Origin 		= Pos	
	self.emitter 		= ParticleEmitter( Pos )
		sound.Play( "ambient/explosions/explode_" .. math.random(1, 4) .. ".wav", Pos, 100, 100 )

	for i=1,5 do 
		local Flash = self.emitter:Add( "effects/muzzleflash"..math.random(1,4), Pos )
			Flash:SetVelocity( Vector(0,0,0) )
			Flash:SetAirResistance( 200 )
			Flash:SetDieTime( 0.15 )
			Flash:SetStartAlpha( 255 )
			Flash:SetEndAlpha( 0 )
			Flash:SetStartSize( Scale*300 )
			Flash:SetEndSize( 0 )
			Flash:SetRoll( math.Rand(180,480) )
			Flash:SetRollDelta( math.Rand(-1,1) )
			Flash:SetColor(255,255,255)	
	end

	for i=1, 50*Scale do
		local Dust = self.emitter:Add( "particle/smokesprites_000"..math.random(1,9), Pos )
			Dust:SetVelocity( DirVec * math.random( 100,400)*Scale + ((VectorRand():GetNormalized()*500)*Scale) )
			Dust:SetDieTime( math.Rand( 1 , 5 )*Scale )
			Dust:SetStartAlpha( 50 )
			Dust:SetEndAlpha( 0 )
			Dust:SetStartSize( (80*Scale) )
			Dust:SetEndSize( (100*Scale) )
			Dust:SetRoll( math.Rand(150, 360) )
			Dust:SetRollDelta( math.Rand(-1, 1) )			
			Dust:SetAirResistance( 250 ) 			 
			Dust:SetGravity( Vector( math.Rand( -200 , 200 ), math.Rand( -200 , 200 ), math.Rand( 10 , 100 ) ) )		
			Dust:SetColor( 80,80,80 )
	end

	for i=1, 60*Scale do
		local Debris = self.emitter:Add( "effects/fleck_cement"..math.random(1,2), Pos )
			Debris:SetVelocity (VectorRand():GetNormalized() * math.random(2000,4000)*Scale )
			Debris:SetDieTime( math.random( 1, 2) * Scale )
			Debris:SetStartAlpha( 255 )
			Debris:SetEndAlpha( 0 )
			Debris:SetStartSize( math.random(4,7)*Scale)
			Debris:SetRoll( math.Rand(0, 360) )
			Debris:SetRollDelta( math.Rand(-5, 5) )			
			Debris:SetAirResistance( 40 ) 			 			
			Debris:SetColor( 53,50,45 )
			Debris:SetGravity( Vector( 0, 0, -600) ) 	
	end
	for i = 1, DebrizzlemyNizzle do 	
		local RanVec = VectorRand():GetNormalized()*math.Rand(4, 7)

		for k = 3, self.Particles do
			local Rcolor = math.random(-20,20)
			local particle1 = self.emitter:Add( "particle/smokesprites_000"..math.random(1,9), Pos )				
			particle1:SetVelocity((VectorRand():GetNormalized()*math.Rand(1, 2) * self.Size) + (RanVec*self.Size*k*3.5))	
			particle1:SetDieTime( math.Rand( 0, 3 )*self.Scale )	
			particle1:SetStartAlpha( math.Rand( 80, 90 )-((-1+Radius)*10) )			
			particle1:SetEndAlpha(0)	
			particle1:SetGravity((VectorRand():GetNormalized()*math.Rand(5, 10)* self.Size) + Vector(0,0,-50))
			particle1:SetAirResistance( 200+Scale*20 ) 		
			particle1:SetStartSize( (6*self.Size)-((k/self.Particles)*self.Size*3) )	
			particle1:SetEndSize( (20*self.Size)-((k/self.Particles)*self.Size) )
			particle1:SetRoll( math.random( -500, 500 )/100 )	
			particle1:SetRollDelta( math.random( -0.5, 0.5 ) )	
			particle1:SetColor( 80+Rcolor,80+Rcolor,80+Rcolor )
		end
	end
end

function EFFECT:Think( )
	return false
end
function EFFECT:Render()
end