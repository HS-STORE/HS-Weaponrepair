local QBCore = exports['qb-core']:GetCoreObject()
local isRepairing = false
local spawnedProps = {}

-- إنشاء الأوبجكت عند بداية السكربت
CreateThread(function()
    for _, loc in ipairs(Config.RepairLocations) do
        local model = GetHashKey(loc.prop)
        RequestModel(model)
        while not HasModelLoaded(model) do
            Wait(10)
        end
        
        local propObj = CreateObject(model, loc.coords.x, loc.coords.y, loc.coords.z - 1.0, false, false, false)
        SetEntityHeading(propObj, loc.heading)
        FreezeEntityPosition(propObj, true)
        SetEntityAsMissionEntity(propObj, true, true)
        table.insert(spawnedProps, propObj)
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        for _, prop in ipairs(spawnedProps) do
            if DoesEntityExist(prop) then
                DeleteEntity(prop)
            end
        end
    end
end)

-- فتح القائمة
function OpenRepairMenu()
    local playerPed = PlayerPedId()
    local weaponHash = GetSelectedPedWeapon(playerPed)

    if weaponHash == GetHashKey("WEAPON_UNARMED") or weaponHash == 0 then
        QBCore.Functions.Notify("يجب أن تكون حامل سلاح في يدك!", "error")
        return
    end

    -- جلب اسم السلاح من QBCore
    local weaponItem = nil
    local PlayerData = QBCore.Functions.GetPlayerData()
    if PlayerData and PlayerData.items then
        for _, item in pairs(PlayerData.items) do
            if item and item.type == "weapon" and GetHashKey(item.name) == weaponHash then
                weaponItem = item
                break
            end
        end
    end

    local weaponName = weaponItem and weaponItem.name or "weapon_pistol"

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "open",
        price = Config.RepairPrice,
        weapon = weaponName
    })
end

RegisterNUICallback('closeUI', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('confirmRepair', function(data, cb)
    if isRepairing then return end

    QBCore.Functions.TriggerCallback('suol-weaponrepair:server:checkMoney', function(hasMoney)
        if hasMoney then
            SetNuiFocus(false, false)
            SendNUIMessage({ action = "close" })
            isRepairing = true

            QBCore.Functions.Progressbar("repairing_weapon", "جاري تصليح السلاح...", 7000, false, true, {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            }, {
                animDict = "mini@repair",
                anim = "fixing_a_ped",
                flags = 16,
            }, {}, {}, function() -- Done
                StopAnimTask(PlayerPedId(), "mini@repair", "fixing_a_ped", 1.0)
                TriggerServerEvent('suol-weaponrepair:server:repairWeapon')
                isRepairing = false
            end, function() -- Cancel
                StopAnimTask(PlayerPedId(), "mini@repair", "fixing_a_ped", 1.0)
                QBCore.Functions.Notify("تم إلغاء التصليح!", "error")
                isRepairing = false
            end)
        else
            QBCore.Functions.Notify("لا تملك المبلغ الكافي ($" .. Config.RepairPrice .. ")!", "error")
        end
    end)
    cb('ok')
end)

-- التفاعل مع الطاولة
CreateThread(function()
    while true do
        local sleep = 1000
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)

        for _, loc in ipairs(Config.RepairLocations) do
            local dist = #(coords - loc.coords)
            if dist < 4.0 then
                sleep = 0
                if dist < 1.8 then
                    QBCore.Functions.DrawText3D(loc.coords.x, loc.coords.y, loc.coords.z + 0.5, "[~p~E~w~] SUOL RP Weapon Repair")
                    if IsControlJustPressed(0, 38) then
                        OpenRepairMenu()
                    end
                end
            end
        end
        Wait(sleep)
    end
end)