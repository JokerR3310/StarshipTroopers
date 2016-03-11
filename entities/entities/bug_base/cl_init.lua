include('shared.lua')

language.Add("bug_tanker", "Tanker Bug")

function ENT:Initialize()	
end

function ENT:Draw()
	self:DrawModel()
end