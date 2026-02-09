-- JSONLoader Module
-- Responsável por carregar e decodificar arquivos JSON

local HttpService = game:GetService("HttpService")

local JSONLoader = {}

-- ========================================
-- CARREGAR DE URL
-- ========================================

-- Carregar JSON de uma URL (GitHub, Pastebin, etc.)
function JSONLoader.loadFromURL(url)
	print("📥 Loading JSON from: " .. url)
	
	local success, result = pcall(function()
		return HttpService:GetAsync(url)
	end)
	
	if success then
		print("✅ Successfully fetched JSON")
		return JSONLoader.loadFromString(result)
	else
		warn("❌ Failed to fetch JSON from " .. url)
		warn("Error: " .. tostring(result))
		return nil
	end
end

-- ========================================
-- CARREGAR DE STRING
-- ========================================

-- Decodificar JSON de uma string
function JSONLoader.loadFromString(jsonString)
	local success, result = pcall(function()
		return HttpService:JSONDecode(jsonString)
	end)
	
	if success then
		print("✅ Successfully decoded JSON")
		return result
	else
		warn("❌ Failed to decode JSON")
		warn("Error: " .. tostring(result))
		return nil
	end
end

-- ========================================
-- UTILIDADES
-- ========================================

-- Validar se JSON foi carregado corretamente
function JSONLoader.validate(data, expectedType)
	if not data then
		warn("❌ Data is nil")
		return false
	end
	
	if expectedType == "array" and type(data) ~= "table" then
		warn("❌ Expected array, got " .. type(data))
		return false
	end
	
	if expectedType == "array" and #data == 0 then
		warn("⚠️ Array is empty")
		return false
	end
	
	return true
end

-- Obter estatísticas do JSON carregado
function JSONLoader.getStats(data)
	if not data then return "No data" end
	
	if type(data) == "table" then
		local count = 0
		for _ in pairs(data) do
			count = count + 1
		end
		return string.format("Loaded %d items", count)
	end
	
	return "Unknown format"
end

return JSONLoader
