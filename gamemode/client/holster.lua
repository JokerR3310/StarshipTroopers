local holsteredgunsconvar = CreateConVar( "cl_holsteredguns", "1", { FCVAR_ARCHIVE, }, "Enable/Disable the rendering of the weapons on any player" )
 
local NEXT_WEAPONS_UPDATE = CurTime();

local weaponsinfos={}
 
weaponsinfos["st_binoculars"]={}
weaponsinfos["st_binoculars"].Model="models/weapons/w_binoculars.mdl"
weaponsinfos["st_binoculars"].Bone="ValveBiped.Bip01_Pelvis"
weaponsinfos["st_binoculars"].BoneOffset={Vector(0,-10,0),Angle(90,10,110)}

weaponsinfos["st_medkit"]={}
weaponsinfos["st_medkit"].Model="models/weapons/w_medkit.mdl"
weaponsinfos["st_medkit"].Bone="ValveBiped.Bip01_Pelvis"
weaponsinfos["st_medkit"].BoneOffset={Vector(0,8,2),Angle(90,30,-110)}

weaponsinfos["weapon_crowbar"]={}
weaponsinfos["weapon_crowbar"].Model="models/weapons/w_crowbar.mdl"
weaponsinfos["weapon_crowbar"].Bone="ValveBiped.Bip01_Spine1"
weaponsinfos["weapon_crowbar"].BoneOffset={Vector(3,0,0),Angle(0,0,45)}

weaponsinfos["st_morita_shotgun"]={}
weaponsinfos["st_morita_shotgun"].Model="models/ryan7259/starshiptroopers/weapons/w_morita_shotgun.mdl"
weaponsinfos["st_morita_shotgun"].Bone="ValveBiped.Bip01_R_Clavicle"
weaponsinfos["st_morita_shotgun"].BoneOffset={Vector(10,5,2),Angle(0,90,0)}

weaponsinfos["st_tactical_launcher"]={}
weaponsinfos["st_tactical_launcher"].Model="models/ryan7259/starshiptroopers/weapons/w_m136_launcher.mdl"
weaponsinfos["st_tactical_launcher"].Bone="ValveBiped.Bip01_L_Clavicle"
weaponsinfos["st_tactical_launcher"].BoneOffset={Vector(-16,5,0),Angle(180,0,0)}

weaponsinfos["st_carbine_short"]={}
weaponsinfos["st_carbine_short"].Model="models/ryan7259/starshiptroopers/weapons/w_moritamk2_carbine.mdl"
weaponsinfos["st_carbine_short"].Bone="ValveBiped.Bip01_Spine1"
weaponsinfos["st_carbine_short"].BoneOffset={Vector(3,4,-8),Angle(90,20,270)}

weaponsinfos["st_carbine_sniper"]={}
weaponsinfos["st_carbine_sniper"].Model="models/ryan7259/starshiptroopers/weapons/w_moritamk2_carbine.mdl"
weaponsinfos["st_carbine_sniper"].Bone="ValveBiped.Bip01_Spine1"
weaponsinfos["st_carbine_sniper"].BoneOffset={Vector(3,4,-8),Angle(90,20,270)}

weaponsinfos["st_carbine_shotgun"]={}
weaponsinfos["st_carbine_shotgun"].Model="models/ryan7259/starshiptroopers/weapons/w_moritamk2_pumpshotty.mdl"
weaponsinfos["st_carbine_shotgun"].Bone="ValveBiped.Bip01_Spine1"
weaponsinfos["st_carbine_shotgun"].BoneOffset={Vector(3,4,-8),Angle(90,20,270)}

weaponsinfos["st_morita_assault_rifle"]={}
weaponsinfos["st_morita_assault_rifle"].Model="models/ryan7259/starshiptroopers/weapons/w_morita_mk4.mdl"
weaponsinfos["st_morita_assault_rifle"].Bone="ValveBiped.Bip01_R_Clavicle"
weaponsinfos["st_morita_assault_rifle"].BoneOffset={Vector(10,-3,5),Angle(0,270,0)}

weaponsinfos["st_sniper_railgun"]={}
weaponsinfos["st_sniper_railgun"].Model="models/ryan7259/starshiptroopers/weapons/w_railgun.mdl"
weaponsinfos["st_sniper_railgun"].Bone="ValveBiped.Bip01_R_Clavicle"
weaponsinfos["st_sniper_railgun"].BoneOffset={Vector(11,0,2),Angle(20,0,0)}

local function CalcOffset(pos,ang,off)
	return pos + ang:Right() * off.x + ang:Forward() * off.y + ang:Up() * off.z;
end
     
local function clhasweapon(pl,weaponclass)
    for i,v in pairs(pl:GetWeapons()) do
        if string.lower(v:GetClass())==string.lower(weaponclass) then return true end
    end
     
    return false;
end
 
local function clgetweapon(pl,weaponclass)
    for i,v in pairs(pl:GetWeapons()) do
        if string.lower(v:GetClass())==string.lower(weaponclass) then return v end
    end
     
    return nil;
end

local function IsTf2Class(ply)
   return LocalPlayer().IsHL2 && !LocalPlayer():IsHL2()
end
 
local function GetHolsteredWeaponTable(ply,indx)
    local class = IsTf2Class(ply) or nil
    if !class then return weaponsinfos[indx]
    else return (weaponsinfos[indx] && weaponsinfos[indx][class]) and weaponsinfos[indx][class] or nil
    end
end
 
local function thinkdamnit()
    if !holsteredgunsconvar:GetBool() then return end
	if GAMEMODE:GmodLoadScript() then return end
    for _,pl in pairs(player.GetAll()) do
        if !IsValid(pl) then continue end
         
        if !pl.CL_CS_WEPS then
            pl.CL_CS_WEPS={}
        end
         
        if !pl:Alive() then pl.CL_CS_WEPS={} continue end
         
        if NEXT_WEAPONS_UPDATE<CurTime() then
            pl.CL_CS_WEPS={} 
            NEXT_WEAPONS_UPDATE=CurTime()+5
        end
         
        for i,v in pairs(pl:GetWeapons())do
            if !IsValid(v) then continue; end
             
            if pl.CL_CS_WEPS[v:GetClass()] then continue end
             
            if !pl.CL_CS_WEPS[v:GetClass()] then
                local worldmodel=v.WorldModelOverride or v.WorldModel
                 
                if GetHolsteredWeaponTable(pl,v:GetClass()) && GetHolsteredWeaponTable(pl,v:GetClass()).Model then
                    worldmodel=GetHolsteredWeaponTable(pl,v:GetClass()).Model
                end
                if !worldmodel || worldmodel=="" then continue end;
                
                pl.CL_CS_WEPS[v:GetClass()]=ClientsideModel(worldmodel,RENDERGROUP_OPAQUE)
                pl.CL_CS_WEPS[v:GetClass()]:SetNoDraw(true)
            end
        end
    end
end
 
local function playerdrawdamnit(pl,legs)
    if !holsteredgunsconvar:GetBool() then return end
	if GAMEMODE:GmodLoadScript() then return end
    if !IsValid(pl) then return end
    if !pl.CL_CS_WEPS then return end
    for i,v in pairs(pl.CL_CS_WEPS) do

        if GetHolsteredWeaponTable(pl,i) && (pl:GetActiveWeapon() == NULL || pl:GetActiveWeapon():GetClass()~=i) && clhasweapon(pl,i) then
            if GetHolsteredWeaponTable(pl,i).Priority then
                local priority = GetHolsteredWeaponTable(pl,i).Priority
                local bol = GetHolsteredWeaponTable(pl,priority) && (pl:GetActiveWeapon()==NULL || pl:GetActiveWeapon():GetClass()!=priority) && clhasweapon(pl,priority)
                if bol then continue; end
            end
             
            local oldpl=pl;
            local wep=clgetweapon(oldpl,i)

            local bone=pl:LookupBone(GetHolsteredWeaponTable(oldpl,i).Bone or "")
            if !bone then pl=oldpl;continue; end
 
            local matrix = pl:GetBoneMatrix(bone)
            if !matrix then pl = oldpl;continue; end
            local pos = matrix:GetTranslation()
			local ang = matrix:GetAngles()
            local pos = CalcOffset(pos,ang,GetHolsteredWeaponTable(oldpl,i).BoneOffset[1])

            v:SetRenderOrigin(pos)
             
            ang:RotateAroundAxis(ang:Forward(),GetHolsteredWeaponTable(oldpl,i).BoneOffset[2].p)
            ang:RotateAroundAxis(ang:Up(),GetHolsteredWeaponTable(oldpl,i).BoneOffset[2].y)
            ang:RotateAroundAxis(ang:Right(),GetHolsteredWeaponTable(oldpl,i).BoneOffset[2].r)
             
            v:SetRenderAngles(ang)
            v:DrawModel();
            
            if GetHolsteredWeaponTable(oldpl,i).DrawFunction then
                GetHolsteredWeaponTable(oldpl,i).DrawFunction(v,oldpl)
            end
            pl=oldpl;
        end
    end
end

hook.Add("Think","HG_Think",thinkdamnit)
hook.Add("PostPlayerDraw","HG_Draw",playerdrawdamnit)