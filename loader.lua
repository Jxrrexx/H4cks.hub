local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "H4cks.hub",
    LoadingTitle = "H4cks.hub | 99 Nights in the Forest",
    LoadingSubtitle = "by Jxrre",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "H4cks.hub",
        FileName = "H4cks.hub"
    },
    Discord = {
        Enabled = false,
        Invite = "getswiftgg",
        RememberJoins = false
    },
    KeySystem = true,
    KeySettings = {
        Title = "H4cks.hub",
        Subtitle = "Key System",
        Note = "Join our Discord (https://discord.gg/BnPXzFhYbB) to obtain the key",
        FileName = "H4cksKey",
        SaveKey = true,
        GrabKeyFromSite = false,
        Key = {"Hello"}
    }
})  -- end Rayfield:CreateWindow call
-- Clipboard copy on load (removed)
print("[H4cks.hub] Join our Discord: https://discord.gg/BnPXzFhYbB")
Rayfield:Notify({Title = "Discord", Content = "Invite link printed to console (F9)", Duration = 5})

local PlayerTab = Window:CreateTab("Player", "user")
local ItemTab = Window:CreateTab("Items", "package")

local Label = PlayerTab:CreateLabel("Welcome to H4cks.hub", "user")

local DEFAULT_WALK_SPEED = 16
local FAST_WALK_SPEED = 50
local DEFAULT_JUMP_POWER = 50
-- Removed High Jump feature (constant and UI)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function getHumanoid()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return character:WaitForChild("Humanoid", 5)
end

local function setMaxDays(value: number)
    local stats = LocalPlayer:FindFirstChild("leaderstats")
    if stats then
        local maxDays = stats:FindFirstChild("Max Days")
        if maxDays and maxDays:IsA("IntValue") then
            maxDays.Value = value
        end
    end
end

local SpeedToggle = PlayerTab:CreateToggle({
    Name = "Speed Boost",
    CurrentValue = false,
    Flag = "SpeedToggle",
    Callback = function(state)
        local humanoid = getHumanoid()
        if humanoid then
            humanoid.WalkSpeed = state and FAST_WALK_SPEED or DEFAULT_WALK_SPEED
        end
    end
})

-- Removed High Jump toggle
local SpeedSlider = PlayerTab:CreateSlider({
    Name = "Custom WalkSpeed",
    Range = {16, 100},
    Increment = 1,
    Suffix = "Studs/s",
    CurrentValue = 16,
    Flag = "SpeedSlider",
    Callback = function(value)
        local humanoid = getHumanoid()
        if humanoid then
            humanoid.WalkSpeed = value
        end
    end
})

local DaysInput = PlayerTab:CreateInput({
    Name = "Set Max Days (Client Sided)",
    CurrentValue = "",
    PlaceholderText = "Enter number of days",
    RemoveTextAfterFocusLost = true,
    NumbersOnly = true,
    Flag = "DaysInput",
    Callback = function(text)
        local number = tonumber(text)
        if number then
            setMaxDays(number)
        end
    end,
})

local Keybind = PlayerTab:CreateKeybind({
    Name = "Toggle UI",
    CurrentKeybind = "RightControl",
    HoldToInteract = false,
    Flag = "UIToggle",
    Callback = function()
        Rayfield:SetVisibility(not Rayfield:IsVisible())
    end
})

local ItemsFolder = workspace:FindFirstChild("Items") or workspace

local function getItemNames()
    local seen = {}
    local list = {}
    for _, child in ipairs(ItemsFolder:GetChildren()) do
        if child:IsA("Model") then
            local n = child.Name
            if not seen[n] then
                seen[n] = true
                table.insert(list, n)
            end
        end
    end
    table.sort(list)
    return list
end

local function teleportItems(names: {string})
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart", 5)
    if not hrp then return end
    for _, itemName in ipairs(names) do
        for _, mdl in ipairs(ItemsFolder:GetChildren()) do
            if mdl.Name == itemName and mdl:IsA("Model") then
                local main = mdl.PrimaryPart or mdl:FindFirstChildWhichIsA("BasePart")
                if main then
                    mdl:SetPrimaryPartCFrame(hrp.CFrame + Vector3.new(math.random(-5,5), 0, math.random(-5,5)))
                end
            end
        end
    end
end

local selectedItems = {}

local ItemDropdown = ItemTab:CreateDropdown({
    Name = "Select Item(s)",
    Options = getItemNames(),
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "ItemDropdown",
    Callback = function(opts)
        selectedItems = opts
    end,
})

local TeleportBtn = ItemTab:CreateButton({
    Name = "Teleport Selected Items",
    Callback = function()
        teleportItems(selectedItems)
    end,
})

local TeleportAllBtn = ItemTab:CreateButton({
    Name = "Teleport ALL Items",
    Callback = function()
        teleportItems(getItemNames())
    end,
})

-- Item Tab additions
local RefreshItemsBtn = ItemTab:CreateButton({
    Name = "Refresh Item List",
    Callback = function()
        ItemDropdown:Refresh(getItemNames())
    end,
})

-- Missing Kids Tab
local KidsTab = Window:CreateTab("Missing Kids", "baby")

local MissingKidsFolder = (workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("MissingKids")) or workspace:FindFirstChild("MissingKids")

local function getKidNames()
    local names = {}
    if MissingKidsFolder then
        for _, child in ipairs(MissingKidsFolder:GetChildren()) do
            table.insert(names, child.Name)
        end
        for name, _ in pairs(MissingKidsFolder:GetAttributes()) do
            table.insert(names, name)
        end
    end
    table.sort(names)
    return names
end

local function getKidPosition(name: string): Vector3?
    if not MissingKidsFolder then return nil end
    if MissingKidsFolder:GetAttribute(name) then
        local v = MissingKidsFolder:GetAttribute(name)
        if typeof(v) == "Vector3" then
            return v
        end
    end
    local inst = MissingKidsFolder:FindFirstChild(name)
    if inst and inst:IsA("Model") and inst.PrimaryPart then
        return inst.PrimaryPart.Position
    elseif inst and inst:IsA("BasePart") then
        return inst.Position
    end
    return nil
end

-- ESP handling
local espParts = {}
local espUpdateTask
local function clearESP()
    if espUpdateTask then
        task.cancel(espUpdateTask)
        espUpdateTask = nil
    end
    for _, rec in ipairs(espParts) do
        if rec.part and rec.part.Parent then
            rec.part:Destroy()
        end
    end
    table.clear(espParts)
end

local function createESPAt(name: string, pos: Vector3)
    local part = Instance.new("Part")
    part.Anchored = true
    part.CanCollide = false
    part.Size = Vector3.new(1,1,1)
    part.Transparency = 1
    part.Position = pos + Vector3.new(0,2,0)
    part.Parent = workspace

    local bill = Instance.new("BillboardGui")
    bill.Size = UDim2.new(0,100,0,30)
    bill.AlwaysOnTop = true
    bill.Adornee = part
    bill.Parent = part

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1,0,1,0)
    text.BackgroundTransparency = 1
    text.TextColor3 = Color3.new(1,1,0)
    text.TextScaled = true
    text.Font = Enum.Font.SourceSansBold
    text.Parent = bill

    table.insert(espParts, {part = part, name = name, label = text})
end

local KidsDropdown = KidsTab:CreateDropdown({
    Name = "Select Kid",
    Options = getKidNames(),
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "KidDropdown",
    Callback = function() end,
})

local TeleportKidBtn = KidsTab:CreateButton({
    Name = "Teleport to Kid",
    Callback = function()
        local option = KidsDropdown.CurrentOption
        if typeof(option) == "table" then option = option[1] end
        if not option then return end
        local pos = getKidPosition(option)
        if pos then
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = CFrame.new(pos + Vector3.new(0,3,0))
            end
        end
    end,
})

local KidsESPToggle = KidsTab:CreateToggle({
    Name = "Kid ESP",
    CurrentValue = false,
    Flag = "KidsESP",
    Callback = function(state)
        clearESP()
        if state then
            for _, name in ipairs(getKidNames()) do
                local pos = getKidPosition(name)
                if pos then
                    createESPAt(name, pos)
                end
            end
            espUpdateTask = task.spawn(function()
                while #espParts > 0 do
                    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    for i = #espParts, 1, -1 do
                        local rec = espParts[i]
                        local pos = getKidPosition(rec.name)
                        if pos and rec.part and rec.part.Parent then
                            rec.part.Position = pos + Vector3.new(0,2,0)
                            if hrp then
                                local dist = (hrp.Position - pos).Magnitude
                                rec.label.Text = string.format("%s [%.0f]", rec.name, dist)
                            else
                                rec.label.Text = rec.name
                            end
                        else
                            if rec.part and rec.part.Parent then rec.part:Destroy() end
                            table.remove(espParts, i)
                        end
                    end
                    task.wait(0.5)
                end
                clearESP()
            end)
        end
    end,
})

local RefreshKidsBtn = KidsTab:CreateButton({
    Name = "Refresh Kid List",
    Callback = function()
        KidsDropdown:Refresh(getKidNames())
    end,
})

local HUNGER_FULL_VALUE = 180 -- value representing full hunger

local hungerTask
local AutoHungerToggle = PlayerTab:CreateToggle({
    Name = "Auto Fill Hunger",
    CurrentValue = false,
    Flag = "AutoHunger",
    Callback = function(state)
        if state then
            if hungerTask then task.cancel(hungerTask) end
            hungerTask = task.spawn(function()
                while true do
                    local attr = LocalPlayer:GetAttribute("Hunger")
                    if attr ~= nil then
                        LocalPlayer:SetAttribute("Hunger", HUNGER_FULL_VALUE)
                    end
                    task.wait(1)
                end
            end)
        else
            if hungerTask then
                task.cancel(hungerTask)
                hungerTask = nil
            end
        end
    end,
})

-- Remove Combat tab and Kill Aura
-- Add ESP for all items and all entities (enemies/NPCs) with distance display

-- ESP utility (now supports both Item and Entity ESP at the same time)
local itemEspParts = {}
local entityEspParts = {}
local itemEspUpdateTask
local entityEspUpdateTask

local function clearItemESP()
    if itemEspUpdateTask then
        task.cancel(itemEspUpdateTask)
        itemEspUpdateTask = nil
    end
    for _, rec in ipairs(itemEspParts) do
        if rec.part and rec.part.Parent then
            rec.part:Destroy()
        end
    end
    table.clear(itemEspParts)
end

local function clearEntityESP()
    if entityEspUpdateTask then
        task.cancel(entityEspUpdateTask)
        entityEspUpdateTask = nil
    end
    for _, rec in ipairs(entityEspParts) do
        if rec.part and rec.part.Parent then
            rec.part:Destroy()
        end
    end
    table.clear(entityEspParts)
end

local function createESPAt(partsTable, name, pos, color)
    local part = Instance.new("Part")
    part.Anchored = true
    part.CanCollide = false
    part.Size = Vector3.new(1,1,1)
    part.Transparency = 1
    part.Position = pos + Vector3.new(0,2,0)
    part.Parent = workspace

    local bill = Instance.new("BillboardGui")
    bill.Size = UDim2.new(0,120,0,30)
    bill.AlwaysOnTop = true
    bill.Adornee = part
    bill.Parent = part

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1,0,1,0)
    text.BackgroundTransparency = 1
    text.TextColor3 = color or Color3.new(1,1,0)
    text.TextScaled = true
    text.Font = Enum.Font.SourceSansBold
    text.Parent = bill

    table.insert(partsTable, {part = part, name = name, label = text})
end

-- ESP for Items
local ItemsFolder = workspace:FindFirstChild("Items") or workspace
local function getItemModels()
    local models = {}
    for _, child in ipairs(ItemsFolder:GetDescendants()) do
        if child:IsA("Model") or child:IsA("BasePart") then
            table.insert(models, child)
        end
    end
    return models
end

-- ESP for Entities (enemies/NPCs)
local function getEntityModels()
    local charsFolder = workspace:FindFirstChild("Characters") or workspace
    local models = {}
    for _, child in ipairs(charsFolder:GetDescendants()) do
        if child:IsA("Model") and child:FindFirstChildWhichIsA("Humanoid", true) then
            table.insert(models, child)
        end
    end
    return models
end

-- BEGIN NEW ESP TAB SECTION ----------------------------------------------
local ESPTab = Window:CreateTab("ESP", "eye")

-- helper to get unique entity names
local function getEntityNames()
    local seen, list = {}, {}
    for _, ent in ipairs(getEntityModels()) do
        if not seen[ent.Name] then
            seen[ent.Name] = true
            table.insert(list, ent.Name)
        end
    end
    table.sort(list)
    return list
end

-- selections
local selectedItemESP, selectedEntityESP = {}, {}

-- Remove ItemEspDropdown and Refresh Item List button
-- (Dropdown and refresh button deleted)

-- Remove EntityEspDropdown and Refresh Entity List button
-- (Dropdown and button deleted)
-- Remove spawnSelectedEntityESP function
-- (Function deleted)

-- Rewrite the Entity ESP toggle to display all entities
ESPTab:CreateToggle({
    Name = "Entity ESP (All)",
    CurrentValue = false,
    Flag = "EnableEntityESP",
    Callback = function(state)
        clearEntityESP()
        if state then
            for _, ent in ipairs(getEntityModels()) do
                local part = ent:FindFirstChild("HumanoidRootPart", true) or ent.PrimaryPart or ent:FindFirstChildWhichIsA("BasePart", true)
                if part then
                    createESPAt(entityEspParts, ent.Name, part.Position, Color3.new(1,0,0))
                end
            end
            entityEspUpdateTask = task.spawn(function()
                while #entityEspParts > 0 do
                    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    for i = #entityEspParts, 1, -1 do
                        local rec = entityEspParts[i]
                        local ent = workspace:FindFirstChild(rec.name, true)
                        local part = ent and (ent:FindFirstChild("HumanoidRootPart", true) or ent.PrimaryPart or ent:FindFirstChildWhichIsA("BasePart", true))
                        local pos = part and part.Position
                        if pos and rec.part and rec.part.Parent then
                            rec.part.Position = pos + Vector3.new(0,2,0)
                            if hrp then
                                rec.label.Text = string.format("%s [%.0f]", rec.name, (hrp.Position - pos).Magnitude)
                            else
                                rec.label.Text = rec.name
                            end
                        else
                            if rec.part and rec.part.Parent then rec.part:Destroy() end
                            table.remove(entityEspParts, i)
                        end
                    end
                    task.wait(0.5)
                end
                clearEntityESP()
            end)
        end
    end,
})
-- Add Item ESP (All) toggle
ESPTab:CreateToggle({
    Name = "Item ESP (All)",
    CurrentValue = false,
    Flag = "EnableItemESP",
    Callback = function(state)
        clearItemESP()
        if state then
            for _, mdl in ipairs(getItemModels()) do
                local pos = mdl:IsA("Model") and ((mdl.PrimaryPart and mdl.PrimaryPart.Position) or (mdl:FindFirstChildWhichIsA("BasePart") and mdl:FindFirstChildWhichIsA("BasePart").Position)) or mdl.Position
                if pos then
                    createESPAt(itemEspParts, mdl.Name, pos, Color3.new(0,1,0))
                end
            end
            itemEspUpdateTask = task.spawn(function()
                while #itemEspParts > 0 do
                    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    for i = #itemEspParts, 1, -1 do
                        local rec = itemEspParts[i]
                        local item = ItemsFolder:FindFirstChild(rec.name, true)
                        local pos = item and (item:IsA("Model") and ((item.PrimaryPart and item.PrimaryPart.Position) or (item:FindFirstChildWhichIsA("BasePart") and item:FindFirstChildWhichIsA("BasePart").Position)) or item.Position)
                        if pos and rec.part and rec.part.Parent then
                            rec.part.Position = pos + Vector3.new(0,2,0)
                            if hrp then
                                rec.label.Text = string.format("%s [%.0f]", rec.name, (hrp.Position - pos).Magnitude)
                            else
                                rec.label.Text = rec.name
                            end
                        else
                            if rec.part and rec.part.Parent then rec.part:Destroy() end
                            table.remove(itemEspParts, i)
                        end
                    end
                    task.wait(0.5)
                end
                clearItemESP()
            end)
        end
    end,
})
-- END NEW ESP TAB SECTION --------------------------------------------------

-- Disable original Item/Entity ESP toggles
-- (legacy ESP section removed)

-- Scanner Tab: Explore and dump game objects
-- (scanner section removed)

-- CharacterAdded handling (moved outside Kill Aura block)
LocalPlayer.CharacterAdded:Connect(function(char)
    local humanoid = char:WaitForChild("Humanoid")
    humanoid.WalkSpeed = SpeedToggle.CurrentValue and FAST_WALK_SPEED or DEFAULT_WALK_SPEED
    humanoid.JumpPower = DEFAULT_JUMP_POWER
end)

local RS = game:GetService("ReplicatedStorage")
