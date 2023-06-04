AddCSLuaFile()

SWEP.Base			= "st_base"

SWEP.Author			= "-=Joker|CMBG|=-"
SWEP.Category 		= "SST Weapons 2"

SWEP.HoldType 		= "duel"

SWEP.Spawnable		= true
SWEP.AdminOnly		= true

SWEP.ViewModel		= "models/weapons/v_models/v_builder_engineer.mdl"
SWEP.ViewBox 		= "models/weapons/v_models/v_toolbox_engineer.mdl"
SWEP.WorldModel		= "models/props_c17/SuitCase_Passenger_Physics.mdl"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.Automatic   	= true

SWEP.PrintName			= "PDA"
SWEP.Slot				= 2
SWEP.SlotPos			= 2
SWEP.DrawAmmo			= false

SWEP.CanBuild = true

SWEP.BuildType = 0

function SWEP:Holster()
	if IsValid(self.blueprint) then
		self.blueprint:Remove()
	end

	self.BuildType = 0

	return true
end

function SWEP:Deploy()
	self:SetHoldType( self.HoldType )

	self:CallOnClient("Deploy",0)
	local seq = self:LookupSequence("draw")
	self:ResetSequence(seq)
	self:SetPlaybackRate(1)
	self:SetSequence(seq)

	self.CanBuild = true

	if SERVER then
        if IsValid(self.blueprint) then
            self.blueprint:Remove()
        end

        self.blueprint = ents.Create("obj_blueprint")
        self.blueprint:SetNoDraw(true)
        self.blueprint:SetOwner(self)
        self.blueprint:Spawn()
    end

    return true
end

function SWEP:PrimaryAttack()
    if self.BuildType == 0 or not self.CanBuild then return end

    if SERVER then
        local building

        if self.BuildType == 1 then
            if self:GetOwner().sentry and IsValid(self:GetOwner().sentry) then return end
            building = "obj_sentrygun"
            self:GetOwner():EmitSound("vo/engineer_autobuildingsentry0" .. math.random(1, 2) .. ".mp3", 80, 95)
        elseif self.BuildType == 2 then
            if self:GetOwner().dispenser and IsValid(self:GetOwner().dispenser) then return end
            building = "obj_dispenser"
            self:GetOwner():EmitSound("vo/engineer_autobuildingdispenser0" .. math.random(1, 2) .. ".mp3", 80, 95)
        end

        local obj = ents.Create(building)
        obj:SetPos(self.blueprint:GetPos())
        obj:SetAngles(self.blueprint:GetAngles())
        obj:Spawn()
        obj:Activate()
        obj:SetBuilder(self:GetOwner())
        obj.owner = self:GetOwner()

        if self.BuildType == 1 then
            self:GetOwner().sentry = obj
        elseif self.BuildType == 2 then
            self:GetOwner().dispenser = obj
        end

        local valid, have, need = self:CheckAmmo()
        self:GetOwner():SetAmmo(have - need, "AirboatGun")
        self:GetOwner():SelectWeapon("st_wrench")
    end

	self:SetNextPrimaryFire(CurTime() + 2)
end

function SWEP:SecondaryAttack()
    if self.BuildType == 0 then return end

    if SERVER and IsValid(self.blueprint) then
        self.blueprint:RotateBlueprint()
    end

    self:SetNextSecondaryFire(CurTime() + 0.4)
end

function SWEP:CheckAmmo()
	local have = self:GetOwner():GetAmmoCount( "AirboatGun" )

	if self.BuildType == 1 and have >= 130 then
		return true, have, 130
	elseif self.BuildType == 2 and have >= 100 then
		return true, have, 100
	else
		return false
	end
end

function SWEP:Think()
    if CLIENT then
        if self.BuildType == 0 then
            if input.IsKeyDown(KEY_1) then
                self.BuildType = 1
            elseif input.IsKeyDown(KEY_2) then
                self.BuildType = 2
            end

            if self.BuildType ~= 0 then
                net.Start("setBuildType")
                net.WriteInt(self.BuildType, 4)
                net.SendToServer()
            end
        end
    else
        if self.BuildType ~= 0 then
            self.blueprint.dt.Type = self.BuildType
        end
    end

    if self.BuildType == 0 or not IsValid(self.blueprint) then return end

    if self:CheckAmmo() and self.blueprint.dt.Allowed then
        self.blueprint:SetColor(Color(100, 255, 100))
        self.CanBuild = true
    else
        self.blueprint:SetColor(Color(255, 100, 100))
        self.CanBuild = false
    end

    self.blueprint:SetNoDraw(false)
end

if CLIENT then
    SWEP.WepSelectIcon = surface.GetTextureID("weapons/st_pda")

    surface.CreateFont("Big", {
        font = "Roboto",
        size = ScrW() / 22,
        weight = 500
    })

    surface.CreateFont("Mini", {
        font = "Roboto",
        size = ScrW() / 74,
        weight = 500
    })

    local build = surface.GetTextureID("hud/ico_build")
    local sentry = surface.GetTextureID("hud/eng_build_sentry_blueprint")
    local disp = surface.GetTextureID("hud/eng_build_dispenser_blueprint")
    local key = surface.GetTextureID("hud/ico_key_blank")
    local metal = surface.GetTextureID("hud/ico_metal")
    local back = surface.GetTextureID("hud/tournament_panel_tan")

    local obj = {sentry, disp}
    local Mpri = {130, 100}
    local sPri = {"Sentry Gun", "Dispenser"}

    function SWEP:DrawHUD()
        if self.BuildType == 0 then
			draw.RoundedBox(8, ScrW() / 2 - ScrW() / (2.65 * 2), ScrH() / 2.2, 258, 190, Color(117, 117, 117, 160))

            draw.SimpleText("BUILD", "Big", ScrW() / 2 - ScrW() / 7.5 + 2, ScrH() / 2.4 + 2, Color(25, 25, 25, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
            draw.SimpleText("BUILD", "Big", ScrW() / 2 - ScrW() / 7.5, ScrH() / 2.4, Color(225, 225, 200, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)

            surface.SetTexture(build)
            surface.SetDrawColor(45, 45, 20, 255)
            surface.DrawTexturedRect(ScrW() / 2 - ScrW() / (2.65 * 2) + 2, ScrH() / 2.4 + 2, ScrW() / 22, ScrW() / 22)
            surface.SetDrawColor(color_white)
            surface.DrawTexturedRect(ScrW() / 2 - ScrW() / (2.65 * 2), ScrH() / 2.4, ScrW() / 22, ScrW() / 22)

            for k, v in pairs(obj) do
                surface.SetTexture(back)
                surface.DrawTexturedRect(ScrW() / 2 - ScrW() / 5.9 + ScrW() / 14 * (k - 1) * 1.25, ScrH() / 1.9, ScrW() / 14, ScrW() / 14)
                surface.SetTexture(v)
                surface.DrawTexturedRect(ScrW() / 2 - ScrW() / 5.9 + ScrW() / 14 * (k - 1) * 1.25 + ScrW() / 64, ScrH() / 1.78, ScrW() / 24, ScrW() / 24)
                surface.SetTexture(key)
                surface.DrawTexturedRect(ScrW() / 2 - ScrW() / 6.3 + ScrW() / 14 * (k - 1) * 1.25 + ScrW() / 64, ScrH() / 1.525, ScrW() / 48, ScrW() / 48)
                surface.SetTexture(metal)
                surface.DrawTexturedRect(ScrW() / 2 - ScrW() / 5.75 + ScrW() / 14 * (k - 1) * 1.25 + ScrW() / 64, ScrH() / 1.865, ScrW() / 86, ScrW() / 86)
                
				draw.SimpleText(k, "Mini", ScrW() / 2 - ScrW() / 6.3 + ScrW() / 14 * (k - 1) * 1.25 + ScrW() / 64 + ScrW() / 48 / 2.3, ScrH() / 1.525 + ScrW() / 48 / 2.2, Color(25, 25, 20, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                draw.SimpleText(Mpri[k], "Mini", ScrW() / 2 - ScrW() / 6.15 + ScrW() / 14 * (k - 1) * 1.25 + ScrW() / 64 + ScrW() / 48 / 1.5, ScrH() / 1.89 + ScrW() / 48 / 2.2, Color(25, 25, 20, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                draw.SimpleText(sPri[k], "Mini", ScrW() / 2 - ScrW() / 5.25 + ScrW() / 14 * (k - 1) * 1.25 + ScrW() / 64 + ScrW() / 48 / 2, ScrH() / 1.95, Color(225, 225, 200, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end
        end
    end

    hook.Add("PlayerBindPress", "PDADisableSomeKeys", function(ply, bind, pressed)
        local wep = ply:GetActiveWeapon()
        if IsValid(wep) and wep:GetClass() == "st_pda" and wep.BuildType == 0 and string.find(bind, "slot*") then return true end
    end)

    function SWEP:CalcView(ply)
        if self.BuildType ~= 0 then
            ply:GetViewModel():SetModel(self.ViewBox)
			ply:GetViewModel():SetSkin(2)
        end
    end

    SWEP.Offset = {
        Pos = {
            Right = -10.5,
            Forward = -2,
            Up = 8,
        },
        Ang = {
            Right = -20,
            Forward = -10,
            Up = 110,
        },
    }

    function SWEP:DrawWorldModel()
        if not IsValid(self:GetOwner()) then return self:DrawModel() end

        local offset, hand
        self.Hand2 = self.Hand2 or self:GetOwner():LookupAttachment("anim_attachment_rh")
        hand = self:GetOwner():GetAttachment(self.Hand2)
        if not hand then return end
        offset = hand.Ang:Right() * self.Offset.Pos.Right + hand.Ang:Forward() * self.Offset.Pos.Forward + hand.Ang:Up() * self.Offset.Pos.Up
       
		hand.Ang:RotateAroundAxis(hand.Ang:Right(), self.Offset.Ang.Right)
        hand.Ang:RotateAroundAxis(hand.Ang:Forward(), self.Offset.Ang.Forward)
        hand.Ang:RotateAroundAxis(hand.Ang:Up(), self.Offset.Ang.Up)
       
		self:SetRenderOrigin(hand.Pos + offset)
        self:SetRenderAngles(hand.Ang)
        self:SetModelScale(0.8, 0)
        self:DrawModel()
    end
else
    util.AddNetworkString("setBuildType")

    net.Receive("setBuildType", function(len, ply)
        local bt = net.ReadInt(4)
        ply:GetActiveWeapon().BuildType = bt
    end)
end