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

-- ================= A REGRA DO INVENTÁRIO (Smarter Item Detection) =================
function Manager:GetInventoryTools(filtroTipo)
    local player = Players.LocalPlayer
    local toolsEncontradas = {}
    local processados = {}

    local function checarItem(item)
        if processados[item.Name] then return end
        
        local isValid = false
        local nLowerCase = item.Name:lower()

        if filtroTipo == "Seed" then
            -- Muitas sementes no Islands tem "seed" ou "sapling" no proprio nome da Tool
            if nLowerCase:match("seed") or nLowerCase:match("spore") or nLowerCase:match("sapling") then
                isValid = true
            else
                -- Caso o nome não seja claro, verifica o interior (antiga checagem, só por segurança)
                for _, child in ipairs(item:GetDescendants()) do
                    if child.Name:lower() == "seed" then
                        isValid = true; break
                    end
                end
            end
        elseif filtroTipo == "Block" then
            -- Busca no interior pela configuração "block-place" (nativo do islands)
            for _, child in ipairs(item:GetDescendants()) do
                if child.Name:lower() == "block-place" then
                    isValid = true; break
                end
            end
        end
        
        if isValid then
            table.insert(toolsEncontradas, item.Name)
            processados[item.Name] = true
        end
    end

    pcall(function()
        -- Character (equipado)
        if player.Character then
            for _, i in ipairs(player.Character:GetChildren()) do checarItem(i) end
        end
        -- Backpack (inventario real)
        local bp = player:FindFirstChild("Backpack")
        if bp then
            for _, i in ipairs(bp:GetChildren()) do checarItem(i) end
        end
    end)

    table.sort(toolsEncontradas)
    if #toolsEncontradas == 0 then table.insert(toolsEncontradas, "Nenhum item encontrado") end
    return toolsEncontradas
end

-- ================= A REGRA DAS SEMENTES GLOBAIS =================
function Manager:GetAllSeedsInGame()
    local allSeeds = {}
    local processados = {}
    
    pcall(function()
        local toolsFolder = ReplicatedStorage:FindFirstChild("Tools")
        if toolsFolder then
            for _, tool in ipairs(toolsFolder:GetChildren()) do
                if not processados[tool.Name] then
                    local nLowerCase = tool.Name:lower()
                    local isSeed = false
                    
                    -- Avaliação mais rápida e abrangente baseada no nome:
                    if nLowerCase:match("seed") or nLowerCase:match("sapling") then
                        isSeed = true
                    else
                        for _, child in ipairs(tool:GetDescendants()) do
                            if child.Name:lower() == "seed" then
                                isSeed = true; break
                            end
                        end
                    end
                    
                    if isSeed then
                        table.insert(allSeeds, tool.Name)
                        processados[tool.Name] = true
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