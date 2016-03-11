ENT.Type = "anim"
ENT.PrintName			= "Fragmentation Grenade"
ENT.Author			= "Generic Default"
ENT.Contact			= "AIDS"
ENT.Purpose			= "Sploding"
ENT.Instructions			= "Throw"

function ENT:OnRemove()
end

function ENT:PhysicsUpdate()
end

function ENT:PhysicsCollide(data,phys)
	if data.Speed > 50 then
		self.Entity:EmitSound(Sound("HEGrenade.Bounce"))
	end
	
	local impulse = -data.Speed * data.HitNormal * .4 + (data.OurOldVelocity * -.6)
	phys:ApplyForceCenter(impulse)
end
