--[[
JP - Auto Skill - Death Ball
Analisado e refatorado para maior eficiência e robustez.
Versão 9: Implementado monitoramento ativo para garantir a detecção de mudança de campeão.
]]

--[[ SERVIços ]]
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")

--[[ BIBLIOTECA E VARIÁVEIS LOCAIS ]]
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/weakhoes/Roblox-UI-Libs/refs/heads/main/Orion%20Lib/Orion%20Lib%20Source.lua')))()
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--[[ CONFIGURAÇÃO ]]
local CONFIG = {
    Enabled = true,
    Debug = true,
    Priorities = {1, 2, 3, 4}, -- Prioridade inicial
    
    -- Seção central para configurar presets de prioridade.
    Presets = {
        ["0 - Kameki"] = {1, 2, 3, 4},
		["1 - Saito e Gazo"] = {1, 4, 2, 3},
        ["2 - Foxuro e Keilo"] = {1, 2, 4, 3},
        ["3 - Gloom"] = {2, 4, 1, 3},
		["4 - Koju"] = {1, 3, 4, 2},
		["5 - Lufus"] = {1, 4, 3, 2	},
        ["6 - JJ"] = {4, 3, 2, 1},
        ["7 - Friera"] = {4, 2, 1, 3},
        ["8 - Wu"] = {3, 4, 1, 2},
		["TesteFoxuro"] = {4, 1, 2, 3},
    },

    -- Mapa de habilidades para campeões (DE/PARA)
    ChampionPresetsMap = {
        ["EXTEND-O ARM"] = "Lufus", ["GUM GUM BALLOON"] = "Lufus", ["GLASS WALL"] = "Lufus", ["TIME HAKI"] = "Lufus",
        ["FAKE BALL"] = "Gazo", ["PHASE DASH"] = "Gazo", ["BLINDFOLD"] = "Gazo", ["ASTRAL PORTAL"] = "Gazo", ["CURSED BLUE"] = "Gazo",
        ["UPPER CUT"] = "Saito", ["SUPER JUMP"] = "Saito", ["SONIC SLIDE"] = "Saito", ["GROUND WALLS"] = "Saito", ["AFTERSHOCK"] = "Saito",
        ["KI BLAST"] = "Kameki", ["DRAGON RUSH"] = "Kameki", ["INSTANT TRAVEL"] = "Kameki", ["DEATH BALL"] = "Kameki",
        ["ZAP FREEZE"] = "Keilo", ["GODSPEED"] = "Keilo", ["ASSASSIN INVISIBILITY"] = "Keilo", ["LIGHTNING INTERCEPT"] = "Keilo", ["ZAP DEFLECT"] = "Keilo",
        ["GEM HUNT"] = "Gemtoki", ["DOUBLE OR NOTHING"] = "Gemtoki", ["CASH OUT"] = "Gemtoki", ["DONATE"] = "Gemtoki",
        ["NINJA RUN"] = "Foxuro", ["SHADOW CLONE"] = "Foxuro", ["TREE JUMP"] = "Foxuro", ["FOX ARMOUR"] = "Foxuro",
        ["LEAP STRIKE"] = "Koju", ["SPIRIT WALL"] = "Koju", ["CHAIN SPEAR"] = "Koju", ["HANDGUN"] = "Koju",
        ["EGOIST WARP"] = "Senshu", ["CHARGED KICK"] = "Senshu", ["YELLOW CARD"] = "Senshu", ["JUGGLING BLAST"] = "Senshu",
        ["SWITCH ELEMENTS"] = "Torokai", ["ICE SLIDE"] = "Torokai", ["FIRE DASH"] = "Torokai", ["ICE ZONE"] = "Torokai", ["FIRE ZONE"] = "Torokai", ["ICE SHIELD"] = "Torokai", ["FIRE BALL"] = "Torokai",
        ["BOMB JUMP"] = "Jiro", ["BONK"] = "Jiro", ["SIDESTEP"] = "Jiro", ["BUNGEE"] = "Jiro",
        ["JET DASH"] = "Denjin", ["GRAVITY HOLD"] = "Denjin", ["ORBITAL CANNON"] = "Denjin", ["OVERHEAT"] = "Denjin",
        ["SHADOW RAMPAGE"] = "Gloom", ["DARK REVERSAL"] = "Gloom", ["DREAD SPHERE"] = "Gloom", ["PHANTOM GRASP"] = "Gloom",
        ["SKY GLIDE"] = "Friera", ["MANA SHOT"] = "Friera", ["RUNEGUARD"] = "Friera", ["SINGULARITY"] = "Friera",
        ["DAGGER DASH"] = "Wu", ["BLINK"] = "Wu", ["RULERS HOLD"] = "Wu", ["ARISE"] = "Wu", ["BLINK (TELEPORT)"] = "Wu",
        ["PHANTOM SLAP"] = "JJ", ["REVENGE"] = "JJ", ["FIST BARRAGE"] = "JJ", ["STANDOFF"] = "JJ"
    },

    FastTriggerAbilities = {
        ["SUPER JUMP"] = true, ["CHAIN SPEAR"] = true, ["SKY GLIDE"] = true, ["DARK REVERSAL"] = true,
    },
    DoublePressAbilities = {
        ["SHADOW CLONE"] = true,
    },
    Keybinds = {
        Enum.KeyCode.One, Enum.KeyCode.Two,
        Enum.KeyCode.Three, Enum.KeyCode.Four
    },
    ParryAbilities = {
        -- Lufus
        ["EXTEND-O ARM"]=true, ["GUM GUM BALLOON"]=true, ["GLASS WALL"]=true, ["TIME HAKI"]=true,
        ["FAKE BALL"]=true, ["PHASE DASH"]=true, ["BLINDFOLD"]=true, ["ASTRAL PORTAL"]=true, ["CURSED BLUE"]=true,
        ["UPPER CUT"]=true, ["SUPER JUMP"]=true, ["SONIC SLIDE"]=true, ["GROUND WALLS"]=true, ["AFTERSHOCK"]=true,
        ["KI BLAST"]=true, ["DRAGON RUSH"]=true, ["INSTANT TRAVEL"]=true, ["DEATH BALL"]=true,
        ["ZAP FREEZE"]=true, ["GODSPEED"]=true, ["ASSASSIN INVISIBILITY"]=true, ["LIGHTNING INTERCEPT"]=true, ["ZAP DEFLECT"]=true,
        ["GEM HUNT"]=true, ["DOUBLE OR NOTHING"]=true, ["CASH OUT"]=true, ["DONATE"]=true,
        ["NINJA RUN"]=true, ["SHADOW CLONE"]=true, ["TREE JUMP"]=true, ["FOX ARMOUR"]=true,
        ["LEAP STRIKE"]=true, ["SPIRIT WALL"]=true, ["CHAIN SPEAR"]=true, ["HANDGUN"]=true,
        ["EGOIST WARP"]=true, ["CHARGED KICK"]=true, ["YELLOW CARD"]=true, ["JUGGLING BLAST"]=true,
        ["SWITCH ELEMENTS"]=true, ["ICE SLIDE"]=true, ["FIRE DASH"]=true, ["ICE ZONE"]=true, ["FIRE ZONE"]=true, ["ICE SHIELD"]=true, ["FIRE BALL"]=true,
        ["BOMB JUMP"]=true, ["BONK"]=true, ["SIDESTEP"]=true, ["BUNGEE"]=true,
        ["JET DASH"]=true, ["GRAVITY HOLD"]=true, ["ORBITAL CANNON"]=true, ["OVERHEAT"]=true,
        ["SHADOW RAMPAGE"]=true, ["DARK REVERSAL"]=true, ["DREAD SPHERE"]=true, ["PHANTOM GRASP"]=true,
        ["SKY GLIDE"]=true, ["MANA SHOT"]=true, ["RUNEGUARD"]=true, ["SINGULARITY"]=true,
        ["DAGGER DASH"]=true, ["BLINK"]=true, ["RULERS HOLD"]=true, ["ARISE"]=true, ["BLINK (TELEPORT)"]=true,
        ["PHANTOM SLAP"]=true, ["REVENGE"]=true, ["FIST BARRAGE"]=true, ["STANDOFF"]=true
    }
}

--[[ INTERFACE GRÁFICA (UI) ]]
local Window = OrionLib:MakeWindow({
    Name = "Ability Control Panel", HidePremium = false,
    SaveConfig = true, ConfigFolder = "OrionAbilityControl_V3", -- MUDANÇA: Nome da pasta alterado para forçar novas configurações
    Size = UDim2.new(0, 500, 0, 420),
    Position = UDim2.new(0, 30, 0, 30),
    ToggleKey = Enum.KeyCode.RightShift,
    StarterOpened = false -- Define que a UI começa fechada
})
local Tab = Window:MakeTab({
    Name = "Ability Settings", Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

--[[ ELEMENTOS DA UI ]]
Tab:AddToggle({ Name = "Enable Auto Skill", Default = CONFIG.Enabled, Callback = function(value) CONFIG.Enabled = value end })
Tab:AddToggle({ Name = "Debug Mode", Default = CONFIG.Debug, Callback = function(value) CONFIG.Debug = value end })
Tab:AddLabel("Prioridade de Uso das Habilidades")

local prioritySliders = {}
local presetDropdown = nil
local activePresetLabel = nil

local function debugPrint(...)
    if CONFIG.Debug then print("[DEBUG]", ...) end
end

local function applyPriorityPreset(presetName)
    local newPriorities = CONFIG.Presets[presetName]
    if not newPriorities then return end

    CONFIG.Priorities = newPriorities
    for i = 1, 4 do
        if prioritySliders[i] then prioritySliders[i]:Set(CONFIG.Priorities[i]) end
    end
    
    if activePresetLabel then activePresetLabel:Set("Preset Ativo: " .. presetName) end
    debugPrint("Preset de prioridade aplicado:", presetName)
end

local presetOptions = {}
for name in pairs(CONFIG.Presets) do table.insert(presetOptions, name) end
table.sort(presetOptions)

presetDropdown = Tab:AddDropdown({
    Name = "Presets de Prioridade", Default = "Selecionar Manualmente...",
    Options = presetOptions, Callback = function(preset) applyPriorityPreset(preset) end
})
activePresetLabel = Tab:AddLabel("Preset Ativo: Nenhum")

local function updatePriorities(changedSlot, newPriority)
    if CONFIG.Priorities[changedSlot] == newPriority then return end
    local oldPriority = CONFIG.Priorities[changedSlot]
    for slot, priority in ipairs(CONFIG.Priorities) do
        if slot ~= changedSlot and priority == newPriority then
            CONFIG.Priorities[slot] = oldPriority
            prioritySliders[slot]:Set(oldPriority)
            break
        end
    end
    CONFIG.Priorities[changedSlot] = newPriority
end

for i = 1, 4 do
    prioritySliders[i] = Tab:AddSlider({
        Name = "Prioridade Slot " .. i, Min = 1, Max = 4,
        Default = CONFIG.Priorities[i], Round = 0,
        Callback = function(value) updatePriorities(i, value) end
    })
end

--[[ FUNÇÕES PRINCIPAIS ]]
local function detectAndApplyChampionPreset(toolbarButtons)
    local championCounts = {}
    local mostFrequentChampion = nil
    local maxCount = 0

    for i = 1, 4 do
        local button = toolbarButtons:FindFirstChild("AbilityButton" .. i)
        if button and button:FindFirstChild("AbilityNameLabel") then
            local abilityName = button.AbilityNameLabel.Text
            local championName = CONFIG.ChampionPresetsMap[abilityName]
            if championName then
                championCounts[championName] = (championCounts[championName] or 0) + 1
            end
        end
    end

    for champion, count in pairs(championCounts) do
        if count > maxCount then
            maxCount = count
            mostFrequentChampion = champion
        end
    end

    if not mostFrequentChampion then
        debugPrint("Nenhum campeão correspondente detectado.")
        activePresetLabel:Set("Preset Ativo: Nenhum (Automático)")
        return
    end

    debugPrint("Campeão detectado:", mostFrequentChampion, "com", maxCount, "habilidade(s).")
    for presetName in pairs(CONFIG.Presets) do
        if presetName:lower():find(mostFrequentChampion:lower()) then
            debugPrint("Preset correspondente encontrado:", presetName, ". Aplicando...")
            applyPriorityPreset(presetName)
            return
        end
    end
    debugPrint("Nenhum preset encontrado para o campeão", mostFrequentChampion)
    activePresetLabel:Set("Preset Ativo: Nenhum (Automático)")
end

local function pressAbilityKey(index, button, abilityName)
    local key = CONFIG.Keybinds[index]
    if not key then return end
    debugPrint("Usando habilidade:", abilityName, "(Slot:", index .. ")")
    local pressCount = CONFIG.DoublePressAbilities[abilityName] and 2 or 1
    for _ = 1, pressCount do
        VirtualInputManager:SendKeyEvent(true, key, false, game)
        task.wait(0.01)
        VirtualInputManager:SendKeyEvent(false, key, false, game)
        task.wait(0.05)
    end
    if button and button:IsA("GuiButton") then
        local originalColor = button.BackgroundColor3
        button.BackgroundColor3 = Color3.new(1, 1, 0)
        task.delay(0.25, function()
            if button and button.Parent then button.BackgroundColor3 = originalColor end
        end)
    end
end

local function findReadyParryAbility(toolbarButtons)
    local abilityButtons = {}
    for i = 1, 4 do abilityButtons[i] = toolbarButtons:FindFirstChild("AbilityButton" .. i) end
    local orderedCheck = {}
    for slot, priority in ipairs(CONFIG.Priorities) do table.insert(orderedCheck, {slot = slot, priority = priority}) end
    table.sort(orderedCheck, function(a, b) return a.priority < b.priority end)
    for _, item in ipairs(orderedCheck) do
        local index = item.slot
        local button = abilityButtons[index]
        if button then
            local label = button:FindFirstChild("AbilityNameLabel")
            local cooldownFrame = button:FindFirstChild("Cooldown")
            local lock = button:FindFirstChild("LockLabel")
            if label and CONFIG.ParryAbilities[label.Text] and cooldownFrame and not cooldownFrame.Visible and lock and not lock.Visible then
                debugPrint("Habilidade de maior prioridade encontrada:", label.Text, "no slot", index)
                return index, button, label.Text
            end
        end
    end
    return nil
end

local function shouldParry(ball, cooldownStartTime, abilityName)
    if not ball or not ball:IsA("BasePart") or not ball:FindFirstChild("Highlight") then return false end
    if ball.Highlight.FillColor ~= Color3.new(1, 0, 0) then return false end
    local elapsed = (time() - cooldownStartTime) * 1000
    local isFast = CONFIG.FastTriggerAbilities[abilityName]
    local threshold = isFast and 300 or 800
    return elapsed >= threshold
end

local function onDeflectCooldownChanged(toolbarButtons)
    if not CONFIG.Enabled then return end
    local deflectButton = toolbarButtons:FindFirstChild("DeflectButton")
    if not deflectButton or not deflectButton:FindFirstChild("Cooldown") then return end
    if deflectButton.Cooldown.Visible then
        local cooldownStartTime = time()
        task.spawn(function()
            debugPrint("Deflect em cooldown. Procurando por oportunidades de parry.")
            while deflectButton.Cooldown.Visible and task.wait(0.05) do
                if not CONFIG.Enabled then break end
                local index, button, abilityName = findReadyParryAbility(toolbarButtons)
                if index then
                    local ball = workspace:FindFirstChild("Part")
                    if ball and shouldParry(ball, cooldownStartTime, abilityName) then
                        pressAbilityKey(index, button, abilityName)
                        break
                    end
                end
            end
            debugPrint("Verificação de parry encerrada.")
        end)
    end
end

-- MUDANÇA: Nova função de monitoramento ativo de habilidades
local function monitorAbilityChanges(toolbarButtons)
    local lastKnownAbilities = {}

    local function getCurrentAbilities()
        local currentAbilities = {}
        for i = 1, 4 do
            local button = toolbarButtons:FindFirstChild("AbilityButton" .. i)
            local label = button and button:FindFirstChild("AbilityNameLabel")
            table.insert(currentAbilities, label and label.Text or "N/A")
        end
        return currentAbilities
    end
    
    lastKnownAbilities = getCurrentAbilities()

    task.spawn(function()
        debugPrint("Iniciando monitoramento de habilidades...")
        while true do
            task.wait(1) -- Verifica a cada segundo
            if CONFIG.Enabled then
                local currentAbilities = getCurrentAbilities()
                local hasChanged = false
                for i = 1, 4 do
                    if currentAbilities[i] ~= lastKnownAbilities[i] then
                        hasChanged = true
                        break
                    end
                end

                if hasChanged then
                    debugPrint("Mudança de habilidade detectada. Re-verificando o campeão.")
                    lastKnownAbilities = currentAbilities
                    task.wait(0.2) -- Pequeno delay para garantir que a UI se estabilizou
                    detectAndApplyChampionPreset(toolbarButtons)
                end
            end
        end
    end)
end

local function main()
    local hud = playerGui:WaitForChild("HUD", 10)
    if not hud then warn("HUD não encontrado.") return end

    local holderBottom = hud:WaitForChild("HolderBottom", 5)
    if not holderBottom then warn("HolderBottom não encontrado.") return end

    local toolbarButtons = holderBottom:WaitForChild("ToolbarButtons", 5)
    if not toolbarButtons then warn("ToolbarButtons não encontrado.") return end

    local deflectButton = toolbarButtons:FindFirstChild("DeflectButton")
    if not deflectButton or not deflectButton:FindFirstChild("Cooldown") then
        warn("Botão de Deflect não encontrado.") return
    end

    task.wait(1) 
    detectAndApplyChampionPreset(toolbarButtons)
    
    -- MUDANÇA: Chamando a nova função de monitoramento
    monitorAbilityChanges(toolbarButtons)

    deflectButton.Cooldown:GetPropertyChangedSignal("Visible"):Connect(function()
        onDeflectCooldownChanged(toolbarButtons)
    end)
    
    print("Auto Skill iniciado com sucesso.")
end

local success, err = pcall(main)
if not success then
    warn("Erro ao inicializar o script de Auto Skill:", err)
end

OrionLib:Init()


