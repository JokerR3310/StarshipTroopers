///////////////////////////////////////////////////////////////////////
//					 Starship Troopers: Config File					 //
//							  01/08/2015					 		 //
///////////////////////////////////////////////////////////////////////

ST_AmmoList = {
	["SMG_G"] = {
		["label"] = "Grenade Round",
		["model"] = "models/Items/AR2_Grenade.mdl",
		["desc"] = "One Grenade Round.",
		["amount"] = "1",
		["ammotype"] = "SMG1_Grenade",
		["allowedfor"] = {"player_engineer"},
		["price"] = "10"
	},
	["SMG"] = {
		["label"] = "SMG Ammo",
		["model"] = "models/weapons/naboje/mk2_ammoclip.mdl",
		["desc"] = "A box of (30) SMG Ammo.",
		["amount"] = "30",
		["ammotype"] = "SMG1",
		["allowedfor"] = {"player_soldier", "player_medic", "player_sniper"},
		["price"] = "4"
	},
	["RPG"] = {
		["label"] = "RPG Round",
		["model"] = "models/weapons/w_missile.mdl",
		["desc"] = "Ammo for Tactical Launcher.",
		["amount"] = "1",
		["ammotype"] = "RPG_Round",
		["allowedfor"] = {"player_soldier"},
		["price"] = "14"
	},
	["CROSSBOW"] = {
		["label"] = "Railgun Ammo",
		["model"] = "models/weapons/naboje/railclip.mdl",
		["desc"] = "A box of (6) Railgun Ammo.",
		["amount"] = "6",
		["ammotype"] = "XBowBolt",
		["allowedfor"] = {"player_sniper"},
		["price"] = "10"
	},
	["SHOTGUN"] = {
		["label"] = "Buckshot",
		["model"] = "models/Items/BoxBuckshot.mdl",
		["desc"] = "A box of (20) Shotgun Shells.",
		["amount"] = "20",
		["ammotype"] = "Buckshot",
		["allowedfor"] = {"player_soldier", "player_engineer", "player_medic"},
		["price"] = "4"
	},
	["GRENADE"] = {
		["label"] = "Hand Grenade",
		["model"] = "models/Items/grenadeAmmo.mdl",
		["desc"] = "One hand grenade.",
		["amount"] = "1",
		["ammotype"] = "Grenade",
		["allowedfor"] = {"player_soldier", "player_engineer", "player_medic", "player_sniper"},
		["price"] = "12"
	},
	["METAL"] = {
		["label"] = "Some Metal",
		["model"] = "models/Items/CrossbowRounds.mdl",
		["desc"] = "Small amount of metal.",
		["amount"] = "15",
		["ammotype"] = "AirboatGun",
		["allowedfor"] = {"player_engineer"},
		["price"] = "10"
	}
}

ST_WeaponList = {
	["ROCKETL"] = {
		["label"] = "MK55 Tactical Launcher",
		["model"] = "models/ryan7259/starshiptroopers/weapons/w_m136_launcher.mdl",
		["desc"] = "Tactical rocket launcher.",
		["weapontype"] = "st_tactical_launcher",
		["allowedfor"] = {"player_soldier"},
		["price"] = "300"
	},
	["SHOTGUN_SOLDI"] = {
		["label"] = "Morita MK II Shotgun",
		["model"] = "models/ryan7259/starshiptroopers/weapons/w_morita_shotgun.mdl",
		["desc"] = "Automatic shotgun.",
		["weapontype"] = "st_morita_shotgun",
		["allowedfor"] = {"player_soldier", "player_engineer", "player_medic"},
		["price"] = "150"
	},
	["physcannon"] = {
		["label"] = "Phys Cannon",
		["model"] = "models/weapons/w_physics.mdl",
		["desc"] = "Physics Cannon.",
		["weapontype"] = "weapon_physcannon",
		["allowedfor"] = {"player_engineer"},
		["price"] = "30"
	},
	["RAILGUN"] = {
		["label"] = "Morita Mk3 Railgun",
		["model"] = "models/ryan7259/starshiptroopers/weapons/w_railgun.mdl",
		["desc"] = "Powerfull railgun.",
		["weapontype"] = "st_sniper_railgun",
		["allowedfor"] = {"player_sniper"},
		["price"] = "200"
	}
}

MsgC( Color( 100, 255, 100 ), "Config file successfully loaded\n" )