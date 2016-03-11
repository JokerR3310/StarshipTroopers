AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

include('shared.lua')

util.AddNetworkString( "AmmoBuy" )
util.AddNetworkString( "WeaponBuy" )

function ENT:Initialize()
	self:SetHullType(HULL_HUMAN)
	self:SetHullSizeNormal()
	self:SetModel("models/Humans/Group03/male_03.mdl")
	self:SetNPCState(NPC_STATE_IDLE)
	self:SetSolid(SOLID_BBOX)
	self:CapabilitiesAdd(bit.bor(CAP_ANIMATEDFACE,CAP_TURN_HEAD))
	self:SetUseType(SIMPLE_USE)
	self:DropToFloor()
	
	self:SetMaxYawSpeed(90)
end

function ENT:AcceptInput(ply, caller)
	if caller:IsPlayer() && !caller.CantUse then
		caller.CantUse = true
		timer.Simple(2, function() caller.CantUse = false end)

		if caller:IsValid() then
			umsg.Start("open_ammo_shop2", caller)
			umsg.End()
		end
	end
end

net.Receive( "AmmoBuy", function(len, ply)	
	local amount = net.ReadString()
	local ammotype = net.ReadString()
	local price = net.ReadString()
	
	local cost
	
	if GAMEMODE:GetGameState() == STATE_ROUND_OVER then
		cost = price / 2
	else
		cost = price
	end

	if !ply:Money_Has(cost) then ply:ChatPrint("You don't have enough points, go into battle and kill a couple of bugs to get more points!") return end
		
	ply:Money_Take(cost)
		
	ply:GiveAmmo(amount,ammotype)
end)

net.Receive( "WeaponBuy", function(len, ply)
	local wep = net.ReadString()
	local price = net.ReadString()

	if !ply:Money_Has(price) then ply:ChatPrint("You do not have points, go into battle and kill a couple of bugs to get more points!") return end

	ply:Money_Take(price)

	ply:Give(wep)
end)