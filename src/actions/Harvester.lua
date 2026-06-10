-- src/actions/Harvester.lua
local Players = game:GetService("Players")
local Harvester = {}
local Bot = _G.IslandsBot
local State = Bot.State
local LocalPlayer = Players.LocalPlayer

-- Estado interno do farm agrícola
Harvester.Ativo = false
Harvester.AutoReplant = false

function Harvester:VerificarEColher(dadosBloco)
    local Manager = Bot.Modules.Manager
    local bloco = dadosBloco.Instancia
    if not bloco or not bloco:IsDescendantOf(workspace) then return false end

    local foiColhido = false

    -- 1. CASO TRIGO / CROPS PADRÃO (Verifica o BoolValue "Harvestable")
    local harvestableObj = bloco:FindFirstChild("Harvestable")
    if harvestableObj and harvestableObj:IsA("BoolValue") and harvestableObj.Value == true then
        local payload = {
            {
                dZnpyRtxna = "\a\240\159\164\163\240\159\164\161\a\n\a\n\a\nsDahbvdxZludavlcoipDDMYasPlcm",
                player = LocalPlayer,
                model = bloco
            }
        }
        local ok = pcall(function()
            Manager.HarvestRemote:InvokeServer(unpack(payload))
        end)
        if ok then foiColhido = true end
        
    -- 2. CASO ARBUSTO DE BERRY (berryBush)
    elseif bloco.Name == "berryBush" then
        local payload = {
            {
                dZnpyRtxna = "\a\240\159\164\163\240\159\164\161\a\n\a\n\a\nsDahbvdxZludavlcoipDDMYasPlcm",
                player = LocalPlayer,
                model = bloco
            }
        }
        local ok = pcall(function()
            Manager.HarvestRemote:InvokeServer(unpack(payload))
        end)
        if ok then foiColhido = true end

    -- 3. CASO ÁRVORE DE FRUTAS (Varre a pasta FruitLocations interna de forma recursiva)
    local fruitLocations = bloco:FindFirstChild("FruitLocations")
    if fruitLocations then
        for _, locPart in ipairs(fruitLocations:GetChildren()) do
            -- Procura por ferramentas/frutas penduradas
            for _, item in ipairs(locPart:GetChildren()) do
                if item:IsA("Tool") or item:IsA("Model") or item:FindFirstChild("DisplayName") then
                    local payload = {
                        {
                            dZnpyRtxna = "\a\240\159\164\163\240\159\164\161\a\n\a\n\a\nsDahbvdxZludavlcoipDDMYasPlcm",
                            player = LocalPlayer,
                            model = item
                        }
                    }
                    pcall(function()
                        Manager.HarvestRemote:InvokeServer(unpack(payload))
                    end)
                    foiColhido = true
                    task.wait(0.05)
                end
            end
        end
    end

    -- Se replantio estiver ativo e colhemos algo no chão, planta uma nova semente
    if foiColhido and self.AutoReplant then
        self:TentarReplantar(dadosBloco.Posicao)
    end

    return foiColhido
end

function Harvester:TentarReplantar(posicao)
    local Manager = Bot.Modules.Manager
    local char = LocalPlayer.Character
    if not char then return end

    -- Detecta se o jogador está segurando uma semente válida
    local tool = char:FindFirstChildOfClass("Tool")
    if tool and tool:FindFirstChild("LocalScript") then
        local payload = {
            uwhiHAMdjExWka = "\a\240\159\164\163\240\159\164\161\a\n\a\n\a\nffEgdldU",
            cframe = CFrame.new(posicao),
            blockType = tool.Name,
            upperBlock = false
        }
        pcall(function()
            Manager.PlaceRemote:InvokeServer(payload)
        end)
    end
end

function Harvester:LoopDeColheita()
    local Manager = Bot.Modules.Manager
    local Scanner = Bot.Modules.Scanner

    while self.Ativo do
        if Scanner then Scanner:EscanearArea() end
        
        local colheuAlgoNesteCiclo = false

        for _, dados in ipairs(State.ListaBlocos) do
            if not self.Ativo then break end
            
            local colheu = self:VerificarEColher(dados)
            if colheu then
                colheuAlgoNesteCiclo = true
                task.wait(0.1) -- Delay para evitar sobrecarga
            end
        end

        if not colheuAlgoNesteCiclo then
            if Manager then Manager:AtualizarStatus("Aguardando plantações crescerem...") end
            task.wait(1)
        end
        task.wait(0.2)
    end
end

function Harvester:SetAtivo(valor)
    self.Ativo = valor
    if valor then
        task.spawn(function()
            self:LoopDeColheita()
        end)
    else
        local Manager = Bot.Modules.Manager
        if Manager then Manager:AtualizarStatus("Ocioso") end
    end
end

function Harvester:SetAutoReplant(valor)
    self.AutoReplant = valor
end

return Harvester