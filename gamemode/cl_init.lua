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

game.AddParticles( "particles/ANTLION_GIB_02.pcf" )
game.AddParticles( "particles/ANTLION_WORKER.pcf" )

surface.CreateFont( "st_timer_text", { font = "Roboto", size = 23, weight = 600, antialias = true } )

GM.HUDToHide = {
	"CHudHealth",
	"CHudBattery",
	"CHudAmmo",
	"CHudSecondaryAmmo"
}

function GM:HUDShouldDraw( name )
	if table.HasValue(self.HUDToHide, name) then return false end
		return true
end

function GM:OnRoundStart( num ) -- Unused hook run on round start where num is the round number.
end