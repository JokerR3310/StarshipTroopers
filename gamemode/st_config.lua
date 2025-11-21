///////////////////////////////////////////////////////////////////////
//					 Starship Troopers: Config File					 //
//							  01/08/2015					 		 //
///////////////////////////////////////////////////////////////////////

ST_AmmoList = {

	SMG1_Grenade = {
		label = "Grenade Round",
		model = "models/Items/AR2_Grenade.mdl",
		desc = "One Grenade Round.",
		amount = 1,
		allowedfor = {
			["player_engineer"] = true
		},
		price = 10
	},

	SMG1 = {
		label = "SMG Ammo",
		model = "models/weapons/naboje/mk2_ammoclip.mdl",
		desc = "A box of (30) SMG Ammo.",
		amount = 30,
		allowedfor = {
			["player_soldier"] = true,
			["player_medic"] = true,
			["player_sniper"] = true
		},
		price = 4
	},

	RPG_Round = {
		label = "RPG Round",
		model = "models/weapons/w_missile.mdl",
		desc = "Ammo for Tactical Launcher.",
		amount = 1,
		allowedfor = {
			["player_soldier"] = true,
		},
		price = 14
	},

	XBowBolt = {
		label = "Railgun Ammo",
		model = "models/weapons/naboje/railclip.mdl",
		desc = "A box of (6) Railgun Ammo.",
		amount = 6,
		allowedfor = {
			["player_sniper"] = true,
		},
		price = 10
	},

	Buckshot = {
		label = "Buckshot",
		model = "models/Items/BoxBuckshot.mdl",
		desc = "A box of (20) Shotgun Shells.",
		amount = 20,
		allowedfor = {
			["player_soldier"] = true,
			["player_engineer"] = true,
			["player_medic"] = true
		},
		price = 4
	},

	Grenade = {
		label = "Hand Grenade",
		model = "models/Items/grenadeAmmo.mdl",
		desc = "One hand grenade.",
		amount = 1,
		allowedfor = {
			["player_soldier"] = true,
			["player_engineer"] = true,
			["player_medic"] = true,
			["player_sniper"] = true
		},
		price = 12
	},

	AirboatGun = {
		label = "Some Metal",
		model = "models/Items/CrossbowRounds.mdl",
		desc = "Small amount of metal.",
		amount = 15,
		allowedfor = {
			["player_engineer"] = true
		},
		price = 10
	}

}

ST_WeaponsList = {

	st_tactical_launcher = {
		label = "MK55 Tactical Launcher",
		model = "models/ryan7259/starshiptroopers/weapons/w_m136_launcher.mdl",
		desc = "Tactical rocket launcher.",
		allowedfor = {
			["player_soldier"] = true,
		},
		price = 300
	},

	st_morita_shotgun = {
		label = "Morita MK II Shotgun",
		model = "models/ryan7259/starshiptroopers/weapons/w_morita_shotgun.mdl",
		desc = "Automatic shotgun.",
		allowedfor = {
			["player_soldier"] = true,
			["player_engineer"] = true,
			["player_medic"] = true
		},
		price = 150
	},

	weapon_physcannon = {
		label = "Phys Cannon",
		model = "models/weapons/w_physics.mdl",
		desc = "Physics Cannon.",
		allowedfor = {
			["player_engineer"] = true
		},
		price = 30
	},

	st_sniper_railgun = {
		label = "Morita Mk3 Railgun",
		model = "models/ryan7259/starshiptroopers/weapons/w_railgun.mdl",
		desc = "Powerfull railgun.",
		allowedfor = {
			["player_sniper"] = true,
		},
		price = 200
	}

}

MsgC( Color(100, 255, 100), "Items config file successfully loaded\n" )