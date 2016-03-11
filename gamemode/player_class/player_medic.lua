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

function PLAYER:SetModel()
	self.Player:SetModel('models/player/group03m/male_0'..math.random(1, 9)..'.mdl')
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