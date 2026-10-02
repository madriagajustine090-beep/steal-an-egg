--// STEAL AN EGG - MOBILE GUI
--// File: main.lua
--// For your own Roblox Studio game
--// Place this as a LocalScript in StarterPlayer > StarterPlayerScripts

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local PICKUP_DISTANCE = 12
local DELIVERY_DISTANCE = 15

local carryingEgg = false
local delivered = 0
local currentEgg = nil

--==================================================
-- CHARACTER
--==================================================

local function getRoot()
	local character = player.Character or player.CharacterAdded:Wait()
	return character:FindFirstChild("HumanoidRootPart")
end

--==================================================
-- OBJECTS
--==================================================

local eggsFolder = workspace:FindFirstChild("Eggs")

if not eggsFolder then
	eggsFolder = Instance.new("Folder")
	eggsFolder.Name = "Eggs"
	eggsFolder.Parent = workspace
end

local deliveryZone = workspace:FindFirstChild("DeliveryZone")

if not deliveryZone then
	deliveryZone = Instance.new("Part")
	deliveryZone.Name = "DeliveryZone"
	deliveryZone.Size = Vector3.new(16, 2, 16)
	deliveryZone.Position = Vector3.new(0, 1, 0)
	deliveryZone.Anchored = true
	deliveryZone.CanCollide = false
	deliveryZone.Transparency = 0.5
	deliveryZone.Parent = workspace
end

--==================================================
-- FIND NEAREST EGG
--==================================================

local function findNearestEgg()

	local root = getRoot()

	if not root then
		return nil
	end

	local nearestEgg = nil
	local nearestDistance = PICKUP_DISTANCE

	for _, egg in ipairs(eggsFolder:GetChildren()) do

		if egg:IsA("BasePart") and egg:GetAttribute("Taken") ~= true then

			local distance = (egg.Position - root.Position).Magnitude

			if distance <= nearestDistance then
				nearestEgg = egg
				nearestDistance = distance
			end
		end
	end

	return nearestEgg
end

--==================================================
-- GUI
--==================================================

local gui = Instance.new("ScreenGui")
gui.Name = "StealAnEggGUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, 240, 0, 220)
main.Position = UDim2.new(1, -255, 0.5, -110)
main.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
main.BorderSizePixel = 0
main.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 16)
corner.Parent = main

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255, 60, 170)
stroke.Thickness = 2
stroke.Parent = main

--==================================================
-- TITLE
--==================================================

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "STEAL AN EGG"
title.TextColor3 = Color3.fromRGB(255, 80, 180)
title.TextSize = 20
title.Font = Enum.Font.GothamBold
title.Parent = main

--==================================================
-- STATUS
--==================================================

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -20, 0, 30)
status.Position = UDim2.new(0, 10, 0, 40)
status.BackgroundTransparency = 1
status.Text = "Status: Ready"
status.TextColor3 = Color3.fromRGB(220, 220, 220)
status.TextSize = 13
status.Font = Enum.Font.Gotham
status.Parent = main

--==================================================
-- COUNTER
--==================================================

local counter = Instance.new("TextLabel")
counter.Size = UDim2.new(1, -20, 0, 25)
counter.Position = UDim2.new(0, 10, 0, 67)
counter.BackgroundTransparency = 1
counter.Text = "Delivered: 0"
counter.TextColor3 = Color3.fromRGB(255, 255, 255)
counter.TextSize = 14
counter.Font = Enum.Font.GothamBold
counter.Parent = main

--==================================================
-- BUTTON FUNCTION
--==================================================

local function createButton(text, y)

	local button = Instance.new("TextButton")

	button.Size = UDim2.new(1, -30, 0, 45)
	button.Position = UDim2.new(0, 15, 0, y)

	button.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
	button.Text = text
	button.TextColor3 = Color3.fromRGB(255, 255, 255)

	button.TextSize = 15
	button.Font = Enum.Font.GothamBold

	button.AutoButtonColor = true
	button.Parent = main

	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0, 10)
	buttonCorner.Parent = button

	local buttonStroke = Instance.new("UIStroke")
	buttonStroke.Color = Color3.fromRGB(255, 60, 170)
	buttonStroke.Thickness = 1.5
	buttonStroke.Parent = button

	return button
end

--==================================================
-- PICK UP
--==================================================

local pickupButton = createButton("PICK UP EGG", 95)

pickupButton.MouseButton1Click:Connect(function()

	if carryingEgg then
		status.Text = "Status: Already carrying!"
		return
	end

	local egg = findNearestEgg()

	if not egg then
		status.Text = "Status: No egg nearby!"
		return
	end

	currentEgg = egg
	carryingEgg = true

	egg:SetAttribute("Taken", true)
	egg.Transparency = 1
	egg.CanCollide = false

	status.Text = "Status: Egg picked up!"

end)

--==================================================
-- DELIVER
--==================================================

local deliverButton = createButton("DELIVER EGG", 145)

deliverButton.MouseButton1Click:Connect(function()

	if not carryingEgg then
		status.Text = "Status: You have no egg!"
		return
	end

	local root = getRoot()

	if not root then
		return
	end

	local distance = (root.Position - deliveryZone.Position).Magnitude

	if distance > DELIVERY_DISTANCE then
		status.Text = "Status: Go to DeliveryZone!"
		return
	end

	carryingEgg = false
	delivered += 1

	counter.Text = "Delivered: " .. delivered
	status.Text = "Status: Egg delivered!"

	if currentEgg and currentEgg.Parent then

		currentEgg:SetAttribute("Taken", false)
		currentEgg.Transparency = 0
		currentEgg.CanCollide = true

	end

	currentEgg = nil

end)

--==================================================
-- HIDE
--==================================================

local hideButton = Instance.new("TextButton")

hideButton.Size = UDim2.new(0, 70, 0, 35)
hideButton.Position = UDim2.new(1, -80, 0, 10)

hideButton.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
hideButton.Text = "HIDE"
hideButton.TextColor3 = Color3.fromRGB(255, 255, 255)
hideButton.TextSize = 13
hideButton.Font = Enum.Font.GothamBold

hideButton.Parent = gui

local hideCorner = Instance.new("UICorner")
hideCorner.CornerRadius = UDim.new(0, 10)
hideCorner.Parent = hideButton

--==================================================
-- SHOW
--==================================================

local showButton = Instance.new("TextButton")

showButton.Size = UDim2.new(0, 80, 0, 40)
showButton.Position = UDim2.new(1, -90, 0, 10)

showButton.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
showButton.Text = "SHOW"
showButton.TextColor3 = Color3.fromRGB(255, 255, 255)
showButton.TextSize = 13
showButton.Font = Enum.Font.GothamBold

showButton.Visible = false
showButton.Parent = gui

local showCorner = Instance.new("UICorner")
showCorner.CornerRadius = UDim.new(0, 10)
showCorner.Parent = showButton

hideButton.MouseButton1Click:Connect(function()

	main.Visible = false
	hideButton.Visible = false
	showButton.Visible = true

end)

showButton.MouseButton1Click:Connect(function()

	main.Visible = true
	hideButton.Visible = true
	showButton.Visible = false

end)

--==================================================
-- LIVE STATUS
--==================================================

RunService.RenderStepped:Connect(function()

	if carryingEgg then
		status.Text = "Status: Carrying egg"
		return
	end

	local egg = findNearestEgg()

	if egg then
		status.Text = "Status: Egg nearby!"
	else
		status.Text = "Status: Ready"
	end

end)
