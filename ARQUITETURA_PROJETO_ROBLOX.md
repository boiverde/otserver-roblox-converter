# 🎮 ARQUITETURA DO PROJETO: OTServer → Roblox 3D Top-Down

## 📋 RESUMO EXECUTIVO

Este documento descreve a arquitetura completa do pipeline automático para converter o mapa do OTServer 15.x em um mundo 3D top-down no Roblox, **sem usar assets oficiais do Tibia**.

---

## 🗂️ ESTRUTURA DO PROJETO

```
OTSERVER_15X/
├── server/
│   ├── data/
│   │   ├── items/items.xml          # Definições de itens do OT
│   │   └── world/world.otbm         # Arquivo de mapa binário
│   ├── data-otservbr-global/
│   │   ├── npc/                     # NPCs do servidor
│   │   ├── monster/                 # Monstros e spawns
│   │   └── world/world.otbm         # Mapa principal (localização real)
│   └── export_map.py                # ✅ Script de exportação (FASE 1)
├── export/                          # ✅ Arquivos JSON exportados
│   ├── tiles.json                   # Grid de tiles (x,y,z + tipo)
│   ├── spawns.json                  # Spawns de monstros
│   └── npcs.json                    # Posições de NPCs
└── roblox/                          # 🔜 FASE 2 - Scripts Roblox
    ├── WorldGenerator.lua           # Gerador de mundo
    ├── TileMapper.lua               # Conversor de tiles
    └── CameraController.lua         # Câmera top-down
```

---

## 📍 FASE 1: EXTRAÇÃO DO MAPA (✅ CONCLUÍDA)

### 1.1 Localização do Mapa

**Arquivo principal:** `C:\Users\merca\.gemini\antigravity\scratch\OTSERVER_15X\server\data-otservbr-global\world\world.otbm`

**Formato:** OTBM (OTServ Binary Map) - formato binário proprietário usado por servidores OT.

### 1.2 Estrutura do Arquivo OTBM

O arquivo `.otbm` contém:

```
OTBM Structure:
├── Header (4 bytes: 0x00 0x00 0x00 0x00)
├── Root Node (0xFE)
│   ├── Version Info
│   ├── Map Dimensions (width, height)
│   └── Version Numbers
├── Map Data Node (0xFE)
│   ├── Description
│   ├── Spawn File
│   ├── House File
│   └── Tile Areas
│       ├── Tile Area (x, y, z base)
│       │   ├── Tile (dx, dy)
│       │   │   ├── Ground Item (ID)
│       │   │   └── Items (walls, objects)
│       │   └── ...
│       └── ...
└── Node End (0xFF)
```

**Escape Character:** `0xFD` - usado para escapar bytes de controle (`0xFE`, `0xFF`)

### 1.3 Parser OTBM (`export_map.py`)

#### **Componentes Principais:**

1. **ItemsLoader**
   - Carrega `items.xml` para classificar itens
   - Identifica tipo: `floor`, `wall`, `door`, `object`
   - Determina se é bloqueante (walkable vs blocking)

2. **OTBMParser**
   - Lê arquivo binário `.otbm`
   - Remove escape characters (`0xFD`)
   - Parseia estrutura de nós recursivamente
   - Extrai coordenadas (x, y, z) e IDs de itens

3. **Classificação de Tiles**
   - **Floor:** Chão, grama, pedra (walkable)
   - **Wall:** Paredes, muros (blocking)
   - **Door:** Portas (blocking, mas interativo)
   - **Object:** Decoração (filtrado se não bloqueante)

#### **Algoritmo de Parsing:**

```python
1. Ler arquivo binário completo
2. Remover escape characters (0xFD)
3. Processar nós recursivamente:
   - ROOTV1: Ler versão e dimensões
   - MAP_DATA: Ler atributos do mapa
   - TILE_AREA: Ler coordenadas base (x, y, z)
   - TILE: Ler offset (dx, dy) e itens
   - ITEM: Ler ID do item e adicionar ao tile
4. Para cada item:
   - Consultar items.xml para propriedades
   - Classificar tipo (floor/wall/object)
   - Determinar se é bloqueante
5. Salvar tiles em JSON
```

### 1.4 Arquivos Exportados

#### **tiles.json**
```json
[
  {
    "x": 1024,
    "y": 1024,
    "z": 7,
    "t": "floor",
    "id": 406
  },
  {
    "x": 1024,
    "y": 1024,
    "z": 7,
    "t": "wall",
    "id": 1285
  }
]
```

**Campos:**
- `x, y, z`: Coordenadas absolutas no grid do OT
- `t`: Tipo (`floor`, `wall`, `door`, `object`)
- `id`: ID do item no OT (para referência, não usado no Roblox)

**Tamanho atual:** ~14 KB (tiles filtrados - apenas estruturais)

#### **spawns.json**
```json
[
  {
    "name": "Dragon",
    "x": 1050,
    "y": 1050,
    "z": 7,
    "centerx": 1050,
    "centery": 1050,
    "centerz": 7,
    "radius": 5
  }
]
```

**Campos:**
- `name`: Nome do monstro
- `x, y, z`: Posição do spawn
- `centerx, centery, centerz`: Centro da área de spawn
- `radius`: Raio de spawn

**Tamanho atual:** ~4.9 MB (muitos spawns)

#### **npcs.json**
```json
[
  {
    "name": "Rashid",
    "x": 1025,
    "y": 1025,
    "z": 7
  }
]
```

**Campos:**
- `name`: Nome do NPC
- `x, y, z`: Posição fixa do NPC

**Tamanho atual:** ~56 KB

---

## 🎯 FASE 2: GERAÇÃO NO ROBLOX (🔜 PRÓXIMA ETAPA)

### 2.1 Padrão de Conversão

#### **Grid Mapping:**
```
1 tile OT = 1 tile lógico Roblox
Tamanho físico: 4x4 studs (recomendado)

Coordenadas:
OT (x, y, z) → Roblox (X, Y, Z)
X_roblox = x_ot * 4
Z_roblox = y_ot * 4  (Y do OT vira Z no Roblox)
Y_roblox = z_ot * 4  (Z do OT vira Y no Roblox - altura)
```

#### **Z-Levels (Andares):**

**Opção 1: Camadas Separadas (Recomendado)**
- Cada Z-level = área separada
- Conectadas por teleports
- Melhor performance (menos objetos carregados)

**Opção 2: Mundo Vertical**
- Z-levels empilhados verticalmente
- Espaçamento: 20 studs entre andares
- Mais fiel ao original, mas pode ter problemas de câmera

### 2.2 Mapeamento de Tiles

#### **Tiles → Roblox Parts:**

| Tipo OT | Roblox Part | Material | Cor | Propriedades |
|---------|-------------|----------|-----|--------------|
| `floor` | Part (0.5 altura) | Grass/Slate/Wood | Verde/Cinza/Marrom | CanCollide=false |
| `wall` | Part (8 altura) | Brick/Concrete | Cinza/Marrom | CanCollide=true |
| `door` | Part (8 altura) | Wood | Marrom | ClickDetector |
| `water` | Part (0.5 altura) | Water | Azul | CanCollide=false |

**⚠️ IMPORTANTE:** Usar apenas materiais genéricos do Roblox, **SEM sprites do Tibia**.

### 2.3 Sistema de Geração

#### **WorldGenerator.lua** (Script Principal)

```lua
-- Pseudocódigo
local HttpService = game:GetService("HttpService")

-- 1. Carregar JSONs
local tiles = HttpService:JSONDecode(tilesJSON)
local spawns = HttpService:JSONDecode(spawnsJSON)
local npcs = HttpService:JSONDecode(npcsJSON)

-- 2. Criar container para o mundo
local WorldContainer = Instance.new("Folder")
WorldContainer.Name = "OTWorld"
WorldContainer.Parent = workspace

-- 3. Gerar tiles
for _, tile in ipairs(tiles) do
    local part = Instance.new("Part")
    part.Size = Vector3.new(4, getTileHeight(tile.t), 4)
    part.Position = Vector3.new(tile.x * 4, tile.z * 4, tile.y * 4)
    part.Material = getTileMaterial(tile.t)
    part.Color = getTileColor(tile.t)
    part.Anchored = true
    part.CanCollide = (tile.t == "wall" or tile.t == "door")
    part.Parent = WorldContainer
end

-- 4. Criar marcadores de spawn
for _, spawn in ipairs(spawns) do
    local marker = Instance.new("Part")
    marker.Size = Vector3.new(2, 0.5, 2)
    marker.Position = Vector3.new(spawn.x * 4, spawn.z * 4, spawn.y * 4)
    marker.Transparency = 0.7
    marker.Color = Color3.new(1, 0, 0) -- Vermelho
    marker.Name = "Spawn_" .. spawn.name
    marker.Anchored = true
    marker.CanCollide = false
    marker.Parent = WorldContainer
end

-- 5. Criar NPCs
for _, npc in ipairs(npcs) do
    local npcMarker = Instance.new("Part")
    npcMarker.Size = Vector3.new(2, 4, 2)
    npcMarker.Position = Vector3.new(npc.x * 4, npc.z * 4, npc.y * 4)
    npcMarker.Color = Color3.new(0, 1, 0) -- Verde
    npcMarker.Name = "NPC_" .. npc.name
    npcMarker.Anchored = true
    npcMarker.Parent = WorldContainer
end
```

#### **TileMapper.lua** (Utilitário)

```lua
local TileMapper = {}

function TileMapper.getTileHeight(tileType)
    if tileType == "floor" then return 0.5
    elseif tileType == "wall" then return 8
    elseif tileType == "door" then return 8
    else return 1 end
end

function TileMapper.getTileMaterial(tileType)
    if tileType == "floor" then return Enum.Material.Grass
    elseif tileType == "wall" then return Enum.Material.Brick
    elseif tileType == "door" then return Enum.Material.Wood
    else return Enum.Material.Plastic end
end

function TileMapper.getTileColor(tileType)
    if tileType == "floor" then return Color3.fromRGB(34, 139, 34)
    elseif tileType == "wall" then return Color3.fromRGB(105, 105, 105)
    elseif tileType == "door" then return Color3.fromRGB(139, 69, 19)
    else return Color3.fromRGB(200, 200, 200) end
end

return TileMapper
```

#### **CameraController.lua** (Câmera Top-Down)

```lua
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

camera.CameraType = Enum.CameraType.Scriptable

RunService.RenderStepped:Connect(function()
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        local rootPart = character.HumanoidRootPart
        local offset = Vector3.new(0, 50, 0) -- 50 studs acima
        camera.CFrame = CFrame.new(rootPart.Position + offset, rootPart.Position)
    end
end)
```

### 2.4 Movimento e Colisão

#### **Movimento:**
- **Livre:** Jogador se move livremente com WASD
- **Snap invisível:** Posição é "snapped" ao grid para alinhamento visual
- **Velocidade:** 16 studs/s (padrão Roblox)

#### **Colisão:**
- **Baseada em tile:** Usar `CanCollide` nos Parts
- **Não física realista:** Movimento arcade, sem física complexa
- **Detecção:** Raycasting para interações (portas, NPCs)

### 2.5 Otimização para 50 Players

#### **Streaming Enabled:**
```lua
workspace.StreamingEnabled = true
workspace.StreamingMinRadius = 128
workspace.StreamingTargetRadius = 256
```

#### **Level of Detail (LOD):**
- Tiles distantes: Reduzir detalhes ou ocultar
- Usar `Region3` para carregar apenas área próxima

#### **Instancing:**
- Usar `Clone()` para tiles repetidos
- Agrupar tiles em `Model` para reduzir hierarquia

---

## 📊 ESPECIFICAÇÃO DOS ARQUIVOS JSON

### tiles.json
```typescript
interface Tile {
    x: number;      // Coordenada X absoluta (OT)
    y: number;      // Coordenada Y absoluta (OT)
    z: number;      // Coordenada Z (andar)
    t: string;      // Tipo: "floor" | "wall" | "door" | "object"
    id: number;     // ID do item no OT (referência)
}
```

### spawns.json
```typescript
interface Spawn {
    name: string;   // Nome do monstro
    x: number;      // Coordenada X do spawn
    y: number;      // Coordenada Y do spawn
    z: number;      // Coordenada Z (andar)
    centerx: number; // Centro X da área de spawn
    centery: number; // Centro Y da área de spawn
    centerz: number; // Centro Z da área de spawn
    radius: number;  // Raio de spawn
}
```

### npcs.json
```typescript
interface NPC {
    name: string;   // Nome do NPC
    x: number;      // Coordenada X fixa
    y: number;      // Coordenada Y fixa
    z: number;      // Coordenada Z (andar)
}
```

---

## 🚀 PRÓXIMOS PASSOS TÉCNICOS

### ✅ Fase 1 - Concluída
- [x] Localizar arquivo de mapa (world.otbm)
- [x] Criar parser OTBM
- [x] Exportar tiles.json
- [x] Exportar spawns.json
- [x] Exportar npcs.json

### 🔜 Fase 2 - Geração no Roblox

#### **Etapa 2.1: Setup Inicial**
- [ ] Criar projeto no Roblox Studio
- [ ] Configurar HttpService para carregar JSONs
- [ ] Criar estrutura de pastas (ReplicatedStorage, ServerScriptService)

#### **Etapa 2.2: Gerador de Mundo**
- [ ] Implementar `WorldGenerator.lua`
- [ ] Implementar `TileMapper.lua`
- [ ] Testar geração de pequena área (100x100 tiles)
- [ ] Otimizar para mapa completo

#### **Etapa 2.3: Câmera e Movimento**
- [ ] Implementar `CameraController.lua`
- [ ] Configurar movimento top-down
- [ ] Adicionar snap ao grid (opcional)

#### **Etapa 2.4: Spawns e NPCs**
- [ ] Criar marcadores visuais de spawn
- [ ] Criar marcadores de NPC
- [ ] (Futuro) Implementar sistema de spawn de mobs

#### **Etapa 2.5: Otimização**
- [ ] Habilitar Streaming
- [ ] Implementar LOD
- [ ] Testar com 50 players simultâneos

#### **Etapa 2.6: Polimento**
- [ ] Adicionar iluminação
- [ ] Adicionar efeitos visuais (partículas, etc.)
- [ ] Criar UI básica

---

## 🛠️ FERRAMENTAS E TECNOLOGIAS

### Fase 1 (Exportação)
- **Python 3.x:** Linguagem de script
- **xml.etree.ElementTree:** Parser XML
- **struct:** Leitura de dados binários
- **json:** Serialização de dados

### Fase 2 (Roblox)
- **Roblox Studio:** IDE de desenvolvimento
- **Lua 5.1:** Linguagem de script do Roblox
- **HttpService:** Carregamento de JSONs
- **RunService:** Loop de renderização

---

## ⚠️ CONSIDERAÇÕES IMPORTANTES

### Legal e Ético
- ✅ **Usar apenas layout e lógica** do OTServer
- ❌ **NÃO usar sprites, tiles, músicas ou assets oficiais do Tibia**
- ✅ **Criar assets genéricos/originais no Roblox**

### Técnico
- **Tamanho do mapa:** Verificar dimensões reais do world.otbm
- **Performance:** Mapa muito grande pode precisar de chunking
- **Memória:** JSONs grandes podem precisar de streaming

### Gameplay
- **Câmera fixa:** Top-down sem rotação livre
- **Movimento:** Grid-based com movimento livre
- **Multiplayer:** Até 50 players por servidor

---

## 📞 SUPORTE E MANUTENÇÃO

### Logs e Debug
- `export_map.py` usa logging para debug
- Verificar `tiles.json` para validar exportação
- Usar Roblox Studio Output para debug Lua

### Atualizações do Mapa
1. Modificar `world.otbm` no OTServer
2. Executar `python export_map.py`
3. Substituir JSONs no Roblox
4. Re-executar `WorldGenerator.lua`

---

## 📈 ROADMAP FUTURO

### Fase 3 - Gameplay (Futuro)
- [ ] Sistema de combate
- [ ] Sistema de spawn dinâmico
- [ ] NPCs interativos
- [ ] Sistema de quests
- [ ] Inventário e itens

### Fase 4 - Social (Futuro)
- [ ] Sistema de party
- [ ] Chat global
- [ ] Leaderboards
- [ ] Sistema de guilds

---

## 📝 CONCLUSÃO

Este projeto demonstra um pipeline completo e automatizado para converter mapas de OTServer em mundos 3D no Roblox, respeitando propriedade intelectual e criando uma experiência única e original.

**Status Atual:** Fase 1 concluída ✅ | Fase 2 pronta para iniciar 🚀

**Próximo Passo:** Implementar `WorldGenerator.lua` no Roblox Studio
