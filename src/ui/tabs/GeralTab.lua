-- src/ui/tabs/GeralTab.lua
local GeralTab = {}

-- Motor Local Interno do Nosso UI "Split Duplo Lado a Lado":
local function CriarSuperCaixa(titulo, parent, themeBase, Zidx)
    local card = Instance.new("Frame", parent)
    card.BackgroundColor3 = themeBase.CardBG
    card.Size = UDim2.new(0, 400, 0, 0) -- Mega largo cobrindo muito a lateral de sua Aba Window Padrão!
    card.ZIndex = Zidx
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)
    
    local stroke = Instance.new("UIStroke", card)
    stroke.Color = themeBase.CardStroke; stroke.Thickness = 1
    
    local txtT = Instance.new("TextLabel", card)
    txtT.Size = UDim2.new(1, 0, 0, 30); txtT.BackgroundTransparency = 1
    txtT.Text = "  " .. titulo; txtT.TextColor3 = themeBase.AccentBlue
    txtT.Font = Enum.Font.SourceSansBold; txtT.TextSize = 14; txtT.TextXAlignment = Enum.TextXAlignment.Left
    
    local content = Instance.new("Frame", card)
    content.Size = UDim2.new(1, 0, 1, -30)
    content.Position = UDim2.new(0, 0, 0, 30); content.BackgroundTransparency = 1
    -- Impede cortes bruscos que escondiam as suas abinhas DropDown caindo. (Liberando Queda Limpa):
    content.ClipsDescendants = false; card.ClipsDescendants = false
    
    -- Metade C:
    local fDir = Instance.new("Frame", content)
    fDir.Size = UDim2.new(0.48, 0, 1, 0)
    fDir.Position = UDim2.new(0.52, 0, 0, 0)
    fDir.BackgroundTransparency = 1
    local lR = Instance.new("UIListLayout", fDir)
    lR.Padding = UDim.new(0, 6); lR.HorizontalAlignment = Enum.HorizontalAlignment.Center
    
    -- Linha da Separação Mágica L. / .R central :
    local lne = Instance.new("Frame", content)
    lne.Size = UDim2.new(0, 1, 1, -20); lne.Position = UDim2.new(0.505, 0, 0, 10)
    lne.BackgroundColor3 = themeBase.PanelBG; lne.BorderSizePixel = 0

    -- Metade L:
    local fEsq = Instance.new("Frame", content)
    fEsq.Size = UDim2.new(0.48, 0, 1, 0)
    fEsq.Position = UDim2.new(0, 0, 0, 0)
    fEsq.BackgroundTransparency = 1
    local lL = Instance.new("UIListLayout", fEsq)
    lL.Padding = UDim.new(0, 6); lL.HorizontalAlignment = Enum.HorizontalAlignment.Center

    Instance.new("UIPadding", fEsq).PaddingTop = UDim.new(0, 8)
    Instance.new("UIPadding", fDir).PaddingTop = UDim.new(0, 8)
    
    local function ResizeDyn() 
        card.Size = UDim2.new(0, 400, 0, math.max(lL.AbsoluteContentSize.Y, lR.AbsoluteContentSize.Y) + 50) 
    end
    lL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(ResizeDyn)
    lR:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(ResizeDyn)
    
    return fEsq, fDir, card
end


function GeralTab:Construir(paginaPai)
    local Bot = _G.IslandsBot; local State = Bot.State
    local Cps = Bot.Modules.UIComponents; local Manager = Bot.Modules.Manager

    Cps:ResetOrder()

    -- [ BLOCO CLÁSSICO SUPERIOR / SETUP TÉCNICA E AUTO]:
    local cxOp, zOp = Cps:CriarCard("PAINEL GERAL AZUL", paginaPai)
    
    Cps:CriarToggleLargo("⛏️ Ligar IA (Minerador Azul)", cxOp, State, "Minerando", zOp, function(v) 
        if Bot.Modules.Miner then Bot.Modules.Miner:Alternar(v) end 
    end)
    Cps:CriarBotaoEstilizado("🔨 Start Construir Base no Plot Azul", cxOp, zOp, function() 
        if Bot.Modules.Builder then Bot.Modules.Builder:ColocarAreaMarcada() end 
    end)
    
    -- Ajuste dos nomes grandes da aba da lista cortando palavras mortas de sua label / "C."=Construct...
    local DpdMat = Cps:CriarDropdown("Bag(C.):", cxOp, State, "BlocoSelecionado", false, zOp + 50, true)
    
    Cps:CriarBotaoEstilizado("🔄 Sincronizar Novos Drops na Bag", cxOp, zOp, function() 
        if Manager then DpdMat:Refresh(Manager:GetInventoryTools("Block")) 
        Manager:AtualizarStatus("🔨 Escaneada os DropBox atuais pra base Local do Client.") end 
    end)
    

    -- ================= A MAGIA COMPLETA DE DOIS-EIXOSUX: GESTOR ÁREA MASTER AZUL=================
    local MtrEsq, MtrDir = CriarSuperCaixa("SELETOR DE AZUIS & GRAVAÇÃO PLOTS O.S", paginaPai, Cps.Theme, zOp - 10)
    
    -- (Esquerda:) Criações + Movimentações DPADS:
    Cps:CriarBotaoEstilizado("🟦 Ligar (Visor. do Seletor)", MtrEsq, zOp, function() 
        if State.ScannerGeral then State.ScannerGeral:CriarSeletorFrontal() end 
    end)
    
    Cps:CriarControlesEspaciais(MtrEsq, zOp, "ScannerGeral")
    
    Cps:CriarToggleLargo("🙈 Esconder Holograma Nos Nums", MtrEsq, State.ScannerGeral, "HideNumbers", zOp, function()
        if State.ScannerGeral then State.ScannerGeral:EscanearArea() end
    end)
    

    -- (Direita:) Nomes / Salvas e Recarga dos mapas Arquivos Lógica Compactada Horizontal !
    local paineInputMnt = Instance.new("Frame", MtrDir)
    paineInputMnt.Size = UDim2.new(0.95, 0, 0, 32); paineInputMnt.BackgroundTransparency = 1
    
    local nomeDigTxt = Cps:CriarInputLargo("Tague o mapa.", paineInputMnt, zOp)
    nomeDigTxt.Size = UDim2.new(0.60, 0, 1, 0)
    
    local btnGtSav = Cps:CriarBotaoEstilizado("💾 O.K", paineInputMnt, zOp, function()
        if nomeDigTxt.Text == "" or not (State.ScannerGeral and State.ScannerGeral.AncoraPart) then 
            if Manager then Manager:AtualizarStatus("❌ Faltou Seletor no Jogo ou um texto em caixas pra agir!") end return 
        end
        Bot.Modules.PlotManager:SalvarPlot("Mining_"..nomeDigTxt.Text, State.ScannerGeral.AncoraPart.Position, State.ScannerGeral.AncoraPart.Size)
        -- Variável "UpdateGlobalDataLocListMining_Ativa_RefreshDorp" (pressionar chamava refresh aqui)!
        if _G.upMnrDropListActionRefreshBotLogicFlowGbl then _G.upMnrDropListActionRefreshBotLogicFlowGbl() end
        if Manager then Manager:AtualizarStatus("✅ Save Salvo. Confirme abaixo a Tag Criada.") end; nomeDigTxt.Text = ""
    end)
    btnGtSav.Size = UDim2.new(0.38, 0, 1, 0); btnGtSav.Position = UDim2.new(0.62, 0, 0, 0)
    btnGtSav.BackgroundColor3 = Color3.fromRGB(0, 160, 200)

    -- Index alto aqui (+80): Superando TODOS abaixo para abrir gavetão Lado R tranquilamente.
    local dbSvsAzulMnrSys = Cps:CriarDropdown("Memórias:", MtrDir, State.MiningSettings, "CurrentSaveName", false, zOp + 80, false)
    _G.upMnrDropListActionRefreshBotLogicFlowGbl = function()
        if not Bot.Modules.PlotManager then return end
        local stfListaMapas = {}
        for ngGZ, _ in pairs(Bot.Modules.PlotManager:ObterTodos()) do 
            if ngGZ:sub(1, 7) == "Mining_" then table.insert(stfListaMapas, ngGZ:sub(8)) end 
        end
        dbSvsAzulMnrSys:Refresh(#stfListaMapas == 0 and {"Nenhum"} or stfListaMapas)
    end
    
    local MtrDirPcsActsMenuHorizontalRowsMinigSveLogcsTridpd = Cps:CriarGridTripla(MtrDir, zOp)
    
    -- Sub botões Minimalistas Curtíssimos/Eficientes para Caber: (Uso por CORES indicando Funções Intuitivas de perigo ou O.K).
    Cps:CriarBotaoPequeno("Subir", Color3.fromRGB(30, 140, 60), MtrDirPcsActsMenuHorizontalRowsMinigSveLogcsTridpd, zOp, function()
        local crNomeCarga = State.MiningSettings.CurrentSaveName
        if not crNomeCarga or crNomeCarga == "Nenhum" then return end
        local rTData = Bot.Modules.PlotManager:ObterTodos()["Mining_"..crNomeCarga]
        if rTData and State.ScannerGeral then 
             State.ScannerGeral:CarregarPlot(Vector3.new(rTData.PosX, rTData.PosY, rTData.PosZ), Vector3.new(rTData.SizeX, rTData.SizeY, rTData.SizeZ)) 
        end
    end)
    Cps:CriarBotaoPequeno("Repo.", Color3.fromRGB(220, 120, 20), MtrDirPcsActsMenuHorizontalRowsMinigSveLogcsTridpd, zOp, function()
        local stfAncDataXgObjGrdPoxWdtCubeObrdrncs = State.ScannerGeral and State.ScannerGeral.AncoraPart
        if (State.MiningSettings.CurrentSaveName) ~= "Nenhum" and stfAncDataXgObjGrdPoxWdtCubeObrdrncs then 
             Bot.Modules.PlotManager:SalvarPlot("Mining_"..State.MiningSettings.CurrentSaveName, stfAncDataXgObjGrdPoxWdtCubeObrdrncs.Position, stfAncDataXgObjGrdPoxWdtCubeObrdrncs.Size) 
             if Manager then Manager:AtualizarStatus("🔁 Corrigida as Áreas Requerida Com Reposição local") end
        end
    end)
    Cps:CriarBotaoPequeno("Del.", Color3.fromRGB(200, 50, 40), MtrDirPcsActsMenuHorizontalRowsMinigSveLogcsTridpd, zOp, function()
        if State.MiningSettings.CurrentSaveName ~= "Nenhum" then
            Bot.Modules.PlotManager:DeletarPlot("Mining_" .. State.MiningSettings.CurrentSaveName)
            State.MiningSettings.CurrentSaveName = "Nenhum"
            if Manager then Manager:AtualizarStatus("🗑️ File Limpado (Limpar Local)."); _G.upMnrDropListActionRefreshBotLogicFlowGbl() end
        end
    end)

    Cps:CriarToggleLargo("💽 Boot / Start Auto Load do Select", MtrDir, State.MiningSettings, "AutoUseSelectedSave", zOp, nil)

    -- [ COMPORTAMENTO FLUIDO BOTS] Embaichooo
    local cFlutCFXTrn, ZidxBaseFluidCX = Cps:CriarCard("O.S MOTION IA VOO MINER.", paginaPai)
    local grdRfxTrfXzWdw = Cps:CriarGridDupla(cFlutCFXTrn, ZidxBaseFluidCX)
    Cps:CriarCheckboxMetade("Habilitar Guias voos", grdRfxTrfXzWdw, State.MiningSettings, "TweenToTarget", ZidxBaseFluidCX)
    Cps:CriarInputMetade("Velocida.(s)", grdRfxTrfXzWdw, State.MiningSettings, "TweenSpeed", 20, ZidxBaseFluidCX)
    

    task.spawn(function()
        task.wait(1.5)
        if _G.upMnrDropListActionRefreshBotLogicFlowGbl then _G.upMnrDropListActionRefreshBotLogicFlowGbl() end
    end)
end

return GeralTab