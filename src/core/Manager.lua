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
            elseif filtroTipo == "Seed" then
                -- PROCURA PELO NOME OU PELO SCRIPT INTERNO "SEED"
                local isSeed = item.Name:lower():match("seed") or item:FindFirstChild("cropSeed")
                if not isSeed then
                    for _, child in ipairs(item:GetChildren()) do
                        if child:IsA("LocalScript") and child.Name:lower() == "seed" then
                            isSeed = true break
                        end
                    end
                end
                
                if isSeed then
                    table.insert(toolsEncontradas, item.Name)
                    itensProcessados[item.Name] = true
                end
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

function Manager:GetAllSeedsInGame()
    local allSeeds = {}
    local rsTools = ReplicatedStorage:FindFirstChild("Tools")
    
    if rsTools then
        for _, tool in ipairs(rsTools:GetChildren()) do
            if tool:IsA("Tool") or tool:IsA("Folder") then
                -- LÓGICA CORRIGIDA: LÊ OS ARQUIVOS PROFUNDOS DOS DEVS
                local isSeed = tool.Name:lower():match("seed") or tool:FindFirstChild("cropSeed")
                if not isSeed then
                    for _, child in ipairs(tool:GetChildren()) do
                        if child:IsA("LocalScript") and child.Name:lower() == "seed" then
                            isSeed = true break
                        end
                    end
                end
                
                if isSeed and not table.find(allSeeds, tool.Name) then
                    table.insert(allSeeds, tool.Name)
                end
            end
        end
    end
    
    table.sort(allSeeds)
    return #allSeeds > 0 and allSeeds or {"Nenhuma Semente Encontrada"}
end

function Manager:AtualizarStatus(mensagem)
    local UI = _G.IslandsBot.Modules.UI
    if UI and UI.SetStatusText then UI:SetStatusText(mensagem) end
end

local network = ReplicatedStorage:WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged")
Manager.HitRemote = network:WaitForChild("CLIENT_BLOCK_HIT_REQUEST")
Manager.PlaceRemote = network:WaitForChild("CLIENT_BLOCK_PLACE_REQUEST")
Manager.PlowRemote = network:WaitForChild("CLIENT_PLOW_BLOCK_REQUEST")
Manager.HarvestRemote = network:WaitForChild("CLIENT_HARVEST_CROP_REQUEST")

return Manager