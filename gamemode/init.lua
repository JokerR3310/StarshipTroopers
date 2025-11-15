AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

AddCSLuaFile("sh_netwrapper.lua")
include("sh_netwrapper.lua")

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

AddCSLuaFile("player_class/player_engineer.lua")
AddCSLuaFile("player_class/player_medic.lua")
AddCSLuaFile("player_class/player_soldier.lua")
AddCSLuaFile("player_class/player_sniper.lua")
---------------------------------------------
AddCSLuaFile("sh_round.lua")
AddCSLuaFile("sh_gamestate.lua")

include("sv_round.lua")
include("sh_round.lua")
include("sh_gamestate.lua")

util.AddNetworkString( "TeamSelect" )
util.AddNetworkString( "OpenTeamSelect" )
util.AddNetworkString( "OpenHelpMenu" )

resource.AddWorkshop( "197393073" )

CreateConVar("stg_game_difficulty", "2", FCVAR_NOTIFY, "Game difficulty convar: 1 - Easy, 2 - Normal, 3 - Hard", 1, 3)

function GM:PlayerInitialSpawn( pl )
	pl:SetTeam(TEAM_SPECTATOR)
	pl:SetNetVar("Credits", 0)
	pl:SetNetVar("Heat", 0)
	pl:SetNetVar("Taunt", false)

	PrintMessage(HUD_PRINTTALK, pl:GetName() .. " has arrived")

	self:ShowTeam(pl)
	pl:ChatPrint("Welcome to Starship Troopers: Do you want to live for ever or what?!")

	pl:GameSync()
end

timer.Create("TauntCooldown", 2, 0, function() 
	for _, ply in ipairs(player.GetAll()) do
		if ply:Alive() then
			ply:SetNetVar("Taunt", false)
		end
	end
end)

timer.Create("AntlionAssaultUpdater", 10, 0, function()
	local soldiers = {}

	for _, npc in ipairs(ents.FindByClass("npc_citizen")) do
		table.insert(soldiers, npc)
	end

	local barney = ents.FindByClass("npc_barney")[1]
	local soldiersAlive = table.Count(soldiers)

	for _, antlion in ipairs(ents.FindByClass("npc_antlion")) do
		if not IsValid(antlion) then continue end

		antlion:Fire("Wake")

		if table.IsEmpty(soldiers) or soldiersAlive < 2 then
			if IsValid(barney) then
				antlion:UpdateEnemyMemory(barney, barney:GetPos())
				antlion:SetEnemy(barney)
			end
		else
			local rid = math.random(1, soldiersAlive)

			for id, marine in ipairs(soldiers) do
				if id ~= rid then continue end

				if IsValid(marine) then
					antlion:UpdateEnemyMemory(marine, marine:GetPos())
					antlion:SetEnemy(marine)
					antlion:AddEntityRelationship(marine, D_HT, 99)
				end
			end
		end

		if IsValid(barney) then
			antlion:AddEntityRelationship(barney, D_HT, 99)
		end
	end
end)

local ArmorNextThink = 0
function GM:PlayerPostThink(ply)
	local curtime = CurTime()

	if ArmorNextThink < curtime then
		if ply:Alive() and ply:Armor() < 100 and (ply.NextArmorRegen or 0) < curtime then
			ply:SetArmor( ply:Armor() + 1 )
		end

		ArmorNextThink = curtime + 0.06
	end

    if player_manager.GetPlayerClass(ply) == "player_engineer" then
        local heat = tonumber(ply:GetNetVar("Heat", 0))

		if (ply.DomNextThink or 0) > curtime then return end

        if heat >= 100 then
			if (ply.DomNextTone or 0) > curtime then return end

            ply.DomNextTone = curtime + 0.2
            ply:EmitSound("weapons/overheat_tone.wav", 30, 100, 1, CHAN_ITEM)
        end

        if heat < 120 then
            ply.DomNextThink = curtime + 0.017
        end

        if heat > 0 then
            ply:SetNetVar("Heat", heat - 1)
        end
    end
end

function GM:PlayerHurt(pl)
	pl.NextArmorRegen = (CurTime() + 3.5)
end

local NPCSoldiersModels = {
    "models/mobileinfantry/npc/mi_01.mdl",
    "models/mobileinfantry/npc/mi_02.mdl",
    "models/mobileinfantry/npc/mi_03.mdl",
    "models/mobileinfantry/npc/mi_04.mdl",
    "models/mobileinfantry/npc/mi_05.mdl",
    "models/mobileinfantry/npc/mi_06.mdl",
    "models/mobileinfantry/npc/mi_07.mdl",
    "models/mobileinfantry/npc/mi_08.mdl",
    "models/mobileinfantry/npc/mi_09.mdl"
}

hook.Add("OnEntityCreated", "ST_ReskinTroops", function(ent)
	local getcl = ent:GetClass()

	if getcl == "npc_citizen" then
		timer.Simple(0, function()
			if IsValid(ent) then
				ent:SetModel(NPCSoldiersModels[math.random(#NPCSoldiersModels)])
				ent:Give( math.random(1, 10) > 5 and "st_carbine_shotgun" or "st_carbine_short" )
				ent:SetPos(ent:GetPos() + Vector(0, 0, 10))
			end
		end)
	elseif getcl == "npc_barney" then
		timer.Simple(0, function()
			if IsValid(ent) then
				ent:SetModel("models/barneystormtrooper.mdl")
				ent:SetColor(Color(190, 190, 190))
				ent:Give( "st_carbine_shotgun" )
			end
		end)
	elseif getcl == "npc_antlion" then
		timer.Simple(0, function()
			local GAME_DIFFICULTY = GetConVar("stg_game_difficulty"):GetInt()
			local max = math.Round(math.abs(math.Remap(GAME_DIFFICULTY, 1, 3, -30, -10)))

			if IsValid(ent) and math.random(1, max) == max then
				local rand = math.Rand(1.25, 1.55)

				if ent:GetModel() == "models/antlion_worker.mdl" then
					ent:SetModelScale(rand * 1.15, 0.01)
				else
					ent:SetModelScale(rand, 0.01)
				end

				local newHP = math.Round(math.Clamp(ent:GetMaxHealth() * (rand * 8), 20, 1000))

				ent:SetMaxHealth(newHP)
				ent:SetHealth(newHP)

				ent:SetColor(Color(255, 160, 160))
				ent.giant = true
			end
		end)
	end
end)

function GM:GetDeathNoticeEntityName( ent )

	if ( isstring( ent ) ) then return ent end
	if ( !IsValid( ent ) ) then return nil end

	-- Some specific HL2 NPCs, just for fun
	if ( ent:GetClass() == "npc_citizen" ) then
		if ( ent:GetName() == "griggs" ) then return "#npc_citizen_griggs" end
		if ( ent:GetName() == "sheckley" ) then return "#npc_citizen_sheckley" end
		if ( ent:GetName() == "tobias" ) then return "#npc_citizen_laszlo" end
		if ( ent:GetName() == "stanley" ) then return "#npc_citizen_sandy" end
		if ( ent:GetName() == "Machine_Gunner" ) then return "Machine Gunner" end
		if ( ent:GetName() == "template_Marine_1" || ent:GetName() == "template_Marine_2" ) then return "Marine Soldier" end
	end

	if ent:GetClass() == "npc_barney" and ent:GetName() == "Lieutenant" then return "Lieutenant" end

	if ( ent:GetClass() == "npc_sniper" and ( ent:GetName() == "alyx_sniper" || ent:GetName() == "sniper_alyx" ) ) then return "#npc_alyx" end

	-- Custom vehicle and NPC names from spawnmenu
	if ( ent:IsVehicle() ) then
		local vehTable = list.GetEntry( "Vehicles", ent.VehicleName )
		if ( vehTable and vehTable.Name ) then return vehTable.Name end
	elseif ( ent:IsNPC() ) then
		local npcTable = list.GetEntry( "NPC", ent.NPCName )
		if ( npcTable and npcTable.Name ) then return npcTable.Name end
	end

	if ent:GetClass() == "npc_antlion" then
		if ent:GetModel() == "models/antlion_worker.mdl" then
			if ent.giant then
				return "Giant Antlion Worker"
			else
				return "Antlion Worker"
			end
		else
			if ent.giant then
				return "Major Antlion"
			else
				return "Antlion"
			end
		end
	end

	-- Fallback to old behavior
	return "#" .. ent:GetClass()

end

function GM:PlayerShouldTakeDamage(ply, attacker)
    if attacker:IsPlayer() then return false end
	if attacker:GetClass() == "npc_citizen" or attacker:GetClass() == "npc_barney" then return false end

    return true
end

local ST_NPCReward = {
    ["npc_antlion"] = 3,
    ["npc_antlionguard"] = 100,
    ["bug_tanker"] = 250
}

local female_snd = {
	"vo/npc/female01/gethellout.wav",
	"vo/npc/female01/gotone01.wav",
	"vo/npc/female01/gotone02.wav",
	"vo/npc/female01/headsup01.wav",
	"vo/npc/female01/headsup02.wav",
	"vo/npc/female01/runforyourlife01.wav",
	"vo/npc/female01/runforyourlife02.wav",
	"vo/npc/female01/likethat.wav",
	"vo/episode_1/npc/female01/cit_kill01.wav",
	"vo/episode_1/npc/female01/cit_kill02.wav",
	"vo/episode_1/npc/female01/cit_kill03.wav",
	"vo/episode_1/npc/female01/cit_kill04.wav",
	"vo/episode_1/npc/female01/cit_kill05.wav",
	"vo/episode_1/npc/female01/cit_kill06.wav",
	"vo/episode_1/npc/female01/cit_kill07.wav",
	"vo/episode_1/npc/female01/cit_kill08.wav",
	"vo/episode_1/npc/female01/cit_kill09.wav",
	"vo/episode_1/npc/female01/cit_kill10.wav",
	"vo/episode_1/npc/female01/cit_kill11.wav",
	"vo/episode_1/npc/female01/cit_kill12.wav",
	"vo/episode_1/npc/female01/cit_kill13.wav",
	"vo/episode_1/npc/female01/cit_kill14.wav",
	"vo/episode_1/npc/female01/cit_kill15.wav",
	"vo/episode_1/npc/female01/cit_kill16.wav",
	"vo/episode_1/npc/female01/cit_kill17.wav"
}

local male_snd = {
	"vo/npc/male01/gethellout.wav",
	"vo/npc/male01/gotone01.wav",
	"vo/npc/male01/gotone02.wav",
	"vo/npc/male01/headsup01.wav",
	"vo/npc/male01/headsup02.wav",
	"vo/npc/male01/runforyourlife01.wav",
	"vo/npc/male01/runforyourlife02.wav",
	"vo/npc/male01/likethat.wav",
	"vo/episode_1/npc/male01/cit_kill01.wav",
	"vo/episode_1/npc/male01/cit_kill02.wav",
	"vo/episode_1/npc/male01/cit_kill03.wav",
	"vo/episode_1/npc/male01/cit_kill04.wav",
	"vo/episode_1/npc/male01/cit_kill05.wav",
	"vo/episode_1/npc/male01/cit_kill06.wav",
	"vo/episode_1/npc/male01/cit_kill07.wav",
	"vo/episode_1/npc/male01/cit_kill08.wav",
	"vo/episode_1/npc/male01/cit_kill09.wav",
	"vo/episode_1/npc/male01/cit_kill10.wav",
	"vo/episode_1/npc/male01/cit_kill11.wav",
	"vo/episode_1/npc/male01/cit_kill12.wav",
	"vo/episode_1/npc/male01/cit_kill13.wav",
	"vo/episode_1/npc/male01/cit_kill14.wav",
	"vo/episode_1/npc/male01/cit_kill15.wav",
	"vo/episode_1/npc/male01/cit_kill16.wav",
	"vo/episode_1/npc/male01/cit_kill17.wav",
	"vo/episode_1/npc/male01/cit_kill19.wav",
	"vo/episode_1/npc/male01/cit_kill20.wav"
}

hook.Add("OnNPCKilled", "OnNPCKilled", function(npc, attacker)
	if attacker:IsPlayer() then
		local getclass = npc:GetClass()

        if ST_NPCReward[getclass] then
			if math.random(10) > 6 and not attacker:GetNetVar("Taunt", false) then
				local getgender = string.find(string.lower(attacker:GetModel()), "mobileinfantry/fmi")

				if getgender then
					attacker:EmitSound(Sound(female_snd[math.random(#female_snd)]))
				else
					attacker:EmitSound(Sound(male_snd[math.random(#male_snd)]))
				end

				attacker:SetNetVar("Taunt", true)
			end

			local bonus = npc:GetColor() == Color(255, 160, 160) and ST_NPCReward[getclass] * 5 or ST_NPCReward[getclass]
            attacker:SetNetVar("Credits", attacker:GetNetVar("Credits", 0) + bonus)
            attacker:AddFrags(bonus)
        end
    end
end)

local ST_FriendNPC = {
    ["npc_barney"] = true,
    ["npc_citizen"] = true
}

function GM:EntityTakeDamage(target, dmginfo)
    if ST_FriendNPC[target:GetClass()] then
        local attacker = dmginfo:GetAttacker()

        if attacker:IsPlayer() or ST_FriendNPC[attacker:GetClass()] then
            dmginfo:SetDamage(0)
        end
    end
end

function GM:PlayerDeath( pl )
	pl.NextSpawnTime = CurTime() + 3
end

hook.Add("DoPlayerDeath", "drop", function(pl, attacker)
	local getWeapon = pl:GetActiveWeapon()

    if IsValid(getWeapon) then
        local drop = ents.Create("item_droppedweapon")
        drop:SetModel(getWeapon:GetModel())
        drop:SetPos(getWeapon:GetPos())
        drop:SetAngles(getWeapon:GetAngles())
        drop:SetSolid(SOLID_VPHYSICS)
        drop:PhysicsInit(SOLID_VPHYSICS)
        drop:Spawn()
        drop:Activate()
        drop:SetMoveType(MOVETYPE_VPHYSICS)
        drop:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

        local phys = drop:GetPhysicsObject()
        if IsValid(phys) then
            phys:AddAngleVelocity(VectorRand() * math.Rand(20, 50))
            phys:AddVelocity(pl:GetVelocity())
            phys:Wake()
        end
    end
end)

function GM:PlayerDeathThink(pl)
    if pl.NextSpawnTime and pl.NextSpawnTime > CurTime() - 4 then return end

	if pl:Team() ~= TEAM_SPECTATOR then
		pl:Spawn()
	end
end

function GM:GetFallDamage(pl, speed)
    return math.max(0, math.ceil(0.2418 * speed - 141.75))
end

function GM:PlayerSwitchFlashlight()
    return false
end

function GM:PlayerUse(pl)
    if pl:Team() == TEAM_SPECTATOR then return false end

    return true
end

function GM:CanPlayerSuicide(pl)
    if pl:Team() == TEAM_SPECTATOR then return false end

    return true
end

function GM:PlayerDisconnected(pl)
    for _, v in pairs(ents.FindByClass("obj_*")) do
        if v:GetBuilder() == pl then
            v:Remove()
        end
    end
end

net.Receive("TeamSelect", function(length, pl)
    local variant = net.ReadInt(4)

    if variant == 1 then
        player_manager.SetPlayerClass(pl, "player_soldier")

        if pl:Team() == TEAM_SPECTATOR then
            pl:SetTeam(1)
            pl:Spawn()
			PrintMessage( HUD_PRINTTALK, pl:Name().. " assigned to team DEFENDERS" )
        else
            pl:SetTeam(1)

            if pl:Alive() then
                pl:Kill()
            end
        end

		pl:ChatPrint("*You will spawn as Soldier")
    elseif variant == 2 then
        player_manager.SetPlayerClass(pl, "player_engineer")

        if pl:Team() == TEAM_SPECTATOR then
            pl:SetTeam(2)
            pl:Spawn()
			PrintMessage( HUD_PRINTTALK, pl:Name().. " assigned to team DEFENDERS" )
        else
            pl:SetTeam(2)

            if pl:Alive() then
                pl:Kill()
            end
        end

		pl:ChatPrint("*You will spawn as Engineer")
    elseif variant == 3 then
        player_manager.SetPlayerClass(pl, "player_medic")

        if pl:Team() == TEAM_SPECTATOR then
            pl:SetTeam(1)
            pl:Spawn()
			PrintMessage( HUD_PRINTTALK, pl:Name().. " assigned to team DEFENDERS" )
        else
            pl:SetTeam(1)

            if pl:Alive() then
                pl:Kill()
            end
        end

		pl:ChatPrint("*You will spawn as Medic")
    elseif variant == 4 then
        player_manager.SetPlayerClass(pl, "player_sniper")

        if pl:Team() == TEAM_SPECTATOR then
            pl:SetTeam(1)
            pl:Spawn()
			PrintMessage( HUD_PRINTTALK, pl:Name().. " assigned to team DEFENDERS" )
        else
            pl:SetTeam(1)

            if pl:Alive() then
                pl:Kill()
            end
        end
		
		pl:ChatPrint("*You will spawn as Sniper")
    elseif variant == 5 then
        pl:SetTeam(TEAM_SPECTATOR)
        pl:KillSilent()
        pl:Spectate(OBS_MODE_ROAMING)
		PrintMessage( HUD_PRINTTALK, pl:Name().. " assigned to team SPECTATORS" )
    end
end)

local pm = FindMetaTable("Player")

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

	--RunConsoleCommand("ai_LOS_mode", "1")

	RunConsoleCommand("sbox_noclip", "0")
	RunConsoleCommand("sbox_godmode", "0")
	RunConsoleCommand("sv_kickerrornum", "0")

	local GAME_DIFFICULTY = GetConVar("stg_game_difficulty"):GetInt()

	RunConsoleCommand("sk_antlion_health", math.Round(math.Remap(GAME_DIFFICULTY, 1, 3, 20, 60)))
	RunConsoleCommand("sk_antlion_swipe_damage", math.Round(math.Remap(GAME_DIFFICULTY, 1, 3, 10, 20)))
	RunConsoleCommand("sk_antlion_jump_damage", math.Round(math.Remap(GAME_DIFFICULTY, 1, 3, 5, 15)))

	RunConsoleCommand("sv_allowcslua", "0")
	RunConsoleCommand("r_shadows", "0")
	RunConsoleCommand("r_drawmodeldecals", "0")

	RunConsoleCommand("cl_threaded_bone_setup", "0")
	
	MsgC(Color(100, 255, 100), "# Loading game settings successfully completed!\n")
end)

cvars_OnConVarChanged = cvars_OnConVarChanged or cvars.OnConVarChanged

function cvars.OnConVarChanged( name, oldVal, newVal )
    cvars_OnConVarChanged( name, oldVal, newVal )
    hook.Run( "OnConVarChanged", name, oldVal, newVal )
end

hook.Add("OnConVarChanged", "OnChangeGameDifficulty", function(name, oldValue, newValue)
    if name == "stg_game_difficulty" then
        RunConsoleCommand("sk_antlion_health", math.Round(math.Remap(newValue, 1, 3, 20, 60)))
		RunConsoleCommand("sk_antlion_swipe_damage", math.Round(math.Remap(newValue, 1, 3, 10, 20)))
		RunConsoleCommand("sk_antlion_jump_damage", math.Round(math.Remap(newValue, 1, 3, 5, 15)))
    end
end)


