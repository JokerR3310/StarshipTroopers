ENT.Type = "anim"
ENT.Author = "-=JokerR |CMBG|=-"

function ENT:PhysicsCollide(data,phys)
	if data.Speed > 50 then
		self.Entity:EmitSound(Sound("HEGrenade.Bounce"))
	end
end