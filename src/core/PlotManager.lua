-- src/core/PlotManager.lua
local HttpService = game:GetService("HttpService")
local PlotManager = {}

-- Modificado para usar extensão de arquivo normal de texto! 
-- Os executors Roblox detestam extensões atípicas ou travam.
local FILE_NAME = "IslandsBot_PlotsSave.txt"

function PlotManager:ObterTodos()
    if type(isfile) == "function" and type(readfile) == "function" then
        if isfile(FILE_NAME) then
            local sucesso, dadosJSON = pcall(function()
                return readfile(FILE_NAME)
            end)
            if sucesso and dadosJSON then
                local objSucesso, dadosTable = pcall(function()
                    return HttpService:JSONDecode(dadosJSON)
                end)
                if objSucesso and type(dadosTable) == "table" then
                    return dadosTable
                end
            end
        end
    end
    return {} -- Volta Vazio se não achar
end

function PlotManager:SalvarPlot(nome, posicao, tamanho)
    if type(writefile) ~= "function" then 
        warn("ERRO (IslandsBot): Seu executor não suporta salvar arquivos locais no PC/Celular!")
        return false 
    end
    
    local plots = self:ObterTodos()
    
    -- Correção dos Math: Encapsula em Floats seguros para garantir encoding de sucesso
    plots[nome] = {
        PosX = math.floor(posicao.X * 100) / 100, 
        PosY = math.floor(posicao.Y * 100) / 100, 
        PosZ = math.floor(posicao.Z * 100) / 100,
        SizeX = math.floor(tamanho.X * 100) / 100, 
        SizeY = math.floor(tamanho.Y * 100) / 100, 
        SizeZ = math.floor(tamanho.Z * 100) / 100
    }
    
    local sucesso, err = pcall(function()
        local dataFormat = HttpService:JSONEncode(plots)
        writefile(FILE_NAME, dataFormat)
    end)
    
    if not sucesso then
        warn("ERRO CRÍTICO no Bot para Salvar. Verifique sua pasta 'workspace' do seu software: ", err)
    end
    
    return sucesso
end

function PlotManager:DeletarPlot(nome)
    if type(writefile) ~= "function" then return false end
    local plots = self:ObterTodos()
    
    if plots[nome] then
        plots[nome] = nil
        pcall(function()
            writefile(FILE_NAME, HttpService:JSONEncode(plots))
        end)
        return true
    end
    return false
end

return PlotManager