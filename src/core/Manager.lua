-- src/core/Manager.lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Manager = {}

local Bot = _G.IslandsBot
local State = Bot.State

-- Cache de conexões de rede
local NetManaged = ReplicatedStorage:WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged")
Manager.HitRemote = NetManaged:WaitForChild("CLIENT_BLOCK_HIT_REQUEST")
Manager.PlaceRemote = NetManaged:WaitForChild("CLIENT_BLOCK_PLACE_REQUEST")

-- Fila de comandos
Manager.Queue = {}
Manager.IsProcessing = false

function Manager:AtualizarStatus(texto)
    State.Status = texto
    if Bot.Modules.UI and Bot.Modules.UI.SetStatusText then
        Bot.Modules.UI:SetStatusText(texto)
    end
end

-- Adiciona uma função à fila de processamento sequencial
function Manager:AdicionarFila(actionFunc)
    table.insert(self.Queue, actionFunc)
    if not self.IsProcessing then
        self:ProcessarProximo()
    end
end

function Manager:ProcessarProximo()
    if #self.Queue == 0 then
        self.IsProcessing = false
        self:AtualizarStatus("Ocioso")
        return
    end

    self.IsProcessing = true
    local tarefa = table.remove(self.Queue, 1)

    task.spawn(function()
        local ok, err = pcall(tarefa)
        if not ok then
            warn("[Manager] Erro ao executar tarefa da fila: " .. tostring(err))
        end
        self:ProcessarProximo()
    end)
end

function Manager:LimparFila()
    self.Queue = {}
    self.IsProcessing = false
end

-- Função auxiliar: obter o bloco raiz real ignorando partes acessórias
function Manager:ObterBlocoRaiz(hitInstance)
    if not hitInstance then return nil end
    if hitInstance.Parent and hitInstance.Parent.Parent and hitInstance.Parent.Parent.Name == "Blocks" then
        return hitInstance.Parent
    end
    return hitInstance
end

return Manager