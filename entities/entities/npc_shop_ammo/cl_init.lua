include("shared.lua")

surface.CreateFont("ScoreboardHeader", {
    font = "coolvetica",
    size = 32,
    weight = 500,
    antialias = true
})

surface.CreateFont("ScoreboardHeader2", {
    font = "coolvetica",
    size = 28,
    weight = 500,
    antialias = true
})

surface.CreateFont("ScoreboardText", {
    font = "Tahoma",
    size = 16,
    weight = 1000,
    antialias = true
})

local coins = Material("icon16/coins.png")
usermessage.Hook("open_ammo_shop2", function()
    local frame = vgui.Create("DFrame")
    frame:SetSize(440, 320)
    frame:Center()
    frame:SetTitle("")
    frame:SetDraggable(false)
    frame:MakePopup()
    function frame:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(30, 30, 30, 195))
        draw.SimpleTextOutlined("Merchant | You have: " .. tonumber(LocalPlayer():GetNetVar("Credits", 0)) .. " Credits", "HudHintTextLarge", 11, 10, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT, 1, Color(0, 0, 0, 255))
    end

    local PropertySheet = vgui.Create("DPropertySheet", frame)
    PropertySheet:SetPos(8, 30)
    PropertySheet:SetSize(424, 284)

    local IconList = vgui.Create("DPanelList", frame)
    IconList:EnableVerticalScrollbar(true)
    IconList:SetPadding(4)
    IconList:SetPos(10, 30)
    IconList:SetSize(420, 284)

    for k, item in pairs(ST_AmmoList) do
        if not item.allowedfor[player_manager.GetPlayerClass(LocalPlayer())] then continue end

        local bar = vgui.Create("DPanel", IconList)
        bar:SetPos(0, 0)
        bar:SetSize(396, 70)
        function bar:Paint(w, h)
            draw.RoundedBox(0, 0, 0, w - 2, h - 5, Color(90, 90, 90, 155))
            draw.DrawText(item.label, "ScoreboardHeader", 70, 4, Color(30, 30, 30, 255))

            if GAMEMODE:GetGameState() == STATE_ROUND_OVER then
                draw.DrawText(item.price / 2, "ScoreboardHeader", 350, 0, Color(30, 30, 30, 255), TEXT_ALIGN_RIGHT)
                draw.RoundedBox(0, 340, 30, 40, 18, Color(60, 190, 60, 175))
                draw.DrawText("-50%", "ScoreboardText", 361, 30.5, Color(180, 245, 180, 255), TEXT_ALIGN_CENTER)
            else
                draw.DrawText(item.price, "ScoreboardHeader", 350, 0, Color(30, 30, 30, 255), TEXT_ALIGN_RIGHT)
            end

            draw.DrawText(item.desc, "ScoreboardText", 70, 37, Color(10, 10, 10, 255))

            surface.SetDrawColor(color_white)
            surface.SetMaterial(coins)
            surface.DrawTexturedRect(360, 7, 16, 16)
        end

        local icon = vgui.Create("SpawnIcon", bar)
        icon:SetModel(item.model)
        icon:SetPos(4, 4)
        icon:SetSize(57, 57)
        icon.DoClick = function()
            net.Start("ST_BuyAmmo")
            net.WriteString(tostring(k))
            net.SendToServer()
        end

        IconList:AddItem(bar)
    end

    local IconList2 = vgui.Create("DPanelList", frame)
    IconList2:EnableVerticalScrollbar(true)
    IconList2:SetPadding(4)
    IconList2:SetPos(0, 0)
    IconList2:SetSize(420, 284)
    function IconList2:Paint(w, h)
        draw.RoundedBox(4, 0, 220, 406, 25, Color(90, 90, 90, 155))
        draw.DrawText("You will lose all weapons and ammo upon death!", "ScoreboardText", 60, 224, Color(30, 30, 30, 255))
    end

    local img = vgui.Create("DImage", IconList2)
    img:SetPos(20, 225)
    img:SetSize(16, 16)
    img:SetImage("icon16/exclamation.png")

    for k, wep in pairs(ST_WeaponsList) do
        if not wep.allowedfor[player_manager.GetPlayerClass(LocalPlayer())] then continue end

        local bar = vgui.Create("DPanel", IconList2)
        bar:SetPos(0, 0)
        bar:SetSize(396, 70)
        function bar:Paint(w, h)
            draw.RoundedBox(0, 0, 0, w - 2, h - 5, Color(90, 90, 90, 155))
            draw.DrawText(wep.label, "ScoreboardHeader2", 70, 4, Color(30, 30, 30, 255))
            draw.DrawText(wep.price, "ScoreboardHeader", 350, 0, Color(30, 30, 30, 255), TEXT_ALIGN_RIGHT)
            draw.DrawText(wep.desc, "ScoreboardText", 70, 37, Color(10, 10, 10, 255))

            surface.SetDrawColor(color_white)
            surface.SetMaterial(coins)
            surface.DrawTexturedRect(360, 7, 16, 16)
        end

        local icon = vgui.Create("SpawnIcon", bar)
        icon:SetModel(wep.model)
        icon:SetPos(4, 4)
        icon:SetSize(57, 57)
        icon.DoClick = function()
            net.Start("ST_BuyWeapon")
            net.WriteString(tostring(k))
            net.SendToServer()
        end

        IconList2:AddItem(bar)
    end

    PropertySheet:AddSheet("Ammo", IconList, "icon16/box.png", false, false, "You can buy some ammo here!")
    PropertySheet:AddSheet("Weapons", IconList2, "icon16/gun.png", false, false, "You can buy weapons here!")
end)