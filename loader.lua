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

-- END NEW ESP TAB SECTION --------------------------------------------------

-- Combat Tab and Kill Aura Implementation
local CombatTab = Window:CreateTab("Combat", 4483362458)

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
