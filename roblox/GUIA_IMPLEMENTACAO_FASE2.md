# 🎮 GUIA DE IMPLEMENTAÇÃO - FASE 2: ROBLOX

## 📋 PRÉ-REQUISITOS

- ✅ Fase 1 concluída (JSONs exportados)
- Roblox Studio instalado
- Conhecimento básico de Lua
- Acesso aos arquivos JSON exportados

---

## 🚀 PASSO A PASSO

### ETAPA 1: Setup do Projeto Roblox

#### 1.1 Criar Novo Projeto
1. Abrir Roblox Studio
2. Criar novo projeto: **Baseplate** (template vazio)
3. Salvar como: `OTServer_Roblox.rbxl`

#### 1.2 Configurar Serviços
```lua
-- ServerScriptService > ConfigureServices
local HttpService = game:GetService("HttpService")
HttpService.HttpEnabled = true -- Permitir requisições HTTP

local workspace = game:GetService("Workspace")
workspace.StreamingEnabled = true
workspace.StreamingMinRadius = 128
workspace.StreamingTargetRadius = 256
```

#### 1.3 Estrutura de Pastas
```
ReplicatedStorage/
├── Modules/
│   ├── TileMapper
│   └── JSONLoader
ServerScriptService/
├── WorldGenerator
└── ConfigureServices
StarterPlayer/
└── StarterPlayerScripts/
    └── CameraController
Workspace/
└── OTWorld/ (será criado pelo script)
```

---

### ETAPA 2: Carregar JSONs

#### 2.1 Hospedar JSONs

**Opção A: GitHub (Recomendado)**
1. Criar repositório público no GitHub
2. Upload dos arquivos JSON
3. Usar raw URLs:
   ```
   https://raw.githubusercontent.com/SEU_USUARIO/SEU_REPO/main/tiles.json
   https://raw.githubusercontent.com/SEU_USUARIO/SEU_REPO/main/spawns.json
   https://raw.githubusercontent.com/SEU_USUARIO/SEU_REPO/main/npcs.json
   ```

**Opção B: Pastebin**
1. Criar paste com conteúdo do JSON
2. Usar raw URL

**Opção C: Embutir no Script (Para testes pequenos)**
```lua
local tilesJSON = [[
[
  {"x": 1024, "y": 1024, "z": 7, "t": "floor", "id": 406},
  ...
]
]]
```

#### 2.2 Módulo JSONLoader

```lua
-- ReplicatedStorage > Modules > JSONLoader
local HttpService = game:GetService("HttpService")

local JSONLoader = {}

function JSONLoader.loadFromURL(url)
    local success, result = pcall(function()
        return HttpService:GetAsync(url)
    end)
    
    if success then
        return HttpService:JSONDecode(result)
    else
        warn("Failed to load JSON from " .. url .. ": " .. tostring(result))
        return nil
    end
end

function JSONLoader.loadFromString(jsonString)
    local success, result = pcall(function()
        return HttpService:JSONDecode(jsonString)
    end)
    
    if success then
        return result
    else
        warn("Failed to decode JSON: " .. tostring(result))
        return nil
    end
end

return JSONLoader
```

---

### ETAPA 3: Módulo TileMapper

```lua
-- ReplicatedStorage > Modules > TileMapper
local TileMapper = {}

-- Configurações de conversão
TileMapper.TILE_SIZE = 4 -- studs por tile

-- Converter coordenadas OT para Roblox
function TileMapper.otToRoblox(x, y, z)
    return Vector3.new(
        x * TileMapper.TILE_SIZE,
        z * TileMapper.TILE_SIZE, -- Z do OT vira Y (altura) no Roblox
        y * TileMapper.TILE_SIZE  -- Y do OT vira Z no Roblox
    )
end

-- Obter altura do tile baseado no tipo
function TileMapper.getTileHeight(tileType)
    local heights = {
        floor = 0.5,
        wall = 8,
        door = 8,
        water = 0.5,
        object = 2
    }
    return heights[tileType] or 1
end

-- Obter material do tile
function TileMapper.getTileMaterial(tileType)
    local materials = {
        floor = Enum.Material.Grass,
        wall = Enum.Material.Brick,
        door = Enum.Material.Wood,
        water = Enum.Material.Water,
        object = Enum.Material.Plastic
    }
    return materials[tileType] or Enum.Material.Plastic
end

-- Obter cor do tile
function TileMapper.getTileColor(tileType)
    local colors = {
        floor = Color3.fromRGB(34, 139, 34),   -- Verde grama
        wall = Color3.fromRGB(105, 105, 105),  -- Cinza
        door = Color3.fromRGB(139, 69, 19),    -- Marrom
        water = Color3.fromRGB(30, 144, 255),  -- Azul
        object = Color3.fromRGB(200, 200, 200) -- Cinza claro
    }
    return colors[tileType] or Color3.fromRGB(255, 255, 255)
end

-- Verificar se tile é colidível
function TileMapper.isColliding(tileType)
    return tileType == "wall" or tileType == "door"
end

return TileMapper
```

---

### ETAPA 4: Gerador de Mundo

```lua
-- ServerScriptService > WorldGenerator
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local JSONLoader = require(ReplicatedStorage.Modules.JSONLoader)
local TileMapper = require(ReplicatedStorage.Modules.TileMapper)

print("🌍 Starting World Generator...")

-- URLs dos JSONs (SUBSTITUIR COM SUAS URLs)
local TILES_URL = "https://raw.githubusercontent.com/SEU_USUARIO/SEU_REPO/main/tiles.json"
local SPAWNS_URL = "https://raw.githubusercontent.com/SEU_USUARIO/SEU_REPO/main/spawns.json"
local NPCS_URL = "https://raw.githubusercontent.com/SEU_USUARIO/SEU_REPO/main/npcs.json"

-- Criar container do mundo
local worldContainer = Instance.new("Folder")
worldContainer.Name = "OTWorld"
worldContainer.Parent = workspace

-- Função para criar tile
local function createTile(tileData)
    local part = Instance.new("Part")
    
    -- Tamanho
    local height = TileMapper.getTileHeight(tileData.t)
    part.Size = Vector3.new(TileMapper.TILE_SIZE, height, TileMapper.TILE_SIZE)
    
    -- Posição
    local position = TileMapper.otToRoblox(tileData.x, tileData.y, tileData.z)
    -- Ajustar Y para que o tile fique no chão
    position = position + Vector3.new(0, height / 2, 0)
    part.Position = position
    
    -- Propriedades visuais
    part.Material = TileMapper.getTileMaterial(tileData.t)
    part.Color = TileMapper.getTileColor(tileData.t)
    
    -- Propriedades físicas
    part.Anchored = true
    part.CanCollide = TileMapper.isColliding(tileData.t)
    
    -- Nome
    part.Name = string.format("Tile_%s_%d_%d_%d", tileData.t, tileData.x, tileData.y, tileData.z)
    
    part.Parent = worldContainer
    return part
end

-- Função para criar marcador de spawn
local function createSpawnMarker(spawnData)
    local marker = Instance.new("Part")
    marker.Size = Vector3.new(2, 0.5, 2)
    
    local position = TileMapper.otToRoblox(spawnData.x, spawnData.y, spawnData.z)
    position = position + Vector3.new(0, 0.25, 0)
    marker.Position = position
    
    marker.Material = Enum.Material.Neon
    marker.Color = Color3.fromRGB(255, 0, 0) -- Vermelho
    marker.Transparency = 0.5
    marker.Anchored = true
    marker.CanCollide = false
    marker.Name = "Spawn_" .. spawnData.name
    
    -- Adicionar label
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 100, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.Parent = marker
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = spawnData.name
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextScaled = true
    label.Parent = billboard
    
    marker.Parent = worldContainer
    return marker
end

-- Função para criar marcador de NPC
local function createNPCMarker(npcData)
    local marker = Instance.new("Part")
    marker.Size = Vector3.new(2, 4, 2)
    
    local position = TileMapper.otToRoblox(npcData.x, npcData.y, npcData.z)
    position = position + Vector3.new(0, 2, 0)
    marker.Position = position
    
    marker.Material = Enum.Material.Neon
    marker.Color = Color3.fromRGB(0, 255, 0) -- Verde
    marker.Transparency = 0.3
    marker.Anchored = true
    marker.CanCollide = false
    marker.Name = "NPC_" .. npcData.name
    
    -- Adicionar label
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 100, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.Parent = marker
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = npcData.name
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextScaled = true
    label.Parent = billboard
    
    marker.Parent = worldContainer
    return marker
end

-- Carregar e gerar tiles
print("📦 Loading tiles...")
local tiles = JSONLoader.loadFromURL(TILES_URL)
if tiles then
    print("✅ Loaded " .. #tiles .. " tiles")
    print("🔨 Generating tiles...")
    
    local tileCount = 0
    for _, tile in ipairs(tiles) do
        createTile(tile)
        tileCount = tileCount + 1
        
        -- Progress update a cada 100 tiles
        if tileCount % 100 == 0 then
            print("  Generated " .. tileCount .. " tiles...")
            wait() -- Yield para evitar timeout
        end
    end
    
    print("✅ Generated " .. tileCount .. " tiles")
else
    warn("❌ Failed to load tiles")
end

-- Carregar e gerar spawns
print("📦 Loading spawns...")
local spawns = JSONLoader.loadFromURL(SPAWNS_URL)
if spawns then
    print("✅ Loaded " .. #spawns .. " spawns")
    print("🔨 Generating spawn markers...")
    
    local spawnCount = 0
    for _, spawn in ipairs(spawns) do
        createSpawnMarker(spawn)
        spawnCount = spawnCount + 1
        
        if spawnCount % 100 == 0 then
            print("  Generated " .. spawnCount .. " spawns...")
            wait()
        end
    end
    
    print("✅ Generated " .. spawnCount .. " spawn markers")
else
    warn("❌ Failed to load spawns")
end

-- Carregar e gerar NPCs
print("📦 Loading NPCs...")
local npcs = JSONLoader.loadFromURL(NPCS_URL)
if npcs then
    print("✅ Loaded " .. #npcs .. " NPCs")
    print("🔨 Generating NPC markers...")
    
    local npcCount = 0
    for _, npc in ipairs(npcs) do
        createNPCMarker(npc)
        npcCount = npcCount + 1
    end
    
    print("✅ Generated " .. npcCount .. " NPC markers")
else
    warn("❌ Failed to load NPCs")
end

print("🎉 World generation complete!")
```

---

### ETAPA 5: Câmera Top-Down

```lua
-- StarterPlayer > StarterPlayerScripts > CameraController
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Configurações
local CAMERA_HEIGHT = 50 -- Altura da câmera
local CAMERA_ANGLE = 60 -- Ângulo de inclinação (graus)
local ZOOM_MIN = 30
local ZOOM_MAX = 100
local ZOOM_SPEED = 5

local currentZoom = CAMERA_HEIGHT

-- Configurar câmera
camera.CameraType = Enum.CameraType.Scriptable

-- Função para atualizar câmera
local function updateCamera()
    local character = player.Character
    if not character then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    -- Posição do personagem
    local charPos = rootPart.Position
    
    -- Calcular offset da câmera
    local angleRad = math.rad(CAMERA_ANGLE)
    local offset = Vector3.new(0, currentZoom, currentZoom * math.tan(angleRad))
    
    -- Posicionar câmera
    camera.CFrame = CFrame.new(charPos + offset, charPos)
end

-- Loop de atualização
RunService.RenderStepped:Connect(updateCamera)

-- Controle de zoom (scroll do mouse)
UserInputService.InputChanged:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.UserInputType == Enum.UserInputType.MouseWheel then
        currentZoom = math.clamp(currentZoom - input.Position.Z * ZOOM_SPEED, ZOOM_MIN, ZOOM_MAX)
    end
end)

print("📷 Camera controller initialized")
```

---

### ETAPA 6: Configurar Movimento

```lua
-- StarterPlayer > StarterCharacterScripts > MovementController
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Configurações de movimento
humanoid.WalkSpeed = 16 -- Velocidade padrão
humanoid.JumpPower = 0 -- Desabilitar pulo (opcional)

print("🏃 Movement controller initialized")
```

---

## 🧪 TESTES

### Teste 1: Carregar JSONs
1. Executar `WorldGenerator`
2. Verificar Output para mensagens de sucesso
3. Confirmar que `OTWorld` foi criado no Workspace

### Teste 2: Visualizar Mundo
1. Mover câmera no Workspace
2. Verificar se tiles foram criados
3. Verificar cores e materiais

### Teste 3: Câmera Top-Down
1. Clicar em "Play"
2. Verificar se câmera está posicionada acima do personagem
3. Testar zoom com scroll do mouse

### Teste 4: Movimento
1. Usar WASD para mover
2. Verificar colisão com paredes
3. Verificar que personagem não colide com chão

---

## 🐛 TROUBLESHOOTING

### Problema: "HttpService is not allowed"
**Solução:** Habilitar HttpService nas configurações do jogo
```lua
game:GetService("HttpService").HttpEnabled = true
```

### Problema: "Failed to load JSON"
**Solução:** 
- Verificar se URL está correta
- Verificar se JSON está válido (usar jsonlint.com)
- Verificar se repositório GitHub é público

### Problema: Tiles não aparecem
**Solução:**
- Verificar se `OTWorld` está no Workspace
- Verificar coordenadas (podem estar muito longe)
- Ajustar câmera para visualizar área correta

### Problema: Performance ruim
**Solução:**
- Reduzir número de tiles (filtrar por área)
- Habilitar Streaming
- Usar LOD (Level of Detail)

---

## 📊 OTIMIZAÇÕES

### Otimização 1: Chunking
Dividir mapa em chunks de 100x100 tiles e carregar apenas chunks próximos ao jogador.

### Otimização 2: Instancing
Usar `Clone()` para tiles repetidos em vez de criar novos Parts.

### Otimização 3: Culling
Ocultar tiles que não estão visíveis pela câmera.

---

## 🎯 PRÓXIMOS PASSOS

1. ✅ Implementar geração básica de mundo
2. ✅ Implementar câmera top-down
3. 🔜 Adicionar iluminação
4. 🔜 Adicionar efeitos visuais
5. 🔜 Implementar sistema de spawn de mobs
6. 🔜 Criar UI básica

---

## 📝 NOTAS FINAIS

- **Performance:** Para mapas grandes, considere carregar apenas área visível
- **Assets:** Use apenas materiais genéricos do Roblox
- **Multiplayer:** Teste com múltiplos jogadores para verificar sincronização
- **Iteração:** Comece pequeno (100x100 tiles) e expanda gradualmente

**Boa sorte com a implementação! 🚀**
