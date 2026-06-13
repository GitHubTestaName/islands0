-- src/ui/tabs/FazendaTab.lua
local FazendaTab = {}

-- Motor Split 2 Colunas 400PX de Lado A. / Lado .B UX Core :
local function MontarCXLayoutLateralUXPlotSaverGearsGrid(tituloAbaaRxtxGrndFrtStrgBlcksStrRendrtXctMthStr, BasePxrtMnuFrmStckPrentrTogDplwtsStkrAtrsObjFrmBaseZIDXDrwsCnnvThtObjFctrBaseDsgDrpDw, CoresSistemaUXCoreBrthStles, PntCstrVntWtrGrndBlrDscXlsZnidXZndxRws)
    local bXb_CardMrgeClpBrderWthsCll_StlsBcsOvlrtDsRstRvsrZInxBxZdtzBxFlrClpFrmsCrClfWrdDrDrcBlkWlsF = Instance.new("Frame", BasePxrtMnuFrmStckPrentrTogDplwtsStkrAtrsObjFrmBaseZIDXDrwsCnnvThtObjFctrBaseDsgDrpDw)
    bXb_CardMrgeClpBrderWthsCll_StlsBcsOvlrtDsRstRvsrZInxBxZdtzBxFlrClpFrmsCrClfWrdDrDrcBlkWlsF.BackgroundColor3 = CoresSistemaUXCoreBrthStles.CardBG
    bXb_CardMrgeClpBrderWthsCll_StlsBcsOvlrtDsRstRvsrZInxBxZdtzBxFlrClpFrmsCrClfWrdDrDrcBlkWlsF.Size = UDim2.new(0, 400, 0, 0) 
    bXb_CardMrgeClpBrderWthsCll_StlsBcsOvlrtDsRstRvsrZInxBxZdtzBxFlrClpFrmsCrClfWrdDrDrcBlkWlsF.ZIndex = PntCstrVntWtrGrndBlrDscXlsZnidXZndxRws
    Instance.new("UICorner", bXb_CardMrgeClpBrderWthsCll_StlsBcsOvlrtDsRstRvsrZInxBxZdtzBxFlrClpFrmsCrClfWrdDrDrcBlkWlsF).CornerRadius = UDim.new(0, 6)
    
    local stkXdrZ = Instance.new("UIStroke", bXb_CardMrgeClpBrderWthsCll_StlsBcsOvlrtDsRstRvsrZInxBxZdtzBxFlrClpFrmsCrClfWrdDrDrcBlkWlsF)
    stkXdrZ.Color = CoresSistemaUXCoreBrthStles.CardStroke; stkXdrZ.Thickness = 1
    
    local rTtShtFrstStrTextWrdsStrHdrLbDrlzDtBlckZ = Instance.new("TextLabel", bXb_CardMrgeClpBrderWthsCll_StlsBcsOvlrtDsRstRvsrZInxBxZdtzBxFlrClpFrmsCrClfWrdDrDrcBlkWlsF)
    rTtShtFrstStrTextWrdsStrHdrLbDrlzDtBlckZ.Size = UDim2.new(1, 0, 0, 30); rTtShtFrstStrTextWrdsStrHdrLbDrlzDtBlckZ.BackgroundTransparency = 1
    rTtShtFrstStrTextWrdsStrHdrLbDrlzDtBlckZ.Text = "  " .. tituloAbaaRxtxGrndFrtStrgBlcksStrRendrtXctMthStr; rTtShtFrstStrTextWrdsStrHdrLbDrlzDtBlckZ.TextColor3 = CoresSistemaUXCoreBrthStles.AccentBlue
    rTtShtFrstStrTextWrdsStrHdrLbDrlzDtBlckZ.Font = Enum.Font.SourceSansBold; rTtShtFrstStrTextWrdsStrHdrLbDrlzDtBlckZ.TextSize = 14; rTtShtFrstStrTextWrdsStrHdrLbDrlzDtBlckZ.TextXAlignment = Enum.TextXAlignment.Left
    
    local ctxMnrXtrHdtCbxMnrsStrp = Instance.new("Frame", bXb_CardMrgeClpBrderWthsCll_StlsBcsOvlrtDsRstRvsrZInxBxZdtzBxFlrClpFrmsCrClfWrdDrDrcBlkWlsF)
    ctxMnrXtrHdtCbxMnrsStrp.Size = UDim2.new(1, 0, 1, -30); ctxMnrXtrHdtCbxMnrsStrp.Position = UDim2.new(0, 0, 0, 30)
    ctxMnrXtrHdtCbxMnrsStrp.BackgroundTransparency = 1
    ctxMnrXtrHdtCbxMnrsStrp.ClipsDescendants = false; bXb_CardMrgeClpBrderWthsCll_StlsBcsOvlrtDsRstRvsrZInxBxZdtzBxFlrClpFrmsCrClfWrdDrDrcBlkWlsF.ClipsDescendants = false

    local dRSpltRdYhTxLytFrmBdCtG = Instance.new("Frame", ctxMnrXtrHdtCbxMnrsStrp)
    dRSpltRdYhTxLytFrmBdCtG.Size = UDim2.new(0.48, 0, 1, 0); dRSpltRdYhTxLytFrmBdCtG.Position = UDim2.new(0.52, 0, 0, 0); dRSpltRdYhTxLytFrmBdCtG.BackgroundTransparency = 1
    local LYT__lRDXyztcFrGdTlpsPckPrc_RightDrsbLsLtBrDtBrkBdDr = Instance.new("UIListLayout", dRSpltRdYhTxLytFrmBdCtG)
    LYT__lRDXyztcFrGdTlpsPckPrc_RightDrsbLsLtBrDtBrkBdDr.Padding = UDim.new(0, 6); LYT__lRDXyztcFrGdTlpsPckPrc_RightDrsbLsLtBrDtBrkBdDr.HorizontalAlignment = Enum.HorizontalAlignment.Center
    
    local cntTrDrSlnWdrLncWdxTlkBrckYtXrFrCrXCtFrGrBcxBtrDrCtSl_DtLnDrBxStrTrXDrLFrDxSr_Z__MidlSpltClFrBxBrCrHlfHrDttDtZ_MidSpnZnXrTrfTrqTrCt = Instance.new("Frame", ctxMnrXtrHdtCbxMnrsStrp)
    cntTrDrSlnWdrLncWdxTlkBrckYtXrFrCrXCtFrGrBcxBtrDrCtSl_DtLnDrBxStrTrXDrLFrDxSr_Z__MidlSpltClFrBxBrCrHlfHrDttDtZ_MidSpnZnXrTrfTrqTrCt.Size = UDim2.new(0, 1, 1, -20); cntTrDrSlnWdrLncWdxTlkBrckYtXrFrCrXCtFrGrBcxBtrDrCtSl_DtLnDrBxStrTrXDrLFrDxSr_Z__MidlSpltClFrBxBrCrHlfHrDttDtZ_MidSpnZnXrTrfTrqTrCt.Position = UDim2.new(0.505, 0, 0, 10); cntTrDrSlnWdrLncWdxTlkBrckYtXrFrCrXCtFrGrBcxBtrDrCtSl_DtLnDrBxStrTrXDrLFrDxSr_Z__MidlSpltClFrBxBrCrHlfHrDttDtZ_MidSpnZnXrTrfTrqTrCt.BackgroundColor3 = CoresSistemaUXCoreBrthStles.PanelBG; cntTrDrSlnWdrLncWdxTlkBrckYtXrFrCrXCtFrGrBcxBtrDrCtSl_DtLnDrBxStrTrXDrLFrDxSr_Z__MidlSpltClFrBxBrCrHlfHrDttDtZ_MidSpnZnXrTrfTrqTrCt.BorderSizePixel = 0

    local eqESpTClLsFrDxbGtYRtXrLTrSl_ClSrdBrTlsRxGrSlvDtBxLtLxHlzS = Instance.new("Frame", ctxMnrXtrHdtCbxMnrsStrp)
    eqESpTClLsFrDxbGtYRtXrLTrSl_ClSrdBrTlsRxGrSlvDtBxLtLxHlzS.Size = UDim2.new(0.48, 0, 1, 0); eqESpTClLsFrDxbGtYRtXrLTrSl_ClSrdBrTlsRxGrSlvDtBxLtLxHlzS.BackgroundTransparency = 1
    local LYT__EqDSzRtXTrzClxVtrLxDrTlz__FrLfStrLSptZqBrSlDxLsCrsBxDrFrVltLtBndDtTckTqLSftSqLBrzSpG__Fr = Instance.new("UIListLayout", eqESpTClLsFrDxbGtYRtXrLTrSl_ClSrdBrTlsRxGrSlvDtBxLtLxHlzS)
    LYT__EqDSzRtXTrzClxVtrLxDrTlz__FrLfStrLSptZqBrSlDxLsCrsBxDrFrVltLtBndDtTckTqLSftSqLBrzSpG__Fr.Padding = UDim.new(0, 6); LYT__EqDSzRtXTrzClxVtrLxDrTlz__FrLfStrLSptZqBrSlDxLsCrsBxDrFrVltLtBndDtTckTqLSftSqLBrzSpG__Fr.HorizontalAlignment = Enum.HorizontalAlignment.Center

    Instance.new("UIPadding", eqESpTClLsFrDxbGtYRtXrLTrSl_ClSrdBrTlsRxGrSlvDtBxLtLxHlzS).PaddingTop = UDim.new(0, 8); Instance.new("UIPadding", dRSpltRdYhTxLytFrmBdCtG).PaddingTop = UDim.new(0, 8)
    
    local function UprRsxD() bXb_CardMrgeClpBrderWthsCll_StlsBcsOvlrtDsRstRvsrZInxBxZdtzBxFlrClpFrmsCrClfWrdDrDrcBlkWlsF.Size = UDim2.new(0, 400, 0, math.max(LYT__EqDSzRtXTrzClxVtrLxDrTlz__FrLfStrLSptZqBrSlDxLsCrsBxDrFrVltLtBndDtTckTqLSftSqLBrzSpG__Fr.AbsoluteContentSize.Y, LYT__lRDXyztcFrGdTlpsPckPrc_RightDrsbLsLtBrDtBrkBdDr.AbsoluteContentSize.Y) + 50) end
    LYT__EqDSzRtXTrzClxVtrLxDrTlz__FrLfStrLSptZqBrSlDxLsCrsBxDrFrVltLtBndDtTckTqLSftSqLBrzSpG__Fr:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UprRsxD); LYT__lRDXyztcFrGdTlpsPckPrc_RightDrsbLsLtBrDtBrkBdDr:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UprRsxD)
    
    return eqESpTClLsFrDxbGtYRtXrLTrSl_ClSrdBrTlsRxGrSlvDtBxLtLxHlzS, dRSpltRdYhTxLytFrmBdCtG, bXb_CardMrgeClpBrderWthsCll_StlsBcsOvlrtDsRstRvsrZInxBxZdtzBxFlrClpFrmsCrClfWrdDrDrcBlkWlsF
end


function FazendaTab:Construir(paginaPai)
    local Bot = _G.IslandsBot; local State = Bot.State
    local Compns = Bot.Modules.UIComponents; local Manager = Bot.Modules.Manager

    Compns:ResetOrder()

    -- 1: AGRO TÉCNICA E SETUP START:
    local CbIag_BxHrxBncBxZdxGltSpqRsSdrTrTrCrPrjDsLytFrmTctZrtF, XzbFrMn_OdsRxSlStrPjFzFqTsLrxCxBsBxZn = Compns:CriarCard("O.S E SETUP: TÉCNICA E AUTO-CULTIVO", paginaPai)
    
    Compns:CriarToggleLargo("🌾 Liga AI da Auto Plantações (All / Cultivos)", CbIag_BxHrxBncBxZdxGltSpqRsSdrTrTrCrPrjDsLytFrmTctZrtF, State, "AutoFarmingCrops", XzbFrMn_OdsRxSlStrPjFzFqTsLrxCxBsBxZn, function(v) 
        if Bot.Modules.Farmer then Bot.Modules.Farmer:AlternarAutoFazenda(v) end 
    end)
    Compns:CriarBotaoEstilizado("🚜 Ara Toda Areá Dentro Do Escalonamento Rapido", CbIag_BxHrxBncBxZdxGltSpqRsSdrTrTrCrPrjDsLytFrmTctZrtF, XzbFrMn_OdsRxSlStrPjFzFqTsLrxCxBsBxZn, function() 
        if Bot.Modules.Farmer then Bot.Modules.Farmer:ArarTerra() end 
    end)
    
    -- DropdownS : Eles vem pra fora caindo livres no render com alto Index (Subliminado de Bugs)! : 
    local SdzMchlQrx = Compns:CriarDropdown("🎒 Semente Manual.", CbIag_BxHrxBncBxZdxGltSpqRsSdrTrTrCrPrjDsLytFrmTctZrtF, State, "SementeSelecionada", true, XzbFrMn_OdsRxSlStrPjFzFqTsLrxCxBsBxZn + 60, true)
    local CndGBLR = Compns:CriarDropdown("🏆 Serv. (Preferidas):", CbIag_BxHrxBncBxZdxGltSpqRsSdrTrTrCrPrjDsLytFrmTctZrtF, State.FarmSettings, "PrioritizePlant", false, XzbFrMn_OdsRxSlStrPjFzFqTsLrxCxBsBxZn + 50, true)
    
    Compns:CriarBotaoEstilizado("🔄 Sinc. Database de Sementes Interna Client O.S.", CbIag_BxHrxBncBxZdxGltSpqRsSdrTrTrCrPrjDsLytFrmTctZrtF, XzbFrMn_OdsRxSlStrPjFzFqTsLrxCxBsBxZn, function()
        if Manager then
            SdzMchlQrx:Refresh(Manager:GetInventoryTools("Seed")); local glGgR = Manager:GetAllSeedsInGame()
            table.insert(glGgR, 1, "Nenhum") ; CndGBLR:Refresh(glGgR)
            Manager:AtualizarStatus("🌱 Banco Escaneado Pessoal Com Servidor do Play!")
        end
    end)

    -- =================== BLOCOS LATERAL MASTER - ESQUERDA  A & B  DIREITA !!  ==============
    local cSEqLtsSpWbTr, cDrtsSvtsRgsTsBlsCr = MontarCXLayoutLateralUXPlotSaverGearsGrid("SISTEMA DE L.V TERRAS SELETOR & GRAVA. / RESTAR", paginaPai, Compns.Theme, XzbFrMn_OdsRxSlStrPjFzFqTsLrxCxBsBxZn - 15)
    
    -- Lado <- ESQ (Lado DpADs da área Movment):
    Compns:CriarBotaoEstilizado("🟩 Abre o Target Front.", cSEqLtsSpWbTr, XzbFrMn_OdsRxSlStrPjFzFqTsLrxCxBsBxZn, function() 
        if State.ScannerFazenda then State.ScannerFazenda:CriarSeletorFrontal() end 
    end)
    Compns:CriarControlesEspaciais(cSEqLtsSpWbTr, XzbFrMn_OdsRxSlStrPjFzFqTsLrxCxBsBxZn, "ScannerFazenda")
    
    Compns:CriarToggleLargo("🙈 Núm Gui off.", cSEqLtsSpWbTr, State.ScannerFazenda, "HideNumbers", XzbFrMn_OdsRxSlStrPjFzFqTsLrxCxBsBxZn, function()
        if State.ScannerFazenda then State.ScannerFazenda:EscanearArea() end
    end)

    -- Lado -> DIR. (Geração Plot Texts Saves Lógick Sysys). Horizontal e Bonitão:
    local RwxGqRsdXrtPlxGrbxY_SrTsInpzMnBrzGrtFstLxrSpqDrFrSlX = Instance.new("Frame", cDrtsSvtsRgsTsBlsCr)
    RwxGqRsdXrtPlxGrbxY_SrTsInpzMnBrzGrtFstLxrSpqDrFrSlX.Size = UDim2.new(0.95, 0, 0, 32); RwxGqRsdXrtPlxGrbxY_SrTsInpzMnBrzGrtFstLxrSpqDrFrSlX.BackgroundTransparency = 1
    
    local NmsCrptBxtTsPqDxqWrRxTxDlzRtCmbFxLsH_DsTsStrCxXlsGtX = Compns:CriarInputLargo("Tagging Cóp.", RwxGqRsdXrtPlxGrbxY_SrTsInpzMnBrzGrtFstLxrSpqDrFrSlX, XzbFrMn_OdsRxSlStrPjFzFqTsLrxCxBsBxZn)
    NmsCrptBxtTsPqDxqWrRxTxDlzRtCmbFxLsH_DsTsStrCxXlsGtX.Size = UDim2.new(0.60, 0, 1, 0)

    local RxTbvBtTqCxSvBq_CxFntSrRsXbrYtrGlHkXmC = Compns:CriarBotaoEstilizado("💾 Svr", RwxGqRsdXrtPlxGrbxY_SrTsInpzMnBrzGrtFstLxrSpqDrFrSlX, XzbFrMn_OdsRxSlStrPjFzFqTsLrxCxBsBxZn, function()
        local FnxRxGtSrQxWrDtTctWstrSpRtsCxlSqtStWxsDsBr_FxLsHrTrMndPqrSt_LsGbxFTrXsGrZstTxtMnGtWrStFltDrHwStBrPrmzWbM = NmsCrptBxtTsPqDxqWrRxTxDlzRtCmbFxLsH_DsTsStrCxXlsGtX.Text
        local RkQbxTsBrLsStRxGrBrWrPlSpWtrFlCqDsSlStrQrqWtsFlLsWrRsSpHlzSlRxbDrPltSlSrStFqzBtzC = State.ScannerFazenda and State.ScannerFazenda.AncoraPart
        if FnxRxGtSrQxWrDtTctWstrSpRtsCxlSqtStWxsDsBr_FxLsHrTrMndPqrSt_LsGbxFTrXsGrZstTxtMnGtWrStFltDrHwStBrPrmzWbM == "" or not RkQbxTsBrLsStRxGrBrWrPlSpWtrFlCqDsSlStrQrqWtsFlLsWrRsSpHlzSlRxbDrPltSlSrStFqzBtzC then 
            if Manager then Manager:AtualizarStatus("❌ Falta Target Verde Na UI E Escrita. Tente criar dnv") end return 
        end
        Bot.Modules.PlotManager:SalvarPlot("Farming_"..FnxRxGtSrQxWrDtTctWstrSpRtsCxlSqtStWxsDsBr_FxLsHrTrMndPqrSt_LsGbxFTrXsGrZstTxtMnGtWrStFltDrHwStBrPrmzWbM, RkQbxTsBrLsStRxGrBrWrPlSpWtrFlCqDsSlStrQrqWtsFlLsWrRsSpHlzSlRxbDrPltSlSrStFqzBtzC.Position, RkQbxTsBrLsStRxGrBrWrPlSpWtrFlCqDsSlStrQrqWtsFlLsWrRsSpHlzSlRxbDrPltSlSrStFqzBtzC.Size)
        if _G.XgWxFmrXfCnsRfBxPlHwGrTrLSttTcsMncPrHrtFsStr then _G.XgWxFmrXfCnsRfBxPlHwGrTrLSttTcsMncPrHrtFsStr() end
        if Manager then Manager:AtualizarStatus("✅ Svs Terra Sálva :  [ ".. FnxRxGtSrQxWrDtTctWstrSpRtsCxlSqtStWxsDsBr_FxLsHrTrMndPqrSt_LsGbxFTrXsGrZstTxtMnGtWrStFltDrHwStBrPrmzWbM.." ] Gravadas no seu TXT C/") end; NmsCrptBxtTsPqDxqWrRxTxDlzRtCmbFxLsH_DsTsStrCxXlsGtX.Text = "" 
    end)
    RxTbvBtTqCxSvBq_CxFntSrRsXbrYtrGlHkXmC.Size = UDim2.new(0.38, 0, 1, 0); RxTbvBtTqCxSvBq_CxFntSrRsXbrYtrGlHkXmC.Position = UDim2.new(0.62, 0, 0, 0); RxTbvBtTqCxSvBq_CxFntSrRsXbrYtrGlHkXmC.BackgroundColor3 = Color3.fromRGB(15, 175, 45)

    -- DropList com Auto Refresh Evental via Variáveis do JOGO (_G.) Localizadas de Alta Instãncia! (+ 80 Para O Rosto dele Descer Cobre a fileira) :
    local YqTbPlxBstStLsnDpsFrmsFnxQstxRrStMndsTcxBsSrF = Compns:CriarDropdown("Sua Terrinha O.S:", cDrtsSvtsRgsTsBlsCr, State.FarmSettings, "CurrentSaveName", false, XzbFrMn_OdsRxSlStrPjFzFqTsLrxCxBsBxZn + 80, false)
    _G.XgWxFmrXfCnsRfBxPlHwGrTrLSttTcsMncPrHrtFsStr = function()
        if not Bot.Modules.PlotManager then return end
        local mRxZltTrMsdLzSrPqwFrTxGrYsxPnzNmtFrLsGtsCxGtrXtrFlBsMnFsSlGztPtxPtxBsSlGtTntRsFxDlx = {}
        for ngGZ, _ in pairs(Bot.Modules.PlotManager:ObterTodos()) do 
            if ngGZ:sub(1, 8) == "Farming_" then table.insert(mRxZltTrMsdLzSrPqwFrTxGrYsxPnzNmtFrLsGtsCxGtrXtrFlBsMnFsSlGztPtxPtxBsSlGtTntRsFxDlx, ngGZ:sub(9)) end 
        end
        YqTbPlxBstStLsnDpsFrmsFnxQstxRrStMndsTcxBsSrF:Refresh(#mRxZltTrMsdLzSrPqwFrTxGrYsxPnzNmtFrLsGtsCxGtrXtrFlBsMnFsSlGztPtxPtxBsSlGtTntRsFxDlx == 0 and {"Nenhum"} or mRxZltTrMsdLzSrPqwFrTxGrYsxPnzNmtFrLsGtsCxGtrXtrFlBsMnFsSlGztPtxPtxBsSlGtTntRsFxDlx)
    end
    
    local NmxRtFqMpsLxDtTrGrStFxBzMnCsMstCrStFlt = Compns:CriarGridTripla(cDrtsSvtsRgsTsBlsCr, XzbFrMn_OdsRxSlStrPjFzFqTsLrxCxBsBxZn)
    
    -- Compact A.Buttons ! : 
    Compns:CriarBotaoPequeno("Chama", Color3.fromRGB(30, 150, 80), NmxRtFqMpsLxDtTrGrStFxBzMnCsMstCrStFlt, XzbFrMn_OdsRxSlStrPjFzFqTsLrxCxBsBxZn, function()
        local Crg = State.FarmSettings.CurrentSaveName; if not Crg or Crg == "Nenhum" then return end
        local nCxLsGzRsBqzPrDtRsStrLzXrVdtQxtPlGTrtLzPcxBxCbzWxt_FrTsRbxDsQtxCrsFxTs = Bot.Modules.PlotManager:ObterTodos()["Farming_"..Crg]
        if nCxLsGzRsBqzPrDtRsStrLzXrVdtQxtPlGTrtLzPcxBxCbzWxt_FrTsRbxDsQtxCrsFxTs and State.ScannerFazenda then 
            State.ScannerFazenda:CarregarPlot(Vector3.new(nCxLsGzRsBqzPrDtRsStrLzXrVdtQxtPlGTrtLzPcxBxCbzWxt_FrTsRbxDsQtxCrsFxTs.PosX, nCxLsGzRsBqzPrDtRsStrLzXrVdtQxtPlGTrtLzPcxBxCbzWxt_FrTsRbxDsQtxCrsFxTs.PosY, nCxLsGzRsBqzPrDtRsStrLzXrVdtQxtPlGTrtLzPcxBxCbzWxt_FrTsRbxDsQtxCrsFxTs.PosZ), Vector3.new(nCxLsGzRsBqzPrDtRsStrLzXrVdtQxtPlGTrtLzPcxBxCbzWxt_FrTsRbxDsQtxCrsFxTs.SizeX, nCxLsGzRsBqzPrDtRsStrLzXrVdtQxtPlGTrtLzPcxBxCbzWxt_FrTsRbxDsQtxCrsFxTs.SizeY, nCxLsGzRsBqzPrDtRsStrLzXrVdtQxtPlGTrtLzPcxBxCbzWxt_FrTsRbxDsQtxCrsFxTs.SizeZ))
            if Manager then Manager:AtualizarStatus("🔄 Terra : [ " .. Crg.. " ] Levantara !") end 
        end
    end)
    Compns:CriarBotaoPequeno("Resta.", Color3.fromRGB(220, 140, 20), NmxRtFqMpsLxDtTrGrStFxBzMnCsMstCrStFlt, XzbFrMn_OdsRxSlStrPjFzFqTsLrxCxBsBxZn, function()
        if (State.FarmSettings.CurrentSaveName) ~= "Nenhum" and State.ScannerFazenda.AncoraPart then 
            Bot.Modules.PlotManager:SalvarPlot("Farming_"..State.FarmSettings.CurrentSaveName, State.ScannerFazenda.AncoraPart.Position, State.ScannerFazenda.AncoraPart.Size) 
            if Manager then Manager:AtualizarStatus("🔄 Arquitetura de ÁREAS Substituídas") end
        end
    end)
    Compns:CriarBotaoPequeno("X-Del", Color3.fromRGB(200, 50, 50), NmxRtFqMpsLxDtTrGrStFxBzMnCsMstCrStFlt, XzbFrMn_OdsRxSlStrPjFzFqTsLrxCxBsBxZn, function()
        if State.FarmSettings.CurrentSaveName ~= "Nenhum" then Bot.Modules.PlotManager:DeletarPlot("Farming_"..State.FarmSettings.CurrentSaveName); State.FarmSettings.CurrentSaveName="Nenhum"; _G.XgWxFmrXfCnsRfBxPlHwGrTrLSttTcsMncPrHrtFsStr(); if Manager then Manager:AtualizarStatus("♻️ Reciclados! ( Delet ) no S.o! :D" ) end end
    end)
    Compns:CriarToggleLargo("🖥️  Svs (B o o T)", cDrtsSvtsRgsTsBlsCr, State.FarmSettings, "AutoUseSelectedSave", XzbFrMn_OdsRxSlStrPjFzFqTsLrxCxBsBxZn, nil)


    -- =================== BLOCOS BAIXO = CONFIG. MÁQUINAS:   ==================
    local cxMnFr_BxTctBszR_PlRsSrqDtBxMxzSlGbxBxNszSrqRwtFxZztLzrPqCxDxTqx_FsTxtStrFzrVtcPrZqNbs, YxZsStrRsTxCrStrXrxBl = Compns:CriarCard("O.S MOTION  CONFIG-RULES E TWEAKS", paginaPai)
    
    local wLtsStrTrFstBsLsFxFrStrTrBsNtsTrNtzDxBxGrCsLsxYtRqCxDqzStBzLqFsGqtV_FrstHtzPrGtStrTq = Compns:CriarGridDupla(cxMnFr_BxTctBszR_PlRsSrqDtBxMxzSlGbxBxNszSrqRwtFxZztLzrPqCxDxTqx_FsTxtStrFzrVtcPrZqNbs, YxZsStrRsTxCrStrXrxBl)
    Compns:CriarCheckboxMetade("Hab. Motor Path. AutoVoo O.s Gui", wLtsStrTrFstBsLsFxFrStrTrBsNtsTrNtzDxBxGrCsLsxYtRqCxDqzStBzLqFsGqtV_FrstHtzPrGtStrTq, State.FarmSettings, "TweenToTarget", YxZsStrRsTxCrStrXrxBl)
    Compns:CriarInputMetade("Velc . Moto Vó.(Sp.I", wLtsStrTrFstBsLsFxFrStrTrBsNtsTrNtzDxBxGrCsLsxYtRqCxDqzStBzLqFsGqtV_FrstHtzPrGtStrTq, State.FarmSettings, "TweenSpeed", 20, YxZsStrRsTxCrStrXrxBl)
    
    local qBsRsGrMntsLsTsDqxLxTctYtsLrcGtRqzTsPlxBncLxsStrFtzRtGtsBrsPnrMtrCtsRnzDnxQzxCbtDrwStrZqzTsSlTztCrlXnrsDsRxFqxTsMxqRxYtRcqTxtSrFrBsLtSrPqbXrDtTxXtxQ = Compns:CriarGridDupla(cxMnFr_BxTctBszR_PlRsSrqDtBxMxzSlGbxBxNszSrqRwtFxZztLzrPqCxDxTqx_FsTxtStrFzrVtcPrZqNbs, YxZsStrRsTxCrStrXrxBl)
    Compns:CriarCheckboxMetade("Aut Replace On Destroy e Rmvz ", qBsRsGrMntsLsTsDqxLxTctYtsLrcGtRqzTsPlxBncLxsStrFtzRtGtsBrsPnrMtrCtsRnzDnxQzxCbtDrwStrZqzTsSlTztCrlXnrsDsRxFqxTsMxqRxYtRcqTxtSrFrBsLtSrPqbXrDtTxXtxQ, State.FarmSettings, "AutoReplace", YxZsStrRsTxCrStrXrxBl)
    Compns:CriarCheckboxMetade("Place. Bloc/Terra Grm Cnv..   ", qBsRsGrMntsLsTsDqxLxTctYtsLrcGtRqzTsPlxBncLxsStrFtzRtGtsBrsPnrMtrCtsRnzDnxQzxCbtDrwStrZqzTsSlTztCrlXnrsDsRxFqxTsMxqRxYtRcqTxtSrFrBsLtSrPqbXrDtTxXtxQ, State.FarmSettings, "PlaceGrass", YxZsStrRsTxCrStrXrxBl)
    
    task.spawn(function()
        task.wait(2); if _G.XgWxFmrXfCnsRfBxPlHwGrTrLSttTcsMncPrHrtFsStr then _G.XgWxFmrXfCnsRfBxPlHwGrTrLSttTcsMncPrHrtFsStr() end
        if Manager then SdzMchlQrx:Refresh(Manager:GetInventoryTools("Seed")); local gt = Manager:GetAllSeedsInGame(); table.insert(gt,1,"Nenhum"); CndGBLR:Refresh(gt) end
    end)
end

return FazendaTab