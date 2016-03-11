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
	self.Player:SetModel('models/player/combine_soldier_prisonguard.mdl')
end

function PLAYER:Loadout()
	self.Player:RemoveAllAmmo()
	self.Player:StripWeapons()
	
	self.Player:GiveAmmo(200, "AirboatGun")
	
	self.Player:Give( "st_wrench" ) 
	self.Player:Give( "st_morita_assault_rifle" )
	self.Player:Give( "st_pda" )
	self.Player:Give( "st_binoculars" )

	self.Player:SelectWeapon('st_wrench')
end

player_manager.RegisterClass( "player_engineer", PLAYER, "player_default" )