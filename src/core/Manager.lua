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

-- ================= A REGRA EXATA DO INVENTÁRIO =================
function Manager:GetInventoryTools(filtroTipo)
    local player = Players.LocalPlayer
    local toolsEncontradas = {}
    local processados = {}

    local function checarTool(item)
        -- Regra 1: Tem que ser uma Tool
        if item:IsA("Tool") and not processados[item.Name] then
            local isValid = false
            
            -- Regra 2: Procura profundamente dentro da Tool
            for _, child in ipairs(item:GetDescendants()) do
                -- Regra 3: Exige que seja LocalScript com o nome certo
                if child:IsA("LocalScript") then
                    if filtroTipo == "Seed" and child.Name:lower() == "seed" then
                        isValid = true
                        break
                    elseif filtroTipo == "Block" and child.Name:lower() == "block-place" then
                        isValid = true
                        break
                    end
                end
            end
            
            if isValid then
                table.insert(toolsEncontradas, item.Name)
                processados[item.Name] = true
            end
        end
    end

    pcall(function()
        -- Lê o que o player tem equipado no corpo (Character)
        if player.Character then
            for _, obj in ipairs(player.Character:GetChildren()) do checarTool(obj) end
        end

        -- Lê a mochila do player (Backpack)
        local bp = player:FindFirstChild("Backpack")
        if bp then
            for _, obj in ipairs(bp:GetChildren()) do checarTool(obj) end
        end
    end)

    table.sort(toolsEncontradas)
    return toolsEncontradas
end

function Manager:GetAllSeedsInGame()
    local allSeeds = {}
    
    pcall(function()
        -- Regra Global: Vai direto na pasta Tools do Servidor
        local toolsFolder = ReplicatedStorage:FindFirstChild("Tools")
        if toolsFolder then
            for _, tool in ipairs(toolsFolder:GetChildren()) do
                -- Procura em todas as ferramentas/pastas guardadas ali
                for _, child in ipairs(tool:GetDescendants()) do
                    if child:IsA("LocalScript") and child.Name:lower() == "seed" then
                        if not table.find(allSeeds, tool.Name) then
                            table.insert(allSeeds, tool.Name)
                        end
                        break
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