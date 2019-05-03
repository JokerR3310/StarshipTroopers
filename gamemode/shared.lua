GM.Name = "Starship Troopers"
GM.Author = "-=JokerR |CMBG|=-"
GM.Email = "N/A"
GM.Website = "http://steamcommunity.com/sharedfiles/filedetails/?id=197393073"
GM.Version = "BETA 0.7.8"

include("player_class/player_engineer.lua")
include("player_class/player_medic.lua")
include("player_class/player_soldier.lua")
include("player_class/player_sniper.lua")

--DeriveGamemode("sandbox") -- Dev mode

-- Pre Load ConVars
GM.RoundLimit = CreateConVar("wave_amount", 11, FCVAR_REPLICATED, "Total rounds amount.") -- 12
GM.RoundLength = CreateConVar("wave_length", 120, FCVAR_REPLICATED, "Round length in seconds.") -- 120
GM.RoundPostEndTime = CreateConVar("wave_post_end", 62, FCVAR_REPLICATED, "Seconds between round end and round start.") -- 62

team.SetUp(1, "Player", Color(0, 0, 255))
team.SetUp(2, "Engi", Color(0, 0, 255))

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
	pl:Flashlight(false)
	pl:AllowFlashlight(false)
	
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
end

function GM:PlayerNoClip( pl )
	if pl:Team() == TEAM_SPECTATOR then return false end
	return GetConVar( "sbox_noclip" ):GetBool()
end

function GM:GmodLoadScript()
	if engine.ActiveGamemode() == self.FolderName then return false end
	return true
end