-- CameraController Script
-- Controla a câmera top-down 3D
-- INSTRUÇÕES: Colocar em StarterPlayer > StarterPlayerScripts

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

print("📷 Initializing Camera Controller...")

-- ========================================
-- CONFIGURAÇÕES
-- ========================================

local CAMERA_HEIGHT = 50 -- Altura da câmera (studs)
local CAMERA_ANGLE = 45 -- Ângulo de inclinação (graus)
local ZOOM_MIN = 20
local ZOOM_MAX = 100
local ZOOM_SPEED = 5
local SMOOTH_SPEED = 0.1 -- Suavização da câmera (0 = instantâneo, 1 = muito suave)

-- Estado
local currentZoom = CAMERA_HEIGHT
local targetZoom = CAMERA_HEIGHT

-- ========================================
-- CONFIGURAR CÂMERA
-- ========================================

camera.CameraType = Enum.CameraType.Scriptable

-- ========================================
-- FUNÇÕES
-- ========================================

-- Calcular posição da câmera
local function calculateCameraPosition(characterPosition)
	-- Converter ângulo para radianos
	local angleRad = math.rad(CAMERA_ANGLE)
	
	-- Calcular offset baseado no zoom e ângulo
	local horizontalOffset = currentZoom * math.sin(angleRad)
	local verticalOffset = currentZoom * math.cos(angleRad)
	
	-- Offset da câmera (atrás e acima do personagem)
	local offset = Vector3.new(0, verticalOffset, horizontalOffset)
	
	-- Posição final da câmera
	local cameraPosition = characterPosition + offset
	
	return cameraPosition
end

-- Atualizar câmera
local function updateCamera()
	local character = player.Character
	if not character then return end
	
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return end
	
	-- Suavizar zoom
	currentZoom = currentZoom + (targetZoom - currentZoom) * SMOOTH_SPEED
	
	-- Posição do personagem
	local charPos = rootPart.Position
	
	-- Calcular posição da câmera
	local cameraPos = calculateCameraPosition(charPos)
	
	-- Posicionar câmera olhando para o personagem
	camera.CFrame = CFrame.new(cameraPos, charPos)
end

-- ========================================
-- CONTROLES
-- ========================================

-- Zoom com scroll do mouse
UserInputService.InputChanged:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	if input.UserInputType == Enum.UserInputType.MouseWheel then
		-- Ajustar zoom
		targetZoom = math.clamp(targetZoom - input.Position.Z * ZOOM_SPEED, ZOOM_MIN, ZOOM_MAX)
	end
end)

-- Teclas de atalho para zoom (opcional)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	-- Zoom in com tecla +
	if input.KeyCode == Enum.KeyCode.Equals or input.KeyCode == Enum.KeyCode.Plus then
		targetZoom = math.clamp(targetZoom - 5, ZOOM_MIN, ZOOM_MAX)
	end
	
	-- Zoom out com tecla -
	if input.KeyCode == Enum.KeyCode.Minus then
		targetZoom = math.clamp(targetZoom + 5, ZOOM_MIN, ZOOM_MAX)
	end
	
	-- Reset zoom com tecla R
	if input.KeyCode == Enum.KeyCode.R then
		targetZoom = CAMERA_HEIGHT
	end
end)

-- ========================================
-- LOOP DE ATUALIZAÇÃO
-- ========================================

RunService.RenderStepped:Connect(updateCamera)

print("✅ Camera Controller initialized")
print("Controls:")
print("  - Mouse Wheel: Zoom in/out")
print("  - +/-: Zoom in/out")
print("  - R: Reset zoom")
