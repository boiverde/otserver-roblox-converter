# 🧪 TESTE RÁPIDO - VALIDAÇÃO DO PROJETO

Este guia permite testar rapidamente se tudo está funcionando corretamente.

---

## ✅ CHECKLIST DE VALIDAÇÃO

### Fase 1 - Extração (Python)

- [ ] **1.1** Python 3.x instalado
- [ ] **1.2** Arquivo `world.otbm` localizado
- [ ] **1.3** Arquivo `items.xml` localizado
- [ ] **1.4** Script `export_map.py` executado sem erros
- [ ] **1.5** Pasta `export/` criada
- [ ] **1.6** Arquivo `tiles.json` gerado
- [ ] **1.7** Arquivo `spawns.json` gerado
- [ ] **1.8** Arquivo `npcs.json` gerado

### Fase 2 - Roblox (Lua)

- [ ] **2.1** Roblox Studio instalado
- [ ] **2.2** Projeto criado (Baseplate)
- [ ] **2.3** Estrutura de pastas criada
- [ ] **2.4** Módulos copiados (TileMapper, JSONLoader)
- [ ] **2.5** Scripts copiados (WorldGenerator, CameraController)
- [ ] **2.6** URLs configuradas ou dados embutidos
- [ ] **2.7** HttpService habilitado
- [ ] **2.8** Jogo executado sem erros
- [ ] **2.9** `OTWorld` criado no Workspace
- [ ] **2.10** Tiles visíveis no mundo
- [ ] **2.11** Câmera funcionando corretamente
- [ ] **2.12** Movimento funcionando

---

## 🧪 TESTE 1: VALIDAR EXPORTAÇÃO

### Objetivo
Verificar se o script Python está exportando corretamente.

### Passos

1. **Abrir terminal/PowerShell**
   ```powershell
   cd C:\Users\merca\.gemini\antigravity\scratch\OTSERVER_15X\server
   ```

2. **Executar script**
   ```powershell
   python export_map.py
   ```

3. **Verificar logs**
   Você deve ver algo como:
   ```
   INFO - Loading items from ...items.xml
   INFO - Reading OTBM: ...world.otbm
   INFO - Unescaping data...
   INFO - Unescaped size: XXXXX bytes
   INFO - Extracted XXX tiles.
   ```

4. **Verificar arquivos**
   ```powershell
   dir ..\export
   ```
   
   Deve mostrar:
   - `tiles.json`
   - `spawns.json`
   - `npcs.json`

5. **Validar JSON**
   ```powershell
   # Ver primeiras linhas do tiles.json
   Get-Content ..\export\tiles.json | Select-Object -First 10
   ```

### ✅ Resultado Esperado
- Logs sem erros
- 3 arquivos JSON criados
- JSONs com conteúdo válido

---

## 🧪 TESTE 2: VALIDAR GERAÇÃO NO ROBLOX (MODO TESTE)

### Objetivo
Testar geração de mundo com dados embutidos (sem precisar hospedar JSONs).

### Passos

1. **Abrir Roblox Studio**

2. **Criar novo projeto**
   - File → New → Baseplate

3. **Criar estrutura de pastas**
   ```
   ReplicatedStorage
     └─ Modules (Folder)
          ├─ TileMapper (ModuleScript)
          └─ JSONLoader (ModuleScript)
   
   ServerScriptService
     └─ WorldGenerator (Script)
   
   StarterPlayer
     └─ StarterPlayerScripts (Folder)
          └─ CameraController (LocalScript)
   ```

4. **Copiar código dos módulos**
   - Abrir `TileMapper.lua` e copiar todo o conteúdo
   - Colar em `ReplicatedStorage > Modules > TileMapper`
   - Repetir para `JSONLoader.lua`

5. **Copiar WorldGenerator**
   - Abrir `WorldGenerator.lua` e copiar todo o conteúdo
   - Colar em `ServerScriptService > WorldGenerator`
   - **IMPORTANTE:** Verificar que `USE_URLS = false` (linha 18)

6. **Copiar CameraController**
   - Abrir `CameraController.lua` e copiar todo o conteúdo
   - Colar em `StarterPlayerScripts > CameraController`

7. **Executar jogo**
   - Clicar em "Play" (F5)

8. **Verificar Output**
   - View → Output
   - Procurar por mensagens como:
     ```
     🌍 OTServer World Generator
     📦 Loading tiles...
     ✅ Loaded 9 items
     🔨 Generating tiles...
     ✅ Generated 9 tiles in 0.XX seconds
     ...
     🎉 World generation complete!
     ```

9. **Verificar Workspace**
   - Explorer → Workspace → OTWorld
   - Deve conter Parts (tiles, spawns, NPCs)

10. **Testar câmera**
    - Scroll do mouse para zoom
    - Teclas +/- para zoom
    - Tecla R para reset

### ✅ Resultado Esperado
- Output sem erros (❌)
- `OTWorld` criado com tiles
- Câmera top-down funcionando
- Zoom funcionando

---

## 🧪 TESTE 3: VALIDAR COM JSONs REAIS

### Objetivo
Testar com os JSONs exportados do OTServer.

### Pré-requisitos
- JSONs hospedados em GitHub ou Pastebin

### Passos

1. **Hospedar JSONs no GitHub**
   - Criar repositório público
   - Upload de `tiles.json`, `spawns.json`, `npcs.json`
   - Copiar URLs raw:
     ```
     https://raw.githubusercontent.com/SEU_USUARIO/SEU_REPO/main/tiles.json
     https://raw.githubusercontent.com/SEU_USUARIO/SEU_REPO/main/spawns.json
     https://raw.githubusercontent.com/SEU_USUARIO/SEU_REPO/main/npcs.json
     ```

2. **Editar WorldGenerator**
   - Abrir `WorldGenerator` no Roblox Studio
   - Mudar `USE_URLS = true` (linha 18)
   - Substituir URLs (linhas 21-23):
     ```lua
     local TILES_URL = "SUA_URL_TILES"
     local SPAWNS_URL = "SUA_URL_SPAWNS"
     local NPCS_URL = "SUA_URL_NPCS"
     ```

3. **Habilitar HttpService**
   - No Roblox Studio, abrir Output
   - Executar comando:
     ```lua
     game:GetService("HttpService").HttpEnabled = true
     ```
   - Ou: Home → Game Settings → Security → Allow HTTP Requests

4. **Executar jogo**
   - Clicar em "Play" (F5)

5. **Verificar Output**
   - Procurar por:
     ```
     📥 Loading JSON from: https://...
     ✅ Successfully fetched JSON
     ✅ Successfully decoded JSON
     ✅ Loaded XXXX items
     ```

6. **Verificar mundo gerado**
   - Workspace → OTWorld
   - Deve conter muitos tiles (dependendo do tamanho do mapa)

### ✅ Resultado Esperado
- JSONs carregados com sucesso
- Mundo gerado com tiles reais do OTServer
- Performance aceitável (pode demorar alguns segundos)

---

## 🧪 TESTE 4: VALIDAR PERFORMANCE

### Objetivo
Verificar se o mundo gerado é performático.

### Passos

1. **Executar jogo**
   - Play → Start Server and Players
   - Selecionar 2-3 players

2. **Verificar FPS**
   - Shift + F5 para mostrar stats
   - FPS deve estar acima de 30

3. **Verificar memória**
   - Stats → Memory
   - Não deve crescer indefinidamente

4. **Testar movimento**
   - Mover personagem pelo mapa
   - Verificar se não há lag

### ✅ Resultado Esperado
- FPS acima de 30
- Memória estável
- Movimento fluido

---

## 🧪 TESTE 5: VALIDAR MULTIPLAYER

### Objetivo
Verificar se funciona com múltiplos jogadores.

### Passos

1. **Executar servidor de teste**
   - Test → Start Server and Players
   - Selecionar 4-5 players

2. **Verificar sincronização**
   - Todos os players devem ver o mesmo mundo
   - Movimento deve ser sincronizado

3. **Verificar performance**
   - FPS deve permanecer aceitável

### ✅ Resultado Esperado
- Mundo sincronizado entre players
- Performance aceitável
- Sem crashes

---

## 🐛 TROUBLESHOOTING

### Problema: "Module not found"
**Causa:** Módulos não estão no lugar correto  
**Solução:** Verificar que TileMapper e JSONLoader estão em `ReplicatedStorage > Modules`

### Problema: "HttpService is not allowed"
**Causa:** HttpService não habilitado  
**Solução:** 
```lua
game:GetService("HttpService").HttpEnabled = true
```
Ou: Game Settings → Security → Allow HTTP Requests

### Problema: "Failed to load JSON"
**Causa:** URL incorreta ou JSON inválido  
**Solução:**
- Verificar URL (deve ser raw URL do GitHub)
- Validar JSON em jsonlint.com
- Verificar se repositório é público

### Problema: Tiles não aparecem
**Causa:** Coordenadas muito longe ou câmera mal posicionada  
**Solução:**
- Verificar coordenadas no JSON
- Ajustar `TILE_SIZE` em TileMapper
- Mover câmera no Workspace para área correta

### Problema: Performance ruim
**Causa:** Muitos tiles sendo gerados  
**Solução:**
- Filtrar tiles por área (editar export_map.py)
- Habilitar Streaming:
  ```lua
  workspace.StreamingEnabled = true
  workspace.StreamingMinRadius = 128
  workspace.StreamingTargetRadius = 256
  ```
- Reduzir `BATCH_SIZE` em WorldGenerator

---

## 📊 MÉTRICAS DE SUCESSO

### Fase 1
- ✅ Exportação completa sem erros
- ✅ JSONs válidos
- ✅ Tamanho dos arquivos razoável

### Fase 2
- ✅ Geração sem erros
- ✅ Tiles visíveis
- ✅ Câmera funcionando
- ✅ FPS > 30
- ✅ Multiplayer funcional

---

## 🎯 PRÓXIMOS PASSOS APÓS VALIDAÇÃO

1. **Otimizar mapa**
   - Filtrar tiles desnecessários
   - Implementar chunking
   - Adicionar LOD

2. **Melhorar visual**
   - Adicionar iluminação
   - Adicionar efeitos visuais
   - Melhorar materiais

3. **Adicionar gameplay**
   - Sistema de spawn de mobs
   - NPCs interativos
   - Sistema de combate

4. **Publicar**
   - Configurar permissões
   - Adicionar descrição
   - Publicar no Roblox

---

**Boa sorte com os testes! 🚀**
