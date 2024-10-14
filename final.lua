--[[
    CBA to actually finish this, doesn't matter though.
    Hold your rod out when you are using auto-cast.
    Auto-sell doesn't work in the slightest.
    Auto-reel has a 50/50 chance to give you 500 - 1200 money per reel.
    Don't have chat or the backpack UI enabled for the Auto-shake.

    Made by SOLIAN. (70467f42f05745ef9e51b07aca97b189) on discord.
]]





-- Services
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local VIM = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = game:GetService("Players").LocalPlayer
local playerGui = player.PlayerGui


-- Variables

local debugEnabled = true

-- Objects

-- Helper functions.

local http_request = function(url : string, content : table)
    local response = http_request(
        {
            Url = url,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = HttpService:JSONEncode({content})
        }
    )
    repeat
        task.wait()
    until response; return response
end

local nullify_velocity = function(time_out : number)
    local start = os.clock()
    time_out = time_out or 5
    repeat
        for _, child in ipairs(player.Character:GetChildren()) do
            if child:IsA("BasePart") then
                child.Massless = true
                child.Velocity = Vector3.new(0, 0, 0)
                child.RotVelocity = Vector3.new(0, 0, 0)
                child.Anchored = true
            end
        end

        task.wait()
    until os.clock() - start > time_out
    for _, child in ipairs(player.Character:GetChildren()) do
        if child:IsA("BasePart") then
            child.Massless = false
            child.Velocity = Vector3.new(0, 0, 0)
            child.RotVelocity = Vector3.new(0, 0, 0)
            child.Anchored = false
        end
    end
end

-- Hub functions.

local auto_reel = function(toggle : boolean)
    local connection
    if not toggle or connection then
        connection:Disconnect(); connection = nil
    elseif toggle then
        local success, error = pcall(function()
            connection = RunService.RenderStepped:Connect(function()
                local reel = playerGui:FindFirstChild("reel")
                if not reel then return end

                local bar = reel:FindFirstChild("bar")
                if not bar then return end

                local playerbar = bar:FindFirstChild("playerbar")
                
                if playerbar then
                    ReplicatedStorage.events:FindFirstChild("reelfinished"):FireServer(100, true)
                end
            end)
        end)
        if success and debugEnabled then
            print("Auto-reel has been successfully toggled: " .. tostring(toggle))
        else
            warn(error)
        end
    end
end

local auto_cast = function(toggle : boolean)
    local connection
    if not toggle or connection then
        connection:Disconnect(); connection = nil
    elseif toggle then
        local success, error = pcall(function()
            connection = playerGui.ChildRemoved:Connect(function(child)
                if child.Name == "reel" then
                    player.Character:FindFirstChildOfClass("Tool").events.reset:FireServer()
                    player.Character:FindFirstChildOfClass("Tool").events.cast:FireServer(100)
                    nullify_velocity(3)
                end
            end)
            player.Character:FindFirstChildOfClass("Tool").events.cast:FireServer(100)
            nullify_velocity(3)
        end)
        if success and debugEnabled then
            print("Auto-casting has been successfully toggled: " .. tostring(toggle))
        else
            warn(error)
        end
    end
end

local auto_sell = function(toggle : boolean)
    local connection
    if not toggle or connection then
        connection:Disconnect(); connection = nil
    elseif toggle then
        local success, error = pcall(function()
            connection = player.Backpack.ChildAdded:Connect(function(child)
                if child:FindFirstChild("Center") then
                    player.Character.Humanoid:EquipTool(child)
                    workspace.world.npcs["Marc Merchant"].merchant.sell:InvokeServer()
                    print"sold?"
                end
            end)
        end)
        if success and debugEnabled then
            print("Auto-selling has been successfully toggled: " .. tostring(toggle))
        else
            warn(error)
        end
    end
end

local auto_shake = function(toggle : boolean)
    local connection
    local lastButtonInstance = nil

    if not toggle or connection then
        if connection then
            connection:Disconnect()
            connection = nil
        end
        lastButtonInstance = nil
    elseif toggle then
        local success, error = pcall(function()
            local connection = RunService.RenderStepped:Connect(function()
                if playerGui:FindFirstChild("shakeui") and playerGui.shakeui.safezone.button then
                    local currentButton = playerGui.shakeui.safezone.button
                    if currentButton ~= lastButtonInstance then
                        lastButtonInstance = currentButton
                        local pos = currentButton.AbsolutePosition
                        local size = currentButton.AbsoluteSize
                        VIM:SendMouseButtonEvent(pos.X + (size.X / 2), pos.Y + (size.Y / 2), Enum.UserInputType.MouseButton1.Value, true, playerGui, 1)
                        VIM:SendMouseButtonEvent(pos.X + (size.X / 2), pos.Y + (size.Y / 2), Enum.UserInputType.MouseButton1.Value, false, playerGui, 1)
                    end
                else
                    lastButtonInstance = nil
                end
            end)
        end)
        if success and debugEnabled then
            print("Auto-shaking has been successfully toggled: " .. tostring(toggle))
        else
            warn(error)
        end
    end
end

auto_reel(true)
auto_sell(true)
auto_cast(true)
auto_shake(true)
