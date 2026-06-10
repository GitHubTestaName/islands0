-- src/core/Manager.lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Manager = {}

local Bot = _G.IslandsBot
local State = Bot.State

local NetManaged = ReplicatedStorage:WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged")
Manager.HitRemote = NetManaged:WaitForChild("CLIENT_BLOCK_HIT_REQUEST")
Manager.PlaceRemote = NetManaged:WaitForChild("CLIENT_BLOCK_PLACE_REQUEST")
Manager.PlowRemote = NetManaged:WaitForChild("CLIENT_PLOW_BLOCK_REQUEST")
Manager.HarvestRemote = NetManaged:WaitForChild("CLIENT_HARVEST_CROP_REQUEST")

Manager.Queue = {}
Manager.IsProcessing = false

function Manager:AtualizarStatus(texto)
    State.Status = texto
    if Bot.Modules.UI and Bot.Modules.UI.SetStatusText then
        Bot.Modules.UI:SetStatusText(texto)
    end
end

function Manager:GetInventoryTools(filterType)
    local ferramentas = {}
    local guardadas = {}
    local LocalPlayer = Players.LocalPlayer
    
    local function analisarItem(obj)
        if obj:IsA("Tool") and not guardadas[obj.Name] then
            -- O Filtro Absoluto que você sugeriu!
            local eBloco = obj:FindFirstChild("block-place") ~= nil
            local eSemente = obj:FindFirstChild("seeds") ~= nil
            
            if filterType == "Block" and eBloco then
                table.insert(ferramentas, obj.Name)
            elseif filterType == "Seed" and eSemente then
                table.insert(ferramentas, obj.Name)
            elseif filterType == "All" then
                table.insert(ferramentas, obj.Name)
            end
            guardadas[obj.Name] = true
        end
    end
    
    for _, obj in pairs(LocalPlayer.Backpack:GetChildren()) do analisarItem(obj) end
    if LocalPlayer.Character then
        for _, obj in pairs(LocalPlayer.Character:GetChildren()) do analisarItem(obj) end
    end
    
    if #ferramentas == 0 then return {"Nenhum item encontrado"} end
    return ferramentas
end

function Manager:AdicionarFila(actionFunc)
    table.insert(self.Queue, actionFunc)
    if not self.IsProcessing then self:ProcessarProximo() end
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
        pcall(tarefa)
        self:ProcessarProximo()
    end)
end

-- A SUA LÓGICA DE DETECÇÃO DA ÁRVORE AQUI:
function Manager:ObterBlocoRaiz(hitInstance)
    if not hitInstance then return nil end
    
    -- 1. Verifica se é parte física de uma Árvore (galho, folha, tronco)
    local pastaColisao = hitInstance:FindFirstAncestor("CollisionBoxes")
    if pastaColisao and pastaColisao.Parent then
        -- Se estiver dentro do CollisionBoxes, o bloco real é o PAI da pasta!
        return pastaColisao.Parent 
    end
    
    -- 2. Busca padrão para blocos normais
    local current = hitInstance
    while current and current.Parent do
        if current.Parent.Name == "Blocks" then
            return current
        end
        current = current.Parent
    end
    return hitInstance
end

return Manager