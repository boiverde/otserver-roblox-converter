-- TileMapper Module
-- Responsável por converter dados do OTServer para Roblox

local TileMapper = {}

-- ========================================
-- CONFIGURAÇÕES
-- ========================================

TileMapper.TILE_SIZE = 4 -- studs por tile (ajuste conforme necessário)

-- ========================================
-- CONVERSÃO DE COORDENADAS
-- ========================================

-- Converter coordenadas OT (x, y, z) para Roblox (X, Y, Z)
-- OT: x = horizontal, y = profundidade, z = altura (andar)
-- Roblox: X = horizontal, Y = altura, Z = profundidade
function TileMapper.otToRoblox(x, y, z)
	return Vector3.new(
		x * TileMapper.TILE_SIZE,
		z * TileMapper.TILE_SIZE, -- Z do OT vira Y (altura) no Roblox
		y * TileMapper.TILE_SIZE  -- Y do OT vira Z no Roblox
	)
end

-- ========================================
-- PROPRIEDADES DE TILES
-- ========================================

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

-- ========================================
-- UTILIDADES
-- ========================================

-- Criar um tile Part completo
function TileMapper.createTilePart(tileData)
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
	
	return part
end

return TileMapper
