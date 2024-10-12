local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local autoCastEnabled = false
local connection

local function clientSideDetection()
    local reel = playerGui:FindFirstChild("reel")
    if not reel then return end

    local bar = reel:FindFirstChild("bar")
    if not bar then return end

    local playerbar = bar:FindFirstChild("playerbar")
    local fish = bar:FindFirstChild("fish")
    
    if playerbar and fish then
        playerbar.Position = fish.Position
    end
end

local function startTracking()
    if connection then connection:Disconnect() end
    
    connection = RunService.RenderStepped:Connect(clientSideDetection)
end

local function stopTracking()
    if connection then
        connection:Disconnect()
        connection = nil
    end
end

local function remote()
    local args = {
        [1] = 100
    }

    local remote = player.Character and player.Character:FindFirstChildOfClass("Tool") and player.Character:FindFirstChildOfClass("Tool").events.cast
    if remote then
        --game:GetService("Workspace").world.npcs["Marc Merchant"].merchant.sellall:InvokeServer()
        remote:FireServer(unpack(args))
    else
        print("this bullshit game doesnt have the remote... FUCK!")
    end
end

local function autocast()
    autoCastEnabled = not autoCastEnabled
    
    if autoCastEnabled then
        StarterGui:SetCore("SendNotification", {
            Title = "Auto Cast",
            Text = "Enabled",
            Duration = 2
        })
        remote()
    else
        StarterGui:SetCore("SendNotification", {
            Title = "Auto Cast",
            Text = "Disabled",
            Duration = 2
        })
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.P then
        autocast()
    end
end)

playerGui.DescendantAdded:Connect(function(descendant)
    if descendant.Name == "playerbar" and descendant.Parent and descendant.Parent.Name == "bar" then
        startTracking()
    end
end)

playerGui.DescendantRemoving:Connect(function(descendant)
    if descendant.Name == "playerbar" and descendant.Parent and descendant.Parent.Name == "bar" then
        stopTracking()
        if autoCastEnabled then
            wait(1)
            remote()
        end
    end
end)

if playerGui:FindFirstChild("reel") and 
   playerGui.reel:FindFirstChild("bar") and 
   playerGui.reel.bar:FindFirstChild("playerbar") then
    startTracking()
end
