////////// Map Config File \\\\\\\\\\\
//									\\
//		Map: 		ST_OUTPOST 87	\\		
//		Author: 	JokerR			\\
//		Version: 	Stable(Beta) 	\\
//									\\
// // // // // // || \\ \\ \\ \\ \\ \\

// Wave Parameters

CreateConVar("wave_amount", 11, FCVAR_REPLICATED, "Total rounds amount.") -- 12
CreateConVar("wave_length", 120, FCVAR_REPLICATED, "Round length in seconds.") -- 120
CreateConVar("wave_post_end", 62, FCVAR_REPLICATED, "Seconds between round end and round start.") -- 122

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
end)

-- SETUP ALL SHIT!!! (TO DO)

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

MsgC( Color( 255, 155, 100 ), "ST_OUTPOST 87 | Map config file Loaded!\n" )