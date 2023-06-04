DEFINE_BASECLASS( "player_default" )

local PLAYER = {} 

PLAYER.StartArmor			= 100
PLAYER.WalkSpeed 			= 140
PLAYER.RunSpeed				= 215
PLAYER.Model				= ""
PLAYER.JumpPower			= 180
PLAYER.DropWeaponOnDie 		= false
PLAYER.TeammateNoCollide	= false

function PLAYER:Spawn()
end

local SoldiersModels = {
    "models/mobileinfantry/fmi_01.mdl",
    "models/mobileinfantry/fmi_02.mdl",
    "models/mobileinfantry/fmi_03.mdl",
    "models/mobileinfantry/fmi_04.mdl",
    "models/mobileinfantry/fmi_06.mdl",
    "models/mobileinfantry/fmi_07.mdl",
    "models/mobileinfantry/mi_02.mdl",
    "models/mobileinfantry/mi_03.mdl",
    "models/mobileinfantry/mi_04.mdl",
    "models/mobileinfantry/mi_05.mdl",
    "models/mobileinfantry/mi_06.mdl",
    "models/mobileinfantry/mi_07.mdl",
    "models/mobileinfantry/mi_08.mdl",
    "models/mobileinfantry/mi_09.mdl"
}

function PLAYER:SetModel()
	self.Player:SetModel(SoldiersModels[math.random(#SoldiersModels)])
end

function PLAYER:Loadout()
	self.Player:RemoveAllAmmo()
	self.Player:StripWeapons()

	self.Player:Give( "weapon_crowbar" )
	self.Player:Give( "st_carbine_shotgun" )
	self.Player:Give( "st_binoculars" )
	
	self.Player:SelectWeapon('st_carbine_shotgun')
end

player_manager.RegisterClass( "player_soldier", PLAYER, "player_default" )