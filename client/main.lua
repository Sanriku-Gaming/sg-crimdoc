local QBCore = exports['qb-core']:GetCoreObject()
local targets = {}
local docs = {}
local blips = {}
local doctorStates = {}

local inBedDict = 'anim@gangops@morgue@table@'
local inBedAnim = 'body_search'

---------------------
--    Functions    --
---------------------
local function loadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Wait(10)
    end
    return function()
        RemoveAnimDict(dict)
    end
end

local function sendBillEmail(amount)
    if not Config.Mail.enabled then
        return
    end
    SetTimeout(math.random(2500, 4000), function()
        TriggerServerEvent('qb-phone:server:sendNewMail', {
            sender = Config.Mail.sender,
            subject = Config.Mail.subject,
            message = Config.Mail.message,
            button = {}
        })
        if Config.Debug then print('Email Sent') end
    end)
end

local function createBlip(coords, bData)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, bData.sprite)
    SetBlipColour(blip, bData.color)
    SetBlipScale(blip, bData.scale)
    SetBlipDisplay(blip, bData.display)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(bData.name)
    EndTextCommandSetBlipName(blip)
    return blip
end

---------------------
--     Threads     --
---------------------
CreateThread(function()
    local Locations = Config.Locations
    for k, v in pairs(Locations) do
        doctorStates[k] = false
        if Config.Debug then print(k, v, v.pedCoords) end
        if v.blip.enable then
            blips[#blips + 1] = createBlip(v.pedCoords, v.blip)
        end

        QBCore.Functions.LoadModel(v.model)
        docs[k] = CreatePed(1, v.model, v.pedCoords.x, v.pedCoords.y, v.pedCoords.z - 1.0, v.pedCoords.w, false, false)
        SetEntityAsMissionEntity(docs[k], true, true)
        FreezeEntityPosition(docs[k], true)
        SetEntityInvincible(docs[k], true)
        SetBlockingOfNonTemporaryEvents(docs[k], true)
        TaskStartScenarioInPlace(docs[k], v.scenario, 0, false)
        if Config.Debug then print('Ped Created') end
        
        targets[#targets + 1] = exports['qb-target']:AddCircleZone('CrimDoc' .. k, vector3(v.pedCoords.x, v.pedCoords.y, v.pedCoords.z), 1.0,
            {
                name = 'CrimDoc' .. k,
                debugPoly = Config.DebugPoly,
                useZ = true,
            },
            {
                options = {
                    {
                        targeticon = v.icon,
                        label = '[#' .. k .. (doctorStates[k] and ' - BUSY] - ' or ' - AVAILABLE] - ') .. v.label .. ' - $' .. v.cost,
                        canInteract = function()
                            return v.item and QBCore.Functions.HasItem(v.item) or true
                        end,
                        action = function()
                            local success = lib.callback.await('sg-crimdoc:server:attemptHeal', false, k)
                            if success then
                                local player = PlayerPedId()
                                DoScreenFadeOut(1000)
                                
                                while not IsScreenFadedOut() do
                                    Wait(100)
                                end
                                
                                if IsPedDeadOrDying(player) then
                                    local pos = GetEntityCoords(player, true)
                                    NetworkResurrectLocalPlayer(pos.x, pos.y, pos.z, GetEntityHeading(player), true, false)
                                end
                                
                                local bedCoords = Config.Locations[k].bedCoords
                                if bedCoords then
                                    SetEntityCoords(player, bedCoords.x, bedCoords.y, bedCoords.z + 0.02)
                                    Wait(500)
                                    loadAnimDict(inBedDict)
                                    TaskPlayAnim(player, inBedDict, inBedAnim, 8.0, 1.0, -1, 1, 0, 0, 0, 0)
                                    SetEntityHeading(player, bedCoords.w)
                                end
                                FreezeEntityPosition(player, true)
                                DoScreenFadeIn(1000)
                                
                                QBCore.Functions.Progressbar('crimdoc_revive', 'Being Healed by the Crim Doc...', Config.Locations[k].reviveTime * 1000, false, false, {
                                    disableMovement = true,
                                    disableCarMovement = true,
                                    disableMouse = false,
                                    disableCombat = true,
                                }, {}, {}, {}, function()-- Done
                                    TriggerEvent('hospital:client:Revive', player)
                                    FreezeEntityPosition(player, false)
                                    Wait(200)
                                    sendBillEmail(Config.Locations[k].cost)
                                    TriggerServerEvent('sg-crimdoc:server:docAvailable', k)
                                    ClearPedTasks(player)
                                end, function()-- Cancel
                                    FreezeEntityPosition(player, false)
                                    TriggerServerEvent('sg-crimdoc:server:docAvailable', k)
                                end)
                            end
                        end,
                    },
                },
                distance = 2.0
            }
        )
    end
end)

---------------------
--     Events      --
---------------------
RegisterNetEvent('sg-crimdoc:client:updateDoctorState', function(docId, isAvailable)
    doctorStates[docId] = not isAvailable
    if Config.Debug then
        print(string.format('Doctor %d state updated - Busy: %s', docId, tostring(not isAvailable)))
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        for i = #targets, 1, -1 do
            if targets[i] then
                exports['qb-target']:RemoveZone(targets[i])
                table.remove(targets, i)
            end
        end
        for i = 1, #docs do
            if docs[i] then
                DeletePed(docs[i])
                table.remove(docs, i)
            end
        end
        for i = 1, #blips do
            if blips[i] then
                RemoveBlip(blips[i])
                table.remove(blips, i)
            end
        end
    end
end)
