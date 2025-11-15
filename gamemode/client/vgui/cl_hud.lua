////------ Starship Troopers Gamemode ------
///--------------- Hud Code --------------
//--------------------------------------

local draw = draw
local Color = Color
local surface = surface
local string = string
local math = math

local col = Color( 255, 80, 0, 255 )

killicon.Add("func_tank", "hud/killicons/func_tank", col)

killicon.Add("npc_antlionguard", "hud/killicons/npc_antlionguard", col)
killicon.Add("npc_antlion", "hud/killicons/npc_antlion", col)
killicon.AddAlias("npc_antlion_worker", "npc_antlion")

killicon.Add("st_carbine_shotgun", "hud/killicons/st_carbine_shotgun", col)
killicon.Add("st_carbine_short", "hud/killicons/st_carbine_short", col)
killicon.Add("st_carbine_sniper", "hud/killicons/st_carbine_sniper", col)
killicon.Add("st_morita_assault_rifle", "hud/killicons/st_morita_assault_rifle", col)
killicon.Add("st_morita_shotgun", "hud/killicons/st_morita_shotgun", col)

killicon.Add("grenade_spit", "hud/killicons/grenade_spit", col)
killicon.Add("env_explosion", "hud/killicons/env_explosion", col)
killicon.AddAlias("st_nade", "env_explosion")
killicon.AddAlias("tiramisu_fragnade", "env_explosion")
killicon.AddAlias("tiramisu_rpg_heat", "env_explosion")

killicon.Add("npc_helicopter", "hud/killicons/npc_helicopter", col)
killicon.Add("env_headcrabcanister", "hud/killicons/env_headcrabcanister", col)

killicon.Add("st_wrench", "hud/killicons/st_wrench", col)
killicon.Add("obj_sentrygun", "hud/killicons/obj_sentrygun", col)

surface.CreateFont( "st_timer_text", { font = "Roboto", size = 23, weight = 600, antialias = true } )

local interactivetips = CreateConVar("cl_intips", "0", {FCVAR_ARCHIVE}, "Enable/Disable Interactive tips.")

local middle = ScrW() / 2

local armor = Material("hud_elements/armor.png")
local shield = Material("icon16/shield.png")
local hp = Material("hud_elements/hp.png")
local heart = Material("icon16/heart.png")
local bug = Material("icon16/bug.png")

function GM:HUDDrawTargetID()

	local trace = LocalPlayer():GetEyeTrace()
	if ( !trace.Hit ) then return end
	if ( !trace.HitNonWorld ) then return end

	local text = "ERROR"
	local font = "ChatFont"
	local skip = false

	if trace.Entity:IsPlayer() then
		text = trace.Entity:Nick()
	elseif trace.Entity:IsNPC() then
		if trace.Entity:GetClass() == "npc_citizen" then
			text = "Marine Soldier"
		elseif trace.Entity:GetClass() == "npc_barney" then
			text = "Lieutenant"
			skip = true
		else
			return
		end
	else
		return
	end

	surface.SetFont( font )
	local w, h = surface.GetTextSize( text )

	local MouseX, MouseY = input.GetCursorPos()

	if ( MouseX == 0 && MouseY == 0 || !vgui.CursorVisible() ) then

		MouseX = ScrW() / 2
		MouseY = ScrH() / 2

	end

	local x = MouseX
	local y = MouseY

	x = x - w / 2
	y = y + 30

	-- The fonts internal drop shadow looks lousy with AA on
	draw.SimpleText( text, font, x + 1, y + 1, Color( 0, 0, 0, 120 ) )
	draw.SimpleText( text, font, x + 2, y + 2, Color( 0, 0, 0, 50 ) )
	draw.SimpleText( text, font, x, y, self:GetTeamColor( trace.Entity ) )

	if skip then return end

	y = y + h + 5

	-- Draw the health
	local absolutehealth = math.Remap(trace.Entity:Health(), 0, trace.Entity:GetMaxHealth(), 0, 100)
	text = math.Round(absolutehealth) .. "%"
	font = "ChatFont"

	surface.SetFont( font )
	w, h = surface.GetTextSize( text )
	x = MouseX - w / 2

	draw.SimpleText( text, font, x + 1, y + 1, Color( 0, 0, 0, 120 ) )
	draw.SimpleText( text, font, x + 2, y + 2, Color( 0, 0, 0, 50 ) )
	draw.SimpleText( text, font, x, y, self:GetTeamColor( trace.Entity ) )

end

hook.Add("HUDPaint", "HUDDrawPaint", function()
	if LocalPlayer():Team() == TEAM_SPECTATOR then
		if not interactivetips:GetBool() then
			draw.RoundedBox(8, middle - 90, 120, 180, 56, Color(41, 128, 185, 90))
			draw.SimpleTextOutlined("Spectator Mode", "DermaLarge", middle, 114, Color(255, 255, 255, 195), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, Color(74, 74, 74))
			draw.SimpleTextOutlined("To change class press F2", "ChatFont", middle, 140, Color(255, 255, 255, 185), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, Color(74, 74, 74))
			draw.SimpleTextOutlined("or write in chat /class", "ChatFont", middle, 170, Color(255, 255, 255, 185), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, Color(74, 74, 74))
		end

		return
	end

	local TimeLeft = GAMEMODE:GetGameState() == STATE_WAITING_FOR_PLAYERS and GAMEMODE.RoundLength:GetInt() or math.Clamp(GetGlobalInt("TimeLeft", 0), 0, GAMEMODE.RoundLength:GetInt())

	draw.RoundedBox(0, middle - 40, 14, 80, 32, Color(41, 128, 185, 180))
	draw.RoundedBox(0, middle - 37, 48, 72, 12, Color(41, 128, 185, 180))
	
	local Timeformat = string.ToMinutesSeconds(TimeLeft)

	draw.SimpleText((TimeLeft<0 and "00:00" or Timeformat), "DermaLarge", middle, 31, (TimeLeft<=25 and Color(210, 10, 90, 255) or color_white), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.SimpleText(("Wave " .. GAMEMODE:GetRound() .. " / " .. GAMEMODE.RoundLimit:GetInt()), "DermaDefaultBold", middle, 53, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	// Timer text \\
	if GAMEMODE:GetGameState() == STATE_ROUND_OVER then
		draw.SimpleTextOutlined(GAMEMODE:GetRound() == GAMEMODE.RoundLimit:GetInt() and "Final Wave Has End, New Map Vote Start!" or "Wave End", "st_timer_text", middle, 69, Color(255, 255, 255, 155) , TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1.4, Color(0,0,0))
	elseif GAMEMODE:GetGameState() == STATE_WAITING_FOR_PLAYERS then
		draw.SimpleTextOutlined("Setup", "st_timer_text", middle, 69, Color(255, 255, 255, 155), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1.4, Color(0,0,0))	
	end

	for _, v in pairs(ents.FindByClass("bug_tanker")) do
		if IsValid(v) and v:Health() > 0 then
			local hpbar = math.Clamp(v:Health() * 0.0262, 0, 418)

			draw.RoundedBox(0, middle - 240, 90, 480, 40, Color(17, 17, 17, 100))
			surface.SetDrawColor(Color(17, 117, 200, 255))
			surface.DrawOutlinedRect(middle - 240, 90, 480, 40)
			
			
			
			
			
			draw.RoundedBox(0, middle - 190, 100, 420, 20, Color(128, 128, 128, 200))
			draw.RoundedBox(0, middle - 189, 101, hpbar, 18, Color(165, 60, 60, 180))

			surface.SetDrawColor(color_white)
			surface.SetMaterial(bug)
			surface.DrawTexturedRect(middle - 220, 103, 16, 16)
		end
	end

	if not LocalPlayer():Alive() then return end

	local granades = LocalPlayer():GetAmmoCount("Grenade")
	local credits = tonumber(LocalPlayer():GetNetVar("Credits", 0))

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

		draw.SimpleTextOutlined("Cr:", "DermaLarge", 108, 130, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 1, Color(74, 74, 74))
		draw.SimpleTextOutlined(credits, "DermaLarge", 120, 130, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM, 1, Color(74, 74, 74))

	// Weapon \\

	if !interactivetips:GetBool() and granades >= 1 then
		local cin = 0.5 + math.sin(SysTime()) * 0.5
		
		draw.RoundedBox(0, ScrW()/1.52, ScrH()/1.2, 200, 34, Color(65, 75, 165, cin * 90))
		draw.SimpleText("Press: *USE* + *Primary attack*", "CenterPrintText", ScrW()/1.243, ScrH()/1.17, Color(150, 150, 150, cin * 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
		draw.SimpleText("to trow a granede", "CenterPrintText", ScrW()/1.29, ScrH()/1.14, Color(150, 150, 150, cin * 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
	end
	
	draw.SimpleTextOutlined("Granades: " .. granades, "DermaLarge", ScrW()/1.143, ScrH()/1.13, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, Color(74, 74, 74))

	-- Ammo
	local wep = LocalPlayer():GetActiveWeapon()

	if IsValid(wep) then
		if wep.Clip1 and wep:Clip1() >= 0 then
			draw.SimpleTextOutlined(wep:Clip1(), "DermaLarge", ScrW() / 1.145, ScrH() - 41, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 1.5, Color(74, 74, 74))
			draw.SimpleTextOutlined(" /" .. LocalPlayer():GetAmmoCount(wep:GetPrimaryAmmoType()), "DermaLarge", ScrW() / 1.145, ScrH() - 35, Color(161, 161, 161), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM, 1, Color(74, 74, 74))
		end

		if wep.Clip2 and wep:Clip2() >= 0 then
			draw.SimpleTextOutlined(wep:Clip2(), "DermaLarge", ScrW() / 1.1, ScrH() - 41, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 1.5, Color(74, 74, 74))
			draw.SimpleTextOutlined(" /" .. LocalPlayer():GetAmmoCount(wep:GetSecondaryAmmoType()), "DermaLarge", ScrW() / 1.1, ScrH() - 35, Color(161, 161, 161), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM, 1, Color(74, 74, 74))
		end
	end

	// Engi Hud \\
	if player_manager.GetPlayerClass( LocalPlayer() ) == "player_engineer" then
		local heat = tonumber(LocalPlayer():GetNetVar("Heat", 0))
		local metal = LocalPlayer():GetAmmoCount("AirboatGun")

		-- Buildings
		for _, v in pairs(ents.FindByClass("obj_*")) do
			if not v.Building or v:GetBuilder() ~= LocalPlayer() then continue end

			if v:GetClass() == "obj_sentrygun" then
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
			elseif v:GetClass() == "obj_dispenser" then
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

		draw.SimpleTextOutlined("Metal: " .. metal, "DermaLarge", ScrW() / 1.14, ScrH() / 1.2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, Color(74, 74, 74))
		draw.DrawText("*c", "Trebuchet24", ScrW() / 1.43, ScrH() / 1.05, Color(160, 160, 255, 180), TEXT_ALIGN_CENTER)

		draw.RoundedBox(4, ScrW() / 1.45, ScrH() / 1.07, 256, 16, Color(57, 57, 146, 180))
		draw.RoundedBox(2, ScrW() / 1.445, ScrH() / 1.068, heat * 2, 12, Color(186, 186, 186, 180))
		draw.RoundedBox(4, ScrW() / 1.160, ScrH() / 1.07, 8, 16, Color(210, 30, 30, 232))
	end
end)