-- SCRIPTED BY FORLEAKEN
-- MADE TO BE USED IN FORSAKEN!!!
-- PLEASE CREDIT ME IF YOU USE THIS

local player : Player = game.Players.LocalPlayer
local assets = game:GetObjects("rbxassetid://116416156015735")[1]
local scaryGUI : ScreenGui = assets.EvilScaryJumpscare
scaryGUI.DisplayOrder = 99999999
local fakeDamage = 0
local currentScary
local scaryDistance = 17.5
function jumpscare(scary : Part)
	local jumpscareGUI = scaryGUI:Clone()
	jumpscareGUI.Parent = player.PlayerGui
	pcall(function()
		jumpscareGUI.Parent = game.CoreGui
	end)
	task.delay(3, function()
		if jumpscareGUI.Parent then
			jumpscareGUI:Destroy()
		end
	end)
	scary.Scream:Play()
end
function moveScary(scary : Part, part : Part)
	if player.Character and player.Character.PrimaryPart and (player.Character.PrimaryPart.Position - scary.Position).Magnitude < scaryDistance then
		scary.CFrame = CFrame.new(player.Character.PrimaryPart.Position)
	else
		scary.CFrame = CFrame.new(scary.Position + (scaryDistance*(part.Position-scary.Position).Unit), part.Position)
	end
	scary:FindFirstChild("Move"):Play()
	if scary:GetAttribute("db") == false and player.Character and player.Character.PrimaryPart and player.Character:FindFirstChildOfClass("Humanoid") and (player.Character.PrimaryPart.Position-scary.Position).Magnitude < 10 then
		scary:SetAttribute("db", true)
		task.delay(5, function()
			scary:SetAttribute("db", false)
		end)
		local hum = player.Character:FindFirstChildOfClass("Humanoid")
		fakeDamage += 100
		hum:SetAttribute("FakeDamage", 100+(hum:GetAttribute("FakeDamage") or 0))
		if hum.Health-fakeDamage <= 0 then
			hum.Health = 0
		end
		jumpscare(scary)
	end
end
player.CharacterAdded:Connect(function(char)
	if currentScary then
		currentScary:Destroy()
		currentScary = nil
	end
	fakeDamage = 0
	task.wait(5)
	if char.Parent.Name == "Spectating" or not workspace.Map.Ingame:FindFirstChild("Map") then
		warn("NOSCARY", char.Parent.Name, workspace.Map.Ingame:FindFirstChild("Map"))
		return
	end
	local hum = player.Character:FindFirstChildOfClass("Humanoid")
	hum.AttributeChanged:Connect(function(attribute)
		if attribute == "FakeDamage" and hum:GetAttribute("FakeDamage") == nil then
			hum:SetAttribute("FakeDamage", fakeDamage)
		end
	end)
	hum.HealthChanged:Connect(function(health)
		if health-fakeDamage <= 0 then
			hum.Health = 0
		end
	end)
	local msg = Instance.new("Message", workspace)
	msg.Text = "EVIL SCARY IS HERE"
	game:GetService("Debris"):AddItem(msg, 3)
	local spawns : Folder = char.Parent.Name == "Survivors" and workspace.Map.Ingame.Map.SpawnPoints.Killers or workspace.Map.Ingame.Map.SpawnPoints.Survivors
	local selectedspawn : Part = spawns:GetChildren()[math.random(1, #spawns:GetChildren())]
	currentScary = assets.EvilScary:Clone()
	local ourScary = currentScary
	ourScary.Parent = workspace
	ourScary.CFrame = selectedspawn.CFrame
	
	task.spawn(function()
		while task.wait() and char.Parent do
			ourScary.Hand.Mesh.Offset = Vector3.new(0, 0, 1)
			ourScary.Hand2.Mesh.Offset = Vector3.new(0, 0, 1)
			task.wait(0.1)
			ourScary.Hand.Mesh.Offset = Vector3.new(0, 0, 0)
			ourScary.Hand2.Mesh.Offset = Vector3.new(0, 0, 0)
			task.wait(0.1)
		end
	end)
	while task.wait() and char.Parent do
		for i = 1, 10 do
			moveScary(ourScary, char.PrimaryPart)
			task.wait(2)
		end
		ourScary.Lunge:Play()
		task.wait(2)
		for i = 1, 5 do
			moveScary(ourScary, char.PrimaryPart)
			task.wait(0.5)
		end
	end
end)
