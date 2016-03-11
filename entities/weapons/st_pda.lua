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

if CLIENT then
	SWEP.WepSelectIcon = surface.GetTextureID("weapons/st_pda")
end

SWEP.PrintName			= "PDA"
SWEP.Slot				= 2
SWEP.SlotPos			= 2
SWEP.DrawAmmo			= false

SWEP.CanBuild = true

SWEP.BuildType = 0

if SERVER then
	util.AddNetworkString("setBuildType")
end

function SWEP:Holster()
	if self.Owner and self.Owner:IsValid() then
		if self.blueprint and self.blueprint:IsValid() then
			self.blueprint:Remove()
		end
	end
	
	self.BuildType = 0
	
	return true
end

function SWEP:Deploy()
	self:SetWeaponHoldType( self.HoldType )

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
		self.blueprint:Activate()
	end
	
	return true
end

function SWEP:PrimaryAttack()
	self.Weapon:SetNextPrimaryFire( CurTime() + 2 )
	
	if self.BuildType == 0 then return end
	
	if self.CanBuild == false then return end

	if SERVER then
	   local building
	   
		if self.BuildType == 1 then
			if self.Owner.sentry and IsValid(self.Owner.sentry) then return end
			building = "obj_sentrygun"
			self.Owner:EmitSound( "vo/engineer_autobuildingsentry0" .. math.random(1,2) .. ".mp3", 80, 95 )
		elseif self.BuildType == 2 then
			if self.Owner.dispenser and IsValid(self.Owner.dispenser) then return end
			building = "obj_dispenser"
			self.Owner:EmitSound( "vo/engineer_autobuildingdispenser0" .. math.random(1,2) .. ".mp3", 80, 95 )
		end

	   local obj = ents.Create( building )
		obj.owner = self.Owner
		obj:SetPos( self.blueprint:GetPos() )
		obj:SetAngles( self.blueprint:GetAngles() )
		obj:Spawn()
		obj:Activate()
		obj:SetBuilder(self.Owner)
			
		obj:SetNetworkedBool( "building", true )
			
		if self.BuildType == 1 then
			self.Owner.sentry = obj
			self.Owner:SetNetworkedEntity( "sentrygun", obj )
		elseif self.BuildType == 2 then
			self.Owner.dispenser = obj
			self.Owner:SetNetworkedEntity( "dispenser", obj )
		end

	   local valid, have, need = self:CheckAmmo()
		self.Owner:SetAmmo(have - need, "AirboatGun")
			
		self.Owner:SelectWeapon( "st_wrench" )
	end
end

function SWEP:SecondaryAttack()
	if self.BuildType == 0 then return end

	self.Weapon:SetNextSecondaryFire(CurTime()+0.4)

	if SERVER then
		if IsValid(self.blueprint) then
			self.blueprint:RotateBlueprint()
		end
	end
end

net.Receive("setBuildType",function(len,ply)
	ply:GetActiveWeapon().BuildType = net.ReadFloat()
end)

function SWEP:CheckAmmo()
	local have = self.Owner:GetAmmoCount( "AirboatGun" )

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
			if(input.IsKeyDown(KEY_1)) then
				self.BuildType = 1
			end
			if(input.IsKeyDown(KEY_2)) then
				self.BuildType = 2
			end

			if self.BuildType != 0 then
				net.Start("setBuildType")
				net.WriteFloat(self.BuildType)
				net.SendToServer()
			end
		end
	end
	
	if SERVER then
		if self.BuildType == 1 then
			self.blueprint.dt.Type = 1
		elseif self.BuildType == 2 then
			self.blueprint.dt.Type = 2
		end
	end

	if self.BuildType == 0 then return end

	if self.blueprint and self.blueprint:IsValid() then
		
	   local haveammo = self:CheckAmmo()
		if !haveammo or !self.blueprint.dt.Allowed then -- !valid
			self.blueprint:SetColor(Color(255,100,100)) -- red
			self.CanBuild = false
		else
			self.blueprint:SetColor(Color(100,255,100))
			self.CanBuild = true
		end

		self.blueprint:SetNoDraw(false)
	end
end

if CLIENT then
	surface.CreateFont("Big", {font = "Roboto", size = ScrW()/22, weight = 500})
	surface.CreateFont("Mini", {font = "Roboto", size = ScrW()/74, weight = 500})
	surface.CreateFont("Tiny", {font = "DebugFixed", size = ScrW()/82, weight = 500})

	local build = surface.GetTextureID("hud/ico_build")

	local sentry = surface.GetTextureID("hud/eng_build_sentry_blueprint")
	local disp = surface.GetTextureID("hud/eng_build_dispenser_blueprint")

	local key = surface.GetTextureID("hud/ico_key_blank")

	local metal = surface.GetTextureID("hud/ico_metal")
	local back = surface.GetTextureID("hud/tournament_panel_tan")

	local obj = {sentry, disp}

	local Mpri = {130, 100}

	local sPri = {"Sentry Gun", "Dispenser"}

	function vgui.PanelBasic(x,y)	
		draw.RoundedBox(8, x, y, 258, 190, Color(117,117,117,160))
	end

	function SWEP:DrawHUD()
		if (self.BuildType == 0) then

		vgui.PanelBasic(ScrW()/2-ScrW()/(2.65*2),ScrH()/2.2,ScrW()/2.65,ScrH()/4)
		draw.SimpleText("BUILD", "Big", ScrW()/2-ScrW()/7.5+2, ScrH()/2.4+2,Color(25,25,25,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
		draw.SimpleText("BUILD", "Big", ScrW()/2-ScrW()/7.5, ScrH()/2.4,Color(225,225,200,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)

		surface.SetTexture(build)
		
		surface.SetDrawColor(45, 45, 20, 255)
		surface.DrawTexturedRect(ScrW()/2-ScrW()/(2.65*2)+2,ScrH()/2.4+2,ScrW()/22,ScrW()/22)
		
		surface.SetDrawColor(color_white)
		surface.DrawTexturedRect(ScrW()/2-ScrW()/(2.65*2),ScrH()/2.4,ScrW()/22,ScrW()/22)

		for k,v in pairs(obj) do
			surface.SetTexture(back)
			surface.DrawTexturedRect(ScrW()/2-ScrW()/5.9 + ScrW()/14*(k-1)*1.25,ScrH()/1.9,ScrW()/14,ScrW()/14)		

			surface.SetTexture(v)
			surface.DrawTexturedRect(ScrW()/2-ScrW()/5.9 + ScrW()/14*(k-1)*1.25 + ScrW()/64,ScrH()/1.78,ScrW()/24,ScrW()/24)		

			surface.SetTexture(key)
			surface.DrawTexturedRect(ScrW()/2-ScrW()/6.3 + ScrW()/14*(k-1)*1.25 + ScrW()/64,ScrH()/1.525,ScrW()/48,ScrW()/48)		

			surface.SetTexture(metal)
			surface.DrawTexturedRect(ScrW()/2-ScrW()/5.75 + ScrW()/14*(k-1)*1.25 + ScrW()/64,ScrH()/1.865,ScrW()/86,ScrW()/86)		

			draw.SimpleText(k, "Mini",ScrW()/2-ScrW()/6.3 + ScrW()/14*(k-1)*1.25 + ScrW()/64+ScrW()/48/2.3,ScrH()/1.525+ScrW()/48/2.2,Color(25,25,20,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

			draw.SimpleText(Mpri[k], "Mini",ScrW()/2-ScrW()/6.15 + ScrW()/14*(k-1)*1.25 + ScrW()/64+ScrW()/48/1.5,ScrH()/1.89+ScrW()/48/2.2,Color(25,25,20,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

			draw.SimpleText(sPri[k], "Tiny",ScrW()/2-ScrW()/5.25 + ScrW()/14*(k-1)*1.25 + ScrW()/64+ScrW()/48/2,ScrH()/1.95,Color(225,225,200,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end
	end
end

	hook.Add("PlayerBindPress","DisableSomeKeys",function( ply, bind, pressed )
		if(ply:GetActiveWeapon() != nil && ply:GetActiveWeapon():IsValid() && ply:GetActiveWeapon():GetClass() == "st_pda") then
			if ( string.find( bind, "slot*" ) ) then return true end
		end
	end)

	function SWEP:CalcView()
		if (self.BuildType != 0) then
			self.Owner:GetViewModel():SetModel(self.ViewBox)
			self.Owner:GetViewModel():SetSkin(2)
		end
	end

	function SWEP:ViewModelDrawn()
			self:NextThink(CurTime())
		return true
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
	function SWEP:DrawWorldModel( )
		if not IsValid( self.Owner ) then
			return self:DrawModel( )
		end
    
		local offset, hand
    
		self.Hand2 = self.Hand2 or self.Owner:LookupAttachment( "anim_attachment_rh" )
    
		hand = self.Owner:GetAttachment( self.Hand2 )
    
		if not hand then return end
    
		offset = hand.Ang:Right( ) * self.Offset.Pos.Right + hand.Ang:Forward( ) * self.Offset.Pos.Forward + hand.Ang:Up( ) * self.Offset.Pos.Up
    
		hand.Ang:RotateAroundAxis( hand.Ang:Right( ), self.Offset.Ang.Right )
		hand.Ang:RotateAroundAxis( hand.Ang:Forward( ), self.Offset.Ang.Forward )
		hand.Ang:RotateAroundAxis( hand.Ang:Up( ), self.Offset.Ang.Up )
    
		self:SetRenderOrigin( hand.Pos + offset )
		self:SetRenderAngles( hand.Ang )
    
		self:SetModelScale( 0.8, 0 )
    
		self:DrawModel()
	end
end