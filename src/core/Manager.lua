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

-- ================= A NOVA INTELIGÊNCIA DE FERRAMENTAS =================
function Manager:GetInventoryTools(filtroTipo)
    local player = Players.LocalPlayer
    local toolsEncontradas = {}
    local itensProcessados = {}

    local function processarItem(item)
        if item:IsA("Tool") and not itensProcessados[item.Name] then
            local atendeFiltro = false
            
            -- Faz a varredura profunda procurando o LocalScript exato
            for _, child in ipairs(item:GetDescendants()) do
                if child:IsA("LocalScript") then
                    local lowerName = child.Name:lower()
                    if filtroTipo == "Block" and lowerName == "block-place" then
                        atendeFiltro = true
                        break
                    elseif filtroTipo == "Seed" and lowerName == "seed" then
                        atendeFiltro = true
                        break
                    end
                end
            end

            if atendeFiltro then
                table.insert(toolsEncontradas, item.Name)
                itensProcessados[item.Name] = true
            end
        end
    end

    -- Lê o que está na mão do boneco
    if player.Character then
        for _, item in ipairs(player.Character:GetChildren()) do processarItem(item) end
    end
    -- Lê o que está na mochila
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _, item in ipairs(backpack:GetChildren()) do processarItem(item) end
    end

    table.sort(toolsEncontradas)
    return toolsEncontradas
end

function Manager:GetAllSeedsInGame()
    local allSeeds = {}
    local rsTools = ReplicatedStorage:FindFirstChild("Tools")
    
    if rsTools then
        for _, tool in ipairs(rsTools:GetChildren()) do
            if tool:IsA("Tool") or tool:IsA("Folder") then
                -- Busca implacável pelo LocalScript "seed" nos arquivos do jogo
                for _, child in ipairs(tool:GetDescendants()) do
                    if child:IsA("LocalScript") and child.Name:lower() == "seed" then
                        if not table.find(allSeeds, tool.Name) then
                            table.insert(allSeeds, tool.Name)
                        end
                        break -- Achou, vai para a próxima ferramenta
                    end
                end
            end
        end
    end
    
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