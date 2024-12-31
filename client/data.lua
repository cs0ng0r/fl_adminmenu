local PedList = require "data.ped"
local Locations = require "data.locations"

local function GetItems()
    local items = {}
    local ItemsData = exports.ox_inventory:Items()

    for name, v in pairs(ItemsData) do
        items[#items + 1] = { label = v.label, value = name }
    end

    return items
end

local function GetJobs(Jobs)
    local jobs = {}

    for name, v in pairs(Jobs) do
        local gradeDataList = {}

        for grade, gradeData in pairs(v.grades) do
            gradeDataList[#gradeDataList + 1] = { name = gradeData.name, grade = gradeData.name, isboss = gradeData.isboss }
        end

        jobs[#jobs + 1] = { label = v.label, value = name, grades = gradeDataList }
    end

    return jobs
end

local function GetLocations()
    local locations = {}

    for name, v in pairs(Locations) do
        locations[#locations + 1] = { label = name, value = tostring(v) }
    end

    return locations
end

-- Sends data to the UI on resource start
function GetData()
    local data = lib.callback.await('fl_adminmenu:getBasicServerData')

    data.pedlist = PedList
    data.items = GetItems()
    data.locations = GetLocations()
    data.jobs = GetJobs(data.jobs)

    SendNUIMessage({
        action = "data",
        data = data
    })
end
