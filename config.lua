print('^3Crimdoc^7 - AI Crim Doc Script by Nicky of ^4SG Scripts^7')
------------------------
--       CONFIG       --
------------------------

Config = {}

Config.Debug = false                                                -- Set to true to for debug prints
Config.DebugPoly = false                                            -- Set to true for debugpoly zones

Config.Mail = {                                                     -- Change the language as needed
    enabled = true,
    sender = 'Crim Doctor',
    subject = 'Service Fees',
    message = 'Thank you for using CrimDoc Services. We wish you a quick recovery, but hope to see you soon!',
}

Config.Locations = {
	{
    blip = {                                                        -- Blip Info for location (if enable set to true)
        enable = false,                                             -- Enable the blip for this doc
        name = 'Crim Doctor',                                       -- Blip Name
        sprite = 61,                                                -- Blip Sprite
        color = 1,                                                  -- Blip Color
        scale = 0.6,                                                -- Blip Size
        display = 6,                                                -- Blip Display
    },
		pedCoords = vector4(378.63, -1433.33, 26.27, 253.98),       -- Location of Doctor Ped (and blip if enabled)
        bedCoords = vector4(386.4, -1438.15, 25.94, 67.50),         -- Location of bed to move to (false if not using a bed)
		model = 's_m_m_doctor_01',                                  -- Ped Model
		scenario = 'WORLD_HUMAN_CLIPBOARD',                         -- Ped Scenario
		label = 'Get Treated',                                      -- Target Label
		icon = 'fas fa-user-doctor',                                -- Target Icon
        item = false,                                               -- Require item to interact with the doctor (false for no item)
        cost = 5000,                                                -- Fee for doctor services
        moneyType = 'cash',                                         -- Money used to pay for the Doc's Fees (change to bank/cash/crypto as needed)
        paySociety = true,                                          -- If you want the Crim Doc Fees to be paid to a society (Set by location)
        society = 'ambulance',                                      -- Society to give fee to (if paySociety is true)
        reviveTime = 50,                                            -- Amount of time to revive in seconds
	},
	{
    blip = {
        enable = false,
        name = 'Crim Doctor',
        sprite = 61,
        color = 1,
        scale = 0.6,
        display = 6,
    },
		pedCoords = vector4(-156.14, 2469.94, 56.98, 260.0),
        bedCoords = vector4(-155.9, 2466.82, 56.88, 270.65),
		label = 'Get Treated',
		model = 's_m_m_doctor_01',
		scenario = 'WORLD_HUMAN_CLIPBOARD',
		icon = 'fas fa-user-doctor',
        item = false,
        cost = 5000,
        moneyType = 'cash',
        paySociety = false,
        society = 'ambulance',
        reviveTime = 50,
	},
}

-------------------------
--  Location Template  --
-------------------------
--[[
--- Configuration for the Crim Doctor
-- @param blip Table containing blip configuration
-- @param blip.enable Boolean indicating if the blip is enabled
-- @param blip.name String representing the name of the blip
-- @param blip.sprite Integer representing the blip sprite
-- @param blip.color Integer representing the blip color
-- @param blip.scale Number representing the blip scale
-- @param blip.display Integer representing the blip display type
-- @param pedCoords Vector4 representing the coordinates of the ped
-- @param bedCoords Vector4 representing the coordinates of the bed
-- @param label String representing the label for the action
-- @param model String representing the model of the ped
-- @param scenario String representing the scenario the ped will perform
-- @param icon String representing the icon for the action
-- @param item Boolean indicating if an item is required
-- @param cost Integer representing the cost of the treatment
-- @param moneyType String representing the type of money used for payment
-- @param paySociety Boolean indicating if the payment goes to society
-- @param society String representing the society to pay if paySociety is true
-- @param reviveTime Integer representing the time in seconds to revive

{
    blip = {
        enable = ,
        name = '',
        sprite = ,
        color = ,
        scale = ,
        display = ,
    },
        pedCoords = ,
        bedCoords = ,
        label = '',
        model = '',
        scenario = '',
        icon = '',
        item = ,
        cost = ,
        moneyType = '',
        paySociety = ,
        society = '',
        reviveTime = ,
    }
]]--