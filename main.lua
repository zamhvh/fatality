local Lib = loadstring(game:HttpGet("https://pastebin.com/raw/u9uSMrwG"))()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

local Packets = require(ReplicatedStorage.Modules.Packets)
local ItemData = require(ReplicatedStorage.Modules.ItemData)
local ItemIDS = require(ReplicatedStorage.Modules.ItemIDS)
local GU = require(ReplicatedStorage.Modules.GameUtil)

local UI = Lib.new(true)
UI.ChangeToggleKey(Enum.KeyCode.Delete)

local FarmingTweenSpeed = 16
local AutoTeleportDistance = 50

local Farming = UI:Category("Farming")

local FarmingTabs = {
    Main = Farming:Sector("Main")
}

local Tween = UI:Category("Tween")

local TweenTabs = {
    Main = Tween:Sector("Main")
}

--farming

local AutoPlant_Enabled = false
local AutoTeleport_Enabled = false

local SelectedFruit = "Bloodfruit"
local PlayerFruits = {}

local BlacklistedItemsForFruits = {
    "Reinforced Chest",
    "Nest",
    "Fish Trap",
    "Chest",
    "Barley"
}

for Name, Data in next, ItemData do
    if Data.growthTime ~= nil and not table.find(BlacklistedItemsForFruits, Name) then
        print(Name)
        table.insert(PlayerFruits, Name)
    end
end

table.sort(PlayerFruits, function(a, b)
    print(a, b)
    return ItemData[a].nourishment.health > ItemData[b].nourishment.health
end)

do 

    HasFruitInPlantBox = function(Box)
        return Box:FindFirstChild("Seed")
    end

    GetClosestPlantBoxWithNoPlantInIt = function()
        local Parts = workspace:GetPartBoundsInRadius(LocalPlayer.Character:GetPivot().Position, 35)

        local Boxes = {}

        for _, Part in next, Parts do

            if Part.Parent.Name == "Plant Box" then

                local Found = HasFruitInPlantBox(Part.Parent)
                if not Found then

                    table.insert(Boxes, Part.Parent)

                end

            end

        end

        local Closest, LastDist = nil, math.huge

        for _, Box in next, Boxes do

            local Dist = (LocalPlayer.Character:GetPivot().Position - Box:GetPivot().Position).Magnitude

            if Dist < LastDist then
                Closest = Box
                LastDist = Dist
            end

        end

        return Closest
    end

    GetAutoTeleportPlantBoxWithNoPlantInIt = function()
        local Parts = workspace:GetPartBoundsInRadius(LocalPlayer.Character:GetPivot().Position, AutoTeleportDistance)

        local Boxes = {}

        for _, Part in next, Parts do

            if Part.Parent.Name == "Plant Box" then

                local Found = HasFruitInPlantBox(Part.Parent)
                if not Found then

                    table.insert(Boxes, Part.Parent)

                end

            end

        end

        local Closest, LastDist = nil, math.huge

        for _, Box in next, Boxes do

            local Dist = (LocalPlayer.Character:GetPivot().Position - Box:GetPivot().Position).Magnitude

            if Dist < LastDist then
                Closest = Box
                LastDist = Dist
            end

        end

        return Closest
    end

    GetClosestBush = function()
        local Parts = workspace:GetPartBoundsInRadius(LocalPlayer.Character:GetPivot().Position, 35)

        local Bushes = {}

        for _, Part in next, Parts do

            if string.find(string.lower(Part.Parent.Name), "bush") or string.find(string.lower(Part.Parent.Name), "tree") or string.find(string.lower(Part.Parent.Name), "patch") then

                table.insert(Bushes, Part.Parent)

            end

        end

        local Closest, LastDist = nil, math.huge

        for _, Bush in next, Bushes do

            local Dist = (LocalPlayer.Character:GetPivot().Position - Bush:GetPivot().Position).Magnitude

            if Dist < LastDist then
                Closest = Bush
                LastDist = Dist
            end

        end

        return Closest
    end

    local FruitSelection; FruitSelection = FarmingTabs.Main:Cheat(
        "Dropdown",
        "Fruit Selection", 
        function(Value)
            SelectedFruit = Value
        end, {
            options = PlayerFruits
        }
    )

    local AutoPlant = FarmingTabs.Main:Cheat(
        "Checkbox",
        "AutoPlant",
        function(State)
            AutoPlant_Enabled = State

            while AutoPlant_Enabled and task.wait(0.02333333) do
                
                local Box = GetClosestPlantBoxWithNoPlantInIt()

                Packets.InteractStructure.send({["structure"] = Box, ["itemID"] = ItemIDS[SelectedFruit]})

            end
        end
    )

    local AutoTeleport = FarmingTabs.Main:Cheat(
        "Checkbox",
        "AutoTeleport",
        function(State)
            AutoTeleport_Enabled = State

            while AutoTeleport_Enabled do
                
                local Box = GetAutoTeleportPlantBoxWithNoPlantInIt()

                if Box == nil then
                    task.wait() 
                    continue 
                end

                local Speed = (LocalPlayer.Character:GetPivot().Position - Box:GetPivot().Position).Magnitude / FarmingTweenSpeed

                local TI = TweenInfo.new(Speed, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)

                local Tween = game:GetService("TweenService"):Create(LocalPlayer.Character.PrimaryPart, TI, {CFrame = Box:GetPivot() * CFrame.new(0, 4, 0)})

                Tween:Play()

                Tween.Completed:Wait()
            end
        end
    )

    local AutoHarvest = FarmingTabs.Main:Cheat(
        "Checkbox",
        "AutoHarvest",
        function(State)
            AutoHarvest_Enabled = State

            while AutoHarvest_Enabled do
                task.wait()
                
                local Bush = GetClosestBush()

                if Bush == nil then continue end

                Packets.Pickup.send(Bush)
            end
        end
    )
end

--tween

do

    TweenTabs.Main:Cheat("Slider", "Farming TweenSpeed", function(Value)
        FarmingTweenSpeed = Value
    end, {min = 0, max = 40, suffix = " studs/sec"})

    TweenTabs.Main:Cheat("Slider", "AutoTeleport Distance", function(Value)
        AutoTeleportDistance = Value
    end, {min = 15, max = 500, suffix = " studs"})

end
