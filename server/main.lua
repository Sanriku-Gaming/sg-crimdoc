local QBCore = exports['qb-core']:GetCoreObject()

---------------------
--  State Manager  --
---------------------
local StateManager = {
    doctors = {},

    BUSY_TIMEOUT = 60000,   -- 1 minute failsafe timeout
    MAX_PATIENTS = 1,       -- Maximum concurrent patients
    SAFETY_MARGIN = 10000,  -- 10 second safety margin

    initDoctor = function(self, docId)
        if not self.doctors[docId] then
            self.doctors[docId] = {
                busy = false,
                currentPatient = nil,
                lastPatientTime = 0,
                timeoutHandle = nil,
                treatmentStart = 0
            }
        end
        return self.doctors[docId]
    end,

    setBusy = function(self, docId, playerId)
        local doctor = self:initDoctor(docId)
        local location = Config.Locations[docId]
        
        if doctor.timeoutHandle then
            clearTimeout(doctor.timeoutHandle)
            doctor.timeoutHandle = nil
        end
        
        doctor.busy = true
        doctor.currentPatient = playerId
        doctor.treatmentStart = GetGameTimer()
        doctor.lastPatientTime = GetGameTimer()

        TriggerClientEvent('sg-crimdoc:client:updateDoctorState', -1, docId, false)
        
        local timeoutDuration = (location.reviveTime * 1000) + self.SAFETY_MARGIN
        
        doctor.timeoutHandle = SetTimeout(timeoutDuration, function()
            if doctor.busy then
                self:setAvailable(docId)
                print(string.format("^1[WARNING] Doctor %d failsafe timeout triggered after %d ms^7", docId, timeoutDuration))
            end
        end)

        if Config.Debug then
            print(string.format("Doctor %d is now treating patient %d (Treatment time: %d seconds)", docId, playerId, location.reviveTime))
        end
    end,
    
    setAvailable = function(self, docId)
        local doctor = self:initDoctor(docId)
        
        if doctor.timeoutHandle then
            clearTimeout(doctor.timeoutHandle)
            doctor.timeoutHandle = nil
        end
        
        local treatmentDuration = 0
        if doctor.treatmentStart > 0 then
            treatmentDuration = GetGameTimer() - doctor.treatmentStart
        end
        
        doctor.busy = false
        doctor.currentPatient = nil
        doctor.treatmentStart = 0

        TriggerClientEvent('sg-crimdoc:client:updateDoctorState', -1, docId, true)

        if Config.Debug then
            print(string.format("Doctor %d is now available (Treatment duration: %dms)", docId, treatmentDuration))
        end
    end,

    isAvailable = function(self, docId)
        local doctor = self:initDoctor(docId)
        return not doctor.busy
    end,

    getCurrentPatient = function(self, docId)
        local doctor = self:initDoctor(docId)
        return doctor.currentPatient
    end,

    getTimeSinceLastPatient = function(self, docId)
        local doctor = self:initDoctor(docId)
        if doctor.lastPatientTime == 0 then
            return 0
        end
        return GetGameTimer() - doctor.lastPatientTime
    end,

    forceReset = function(self, docId)
        self.doctors[docId] = nil
        self:initDoctor(docId)
        if Config.Debug then
            print(string.format("Doctor %d state forcefully reset", docId))
        end
    end,

    getState = function(self, docId)
        return self.doctors[docId] or {busy = false, currentPatient = nil, lastPatientTime = 0}
    end
}

---------------------
--    Callbacks    --
---------------------
lib.callback.register('sg-crimdoc:server:attemptHeal', function(source, loc)
    local src = source
    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local doc = Config.Locations[loc]
    local docCoods = doc.pedCoords

    if #(coords - vec3(docCoods.x, docCoods.y, docCoods.z)) > 10 then
        return false
    end

    if not StateManager:isAvailable(loc) then
        QBCore.Functions.Notify(src, 'Doc is busy, please wait', 'error', 5000)
        return false
    end

    local Player = QBCore.Functions.GetPlayer(src)
    local hasPaid = pcall(function()
        return Player.Functions.RemoveMoney(doc.moneyType, doc.cost, 'Crim Doc Fees')
    end)

    if not hasPaid then
        QBCore.Functions.Notify(src, 'You don\'t have enough ' .. doc.moneyType .. ' to use these services', 'error', 5000)
        return false
    else
        if doc.paySociety then
            exports['qb-banking']:AddMoney(doc.society, doc.cost, 'Crim Doc Fees')
        end
    end

    StateManager:setBusy(loc, src)

    return true
end)

---------------------
--    Commands     --
---------------------
RegisterCommand('checkdocstates', function(source, args)
    if not Config.Debug then return end
    
    for i = 1, #Config.Locations do
        local state = StateManager:getState(i)
        print(string.format("Doctor %d state:", i))
        print("Busy:", state.busy)
        print("Current Patient:", state.currentPatient)
        print("Last Patient Time:", state.lastPatientTime)
    end
end, true)

RegisterCommand('resetdocstate', function(source, args)
    if not Config.Debug then return end
    
    if #args < 1 then
        print("^1[ERROR] No doctor ID provided^7")
        return
    end
    
    local docId = tonumber(args[1])
    if not docId then
        print("^1[ERROR] Invalid doctor ID provided^7")
        return
    end
    
    StateManager:forceReset(docId)
    print(string.format("^2Doctor %d state forcefully reset^7", docId))
end, true)

---------------------
--     Events      --
---------------------
RegisterNetEvent('sg-crimdoc:server:docAvailable', function(loc)
    StateManager:setAvailable(loc)
end)

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        if type(Config.Mail.enabled) ~= "boolean" then
            Config.Mail.enabled = true
        end
    end
end)

AddEventHandler('playerDropped', function(reason)
    local src = source
    for docId, doctor in pairs(StateManager.doctors) do
        if doctor.currentPatient == src then
            StateManager:setAvailable(docId)
        end
    end
end)