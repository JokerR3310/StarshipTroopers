////------ Starship Troopers Gamemode ------
///--------------- Hud Code --------------
//--------------------------------------

local interactivetips = CreateConVar("cl_intips", "0", {FCVAR_ARCHIVE}, "Enable/Disable Interactive tips.")

local middle = ScrW()/2

local armor = Material("hud_elements/armor.png")
local shield = Material("icon16/shield.png")
local hp = Material("hud_elements/hp.png")
local heart = Material("icon16/heart.png")

function GM:HUDPaint() 
	if not LocalPlayer() or not IsValid(LocalPlayer()) then return end
	
	if LocalPlayer():Team() == TEAM_SPECTATOR then
		if !interactivetips:GetBool() then
			draw.RoundedBox(8, middle - 90, 120, 180, 56, Color(41, 128, 185, 90))
			draw.SimpleTextOutlined("Spectator Mode", "DermaLarge", middle, 114, Color(255,255,255,195), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, Color(74, 74, 74))
			draw.SimpleTextOutlined("To change class press F2", "ChatFont", middle, 140, Color(255,255,255,185), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, Color(74, 74, 74))
			draw.SimpleTextOutlined("or write in chat /class", "ChatFont", middle, 170, Color(255,255,255,185), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, Color(74, 74, 74))
		end
	return end

	local TimeLeft = GAMEMODE:GetGameState() == STATE_WAITING_FOR_PLAYERS and GAMEMODE.RoundLength:GetInt() or math.Clamp(GetGlobalInt("TimeLeft", 0), 0, GAMEMODE.RoundLength:GetInt())

	draw.RoundedBox(0, middle - 40, 14, 80, 32, Color(41, 128, 185, 180))
	
	local Timeformat = string.ToMinutesSeconds(TimeLeft)
	--local Timeformat = string.FormattedTime( TimeLeft, "%2i:%02i" )

	draw.SimpleText((TimeLeft<0 and "00:00" or Timeformat), "DermaLarge", middle, 31, (TimeLeft<=25 and Color(210, 10, 90, 255) or color_white), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	
	// Timer text \\
	if GAMEMODE:GetGameState() == STATE_ROUND_OVER then
		draw.SimpleTextOutlined(GAMEMODE:GetRound() == GAMEMODE.RoundLimit:GetInt() and "Final Wave Has End, New Map Vote Start!" or "Wave End", "st_timer_text", middle, 58, Color(255, 255, 255, 155) , TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1.4, Color(0,0,0))
	elseif GAMEMODE:GetGameState() == STATE_WAITING_FOR_PLAYERS then
		draw.SimpleTextOutlined("Setup", "st_timer_text", middle, 58, Color(255, 255, 255, 155), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1.4, Color(0,0,0))	
	end
	
	if not LocalPlayer():Alive() then return end

	local granades = LocalPlayer():GetAmmoCount("Grenade")
	local metal = LocalPlayer():GetAmmoCount("AirboatGun")
	local points = LocalPlayer():GetNWInt("cash")
	local heat = LocalPlayer():GetNWInt("heat")

	// Left Side \\

		// Health & Armor \\
		draw.RoundedBox(0, 70, 18, 236, 66, Color(17, 17, 17, 200))

		surface.SetDrawColor(Color(17, 117, 200, 255))
		surface.DrawOutlinedRect(-1, 33, 71, 36)
		surface.DrawOutlinedRect(69, 18, 237, 66)

		surface.SetDrawColor(color_white)
		
		if LocalPlayer():Armor() > 0 then
			surface.SetMaterial(armor)
			surface.DrawTexturedRect(76, 24, LocalPlayer():Armor() * 2, 20)
		end

		surface.SetMaterial(shield)
		surface.DrawTexturedRect(282.5, 26, 16, 16)

		surface.SetMaterial(hp)
		surface.DrawTexturedRect(76, 56, LocalPlayer():Health() * 2, 20)

		surface.SetMaterial(heart)
		surface.DrawTexturedRect(282.5, 58, 16, 16)

		// Money \\
		draw.RoundedBox(0, 70, 94, 41, 40, Color(17, 17, 17, 180))

		surface.SetDrawColor(Color(17, 117, 200, 255))
		surface.DrawOutlinedRect(-1, 100, 71, 30)
		surface.DrawOutlinedRect(69, 94, 42, 40)

		draw.SimpleTextOutlined("Ps:", "DermaLarge", 110, 130, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 1, Color(74, 74, 74))
		draw.SimpleTextOutlined(points, "DermaLarge", 120, 130, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM, 1, Color(74, 74, 74))

		// Building \\
		for _, v in pairs(ents.FindByClass("obj_sentrygun")) do
			if v.ClientInitialized and v:GetBuilder() == LocalPlayer() then
				draw.RoundedBox(4, 10, 150, 160, 60, Color(17, 17, 17, 180))
				-- Health --
					draw.RoundedBox(0, 16, 155, 18, 50, Color(65, 65, 65, 250))
					draw.RoundedBox(0, 16, 155, 18, v:GetLevel() == 1 and v:Health() / 3 or v:Health() / 3.6, Color(225, 105, 105, 250))
					draw.SimpleTextOutlined("+", "DermaLarge", 32.3, 195, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 1, Color(74, 74, 74))
				-- Ammo --
				if v:GetState() == 3 then
					draw.SimpleTextOutlined("Shells:", "Default", 74, 165, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 1, Color(74, 74, 74))
		
					draw.RoundedBox(0, 40, 166, 120, 12, Color(65, 65, 65, 250))
					draw.RoundedBox(0, 40, 166, v:GetAmmo1Percentage() * 120, 12, Color(225, 225, 225, 200))
				-- Progress --
					if v:GetLevel() == 1 then
						draw.SimpleTextOutlined("Upgrade:", "Default", 85, 191, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 1, Color(74, 74, 74))

						draw.RoundedBox(0, 40, 192, 120, 12, Color(65, 65, 65, 250))
						draw.RoundedBox(0, 40, 192, v:GetMetal() * 0.6, 12, Color(225, 225, 225, 200))
					end
				else 
					draw.SimpleTextOutlined("Building...", "Default", 90, 175, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 1, Color(74, 74, 74))
		
					draw.RoundedBox(0, 40, 178, 120, 12, Color(65, 65, 65, 250))
					draw.RoundedBox(0, 40, 178, v:GetBuildProgress() * 120, 12, Color(225, 225, 225, 200))
				end
			end
		end
		
		for _, v in pairs(ents.FindByClass("obj_dispenser")) do
			if v.ClientInitialized and v:GetBuilder() == LocalPlayer() then
				draw.RoundedBox(4, 10, 220, 160, 60, Color(17, 17, 17, 180))
				-- Health --
					draw.RoundedBox(0, 16, 225, 18, 50, Color(65, 65, 65, 250))
					if v:GetLevel() == 1 then
						draw.RoundedBox(0, 16, 225, 18, v:Health() / 3, Color(225, 105, 105, 250))
					else
						draw.RoundedBox(0, 16, 225, 18, v:GetLevel() == 2 and v:Health() / 3.6 or v:Health() / 4.3, Color(225, 105, 105, 250))
					end
					draw.SimpleTextOutlined("+", "DermaLarge", 32.3, 266, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 1, Color(74, 74, 74))
				-- Progress --
				if v:GetState() == 3 then
					if v:GetLevel() <= 2 then
						draw.SimpleTextOutlined("Upgrade:", "Default", 85, 232, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 1, Color(74, 74, 74))

						draw.RoundedBox(0, 40, 235, 120, 12, Color(65, 65, 65, 250))
						draw.RoundedBox(0, 40, 235, v:GetMetal() * 0.6, 12, Color(225, 225, 225, 200))
					end
					draw.RoundedBox(0, 40, 255, 120, 16, Color(65, 65, 65, 250))
					draw.RoundedBox(0, 40, 255, v:GetAmmoPercentage() * 120, 16, Color(225, 225, 225, 200))
				else 
					draw.SimpleTextOutlined("Building...", "Default", 90, 246, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 1, Color(74, 74, 74))
		
					draw.RoundedBox(0, 40, 248, 120, 12, Color(65, 65, 65, 250))
					draw.RoundedBox(0, 40, 248, v:GetBuildProgress() * 120, 12, Color(225, 225, 225, 200))
				end
			end
		end
		
	// Right Side \\

	// Weapon \\

	if !interactivetips:GetBool() and granades >= 1 then
		local cin = 0.5 + math.sin(SysTime()) * 0.5
		
		draw.RoundedBox(0, ScrW()/1.52, ScrH()/1.2, 200, 34, Color(65, 75, 165, cin * 90))
		draw.SimpleText("Press: *USE* + *Primary attack*", "CenterPrintText", ScrW()/1.243, ScrH()/1.17, Color(150, 150, 150, cin * 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
		draw.SimpleText("to trow a granede", "CenterPrintText", ScrW()/1.29, ScrH()/1.14, Color(150, 150, 150, cin * 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
	end
	
	draw.SimpleTextOutlined("Granades: "..granades, "DermaLarge", ScrW()/1.143, ScrH()/1.13, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, Color(74, 74, 74))

	// Ammo \\	
	if IsValid(LocalPlayer():GetActiveWeapon()) and LocalPlayer():GetActiveWeapon().Clip1 and LocalPlayer():GetActiveWeapon():Clip1() >= 0 then
	   local wep = LocalPlayer():GetActiveWeapon()
		draw.SimpleTextOutlined(wep:Clip1(), "DermaLarge", ScrW()/1.145, ScrH() - 41, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 1.5, Color(74, 74, 74))
		draw.SimpleTextOutlined(" /"..LocalPlayer():GetAmmoCount(wep:GetPrimaryAmmoType()), "DermaLarge", ScrW()/1.145, ScrH() - 35, Color(161, 161, 161), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM, 1, Color(74, 74, 74))
	end

	// Engi Hud \\
	if player_manager.GetPlayerClass( LocalPlayer() ) == "player_engineer" then
		draw.SimpleTextOutlined("Metal: "..metal, "DermaLarge", ScrW()/1.14, ScrH()/1.2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, Color(74, 74, 74))
		
		draw.DrawText("*c:", "Trebuchet24", ScrW() / 1.43, ScrH() / 1.05, Color(160, 160, 255, 180), TEXT_ALIGN_CENTER)
		draw.RoundedBox(4, ScrW() / 1.45, ScrH() / 1.07, ScreenScale(129), ScreenScale(8), Color(57, 57, 146, 180))
		draw.RoundedBox(2, ScrW() / 1.445, ScrH() / 1.066, ScreenScale(heat + 1), ScreenScale(6), Color(186, 186, 186, 180))
		draw.RoundedBox(4, ScrW() / 1.14, ScrH() / 1.066, ScreenScale(8), ScreenScale(6), Color(210, 30, 30, 232))
	end
end