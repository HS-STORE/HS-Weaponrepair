local QBCore = exports['qb-core']:GetCoreObject()

-- التحقق من الكاش أو البنك
QBCore.Functions.CreateCallback('suol-weaponrepair:server:checkMoney', function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return cb(false) end

    local price = Config.RepairPrice
    if Player.PlayerData.money.cash >= price or Player.PlayerData.money.bank >= price then
        cb(true)
    else
        cb(false)
    end
end)

-- خصم المبلغ وتصليح جودة السلاح
RegisterNetEvent('suol-weaponrepair:server:repairWeapon', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local price = Config.RepairPrice
    local paid = false

    if Player.PlayerData.money.cash >= price then
        Player.Functions.RemoveMoney('cash', price, "weapon-repair")
        paid = true
    elseif Player.PlayerData.money.bank >= price then
        Player.Functions.RemoveMoney('bank', price, "weapon-repair")
        paid = true
    end

    if paid then
        local weaponItem = Player.PlayerData.items[Player.PlayerData.source] or Player.Functions.GetItemByName(Player.PlayerData.items)
        
        -- تصليح السلاح المحمول في اليد
        local currentWeapon = Player.PlayerData.items
        for slot, item in pairs(Player.PlayerData.items) do
            if item and item.type == "weapon" then
                -- تعديل جودة السلاح إلى 100%
                item.info.quality = 100
                Player.PlayerData.items[slot] = item
                Player.Functions.SetPlayerData("items", Player.PlayerData.items)
                TriggerClientEvent('QBCore:Notify', src, "Weapon successfully repaired for $" .. price .. "!", "success")
                return
            end
        end
    end
end)