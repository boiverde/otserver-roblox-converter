# 📦 GUIA: CRIAR REPOSITÓRIO NO GITHUB

## 🎯 OBJETIVO

Criar repositório público no GitHub para hospedar o projeto e permitir que os scripts Roblox carreguem os arquivos JSON.

---

## 📋 PRÉ-REQUISITOS

- [ ] Conta no GitHub (https://github.com/boiverde)
- [ ] Git instalado (https://git-scm.com/download/win)

---

## 🚀 MÉTODO 1: INTERFACE WEB (RECOMENDADO PARA INICIANTES)

### Passo 1: Criar Repositório

1. **Acessar GitHub**
   - Ir para https://github.com/boiverde
   - Fazer login

2. **Criar Novo Repositório**
   - Clicar no botão **"+"** no canto superior direito
   - Selecionar **"New repository"**

3. **Configurar Repositório**
   ```
   Repository name: otserver-roblox-converter
   Description: Pipeline automático para converter mapas de OTServer 15.x em mundos 3D top-down no Roblox
   Visibility: ✅ Public (IMPORTANTE!)
   Initialize: ✅ Add a README file
   Add .gitignore: Python
   License: MIT (opcional)
   ```

4. **Criar**
   - Clicar em **"Create repository"**

### Passo 2: Upload dos Arquivos

1. **Acessar Repositório**
   - Você será redirecionado para o repositório criado

2. **Upload via Web**
   - Clicar em **"Add file"** → **"Upload files"**

3. **Selecionar Arquivos**
   - Arrastar ou clicar para selecionar:
     ```
     ✅ README.md
     ✅ ARQUITETURA_PROJETO_ROBLOX.md
     ✅ ENTREGAVEIS.md
     ✅ TESTE_RAPIDO.md
     ✅ DIAGRAMA_FLUXO.md
     ```

4. **Upload de Pastas**
   - **Opção A:** Criar pastas manualmente e fazer upload dos arquivos
   - **Opção B:** Usar Git CLI (Método 2)

5. **Commit**
   - Commit message: `Initial commit - Documentação e scripts`
   - Clicar em **"Commit changes"**

6. **Repetir para outras pastas**
   - Criar pasta `roblox/` e fazer upload dos `.lua`
   - Criar pasta `export/` e fazer upload dos `.json`
   - Criar pasta `server/` e fazer upload do `export_map.py`

### Passo 3: Obter URLs dos JSONs

Após upload, as URLs raw serão:

```
https://raw.githubusercontent.com/boiverde/otserver-roblox-converter/main/export/tiles.json
https://raw.githubusercontent.com/boiverde/otserver-roblox-converter/main/export/spawns.json
https://raw.githubusercontent.com/boiverde/otserver-roblox-converter/main/export/npcs.json
```

**Copiar essas URLs para usar no `WorldGenerator.lua`**

---

## 🛠️ MÉTODO 2: GIT CLI (RECOMENDADO PARA AVANÇADOS)

### Passo 1: Criar Repositório Vazio no GitHub

1. Acessar https://github.com/new
2. Configurar:
   ```
   Repository name: otserver-roblox-converter
   Visibility: Public
   NÃO marcar "Initialize with README"
   ```
3. Clicar em "Create repository"

### Passo 2: Executar Script Automatizado

1. **Abrir PowerShell como Administrador**

2. **Navegar para pasta do projeto**
   ```powershell
   cd C:\Users\merca\.gemini\antigravity\scratch\OTSERVER_15X
   ```

3. **Executar script**
   ```powershell
   .\setup_github_repo.ps1
   ```

4. **Autenticar**
   - Quando solicitado, usar **Personal Access Token**
   - Criar token em: https://github.com/settings/tokens
   - Permissões necessárias: `repo` (full control)

### Passo 3: Verificar Upload

1. Acessar https://github.com/boiverde/otserver-roblox-converter
2. Verificar se todos os arquivos foram enviados

---

## 🔧 MÉTODO 3: GIT CLI MANUAL (PASSO A PASSO)

### Passo 1: Instalar Git

```powershell
# Verificar se Git está instalado
git --version

# Se não estiver, baixar em: https://git-scm.com/download/win
```

### Passo 2: Configurar Git (Primeira Vez)

```powershell
git config --global user.name "Seu Nome"
git config --global user.email "seu@email.com"
```

### Passo 3: Inicializar Repositório

```powershell
# Navegar para pasta do projeto
cd C:\Users\merca\.gemini\antigravity\scratch\OTSERVER_15X

# Inicializar Git
git init

# Criar .gitignore
@"
__pycache__/
*.pyc
*.log
.vscode/
server/data-otservbr-global/world/*.otbm
"@ | Out-File -FilePath .gitignore -Encoding utf8
```

### Passo 4: Adicionar Arquivos

```powershell
# Adicionar documentação
git add README.md
git add ARQUITETURA_PROJETO_ROBLOX.md
git add ENTREGAVEIS.md
git add TESTE_RAPIDO.md
git add DIAGRAMA_FLUXO.md
git add .gitignore

# Adicionar scripts
git add roblox/*.lua
git add server/export_map.py

# Adicionar JSONs
git add export/tiles.json
git add export/npcs.json

# spawns.json pode ser muito grande (4.9 MB)
# Verificar tamanho antes
git add export/spawns.json
```

### Passo 5: Commit

```powershell
git commit -m "Initial commit - OTServer to Roblox converter"
```

### Passo 6: Adicionar Remote

```powershell
git remote add origin https://github.com/boiverde/otserver-roblox-converter.git
```

### Passo 7: Push

```powershell
git branch -M main
git push -u origin main
```

**Nota:** Você precisará autenticar. Use Personal Access Token:
1. Ir para https://github.com/settings/tokens
2. Gerar novo token (classic)
3. Permissões: `repo`
4. Copiar token
5. Usar como senha ao fazer push

---

## ⚠️ PROBLEMAS COMUNS

### Problema 1: "File is too large"

**Causa:** `spawns.json` é muito grande (4.9 MB)

**Solução A:** Usar Git LFS
```powershell
git lfs install
git lfs track "*.json"
git add .gitattributes
git add export/spawns.json
git commit -m "Add large JSON files with LFS"
git push
```

**Solução B:** Hospedar separadamente
- Upload para Google Drive ou Dropbox
- Obter link público
- Usar no `WorldGenerator.lua`

### Problema 2: "Authentication failed"

**Causa:** GitHub não aceita mais senha por CLI

**Solução:** Usar Personal Access Token
1. https://github.com/settings/tokens
2. Generate new token (classic)
3. Permissões: `repo`
4. Copiar token
5. Usar como senha

### Problema 3: "Repository not found"

**Causa:** Repositório não foi criado no GitHub

**Solução:** Criar repositório vazio primeiro em https://github.com/new

---

## 📍 URLS FINAIS

Após upload bem-sucedido, as URLs serão:

### Repositório
```
https://github.com/boiverde/otserver-roblox-converter
```

### Raw URLs (para usar no Roblox)
```
https://raw.githubusercontent.com/boiverde/otserver-roblox-converter/main/export/tiles.json
https://raw.githubusercontent.com/boiverde/otserver-roblox-converter/main/export/spawns.json
https://raw.githubusercontent.com/boiverde/otserver-roblox-converter/main/export/npcs.json
```

### Scripts Lua
```
https://github.com/boiverde/otserver-roblox-converter/tree/main/roblox
```

---

## ✅ CHECKLIST DE VALIDAÇÃO

Após criar o repositório, verificar:

- [ ] Repositório é **público**
- [ ] README.md está visível
- [ ] Pasta `roblox/` contém 4 arquivos `.lua`
- [ ] Pasta `export/` contém 3 arquivos `.json`
- [ ] Pasta `server/` contém `export_map.py`
- [ ] URLs raw funcionam (testar no navegador)

---

## 🎯 PRÓXIMO PASSO

Após criar o repositório:

1. **Copiar URLs raw dos JSONs**
2. **Editar `WorldGenerator.lua`**
   ```lua
   local TILES_URL = "https://raw.githubusercontent.com/boiverde/otserver-roblox-converter/main/export/tiles.json"
   local SPAWNS_URL = "https://raw.githubusercontent.com/boiverde/otserver-roblox-converter/main/export/spawns.json"
   local NPCS_URL = "https://raw.githubusercontent.com/boiverde/otserver-roblox-converter/main/export/npcs.json"
   ```
3. **Implementar no Roblox Studio**

---

## 📞 SUPORTE

Se tiver problemas:

1. Verificar se Git está instalado: `git --version`
2. Verificar se repositório foi criado no GitHub
3. Verificar autenticação (usar Personal Access Token)
4. Consultar documentação do Git: https://git-scm.com/doc

---

**Boa sorte! 🚀**
