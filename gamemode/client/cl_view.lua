local WalkTimer 		= 0
local VelSmooth 		= 0
local LastStrafeRoll 	= 0

local movementconvar = CreateConVar( "cl_movement", "1", { FCVAR_ARCHIVE, }, "Enable/Disable the movement effects" )

local function CalcView(ply, pos, ang, fov)
	local vel = ply:GetVelocity()
	local angle = ply:EyeAngles()

	if !movementconvar:GetBool() then return end
	if ply:Team() == TEAM_SPECTATOR then return end
	// Underwater effect
	--if 2 < ply:WaterLevel() and ply:Alive() then
	--	ang.roll = ang.roll + math.sin(RealTime()) * 7
	--end

	// Movement effect
	if ply:Alive() then	
		ang.roll = ang.roll + math.sin(WalkTimer) * VelSmooth * 0.001
		ang.pitch = ang.pitch + math.sin(WalkTimer * 2) * VelSmooth * 0.01

		ang.roll = ang.roll + ply:EyeAngles():Right():DotProduct(ply:GetVelocity()) * 0.005

		if ply:IsOnGround() then	

			VelSmooth = VelSmooth * 0.5 + ply:GetVelocity():Length() * 0.04
			WalkTimer = WalkTimer + VelSmooth * FrameTime() * 0.04

			VelSmooth = math.Clamp(VelSmooth * 0.9 + vel:Length() * 0.1, 0, 75)
			
			WalkTimer 		= WalkTimer + VelSmooth * FrameTime() * 0.05
			LastStrafeRoll 	= (LastStrafeRoll * 3) + (ang:Right():DotProduct(vel) * 0.0001 * VelSmooth * 0.3)
			LastStrafeRoll 	= LastStrafeRoll * 0.25
			angle.roll 		= angle.roll + LastStrafeRoll
			
			angle.roll 	= angle.roll + math.sin(WalkTimer) * VelSmooth * 0.000002 * VelSmooth
			angle.pitch = angle.pitch + math.cos(WalkTimer * 0.5) * VelSmooth * 0.000002 * VelSmooth
			angle.yaw 	= angle.yaw + math.cos(WalkTimer) * VelSmooth * 0.000002 * VelSmooth
		end
	end

end
hook.Add("CalcView", "CalcView", CalcView)