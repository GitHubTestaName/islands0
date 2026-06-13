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

-- ================= A REGRA EXATA DO INVENTÁRIO (Sementes Pessoais / Blocos) =================
function Manager:GetInventoryTools(filtroTipo)
    local player = Players.LocalPlayer
    local toolsEncontradas = {}
    local processados = {}

    local function checarItem(item)
        if not processados[item.Name] then
            local isValid = false
            
            -- Vasculha absolutamente tudo dentro do item, sem importar a classe
            local todosFilhos = item:GetDescendants()
            for i = 1, #todosFilhos do
                local child = todosFilhos[i]
                local cName = child.Name:lower()
                
                if filtroTipo == "Seed" and cName == "seed" then
                    isValid = true
                    break
                elseif filtroTipo == "Block" and cName == "block-place" then
                    isValid = true
                    break
                end
            end
            
            if isValid then
                table.insert(toolsEncontradas, item.Name)
                processados[item.Name] = true
            end
        end
    end

    pcall(function()
        -- 1. Verifica TUDO no Character (mão/equipado)
        if player.Character then
            local itensCharacter = player.Character:GetChildren()
            for i = 1, #itensCharacter do
                checarItem(itensCharacter[i])
            end
        end

        -- 2. Verifica TUDO no Backpack (mochila)
        local bp = player:FindFirstChild("Backpack")
        if bp then
            local itensMochila = bp:GetChildren()
            for i = 1, #itensMochila do
                checarItem(itensMochila[i])
            end
        end
    end)

    table.sort(toolsEncontradas)
    return toolsEncontradas
end

-- ================= A REGRA DAS SEMENTES GLOBAIS (Priorize Plant) =================
function Manager:GetAllSeedsInGame()
    local allSeeds = {}
    local processados = {}
    
    pcall(function()
        local toolsFolder = ReplicatedStorage:FindFirstChild("Tools")
        
        if toolsFolder then
            local todosOsItens = toolsFolder:GetChildren()
            
            -- Vasculha todos os itens guardados na pasta Tools do servidor
            for i = 1, #todosOsItens do
                local tool = todosOsItens[i]
                
                if not processados[tool.Name] then
                    local todosFilhosTool = tool:GetDescendants()
                    
                    for j = 1, #todosFilhosTool do
                        local child = todosFilhosTool[j]
                        if child.Name:lower() == "seed" then
                            table.insert(allSeeds, tool.Name)
                            processados[tool.Name] = true
                            break
                        end
                    end
                end
            end
        end
    end)
    
    table.sort(allSeeds)
    return allSeeds
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