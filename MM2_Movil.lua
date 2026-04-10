--[[
    CGS MOBILE - MENÚ HORIZONTAL CENTRADO
    Botón arrastrable con logo personalizable
    ESP sin confusiones
    Panel admin con botón cerrar
    Teletransporte por nombre (TP Name) funcionando
    Pistola caída visible a través de paredes
]]

-- ========== CONFIGURACIÓN ==========
local LOGO_ID = "rbxassetid://6031091086"   -- Cambia por el ID de tu logo (si no funciona, usa texto)
local BTN_SIZE = 60
local MENU_HEIGHT = 80

-- ========== SERVICIOS ==========
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ========== SETTINGS ==========
local Settings = {
    SilentAim = false,
    UseCameraAimbot = false,
    TriggerBot = false,
    Wallbang = false,
    KnifeAura = false,
    AutoShoot = false,
    FakeLag = false,
    ServerLag = false,
    SpeedGlitch = false,
    FlingSheriff = false,
    FlingMurder = false,
    GrabHeight = 3,
    AuraRange = 25,
    AuraDelay = 0.035,
    ChestOffset = 1.65,
    ShootRange = 100,
}

-- ========== VARIABLES ==========
local Rubies = {}
local LastShot = 0
local FakeLagConn, ServerLagConn, SpeedGlitchConn = nil, nil, nil
local SelectedPlayer = nil

-- ========== NOTIFICACIONES ==========
local function Notify(title, text)
    StarterGui:SetCore("SendNotification", {Title = title, Text = text, Duration = 2})
end

-- ========== ESP MEJORADO (SIN CONFUSIONES) ==========
local function GetRoleColor(player)
    if not player.Character then return Color3.new(0.5,0.5,0.5), 0.5 end
    local char = player.Character
    local bp = player:FindFirstChild("Backpack") or player.Backpack
    
    local hasKnife = false
    if char:FindFirstChild("Knife") or char:FindFirstChild("KnifeClone") then hasKnife = true end
    if bp and (bp:FindFirstChild("Knife") or bp:FindFirstChild("KnifeClone")) then hasKnife = true end
    
    local hasGun = false
    if char:FindFirstChild("Gun") or char:FindFirstChild("Revolver") then hasGun = true end
    if bp and (bp:FindFirstChild("Gun") or bp:FindFirstChild("Revolver")) then hasGun = true end
    
    if hasKnife then
        return Color3.new(1, 0, 0), 0.25
    elseif hasGun then
        return Color3.fromRGB(0, 150, 255), 0.2
    else
        return Color3.new(0, 1, 0), 0.4
    end
end

local function UpdateESP(player)
    if player == LocalPlayer then return end
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local box = Rubies[player]
    if not box then
        box = Instance.new("BoxHandleAdornment")
        box.Name = "CGS_ESP"
        box.Size = Vector3.new(1.2, 1.2, 1.2)
        box.AlwaysOnTop = true
        box.ZIndex = 5
        Rubies[player] = box
    end
    local color, trans = GetRoleColor(player)
    box.Color3 = color
    box.Transparency = trans
    box.Adornee = root
    box.Parent = root
end

-- ========== TOGGLES Y ACCIONES ==========
local function ToggleFakeLag()
    Settings.FakeLag = not Settings.FakeLag
    if Settings.FakeLag then
        FakeLagConn = RunService.Heartbeat:Connect(function()
            if not Settings.FakeLag then return end
            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root and math.random(1,3)==1 then
                root.AssemblyLinearVelocity = Vector3.new(0, root.AssemblyLinearVelocity.Y, 0)
            end
        end)
    else
        if FakeLagConn then FakeLagConn:Disconnect(); FakeLagConn=nil end
    end
    Notify("⏳ Fake Lag", Settings.FakeLag and "On" or "Off")
end

local function ToggleServerLag()
    Settings.ServerLag = not Settings.ServerLag
    if Settings.ServerLag then
        ServerLagConn = RunService.Heartbeat:Connect(function()
            if not Settings.ServerLag then return end
            pcall(function()
                local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    root:SetNetworkOwner(nil)
                    for i=1,20 do
                        root.AssemblyLinearVelocity = Vector3.new(math.random(-120,120), root.AssemblyLinearVelocity.Y, math.random(-120,120))
                    end
                end
            end)
        end)
    else
        if ServerLagConn then ServerLagConn:Disconnect(); ServerLagConn=nil end
    end
    Notify("🌐 Server Lag", Settings.ServerLag and "On" or "Off")
end

local function ToggleSpeedGlitch()
    Settings.SpeedGlitch = not Settings.SpeedGlitch
    if Settings.SpeedGlitch then
        SpeedGlitchConn = RunService.Heartbeat:Connect(function()
            if not Settings.SpeedGlitch then return end
            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local vel = root.AssemblyLinearVelocity
                root.AssemblyLinearVelocity = Vector3.new(vel.X*1.48, vel.Y, vel.Z*1.48)
            end
        end)
    else
        if SpeedGlitchConn then SpeedGlitchConn:Disconnect(); SpeedGlitchConn=nil end
    end
    Notify("⚡ Speed Glitch", Settings.SpeedGlitch and "On" or "Off")
end

local function ToggleFlingSheriff()
    local char = LocalPlayer.Character
    local myRoot = char and char:FindFirstChild("HumanoidRootPart")
    if myRoot then
        local oldCF = myRoot.CFrame
        for _, p in pairs(Players:GetPlayers()) do
            if p~=LocalPlayer and p.Character then
                local targetRoot = p.Character:FindFirstChild("HumanoidRootPart")
                local isSheriff = p.Backpack:FindFirstChild("Gun") or p.Character:FindFirstChild("Gun") or p.Backpack:FindFirstChild("Revolver") or p.Character:FindFirstChild("Revolver")
                if isSheriff and targetRoot then
                    Notify("⚡", "FLING SHERIFF")
                    myRoot.AssemblyAngularVelocity = Vector3.new(0,999999,0)
                    local start = tick()
                    while tick()-start < 0.4 do
                        myRoot.CFrame = targetRoot.CFrame * CFrame.Angles(0, math.rad(tick()*12000),0) * CFrame.new(0.6,0,0.6)
                        myRoot.AssemblyLinearVelocity = Vector3.new(25000,50,25000)
                        task.wait()
                        if not targetRoot.Parent then break end
                    end
                    myRoot.CFrame = oldCF
                    myRoot.AssemblyLinearVelocity = Vector3.new(0,0,0)
                    myRoot.AssemblyAngularVelocity = Vector3.new(0,0,0)
                    return
                end
            end
        end
    end
end

local function ToggleFlingMurder()
    local char = LocalPlayer.Character
    local myRoot = char and char:FindFirstChild("HumanoidRootPart")
    if myRoot then
        local oldCF = myRoot.CFrame
        for _, p in pairs(Players:GetPlayers()) do
            if p~=LocalPlayer and p.Character then
                local targetRoot = p.Character:FindFirstChild("HumanoidRootPart")
                local isMurder = p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")
                if isMurder and targetRoot then
                    Notify("⚡", "FLING MURDER")
                    myRoot.AssemblyAngularVelocity = Vector3.new(0,999999,0)
                    local start = tick()
                    while tick()-start < 0.4 do
                        myRoot.CFrame = targetRoot.CFrame * CFrame.Angles(0, math.rad(tick()*12000),0) * CFrame.new(0.6,0,0.6)
                        myRoot.AssemblyLinearVelocity = Vector3.new(25000,50,25000)
                        task.wait()
                        if not targetRoot.Parent then break end
                    end
                    myRoot.CFrame = oldCF
                    myRoot.AssemblyLinearVelocity = Vector3.new(0,0,0)
                    myRoot.AssemblyAngularVelocity = Vector3.new(0,0,0)
                    return
                end
            end
        end
    end
end

-- ========== TELETRANSPORTES ==========
local function TeleportToLobby()
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then Notify("⚠️","Sin personaje") return end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():find("lobby") then
            root.CFrame = obj.CFrame + Vector3.new(0,5,0)
            Notify("🏢","Lobby")
            return
        end
    end
    Notify("❌","No se encontró lobby")
end

local function TeleportToAlivePlayer()
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then Notify("⚠️","Sin personaje") return end
    local targets = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p~=LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(targets, p)
        end
    end
    if #targets==0 then Notify("❌","Sin jugadores") return end
    local target = targets[math.random(#targets)]
    root.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0,2,3)
    Notify("🌀","TP a "..target.Name)
end

local function GrabGun()
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    for _, v in ipairs(workspace:GetDescendants()) do
        if v.Name=="GunDrop" and v:IsA("BasePart") then
            local old = root.CFrame
            root.CFrame = v.CFrame * CFrame.new(0, Settings.GrabHeight, 0)
            task.wait(0.15)
            root.CFrame = old
            Notify("🔫","Pistola agarrada")
            break
        end
    end
end

-- ========== TELETRANSPORTE POR NOMBRE ==========
local function TeleportByName(playerName)
    if not playerName or playerName == "" then
        Notify("❌", "Nombre vacío")
        return false
    end
    
    local target = nil
    for _, p in pairs(Players:GetPlayers()) do
        if p.Name:lower() == playerName:lower() or p.DisplayName:lower() == playerName:lower() then
            target = p
            break
        end
    end
    
    if not target then
        Notify("❌", "Usuario no encontrado: " .. playerName)
        return false
    end
    
    local targetRoot = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
    if not targetRoot then
        Notify("⚠️", "El jugador no tiene personaje")
        return false
    end
    
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then
        Notify("⚠️", "No tienes personaje")
        return false
    end
    
    myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 2, 3)
    Notify("✅", "Teletransportado a " .. target.Name)
    return true
end

local function OpenTeleportInput()
    if CoreGui:FindFirstChild("TeleportInputGUI") then CoreGui.TeleportInputGUI:Destroy() end
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "TeleportInputGUI"
    gui.ResetOnSpawn = false
    gui.Parent = CoreGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 150)
    frame.Position = UDim2.new(0.5, -150, 0.5, -75)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.fromRGB(0, 255, 0)
    frame.Active = true
    frame.Draggable = true
    frame.Parent = gui
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 35)
    title.BackgroundColor3 = Color3.fromRGB(0, 50, 0)
    title.Text = "TP POR NOMBRE"
    title.TextColor3 = Color3.fromRGB(0, 255, 0)
    title.Font = Enum.Font.Code
    title.TextSize = 16
    title.Parent = frame
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 35, 0, 35)
    closeBtn.Position = UDim2.new(1, -35, 0, 0)
    closeBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
    closeBtn.Font = Enum.Font.Code
    closeBtn.TextSize = 14
    closeBtn.Parent = title
    closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)
    
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0.8, 0, 0, 40)
    box.Position = UDim2.new(0.1, 0, 0.45, 0)
    box.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    box.BorderColor3 = Color3.fromRGB(0, 255, 0)
    box.TextColor3 = Color3.fromRGB(0, 255, 0)
    box.Font = Enum.Font.Code
    box.TextSize = 14
    box.Text = "Nombre del jugador"
    box.ClearTextOnFocus = true
    box.Parent = frame
    
    local tpBtn = Instance.new("TextButton")
    tpBtn.Size = UDim2.new(0.4, 0, 0, 40)
    tpBtn.Position = UDim2.new(0.05, 0, 0.75, 0)
    tpBtn.BackgroundColor3 = Color3.fromRGB(0, 80, 0)
    tpBtn.BorderColor3 = Color3.fromRGB(0, 255, 0)
    tpBtn.Text = "TELEPORT"
    tpBtn.TextColor3 = Color3.fromRGB(255,255,255)
    tpBtn.Font = Enum.Font.Code
    tpBtn.TextSize = 14
    tpBtn.Parent = frame
    
    local cancelBtn = Instance.new("TextButton")
    cancelBtn.Size = UDim2.new(0.4, 0, 0, 40)
    cancelBtn.Position = UDim2.new(0.55, 0, 0.75, 0)
    cancelBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
    cancelBtn.BorderColor3 = Color3.fromRGB(150, 0, 0)
    cancelBtn.Text = "CANCELAR"
    cancelBtn.TextColor3 = Color3.fromRGB(255,255,255)
    cancelBtn.Font = Enum.Font.Code
    cancelBtn.TextSize = 14
    cancelBtn.Parent = frame
    
    tpBtn.MouseButton1Click:Connect(function()
        local name = box.Text
        gui:Destroy()
        TeleportByName(name)
    end)
    
    cancelBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)
end

-- ========== GUN HIGHLIGHT (VISIBLE A TRAVÉS DE PAREDES) ==========
local function SetupGunHighlight()
    Workspace.DescendantAdded:Connect(function(v)
        if v.Name == "GunDrop" and v:IsA("BasePart") then
            -- Eliminar highlight previo si existe
            local existing = v:FindFirstChild("CGS_GunHighlight")
            if existing then existing:Destroy() end
            
            local hl = Instance.new("Highlight")
            hl.Name = "CGS_GunHighlight"
            hl.FillColor = Color3.fromRGB(255, 100, 0)      -- Naranja brillante
            hl.OutlineColor = Color3.fromRGB(255, 255, 255) -- Contorno blanco
            hl.FillTransparency = 0.2
            hl.OutlineTransparency = 0
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop -- Visible a través de paredes
            hl.Parent = v
            
            ShowNotification("🔫 PISTOLA CAÍDA", "¡Visible a través de paredes! Toca Z para agarrar")
        end
    end)
end

-- ========== ADMIN PANEL CON BOTÓN CERRAR ==========
local function ExecuteTargetFling(target)
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local targetRoot = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
    if myRoot and targetRoot then
        Notify("⚡","FLING a "..target.Name)
        local old = myRoot.CFrame
        myRoot.AssemblyAngularVelocity = Vector3.new(0,999999,0)
        local start = tick()
        while tick()-start < 0.5 do
            myRoot.CFrame = targetRoot.CFrame * CFrame.new(0,0,0)
            myRoot.AssemblyLinearVelocity = Vector3.new(30000,30000,30000)
            task.wait()
            if not targetRoot.Parent then break end
        end
        myRoot.CFrame = old
        myRoot.AssemblyLinearVelocity = Vector3.new(0,0,0)
        myRoot.AssemblyAngularVelocity = Vector3.new(0,0,0)
    end
end

local function ExecuteTargetHunt(target)
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local targetRoot = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
    if myRoot and targetRoot then
        myRoot.CFrame = targetRoot.CFrame * CFrame.new(0,0,3)
        Notify("🔪","HUNT a "..target.Name)
    end
end

local function CreateAdminPanel()
    if CoreGui:FindFirstChild("CGS_AdminPanel") then CoreGui.CGS_AdminPanel:Destroy() end
    local gui = Instance.new("ScreenGui")
    gui.Name = "CGS_AdminPanel"
    gui.Parent = CoreGui
    gui.Enabled = false
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0,500,0,350)
    frame.Position = UDim2.new(0.5,-250,0.5,-175)
    frame.BackgroundColor3 = Color3.fromRGB(12,12,12)
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.fromRGB(255,0,0)
    frame.Active = true
    frame.Draggable = true
    frame.Parent = gui
    
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1,0,0,35)
    titleBar.BackgroundColor3 = Color3.fromRGB(25,0,0)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = frame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1,-40,0,35)
    title.BackgroundTransparency = 1
    title.Text = "CGS ADMIN V24.0"
    title.TextColor3 = Color3.fromRGB(255,50,50)
    title.Font = Enum.Font.Code
    title.TextSize = 16
    title.TextXAlignment = Enum.TextXAlignment.Center
    title.Parent = titleBar
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0,35,0,35)
    closeBtn.Position = UDim2.new(1,-35,0,0)
    closeBtn.BackgroundColor3 = Color3.fromRGB(100,0,0)
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
    closeBtn.Font = Enum.Font.Code
    closeBtn.TextSize = 18
    closeBtn.Parent = titleBar
    closeBtn.MouseButton1Click:Connect(function() gui.Enabled = false end)
    
    local left = Instance.new("ScrollingFrame")
    left.Size = UDim2.new(0.5,-15,1,-55)
    left.Position = UDim2.new(0,10,0,45)
    left.BackgroundColor3 = Color3.fromRGB(20,20,20)
    left.BorderColor3 = Color3.fromRGB(150,0,0)
    left.ScrollBarThickness = 5
    left.Parent = frame
    
    local layout = Instance.new("UIListLayout")
    layout.Parent = left
    layout.Padding = UDim.new(0,4)
    layout.SortOrder = Enum.SortOrder.Name
    
    local right = Instance.new("Frame")
    right.Size = UDim2.new(0.5,-15,1,-55)
    right.Position = UDim2.new(0.5,5,0,45)
    right.BackgroundColor3 = Color3.fromRGB(15,15,15)
    right.BorderColor3 = Color3.fromRGB(100,0,0)
    right.Parent = frame
    
    local actionTitle = Instance.new("TextLabel")
    actionTitle.Size = UDim2.new(1,0,0,30)
    actionTitle.Text = "SELECCIONA OBJETIVO"
    actionTitle.TextColor3 = Color3.fromRGB(200,200,200)
    actionTitle.BackgroundTransparency = 1
    actionTitle.Font = Enum.Font.Code
    actionTitle.TextSize = 14
    actionTitle.Parent = right
    
    local flingBtn = Instance.new("TextButton")
    flingBtn.Size = UDim2.new(1,-20,0,40)
    flingBtn.Position = UDim2.new(0,10,0,50)
    flingBtn.BackgroundColor3 = Color3.fromRGB(80,0,0)
    flingBtn.Text = "⚡ EJECUTAR FLING"
    flingBtn.TextColor3 = Color3.new(1,1,1)
    flingBtn.Font = Enum.Font.Code
    flingBtn.TextSize = 14
    flingBtn.Visible = false
    flingBtn.Parent = right
    
    local huntBtn = Instance.new("TextButton")
    huntBtn.Size = UDim2.new(1,-20,0,40)
    huntBtn.Position = UDim2.new(0,10,0,100)
    huntBtn.BackgroundColor3 = Color3.fromRGB(0,60,0)
    huntBtn.Text = "🔪 CAZAR (TP)"
    huntBtn.TextColor3 = Color3.new(1,1,1)
    huntBtn.Font = Enum.Font.Code
    huntBtn.TextSize = 14
    huntBtn.Visible = false
    huntBtn.Parent = right
    
    local function UpdateList()
        for _, v in pairs(left:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1,-10,0,30)
                btn.BackgroundColor3 = Color3.fromRGB(30,10,10)
                btn.Text = p.DisplayName
                btn.TextColor3 = Color3.new(1,1,1)
                btn.Font = Enum.Font.Code
                btn.TextSize = 13
                btn.Parent = left
                btn.MouseButton1Click:Connect(function()
                    SelectedPlayer = p
                    actionTitle.Text = "@" .. p.Name:upper()
                    actionTitle.TextColor3 = Color3.fromRGB(255,255,0)
                    flingBtn.Visible = true
                    huntBtn.Visible = true
                end)
            end
        end
        left.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y+10)
    end
    
    flingBtn.MouseButton1Click:Connect(function() if SelectedPlayer then ExecuteTargetFling(SelectedPlayer) end end)
    huntBtn.MouseButton1Click:Connect(function() if SelectedPlayer then ExecuteTargetHunt(SelectedPlayer) end end)
    
    UpdateList()
    Players.PlayerAdded:Connect(UpdateList)
    Players.PlayerRemoving:Connect(UpdateList)
end

-- ========== MENÚ HORIZONTAL CENTRADO ==========
local function CreateHorizontalMenu()
    if CoreGui:FindFirstChild("CGS_HorizontalMenu") then return end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CGS_HorizontalMenu"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = CoreGui
    
    local btn = Instance.new("ImageButton")
    btn.Size = UDim2.new(0, BTN_SIZE, 0, BTN_SIZE)
    btn.Position = UDim2.new(0, 20, 0, 100)
    btn.BackgroundColor3 = Color3.fromRGB(255,0,0)
    btn.BackgroundTransparency = 0.2
    btn.Image = LOGO_ID
    btn.ImageColor3 = Color3.fromRGB(255,255,255)
    btn.Parent = screenGui
    
    local menu = Instance.new("Frame")
    menu.Size = UDim2.new(0, 0, 0, MENU_HEIGHT)
    menu.Position = UDim2.new(0.5, 0, 0.5, -MENU_HEIGHT/2)
    menu.AnchorPoint = Vector2.new(0.5, 0)
    menu.BackgroundColor3 = Color3.fromRGB(20,20,30)
    menu.BackgroundTransparency = 0.1
    menu.BorderSizePixel = 2
    menu.BorderColor3 = Color3.fromRGB(255,0,0)
    menu.Visible = false
    menu.ClipsDescendants = true
    menu.Parent = screenGui
    
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1,0,1,0)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 3
    scroll.CanvasSize = UDim2.new(0,0,0,0)
    scroll.Parent = menu
    
    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.Padding = UDim.new(0, 5)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = scroll
    
    local function updateWidth()
        local total = layout.AbsoluteContentSize.X + 20
        menu.Size = UDim2.new(0, math.min(total, 450), 0, MENU_HEIGHT)
        scroll.CanvasSize = UDim2.new(0, total, 0, 0)
    end
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateWidth)
    
    local function addButton(text, color, callback)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 70, 0, 50)
        b.BackgroundColor3 = color
        b.BackgroundTransparency = 0.2
        b.Text = text
        b.TextColor3 = Color3.fromRGB(255,255,255)
        b.Font = Enum.Font.Code
        b.TextSize = 12
        b.Parent = scroll
        b.MouseButton1Click:Connect(function()
            callback()
            menu.Visible = false
            btn.BackgroundColor3 = Color3.fromRGB(255,0,0)
            btn.BackgroundTransparency = 0.2
        end)
        updateWidth()
        return b
    end
    
    local function addToggle(text, color, settingVar, onColor, offColor)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 70, 0, 50)
        b.BackgroundColor3 = Settings[settingVar] and onColor or offColor
        b.BackgroundTransparency = 0.2
        b.Text = text .. (Settings[settingVar] and " ✅" or " ❌")
        b.TextColor3 = Color3.fromRGB(255,255,255)
        b.Font = Enum.Font.Code
        b.TextSize = 11
        b.Parent = scroll
        local function update()
            b.Text = text .. (Settings[settingVar] and " ✅" or " ❌")
            b.BackgroundColor3 = Settings[settingVar] and onColor or offColor
        end
        b.MouseButton1Click:Connect(function()
            if settingVar == "SilentAim" then
                Settings.SilentAim = not Settings.SilentAim
                Notify("🔇 Silent Aim", Settings.SilentAim and "On" or "Off")
            elseif settingVar == "KnifeAura" then
                Settings.KnifeAura = not Settings.KnifeAura
                Notify("🔪 Kill Aura", Settings.KnifeAura and "On" or "Off")
            elseif settingVar == "AutoShoot" then
                Settings.AutoShoot = not Settings.AutoShoot
                Notify("🔫 Auto Shoot", Settings.AutoShoot and "On" or "Off")
            elseif settingVar == "TriggerBot" then
                Settings.TriggerBot = not Settings.TriggerBot
                Notify("⚡ Trigger Bot", Settings.TriggerBot and "On" or "Off")
            elseif settingVar == "UseCameraAimbot" then
                Settings.UseCameraAimbot = not Settings.UseCameraAimbot
                Notify("🎯 Camera Aimbot", Settings.UseCameraAimbot and "On" or "Off")
            elseif settingVar == "Wallbang" then
                Settings.Wallbang = not Settings.Wallbang
                Notify("🏹 Wallbang", Settings.Wallbang and "On" or "Off")
            elseif settingVar == "FakeLag" then
                ToggleFakeLag()
            elseif settingVar == "ServerLag" then
                ToggleServerLag()
            elseif settingVar == "SpeedGlitch" then
                ToggleSpeedGlitch()
            end
            update()
        end)
        updateWidth()
        return b
    end
    
    -- AÑADIR TODAS LAS FUNCIONES
    addToggle("🔇 Silent", Color3.fromRGB(0,100,0), "SilentAim", Color3.fromRGB(0,150,0), Color3.fromRGB(80,0,0))
    addToggle("🔪 Kill", Color3.fromRGB(0,100,0), "KnifeAura", Color3.fromRGB(0,150,0), Color3.fromRGB(80,0,0))
    addToggle("🔫 Auto", Color3.fromRGB(0,100,0), "AutoShoot", Color3.fromRGB(0,150,0), Color3.fromRGB(80,0,0))
    addToggle("⚡ Trigger", Color3.fromRGB(0,100,0), "TriggerBot", Color3.fromRGB(0,150,0), Color3.fromRGB(80,0,0))
    addToggle("🎯 CamBot", Color3.fromRGB(0,100,0), "UseCameraAimbot", Color3.fromRGB(0,150,0), Color3.fromRGB(80,0,0))
    addToggle("🏹 Wall", Color3.fromRGB(0,100,0), "Wallbang", Color3.fromRGB(0,150,0), Color3.fromRGB(80,0,0))
    addToggle("⏳ FakeLag", Color3.fromRGB(100,0,0), "FakeLag", Color3.fromRGB(0,150,0), Color3.fromRGB(80,0,0))
    addToggle("🌐 Lag", Color3.fromRGB(100,0,0), "ServerLag", Color3.fromRGB(0,150,0), Color3.fromRGB(80,0,0))
    addToggle("⚡ Speed", Color3.fromRGB(100,0,0), "SpeedGlitch", Color3.fromRGB(0,150,0), Color3.fromRGB(80,0,0))
    
    addButton("🎲 Sheriff", Color3.fromRGB(100,0,100), ToggleFlingSheriff)
    addButton("🎲 Murder", Color3.fromRGB(100,0,100), ToggleFlingMurder)
    addButton("🏢 Lobby", Color3.fromRGB(0,80,150), TeleportToLobby)
    addButton("🌀 TP Rand", Color3.fromRGB(150,80,0), TeleportToAlivePlayer)
    addButton("🔫 Agarrar", Color3.fromRGB(150,150,0), GrabGun)
    addButton("👥 Admin", Color3.fromRGB(0,100,100), function()
        local panel = CoreGui:FindFirstChild("CGS_AdminPanel")
        if panel then panel.Enabled = not panel.Enabled end
        Notify("🛡️", panel and (panel.Enabled and "Admin abierto" or "Admin cerrado") or "Error")
    end)
    addButton("📝 TP Name", Color3.fromRGB(0,150,0), OpenTeleportInput)
    
    local menuOpen = false
    btn.MouseButton1Click:Connect(function()
        menuOpen = not menuOpen
        menu.Visible = menuOpen
        if menuOpen then
            btn.BackgroundColor3 = Color3.fromRGB(0,255,0)
            btn.BackgroundTransparency = 0.5
            updateWidth()
        else
            btn.BackgroundColor3 = Color3.fromRGB(255,0,0)
            btn.BackgroundTransparency = 0.2
        end
    end)
    
    local dragging = false
    local dragStart, btnStart
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            btnStart = btn.Position
        end
    end)
    btn.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            btn.Position = UDim2.new(btnStart.X.Scale, btnStart.X.Offset + delta.X, btnStart.Y.Scale, btnStart.Y.Offset + delta.Y)
        end
    end)
    btn.InputEnded:Connect(function() dragging = false end)
end

-- ========== BUCLES DE AIMBOT, KILL AURA, ETC ==========
RunService.RenderStepped:Connect(function()
    if Settings.UseCameraAimbot then
        for _, p in pairs(Players:GetPlayers()) do
            if p~=LocalPlayer and p.Character and (p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")) then
                local part = p.Character:FindFirstChild("UpperTorso") or p.Character:FindFirstChild("Torso") or p.Character:FindFirstChild("HumanoidRootPart")
                if part then
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, part.Position)
                end
                break
            end
        end
    end
end)

pcall(function()
    local mt = getrawmetatable(game)
    local old = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        if Settings.SilentAim and getnamecallmethod() == "FireServer" then
            local name = tostring(self.Name):lower()
            if name:find("shoot") or name:find("gun") then
                for _, p in pairs(Players:GetPlayers()) do
                    if p~=LocalPlayer and p.Character then
                        local isM = p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")
                        if isM then
                            local root = p.Character:FindFirstChild("HumanoidRootPart")
                            if root then
                                return old(self, root.Position + Vector3.new(0, Settings.ChestOffset, 0))
                            end
                        end
                    end
                end
            end
        end
        return old(self, ...)
    end)
    setreadonly(mt, true)
end)

RunService.RenderStepped:Connect(function()
    if Settings.TriggerBot and LocalPlayer.Character then
        local gun = LocalPlayer.Character:FindFirstChild("Gun") or LocalPlayer.Backpack:FindFirstChild("Gun")
        if gun then
            for _, p in pairs(Players:GetPlayers()) do
                if p~=LocalPlayer and p.Character then
                    if p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife") then
                        gun:Activate()
                        break
                    end
                end
            end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if Settings.KnifeAura and LocalPlayer.Character then
        local knife = LocalPlayer.Character:FindFirstChild("Knife") or LocalPlayer.Backpack:FindFirstChild("Knife")
        if knife then
            for _, p in pairs(Players:GetPlayers()) do
                if p~=LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (LocalPlayer.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                    if dist <= Settings.AuraRange then
                        knife:Activate()
                        task.wait(Settings.AuraDelay)
                    end
                end
            end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if Settings.AutoShoot and tick() - LastShot > 0.07 then
        local char = LocalPlayer.Character
        if char then
            local gun = char:FindFirstChild("Gun") or LocalPlayer.Backpack:FindFirstChild("Gun")
            if gun then
                for _, p in pairs(Players:GetPlayers()) do
                    if p~=LocalPlayer and p.Character then
                        if p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife") then
                            local upper = p.Character:FindFirstChild("UpperTorso") or p.Character:FindFirstChild("Torso")
                            local root = p.Character:FindFirstChild("HumanoidRootPart")
                            local pos = upper and (upper.Position + Vector3.new(0,Settings.ChestOffset,0)) or (root and root.Position + Vector3.new(0,Settings.ChestOffset,0))
                            if pos and (char.HumanoidRootPart.Position - pos).Magnitude < Settings.ShootRange then
                                gun:Activate()
                                LastShot = tick()
                            end
                            break
                        end
                    end
                end
            end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    for _, p in pairs(Players:GetPlayers()) do
        pcall(function() UpdateESP(p) end)
    end
end)

-- ========== INICIO ==========
SetupGunHighlight()
CreateAdminPanel()
CreateHorizontalMenu()

task.wait(2)
for _, p in pairs(Players:GetPlayers()) do
    pcall(function() UpdateESP(p) end)
end

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        task.wait(1.5)
        pcall(function() UpdateESP(p) end)
    end)
end)

Notify("✅", "CGS Mobile cargado - TP por nombre incluido - Pistola visible a través de paredes")
print("==========================================")
print("CGS MOBILE V24.0 - MENÚ HORIZONTAL")
print("Botón arrastrable | Menú centrado")
print("TP por nombre FUNCIONAL")
print("Pistola caída visible a través de paredes")
print("==========================================")