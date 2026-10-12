-- ==========================================
-- Auto-Run FPS Booster & Map Cleaner UI 
-- (Top-Left, Minimized Button, Auto Execute)
-- ==========================================

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local guiParent = pcall(function() return CoreGui.Name end) and CoreGui or player:WaitForChild("PlayerGui")

-- ลบ UI เก่าออกถ้ามี
if guiParent:FindFirstChild("FPSBoosterUI") then
    guiParent.FPSBoosterUI:Destroy()
end

-- ================= สร้าง UI =================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FPSBoosterUI"
ScreenGui.Parent = guiParent

-- เฟรมหลัก (ย้ายมาเริ่มต้นที่มุมซ้ายบน)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 150)
MainFrame.Position = UDim2.new(0, 20, 0, 20) -- มุมซ้ายบน ห่างขอบนิดหน่อย
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- ให้ใช้เมาส์ลากได้เหมือนเดิม
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- แถบหัวข้อ (สำหรับใส่ปุ่มย่อ)
local TitleFrame = Instance.new("Frame")
TitleFrame.Size = UDim2.new(1, 0, 0, 35)
TitleFrame.BackgroundTransparency = 1
TitleFrame.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "⚡ FPS & Map Cleaner"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleFrame

-- ปุ่มย่อ/ขยาย UI (-)
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
MinimizeBtn.Position = UDim2.new(1, -35, 0, 2)
MinimizeBtn.BackgroundTransparency = 1
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 20
MinimizeBtn.Parent = TitleFrame

-- เฟรมเก็บเนื้อหา (ปุ่มด้านใน)
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, 0, 1, -35)
ContentFrame.Position = UDim2.new(0, 0, 0, 35)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

local TreeButton = Instance.new("TextButton")
TreeButton.Size = UDim2.new(0.9, 0, 0, 35)
TreeButton.Position = UDim2.new(0.05, 0, 0, 10)
TreeButton.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
TreeButton.Text = "🌲 ซ่อนต้นไม้/หญ้า : OFF"
TreeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TreeButton.Font = Enum.Font.GothamSemibold
TreeButton.TextSize = 14
TreeButton.Parent = ContentFrame
Instance.new("UICorner", TreeButton).CornerRadius = UDim.new(0, 6)

local FpsButton = Instance.new("TextButton")
FpsButton.Size = UDim2.new(0.9, 0, 0, 35)
FpsButton.Position = UDim2.new(0.05, 0, 0, 55)
FpsButton.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
FpsButton.Text = "🚀 Boost FPS : OFF"
FpsButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FpsButton.Font = Enum.Font.GothamSemibold
FpsButton.TextSize = 14
FpsButton.Parent = ContentFrame
Instance.new("UICorner", FpsButton).CornerRadius = UDim.new(0, 6)

-- ================= ลอจิกการทำงาน =================
local isMinimized = false
local treesHidden = false
local fpsBoosted = false
local originalTreeStates = {}
local eventConnection = nil

-- ฟังก์ชันย่อ/ขยาย UI
MinimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        MainFrame.Size = UDim2.new(0, 250, 0, 35) -- พับเหลือ 35px (เห็นแค่หัว)
        ContentFrame.Visible = false
        MinimizeBtn.Text = "+"
    else
        MainFrame.Size = UDim2.new(0, 250, 0, 150) -- กางออกเท่าเดิม
        ContentFrame.Visible = true
        MinimizeBtn.Text = "-"
    end
end)

local function IsTreeOrGrass(obj)
    local name = string.lower(obj.Name)
    local pName = obj.Parent and string.lower(obj.Parent.Name) or ""
    local keywords = {"tree", "leaf", "leaves", "grass", "bush", "plant", "wood", "rock"}
    for _, word in ipairs(keywords) do
        if string.find(name, word) or string.find(pName, word) then
            return true
        end
    end
    return false
end

-- ฟังก์ชันซ่อนต้นไม้/หญ้า
local function ToggleTrees()
    treesHidden = not treesHidden
    if treesHidden then
        TreeButton.Text = "🌲 ซ่อนต้นไม้/หญ้า : ON"
        TreeButton.BackgroundColor3 = Color3.fromRGB(85, 255, 85)
        
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and IsTreeOrGrass(obj) then
                originalTreeStates[obj] = {
                    Transparency = obj.Transparency,
                    CanCollide = obj.CanCollide
                }
                obj.Transparency = 1
                obj.CanCollide = false
            end
        end
    else
        TreeButton.Text = "🌲 ซ่อนต้นไม้/หญ้า : OFF"
        TreeButton.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
        
        for obj, state in pairs(originalTreeStates) do
            if obj and obj.Parent then
                obj.Transparency = state.Transparency
                obj.CanCollide = state.CanCollide
            end
        end
        originalTreeStates = {}
    end
end

-- ฟังก์ชัน Boost FPS
local function ToggleFPS()
    fpsBoosted = not fpsBoosted
    if fpsBoosted then
        FpsButton.Text = "🚀 Boost FPS : ON"
        FpsButton.BackgroundColor3 = Color3.fromRGB(85, 255, 85)
        
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        
        for _, obj in pairs(game:GetDescendants()) do
            if obj:IsA("BasePart") then
                obj.Material = Enum.Material.SmoothPlastic
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") then
                obj.Enabled = false
            end
        end
        
        eventConnection = game.DescendantAdded:Connect(function(obj)
            if fpsBoosted then
                task.wait()
                if obj:IsA("BasePart") then
                    obj.Material = Enum.Material.SmoothPlastic
                elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
                    obj.Enabled = false
                end
            end
        end)
    else
        FpsButton.Text = "🚀 Boost FPS : OFF"
        FpsButton.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
        
        Lighting.GlobalShadows = true
        if eventConnection then eventConnection:Disconnect() end
        
        for _, obj in pairs(game:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") then
                obj.Enabled = true
            end
        end
    end
end

TreeButton.MouseButton1Click:Connect(ToggleTrees)
FpsButton.MouseButton1Click:Connect(ToggleFPS)

-- ================= ออโต้รันตอนเปิดสคริปต์ (Auto Enable) =================
task.spawn(function()
    if not treesHidden then ToggleTrees() end
    if not fpsBoosted then ToggleFPS() end
end)
