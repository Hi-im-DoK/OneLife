local pma = exports["pma-voice"]
local currentChannel = 0
local itemCooldown = false

OneLifeMenu = {

    Indexaccesories = 1,
    IndexClothes = 1,
    Indexinvetory = 1,
    IndexVetement = 1,
    Accesoires = 1,
    Indexdoor = 1,
    LimitateurIndex = 1,
    Item = true,
    Weapon = true,
    Radar = true,
    Vetement = true,
    AccesoiresMenu = true,
    Report = true,
    ui = true,
    TickRadio = false,
    InfosRadio = false,
    Bruitages = true,
    Statut = "~p~Allumé",
    VolumeRadio = 1,
    jobChannels = {
        {job="police", "sheriff", "ambulance", "gouvernement", min=1, max=8}
    },

    DoorState = {
        FrontLeft = false,
        FrontRight = false,
        BackLeft = false,
        BackRight = false,
        Hood = false,
        Trunk = false
    },

    voiture_limite = {
        "50 km/h",
        "80 km/h",
        "130 km/h",
        "Personalisée",
        "Désactiver"
    },
}
function startAnimAction(lib, anim)
	ESX.Streaming.RequestAnimDict(lib, function()
		TaskPlayAnim(plyPed, lib, anim, 8.0, 1.0, -1, 49, 0, false, false, false)
		RemoveAnimDict(lib)
	end)
end
Masque = true 

function GetCurrentWeight()
	local currentWeight = 0
	for i = 1, #ESX.PlayerData.inventory, 1 do
		if ESX.PlayerData.inventory[i].count > 0 then
			currentWeight = currentWeight + (ESX.PlayerData.inventory[i].weight * ESX.PlayerData.inventory[i].count)
		end
	end
	return currentWeight
end

local BillData = {}

openMenuF5 = function()

    local mainf5 = RageUI.CreateMenu("", "Voici les actions disponibles")
    
    --Menu Principaux
    local invetory = RageUI.CreateSubMenu(mainf5, "", "Voici votre inventaire")
    local portefeuille = RageUI.CreateSubMenu(mainf5, "", "Voici votre portefeuille")
    local vehicle = RageUI.CreateSubMenu(mainf5, "", "Voici les actions disponibles")
    local vetmenu = RageUI.CreateSubMenu(mainf5, "", "Actions vêtements")
    local radio = RageUI.CreateSubMenu(mainf5, "", "Voici les actions disponibles")
    local diversmenu = RageUI.CreateSubMenu(mainf5, "", "Voici les actions disponibles")
    local pubs = RageUI.CreateSubMenu(mainf5, "", "Voici les actions disponibles")

    local actioninventory = RageUI.CreateSubMenu(invetory, "", "Voici les actions disponibles")
    local infojob = RageUI.CreateSubMenu(portefeuille, "", "Voici les information sur votre travail")
    local infojob2 = RageUI.CreateSubMenu(portefeuille, "", "Voici les information sur votre organisation")
    local gestionjob = RageUI.CreateSubMenu(mainf5, "", "Voici les information sur votre entreprise")
    local gestionjob2 = RageUI.CreateSubMenu(mainf5, "", "Voici les information sur votre organisation")
    local billingmenu = RageUI.CreateSubMenu(portefeuille, "", "Voici vos facture")
    local actionweapon = RageUI.CreateSubMenu(invetory, "", "Voici les actions dipsonibles")
    local gestionlicense = RageUI.CreateSubMenu(portefeuille, "", "Voici vos license")
    mainf5.Closed = function()end 
    radio.EnableMouse = true
    RageUI.Visible(mainf5, not RageUI.Visible(mainf5))

    ESX.TriggerServerCallback("ronflex:getradio", function(cb)
        OneLifeMenu.InfosRadio = cb
    end)

    while mainf5 do
        Wait(0)

        RageUI.IsVisible(mainf5, function()

            RageUI.Button("> Inventaire", "Accéder à votre inventaire", {RightLabel = "→→→"}, true, {}, invetory)

            RageUI.Button("> Portefeuille", "Votre Portefeuille", {RightLabel = "→→→"}, true, {}, portefeuille)

            if IsPedSittingInAnyVehicle(PlayerPedId()) then 
                RageUI.Button('> Gestion véhicule', 'Actions sur le véhicule', {RightLabel = "→→→"}, true, {}, vehicle)
            end

            RageUI.Button("> Vêtements", "Actions sur vos vêtements", {RightLabel = "→→→"}, true, {}, vetmenu)


            if ESX.PlayerData.job.grade_name == "boss" then 
                RageUI.Button("> Gestion Entreprise", nil, {RightLabel = "→→→"}, true, {
                    onSelected = function()
                        RefreshMoney()
                    end
                }, gestionjob)
            end

            if ESX.PlayerData.job2.grade_name == "boss" then 
                RageUI.Button("> Gestion Organisation", nil, {RightLabel = "→→→"}, true, {
                    onSelected = function()
                        RefreshMoney2()
                    end
                }, gestionjob2)
            end

            RageUI.Button("> Radio", "Accéder à la radio", {RightLabel = "→→→"}, OneLifeMenu.InfosRadio, {
                onSelected = function()
                end
            }, radio)

            RageUI.Button("> Pubs", "Publicités", {RightLabel = "→→→"}, true, {}, pubs)

            RageUI.Button("> Divers", "Actions diverses", {RightLabel = "→→→"}, true, {}, diversmenu)
        
        end, function()
        end)

        RageUI.IsVisible(invetory, function()
            ESX.PlayerData = ESX.GetPlayerData()

            RageUI.Separator('Poids > '.. GetCurrentWeight() + 0.0 .. '/' .. ESX.PlayerData.maxWeight + 0.0)

            RageUI.List("Filtre", {"Aucun", "Inventaire", "Armes", "Vetements", "Accesoires"}, OneLifeMenu.Indexinvetory, nil, {}, true, {
                onListChange = function(index)
                    OneLifeMenu.Indexinvetory = index 
                    if index == 1 then 
                        OneLifeMenu.Item, OneLifeMenu.Weapon, OneLifeMenu.Vetement, OneLifeMenu.AccesoiresMenu = true, true, true, true
                    elseif index == 2 then 
                        OneLifeMenu.Item, OneLifeMenu.Weapon, OneLifeMenu.Vetement, OneLifeMenu.AccesoiresMenu = true, false, false, false
                    elseif index == 3 then 
                        OneLifeMenu.Item, OneLifeMenu.Weapon, OneLifeMenu.Vetement, OneLifeMenu.AccesoiresMenu = false, true, false, false
                    elseif index == 4 then 
                        OneLifeMenu.Item, OneLifeMenu.Weapon, OneLifeMenu.Vetement, OneLifeMenu.AccesoiresMenu = false, false, true, false
                    elseif index == 5 then 
                        OneLifeMenu.Item, OneLifeMenu.Weapon, OneLifeMenu.Vetement, OneLifeMenu.AccesoiresMenu = false, false, false, true
                    end
                end
            })

            if OneLifeMenu.Item then 
                if #ESX.PlayerData.inventory > 0 then 
                    RageUI.Separator("↓ Item ↓")
                    for k, v in pairs(ESX.PlayerData.inventory) do 
                        if v.count > 0 then 
                            RageUI.Button("> "..v.label.."", nil,  {RightLabel = "Quantité : ~r~x"..v.count..""}, not itemCooldown, {
                                onSelected = function()
                                    count = v.count 
                                    label  = v.label
                                    name = v.name
                                    remove = v.canRemove
                                    Wait(100)
                                end
                            }, actioninventory)
                        end
                    end
                else
                    RageUI.Separator("~r~Aucun Item")
                end
            end

            if OneLifeMenu.Weapon then 
                if #Player.WeaponData > 0 then 
                    RageUI.Separator("↓ Armes ↓")
                    for i = 1, #Player.WeaponData, 1 do
                        if HasPedGotWeapon(PlayerPedId(), Player.WeaponData[i].hash, false) then
                            local ammo = GetAmmoInPedWeapon(PlayerPedId(), Player.WeaponData[i].hash)
                            RageUI.Button("> "..Player.WeaponData[i].label, nil, { RightLabel = "Munition(s) : ~r~x"..ammo }, true, {
                                onSelected = function()
                                    ammoo = ammo 
                                    name = Player.WeaponData[i].name 
                                    label = Player.WeaponData[i].label
                                end
                            }, actionweapon)
                        end
                    end
                else
                    RageUI.Separator("~r~Aucune Armes")
                end
            end

            if OneLifeMenu.Vetement then 
                if ClothesPlayer ~= nil  then 
                    RageUI.Separator("Vetement")
                    for k, v in pairs(ClothesPlayer) do 
                        if v.label ~= nil and v.type == "vetement" and v.equip ~= "n" then 
                            RageUI.List("> Tenue "..v.label, {"Equiper", "Renomer", "Supprimer", "Donner"}, OneLifeMenu.IndexVetement, nil, {}, true, {
                                onListChange = function(Index)
                                    OneLifeMenu.IndexVetement = Index
                                end,
                                onSelected = function(Index)
                                    if Index == 1 then 
                                        startAnimAction('clothingtie', 'try_tie_neutral_a')
                                        Wait(1000)
                                        ExecuteCommand("me équipe une tenue")
                                        TriggerEvent("skinchanger:getSkin", function(skin)
                                            TriggerEvent("skinchanger:loadClothes", skin, json.decode(v.skin))
                                        end)
                                        TriggerEvent("skinchanger:getSkin", function(skin)
                                            TriggerServerEvent("esx_skin:save", skin)
                                        end)
                                    elseif Index == 2 then 
                                        local newname = KeyboardInput("Nouveau nom", "", 15)
                                        if newname then 
                                            TriggerServerEvent("ewen:RenameTenue", v.id, newname)
                                        end
                                    elseif Index == 3 then 
                                        TriggerServerEvent('ronflex:deletetenue', v.id)
                                    elseif Index == 4 then 
                                        local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                                        if closestDistance ~= -1 and closestDistance <= 3 then
                                            local closestPed = GetPlayerPed(closestPlayer)
                                            TriggerServerEvent("ronflex:donnertenue", GetPlayerServerId(closestPlayer), v.id)
                                            RageUI.CloseAll()
                                        else
                                            ESX.ShowNotification("Personne aux alentours")
                                        end
                                    end
                                end,
                              
                            })
                        end
                    end
                else
                    RageUI.Separator("~r~Aucune Tenue")
                end
            end

            if OneLifeMenu.AccesoiresMenu then 
                if ClothesPlayer ~= nil then 
                    RageUI.Separator("Accesoires")
                    if not ClothesPlayer ~= nil then
                        for k, v in pairs(ClothesPlayer) do 
                            if v.label ~= nil and v.type ~= "vetement" then 
                                RageUI.List("> "..v.type..' '..v.label, {"Equiper", "Renomer", "Supprimer", "Donner"}, OneLifeMenu.IndexVetement, nil, {}, true, {
                                    onListChange = function(Index)
                                        OneLifeMenu.IndexVetement = Index
                                    end,
                                    onSelected = function(Index)
                                        if Index == 1 then 
                                            startAnimAction('clothingtie', 'try_tie_neutral_a')
                                            Wait(1000)
                                            ExecuteCommand("me équipe un "..v.type)
                                            TriggerEvent("skinchanger:getSkin", function(skin)
                                                TriggerEvent("skinchanger:loadClothes", skin, json.decode(v.skin))
                                            end)
                                            TriggerEvent("skinchanger:getSkin", function(skin)
                                                TriggerServerEvent("esx_skin:save", skin)
                                            end)
                                        elseif Index == 2 then 
                                            local newname = KeyboardInput("Nouveau nom", "", 15)
                                            if newname then 
                                                TriggerServerEvent("ewen:RenameTenue", v.id, newname)
                                            end
                                        elseif Index == 3 then 
                                            ExecuteCommand("me supprime le/la "..v.type.." ")
                                            TriggerServerEvent('ronflex:deletetenue', v.id)
                                        elseif Index == 4 then 
                                            local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                                            if closestDistance ~= -1 and closestDistance <= 3 then
                                                local closestPed = GetPlayerPed(closestPlayer)
                                                TriggerServerEvent("ronflex:donnertenue", GetPlayerServerId(closestPlayer), v.id)
                                                RageUI.CloseAll()
                                            else
                                                ESX.ShowNotification("Personne aux alentours")
                                            end
                                        end
                                    end
                                })
                            end
                        end
                    end
                else
                    RageUI.Separator("~r~Aucun Accésoire")
                end
            end

        end, function()
        end)

        RageUI.IsVisible(portefeuille, function()

            local player, closestplayer = ESX.Game.GetClosestPlayer()

            RageUI.Separator('[Information Compte]')

            for i = 1, #ESX.PlayerData.accounts, 1 do
                if ESX.PlayerData.accounts[i].name == 'bank'  then
                    RageUI.Button('Argent en banque: ~p~'..ESX.PlayerData.accounts[i].money.."$", nil, {RightLabel = ""}, true, {})
                end
            end
			
            for i = 1, #ESX.PlayerData.accounts, 1 do
                if ESX.PlayerData.accounts[i].name == 'cash'  then
                    RageUI.Button('Argent en liquide: ~p~'..ESX.PlayerData.accounts[i].money.."$", nil, {RightLabel = ""}, true, {
                        onActive = function()
                            local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                            if closestDistance ~= -1 and closestDistance <= 3 then
                                PlayerMakrer(closestPlayer)
                            end
                        end,
                        onSelected = function()
                            local check, quantity = CheckQuantity(KeyboardInput("Nombres d'argent que vous voulez donner", '', 100))
                            if check then 
                                local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

                                if closestDistance ~= -1 and closestDistance <= 3 then
                                    local closestPed = GetPlayerPed(closestPlayer)
                                    if not IsPedSittingInAnyVehicle(closestPed) then
                                        TriggerServerEvent('esx:giveInventoryItem', GetPlayerServerId(closestPlayer), 'item_account', "cash", quantity)
                                        RageUI.GoBack()
                                    else
                                        ESX.ShowNotification("~r~Vous ne pouvez pas faire ceci dans un véhicule !")
                                    end
                                else
                                    ESX.ShowNotification('Aucun joueur proche !')
                                end
                            else
                                ESX.ShowNotification("Arguments Inssufisant")
                            end
                        end
                    })
                end
            end

            for i = 1, #ESX.PlayerData.accounts, 1 do
                if ESX.PlayerData.accounts[i].name == 'dirtycash'  then
                    RageUI.Button('Argent non déclaré: ~r~'..ESX.PlayerData.accounts[i].money.."$", nil, {RightLabel = ""}, true, {
                        onActive = function()
                            local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                            if closestDistance ~= -1 and closestDistance <= 3 then
                                PlayerMakrer(closestPlayer)
                            end
                        end,
                        onSelected = function()
                            local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                            local check, quantity = CheckQuantity(KeyboardInput("Nombres d'argent que vous voulez donner", '', 100))
                            if check then 
                                if closestDistance ~= -1 and closestDistance <= 3 then
                                    local closestPed = GetPlayerPed(closestPlayer)
                                    if not IsPedSittingInAnyVehicle(closestPed) then
                                        TriggerServerEvent('esx:giveInventoryItem', GetPlayerServerId(closestPlayer), 'item_account', "dirtycash", quantity)
                                        RageUI.GoBack()
                                    else
                                        ESX.ShowNotification("~r~Vous ne pouvez pas faire ceci dans un véhicule !")
                                    end
                                else
                                    ESX.ShowNotification('Aucun joueur proche !')
                                end
                            else
                                ESX.ShowNotification("Arguments Inssufisant")
                            end
                        end
                    })
                end
            end
			
            RageUI.Button("> Accéder à vos factures", nil, {RightLabel = "→→→"}, true, {
                onSelected = function()
                    ESX.TriggerServerCallback('ewen:getFactures', function(bills) BillData = bills end)
                end
            }, billingmenu)

            RageUI.Separator("[Information Personnelles]")

            RageUI.Button("Information Métier", "Accéder aux information de votre métier", {RightLabel = "→→→"}, true, {onSelected = function()RefreshMoney()end}, infojob)

            RageUI.Button("Information Organisation", "Accéder aux information de votre organisation", {RightLabel = "→→→"}, true, {onSelected = function()RefreshMoney2()end}, infojob2)

            RageUI.Button("> Gestion License", nil, {RightLabel = "→→→"}, true, {}, gestionlicense)

        end, function()
        end)

        RageUI.IsVisible(vehicle, function()

            local pVeh = GetVehiclePedIsUsing(PlayerPedId())

            RageUI.Button("Allumer / Eteindre le moteur", nil, {RightLabel = OneLifeMenu.Statut}, true, {
                onSelected = function()
                    if GetIsVehicleEngineRunning(pVeh) then
                        OneLifeMenu.Statut = "~r~Eteint"

                        SetVehicleEngineOn(pVeh, false, false, true)
                        SetVehicleUndriveable(pVeh, true)
                    elseif not GetIsVehicleEngineRunning(pVeh) then
                        OneLifeMenu.Statut = "~p~Allumé"

                        SetVehicleEngineOn(pVeh, true, false, true)
                        SetVehicleUndriveable(pVeh, false)
                    end
                end
            })

            RageUI.List("Ouvrir / Fermer porte", {"Avant gauche", "Avant Droite", "Arrière Gauche", "Arrière Droite", "Capot", "Coffre"}, OneLifeMenu.Indexdoor, nil, {}, true, {
                onListChange = function(index)
                    OneLifeMenu.Indexdoor = index 
                end,
                onSelected = function(index)
                    
                    if index == 1 then
                        if not OneLifeMenu.DoorState.FrontLeft then
                            OneLifeMenu.DoorState.FrontLeft = true
                            SetVehicleDoorOpen(pVeh, 0, false, false)
                        elseif OneLifeMenu.DoorState.FrontLeft then
                            OneLifeMenu.DoorState.FrontLeft = false
                            SetVehicleDoorShut(pVeh, 0, false, false)
                        end
                    elseif index == 2 then
                        if not OneLifeMenu.DoorState.FrontRight then
                            OneLifeMenu.DoorState.FrontRight = true
                            SetVehicleDoorOpen(pVeh, 1, false, false)
                        elseif OneLifeMenu.DoorState.FrontRight then
                            OneLifeMenu.DoorState.FrontRight = false
                            SetVehicleDoorShut(pVeh, 1, false, false)
                        end
                    elseif index == 3 then
                        if not OneLifeMenu.DoorState.BackLeft then
                            OneLifeMenu.DoorState.BackLeft = true
                            SetVehicleDoorOpen(pVeh, 2, false, false)
                        elseif OneLifeMenu.DoorState.BackLeft then
                            OneLifeMenu.DoorState.BackLeft = false
                            SetVehicleDoorShut(pVeh, 2, false, false)
                        end
                    elseif index == 4 then
                        if not OneLifeMenu.DoorState.BackRight then
                            OneLifeMenu.DoorState.BackRight = true
                            SetVehicleDoorOpen(pVeh, 3, false, false)
                        elseif OneLifeMenu.DoorState.BackRight then
                            OneLifeMenu.DoorState.BackRight = false
                            SetVehicleDoorShut(pVeh, 3, false, false)
                        end
                    elseif index == 5 then 
                        if not OneLifeMenu.DoorState.Hood then
                            OneLifeMenu.DoorState.Hood = true
                            SetVehicleDoorOpen(pVeh, 4, false, false)
                        elseif OneLifeMenu.DoorState.Hood then
                            OneLifeMenu.DoorState.Hood = false
                            SetVehicleDoorShut(pVeh, 4, false, false)
                        end
                    elseif index == 6 then 
                        if not OneLifeMenu.DoorState.Trunk then
                            OneLifeMenu.DoorState.Trunk = true
                            SetVehicleDoorOpen(pVeh, 5, false, false)
                        elseif OneLifeMenu.DoorState.Trunk then
                            OneLifeMenu.DoorState.Trunk = false
                            SetVehicleDoorShut(pVeh, 5, false, false)
                        end
                    end
                end
            })

            RageUI.Button("Fermer toutes les portes", nil, {RightLabel =  "→→→"}, true, {
                onSelected = function ()
                    for door = 0, 7 do
                        SetVehicleDoorShut(pVeh, door, false)
                    end
                end
            })

            RageUI.List("Limitateur", OneLifeMenu.voiture_limite, OneLifeMenu.LimitateurIndex, nil, {}, true, {
                onListChange = function(i, item)
                    OneLifeMenu.LimitateurIndex = i
                end,

                onSelected = function(i, item)
                    if i == 1 then
                        SetEntityMaxSpeed(GetVehiclePedIsIn(PlayerPedId(), false), 50.0/3.6)
                        ESX.ShowNotification("Limitateur de vitesse défini sur ~p~50 km/h")
                    elseif i == 2 then  
                        SetEntityMaxSpeed(GetVehiclePedIsIn(PlayerPedId(), false), 80.0/3.6)
                        ESX.ShowNotification("Limitateur de vitesse défini sur ~p~80 km/h")
                    elseif i == 3  then
                        SetEntityMaxSpeed(GetVehiclePedIsIn(PlayerPedId(), false), 130.0/3.6)
                        ESX.ShowNotification("Limitateur de vitesse défini sur ~p~130 km/h")
                    elseif i == 4 then
                        local speed = KeyboardInput("Indiquer la vitesse", "", 10)
                        if speed ~= nil or speed ~= tostring("") then 
                            SetEntityMaxSpeed(GetVehiclePedIsIn(PlayerPedId(), false), ESX.Math.Round(speed, 1)/3.6)
                            ESX.ShowNotification("Limitateur de vitesse défini sur ~p~"..speed..'km/h')
                        else
                            return
                        end
                    elseif i == 5 then 
                        SetEntityMaxSpeed(GetVehiclePedIsIn(PlayerPedId(), false), 10000.0/3.6)    
                        ESX.ShowNotification("Limitateur de vitesse désactivé")
                    end
                end
            })

   
        
        end, function()
        end)

        RageUI.IsVisible(vetmenu, function()

            RageUI.List(" Vetement", {"Haut", "Bas", "Chaussures", "Sac", "Giltet par balle"}, OneLifeMenu.IndexClothes, nil, {LeftBadge = RageUI.BadgeStyle.Clothes}, true, {
                onListChange = function(index)
                    OneLifeMenu.IndexClothes = index 
                end, 
                onSelected = function(index)
                    ESX.TriggerServerCallback("esx_skin:getPlayerSkin", function(skin)
                        TriggerEvent("skinchanger:getSkin", function(skina)
                            if index == 1 then 
                                if skin.torso_1 ~= skina.torso_1 then
                                    ExecuteCommand("me remet son Haut")
                                    TriggerEvent("skinchanger:loadClothes", skina, { ["torso_1"] = skin.torso_1, ["torso_2"] = skin.torso_2, ["tshirt_1"] = skin.tshirt_1, ["tshirt_2"] = skin.tshirt_2, ["arms"] = skin.arms })
                                else
                                    ExecuteCommand("me retire son Haut")
                                    if skin.sex == 0 then
                                        TriggerEvent("skinchanger:loadClothes", skina, { ["torso_1"] = 15, ["torso_2"] = 0, ["tshirt_1"] = 15, ["tshirt_2"] = 0, ["arms"] = 15 })
                                    else
                                        TriggerEvent("skinchanger:loadClothes", skina, { ["torso_1"] = 15, ["torso_2"] = 0, ["tshirt_1"] = 15, ["tshirt_2"] = 0, ["arms"] = 15 })
                                    end
                                end
                            elseif index == 2 then 
                                if skin.pants_1 ~= skina.pants_1 then
                                    ExecuteCommand("me remet son Pantalon")
                                    TriggerEvent("skinchanger:loadClothes", skina, { ["pants_1"] = skin.pants_1, ["pants_2"] = skin.pants_2 })
                                else
                                    ExecuteCommand("me retire son Pantalon")
                                    if skin.sex == 0 then
                                        TriggerEvent("skinchanger:loadClothes", skina, { ["pants_1"] = 63, ["pants_2"] = 0 })
                                    else
                                        TriggerEvent("skinchanger:loadClothes", skina, { ["pants_1"] = 15, ["pants_2"] = 0 })
                                    end
                                end
                            elseif index == 3 then 
                                if skin.shoes_1 ~= skina.shoes_1 then
                                    ExecuteCommand("me remet ses Chaussures")
                                    TriggerEvent("skinchanger:loadClothes", skina, { ["shoes_1"] = skin.shoes_1, ["shoes_2"] = skin.shoes_2 })
                                else
                                    if skin.sex == 0 then
                                        ExecuteCommand("me enlève ses Chaussures")
                                        TriggerEvent("skinchanger:loadClothes", skina, { ["shoes_1"] = 49, ["shoes_2"] = 0 })
                                    else
                                        TriggerEvent("skinchanger:loadClothes", skina, { ["shoes_1"] = 46, ["shoes_2"] = 0 })
                                    end
                                end
                            elseif index == 4 then
                                if skin.bags_1 ~= skina.bags_1 then
                                    ExecuteCommand("me retire son Sac")
                                    TriggerEvent("skinchanger:loadClothes", skina, { ["bags_1"] = skin.bags_1, ["bags_2"] = skin.bags_2 })
                                else
                                    ExecuteCommand("me retire son Sac")
                                    TriggerEvent("skinchanger:loadClothes", skina, { ["bags_1"] = 0, ["bags_2"] = 0 })
                                end
                            elseif index == 5 then 
                                if skin.bproof_1 ~= skina.bproof_1 then
                                    ExecuteCommand("me retire son Gilet par balle")
                                    TriggerEvent("skinchanger:loadClothes", skina, { ["bproof_1"] = skin.bproof_1, ["bproof_2"] = skin.bproof_2 })
                                else
                                    ExecuteCommand("me retire son Gilet par balle")
                                    TriggerEvent("skinchanger:loadClothes", skina, { ["bproof_1"] = 0, ["bproof_2"] = 0 })
                                end
                            end
                        end)
                    end)
                end
            })

            RageUI.List(' Accesoires', {"Masque","Chapeau", "Lunette", "Boucle d'oreilles", "Chaine"}, OneLifeMenu.Indexaccesories, nil, {LeftBadge = RageUI.BadgeStyle.Mask}, true, {
                onListChange = function(Index)
                    OneLifeMenu.Indexaccesories = Index;
                end,

                onSelected = function(Index)
                    if Index == 1 then
                        Wait(250)
                        setAccess('mask', plyPed)
                    elseif Index == 2 then
                        Wait(250)
                        setAccess('helmet', plyPed)
                    elseif Index == 3 then
                        Wait(250)
                        setAccess('glasses', plyPed)
                    elseif Index == 4 then
                        Wait(250)
                        setAccess('ears', plyPed)
                    elseif Index == 5 then
                        Wait(250)
                        setAccess('chain', plyPed)
                    end
                end
            })

        end, function()
        end)

        RageUI.IsVisible(radio, function()

            RageUI.Button("Allumer / Eteindre", "Vous permet d'allumer ou d'éteindre la radio", {RightLabel = "→→→"}, true, {
                onSelected = function()
                    if not OneLifeMenu.TickRadio then 
                        OneLifeMenu.TickRadio = true 
                        pma:setVoiceProperty("radioEnabled", true)
                        ESX.ShowNotification("~p~OneLife~s~~n~Radio Allumé !")
                    else
                        OneLifeMenu.TickRadio = false
                        pma:setRadioChannel(0)
                        pma:setVoiceProperty("radioEnabled", false)
                        ESX.ShowNotification("~p~OneLife~s~~n~Radio Eteinte !")
                    end
                end
            })

            if OneLifeMenu.TickRadio then
                RageUI.Separator("Radio: ~p~Allumée")

                if OneLifeMenu.Bruitages then 
                    RageUI.Separator("Bruitages: ~p~Activés")
                else
                    RageUI.Separator("Bruitages: ~r~Désactivés")
                end

                if OneLifeMenu.VolumeRadio*100 <= 20 then 
                    ColorRadio = "~p~" 
                elseif OneLifeMenu.VolumeRadio*100 <= 45 then 
                    ColorRadio ="~y~" 
                elseif OneLifeMenu.VolumeRadio*100 <= 65 then 
                    ColorRadio ="~o~" 
                elseif OneLifeMenu.VolumeRadio*100 <= 100 then 
                    ColorRadio ="~r~" 
                end 

                RageUI.Separator("Volume: "..ColorRadio..ESX.Math.Round(OneLifeMenu.VolumeRadio*100).."~s~ %")

                RageUI.Button("Se connecter à une fréquence ", "Choissisez votre fréquence", {RightLabel = OneLifeMenu.Frequence}, true, {
                    onSelected = function()
                                local verif, Frequence = CheckQuantity(KeyboardInput("Fréquence", "", 10))
                                local PlayerData = ESX.GetPlayerData(_source)
                                local restricted = {}
                                
                                if Frequence > 500 then
                                    return
                                end
                                
                                for i,v in pairs(OneLifeMenu.jobChannels) do
                                    if Frequence >= v.min and Frequence <= v.max then
                                        table.insert(restricted, v)
                                    end
                                end
                            
                                if #restricted > 0 then
                                    for i,v in pairs(restricted) do
                                        if PlayerData.job.name == v.job and Frequence >= v.min and Frequence <= v.max then
                                            OneLifeMenu.Frequence = tostring(Frequence)
                                            pma:setRadioChannel(Frequence)
                                            ESX.ShowNotification("~p~OneLife~s~~n~Fréquence définie sur "..Frequence.." MHZ")
                                            currentChannel = Frequence
                                            break
                                        elseif i == #restricted then
                                            ESX.ShowNotification('~p~OneLife~s~~n~Echec de la connexion a la fréquence')
                                            break
                                        end
                                    end
                                else
                                    OneLifeMenu.Frequence = tostring(Frequence)
                                    pma:setRadioChannel(Frequence)
                                    ESX.ShowNotification("~p~OneLife~s~~n~Fréquence définie sur "..Frequence.." MHZ")
                                    currentChannel = Frequence
                                end
                    end
                })

                RageUI.Button("Se déconnecter de la fréquence", "Vous permet de déconnecter de votre fréquence actuelle", {RightLabel = "→→→"}, true, {
                    onSelected = function()
                        pma:setRadioChannel(0)
                        OneLifeMenu.Frequence = "0"
                        ESX.ShowNotification("Vous vous êtes déconnecter de la fréquence")
                    end
                })

                RageUI.Button("Activer les bruitages", "Vous permet d'activer les bruitages'", {RightLabel = "→→→"}, true, {
                    onSelected = function()
                        if OneLifeMenu.Bruitages then 
                            OneLifeMenu.Bruitages = false
                            pma:setVoiceProperty("micClicks", false)
                            ESX.ShowNotification("Bruitages radio désactives")
                        else
                            OneLifeMenu.Bruitages = true 
                            ESX.ShowNotification("Bruitages radio activés")
                            pma:setVoiceProperty("micClicks", true)
                        end
                    end
                })
            else
                RageUI.Separator("Radio: ~r~Eteinte")
            end

        end, function()
            RageUI.PercentagePanel(OneLifeMenu.VolumeRadio, 'Volume', '0%', '100%', {
                onProgressChange = function(Percentage)
                    OneLifeMenu.VolumeRadio = Percentage
                    pma:setRadioVolume(Percentage)
                end
            }, 5) 
        end)

        RageUI.IsVisible(pubs, function()

            RageUI.Button("Twt", nil, {RightLabel = "→→→"}, true, {
                onSelected = function()
                    local info = 'Twitter'
                    local message = KeyboardInput('Veuillez mettre le messsage à envoyer', '', 250)
                    if message ~= nil and message ~= "" then
                        TriggerServerEvent('Twt', info, message)
                    end
                end
            })

            RageUI.Button("Twt Anonyme", nil, {RightLabel = "→→→"}, true, {
                onSelected = function()
                    local info = 'Anonyme'
                    local message = KeyboardInput('Veuillez mettre le messsage à envoyer', '', 250)
                    if message ~= nil and message ~= "" then
                        TriggerServerEvent('Ano', info, message)
                    end
                end
            })

            RageUI.Button("Pub entreprise", nil, {RightLabel = "→→→"}, true, {
                onSelected = function()
                    local info = 'Entreprise'
                    local message = KeyboardInput('Veuillez mettre le messsage à envoyer', '', 250)
                    if message ~= nil and message ~= "" then
                        TriggerServerEvent('Entreprise', info, message)
                    end
                end
            })

            if (ESX.PlayerData.job and ESX.PlayerData.job.name == 'police') then
                RageUI.Button("LSPD", nil, {RightLabel = "→→→"}, true, {
                    onSelected = function()
                        local info = 'LSPD'
                        local message = KeyboardInput('Veuillez mettre le messsage à envoyer', '', 250)
                        if message ~= nil and message ~= "" then
                            TriggerServerEvent('Police', info, message)
                        end
                    end
                })
            end

        end, function()
        end)

        RageUI.IsVisible(diversmenu, function()

            RageUI.Checkbox("Activer le radar", "Vous permet d'activer ou de désactiver la minimap", OneLifeMenu.Radar, {}, {
                onChecked = function()
                end,
                onUnChecked = function()
                end,
                onSelected = function(Index)
                    DisplayRadar(OneLifeMenu.Radar)
                    OneLifeMenu.Radar = Index
                end
                
            })

            RageUI.Checkbox("Activer l'HUD", "Vous permet d'activer ou de désactiver l'HUD", OneLifeMenu.ui, {}, {
                onChecked = function()
                end,
                onUnChecked = function()
                end,
                onSelected = function(Index)
                    TriggerEvent("tempui:toggleUi", not OneLifeMenu.ui)
                    OneLifeMenu.ui = Index
                end

            })

            RageUI.Checkbox('Mode cinématique', nil, cinemamode, {}, {
                onChecked = function()
                    ExecuteCommand('noir')
                    cinemamode = true
                end,
                onUnChecked = function()
                    ExecuteCommand('noir')
                    cinemamode = false
                end,
            })
            RageUI.Checkbox('Mode drift', nil, driftmode, {}, {
                onChecked = function()
                    driftmode = not driftmode
                end,
                onUnChecked = function()
                    driftmode = false
                end,
                onSelected = function(Index)
                    driftmode = Index
                end
            })
            RageUI.Checkbox('Désactiver les coups de crosse', nil, coupCrosse, {}, {
                onChecked = function()
                    Citizen.CreateThread(function()
                        while coupCrosse do
                            Citizen.Wait(0)
                            local ped = PlayerPedId()
                            if IsPedArmed(ped, 6) then
                                DisableControlAction(1, 140, true)
                                DisableControlAction(1, 141, true)
                                DisableControlAction(1, 142, true)
                            end
                        end
                    end)
                end,
                onUnChecked = function()
                    coupCrosse = false
                end,
                onSelected = function(Index)
                    coupCrosse = Index
                end
            })

        end, function()
        end)
        
        RageUI.IsVisible(gestionjob, function()
        
            if ESX.PlayerData.job.grade_name == "boss" then 

                if societymoney ~= nil then
                    RageUI.Separator("Argent dans la société : ~p~"..societymoney.."$")
                end

                RageUI.Separator("[Entreprise]")

                RageUI.Button("Recruter un employé", nil, {RightLabel = "→→→"}, true, {
                    onActive = function()
                        local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                        if closestDistance ~= -1 and closestDistance <= 3 then
                            PlayerMakrer(closestPlayer)
                        end
                    end, 
                    onSelected = function()
                        local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                        if closestDistance ~= -1 and closestDistance <= 3 then
                            TriggerServerEvent("KorioZ-PersonalMenu:Boss_recruterplayer", GetPlayerServerId(closestPlayer), ESX.PlayerData.job.name)
                        else
                            ESX.ShowNotification("Aucun joueur à proximité")
                        end
                    end
                })

                RageUI.Button("Virer un employé", nil, {RightLabel = "→→→"}, true, {
                    onActive = function()
                        local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                        if closestDistance ~= -1 and closestDistance <= 3 then
                            PlayerMakrer(closestPlayer)
                        end
                    end, 
                    onSelected = function()
                        local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                        if closestDistance ~= -1 and closestDistance <= 3 then
                            TriggerServerEvent("KorioZ-PersonalMenu:Boss_virerplayer", GetPlayerServerId(closestPlayer))
                        else
                            ESX.ShowNotification("Aucun joueur à proximité")
                        end
                    end
                })

                RageUI.Button("Promouvroir un employé", nil, {RightLabel = "→→→"}, true, {
                    onActive = function()
                        local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                        if closestDistance ~= -1 and closestDistance <= 3 then
                            PlayerMakrer(closestPlayer)
                        end
                    end, 
                    onSelected = function()
                        local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                        if closestDistance ~= -1 and closestDistance <= 3 then
                            TriggerServerEvent("KorioZ-PersonalMenu:Boss_promouvoirplayer", GetPlayerServerId(closestPlayer))
                        else
                            ESX.ShowNotification("Aucun joueur à proximité")
                        end
                    end
                })

                RageUI.Button("Rétrograder un employé", nil, {RightLabel = "→→→"}, true, {
                    onActive = function()
                        local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                        if closestDistance ~= -1 and closestDistance <= 3 then
                            PlayerMakrer(closestPlayer)
                        end
                    end, 
                    onSelected = function()
                        local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                        if closestDistance ~= -1 and closestDistance <= 3 then
                            TriggerServerEvent("KorioZ-PersonalMenu:Boss_destituerplayer", GetPlayerServerId(closestPlayer))
                        else
                            ESX.ShowNotification("Aucun joueur à proximité")
                        end
                    end
                })
            end
        end, function()
        end)


        RageUI.IsVisible(gestionjob2, function()

            if ESX.PlayerData.job2.grade_name == "boss" then 

                if societymoney2 ~= nil then
                    RageUI.Separator("Argent dans le coffre~s~ : ~p~"..societymoney2.."$")
                end

                RageUI.Separator("[Organisation]")

                RageUI.Button("Recruter un employé", nil, {RightLabel = "→→→"}, true, {
                    onActive = function()
                        local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                        if closestDistance ~= -1 and closestDistance <= 3 then
                            PlayerMakrer(closestPlayer)
                        end
                    end, 
                    onSelected = function()
                        local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                        if closestDistance ~= -1 and closestDistance <= 3 then
                            TriggerServerEvent("KorioZ-PersonalMenu:Boss_recruterplayer2", GetPlayerServerId(closestPlayer), ESX.PlayerData.job2.name)
                        else
                            ESX.ShowNotification("Aucun joueur à proximité")
                        end
                    end
                })

                RageUI.Button("Virer un employé", nil, {RightLabel = "→→→"}, true, {
                    onActive = function()
                        local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                        if closestDistance ~= -1 and closestDistance <= 3 then
                            PlayerMakrer(closestPlayer)
                        end
                    end, 
                    onSelected = function()
                        local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                        if closestDistance ~= -1 and closestDistance <= 3 then
                            TriggerServerEvent("KorioZ-PersonalMenu:Boss_virerplayer2", GetPlayerServerId(closestPlayer))
                        else
                            ESX.ShowNotification("Aucun joueur à proximité")
                        end
                    end
                })

                RageUI.Button("Promouvroir un employé", nil, {RightLabel = "→→→"}, true, {
                    onActive = function()
                        local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                        if closestDistance ~= -1 and closestDistance <= 3 then
                            PlayerMakrer(closestPlayer)
                        end
                    end, 
                    onSelected = function()
                        local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                        if closestDistance ~= -1 and closestDistance <= 3 then
                            TriggerServerEvent("KorioZ-PersonalMenu:Boss_promouvoirplayer2", GetPlayerServerId(closestPlayer))
                        else
                            ESX.ShowNotification("Aucun joueur à proximité")
                        end
                    end
                })

                RageUI.Button("Rétrograder un employé", nil, {RightLabel = "→→→"}, true, {
                    onActive = function()
                        local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                        if closestDistance ~= -1 and closestDistance <= 3 then
                            PlayerMakrer(closestPlayer)
                        end
                    end, 
                    onSelected = function()
                        local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                        if closestDistance ~= -1 and closestDistance <= 3 then
                            TriggerServerEvent("KorioZ-PersonalMenu:Boss_destituerplayer2", GetPlayerServerId(closestPlayer))
                        else
                            ESX.ShowNotification("Aucun joueur à proximité")
                        end
                    end
                })
            end

        end, function()
        end)

        RageUI.IsVisible(actioninventory, function()

            RageUI.Separator("Nom : ~p~"..tostring(label).." ~s~/ Quantité : ~p~"..tostring(count).."")

            RageUI.Button("> Utilser", nil, {RightLabel = "→→→"}, not itemCooldown, {
                onSelected = function()
                    itemCooldown = true
                    typee = "use"
                    TriggerServerEvent('esx:useItem', name)
                    ExecuteCommand("me utilise x1 "..label)
                    count = count - 1
                    if count < 0 then 
                        RageUI.GoBack()
                    end
                    Citizen.SetTimeout(1500, function() itemCooldown = false end)
                end
            })

            RageUI.Button("> Donner", nil, {RightLabel = "→→→"}, not itemCooldown, {
                onActive = function()
                    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                    if closestDistance ~= -1 and closestDistance <= 3 then
                        PlayerMakrer(closestPlayer)
                    end
                end,
                onSelected = function()
                    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                    local check, quantity = CheckQuantity(KeyboardInput("", "", 20))
                    if check then 
                        local closestPed = GetPlayerPed(closestPlayer)
                        if tonumber(quantity) > tonumber(count) then 
                            ESX.ShowNotification('Vous n\'en n\'avez pas assez')
                        else
                            --if not ESX.ContribItem(name) then 
                                itemCooldown = true
                                TriggerServerEvent('esx:giveInventoryItem', GetPlayerServerId(closestPlayer), 'item_standard', name, quantity)
                                ExecuteCommand("me donne un/une "..label.." à la personne")
                                RageUI.GoBack()
                                Citizen.SetTimeout(1500, function() itemCooldown = false end)
                            --else
                                --ESX.ShowNotification('~p~OneLife ~w~~n~Vous ne pouvez pas donner cette objets')
                            --end
                        end
                    else
                        ESX.ShowNotification('Arguments Manquants !')
                    end
                end
            })
            
        end , function()
        end)

        RageUI.IsVisible(actionweapon, function()
            RageUI.Separator("Nom : ~p~"..tostring(label).." ~s~/ Balles : ~p~"..tostring(ammoo).."")

            if PermanantWeapon[name] ~= nil then 
                RageUI.Separator("Vous ne pouvez pas donner cette arme")

            else
                RageUI.Button("> Donner", nil, {RightLabel = "→→→"}, true, {
                    onActive = function()
                        local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                        if closestDistance ~= -1 and closestDistance <= 3 then
                            PlayerMakrer(closestPlayer)
                        end
                    end,
                    onSelected = function()
                        local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
    
                        if closestDistance ~= -1 and closestDistance <= 3 then
                            local closestPed = GetPlayerPed(closestPlayer)
                            TriggerServerEvent("esx:giveInventoryItem", GetPlayerServerId(closestPlayer), "item_weapon", name, nil)
                            RageUI.CloseAll()
                        else
                            ESX.ShowNotification("Personne aux alentours")
                        end
                    end
                })
            end

        end, function()
        end)

        RageUI.IsVisible(infojob, function()
            ESX.PlayerData = ESX.GetPlayerData()
            
            RageUI.Button("Votre Métier: ", nil, {RightLabel = "~p~"..ESX.PlayerData.job.label}, true, {})
            RageUI.Button("Votre Grade: ", nil, {RightLabel = "~p~"..ESX.PlayerData.job.grade_label}, true, {})

        end, function()
        end)


        RageUI.IsVisible(infojob2, function()
            
            RageUI.Button("Votre Organisation: ", nil, {RightLabel = "~p~"..ESX.PlayerData.job2.label}, true, {})
            RageUI.Button("Votre Rang: ", nil, {RightLabel = "~p~"..ESX.PlayerData.job2.grade_label}, true, {})

            
        end, function()
        end)

        RageUI.IsVisible(billingmenu, function()
            if #BillData ~= 0 then
                for i = 1, #BillData, 1 do
                    RageUI.Button(BillData[i].label, nil, {RightLabel = '$' .. ESX.Math.GroupDigits(BillData[i].amount)}, true, {
                        onSelected = function()
                        ESX.TriggerServerCallback('esx_billing:payBill', function()
                            RageUI.GoBack()
                        end, BillData[i].id)
                    end})
                end
            else
                RageUI.Separator('~r~')
                RageUI.Separator('~r~Vous n\'avez pas de facture')
                RageUI.Separator('~r~')
            end
        end, function()
        end)
        
        RageUI.IsVisible(gestionlicense, function()

            RageUI.Separator("~p~↓ Carte D'identité ↓")
            
            RageUI.Button("> Montrer sa carte d'identité", nil, {RightLabel = '→→→'}, true, {
                onActive = function()
                    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                    if closestDistance ~= -1 and closestDistance <= 3 then
                        PlayerMakrer(closestPlayer)
                    end
                end,
                onSelected = function()
                    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                    if closestDistance ~= -1 and closestDistance <= 3.0 then
                        TriggerServerEvent("jsfour-idcard:open", GetPlayerServerId(PlayerId()), GetPlayerServerId(closestPlayer))
                    else
                        ESX.ShowNotification("Aucun joueurs aux alentours")
                    end
                end
            })

            RageUI.Button("> Regarder sa carte d'identité", nil, {RightLabel = "→→→"}, true, {
                onSelected = function()
                    TriggerServerEvent("jsfour-idcard:open", GetPlayerServerId(PlayerId()), GetPlayerServerId(PlayerId()))
                end
            })

            RageUI.Separator("~p~↓ Permis de conduire ↓")

            RageUI.Button("> Montrer son permis de conduire", nil, {RightLabel = '→→→'}, true, {
                onActive = function()
                    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                    if closestDistance ~= -1 and closestDistance <= 3 then
                        PlayerMakrer(closestPlayer)
                    end
                end,
                onSelected = function()
                    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                    if closestDistance ~= -1 and closestDistance <= 3.0 then
                        TriggerServerEvent("jsfour-idcard:open", GetPlayerServerId(PlayerId()), GetPlayerServerId(closestPlayer), "driver")
                    else
                        ESX.ShowNotification("Aucun joueurs aux alentours")
                    end
                end
            })

            RageUI.Button("> Regarder son permis de conduire", nil, {RightLabel = "→→→"}, true, {
                onSelected = function()
                    TriggerServerEvent("jsfour-idcard:open", GetPlayerServerId(PlayerId()), GetPlayerServerId(PlayerId()), "driver")
                end
            })

            RageUI.Separator("~p~↓ Permis de port d'armes ↓")

            RageUI.Button("> Montrer son permis de port d'armes", nil, {RightLabel = '→→→'}, true, {
                onActive = function()
                    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                    if closestDistance ~= -1 and closestDistance <= 3 then
                        PlayerMakrer(closestPlayer)
                    end
                end,
                onSelected = function()
                    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                    if closestDistance ~= -1 and closestDistance <= 3.0 then
                        TriggerServerEvent("jsfour-idcard:open", GetPlayerServerId(PlayerId()), GetPlayerServerId(closestPlayer), "weapon")
                    else
                        ESX.ShowNotification("Aucun joueurs aux alentours")
                    end
                end
            })

            RageUI.Button("> Regarder son permis de port d'armes", nil, {RightLabel = "→→→"}, true, {
                onSelected = function()
                    TriggerServerEvent("jsfour-idcard:open", GetPlayerServerId(PlayerId()), GetPlayerServerId(PlayerId()), "weapon")
                end
            })
        
        end, function()
        end)
        if not RageUI.Visible(mainf5) and 
        not RageUI.Visible(invetory) and 
        not RageUI.Visible(portefeuille) and 
        not RageUI.Visible(vetmenu) and 
        not RageUI.Visible(vehicle) and
        not RageUI.Visible(radio) and
        not RageUI.Visible(pubs) and 
        not RageUI.Visible(diversmenu) and 

        not RageUI.Visible(actioninventory) and 
        not RageUI.Visible(infojob) and 
        not RageUI.Visible(infojob2) and 
        not RageUI.Visible(gestionjob) and
        not RageUI.Visible(gestionjob2) and 
        not RageUI.Visible(billingmenu) and 

        not RageUI.Visible(actionweapon) and 
        not RageUI.Visible(gestionlicense) then 
            mainf5 = RMenu:DeleteType("mainf5")
        end
    end
end


Keys.Register("F5", "Menu_Interacion", "Menu F5", function()
    if not PlayerIsDead then 
        openMenuF5()
    end
end)

Citizen.CreateThread(function()
    while true do 
        Wait(5000)
        TriggerEvent("skinchanger:getSkin", function(skin)
            if skin.bags_1 == 0 then
                if ESX.PlayerData.maxWeight ~= 24 then 
                    TriggerServerEvent('ewen:ChangeWeightInventory', 24)
                end
            else
                if ESX.PlayerData.maxWeight ~= 40 then 
                    TriggerServerEvent('ewen:ChangeWeightInventory', 40)
                end
            end
        end)
        if GetCurrentWeight() > ESX.PlayerData.maxWeight then
            DrawMissionText('~p~Vous êtes trop lourd, Vous ne pouver plus courrir', 5000)
            DisableControlAction(0, 22, true)
            DisableControlAction(0, 21, true)
        end
    end
end)

local NoCourir = false
Citizen.CreateThread(function()
    while true do 
        Wait(5000)
        TriggerEvent("skinchanger:getSkin", function(skin)
            if skin.bags_1 == 0 then
                if ESX.PlayerData.maxWeight ~= 24 then 
                    TriggerServerEvent('ewen:ChangeWeightInventory', 24)
                end
            else
                if ESX.PlayerData.maxWeight ~= 40 then 
                    TriggerServerEvent('ewen:ChangeWeightInventory', 40)
                end
            end
        end)
        if GetCurrentWeight() > ESX.PlayerData.maxWeight then
            DrawMissionText('~p~Vous êtes trop lourd, Vous ne pouver plus courrir', 5000)
            NoCourir = true
        else 
            NoCourir = false
        end
    end
end)

Citizen.CreateThread(function()
	while true do
		if NoCourir then
			Citizen.Wait(10)
		else
			Wait(5000)
		end

		if NoCourir then
			DisableControlAction(0, 21, true) -- INPUT_SPRINT
			DisableControlAction(0, 22, true) -- INPUT_JUMP
			DisableControlAction(0, 24, true) -- INPUT_ATTACK
			DisableControlAction(0, 44, true) -- INPUT_COVER
			DisableControlAction(0, 45, true) -- INPUT_RELOAD
			DisableControlAction(0, 140, true) -- INPUT_MELEE_ATTACK_LIGHT
			DisableControlAction(0, 141, true) -- INPUT_MELEE_ATTACK_HEAVY
			DisableControlAction(0, 142, true) -- INPUT_MELEE_ATTACK_ALTERNATE
			DisableControlAction(0, 143, true) -- INPUT_MELEE_BLOCK
			DisableControlAction(0, 144, true) -- PARACHUTE DEPLOY
			DisableControlAction(0, 145, true) -- PARACHUTE DETACH
			DisableControlAction(0, 243, true) -- INPUT_ENTER_CHEAT_CODE
			DisableControlAction(0, 257, true) -- INPUT_ATTACK2
			DisableControlAction(0, 263, true) -- INPUT_MELEE_ATTACK1
			DisableControlAction(0, 264, true) -- INPUT_MELEE_ATTACK2
			DisableControlAction(0, 73, true) -- INPUT_X
		end
	end
end)