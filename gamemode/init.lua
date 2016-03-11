AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

AddCSLuaFile("st_config.lua")
include("st_config.lua")

----------------------------
AddCSLuaFile("mapvote/cl_mapvote.lua")
AddCSLuaFile("mapvote/config.lua")

include("mapvote/config.lua")
include("mapvote/sv_mapvote.lua")
include("mapvote/rtv.lua")

-----------------------------
AddCSLuaFile("client/cl_legs.lua")
AddCSLuaFile("client/cl_view.lua")
AddCSLuaFile("client/holster.lua")

AddCSLuaFile("client/vgui/cl_hud.lua")
AddCSLuaFile("client/vgui/cl_help.lua")
AddCSLuaFile("client/vgui/cl_scoreboard.lua")
AddCSLuaFile("client/vgui/cl_teamselect.lua")

---------------------------------------------
AddCSLuaFile("sh_round.lua")
AddCSLuaFile("sh_gamestate.lua")

AddCSLuaFile("cl_entclientinit.lua")

include("sv_round.lua")
include("sh_round.lua")
include("sh_gamestate.lua")

include("player_class/player_engineer.lua")
include("player_class/player_medic.lua")
include("player_class/player_soldier.lua")
include("player_class/player_sniper.lua")

util.AddNetworkString( "TeamSelect" )
util.AddNetworkString( "OpenTeamSelect" )
util.AddNetworkString( "OpenHelpMenu" )

resource.AddWorkshop( "197393073" )

local RegenLast = 0
local RegenDelay = 0.06
local pm = FindMetaTable("Player")

function GM:Initialize()
	--if file.Exists("gamemodes/" .. string.lower( GAMEMODE.Name ) .. "/gamemode/maps/" .. string.lower( game.GetMap() ) .. ".lua", "GAME") then
	--	include("../gamemodes/" .. string.lower( GAMEMODE.Name ) .. "/gamemode/maps/" .. string.lower( game.GetMap() ) .. ".lua")
	--end
	--print("Loading maps successfully completed")
end

function GM:GetGameDescription() 
 	return self.Name 
end

local DomNextThink = 0
local DomNextTone = 0

function GM:Think()
	local curtime = CurTime()
	if curtime - RegenLast >= RegenDelay then
		for _, v in ipairs( player.GetAll() ) do
			if v:Alive() and v:Armor() < 100 and (NextArmorRegen or 0) < CurTime() then
				v:SetArmor( v:Armor() + 1 )
			end
		end
		RegenLast = curtime
	end
	
	for k, v in pairs(player.GetAll()) do
		if (curtime < DomNextThink) then return end
		if v:Get_heat() >= 100 then
			if (curtime < DomNextTone) then return end
			DomNextTone = curtime + 0.2
		end
		if v:Get_heat() < 120 then
			DomNextThink = curtime +0.017
		end
		if v:Get_heat() > 0 then
			v:Set_heat(v:Get_heat() - 1)
		end
	end
end

function GM:PlayerHurt()
	NextArmorRegen = (CurTime() + 3.5)
end

function GM:PlayerShouldTakeDamage(ply, attacker)
	if (game.SinglePlayer()) then return true end
	
	if (cvars.Bool("sbox_godmode", false )) then return false end
	
	if (attacker:IsValid() && attacker:IsPlayer()) then
		return cvars.Bool( "sbox_playershurtplayers", true)
	end
	return true
end

function NPCKilled(npc, pl)
	if pl:IsPlayer() then
		if table.HasValue(ST_BugsNPC, npc:GetClass()) then
			pl:Money_Add(2)
			pl:AddFrags(2)
		elseif table.HasValue(ST_BossNPC, npc:GetClass()) then
			pl:Money_Add(15)
			pl:AddFrags(15)
		end
	end
end
hook.Add("OnNPCKilled", "OnNPCKilled", NPCKilled)

function GM:ScaleNPCDamage(npc, hit, dmg)
	if table.HasValue(ST_FriendNPC, npc:GetClass() ) then
		local pl = dmg:GetAttacker()
		if pl:IsPlayer() then
			dmg:SetDamage(0)
		end
	end
end

function GM:PlayerDeath( pl )
	pl.NextSpawnTime = CurTime() + 2
end

function PlayerDropWeapon(pl, attacker) -- Drop wep
	if (pl:GetActiveWeapon():IsValid()) then

	local drop = ents.Create("item_droppedweapon")
		drop:SetModel(pl:GetActiveWeapon():GetModel())
		drop:SetPos(pl:GetActiveWeapon():GetPos())
		drop:SetAngles(pl:GetActiveWeapon():GetAngles())
		drop:SetSolid(SOLID_VPHYSICS)
		drop:PhysicsInit(SOLID_VPHYSICS)
		drop:Spawn()
		drop:Activate()
		
		drop:SetMoveType(MOVETYPE_VPHYSICS)
		drop:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
			
	local phys = drop:GetPhysicsObject()
		if phys:IsValid() then
			phys:AddAngleVelocity(VectorRand())
			phys:AddVelocity(pl:GetVelocity())
			phys:Wake()
		end
	end
end
hook.Add("DoPlayerDeath", "drop", PlayerDropWeapon)

function GM:PlayerDeathThink( pl )
	if (pl.NextSpawnTime and pl.NextSpawnTime > CurTime() - 4 ) then return end
		pl:Spawn()
end

function GM:GetFallDamage( pl, vel )
	return (vel-480)*(100/(1024-580))
end

function GM:PlayerUse( pl )
	if pl:Team() == TEAM_SPECTATOR then return false end
	return true
end

function GM:CanPlayerSuicide( pl )
	if pl:Team() == TEAM_SPECTATOR then return false end
	return true
end

function GM:PlayerDisconnected( pl )
	 PrintMessage( HUD_PRINTTALK, "Player "..pl:Name().. " left the game." )
	 for _,v in pairs(ents.FindByClass("obj_*")) do
		if v:GetBuilder() == pl then
			v:Remove()
		end
	end
end

function GM:ShutDown()
	function pm:ShutDown()
		self:RemovePData( "cash" )
	end
end

net.Receive("TeamSelect", function(length, pl)
	local variant = net.ReadInt(4)
	if variant == 1 then
		if pl:Team() == TEAM_SPECTATOR then
			pl:SetTeam(1)
			player_manager.SetPlayerClass( pl, "player_soldier" )
			pl:Spawn()
		else
			RunConsoleCommand("kill")
			pl:SetTeam(1)
			player_manager.SetPlayerClass( pl, "player_soldier" )
		end
	elseif variant == 2 then
		if pl:Team() == TEAM_SPECTATOR then
			pl:SetTeam(2)
			player_manager.SetPlayerClass( pl, "player_engineer" )
			pl:Spawn()
		else
			RunConsoleCommand("kill")
			pl:SetTeam(2)
			player_manager.SetPlayerClass( pl, "player_engineer" )
		end
	elseif variant == 3 then
		if pl:Team() == TEAM_SPECTATOR then
			pl:SetTeam(1)
			player_manager.SetPlayerClass( pl, "player_medic" )
			pl:Spawn()
		else
			RunConsoleCommand("kill")
			pl:SetTeam(1)
			player_manager.SetPlayerClass( pl, "player_medic" )
		end
	elseif variant == 4 then
		if pl:Team() == TEAM_SPECTATOR then
			pl:SetTeam(1)
			player_manager.SetPlayerClass( pl, "player_sniper" )
			pl:Spawn()
		else
			RunConsoleCommand("kill")
			pl:SetTeam(1)
			player_manager.SetPlayerClass( pl, "player_sniper" )
		end
	elseif variant == 5 then
		pl:SetTeam(TEAM_SPECTATOR)
		pl:KillSilent()
		pl:Spectate(OBS_MODE_ROAMING)
	end
end)

-----------------------------------------------------------------
function pm:Money_Create() -- DONT TOUCH! THIS FUNCTION SAVES THE SHIT
	if self:SetPData( "cash" ) == nil then -- if there is no data under "cash", create some!
		self:SetPData( "cash", 0 ) -- if there is no "cash" data, give them 15 cash to begin with!
		self:SetPData( "heat", 0 ) -- if there is no "cash" data, give them 15 cash to begin with!
	end
end

function pm:Money_Set( cash )
	self:SetPData( "cash", tonumber(cash) ) -- Saves the cash to the server
	self:SetNWInt( "cash", tonumber(cash) ) -- Sends the amount to the players" screens
end

function pm:Money_Add( cash ) -- player:Money_Add = ADD MONEY FOR A PLAYER
	local current = tonumber(self:GetPData( "cash" )) -- Get the old amount of money
	if cash > 0 then -- If the cash to give is over 0...
		self:Money_Set( current + cash ) -- Set the money to: The old amount of money + the money wished to be added
	end
end

function pm:Money_Get() -- player:Money_Add = GET THE MONEY FOR A PLAYER
	local current = tonumber(self:GetPData( "cash" )) -- Get the old amount of money
	return current
end

function pm:Money_Has( cash ) -- player:Money_Add = GET THE MONEY FOR A PLAYER
	local current = tonumber(self:GetPData( "cash" )) -- Get the old amount of money
	if current >= tonumber(cash) then -- if the old amount si over the amount checked...
		return true -- say it"s true!
	else
		return false -- if not, say it"s false!
	end
end

function pm:Money_Take( cash )  -- player:Money_Add = TAKE MONEY FOR A PLAYER
	if self:Money_Has( cash ) then -- if you got the amount of money...
		local current = tonumber(self:GetPData( "cash" )) -- Get the old amount of money
		self:Money_Set( current - cash ) -- Take the old amount of money and take away the amount given!
	end
end

function pm:Get_heat( heat )
	local current = tonumber(self:GetPData( "heat" )) -- Get the old amount of money
	return current
end

function pm:Set_heat( heat )
	self:SetPData( "heat", tonumber(heat) ) -- Saves the cash to the server
	self:SetNWInt( "heat", tonumber(heat) ) -- Sends the amount to the players" screens
end

function pm:GameSync()
	net.Start("GameState")
	net.WriteInt(GAMEMODE:GetGameState(), 4)
	net.Send(self)

	net.Start("Wave")
	net.WriteInt(GAMEMODE:GetRound(), 8)
	net.Send(self)
end

-- CSettings
timer.Simple(3, function()
	RunConsoleCommand("ai_disabled", "0");

	RunConsoleCommand("sv_kickerrornum", "0");
	RunConsoleCommand("ai_ignoreplayers", "0");

	RunConsoleCommand("sk_antlion_health", "40");
	RunConsoleCommand("sk_antlion_swipe_damage", "15");
	RunConsoleCommand("sk_antlion_jump_damage", "10");

	RunConsoleCommand("sv_allowcslua", "0");
	
	MsgC( Color( 100, 255, 100 ), "Loading settings successfully completed\n" )
end)