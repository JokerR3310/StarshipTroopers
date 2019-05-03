include("shared.lua")

include("client/cl_legs.lua")
include("client/cl_view.lua")
include("client/holster.lua")

include("client/vgui/cl_hud.lua")
include("client/vgui/cl_help.lua")
include("client/vgui/cl_scoreboard.lua")
include("client/vgui/cl_teamselect.lua")
----------
include("sh_round.lua")
include("sh_gamestate.lua")

include("cl_entclientinit.lua")

include("mapvote/config.lua")
include("mapvote/cl_mapvote.lua")

include("st_config.lua")

game.AddParticles( "particles/antlion_gib_02.pcf" )
game.AddParticles( "particles/antlion_worker.pcf" )
game.AddParticles( "particles/sparks.pcf" )

surface.CreateFont( "st_timer_text", { font = "Roboto", size = 23, weight = 600, antialias = true } )

function GM:Initialize()
	RunConsoleCommand("gmod_mcore_test", "1")
	RunConsoleCommand("mat_queue_mode", "2")
	RunConsoleCommand("cl_threaded_bone_setup", "1")
end

local HUDToHide = {
	["CHudHealth"]=true,
	["CHudBattery"]=true,
	["CHudAmmo"]=true,
	["CHudSecondaryAmmo"]=true
}

function GM:HUDShouldDraw(name)
	if HUDToHide[name] then return false end
	return true
end

function GM:OnRoundStart( num ) -- Unused hook run on round start where num is the round number.
end