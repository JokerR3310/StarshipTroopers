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

util.AddNetworkString( "TeamSelect" )
util.AddNetworkString( "OpenTeamSelect" )
util.AddNetworkString( "OpenHelpMenu" )

resource.AddWorkshop( "197393073" )

local RegenLast = 0
local RegenDelay = 0.06
local pm = FindMetaTable("Player")

function GM:GetGameDescription() 
 	return self.Name 
end

function GM:PlayerInitialSpawn( pl )
	pl:SetTeam(TEAM_SPECTATOR)
	pl:Money_Create()
	
	PrintMessage(HUD_PRINTTALK, pl:GetName() .. " has arrived.")
	
	self:ShowTeam(pl)
	pl:ChatPrint("Welcome to Starship Troopers: Do you want to live for ever or what?!")
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
	if (attacker:IsValid() && attacker:IsPlayer()) then
		return false
	end
	return true
end

local ST_BugsNPC = {
	["npc_antlion"]=true,
	["npc_antlion_worker"]=true
}
local ST_BossNPC = {
	["npc_antlionguard"]=true,
	["bug_tanker"]=true
}

function NPCKilled(npc, attacker)
	if attacker:IsPlayer() then
		if ST_BugsNPC[npc:GetClass()] then
			attacker:Money_Add(2)
			attacker:AddFrags(2)
		elseif ST_BossNPC[npc:GetClass()] then
			attacker:Money_Add(60)
			attacker:AddFrags(60)
		end
	end
end
hook.Add("OnNPCKilled", "OnNPCKilled", NPCKilled)

local ST_FriendNPC = {
	["npc_barney"]=true,
	["npc_citizen"]=true
}

function GM:EntityTakeDamage(target, dmginfo)
	if target:IsNPC() and ST_FriendNPC[target:GetClass()] then
		local pl = dmginfo:GetAttacker()
		if pl:IsPlayer() then
			dmginfo:SetDamage(0)
		end
	end
end

function GM:PlayerDeath( pl )
	pl.NextSpawnTime = CurTime() + 2
end

function PlayerDropWeapon(pl, attacker)
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
			phys:AddAngleVelocity(VectorRand()* math.Rand(20,50))
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

function GM:GetFallDamage( pl, speed )
	return math.max(0, math.ceil(0.2418*speed - 141.75))
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
		player_manager.SetPlayerClass(pl, "player_soldier")
		if pl:Team() == TEAM_SPECTATOR then
			pl:SetTeam(1)
			pl:Spawn()
		else
			pl:SetTeam(1)
			RunConsoleCommand("kill")
		end
	elseif variant == 2 then
		player_manager.SetPlayerClass(pl, "player_engineer")
		if pl:Team() == TEAM_SPECTATOR then
			pl:SetTeam(2)
			pl:Spawn()
		else
			RunConsoleCommand("kill")
			pl:SetTeam(2)
		end
	elseif variant == 3 then
		player_manager.SetPlayerClass(pl, "player_medic")
		if pl:Team() == TEAM_SPECTATOR then
			pl:SetTeam(1)
			pl:Spawn()
		else
			RunConsoleCommand("kill")
			pl:SetTeam(1)
		end
	elseif variant == 4 then
		player_manager.SetPlayerClass(pl, "player_sniper")
		if pl:Team() == TEAM_SPECTATOR then
			pl:SetTeam(1)
			pl:Spawn()
		else
			RunConsoleCommand("kill")
			pl:SetTeam(1)
		end
	elseif variant == 5 then
		pl:SetTeam(TEAM_SPECTATOR)
		pl:KillSilent()
		pl:Spectate(OBS_MODE_ROAMING)
	end
end)

function pm:Money_Create()
	self:SetPData( "cash", 0 ) 
	self:SetPData( "heat", 0 )
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

timer.Simple(3, function()
	-- Con Settings
	RunConsoleCommand("ai_disabled", "0")
	RunConsoleCommand("ai_ignoreplayers", "0")
	RunConsoleCommand("ai_serverragdolls", "0")
	RunConsoleCommand("npc_citizen_auto_player_squad", "0")
	
	RunConsoleCommand("sbox_noclip", "0")
	RunConsoleCommand("sbox_godmode", "0")
	RunConsoleCommand("sv_kickerrornum", "0")

	RunConsoleCommand("sk_antlion_health", "40")
	RunConsoleCommand("sk_antlion_swipe_damage", "15")
	RunConsoleCommand("sk_antlion_jump_damage", "10")

	RunConsoleCommand("sv_allowcslua", "0")
	RunConsoleCommand("r_shadows", "0")
	
	MsgC(Color(100, 255, 100), "# Loading game settings successfully completed!\n")
	
	-- Auto Load Map config
	local LoadMap = GAMEMODE.FolderName .. "/gamemode/maps/" .. game.GetMap() .. ".lua"
	if file.Exists( LoadMap, "LUA" ) then
		MsgC(Color(100, 255, 100), "# Loading config for: "..game.GetMap().."... \n")
		include( LoadMap )
	else
		MsgC(Color(255, 100, 100), "* THIS MAP IS NOT SUPPORTED *\n")
		MsgC(Color(255, 50, 50), "The current map is unsupported!\n")
	end
end)