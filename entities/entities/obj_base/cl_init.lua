include("shared.lua")

function ENT:Initialize()
	self:InstallDataTable()
	self:SetupDataTables() -- we need to do this manually because SNPCs do not support clientside scripts
end

if game.SinglePlayer() then
	net.Receive("SinglePlayerHealthNetwork", function()
		local entity = net.ReadEntity()
		local health = net.ReadUInt(18)

		if IsValid(entity) then
			entity:SetHealth(health)
		end
	end)
end

local Scrw_x, Scrw_y = ScrW()/2, ScrH()/2
local function DrawBuilingsInfo()
	if LocalPlayer():GetEyeTrace().Entity.Building then

		local building = LocalPlayer():GetEyeTrace().Entity
		local dist = LocalPlayer():GetPos():Distance(building:GetPos())
		local printname = building.PrintName
		local owner = building:GetBuilder():GetName()
		local health = building:Health()
		local level = building:GetLevel()
		local progress = building:GetMetal()
		
		if dist < 500 then
			local Alpha = math.Clamp(280 - (0.70 * dist), 0, 225)
			draw.RoundedBox(4, Scrw_x - 150, Scrw_y + 20, 300, 44, Color(35, 35, 35, Alpha))
			draw.RoundedBox(4, Scrw_x - 160, Scrw_y + 50, 44, 24, Color(235, 135, 35, Alpha))
			draw.SimpleText(health, "CloseCaption_Normal", Scrw_x - 138, Scrw_y + 75, Color( 255, 255, 255, Alpha ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
			draw.SimpleText(printname.." Built by "..owner, "ChatFont", Scrw_x, Scrw_y + 43, Color( 255, 255, 255, Alpha ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
			if printname == "Dispenser" then
				draw.SimpleText(level < 3 and "( Level "..level.." ) Upgrade Progress: "..progress.." / 200" or "( Level 3 ) Maximum upgrade", "Trebuchet18", Scrw_x, Scrw_y + 62, Color( 39, 200, 96, Alpha ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
			else
				draw.SimpleText(level < 2 and "( Level "..level.." ) Upgrade Progress: "..progress.." / 200" or "( Level 2 ) Maximum upgrade", "Trebuchet18", Scrw_x, Scrw_y + 62, Color( 39, 200, 96, Alpha ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
			end
		end
	end
end		
hook.Add("HUDPaint", "DrawBuilingsInfo", DrawBuilingsInfo)