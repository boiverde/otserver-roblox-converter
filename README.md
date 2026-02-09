# 🎮 OTSERVER → ROBLOX 3D TOP-DOWN

Pipeline automático para converter mapas de OTServer 15.x em mundos 3D top-down no Roblox, **sem usar assets oficiais do Tibia**.

---

## 🎯 OBJETIVO

Criar um sistema automatizado que:
1. ✅ Extrai layout, grid, posições e spawns do mapa do OTServer
2. ✅ Exporta dados para formato intermediário (JSON)
3. ✅ Gera automaticamente mundo 3D no Roblox
4. ✅ Usa apenas assets genéricos/originais (sem copiar Tibia)

---

## 📊 STATUS DO PROJETO

| Fase | Status | Descrição |
|------|--------|-----------|
| **Fase 1** | ✅ **CONCLUÍDA** | Extração e exportação do mapa OTServer |
| **Fase 2** | 📝 **DOCUMENTADA** | Geração automática no Roblox |
| **Fase 3** | 🔜 **PLANEJADA** | Gameplay e mecânicas |

---

## 📁 ESTRUTURA DO PROJETO

```
OTSERVER_15X/
├── 📄 README.md                           ← VOCÊ ESTÁ AQUI
├── 📄 ARQUITETURA_PROJETO_ROBLOX.md       ← Arquitetura completa
├── 📄 ENTREGAVEIS.md                      ← Lista de entregáveis
├── 📄 TESTE_RAPIDO.md                     ← Guia de testes
│
├── server/
│   ├── export_map.py                      ← Script de exportação (Fase 1)
│   └── data-otservbr-global/
│       └── world/world.otbm               ← Mapa do OTServer
│
├── export/
│   ├── tiles.json                         ← Tiles exportados (~14 KB)
│   ├── spawns.json                        ← Spawns exportados (~4.9 MB)
│   └── npcs.json                          ← NPCs exportados (~56 KB)
│
└── roblox/
    ├── 📄 GUIA_IMPLEMENTACAO_FASE2.md     ← Guia de implementação
    ├── TileMapper.lua                     ← Módulo de conversão
    ├── JSONLoader.lua                     ← Módulo de carregamento
    ├── WorldGenerator.lua                 ← Script de geração
    └── CameraController.lua               ← Script de câmera
```

---

## 🚀 INÍCIO RÁPIDO

### Fase 1: Exportar Mapa do OTServer

```bash
# 1. Navegar para pasta do servidor
cd C:\Users\merca\.gemini\antigravity\scratch\OTSERVER_15X\server

# 2. Executar script de exportação
python export_map.py

# 3. Verificar arquivos exportados
dir ..\export
```

**Resultado:** 3 arquivos JSON criados em `export/`

### Fase 2: Gerar Mundo no Roblox

1. **Abrir Roblox Studio**
2. **Criar novo projeto** (Baseplate)
3. **Seguir guia:** `roblox/GUIA_IMPLEMENTACAO_FASE2.md`
4. **Copiar scripts** para locais corretos
5. **Executar jogo** (F5)

**Resultado:** Mundo 3D gerado automaticamente

---

## 📖 DOCUMENTAÇÃO

### Documentos Principais

1. **[ARQUITETURA_PROJETO_ROBLOX.md](ARQUITETURA_PROJETO_ROBLOX.md)**
   - Arquitetura completa do projeto
   - Explicação detalhada de ambas as fases
   - Especificação técnica
   - Roadmap completo

2. **[roblox/GUIA_IMPLEMENTACAO_FASE2.md](roblox/GUIA_IMPLEMENTACAO_FASE2.md)**
   - Passo a passo de implementação no Roblox
   - Código completo de todos os módulos
   - Instruções de setup
   - Troubleshooting

3. **[ENTREGAVEIS.md](ENTREGAVEIS.md)**
   - Lista completa de arquivos criados
   - Descrição de cada componente
   - Próximos passos
   - Estrutura final

4. **[TESTE_RAPIDO.md](TESTE_RAPIDO.md)**
   - Checklist de validação
   - Testes passo a passo
   - Troubleshooting
   - Métricas de sucesso

---

## 🛠️ TECNOLOGIAS

### Fase 1 - Extração
- **Python 3.x**
- **xml.etree.ElementTree** (parser XML)
- **struct** (leitura binária)
- **json** (serialização)

### Fase 2 - Roblox
- **Roblox Studio**
- **Lua 5.1**
- **HttpService** (carregamento de JSONs)
- **RunService** (loop de renderização)

---

## 📦 COMPONENTES

### Scripts Python (Fase 1)

#### `export_map.py`
Parser completo de arquivos OTBM que:
- Lê `world.otbm` (formato binário)
- Carrega `items.xml` para classificação
- Extrai tiles, spawns e NPCs
- Exporta para JSON

### Scripts Lua (Fase 2)

#### `TileMapper.lua` (Módulo)
- Converte coordenadas OT → Roblox
- Mapeia tipos de tiles
- Define materiais e cores
- Cria Parts completos

#### `JSONLoader.lua` (Módulo)
- Carrega JSON de URLs
- Decodifica e valida dados
- Tratamento de erros

#### `WorldGenerator.lua` (Script)
- Gera tiles automaticamente
- Cria marcadores de spawn
- Cria marcadores de NPC
- Progress tracking

#### `CameraController.lua` (LocalScript)
- Câmera top-down fixa
- Zoom suave
- Controles de teclado/mouse

---

## 🎨 PADRÃO DE CONVERSÃO

### Grid Mapping
```
1 tile OT = 4x4 studs Roblox (configurável)

Coordenadas:
OT (x, y, z) → Roblox (X, Y, Z)
X_roblox = x_ot * 4
Z_roblox = y_ot * 4
Y_roblox = z_ot * 4  (altura)
```

### Tiles → Roblox Parts

| Tipo OT | Material Roblox | Cor | Colisão |
|---------|----------------|-----|---------|
| `floor` | Grass | Verde | ❌ |
| `wall` | Brick | Cinza | ✅ |
| `door` | Wood | Marrom | ✅ |
| `water` | Water | Azul | ❌ |

---

## ⚠️ IMPORTANTE

### Legal e Ético
- ✅ **Usar apenas layout e lógica** do OTServer
- ❌ **NÃO usar sprites, tiles, músicas ou assets oficiais do Tibia**
- ✅ **Criar assets genéricos/originais no Roblox**

### Técnico
- **Mapa grande:** Considere chunking ou streaming
- **Performance:** Teste com múltiplos jogadores
- **JSONs grandes:** Considere hospedar em CDN

---

## 🧪 TESTES

### Teste Rápido (Fase 1)
```bash
cd server
python export_map.py
```
**Esperado:** 3 arquivos JSON criados sem erros

### Teste Rápido (Fase 2)
1. Abrir Roblox Studio
2. Copiar scripts para locais corretos
3. Executar jogo (F5)

**Esperado:** Mundo gerado com tiles visíveis

**Guia completo:** [TESTE_RAPIDO.md](TESTE_RAPIDO.md)

---

## 📈 ROADMAP

### ✅ Fase 1 - Extração (CONCLUÍDA)
- [x] Parser OTBM
- [x] Exportador de tiles
- [x] Exportador de spawns
- [x] Exportador de NPCs

### 📝 Fase 2 - Roblox (DOCUMENTADA)
- [x] Módulo TileMapper
- [x] Módulo JSONLoader
- [x] WorldGenerator
- [x] CameraController
- [ ] Implementação no Roblox Studio
- [ ] Testes de performance
- [ ] Otimizações

### 🔜 Fase 3 - Gameplay (PLANEJADA)
- [ ] Sistema de combate
- [ ] Spawn dinâmico de mobs
- [ ] NPCs interativos
- [ ] Sistema de quests
- [ ] Inventário e itens

### 🔜 Fase 4 - Social (FUTURA)
- [ ] Sistema de party
- [ ] Chat global
- [ ] Leaderboards
- [ ] Sistema de guilds

---

## 🐛 TROUBLESHOOTING

### Problema: "HttpService is not allowed"
**Solução:**
```lua
game:GetService("HttpService").HttpEnabled = true
```
Ou: Game Settings → Security → Allow HTTP Requests

### Problema: "Failed to load JSON"
**Solução:**
- Verificar se URL está correta (raw URL do GitHub)
- Validar JSON em jsonlint.com
- Verificar se repositório é público

### Problema: Tiles não aparecem
**Solução:**
- Verificar se `OTWorld` existe no Workspace
- Ajustar câmera para área correta
- Verificar coordenadas no JSON

**Mais soluções:** [TESTE_RAPIDO.md](TESTE_RAPIDO.md#-troubleshooting)

---

## 📞 SUPORTE

### Logs e Debug

**Python:**
```bash
python export_map.py
# Verificar logs no console
```

**Roblox:**
- View → Output
- Procurar por ✅ (sucesso) ou ❌ (erro)

### Documentação Adicional
- [Arquitetura Completa](ARQUITETURA_PROJETO_ROBLOX.md)
- [Guia de Implementação](roblox/GUIA_IMPLEMENTACAO_FASE2.md)
- [Guia de Testes](TESTE_RAPIDO.md)

---

## 🎯 PRÓXIMOS PASSOS

1. ✅ **Revisar documentação**
   - Ler [ARQUITETURA_PROJETO_ROBLOX.md](ARQUITETURA_PROJETO_ROBLOX.md)
   - Ler [GUIA_IMPLEMENTACAO_FASE2.md](roblox/GUIA_IMPLEMENTACAO_FASE2.md)

2. 🔜 **Hospedar JSONs**
   - Criar repositório GitHub público
   - Upload dos arquivos JSON
   - Obter URLs raw

3. 🔜 **Implementar no Roblox**
   - Seguir guia de implementação
   - Copiar scripts
   - Configurar URLs
   - Testar

4. 🔜 **Otimizar e Publicar**
   - Ajustar performance
   - Melhorar visual
   - Publicar no Roblox

---

## 📝 NOTAS FINAIS

Este projeto demonstra um pipeline completo e automatizado para converter mapas de OTServer em mundos 3D no Roblox, respeitando propriedade intelectual e criando uma experiência única e original.

**Todos os componentes necessários foram criados e documentados.**

**Status:** ✅ **PRONTO PARA IMPLEMENTAÇÃO**

---

## 📄 LICENÇA

Este projeto é para uso educacional e demonstração de automação. Não inclui nem usa assets oficiais do Tibia.

---

**Desenvolvido com ❤️ para automação máxima**

**Última atualização:** 2026-02-09
