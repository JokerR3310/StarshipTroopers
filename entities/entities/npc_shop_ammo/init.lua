AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

util.AddNetworkString("ST_BuyAmmo")
util.AddNetworkString("ST_BuyWeapon")

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

local female_snd = {
	"vo/npc/female01/finally.wav",
	"vo/npc/female01/fantastic01.wav",
	"vo/npc/female01/fantastic02.wav"
}

local male_snd = {
	"vo/npc/male01/evenodds.wav",
	"vo/npc/male01/oneforme.wav",
	"vo/npc/male01/finally.wav",
	"vo/npc/male01/fantastic01.wav",
	"vo/npc/male01/fantastic02.wav"
}

local function dovoice(ply)
	if math.random(1, 2) == 2 then return end

	if not ply:GetNetVar("Taunt", false) then
		local getgender = string.find(string.lower(ply:GetModel()), "mobileinfantry/fmi")

		if getgender then
			ply:EmitSound(Sound(female_snd[math.random(#female_snd)]))
		else
			ply:EmitSound(Sound(male_snd[math.random(#male_snd)]))
		end

		ply:SetNetVar("Taunt", true)
	end
end

net.Receive("ST_BuyAmmo", function(_, ply)
	local ammotype = net.ReadString()
	if not ammotype then return end

	local getAmmo = ST_AmmoList[ammotype]
	if not getAmmo then return end

	local getPrice = getAmmo.price

	local getCredits = tonumber(ply:GetNetVar("Credits", 0))
	local cost = GAMEMODE:GetGameState() == STATE_ROUND_OVER and getPrice / 2 or getPrice

	if getCredits < cost then
		ply:ChatPrint("You don't have enough Credits, go into battle and kill a couple of bugs to get more Credits!")

		return
	end

	dovoice(ply)

	ply:SetNetVar("Credits", getCredits - cost)
	ply:GiveAmmo(getAmmo.amount, ammotype)
end)

net.Receive("ST_BuyWeapon", function(_, ply)
	local wep = net.ReadString()
	if not wep then return end

	if not ply:Alive() then return end

	if ply:HasWeapon(wep) then 
		ply:ChatPrint("You already have exactly the same weapon!")

		return
	end

	local getWeapon = ST_WeaponsList[wep]
	if not getWeapon then return end

	local getPrice = getWeapon.price
	local getCredits = tonumber(ply:GetNetVar("Credits", 0))

	if getCredits < getPrice then 
		ply:ChatPrint("You don't have enough Credits, go into battle and kill a couple of bugs to get more Credits!")

		return
	end

	dovoice(ply)

	ply:SetNetVar("Credits", getCredits - getPrice)
	ply:Give(wep)
end)