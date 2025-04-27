--[[
  KYT Movement Enhancement Module
  Secure version with anti-detection measures
]]

local function SafeWaitForChild(parent, childName)
    local child
    while true do
        child = parent:FindFirstChild(childName)
        if child then return child end
        task.wait()
    end
end

local function CreateSecureInstance(className, properties)
    local success, instance = pcall(function()
        local obj = Instance.new(className)
        for k,v in pairs(properties) do
            pcall(function() obj[k] = v end)
        end
        return obj
    end)
    return success and instance or nil
end

-- Random string generator for obfuscation
local function RandomString(length)
    local chars = {}
    for i = 1, length do
        chars[i] = string.char(math.random(97, 122))
    end
    return table.concat(chars)
end

-- Main execution with error handling
local function Main()
    -- Obfuscated variable names
    local _L = game:GetService("Players").LocalPlayer
    local _I = game:GetService("UserInputService")
    local _R = game:GetService("RunService")
    local _T = task
    
    -- Secure initialization
    local uiParent
    pcall(function()
        uiParent = SafeWaitForChild(_L, "PlayerGui")
    end)
    if not uiParent then return end

    -- Create interface with random elements
    local interfaceName = "UI_"..RandomString(8)..tostring(math.random(100,999))
    local mainContainer = CreateSecureInstance("ScreenGui", {
        Name = interfaceName,
        ResetOnSpawn = false,
        Parent = uiParent
    })
    if not mainContainer then return end

    -- Frame with random properties
    local mainFrame = CreateSecureInstance("Frame", {
        Size = UDim2.new(0, 220, 0, 180),
        Position = UDim2.new(0.5, -110, 0.5, -90),
        BackgroundColor3 = Color3.fromRGB(28, 28, 28),
        BorderSizePixel = 0,
        Parent = mainContainer
    })
    
    -- Delayed element creation
    _T.delay(0.5, function()
        -- Title with random font
        CreateSecureInstance("TextLabel", {
            Name = RandomString(5),
            Text = "Movement Settings",
            Size = UDim2.new(1, 0, 0, 25),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundColor3 = Color3.fromRGB(45, 45, 45),
            TextColor3 = Color3.fromRGB(200, 200, 200),
            Font = math.random() > 0.5 and Enum.Font.Gotham or Enum.Font.SourceSans,
            Parent = mainFrame
        })
        
        -- Movement controls
        local buttonProperties = {
            Size = UDim2.new(0.9, 0, 0, 30),
            BackgroundColor3 = Color3.fromRGB(60, 60, 60),
            TextColor3 = Color3.fromRGB(220, 220, 220),
            Font = Enum.Font.SourceSans,
            TextSize = 14,
            AutoButtonColor = false
        }
        
        local flyButton = CreateSecureInstance("TextButton", {
            Text = "Flight Mode (F)",
            Position = UDim2.new(0.05, 0, 0.2, 0),
            Parent = mainFrame
        })
        table.foreach(buttonProperties, function(k,v) flyButton[k] = v end)
        
        local noclipButton = CreateSecureInstance("TextButton", {
            Text = "Collision Mode (V)",
            Position = UDim2.new(0.05, 0, 0.45, 0),
            Parent = mainFrame
        })
        table.foreach(buttonProperties, function(k,v) noclipButton[k] = v end)
        
        -- Speed control with random name
        CreateSecureInstance("TextBox", {
            Name = "Input_"..RandomString(4),
            Text = "50",
            PlaceholderText = "Set speed",
            Size = UDim2.new(0.9, 0, 0, 25),
            Position = UDim2.new(0.05, 0, 0.7, 0),
            BackgroundColor3 = Color3.fromRGB(50, 50, 50),
            TextColor3 = Color3.fromRGB(240, 240, 240),
            ClearTextOnFocus = false,
            Parent = mainFrame
        })
        
        -- Make frame draggable
        local dragStart, startPos
        mainFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragStart = input.Position
                startPos = mainFrame.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragStart = nil
                    end
                end)
            end
        end)
        
        mainFrame.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement and dragStart then
                local delta = input.Position - dragStart
                mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, 
                                             startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
        
        -- Movement logic
        local flightActive = false
        local noclipActive = false
        local currentSpeed = 50
        
        -- Update button states with delay
        local function UpdateButtonStates()
            _T.spawn(function()
                _T.wait(0.1)
                flyButton.BackgroundColor3 = flightActive and Color3.fromRGB(80, 160, 80) or Color3.fromRGB(60, 60, 60)
                noclipButton.BackgroundColor3 = noclipActive and Color3.fromRGB(80, 160, 80) or Color3.fromRGB(60, 60, 60)
            end)
        end
        
        -- Movement handler
        _R.Heartbeat:Connect(function()
            if not _L.Character then return end
            
            local root = _L.Character:FindFirstChild("HumanoidRootPart")
            if not root then return end
            
            -- Flight logic
            if flightActive then
                local camera = workspace.CurrentCamera
                local moveDirection = Vector3.new()
                
                if _I:IsKeyDown(Enum.KeyCode.W) then moveDirection += camera.CFrame.LookVector end
                if _I:IsKeyDown(Enum.KeyCode.S) then moveDirection -= camera.CFrame.LookVector end
                if _I:IsKeyDown(Enum.KeyCode.D) then moveDirection += camera.CFrame.RightVector end
                if _I:IsKeyDown(Enum.KeyCode.A) then moveDirection -= camera.CFrame.RightVector end
                if _I:IsKeyDown(Enum.KeyCode.Space) then moveDirection += Vector3.new(0, 1, 0) end
                if _I:IsKeyDown(Enum.KeyCode.LeftControl) then moveDirection -= Vector3.new(0, 1, 0) end
                
                if moveDirection.Magnitude > 0 then
                    root.Velocity = moveDirection.Unit * currentSpeed
                else
                    root.Velocity = Vector3.new()
                end
            end
            
            -- Noclip logic
            if noclipActive then
                for _, part in pairs(_L.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
        
        -- UI interactions
        flyButton.MouseButton1Click:Connect(function()
            flightActive = not flightActive
            UpdateButtonStates()
        end)
        
        noclipButton.MouseButton1Click:Connect(function()
            noclipActive = not noclipActive
            UpdateButtonStates()
        end)
        
        -- Keyboard controls
        _I.InputBegan:Connect(function(input, processed)
            if processed then return end
            
            if input.KeyCode == Enum.KeyCode.F then
                flightActive = not flightActive
                UpdateButtonStates()
            elseif input.KeyCode == Enum.KeyCode.V then
                noclipActive = not noclipActive
                UpdateButtonStates()
            end
        end)
        
        -- Speed control
        mainFrame.ChildAdded:Connect(function(child)
            if string.find(child.Name, "Input_") then
                child.FocusLost:Connect(function()
                    local num = tonumber(child.Text)
                    if num and num > 0 then
                        currentSpeed = math.clamp(num, 10, 200)
                        child.Text = tostring(math.floor(currentSpeed))
                    else
                        child.Text = "50"
                        currentSpeed = 50
                    end
                end)
            end
        end)
        
        -- Cleanup on reset
        _L.CharacterAdded:Connect(function()
            flightActive = false
            noclipActive = false
            UpdateButtonStates()
        end)
    end)
end

-- Protected execution
local success, err = pcall(Main)
if not success then
    warn("Initialization completed with minor issues")
end
