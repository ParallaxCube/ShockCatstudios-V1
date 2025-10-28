local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
   Name = "Forsaken Meta Hub",
   Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
   LoadingTitle = "Meta Hub",
   LoadingSubtitle = "by Metta",
   ShowText = "Rayfield", -- for mobile users to unhide rayfield, change if you'd like
   Theme = "Default", -- Check https://docs.sirius.menu/rayfield/configuration/themes

   ToggleUIKeybind = "K", -- The keybind to toggle the UI visibility (string like "K" or Enum.KeyCode)

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false, -- Prevents Rayfield from warning when the script has a version mismatch with the interface

   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil, -- Create a custom folder for your hub/game
      FileName = "Big Hub"
   },

   Discord = {
      Enabled = false, -- Prompt the user to join your Discord server if their executor supports it
      Invite = "noinvitelink", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ ABCD would be ABCD
      RememberJoins = true -- Set this to false to make them join the discord every time they load it up
   },

   KeySystem = false, -- Set this to true to use our key system
   KeySettings = {
      Title = "Untitled",
      Subtitle = "Key System",
      Note = "No method of obtaining the key is provided", -- Use this to tell the user how to get a key
      FileName = "Key", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
      SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
      GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = {"Hello"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
   }
})
local MainTab = Window:CreateTab("Main", 4483362458) -- Title, Image
local PlayerTab = Window:CreateTab("Player", 4483362458) -- Title, Image
local EspTab = Window:CreateTab("Esp", 4483362458) -- Title, Image
local GeneratorTab = Window:CreateTab("Generators", 4483362458)
local AimbotTab = Window:CreateTab("Aimbot", 4483362458) -- Title, Image
local Toggle = PlayerTab:CreateToggle({
   Name = "Infinite Stamina",
   CurrentValue = false,
   Flag = "Toggle1",
   Callback = function(Value)
       if Value then
           local sprintingModule = require(game:GetService("ReplicatedStorage").Systems.Character.Game.Sprinting)
           
           local originalStaminaChange = sprintingModule.ChangeStat
           sprintingModule.ChangeStat = function(self, stat, value)
               if stat == "Stamina" then
                   return
               end
               return originalStaminaChange(self, stat, value)
           end
           
           local originalInit = sprintingModule.Init
           sprintingModule.Init = function(self)
               originalInit(self)
               
               self.StaminaLossDisabled = true
               self.Stamina = self.MaxStamina
               
               local staminaLoop
               staminaLoop = game:GetService("RunService").Heartbeat:Connect(function()
                   if self.Stamina < self.MaxStamina then
                       self.Stamina = self.MaxStamina
                       if self.__staminaChangedEvent then
                           self.__staminaChangedEvent:Fire(self.MaxStamina)
                       end
                   end
               end)
               
               self._infiniteStaminaLoop = staminaLoop
           end
           
           if sprintingModule.DefaultsSet then
               sprintingModule.StaminaLossDisabled = true
               sprintingModule.Stamina = sprintingModule.MaxStamina
               
               if not sprintingModule._infiniteStaminaLoop then
                   local staminaLoop = game:GetService("RunService").Heartbeat:Connect(function()
                       if sprintingModule.Stamina < sprintingModule.MaxStamina then
                           sprintingModule.Stamina = sprintingModule.MaxStamina
                           if sprintingModule.__staminaChangedEvent then
                               sprintingModule.__staminaChangedEvent:Fire(sprintingModule.MaxStamina)
                           end
                       end
                   end)
                   sprintingModule._infiniteStaminaLoop = staminaLoop
               end
           end
           
           _G.InfiniteStaminaData = {
               OriginalChangeStat = originalStaminaChange,
               OriginalInit = originalInit,
               Module = sprintingModule
           }
           
       else
           if _G.InfiniteStaminaData then
               local sprintingModule = _G.InfiniteStaminaData.Module
               
               sprintingModule.ChangeStat = _G.InfiniteStaminaData.OriginalChangeStat
               sprintingModule.Init = _G.InfiniteStaminaData.OriginalInit
               sprintingModule.StaminaLossDisabled = false
               
               if sprintingModule._infiniteStaminaLoop then
                   sprintingModule._infiniteStaminaLoop:Disconnect()
                   sprintingModule._infiniteStaminaLoop = nil
               end
               
               _G.InfiniteStaminaData = nil
           end
       end
   end,
})
local Input = PlayerTab:CreateInput({
   Name = "Speed",
   CurrentValue = "",
   PlaceholderText = "Enter sprint speed",
   RemoveTextAfterFocusLost = false,
   Flag = "Input1",
   Callback = function(Text)
       local newSpeed = tonumber(Text)
       if newSpeed then
           local sprintingModule = require(game:GetService("ReplicatedStorage").Systems.Character.Game.Sprinting)
           
           if sprintingModule then
               sprintingModule.SprintSpeed = newSpeed
               
               if sprintingModule.IsSprinting and sprintingModule.__speedMultiplier then
                   local humanoid = game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
                   if humanoid then
                       local baseSpeed = humanoid:GetAttribute("BaseSpeed") or 16
                       sprintingModule.__speedMultiplier.Value = newSpeed / baseSpeed
                   end
               end
           end
       end
   end,
})
local Input = PlayerTab:CreateInput({
   Name = "Stamina gain/sec",
   CurrentValue = "",
   PlaceholderText = "Enter stamina gain per second",
   RemoveTextAfterFocusLost = false,
   Flag = "Input1",
   Callback = function(Text)
       local newGain = tonumber(Text)
       if newGain then
           local sprintingModule = require(game:GetService("ReplicatedStorage").Systems.Character.Game.Sprinting)
           
           if sprintingModule then
               sprintingModule.StaminaGain = newGain
           end
       end
   end,
})
local Toggle = EspTab:CreateToggle({
   Name = "Killer esp",
   CurrentValue = false,
   Flag = "Toggle1",
   Callback = function(Value)
       if Value then
           if not _G.KillerESPData then
               _G.KillerESPData = {
                   Highlights = {},
                   Connections = {}
               }
           end

           local function isKiller(model)
               return model:IsA("Model") and model.Parent and model.Parent.Name == "Killers" and model.Parent.Parent and model.Parent.Parent.Name == "Players" and model.Parent.Parent.Parent == game.Workspace
           end

           local function updateKillerESP()
               for killer, highlight in pairs(_G.KillerESPData.Highlights) do
                   if killer and killer.Parent then
                       highlight.Adornee = killer
                       highlight.Enabled = true
                   else
                       highlight.Enabled = false
                   end
               end
           end

           local function createKillerESP(killer)
               if not isKiller(killer) then return end
               
               local highlight = Instance.new("Highlight")
               highlight.Name = killer.Name .. "_KillerESP"
               highlight.FillColor = Color3.fromRGB(255, 0, 0)
               highlight.FillTransparency = 0.5
               highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
               highlight.OutlineTransparency = 0.2
               highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
               highlight.Parent = game.CoreGui
               
               _G.KillerESPData.Highlights[killer] = highlight
           end

           local function scanForKillers()
               local playersFolder = game.Workspace:FindFirstChild("Players")
               if playersFolder then
                   local killersFolder = playersFolder:FindFirstChild("Killers")
                   if killersFolder then
                       for _, killer in pairs(killersFolder:GetChildren()) do
                           if killer:IsA("Model") then
                               createKillerESP(killer)
                           end
                       end
                   end
               end
           end

           scanForKillers()

           local function handleDescendantAdded(descendant)
               if descendant:IsA("Model") then
                   local parent = descendant.Parent
                   if parent and parent.Name == "Killers" then
                       local grandParent = parent.Parent
                       if grandParent and grandParent.Name == "Players" and grandParent.Parent == game.Workspace then
                           createKillerESP(descendant)
                       end
                   end
               end
           end

           local function handleDescendantRemoving(descendant)
               if _G.KillerESPData.Highlights[descendant] then
                   _G.KillerESPData.Highlights[descendant]:Destroy()
                   _G.KillerESPData.Highlights[descendant] = nil
               end
           end

           local descendantAddedConn = game.Workspace.DescendantAdded:Connect(handleDescendantAdded)
           local descendantRemovingConn = game.Workspace.DescendantRemoving:Connect(handleDescendantRemoving)

           _G.KillerESPData.MainConnections = {
               descendantAdded = descendantAddedConn,
               descendantRemoving = descendantRemovingConn
           }

           _G.KillerESPData.UpdateLoop = game:GetService("RunService").Heartbeat:Connect(function()
               updateKillerESP()
           end)

       else
           if _G.KillerESPData then
               if _G.KillerESPData.UpdateLoop then
                   _G.KillerESPData.UpdateLoop:Disconnect()
               end

               if _G.KillerESPData.MainConnections then
                   _G.KillerESPData.MainConnections.descendantAdded:Disconnect()
                   _G.KillerESPData.MainConnections.descendantRemoving:Disconnect()
               end

               for killer, highlight in pairs(_G.KillerESPData.Highlights) do
                   highlight:Destroy()
               end

               _G.KillerESPData = nil
           end
       end
   end,
})
local Toggle = EspTab:CreateToggle({
   Name = "Players' esp",
   CurrentValue = false,
   Flag = "Toggle1",
   Callback = function(Value)
       if Value then
           if not _G.SurvivorESPData then
               _G.SurvivorESPData = {
                   Highlights = {},
                   Connections = {}
               }
           end

           local function isSurvivor(model)
               return model:IsA("Model") and model.Parent and model.Parent.Name == "Survivors" and model.Parent.Parent and model.Parent.Parent.Name == "Players" and model.Parent.Parent.Parent == game.Workspace and model ~= game.Players.LocalPlayer.Character
           end

           local function updateSurvivorESP()
               for survivor, highlight in pairs(_G.SurvivorESPData.Highlights) do
                   if survivor and survivor.Parent then
                       highlight.Adornee = survivor
                       highlight.Enabled = true
                   else
                       highlight.Enabled = false
                   end
               end
           end

           local function createSurvivorESP(survivor)
               if not isSurvivor(survivor) then return end
               
               local highlight = Instance.new("Highlight")
               highlight.Name = survivor.Name .. "_SurvivorESP"
               highlight.FillColor = Color3.fromRGB(0, 255, 0)
               highlight.FillTransparency = 0.6
               highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
               highlight.OutlineTransparency = 0.2
               highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
               highlight.Parent = game.CoreGui
               
               _G.SurvivorESPData.Highlights[survivor] = highlight
           end

           local function scanForSurvivors()
               local playersFolder = game.Workspace:FindFirstChild("Players")
               if playersFolder then
                   local survivorsFolder = playersFolder:FindFirstChild("Survivors")
                   if survivorsFolder then
                       for _, survivor in pairs(survivorsFolder:GetChildren()) do
                           if survivor:IsA("Model") then
                               createSurvivorESP(survivor)
                           end
                       end
                   end
               end
           end

           scanForSurvivors()

           local function handleDescendantAdded(descendant)
               if descendant:IsA("Model") then
                   local parent = descendant.Parent
                   if parent and parent.Name == "Survivors" then
                       local grandParent = parent.Parent
                       if grandParent and grandParent.Name == "Players" and grandParent.Parent == game.Workspace then
                           createSurvivorESP(descendant)
                       end
                   end
               end
           end

           local function handleDescendantRemoving(descendant)
               if _G.SurvivorESPData.Highlights[descendant] then
                   _G.SurvivorESPData.Highlights[descendant]:Destroy()
                   _G.SurvivorESPData.Highlights[descendant] = nil
               end
           end

           local descendantAddedConn = game.Workspace.DescendantAdded:Connect(handleDescendantAdded)
           local descendantRemovingConn = game.Workspace.DescendantRemoving:Connect(handleDescendantRemoving)

           _G.SurvivorESPData.MainConnections = {
               descendantAdded = descendantAddedConn,
               descendantRemoving = descendantRemovingConn
           }

           _G.SurvivorESPData.UpdateLoop = game:GetService("RunService").Heartbeat:Connect(function()
               updateSurvivorESP()
           end)

       else
           if _G.SurvivorESPData then
               if _G.SurvivorESPData.UpdateLoop then
                   _G.SurvivorESPData.UpdateLoop:Disconnect()
               end

               if _G.SurvivorESPData.MainConnections then
                   _G.SurvivorESPData.MainConnections.descendantAdded:Disconnect()
                   _G.SurvivorESPData.MainConnections.descendantRemoving:Disconnect()
               end

               for survivor, highlight in pairs(_G.SurvivorESPData.Highlights) do
                   highlight:Destroy()
               end

               _G.SurvivorESPData = nil
           end
       end
   end,
})
local Toggle = EspTab:CreateToggle({
   Name = "Item esp",
   CurrentValue = false,
   Flag = "Toggle1",
   Callback = function(Value)
       if Value then
           if not _G.ItemESPData then
               _G.ItemESPData = {
                   Highlights = {},
                   Billboards = {},
                   Connections = {}
               }
           end

           local function isTargetItem(model)
               return model:IsA("Model") and (model.Name == "BloxyCola" or model.Name == "Medkit") and 
                      model.Parent and model.Parent.Name == "Map" and 
                      model.Parent.Parent and model.Parent.Parent.Name == "Ingame" and 
                      model.Parent.Parent.Parent and model.Parent.Parent.Parent.Name == "Map" and 
                      model.Parent.Parent.Parent.Parent == game.Workspace
           end

           local function updateItemESP()
               for item, data in pairs(_G.ItemESPData.Highlights) do
                   if item and item.Parent then
                       data.highlight.Adornee = item
                       data.highlight.Enabled = true
                       if data.billboard then
                           data.billboard.Adornee = item
                           data.billboard.Enabled = true
                       end
                   else
                       data.highlight.Enabled = false
                       if data.billboard then
                           data.billboard.Enabled = false
                       end
                   end
               end
           end

           local function createItemESP(item)
               if not isTargetItem(item) then return end
               
               local highlight = Instance.new("Highlight")
               highlight.Name = item.Name .. "_ItemESP"
               highlight.FillColor = Color3.fromRGB(128, 0, 128)
               highlight.FillTransparency = 0.5
               highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
               highlight.OutlineTransparency = 0.1
               highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
               highlight.Parent = game.CoreGui
               
               local billboard = Instance.new("BillboardGui")
               billboard.Name = item.Name .. "_Label"
               billboard.Size = UDim2.new(0, 80, 0, 20)
               billboard.StudsOffset = Vector3.new(0, 2, 0)
               billboard.AlwaysOnTop = true
               billboard.Adornee = item
               billboard.Parent = game.CoreGui
               
               local textLabel = Instance.new("TextLabel")
               textLabel.Size = UDim2.new(1, 0, 1, 0)
               textLabel.BackgroundTransparency = 1
               textLabel.Text = item.Name
               textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
               textLabel.TextSize = 12
               textLabel.Font = Enum.Font.SourceSansBold
               textLabel.TextStrokeTransparency = 0
               textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
               textLabel.Parent = billboard
               
               _G.ItemESPData.Highlights[item] = {
                   highlight = highlight,
                   billboard = billboard
               }
           end

           local function scanForItems()
               local mapFolder = game.Workspace:FindFirstChild("Map")
               if mapFolder then
                   local ingameFolder = mapFolder:FindFirstChild("Ingame")
                   if ingameFolder then
                       local mapSubFolder = ingameFolder:FindFirstChild("Map")
                       if mapSubFolder then
                           for _, item in pairs(mapSubFolder:GetDescendants()) do
                               if item:IsA("Model") and (item.Name == "BloxyCola" or item.Name == "Medkit") then
                                   createItemESP(item)
                               end
                           end
                       end
                   end
               end
           end

           scanForItems()

           local function handleDescendantAdded(descendant)
               if descendant:IsA("Model") and (descendant.Name == "BloxyCola" or descendant.Name == "Medkit") then
                   local parent = descendant.Parent
                   if parent and parent.Name == "Map" then
                       local grandParent = parent.Parent
                       if grandParent and grandParent.Name == "Ingame" then
                           local greatGrandParent = grandParent.Parent
                           if greatGrandParent and greatGrandParent.Name == "Map" and greatGrandParent.Parent == game.Workspace then
                               createItemESP(descendant)
                           end
                       end
                   end
               end
           end

           local function handleDescendantRemoving(descendant)
               if _G.ItemESPData.Highlights[descendant] then
                   local data = _G.ItemESPData.Highlights[descendant]
                   data.highlight:Destroy()
                   if data.billboard then
                       data.billboard:Destroy()
                   end
                   _G.ItemESPData.Highlights[descendant] = nil
               end
           end

           local descendantAddedConn = game.Workspace.DescendantAdded:Connect(handleDescendantAdded)
           local descendantRemovingConn = game.Workspace.DescendantRemoving:Connect(handleDescendantRemoving)

           _G.ItemESPData.MainConnections = {
               descendantAdded = descendantAddedConn,
               descendantRemoving = descendantRemovingConn
           }

           _G.ItemESPData.UpdateLoop = game:GetService("RunService").Heartbeat:Connect(function()
               updateItemESP()
           end)

       else
           if _G.ItemESPData then
               if _G.ItemESPData.UpdateLoop then
                   _G.ItemESPData.UpdateLoop:Disconnect()
               end

               if _G.ItemESPData.MainConnections then
                   _G.ItemESPData.MainConnections.descendantAdded:Disconnect()
                   _G.ItemESPData.MainConnections.descendantRemoving:Disconnect()
               end

               for item, data in pairs(_G.ItemESPData.Highlights) do
                   data.highlight:Destroy()
                   if data.billboard then
                       data.billboard:Destroy()
                   end
               end

               _G.ItemESPData = nil
           end
       end
   end,
})
local Toggle = EspTab:CreateToggle({
   Name = "Generators' esp",
   CurrentValue = false,
   Flag = "Toggle1",
   Callback = function(Value)
       if Value then
           if not _G.GeneratorESPData then
               _G.GeneratorESPData = {
                   Highlights = {},
                   Billboards = {},
                   Connections = {}
               }
           end

           local function isGenerator(model)
               return model:IsA("Model") and model.Name == "Generator" and 
                      model.Parent and model.Parent.Name == "Map" and 
                      model.Parent.Parent and model.Parent.Parent.Name == "Ingame" and 
                      model.Parent.Parent.Parent and model.Parent.Parent.Parent.Name == "Map" and 
                      model.Parent.Parent.Parent.Parent == game.Workspace
           end

           -- Функция для получения прогресса генератора
           local function getGeneratorProgress(generator)
               local progressValue = generator:FindFirstChild("Progress")
               if progressValue and progressValue:IsA("NumberValue") then
                   return progressValue.Value
               end
               return 0
           end

           local function updateGeneratorESP()
               for generator, highlight in pairs(_G.GeneratorESPData.Highlights) do
                   if generator and generator.Parent then
                       local progress = getGeneratorProgress(generator)
                       
                       -- Если прогресс 100% - скрываем подсветку
                       if progress >= 100 then
                           highlight.Enabled = false
                           if _G.GeneratorESPData.Billboards[generator] then
                               _G.GeneratorESPData.Billboards[generator].Enabled = false
                           end
                       else
                           highlight.Enabled = true
                           
                           -- Обновляем цвет в зависимости от прогресса
                           if progress == 0 then
                               highlight.FillColor = Color3.fromRGB(255, 0, 0) -- Красный
                           elseif progress < 50 then
                               highlight.FillColor = Color3.fromRGB(255, 165, 0) -- Оранжевый
                           elseif progress < 100 then
                               highlight.FillColor = Color3.fromRGB(255, 255, 0) -- Желтый
                           end
                           
                           -- Обновляем текст прогресса
                           if _G.GeneratorESPData.Billboards[generator] then
                               _G.GeneratorESPData.Billboards[generator].TextLabel.Text = math.floor(progress) .. "%"
                               _G.GeneratorESPData.Billboards[generator].Enabled = true
                           end
                       end
                       
                       highlight.Adornee = generator
                   else
                       highlight.Enabled = false
                       if _G.GeneratorESPData.Billboards[generator] then
                           _G.GeneratorESPData.Billboards[generator].Enabled = false
                       end
                   end
               end
           end

           local function createGeneratorESP(generator)
               if not isGenerator(generator) then return end
               
               -- Создаем подсветку
               local highlight = Instance.new("Highlight")
               highlight.Name = generator.Name .. "_GeneratorESP"
               highlight.FillColor = Color3.fromRGB(255, 0, 0) -- Начальный цвет красный
               highlight.FillTransparency = 0.6
               highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
               highlight.OutlineTransparency = 0.2
               highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
               highlight.Parent = game.CoreGui
               
               -- Создаем BillboardGui для текста прогресса
               local billboard = Instance.new("BillboardGui")
               billboard.Name = generator.Name .. "_ProgressText"
               billboard.Adornee = generator:FindFirstChild("PrimaryPart") or generator:FindFirstChildWhichIsA("BasePart")
               billboard.Size = UDim2.new(0, 100, 0, 40)
               billboard.StudsOffset = Vector3.new(0, 3, 0)
               billboard.AlwaysOnTop = true
               billboard.MaxDistance = 100
               
               local textLabel = Instance.new("TextLabel")
               textLabel.Size = UDim2.new(1, 0, 1, 0)
               textLabel.BackgroundTransparency = 1
               textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
               textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
               textLabel.TextStrokeTransparency = 0
               textLabel.TextSize = 14
               textLabel.Font = Enum.Font.GothamBold
               textLabel.Text = "0%"
               textLabel.Parent = billboard
               
               billboard.Parent = game.CoreGui
               
               _G.GeneratorESPData.Highlights[generator] = highlight
               _G.GeneratorESPData.Billboards[generator] = billboard
           end

           local function scanForGenerators()
               local mapFolder = game.Workspace:FindFirstChild("Map")
               if mapFolder then
                   local ingameFolder = mapFolder:FindFirstChild("Ingame")
                   if ingameFolder then
                       local mapSubFolder = ingameFolder:FindFirstChild("Map")
                       if mapSubFolder then
                           for _, generator in pairs(mapSubFolder:GetDescendants()) do
                               if generator:IsA("Model") and generator.Name == "Generator" then
                                   createGeneratorESP(generator)
                               end
                           end
                       end
                   end
               end
           end

           local function handleDescendantAdded(descendant)
               if descendant:IsA("Model") and descendant.Name == "Generator" then
                   local parent = descendant.Parent
                   if parent and parent.Name == "Map" then
                       local grandParent = parent.Parent
                       if grandParent and grandParent.Name == "Ingame" then
                           local greatGrandParent = grandParent.Parent
                           if greatGrandParent and greatGrandParent.Name == "Map" and greatGrandParent.Parent == game.Workspace then
                               createGeneratorESP(descendant)
                           end
                       end
                   end
               end
           end

           local function handleDescendantRemoving(descendant)
               if _G.GeneratorESPData.Highlights[descendant] then
                   _G.GeneratorESPData.Highlights[descendant]:Destroy()
                   _G.GeneratorESPData.Highlights[descendant] = nil
               end
               if _G.GeneratorESPData.Billboards[descendant] then
                   _G.GeneratorESPData.Billboards[descendant]:Destroy()
                   _G.GeneratorESPData.Billboards[descendant] = nil
               end
           end

           -- Соединение для отслеживания изменения прогресса
           local function monitorProgressChanges()
               for generator, _ in pairs(_G.GeneratorESPData.Highlights) do
                   local progressValue = generator:FindFirstChild("Progress")
                   if progressValue and progressValue:IsA("NumberValue") then
                       if not _G.GeneratorESPData.Connections[generator] then
                           _G.GeneratorESPData.Connections[generator] = progressValue:GetPropertyChangedSignal("Value"):Connect(function()
                               updateGeneratorESP()
                           end)
                       end
                   end
               end
           end

           scanForGenerators()
           monitorProgressChanges()

           local descendantAddedConn = game.Workspace.DescendantAdded:Connect(function(descendant)
               handleDescendantAdded(descendant)
               task.wait(0.1) -- Ждем немного перед мониторингом прогресса
               monitorProgressChanges()
           end)

           local descendantRemovingConn = game.Workspace.DescendantRemoving:Connect(handleDescendantRemoving)

           _G.GeneratorESPData.MainConnections = {
               descendantAdded = descendantAddedConn,
               descendantRemoving = descendantRemovingConn
           }

           _G.GeneratorESPData.UpdateLoop = game:GetService("RunService").Heartbeat:Connect(function()
               updateGeneratorESP()
           end)

       else
           -- Отключаем ESP
           if _G.GeneratorESPData then
               if _G.GeneratorESPData.UpdateLoop then
                   _G.GeneratorESPData.UpdateLoop:Disconnect()
               end

               if _G.GeneratorESPData.MainConnections then
                   _G.GeneratorESPData.MainConnections.descendantAdded:Disconnect()
                   _G.GeneratorESPData.MainConnections.descendantRemoving:Disconnect()
               end

               -- Отключаем соединения прогресса
               for generator, connection in pairs(_G.GeneratorESPData.Connections) do
                   connection:Disconnect()
               end

               -- Удаляем подсветки и билборды
               for generator, highlight in pairs(_G.GeneratorESPData.Highlights) do
                   highlight:Destroy()
               end
               for generator, billboard in pairs(_G.GeneratorESPData.Billboards) do
                   billboard:Destroy()
               end

               _G.GeneratorESPData = nil
           end
       end
   end,
})
local Button = MainTab:CreateButton({
   Name = "Fulbright",
   Callback = function()
       local Lighting = game:GetService("Lighting")
       
       -- Сохраняем оригинальные настройки
       if not _G.OriginalLightingSettings then
           _G.OriginalLightingSettings = {
               Ambient = Lighting.Ambient,
               Brightness = Lighting.Brightness,
               ColorShift_Bottom = Lighting.ColorShift_Bottom,
               ColorShift_Top = Lighting.ColorShift_Top,
               EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale,
               EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale,
               GlobalShadows = Lighting.GlobalShadows,
               OutdoorAmbient = Lighting.OutdoorAmbient,
               ShadowSoftness = Lighting.ShadowSoftness
           }
       end
       
       -- Устанавливаем Fulbright настройки
       Lighting.Ambient = Color3.fromRGB(255, 255, 255)
       Lighting.Brightness = 2
       Lighting.ColorShift_Bottom = Color3.fromRGB(0, 0, 0)
       Lighting.ColorShift_Top = Color3.fromRGB(0, 0, 0)
       Lighting.EnvironmentDiffuseScale = 0
       Lighting.EnvironmentSpecularScale = 0
       Lighting.GlobalShadows = false
       Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
       Lighting.ShadowSoftness = 0
       
       -- Отключаем все источники света
       for _, light in pairs(Lighting:GetChildren()) do
           if light:IsA("Light") then
               light.Enabled = false
           end
       end
   end,
})
local Toggle = EspTab:CreateToggle({
   Name = "C00lkid's minions esp",
   CurrentValue = false,
   Flag = "Toggle1",
   Callback = function(Value)
       if Value then
           if not _G.MinionESPData then
               _G.MinionESPData = {
                   Highlights = {},
                   Connections = {}
               }
           end

           local function isMinion(model)
               return model:IsA("Model") and model.Name == "PizzaDeliveryRig" and 
                      model.Parent and model.Parent.Name == "Ingame" and 
                      model.Parent.Parent and model.Parent.Parent.Name == "Map" and 
                      model.Parent.Parent.Parent == game.Workspace
           end

           local function updateMinionESP()
               for minion, highlight in pairs(_G.MinionESPData.Highlights) do
                   if minion and minion.Parent then
                       highlight.Adornee = minion
                       highlight.Enabled = true
                   else
                       highlight.Enabled = false
                   end
               end
           end

           local function createMinionESP(minion)
               if not isMinion(minion) then return end
               
               local highlight = Instance.new("Highlight")
               highlight.Name = minion.Name .. "_MinionESP"
               highlight.FillColor = Color3.fromRGB(0, 0, 255)
               highlight.FillTransparency = 0.6
               highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
               highlight.OutlineTransparency = 0.2
               highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
               highlight.Parent = game.CoreGui
               
               _G.MinionESPData.Highlights[minion] = highlight
           end

           local function scanForMinions()
               local mapFolder = game.Workspace:FindFirstChild("Map")
               if mapFolder then
                   local ingameFolder = mapFolder:FindFirstChild("Ingame")
                   if ingameFolder then
                       local minion = ingameFolder:FindFirstChild("PizzaDeliveryRig")
                       if minion then
                           createMinionESP(minion)
                       end
                   end
               end
           end

           scanForMinions()

           local function handleDescendantAdded(descendant)
               if descendant:IsA("Model") and descendant.Name == "PizzaDeliveryRig" then
                   local parent = descendant.Parent
                   if parent and parent.Name == "Ingame" then
                       local grandParent = parent.Parent
                       if grandParent and grandParent.Name == "Map" and grandParent.Parent == game.Workspace then
                           createMinionESP(descendant)
                       end
                   end
               end
           end

           local function handleDescendantRemoving(descendant)
               if _G.MinionESPData.Highlights[descendant] then
                   _G.MinionESPData.Highlights[descendant]:Destroy()
                   _G.MinionESPData.Highlights[descendant] = nil
               end
           end

           local descendantAddedConn = game.Workspace.DescendantAdded:Connect(handleDescendantAdded)
           local descendantRemovingConn = game.Workspace.DescendantRemoving:Connect(handleDescendantRemoving)

           _G.MinionESPData.MainConnections = {
               descendantAdded = descendantAddedConn,
               descendantRemoving = descendantRemovingConn
           }

           _G.MinionESPData.UpdateLoop = game:GetService("RunService").Heartbeat:Connect(function()
               updateMinionESP()
           end)

       else
           if _G.MinionESPData then
               if _G.MinionESPData.UpdateLoop then
                   _G.MinionESPData.UpdateLoop:Disconnect()
               end

               if _G.MinionESPData.MainConnections then
                   _G.MinionESPData.MainConnections.descendantAdded:Disconnect()
                   _G.MinionESPData.MainConnections.descendantRemoving:Disconnect()
               end

               for minion, highlight in pairs(_G.MinionESPData.Highlights) do
                   highlight:Destroy()
               end

               _G.MinionESPData = nil
           end
       end
   end,
})
local AutoGenerator = {
    Enabled = false,
    Cooldown = 2.5,
    Loop = nil
}

-- Объявляем функции ДО тоггла
local function ForceCompletePuzzle()
    local success, FlowGameManager = pcall(function()
        return require(game.ReplicatedStorage.Modules.Misc.FlowGameManager)
    end)
    
    if not success then
        return false
    end
    
    if FlowGameManager.activeGame and not FlowGameManager.activeGame.gameEnded then
        FlowGameManager.activeGame:EndGame(true)
        return true
    end
    
    return false
end

local function FindAndActivateGenerator()
    local IngameMapFolder = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Ingame")
    local SubMapFolder = IngameMapFolder and IngameMapFolder:FindFirstChild("Map")
    
    if not SubMapFolder then return false end
    
    for _, generator in ipairs(SubMapFolder:GetChildren()) do
        if generator.Name == "Generator" then
            local progress = generator:FindFirstChild("Progress")
            if progress and progress:IsA("NumberValue") and progress.Value < 100 then
                local success = pcall(function()
                    generator.Remotes.RE:FireServer()
                end)
                
                if success then
                    print("✅ Generator activated, waiting for puzzle...")
                    
                    local maxWaitTime = 10
                    local startTime = tick()
                    
                    while tick() - startTime < maxWaitTime do
                        task.wait(0.1)
                        
                        if ForceCompletePuzzle() then
                            print("✅ Puzzle completed automatically!")
                            return true
                        end
                    end
                    
                    print("❌ Puzzle didn't appear in time")
                    return false
                end
            end
        end
    end
    
    return false
end

local function StartAutoGenerator()
    if AutoGenerator.Loop then
        AutoGenerator.Loop:Disconnect()
        AutoGenerator.Loop = nil
    end
    
    AutoGenerator.Loop = game:GetService("RunService").Heartbeat:Connect(function(deltaTime)
        if not AutoGenerator.Enabled then return end
        
        if not AutoGenerator.LastCheck then
            AutoGenerator.LastCheck = tick()
        end
        
        if tick() - AutoGenerator.LastCheck >= AutoGenerator.Cooldown then
            AutoGenerator.LastCheck = tick()
            
            local success = FindAndActivateGenerator()
            
            if not success then
                print("❌ No available generators found")
            end
        end
    end)
end

local function StopAutoGenerator()
    if AutoGenerator.Loop then
        AutoGenerator.Loop:Disconnect()
        AutoGenerator.Loop = nil
    end
    AutoGenerator.LastCheck = nil
    print("❌ Auto Generator disabled")
end

-- Теперь создаем UI элементы ПОСЛЕ объявления функций
local Slider = GeneratorTab:CreateSlider({
   Name = "Auto Generator time",
   Range = {2.5, 5},
   Increment = 0.1,
   Suffix = "sec",
   CurrentValue = 2.5,
   Flag = "AutoGenTime",
   Callback = function(Value)
       AutoGenerator.Cooldown = Value
   end,
})

local Toggle = GeneratorTab:CreateToggle({
   Name = "Auto Generator",
   CurrentValue = false,
   Flag = "AutoGenToggle",
   Callback = function(Value)
       AutoGenerator.Enabled = Value
       
       if Value then
           StartAutoGenerator()
       else
           StopAutoGenerator()
       end
   end,
})

local Button = GeneratorTab:CreateButton({
   Name = "Complete Current Puzzle",
   Callback = function()
       if ForceCompletePuzzle() then
           print("✅ Current puzzle completed!")
       else
           print("❌ No active puzzle found")
       end
   end,
})
local Aimbot = {
    Enabled = false,
    Connection = nil,
    Active = false,
    Cooldown = 3,
    Prediction = 0.5
}

local function FindPlasmaBeamButton()
    local localPlayer = game.Players.LocalPlayer
    if not localPlayer then return nil end
    
    local playerGui = localPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return nil end
    
    local mainUI = playerGui:FindFirstChild("MainUI")
    if mainUI then
        local abilityContainer = mainUI:FindFirstChild("AbilityContainer")
        if abilityContainer then
            return abilityContainer:FindFirstChild("PlasmaBeam")
        end
    end
    
    return nil
end

local function GetNearestKiller()
    local killersFolder = workspace:FindFirstChild("Players") and workspace.Players:FindFirstChild("Killers")
    if not killersFolder then return nil end
    
    local camera = workspace.CurrentCamera
    if not camera then return nil end
    
    local nearestKiller = nil
    local nearestDistance = math.huge
    
    for _, killer in ipairs(killersFolder:GetChildren()) do
        if killer:IsA("Model") then
            local killerHRP = killer:FindFirstChild("HumanoidRootPart")
            if killerHRP then
                local distance = (camera.CFrame.Position - killerHRP.Position).Magnitude
                if distance < nearestDistance then
                    nearestDistance = distance
                    nearestKiller = killer
                end
            end
        end
    end
    
    return nearestKiller
end

local function AimAtKiller()
    local killer = GetNearestKiller()
    if not killer then return false end
    
    local camera = workspace.CurrentCamera
    if not camera then return false end
    
    local killerHRP = killer:FindFirstChild("HumanoidRootPart")
    if not killerHRP then return false end
    
    local currentCFrame = camera.CFrame
    
    -- Простое предсказание движения
    local predictedPosition = killerHRP.Position + killerHRP.Velocity * Aimbot.Prediction
    
    local targetCFrame = CFrame.lookAt(currentCFrame.Position, predictedPosition)
    camera.CFrame = targetCFrame
    
    return true
end

local function SetupPlasmaBeamAimbot()
    if not Aimbot.Enabled then return end
    
    local plasmaBeamButton = FindPlasmaBeamButton()
    if not plasmaBeamButton then
        task.delay(3, SetupPlasmaBeamAimbot)
        return
    end
    
    if plasmaBeamButton:IsA("TextButton") or plasmaBeamButton:IsA("ImageButton") then
        plasmaBeamButton.MouseButton1Click:Connect(function()
            if Aimbot.Enabled and not Aimbot.Active then
                Aimbot.Active = true
                
                if Aimbot.Connection then
                    Aimbot.Connection:Disconnect()
                end
                
                Aimbot.Connection = game:GetService("RunService").Heartbeat:Connect(function()
                    if not Aimbot.Active or not Aimbot.Enabled then return end
                    AimAtKiller()
                end)
                
                task.delay(Aimbot.Cooldown, function()
                    Aimbot.Active = false
                    if Aimbot.Connection then
                        Aimbot.Connection:Disconnect()
                        Aimbot.Connection = nil
                    end
                end)
            end
        end)
    end
end

local Toggle = AimbotTab:CreateToggle({
   Name = "PlasmaBeam Aimbot",
   CurrentValue = false,
   Flag = "PlasmaBeamAimbot",
   Callback = function(Value)
       Aimbot.Enabled = Value
       
       if Value then
           SetupPlasmaBeamAimbot()
       else
           if Aimbot.Connection then
               Aimbot.Connection:Disconnect()
               Aimbot.Connection = nil
           end
           Aimbot.Active = false
       end
   end,
})

local Slider = AimbotTab:CreateSlider({
   Name = "Prediction",
   Range = {0.0, 1.0},
   Increment = 0.1,
   Suffix = "sec",
   CurrentValue = 0.5,
   Flag = "AimbotPrediction",
   Callback = function(Value)
       Aimbot.Prediction = Value
   end,
})

game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function()
    task.wait(3)
    if Aimbot.Enabled then
        SetupPlasmaBeamAimbot()
    end
end)

local ZombieESP = {
    Enabled = false,
    Highlights = {},
    Connections = {}
}

local Toggle = EspTab:CreateToggle({
   Name = "1x4 Zombies Esp",
   CurrentValue = false,
   Flag = "ZombieESP",
   Callback = function(Value)
       ZombieESP.Enabled = Value
       
       if Value then
           -- Включаем ESP
           local function CreateZombieESP(zombie)
               if not zombie:IsA("Model") then return end
               if ZombieESP.Highlights[zombie] then return end
               
               local highlight = Instance.new("Highlight")
               highlight.Name = "ZombieESP"
               highlight.FillColor = Color3.fromRGB(0, 100, 255) -- Синий цвет
               highlight.FillTransparency = 0.7
               highlight.OutlineColor = Color3.fromRGB(255, 255, 255) -- Белый контур
               highlight.OutlineTransparency = 0.2
               highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
               highlight.Adornee = zombie
               highlight.Parent = game.CoreGui
               
               ZombieESP.Highlights[zombie] = highlight
               
               -- Отслеживаем удаление зомби
               local connection
               connection = zombie.AncestryChanged:Connect(function(_, parent)
                   if not parent then
                       if highlight then
                           highlight:Destroy()
                       end
                       ZombieESP.Highlights[zombie] = nil
                       connection:Disconnect()
                   end
               end)
           end
           
           -- Ищем существующих зомби
           local function ScanForZombies()
               local mapFolder = workspace:FindFirstChild("Map")
               if not mapFolder then return end
               
               local ingameFolder = mapFolder:FindFirstChild("Ingame")
               if not ingameFolder then return end
               
               local zombieFolder = ingameFolder:FindFirstChild("1x1x1x1Zombie")
               if not zombieFolder then return end
               
               for _, zombie in ipairs(zombieFolder:GetDescendants()) do
                   if zombie:IsA("Model") and zombie:FindFirstChild("Humanoid") then
                       CreateZombieESP(zombie)
                   end
               end
           end
           
           -- Отслеживаем новых зомби
           local function MonitorZombieFolder()
               local mapFolder = workspace:FindFirstChild("Map")
               if not mapFolder then return end
               
               local ingameFolder = mapFolder:FindFirstChild("Ingame")
               if not ingameFolder then return end
               
               local zombieFolder = ingameFolder:FindFirstChild("1x1x1x1Zombie")
               if not zombieFolder then return end
               
               ZombieESP.Connections.descendantAdded = zombieFolder.DescendantAdded:Connect(function(descendant)
                   if descendant:IsA("Model") and descendant:FindFirstChild("Humanoid") then
                       task.wait(0.1) -- Ждем полной загрузки модели
                       CreateZombieESP(descendant)
                   end
               end)
               
               ZombieESP.Connections.descendantRemoving = zombieFolder.DescendantRemoving:Connect(function(descendant)
                   if ZombieESP.Highlights[descendant] then
                       ZombieESP.Highlights[descendant]:Destroy()
                       ZombieESP.Highlights[descendant] = nil
                   end
               end)
           end
           
           -- Оптимизированное обновление
           ZombieESP.Connections.updateLoop = game:GetService("RunService").Stepped:Connect(function()
               if not ZombieESP.Enabled then return end
               
               for zombie, highlight in pairs(ZombieESP.Highlights) do
                   if zombie and zombie.Parent then
                       highlight.Enabled = true
                   else
                       highlight.Enabled = false
                   end
               end
           end)
           
           -- Запускаем сканирование
           ScanForZombies()
           MonitorZombieFolder()
           
       else
           -- Выключаем ESP
           for _, connection in pairs(ZombieESP.Connections) do
               connection:Disconnect()
           end
           ZombieESP.Connections = {}
           
           for _, highlight in pairs(ZombieESP.Highlights) do
               highlight:Destroy()
           end
           ZombieESP.Highlights = {}
       end
   end,
})
