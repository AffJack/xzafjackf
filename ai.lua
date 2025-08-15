-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

-- API Configuration
local API_KEY = "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"
local API_URL = "https://api.openai.com/v1/chat/completions"

-- Remote Events/Functions
local ChatRemoteEvent = Instance.new("RemoteEvent")
ChatRemoteEvent.Name = "ChatAIResponse"
ChatRemoteEvent.Parent = ReplicatedStorage

local AIServiceRemote = Instance.new("RemoteFunction")
AIServiceRemote.Name = "AIService"
AIServiceRemote.Parent = ReplicatedStorage

-- GUI Creation
local function createMainGUI(player)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AIChatGUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    screenGui.ResetOnSpawn = false

    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 400, 0, 500)
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui

    -- Corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame

    -- Drop shadow
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 10, 1, 10)
    shadow.Position = UDim2.new(0, -5, 0, -5)
    shadow.Image = "rbxassetid://1316045217"
    shadow.ImageColor3 = Color3.new(0, 0, 0)
    shadow.ImageTransparency = 0.8
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.BackgroundTransparency = 1
    shadow.Parent = mainFrame
    shadow.ZIndex = -1

    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = titleBar

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(0.7, 0, 1, 0)
    title.Position = UDim2.new(0.1, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "AI Chat Assistant"
    title.TextColor3 = Color3.fromRGB(220, 220, 220)
    title.Font = Enum.Font.GothamMedium
    title.TextSize = 14
    title.Parent = titleBar

    -- Close/Minimize Button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -30, 0, 0)
    closeButton.BackgroundTransparency = 1
    closeButton.Text = "×"
    closeButton.TextColor3 = Color3.fromRGB(220, 220, 220)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 18
    closeButton.Parent = titleBar

    -- Minimized Button (hidden initially)
    local minimizedButton = Instance.new("ImageButton")
    minimizedButton.Name = "MinimizedButton"
    minimizedButton.Size = UDim2.new(0, 50, 0, 50)
    minimizedButton.Position = UDim2.new(1, -60, 1, -60)
    minimizedButton.BackgroundTransparency = 1
    minimizedButton.Image = "rbxassetid://3926305904" -- Default AI icon
    minimizedButton.ImageRectSize = Vector2.new(36, 36)
    minimizedButton.ImageRectOffset = Vector2.new(324, 364)
    minimizedButton.Visible = false
    minimizedButton.Parent = screenGui

    -- Content Frame
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "ContentFrame"
    contentFrame.Size = UDim2.new(1, -20, 1, -100)
    contentFrame.Position = UDim2.new(0, 10, 0, 40)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = mainFrame

    -- Player Selection
    local playerSelection = Instance.new("ScrollingFrame")
    playerSelection.Name = "PlayerSelection"
    playerSelection.Size = UDim2.new(1, 0, 0, 120)
    playerSelection.Position = UDim2.new(0, 0, 0, 0)
    playerSelection.BackgroundTransparency = 1
    playerSelection.ScrollBarThickness = 4
    playerSelection.CanvasSize = UDim2.new(0, 0, 0, 0)
    playerSelection.AutomaticCanvasSize = Enum.AutomaticSize.Y
    playerSelection.Parent = contentFrame

    local playerListLayout = Instance.new("UIListLayout")
    playerListLayout.Name = "PlayerListLayout"
    playerListLayout.Padding = UDim.new(0, 5)
    playerListLayout.Parent = playerSelection

    -- Role Selection
    local roleLabel = Instance.new("TextLabel")
    roleLabel.Name = "RoleLabel"
    roleLabel.Size = UDim2.new(1, 0, 0, 20)
    roleLabel.Position = UDim2.new(0, 0, 0, 130)
    roleLabel.BackgroundTransparency = 1
    roleLabel.Text = "AI Role:"
    roleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    roleLabel.Font = Enum.Font.Gotham
    roleLabel.TextSize = 12
    roleLabel.TextXAlignment = Enum.TextXAlignment.Left
    roleLabel.Parent = contentFrame

    local roleDropdown = Instance.new("TextButton")
    roleDropdown.Name = "RoleDropdown"
    roleDropdown.Size = UDim2.new(1, 0, 0, 30)
    roleDropdown.Position = UDim2.new(0, 0, 0, 150)
    roleDropdown.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    roleDropdown.Text = "Select Role..."
    roleDropdown.TextColor3 = Color3.fromRGB(220, 220, 220)
    roleDropdown.Font = Enum.Font.Gotham
    roleDropdown.TextSize = 12
    roleDropdown.Parent = contentFrame

    local roleDropdownCorner = Instance.new("UICorner")
    roleDropdownCorner.CornerRadius = UDim.new(0, 4)
    roleDropdownCorner.Parent = roleDropdown

    -- Role options (hidden initially)
    local roleOptions = Instance.new("Frame")
    roleOptions.Name = "RoleOptions"
    roleOptions.Size = UDim2.new(1, 0, 0, 0)
    roleOptions.Position = UDim2.new(0, 0, 0, 180)
    roleOptions.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    roleOptions.Visible = false
    roleOptions.Parent = contentFrame

    local roleOptionsCorner = Instance.new("UICorner")
    roleOptionsCorner.CornerRadius = UDim.new(0, 4)
    roleOptionsCorner.Parent = roleOptions

    local roleOptionsList = Instance.new("UIListLayout")
    roleOptionsList.Name = "RoleOptionsList"
    roleOptionsList.Parent = roleOptions

    -- Custom Prompt
    local promptLabel = Instance.new("TextLabel")
    promptLabel.Name = "PromptLabel"
    promptLabel.Size = UDim2.new(1, 0, 0, 20)
    promptLabel.Position = UDim2.new(0, 0, 0, 190)
    promptLabel.BackgroundTransparency = 1
    promptLabel.Text = "Custom Prompt (optional):"
    promptLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    promptLabel.Font = Enum.Font.Gotham
    promptLabel.TextSize = 12
    promptLabel.TextXAlignment = Enum.TextXAlignment.Left
    promptLabel.Parent = contentFrame

    local promptBox = Instance.new("TextBox")
    promptBox.Name = "PromptBox"
    promptBox.Size = UDim2.new(1, 0, 0, 60)
    promptBox.Position = UDim2.new(0, 0, 0, 210)
    promptBox.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    promptBox.TextColor3 = Color3.fromRGB(220, 220, 220)
    promptBox.Font = Enum.Font.Gotham
    promptBox.TextSize = 12
    promptBox.TextWrapped = true
    promptBox.PlaceholderText = "Enter custom instructions for the AI..."
    promptBox.ClearTextOnFocus = false
    promptBox.Text = ""
    promptBox.Parent = contentFrame

    local promptBoxCorner = Instance.new("UICorner")
    promptBoxCorner.CornerRadius = UDim.new(0, 4)
    promptBoxCorner.Parent = promptBox

    -- Input Area
    local inputFrame = Instance.new("Frame")
    inputFrame.Name = "InputFrame"
    inputFrame.Size = UDim2.new(1, -20, 0, 80)
    inputFrame.Position = UDim2.new(0, 10, 1, -90)
    inputFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    inputFrame.Parent = mainFrame

    local inputFrameCorner = Instance.new("UICorner")
    inputFrameCorner.CornerRadius = UDim.new(0, 8)
    inputFrameCorner.Parent = inputFrame

    local inputBox = Instance.new("TextBox")
    inputBox.Name = "InputBox"
    inputBox.Size = UDim2.new(1, -80, 1, -10)
    inputBox.Position = UDim2.new(0, 10, 0, 5)
    inputBox.BackgroundTransparency = 1
    inputBox.TextColor3 = Color3.fromRGB(220, 220, 220)
    inputBox.Font = Enum.Font.Gotham
    inputBox.TextSize = 12
    inputBox.TextWrapped = true
    inputBox.PlaceholderText = "Type your message to the AI..."
    inputBox.ClearTextOnFocus = false
    inputBox.Parent = inputFrame

    local sendButton = Instance.new("TextButton")
    sendButton.Name = "SendButton"
    sendButton.Size = UDim2.new(0, 60, 0, 30)
    sendButton.Position = UDim2.new(1, -70, 0.5, -15)
    sendButton.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
    sendButton.Text = "Send"
    sendButton.TextColor3 = Color3.fromRGB(220, 220, 220)
    sendButton.Font = Enum.Font.GothamMedium
    sendButton.TextSize = 12
    sendButton.Parent = inputFrame

    local sendButtonCorner = Instance.new("UICorner")
    sendButtonCorner.CornerRadius = UDim.new(0, 4)
    sendButtonCorner.Parent = sendButton

    -- Status Label
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Size = UDim2.new(1, -20, 0, 20)
    statusLabel.Position = UDim2.new(0, 10, 1, -100)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Ready"
    statusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextSize = 10
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = mainFrame

    -- Predefined roles
    local roles = {
        {
            Name = "Programmer",
            Prompt = "You are an expert programmer. Provide concise answers with code optimizations when possible. Format code in markdown."
        },
        {
            Name = "Funny Bot",
            Prompt = "You are a humorous assistant. Keep responses light-hearted and entertaining. Include jokes and puns when appropriate."
        },
        {
            Name = "Strict Moderator",
            Prompt = "You are a formal moderator. Respond professionally and enforce rules. Keep answers brief and authoritative."
        },
        {
            Name = "Game Guide",
            Prompt = "You are a helpful game guide. Provide tips and explanations about game mechanics without spoilers."
        }
    }

    -- Create role options
    for _, role in ipairs(roles) do
        local roleButton = Instance.new("TextButton")
        roleButton.Name = role.Name
        roleButton.Size = UDim2.new(1, 0, 0, 30)
        roleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
        roleButton.Text = role.Name
        roleButton.TextColor3 = Color3.fromRGB(220, 220, 220)
        roleButton.Font = Enum.Font.Gotham
        roleButton.TextSize = 12
        roleButton.Parent = roleOptions

        local roleButtonCorner = Instance.new("UICorner")
        roleButtonCorner.CornerRadius = UDim.new(0, 4)
        roleButtonCorner.Parent = roleButton

        roleButton.MouseButton1Click:Connect(function()
            roleDropdown.Text = role.Name
            promptBox.Text = role.Prompt
            roleOptions.Visible = false
        end)
    end

    -- Update role options size
    roleOptionsList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        roleOptions.Size = UDim2.new(1, 0, 0, roleOptionsList.AbsoluteContentSize.Y)
    end)

    -- Variables
    local selectedPlayers = {}
    local isDragging = false
    local dragStartPos = Vector2.new(0, 0)
    local frameStartPos = Vector2.new(0, 0)
    local lastRequestTime = 0

    -- Functions
    local function updatePlayerList()
        -- Clear existing player list
        for _, child in ipairs(playerSelection:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end

        -- Add all players to the list
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= player then
                local playerFrame = Instance.new("Frame")
                playerFrame.Name = player.Name
                playerFrame.Size = UDim2.new(1, 0, 0, 30)
                playerFrame.BackgroundTransparency = 1

                local checkbox = Instance.new("ImageButton")
                checkbox.Name = "Checkbox"
                checkbox.Size = UDim2.new(0, 20, 0, 20)
                checkbox.Position = UDim2.new(0, 0, 0.5, -10)
                checkbox.BackgroundTransparency = 1
                checkbox.Image = "rbxassetid://3926305904"
                checkbox.ImageRectOffset = Vector2.new(312, 4)
                checkbox.ImageRectSize = Vector2.new(24, 24)
                checkbox.Parent = playerFrame

                local playerName = Instance.new("TextLabel")
                playerName.Name = "PlayerName"
                playerName.Size = UDim2.new(1, -30, 1, 0)
                playerName.Position = UDim2.new(0, 30, 0, 0)
                playerName.BackgroundTransparency = 1
                playerName.Text = player.Name
                playerName.TextColor3 = Color3.fromRGB(220, 220, 220)
                playerName.Font = Enum.Font.Gotham
                playerName.TextSize = 12
                playerName.TextXAlignment = Enum.TextXAlignment.Left
                playerName.Parent = playerFrame

                -- Check if player is selected
                if selectedPlayers[player.UserId] then
                    checkbox.ImageRectOffset = Vector2.new(312, 4)
                else
                    checkbox.ImageRectOffset = Vector2.new(312, 36)
                end

                -- Toggle selection on click
                checkbox.MouseButton1Click:Connect(function()
                    selectedPlayers[player.UserId] = not selectedPlayers[player.UserId]
                    if selectedPlayers[player.UserId] then
                        checkbox.ImageRectOffset = Vector2.new(312, 4)
                    else
                        checkbox.ImageRectOffset = Vector2.new(312, 36)
                    end
                end)

                playerFrame.Parent = playerSelection
            end
        end
    end

    local function callChatGPT(prompt, message)
        local currentTime = os.time()
        if currentTime - lastRequestTime < 3 then
            return nil, "Please wait before sending another request."
        end
        lastRequestTime = currentTime

        local systemMessage = prompt ~= "" and prompt or "You are a helpful assistant."
        
        local requestData = {
            model = "gpt-3.5-turbo",
            messages = {
                {
                    role = "system",
                    content = systemMessage
                },
                {
                    role = "user",
                    content = message
                }
            },
            temperature = 0.7
        }

        local success, response = pcall(function()
            return HttpService:PostAsync(API_URL, HttpService:JSONEncode(requestData), Enum.HttpContentType.ApplicationJson, false, {
                Authorization = "Bearer " .. API_KEY
            })
        end)

        if not success then
            return nil, "API request failed: " .. tostring(response)
        end

        local decoded = HttpService:JSONDecode(response)
        if decoded and decoded.choices and #decoded.choices > 0 then
            return decoded.choices[1].message.content, nil
        else
            return nil, "Invalid response from API"
        end
    end

    local function sendToSelectedPlayers(message)
        for userId, _ in pairs(selectedPlayers) do
            local targetPlayer = Players:GetPlayerByUserId(userId)
            if targetPlayer then
                ChatRemoteEvent:FireClient(targetPlayer, message)
            end
        end
    end

    -- Event Handlers
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            dragStartPos = Vector2.new(input.Position.X, input.Position.Y)
            frameStartPos = Vector2.new(mainFrame.Position.X.Offset, mainFrame.Position.Y.Offset)
        end
    end)

    titleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = Vector2.new(input.Position.X, input.Position.Y) - dragStartPos
            mainFrame.Position = UDim2.new(0, frameStartPos.X + delta.X, 0, frameStartPos.Y + delta.Y)
        end
    end)

    closeButton.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
        minimizedButton.Visible = true
    end)

    minimizedButton.MouseButton1Click:Connect(function()
        mainFrame.Visible = true
        minimizedButton.Visible = false
    end)

    roleDropdown.MouseButton1Click:Connect(function()
        roleOptions.Visible = not roleOptions.Visible
    end)

    sendButton.MouseButton1Click:Connect(function()
        local message = inputBox.Text
        if message == "" then return end
        
        -- Block button to prevent spam
        sendButton.Text = "Sending..."
        sendButton.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
        sendButton.TextColor3 = Color3.fromRGB(150, 150, 150)
        sendButton.AutoButtonColor = false
        
        -- Check if any players are selected
        local hasSelected = false
        for _ in pairs(selectedPlayers) do
            hasSelected = true
            break
        end
        
        if not hasSelected then
            statusLabel.Text = "Error: No players selected"
            statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            
            -- Reset button after delay
            task.delay(2, function()
                sendButton.Text = "Send"
                sendButton.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
                sendButton.TextColor3 = Color3.fromRGB(220, 220, 220)
                sendButton.AutoButtonColor = true
                statusLabel.Text = "Ready"
                statusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
            end)
            return
        end
        
        statusLabel.Text = "Processing request..."
        statusLabel.TextColor3 = Color3.fromRGB(200, 200, 100)
        
        local prompt = promptBox.Text
        
        -- Call ChatGPT in a separate thread to avoid freezing the game
        task.spawn(function()
            local response, err = callChatGPT(prompt, message)
            
            if response then
                -- Send to selected players
                sendToSelectedPlayers(response)
                
                statusLabel.Text = "Response sent!"
                statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            else
                statusLabel.Text = "Error: " .. (err or "Unknown error")
                statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
                print("AI API Error:", err)
            end
            
            -- Reset UI
            inputBox.Text = ""
            
            task.delay(2, function()
                sendButton.Text = "Send"
                sendButton.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
                sendButton.TextColor3 = Color3.fromRGB(220, 220, 220)
                sendButton.AutoButtonColor = true
                statusLabel.Text = "Ready"
                statusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
            end)
        end)
    end)

    -- Initialize
    updatePlayerList()
    Players.PlayerAdded:Connect(updatePlayerList)
    Players.PlayerRemoving:Connect(updatePlayerList)
end

-- Create GUI for each player
Players.PlayerAdded:Connect(createMainGUI)
for _, player in ipairs(Players:GetPlayers()) do
    createMainGUI(player)
end

-- Server-side handler for chat messages
ChatRemoteEvent.OnServerEvent:Connect(function(player, message)
    -- This would send to all players, but we filter on client side
    -- In a real game you might want to add more security checks here
    for _, recipient in ipairs(Players:GetPlayers()) do
        recipient:Chat(message)
    end
end)

-- API handler
AIServiceRemote.OnServerInvoke = function(player, prompt, message)
    local API_KEY = "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"
    local API_URL = "https://api.openai.com/v1/chat/completions"
    
    local requestData = {
        model = "gpt-3.5-turbo",
        messages = {
            {
                role = "system",
                content = prompt ~= "" and prompt or "You are a helpful assistant."
            },
            {
                role = "user",
                content = message
            }
        },
        temperature = 0.7
    }
    
    local success, response = pcall(function()
        return game:GetService("HttpService"):PostAsync(API_URL, game:GetService("HttpService"):JSONEncode(requestData), Enum.HttpContentType.ApplicationJson, false, {
            Authorization = "Bearer " .. API_KEY
        }
    end)
    
    if not success then
        warn("API request failed:", response)
        return nil, "API request failed: " .. tostring(response)
    end
    
    local decoded = game:GetService("HttpService"):JSONDecode(response)
    if decoded and decoded.choices and #decoded.choices > 0 then
        return decoded.choices[1].message.content
    else
        return nil, "Invalid response from API"
    end
end# xzafjack
