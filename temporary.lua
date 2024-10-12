--[[
    Feel free to use the source code for your projects, a better version will be made in the coming weeks.
    The updated version will be 100% free aside from supporters (people that donate to me) getting some more fine tuned features.
    My Discord is the same as it always is, 70467f42f05745ef9e51b07aca97b189.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local autoCastEnabled = false
local connection

StarterGui:SetCore("SendNotification", {
    Title = "Important",
    Text = "The script will be turned into free hub in the coming weeks.",
    Duration = 20
})
StarterGui:SetCore("SendNotification", {
    Title = "Important",
    Text = "Press P to toggle Auto-Cast.",
    Duration = 20
})
StarterGui:SetCore("SendNotification", {
    Title = "Important",
    Text = "As always my discord is the same, 70467f42f05745ef9e51b07aca97b189.",
    Duration = 20
})

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
        -- REMOVE THE COMMENT FOR THIS TO ADD BACK AUTOSELLING.
        --game:GetService("Workspace").world.npcs["Marc Merchant"].merchant.sellall:InvokeServer()
        remote:FireServer(unpack(args))
        rod()
    else
        print("this bullshit game doesnt have the remote... FUCK!")
    end
end

local function rod()
    if game:GetService("Players").LocalPlayer.Character:WaitForChild(game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Tool"), 5) then
        local rod = game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Tool")
        rod.Parent = game:GetService("Players").LocalPlayer.Backpack
        repeat
            task.wait()
        until rod.Parent == game:GetService("Players").LocalPlayer.Backpack
        local rod = game:GetService("Players").LocalPlayer.Character.Humanoid:EquipTool(rod)
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
        game:GetService("Players").LocalPlayer.Character.Head.Anchored = true
        remote()
    else
        StarterGui:SetCore("SendNotification", {
            Title = "Auto Cast",
            Text = "Disabled",
            Duration = 2
        })
        game:GetService("Players").LocalPlayer.Character.Head.Anchored = false
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

game:GetService("Players").LocalPlayer.PlayerGui.ChildAdded:Connect(function(child)
    if child.Name == "shakeui" then
        child:WaitForChild("safezone").ChildAdded:Connect(function(c)
            c.Position = UDim2.new(0.5, 0, 0.5, 0)
        end)
    end
end)

while task.wait(540) do
    mouse1click(0, 0)
end
