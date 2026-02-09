-- WorldGenerator Script
-- Gera o mundo do OTServer no Roblox a partir de arquivos JSON
-- INSTRUÇÕES: 
-- 1. Colocar este script em ServerScriptService
-- 2. Colocar TileMapper e JSONLoader em ReplicatedStorage > Modules
-- 3. Substituir as URLs abaixo pelos seus arquivos JSON
-- 4. Executar o jogo

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local JSONLoader = require(ReplicatedStorage.Modules.JSONLoader)
local TileMapper = require(ReplicatedStorage.Modules.TileMapper)

print("=" .. string.rep("=", 50))
print("🌍 OTServer World Generator")
print("=" .. string.rep("=", 50))

-- ========================================
-- CONFIGURAÇÕES
-- ========================================

-- SUBSTITUIR COM SUAS URLs OU USAR DADOS EMBUTIDOS
local USE_URLS = true -- Mudar para true para usar URLs

-- URLs dos JSONs (se USE_URLS = true)
local TILES_URL = "https://raw.githubusercontent.com/boiverde/otserver-roblox-converter/main/export/tiles.json"
local SPAWNS_URL = "https://raw.githubusercontent.com/boiverde/otserver-roblox-converter/main/export/spawns.json"
local NPCS_URL = "https://raw.githubusercontent.com/boiverde/otserver-roblox-converter/main/export/npcs.json"

-- Dados embutidos para teste (se USE_URLS = false)
local TILES_JSON = [[
[
  {"x": 1000, "y": 1000, "z": 7, "t": "floor", "id": 406},
  {"x": 1001, "y": 1000, "z": 7, "t": "floor", "id": 406},
  {"x": 1002, "y": 1000, "z": 7, "t": "floor", "id": 406},
  {"x": 1000, "y": 1001, "z": 7, "t": "floor", "id": 406},
  {"x": 1001, "y": 1001, "z": 7, "t": "floor", "id": 406},
  {"x": 1002, "y": 1001, "z": 7, "t": "floor", "id": 406},
  {"x": 1000, "y": 1002, "z": 7, "t": "wall", "id": 1285},
  {"x": 1001, "y": 1002, "z": 7, "t": "wall", "id": 1285},
  {"x": 1002, "y": 1002, "z": 7, "t": "wall", "id": 1285}
]
]]

local SPAWNS_JSON = [[
[
  {"name": "Dragon", "x": 1001, "y": 1001, "z": 7, "centerx": 1001, "centery": 1001, "centerz": 7, "radius": 5}
]
]]

local NPCS_JSON = [[
[
  {"name": "Rashid", "x": 1000, "y": 1000, "z": 7}
]
]]

-- Configurações de geração
local BATCH_SIZE = 100 -- Número de tiles a gerar antes de yield
local GENERATE_TILES = true
local GENERATE_SPAWNS = true
local GENERATE_NPCS = true

-- ========================================
-- SETUP
-- ========================================

-- Criar container do mundo
local worldContainer = workspace:FindFirstChild("OTWorld")
if worldContainer then
	print("⚠️ OTWorld already exists, clearing...")
	worldContainer:ClearAllChildren()
else
	worldContainer = Instance.new("Folder")
	worldContainer.Name = "OTWorld"
	worldContainer.Parent = workspace
end

-- ========================================
-- FUNÇÕES DE GERAÇÃO
-- ========================================

-- Criar tile
local function createTile(tileData)
	local part = TileMapper.createTilePart(tileData)
	part.Parent = worldContainer
	return part
end

-- Criar marcador de spawn
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
	billboard.AlwaysOnTop = true
	billboard.Parent = marker
	
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = spawnData.name
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextScaled = true
	label.Font = Enum.Font.SourceSansBold
	label.Parent = billboard
	
	marker.Parent = worldContainer
	return marker
end

-- Criar marcador de NPC
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
	billboard.AlwaysOnTop = true
	billboard.Parent = marker
	
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = npcData.name
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextScaled = true
	label.Font = Enum.Font.SourceSansBold
	label.Parent = billboard
	
	marker.Parent = worldContainer
	return marker
end

-- ========================================
-- CARREGAR E GERAR
-- ========================================

-- Gerar tiles
if GENERATE_TILES then
	print("\n📦 Loading tiles...")
	
	local tiles
	if USE_URLS then
		tiles = JSONLoader.loadFromURL(TILES_URL)
	else
		tiles = JSONLoader.loadFromString(TILES_JSON)
	end
	
	if tiles and JSONLoader.validate(tiles, "array") then
		print("✅ " .. JSONLoader.getStats(tiles))
		print("🔨 Generating tiles...")
		
		local tileCount = 0
		local startTime = tick()
		
		for _, tile in ipairs(tiles) do
			createTile(tile)
			tileCount = tileCount + 1
			
			-- Yield a cada BATCH_SIZE tiles para evitar timeout
			if tileCount % BATCH_SIZE == 0 then
				print(string.format("  Progress: %d/%d tiles (%.1f%%)", tileCount, #tiles, (tileCount / #tiles) * 100))
				task.wait()
			end
		end
		
		local elapsed = tick() - startTime
		print(string.format("✅ Generated %d tiles in %.2f seconds", tileCount, elapsed))
	else
		warn("❌ Failed to load tiles")
	end
end

-- Gerar spawns
if GENERATE_SPAWNS then
	print("\n📦 Loading spawns...")
	
	local spawns
	if USE_URLS then
		spawns = JSONLoader.loadFromURL(SPAWNS_URL)
	else
		spawns = JSONLoader.loadFromString(SPAWNS_JSON)
	end
	
	if spawns and JSONLoader.validate(spawns, "array") then
		print("✅ " .. JSONLoader.getStats(spawns))
		print("🔨 Generating spawn markers...")
		
		local spawnCount = 0
		local startTime = tick()
		
		for _, spawn in ipairs(spawns) do
			createSpawnMarker(spawn)
			spawnCount = spawnCount + 1
			
			if spawnCount % BATCH_SIZE == 0 then
				print(string.format("  Progress: %d/%d spawns", spawnCount, #spawns))
				task.wait()
			end
		end
		
		local elapsed = tick() - startTime
		print(string.format("✅ Generated %d spawn markers in %.2f seconds", spawnCount, elapsed))
	else
		warn("❌ Failed to load spawns")
	end
end

-- Gerar NPCs
if GENERATE_NPCS then
	print("\n📦 Loading NPCs...")
	
	local npcs
	if USE_URLS then
		npcs = JSONLoader.loadFromURL(NPCS_URL)
	else
		npcs = JSONLoader.loadFromString(NPCS_JSON)
	end
	
	if npcs and JSONLoader.validate(npcs, "array") then
		print("✅ " .. JSONLoader.getStats(npcs))
		print("🔨 Generating NPC markers...")
		
		local npcCount = 0
		local startTime = tick()
		
		for _, npc in ipairs(npcs) do
			createNPCMarker(npc)
			npcCount = npcCount + 1
		end
		
		local elapsed = tick() - startTime
		print(string.format("✅ Generated %d NPC markers in %.2f seconds", npcCount, elapsed))
	else
		warn("❌ Failed to load NPCs")
	end
end

-- ========================================
-- FINALIZAÇÃO
-- ========================================

print("\n" .. string.rep("=", 52))
print("🎉 World generation complete!")
print(string.rep("=", 52))
