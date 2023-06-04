GM.Name = "Starship Troopers"
GM.Author = "-=JokerR |CMBG|=-"
GM.Version = "BETA 0.8.1"

DeriveGamemode("sandbox") -- Dev mode

include("player_class/player_engineer.lua")
include("player_class/player_medic.lua")
include("player_class/player_soldier.lua")
include("player_class/player_sniper.lua")

-- Pre Load ConVars
GM.RoundLimit = GetConVar("wave_amount") 
GM.RoundLength = GetConVar("wave_length")
GM.RoundPostEndTime = GetConVar("wave_post_end")

team.SetUp(1, "Player", Color(0, 0, 255))
team.SetUp(2, "Engi", Color(0, 0, 255))

function GM:GetGameDescription() 
 	return "Starship Troopers - Outpost Defence Simulator 2015"
end

function GM:Initialize()
	hook.Remove("PlayerTick", "TickWidgets")
end

function GM:ShowHelp( pl )
	net.Start("OpenHelpMenu")
	net.Send(pl)
end

function GM:ShowTeam( pl )
	net.Start("OpenTeamSelect")
	net.Send(pl)
end

net.Receive("OpenTeamSelect", function( length )
	if GAMEMODE.HelpMenu then GAMEMODE.HelpMenu:Remove() end
	if GAMEMODE.TeamSelect then GAMEMODE.TeamSelect:Remove() end
	GAMEMODE.TeamSelect = vgui.Create("DTeamSelect")
end)

net.Receive("OpenHelpMenu", function()
	if GAMEMODE.TeamSelect then GAMEMODE.TeamSelect:Remove() end
	if GAMEMODE.HelpMenu then GAMEMODE.HelpMenu:Remove() end
	GAMEMODE.HelpMenu = vgui.Create("DHelpMenu")
end)

function GM:PlayerSpawn( pl )
	pl:SetCanZoom(false)

	if pl:Team() == TEAM_SPECTATOR then
		pl:SetNoTarget(true)
		GAMEMODE:PlayerSpawnAsSpectator( pl )
		return
	end

	pl:SetNoTarget(false)
	
	pl:UnSpectate()	
	
	player_manager.OnPlayerSpawn( pl )
	player_manager.RunClass( pl, "Loadout" )
	player_manager.RunClass( pl, "SetModel" )
end

function GM:ContextMenuOpen()
	return false
end

function GM:PlayerNoClip( pl )
	if pl:Team() == TEAM_SPECTATOR then return false end
	return GetConVar( "sbox_noclip" ):GetBool()
end