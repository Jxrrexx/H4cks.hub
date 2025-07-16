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
    Theme = "Default"
})

-- Print discord link and notify
print("[H4cks.hub] Join our Discord for extra features and more games: https://discord.gg/BnPXzFhYbB")
Rayfield:Notify({
    Title = "H4cks.hub",
    Content = "Join our Discord for extra features! (Link in F9)",
    Duration = 5
})

local PlayerTab = Window:CreateTab("Player", "user")
local ItemTab = Window:CreateTab("Items", "package")
local KidsTab = Window:CreateTab("Missing Kids", "baby")
local CombatTab = Window:CreateTab("Combat", 4483362458)
local ESPTab = Window:CreateTab("ESP", 4483362458)
local TeleportTab = Window:CreateTab("Teleport", "package")

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

local function teleportSingleItem(itemName: string)
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart", 5)
    if not hrp then return end
    
    -- Find first matching item
    for _, mdl in ipairs(ItemsFolder:GetChildren()) do
        if mdl.Name == itemName and mdl:IsA("Model") then
            local main = mdl.PrimaryPart or mdl:FindFirstChildWhichIsA("BasePart")
            if main then
                mdl:SetPrimaryPartCFrame(hrp.CFrame + Vector3.new(math.random(-5,5), 0, math.random(-5,5)))
                break -- Only teleport one item
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

local TeleportSingleBtn = ItemTab:CreateButton({
    Name = "Teleport Single Item",
    Callback = function()
        if #selectedItems > 0 then
            teleportSingleItem(selectedItems[1])
        end
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
local espParts = {
    players = {},
    kids = {},
    chests = {},
    items = {},
    enemies = {},
    custom_items = {},
    custom_characters = {}
}

local espEnabled = {
    players = false,
    kids = false,
    items = false,
    enemies = false,
    chests = false
}

-- ESP handling additions for custom ESP
local customItemESPEnabled = false
local customCharacterESPEnabled = false
local selectedCustomItems = {}
local selectedCustomCharacters = {}

local function clearESP(espType)
    if espType then
        for _, rec in ipairs(espParts[espType]) do
            if rec.part and rec.part.Parent then
                rec.part:Destroy()
            end
        end
        table.clear(espParts[espType])
    else
        for _, typeTable in pairs(espParts) do
            for _, rec in ipairs(typeTable) do
        if rec.part and rec.part.Parent then
            rec.part:Destroy()
                end
            end
            table.clear(typeTable)
        end
    end
end

local function createESPAt(name, pos, espType, color, object)
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
    text.TextColor3 = color or Color3.new(1,1,0)
    text.TextScaled = true
    text.Font = Enum.Font.SourceSansBold
    text.Text = ""  -- Start with empty text
    text.Parent = bill

    local newESP = {
        part = part, 
        name = name, 
        label = text, 
        object = object, -- Store reference to the actual object
        objectId = object and object:GetFullName() -- Store unique identifier for the object
    }
    
    table.insert(espParts[espType], newESP)
    return newESP
end

-- ESP Update Function
local function updateESP()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    -- Update Player ESP
    if espEnabled.players then
        -- Remove ESP for players that no longer exist
        for i = #espParts.players, 1, -1 do
            local rec = espParts.players[i]
            local player = Players:FindFirstChild(rec.name)
            if not player then
                if rec.part and rec.part.Parent then 
                    rec.part:Destroy() 
                end
                table.remove(espParts.players, i)
            else
                local char = player.Character
                local playerRoot = char and char:FindFirstChild("HumanoidRootPart")
                if not playerRoot then
                    if rec.part and rec.part.Parent then 
                        rec.part:Destroy() 
                    end
                    table.remove(espParts.players, i)
                end
            end
        end
        
        -- Create/update ESP for existing players
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local char = player.Character
                if char then
                    local playerRoot = char:FindFirstChild("HumanoidRootPart")
                    if playerRoot then
                        local found = false
                        for _, rec in ipairs(espParts.players) do
                            if rec.name == player.Name then
                                found = true
                                rec.part.Position = playerRoot.Position + Vector3.new(0,2,0)
                                if hrp then
                                    local dist = (hrp.Position - playerRoot.Position).Magnitude
                                    rec.label.Text = string.format("%s [%.0f]", player.Name, dist)
                                end
                                break
                            end
                        end
                        if not found then
                            createESPAt(player.Name, playerRoot.Position, "players", Color3.new(1,0,0), player)
                        end
                    end
                end
            end
        end
    end
    
    -- Update Item ESP
    if espEnabled.items then
        -- Remove ESP for items that no longer exist
        for i = #espParts.items, 1, -1 do
            local rec = espParts.items[i]
            local object = rec.object
            
            -- Check if the object still exists
            if not (object and object.Parent) then
                if rec.part and rec.part.Parent then 
                    rec.part:Destroy() 
                end
                table.remove(espParts.items, i)
            end
        end
        
        -- Create/update ESP for existing items
        if workspace:FindFirstChild("Items") then
            for _, item in ipairs(workspace.Items:GetChildren()) do
                if item:IsA("Model") or item:IsA("BasePart") then
                    local itemPart = item:IsA("Model") and (item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")) or item
                    if itemPart then
                        local found = false
                        for _, rec in ipairs(espParts.items) do
                            if rec.object == item then
                                found = true
                                rec.part.Position = itemPart.Position + Vector3.new(0,2,0)
                                if hrp then
                                    local dist = (hrp.Position - itemPart.Position).Magnitude
                                    rec.label.Text = string.format("%s [%.0f]", item.Name, dist)
                                end
                                break
                            end
                        end
                        if not found then
                            createESPAt(item.Name, itemPart.Position, "items", Color3.new(0,1,0), item)
                        end
                    end
                end
            end
        end
    end
    
    -- Update Enemy ESP
    if espEnabled.enemies then
        -- Remove ESP for enemies that no longer exist
        for i = #espParts.enemies, 1, -1 do
            local rec = espParts.enemies[i]
            local object = rec.object
            
            -- Check if the object still exists
            if not (object and object.Parent) then
                if rec.part and rec.part.Parent then 
                    rec.part:Destroy() 
                end
                table.remove(espParts.enemies, i)
            end
        end
        
        -- Create/update ESP for existing enemies
        if workspace:FindFirstChild("Characters") then
            for _, enemy in ipairs(workspace.Characters:GetChildren()) do
                if enemy:IsA("Model") then
                    local enemyPart = enemy.PrimaryPart or enemy:FindFirstChild("HitBox") or enemy:FindFirstChildWhichIsA("BasePart")
                    if enemyPart then
                        local found = false
                        for _, rec in ipairs(espParts.enemies) do
                            if rec.object == enemy then
                                found = true
                                rec.part.Position = enemyPart.Position + Vector3.new(0,2,0)
                                if hrp then
                                    local dist = (hrp.Position - enemyPart.Position).Magnitude
                                    rec.label.Text = string.format("%s [%.0f]", enemy.Name, dist)
                                end
                                break
                            end
                        end
                        if not found then
                            createESPAt(enemy.Name, enemyPart.Position, "enemies", Color3.new(1,0,0), enemy)
                        end
                    end
                end
            end
        end
    end

    -- Update Kid ESP
    if espEnabled.kids then
        -- Remove ESP for kids that no longer exist
        for i = #espParts.kids, 1, -1 do
            local rec = espParts.kids[i]
            local pos = getKidPosition(rec.name)
            if not pos then
                if rec.part and rec.part.Parent then 
                    rec.part:Destroy() 
                end
                table.remove(espParts.kids, i)
            else
                rec.part.Position = pos + Vector3.new(0,2,0)
                if hrp then
                    local dist = (hrp.Position - pos).Magnitude
                    rec.label.Text = string.format("%s [%.0f]", rec.name, dist)
                end
            end
        end
        
        -- Create ESP for new kids
        for _, kidName in ipairs(getKidNames()) do
            local found = false
            for _, rec in ipairs(espParts.kids) do
                if rec.name == kidName then
                    found = true
                    break
                end
            end
            if not found then
                local pos = getKidPosition(kidName)
                if pos then
                    createESPAt(kidName, pos, "kids", Color3.new(1,1,0), nil)
                end
            end
        end
    end

    -- Update Chest ESP
    if espEnabled.chests then
        -- Remove ESP for chests that no longer exist
        for i = #espParts.chests, 1, -1 do
            local rec = espParts.chests[i]
            local object = rec.object
            
            -- Check if the object still exists
            if not (object and object.Parent) then
                if rec.part and rec.part.Parent then 
                    rec.part:Destroy() 
                end
                table.remove(espParts.chests, i)
            end
        end
        
        -- Create/update ESP for existing chests
        if workspace:FindFirstChild("Items") then
            for _, item in ipairs(workspace.Items:GetChildren()) do
                if (item:IsA("Model") or item:IsA("BasePart")) and item.Name == "Item Chest" then
                    local itemPart = item:IsA("Model") and (item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")) or item
                    if itemPart then
                        local found = false
                        for _, rec in ipairs(espParts.chests) do
                            if rec.object == item then
                                found = true
                                rec.part.Position = itemPart.Position + Vector3.new(0,2,0)
                                if hrp then
                                    local dist = (hrp.Position - itemPart.Position).Magnitude
                                    rec.label.Text = string.format("%s [%.0f]", item.Name, dist)
                                end
                                break
                            end
                        end
                        if not found then
                            createESPAt(item.Name, itemPart.Position, "chests", Color3.new(1, 0.5, 0), item)
                        end
                    end
                end
            end
        end
    end
    
    -- Custom Item ESP
    if customItemESPEnabled then
        -- Remove ESP for custom items that no longer exist
        for i = #espParts.custom_items, 1, -1 do
            local rec = espParts.custom_items[i]
            local object = rec.object
            
            -- Check if the object still exists
            if not (object and object.Parent) then
                if rec.part and rec.part.Parent then 
                    rec.part:Destroy() 
                end
                table.remove(espParts.custom_items, i)
            end
        end
        
        -- Create/update ESP for existing custom items
        if workspace:FindFirstChild("Items") then
            for _, item in ipairs(workspace.Items:GetChildren()) do
                if (item:IsA("Model") or item:IsA("BasePart")) and table.find(selectedCustomItems, item.Name) then
                    local itemPart = item:IsA("Model") and (item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")) or item
                    if itemPart then
                        local found = false
                        for _, rec in ipairs(espParts.custom_items) do
                            if rec.object == item then
                                found = true
                                rec.part.Position = itemPart.Position + Vector3.new(0,2,0)
                                if hrp then
                                    local dist = (hrp.Position - itemPart.Position).Magnitude
                                    rec.label.Text = string.format("%s [%.0f]", item.Name, dist)
                                end
                                break
                            end
                        end
                        if not found then
                            createESPAt(item.Name, itemPart.Position, "custom_items", Color3.new(0,1,1), item)
                        end
                    end
                end
            end
        end
    end
    
    -- Custom Character ESP
    if customCharacterESPEnabled then
        -- Remove ESP for custom characters that no longer exist
        for i = #espParts.custom_characters, 1, -1 do
            local rec = espParts.custom_characters[i]
            local object = rec.object
            
            -- Check if the object still exists
            if not (object and object.Parent) then
                if rec.part and rec.part.Parent then 
                    rec.part:Destroy() 
                end
                table.remove(espParts.custom_characters, i)
            end
        end
        
        -- Create/update ESP for existing custom characters
        if workspace:FindFirstChild("Characters") then
            for _, char in ipairs(workspace.Characters:GetChildren()) do
                if char:IsA("Model") and table.find(selectedCustomCharacters, char.Name) then
                    local charPart = char.PrimaryPart or char:FindFirstChild("HumanoidRootPart") or char:FindFirstChildWhichIsA("BasePart")
                    if charPart then
                        local found = false
                        for _, rec in ipairs(espParts.custom_characters) do
                            if rec.object == char then
                                found = true
                                rec.part.Position = charPart.Position + Vector3.new(0,2,0)
                                if hrp then
                                    local dist = (hrp.Position - charPart.Position).Magnitude
                                    rec.label.Text = string.format("%s [%.0f]", char.Name, dist)
                                end
                                break
                            end
                        end
                        if not found then
                            createESPAt(char.Name, charPart.Position, "custom_characters", Color3.new(1,0,1), char)
                        end
                    end
                end
            end
        end
    end
end

-- Remove the old updateESP function override
local oldUpdateESP = updateESP
function updateESP()
    -- Call the new updateESP function directly
    oldUpdateESP()
end

-- ESP Tab UI
-- Player ESP
local PlayerESPToggle = ESPTab:CreateToggle({
    Name = "Player ESP",
    CurrentValue = false,
    Flag = "PlayerESP",
    Callback = function(state)
        espEnabled.players = state
        clearESP("players")
    end,
})

-- Item ESP
local ItemESPToggle = ESPTab:CreateToggle({
    Name = "Item ESP",
    CurrentValue = false,
    Flag = "ItemESP",
    Callback = function(state)
        espEnabled.items = state
        clearESP("items")
    end,
})

local ChestESPToggle = ESPTab:CreateToggle({
    Name = "Chest ESP",
    CurrentValue = false,
    Flag = "ChestESP",
    Callback = function(state)
        espEnabled.chests = state
        clearESP("chests")
    end,
})

-- Enemy ESP
local EnemyESPToggle = ESPTab:CreateToggle({
    Name = "Enemy ESP",
    CurrentValue = false,
    Flag = "EnemyESP",
    Callback = function(state)
        espEnabled.enemies = state
        clearESP("enemies")
    end,
})

-- Kid ESP
local KidsESPToggle = ESPTab:CreateToggle({
    Name = "Kid ESP",
    CurrentValue = false,
    Flag = "KidsESP",
    Callback = function(state)
        espEnabled.kids = state
        clearESP("kids")
    end,
})

-- Helper to get all unique item names
local function getAllUniqueItemNames()
    local seen = {}
    local names = {}
    if workspace:FindFirstChild("Items") then
        for _, item in ipairs(workspace.Items:GetChildren()) do
            if (item:IsA("Model") or item:IsA("BasePart")) and not seen[item.Name] then
                seen[item.Name] = true
                table.insert(names, item.Name)
            end
        end
    end
    table.sort(names)
    return names
end

-- Helper to get all unique character names
local function getAllUniqueCharacterNames()
    local seen = {}
    local names = {}
    if workspace:FindFirstChild("Characters") then
        for _, char in ipairs(workspace.Characters:GetChildren()) do
            if char:IsA("Model") and not seen[char.Name] then
                seen[char.Name] = true
                table.insert(names, char.Name)
            end
        end
    end
    table.sort(names)
    return names
end

-- Custom ESP UI elements
local CustomItemDropdown = ESPTab:CreateDropdown({
    Name = "Custom Item ESP (Select Items)",
    Options = getAllUniqueItemNames(),
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "CustomItemDropdown",
    Callback = function(opts)
        selectedCustomItems = opts
    end,
})

local CustomItemESPToggle = ESPTab:CreateToggle({
    Name = "Custom Item ESP",
    CurrentValue = false,
    Flag = "CustomItemESP",
    Callback = function(state)
        customItemESPEnabled = state
        clearESP("custom_items")
    end,
})

local CustomCharacterDropdown = ESPTab:CreateDropdown({
    Name = "Custom Character ESP (Select Characters)",
    Options = getAllUniqueCharacterNames(),
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "CustomCharacterDropdown",
    Callback = function(opts)
        selectedCustomCharacters = opts
    end,
})

local CustomCharacterESPToggle = ESPTab:CreateToggle({
    Name = "Custom Character ESP",
    CurrentValue = false,
    Flag = "CustomCharacterESP",
    Callback = function(state)
        customCharacterESPEnabled = state
        clearESP("custom_characters")
    end,
})

-- ESP Color Picker
local ESPColorPicker = ESPTab:CreateColorPicker({
    Name = "ESP Color",
    Color = Color3.new(1,1,0),
    Flag = "ESPColor",
    Callback = function(color)
        for _, typeTable in pairs(espParts) do
            for _, rec in ipairs(typeTable) do
                if rec.label then
                    rec.label.TextColor3 = color
                end
            end
        end
    end,
})

-- Start ESP Update Loop
task.spawn(function()
    while true do
        if espEnabled.players or espEnabled.items or espEnabled.enemies or espEnabled.kids or espEnabled.chests or customItemESPEnabled or customCharacterESPEnabled then
            updateESP()
        end
        task.wait(0.1)
    end
end)

-- Handle player added/removed for ESP
Players.PlayerAdded:Connect(function(player)
    if espEnabled.players then
        player.CharacterAdded:Connect(function(char)
            local hrp = char:WaitForChild("HumanoidRootPart", 5)
            if hrp then
                createESPAt(player.Name, hrp.Position, "players", Color3.new(1,0,0), player)
            end
        end)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    for i, rec in ipairs(espParts.players) do
        if rec.name == player.Name then
            if rec.part and rec.part.Parent then
                rec.part:Destroy()
            end
            table.remove(espParts.players, i)
            break
        end
    end
end)

-- Add ESP Configuration Options
-- Remove old ESP toggle from Kids tab since it's now in ESP tab

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

local RefreshKidsBtn = KidsTab:CreateButton({
    Name = "Refresh Kid List",
    Callback = function()
        KidsDropdown:Refresh(getKidNames())
    end,
})

-- END NEW ESP TAB SECTION --------------------------------------------------

-- Combat Tab and Kill Aura Implementation
-- Variables for Kill Aura
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DamageEvent = ReplicatedStorage.RemoteEvents.ToolDamageObject
local Characters = workspace.Characters

-- Configuration
local Config = {
    Enabled = false,
    Range = 30,
    AttackDelay = 0.1,
    CurrentAmount = 0,
    ActiveTargets = {}
}

-- Toggle for KillAura
CombatTab:CreateToggle({
    Name = "KillAura",
    CurrentValue = false,
    Flag = "KillAuraEnabled",
    Callback = function(Value)
        Config.Enabled = Value
        if Value then
            StartKillAura()
        else
            Config.ActiveTargets = {}
        end
    end,
})

-- Slider for Range
CombatTab:CreateSlider({
    Name = "Range",
    Range = {1, 100},
    Increment = 5,
    Suffix = "Studs",
    CurrentValue = 30,
    Flag = "KillAuraRange",
    Callback = function(Value)
        Config.Range = Value
    end,
})

-- Slider for Attack Speed
CombatTab:CreateSlider({
    Name = "Attack Speed",
    Range = {0.05, 1},
    Increment = 0.05,
    Suffix = "Seconds",
    CurrentValue = 0.1,
    Flag = "AttackDelay",
    Callback = function(Value)
        Config.AttackDelay = Value
    end,
})

-- Optimized target validation
local function isValidTarget(character)
    return character and character:IsA("Model")
end

-- Optimized damage function
local function DamageTarget(target)
    -- List of weapons to try in order of preference
    local weapons = {
        "Morningstar",
        "Good Axe",
        "Spear",
        "Old Axe"
    }
    
    -- Try each weapon in order
    local weaponToUse = nil
    for _, weapon in ipairs(weapons) do
        if LocalPlayer.Inventory:FindFirstChild(weapon) then
            weaponToUse = LocalPlayer.Inventory[weapon]
            break
        end
    end
    
    -- If no weapon found, return
    if not weaponToUse then return end
    
    Config.CurrentAmount = Config.CurrentAmount + 1
    DamageEvent:InvokeServer(
        target,
        weaponToUse,
        tostring(Config.CurrentAmount) .. "_7367831688",
        CFrame.new(-2.962610244751, 4.5547881126404, -75.950843811035, 0.89621275663376, -1.3894891459643e-08, 0.44362446665764, -7.994568895775e-10, 1, 3.293635941759e-08, -0.44362446665764, -2.9872644802253e-08, 0.89621275663376)
    )
end

-- Optimized attack loop
local function AttackLoop(target)
    if not Config.ActiveTargets[target] then
        Config.ActiveTargets[target] = true
        task.spawn(function()
            while target and Config.Enabled and Config.ActiveTargets[target] do
                DamageTarget(target)
                task.wait(Config.AttackDelay)
            end
        end)
    end
end

-- Main KillAura function
function StartKillAura()
    task.spawn(function()
        while Config.Enabled do
            local playerRoot = LocalPlayer.Character and LocalPlayer.Character.PrimaryPart
            if playerRoot then
                for _, target in ipairs(Characters:GetChildren()) do
                    if not Config.Enabled then break end
                    if isValidTarget(target) then
                        local targetPart = target.PrimaryPart or target:FindFirstChild("HitBox")
                        if targetPart and (targetPart.Position - playerRoot.Position).Magnitude <= Config.Range then
                            AttackLoop(target)
                        else
                            Config.ActiveTargets[target] = nil
                        end
                    end
                end
            end
            task.wait(0.1)
        end
    end)
end

-- CharacterAdded handling
LocalPlayer.CharacterAdded:Connect(function(char)
    local humanoid = char:WaitForChild("Humanoid")
    humanoid.WalkSpeed = SpeedToggle.CurrentValue and FAST_WALK_SPEED or DEFAULT_WALK_SPEED
    humanoid.JumpPower = DEFAULT_JUMP_POWER
end)

local function getChestNames()
    local names = {}
    if workspace:FindFirstChild("Items") then
        for _, item in ipairs(workspace.Items:GetChildren()) do
            if (item:IsA("Model") or item:IsA("BasePart")) and item.Name == "Item Chest" then
                table.insert(names, item.Name)
            end
        end
    end
    return names
end

local selectedChest = nil

local ChestDropdown = TeleportTab:CreateDropdown({
    Name = "Select Chest",
    Options = getChestNames(),
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "ChestDropdown",
    Callback = function(opt)
        if type(opt) == "table" then
            selectedChest = opt[1]
        else
            selectedChest = opt
        end
    end,
})

TeleportTab:CreateButton({
    Name = "Teleport to Chest",
    Callback = function()
        if not selectedChest then return end
        if workspace:FindFirstChild("Items") then
            for _, item in ipairs(workspace.Items:GetChildren()) do
                if (item:IsA("Model") or item:IsA("BasePart")) and item.Name == selectedChest then
                    local part = item:IsA("Model") and (item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")) or item
                    if part then
                        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                        local hrp = character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            hrp.CFrame = CFrame.new(part.Position + Vector3.new(0, 3, 0))
                        end
                    end
                    break
                end
            end
        end
    end,
})

TeleportTab:CreateButton({
    Name = "Refresh Chest List",
    Callback = function()
        ChestDropdown:Refresh(getChestNames())
    end,
})
