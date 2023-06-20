CallbackModule, PlayerModule, FunctionsModule, DatabaseModule, CommandsModule, EventsModule = nil, nil, nil, nil, nil, nil

_Ready = false
AddEventHandler('Modules/server/ready', function()
    TriggerEvent('Modules/server/request-dependencies', {
        'Callback',
        'Player',
        'Functions',
        'Database',
        'Commands',
        'Events',
    }, function(Succeeded)
        if not Succeeded then return end
        CallbackModule = exports['mercy-base']:FetchModule('Callback')
        PlayerModule = exports['mercy-base']:FetchModule('Player')
        FunctionsModule = exports['mercy-base']:FetchModule('Functions')
        DatabaseModule = exports['mercy-base']:FetchModule('Database')
        CommandsModule = exports['mercy-base']:FetchModule('Commands')
        EventsModule = exports['mercy-base']:FetchModule('Events')
        _Ready = true
    end)
end)

-- [ Code ] --

local DryerBusy = false

-- [ Threads ] --

Citizen.CreateThread(function()
    while not _Ready do
        Citizen.Wait(250)
    end

    CallbackModule.CreateCallback('mercy-illegal/server/is-dryer-busy', function(Source, Cb)
        Cb(DryerBusy)
    end)
end)

RegisterNetEvent('mercy-illegal/server/start-dry-process', function()
    local src = source
    local Player = PlayerModule.GetPlayerBySource(src)
    if not Player then return end
    local HasBranches = false

    local StashItems = exports['mercy-inventory']:GetInventoryItems('dry-rack')
    if StashItems ~= nil then 
        for ItemId, Item in pairs(StashItems) do
            if Item.ItemName == 'weed-branch' then
                HasBranches = true 
            end
        end
    end

    if HasBranches then
        DryerBusy = true
        Player.Functions.Notify('dryer-drying', 'Drying the branches...')
        SetTimeout((1000 * 60) * Config.WeedRackDryTime, function()
            local StashItems = exports['mercy-inventory']:GetInventoryItems('dry-rack')
            for ItemId, Item in pairs(StashItems) do
                if Item.ItemName == 'weed-branch' then
                    StashItems[ItemId].ItemName = 'weed-dried-bud-one'
                end
            end
            exports['mercy-inventory']:SetInventoryItems('dry-rack', StashItems)
            Wait(500)
            DryerBusy = false
            Player.Functions.Notify('dryer-ready', 'Dryer is ready!', 'success')
        end)
    else
        Player.Functions.Notify('dryer-no-branches', 'Place branches on the rack!', 'error')
    end
end)