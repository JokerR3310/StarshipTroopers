include("shared.lua")

include("sh_netwrapper.lua")

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

include("mapvote/config.lua")
include("mapvote/cl_mapvote.lua")

include("st_config.lua")

game.AddParticles( "particles/sparks.pcf" )

function GM:Initialize()
	RunConsoleCommand("gmod_mcore_test", "1")
	RunConsoleCommand("mat_queue_mode", "2")
	RunConsoleCommand("cl_threaded_bone_setup", "0")
	RunConsoleCommand("r_drawmodeldecals", "0")
end

timer.Simple(5, function()
	-- Con Settings
	RunConsoleCommand("cl_threaded_bone_setup", "0")
	RunConsoleCommand("r_drawmodeldecals", "0")
end)

local hide = {
	["CHudHealth"] = true,
	["CHudBattery"] = true,
	["CHudAmmo"] = true,
	["CHudSecondaryAmmo"] = true
}

hook.Add("HUDShouldDraw", "HideHUD", function(name)
	if hide[name] then
		return false
	end
end)

function GM:OnRoundStart( num ) -- Unused hook run on round start where num is the round number.
end