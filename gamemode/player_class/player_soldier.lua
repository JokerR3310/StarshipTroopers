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

function PLAYER:SetModel()
	self.Player:SetModel('models/player/deltaforce/m0'..math.random(1, 8)..'.mdl')
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