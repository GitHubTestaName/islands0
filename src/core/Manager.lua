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

-- LER INVENTÁRIO (Procura Ferramentas e Blocos)
function Manager:GetInventoryTools()
    local ferramentas = {}
    local guardadas = {}
    local LocalPlayer = Players.LocalPlayer
    
    local function add(obj)
        if obj:IsA("Tool") and not guardadas[obj.Name] then
            table.insert(ferramentas, obj.Name)
            guardadas[obj.Name] = true
        end
    end
    
    for _, obj in pairs(LocalPlayer.Backpack:GetChildren()) do add(obj) end
    if LocalPlayer.Character then
        for _, obj in pairs(LocalPlayer.Character:GetChildren()) do add(obj) end
    end
    
    if #ferramentas == 0 then return {"Nenhuma ferramenta encontrada"} end
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

function Manager:ObterBlocoRaiz(hitInstance)
    if not hitInstance then return nil end
    if hitInstance.Parent and hitInstance.Parent.Parent and hitInstance.Parent.Parent.Name == "Blocks" then
        return hitInstance.Parent
    end
    return hitInstance
end

return Manager