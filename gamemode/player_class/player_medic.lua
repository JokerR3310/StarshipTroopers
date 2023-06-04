DEFINE_BASECLASS( "player_default" )

local PLAYER = {} 

PLAYER.StartArmor			= 100
PLAYER.WalkSpeed 			= 160
PLAYER.RunSpeed				= 235
PLAYER.Model				= ""
PLAYER.JumpPower			= 210
PLAYER.DropWeaponOnDie 		= false
PLAYER.TeammateNoCollide	= false

function PLAYER:Spawn()
end

local MedicModels = {
    "models/mobileinfantry/fmi_m_01.mdl",
    "models/mobileinfantry/fmi_m_02.mdl",
    "models/mobileinfantry/fmi_m_03.mdl",
    "models/mobileinfantry/fmi_m_04.mdl",
    "models/mobileinfantry/fmi_m_06.mdl",
    "models/mobileinfantry/fmi_m_07.mdl",
    "models/mobileinfantry/mi_m_02.mdl",
    "models/mobileinfantry/mi_m_03.mdl",
    "models/mobileinfantry/mi_m_04.mdl",
    "models/mobileinfantry/mi_m_05.mdl",
    "models/mobileinfantry/mi_m_06.mdl",
    "models/mobileinfantry/mi_m_07.mdl",
    "models/mobileinfantry/mi_m_08.mdl",
    "models/mobileinfantry/mi_m_09.mdl"
}

function PLAYER:SetModel()
	self.Player:SetModel(MedicModels[math.random(#MedicModels)])
end

function PLAYER:Loadout()
	self.Player:RemoveAllAmmo()
	self.Player:StripWeapons()

	self.Player:Give( "weapon_crowbar" ) 
	self.Player:Give( "st_carbine_short" )
	self.Player:Give( "st_medkit" )
	self.Player:Give( "st_binoculars" )
	
	self.Player:SelectWeapon('st_carbine_short')
end

player_manager.RegisterClass( "player_medic", PLAYER, "player_default" )