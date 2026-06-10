-- loader.lua
-- Ponto de entrada para carregar a automação modularizada

-- Configuração do repositório
local GITHUB_USER = "GitHubTestaName"
local GITHUB_REPO = "Islands"
local BRANCH = "main"
local BASE_URL = string.format("https://raw.githubusercontent.com/%s/%s/%s/", GITHUB_USER, GITHUB_REPO, BRANCH)

-- Inicialização do ambiente global compartilhado
_G.IslandsBot = {
    Config = {
        BLOCK_SIZE = 3,
        BaseUrl = BASE_URL
    },
    State = {
        AncoraPart = nil,
        Handles = nil,
        CaixaVisual = nil,
        MarcadoresVisuais = {},
        ListaBlocos = {},
        Minerando = false,
        Construindo = false,
        Status = "Ocioso"
    },
    Modules = {}
}

local function carregarModulo(caminho)
    local url = BASE_URL .. caminho
    local success, scriptContent = pcall(game.HttpGet, game, url)
    if not success or not scriptContent then
        warn("[Loader] Erro ao baixar modulo: " .. caminho)
        return nil
    end
    
    local executable, compileError = loadstring(scriptContent)
    if not executable then
        warn("[Loader] Erro de compilacao no modulo: " .. caminho .. " | " .. tostring(compileError))
        return nil
    end
    
    local loadSuccess, moduleResult = pcall(executable)
    if not loadSuccess then
        warn("[Loader] Erro de execucao no modulo: " .. caminho .. " | " .. tostring(moduleResult))
        return nil
    end
    
    return moduleResult
end

-- Carregamento sequencial dos módulos
-- Carregamento sequencial dos módulos
task.spawn(function()
    print("[Loader] Carregando modulos do backend...")
    _G.IslandsBot.Modules.Manager = carregarModulo("src/core/Manager.lua")
    _G.IslandsBot.Modules.Scanner = carregarModulo("src/core/Scanner.lua")
    _G.IslandsBot.Modules.Miner = carregarModulo("src/actions/Miner.lua")
    _G.IslandsBot.Modules.Builder = carregarModulo("src/actions/Builder.lua")
    _G.IslandsBot.Modules.Farmer = carregarModulo("src/actions/Farmer.lua") -- NOVO AQUI
    
    print("[Loader] Inicializando interface do usuario...")
    _G.IslandsBot.Modules.UI = carregarModulo("src/ui/Window.lua")
    print("[Loader] Inicializacao concluida.")
end)