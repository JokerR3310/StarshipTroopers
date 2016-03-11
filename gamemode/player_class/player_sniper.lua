DEFINE_BASECLASS( "player_default" )

local PLAYER = {} 

PLAYER.StartArmor			= 100
PLAYER.WalkSpeed 			= 150
PLAYER.RunSpeed				= 225
PLAYER.Model				= ""
PLAYER.JumpPower			= 210
PLAYER.DropWeaponOnDie 		= false
PLAYER.TeammateNoCollide	= false

function PLAYER:Spawn()
end

function PLAYER:SetModel()
	self.Player:SetModel('models/player/group03/male_0'..math.random(1, 9)..'.mdl')
end

function PLAYER:Loadout()
	self.Player:RemoveAllAmmo()
	self.Player:StripWeapons()
	
	self.Player:Give( "weapon_crowbar" )
	self.Player:Give( "st_carbine_sniper" ) 
	self.Player:Give( "st_binoculars" )
	
	self.Player:SelectWeapon('st_carbine_sniper')
end

player_manager.RegisterClass( "player_sniper", PLAYER, "player_default" )