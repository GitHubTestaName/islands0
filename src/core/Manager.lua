-- src/core/Manager.lua
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Manager = {}

function Manager:ObterBlocoRaiz(part)
    if not part then return nil end
    local atual = part
    while atual and atual ~= workspace and atual.Name ~= "Blocks" do
        if atual:IsA("Model") and atual.PrimaryPart then return atual end
        if atual:IsA("BasePart") and atual.Name ~= "Trunk" and atual.Name ~= "Top" and atual.Parent.Name == "Blocks" then
            return atual
        end
        atual = atual.Parent
    end
    return part:IsA("BasePart") and part or nil
end

function Manager:GetInventoryTools(filtroTipo)
    local player = Players.LocalPlayer
    local toolsEncontradas = {}
    local itensProcessados = {}

    local function processarItem(item)
        if item:IsA("Tool") and not itensProcessados[item.Name] then
            if filtroTipo == "Block" and (item.Name:match("Block") or item:FindFirstChild("block-meta")) then
                table.insert(toolsEncontradas, item.Name)
                itensProcessados[item.Name] = true
            elseif filtroTipo == "Seed" and (item.Name:lower():match("seed") or item:FindFirstChild("cropSeed")) then
                table.insert(toolsEncontradas, item.Name)
                itensProcessados[item.Name] = true
            end
        end
    end

    if player.Character then
        for _, item in ipairs(player.Character:GetChildren()) do processarItem(item) end
    end
    for _, item in ipairs(player.Backpack:GetChildren()) do processarItem(item) end

    table.sort(toolsEncontradas)
    return #toolsEncontradas > 0 and toolsEncontradas or {"Nenhum item encontrado"}
end

-- NOVA FUNÇÃO: Pega TODAS as sementes do jogo direto dos arquivos do desenvolvedor!
function Manager:GetAllSeedsInGame()
    local allSeeds = {}
    local rsTools = ReplicatedStorage:FindFirstChild("Tools")
    
    if rsTools then
        for _, tool in ipairs(rsTools:GetChildren()) do
            if tool:IsA("Tool") or tool:IsA("Folder") then
                -- Checa se o nome termina com "Seeds" ou se tem o script característico
                if tool.Name:match("Seeds$") or tool.Name:match("seeds$") or tool:FindFirstChild("cropSeed") then
                    table.insert(allSeeds, tool.Name)
                end
            end
        end
    end
    
    table.sort(allSeeds)
    return #allSeeds > 0 and allSeeds or {"WheatSeeds"} -- Fallback seguro
end

function Manager:AtualizarStatus(mensagem)
    local UI = _G.IslandsBot.Modules.UI
    if UI and UI.SetStatusText then UI:SetStatusText(mensagem) end
end

-- Mapeamento dos Remotes
local network = ReplicatedStorage:WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged")
Manager.HitRemote = network:WaitForChild("CLIENT_BLOCK_HIT_REQUEST")
Manager.PlaceRemote = network:WaitForChild("CLIENT_BLOCK_PLACE_REQUEST")
Manager.PlowRemote = network:WaitForChild("CLIENT_PLOW_BLOCK_REQUEST")
Manager.HarvestRemote = network:WaitForChild("CLIENT_HARVEST_CROP_REQUEST")

return Manager