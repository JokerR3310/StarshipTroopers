////////// Map Config File \\\\\\\\\\\
//									\\
//		Map: 		STG_OUTPOST 87	\\		
//		Author: 	Tysn (Obsidian Conflict)
//		Version: 	Stable(Beta) 	\\
//									\\
// // // // // // || \\ \\ \\ \\ \\ \\

// Wave Parameters

CreateConVar("wave_amount", 12, FCVAR_REPLICATED, "Total rounds amount.") -- 12
CreateConVar("wave_length", 120, FCVAR_REPLICATED, "Round length in seconds.") -- 120
CreateConVar("wave_post_end", 62, FCVAR_REPLICATED, "Seconds between round end and round start.") -- 62



// Do Not modify anything below this line!

timer.Simple(1, function()
	for _, ent in ipairs( ents.FindByName( "Cutscene_Relay" )) do
		if ( ent:GetClass() == "logic_relay" ) then
			ent:Fire( "trigger" )
			timer.Simple(10, function()
				hook.Call( "OnPreRoundStart", GAMEMODE, GAMEMODE.Round + 1 )
			end)
		end
	end
	
	
	
	--[[
	local gunner = ents.Create( "npc_citizen" )
	--gunner:SetModel( "models/weapons/naboje/mk2_ammo.mdl" )
	gunner:SetPos(Vector(-451.53, -485.76, 264.03))
	--gunner:Spawn()
	
	local gunner = ents.Create( "npc_citizen" )
	--gunner:SetModel( "models/weapons/naboje/mk2_ammo.mdl" )
	gunner:SetPos(Vector(82.84, 73.34, 264.03))
	--gunner:Spawn()
	
	
	local barney = ents.Create( "npc_barney" )
	--barney:SetModel( "models/weapons/naboje/mk2_ammo.mdl" )
	barney:SetPos(Vector(-531.43, 148.06, 76.03))
	--barney:Spawn()
	]]
end)

-- SETUP ALL SHIT!!! (TO DO)


--[[
local right_wing = {
	Vector(-229.01, -6570.85, 117.37),
	
	Vector(-520.35, -6496.35, 87.68),
	Vector(-652.6, -6469.08, 83.45),
	Vector(-852.44, -6436.2, 88.81),
	Vector(-1059.95, -6403.48, 96.39),
	Vector(-1238.87, -6381.23, 111.35),
	Vector(-1417.98, -6360.01, 127.82),
	Vector(-1619.6, -6336.77, 147.27),
	Vector(-1606.52, -6005.96, 99.22),
	Vector(-1383.91, -6016.83, 86.91),
	Vector(-1278.44, -6021.93, 80.32),
	Vector(-1128.81, -6035.93, 72.4),
	Vector(-930.81, -6040.35, 75.95),
	Vector(-1058.45, -5666.93, 84.51),
	Vector(-1303.42, -5565.73, 64.72),
	Vector(-1517.83, -5530.42, 64.58),
	Vector(-1726.42, -5505.78, 67.91),
	Vector(-1897.91, -5486.58, 71.43),
	Vector(-2069.12, -5465.28, 73.38),
	Vector(-2150.61, -4989.92, 57.11),
	
}
]]

--[[
hook.Add("OnRoundStart", "STGRoundStart", function(round)
	print(round)

	if round == 2 then
		
		timer.Simple(5, function()
		end)
		
		
		
		
		timer.Create( "antlion_timer_01", 5, 24, function()
		
			for i = 1, math.random(6, 12) do
				local npc = ents.Create( "npc_antlion" )
				--npc:SetModel( "" )
				npc:SetPos(right_wing[math.random(#right_wing)] + Vector(math.random(-512, 512), math.random(-512, 512), 100))
				--npc:Spawn()
			
			
			end
		
		
		
		
		end )
		
		
		
		
		--npc_antlion
		--npc_antlionguard
		
	
	
	end
	
end)

]]











/////// WAVE 1 ////////

/////// WAVE 2 ////////

/////// WAVE 3 ////////

/////// WAVE 4 ////////

/////// WAVE 5 ////////

/////// WAVE 6 ////////

/////// WAVE 7 ////////

/////// WAVE 8 ////////

/////// WAVE 9 ////////

/////// WAVE 10 ///////

MsgC( Color( 255, 155, 100 ), "# STG_OUTPOST 87 | Map config file Loaded!\n" )