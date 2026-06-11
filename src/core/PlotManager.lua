-- src/core/PlotManager.lua
local HttpService = game:GetService("HttpService")
local PlotManager = {}

-- Nome do arquivo físico que será salvo na pasta "workspace" do seu executor
local FILE_NAME = "IslandsBot_FarmPlots.json"

-- Retorna todos os plots salvos no seu PC
function PlotManager:ObterTodos()
    if isfile and isfile(FILE_NAME) then
        local sucesso, dados = pcall(function()
            return HttpService:JSONDecode(readfile(FILE_NAME))
        end)
        if sucesso and type(dados) == "table" then
            return dados
        end
    end
    return {}
end

-- Salva um novo plot (Posição e Tamanho)
function PlotManager:SalvarPlot(nome, posicao, tamanho)
    if not writefile then 
        warn("Seu executor não suporta a função 'writefile' para salvar!")
        return false 
    end
    
    local plots = self:ObterTodos()
    
    plots[nome] = {
        PosX = posicao.X, PosY = posicao.Y, PosZ = posicao.Z,
        SizeX = tamanho.X, SizeY = tamanho.Y, SizeZ = tamanho.Z
    }
    
    local sucesso = pcall(function()
        writefile(FILE_NAME, HttpService:JSONEncode(plots))
    end)
    
    return sucesso
end

-- Deleta um plot específico
function PlotManager:DeletarPlot(nome)
    if not writefile then return false end
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