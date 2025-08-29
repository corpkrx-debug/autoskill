--[[
JP - Auto Skill - Death Ball
Analisado e refatorado para maior eficiência e robustez.
Versão 5: Janela com tamanho e posição personalizados.
]]

--[[ SERVIÇOS ]]
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
        ["Padrão"] = {1, 2, 3, 4},
        ["Invertido"] = {4, 3, 2, 1},
        ["Meio-Primeiro"] = {2, 3, 1, 4},
        ["Extremos-Primeiro"] = {1, 4, 2, 3},
    },

    FastTriggerAbilities = {
        ["DEKU SMASH"] = true, ["BATTLE SPIRIT"] = true, ["SUPER JUMP"] = true,
        ["CHAIN SPEAR"] = true, ["SKY GLIDE"] = true, ["DARK REVERSAL"] = true,
    },
    DoublePressAbilities = {
        ["SHADOW CLONE"] = true,
    },
    Keybinds = {
        Enum.KeyCode.One, Enum.KeyCode.Two,
        Enum.KeyCode.Three, Enum.KeyCode.Four
    },
    ParryAbilities = {
        ["UPPER CUT"]=true, ["DEKU SMASH"]=true, ["BRUTAL STEP"]=true, ["FALSE RUSH"]=true, ["LEAP SHREDS"]=true,
        ["SHADOW SLASH"]=true, ["ICE SLIDE"]=true, ["ZAP KICKZ"]=true, ["SPIRIT WRATH"]=true, ["BATTLE SPIRIT"]=true,
        ["CHAOTIC RUSH"]=true, ["INSTANT SLASH"]=true, ["OMNI-SLASH"]=true, ["BREAKDANCE"]=true, ["PHANTOM BLAST"]=true,
        ["SIDESTEP"]=true, ["RUSH PUNCH"]=true, ["REAP SLASH"]=true, ["JUJUMANJI SLASH"]=true, ["FLASH WRATH"]=true,
        ["SONIC SLIDE"]=true, ["FROZEN WRATHS"]=true, ["CHAIN SHOT"]=true, ["HANZO PUNCH"]=true, ["ASSAULT INTERVENTION"]=true,
        ["LIFESTEAL INFECTION"]=true, ["FORG-SMASH"]=true, ["CLONE PUNCH"]=true, ["PULL"]=true, ["JUDGEMENT CUT"]=true,
        ["GALAXY SLASH"]=true, ["REAPER"]=true, ["RAGING DEFLECTION"]=true, ["SHADOW RUSH"]=true, ["ICE"]=true, ["WIND"]=true,
        ["RAGING WIND"]=true, ["DEATH BALL"]=true, ["INFINITY"]=true, ["SINGULARITY"]=true, ["DEATH STEP"]=true,
        ["RAGING DEMON"]=true, ["SPECTRE"]=true, ["BLINK"]=true, ["INSTINCT"]=true, ["PHANTOM STEP"]=true,
        ["DEATH COUNTER"]=true, ["FATAL BLADE"]=true, ["ASSASSINATION"]=true, ["PHANTASMAGORIA"]=true, ["VOID"]=true,
        ["DEATH GOD"]=true, ["ZAP FREEZE"]=true, ["GODSPEED"]=true, ["ASSASSIN INVISIBILITY"]=true,
        ["LIGHTNING INTERCEPT"]=true, ["DAGGER DASH"]=true, ["RULERS HOLD"]=true, ["ARISE"]=true,
        ["SHADOW RAMPAGE"]=true, ["DARK REVERSAL"]=true, ["DREAD SPHERE"]=true, ["PHANTOM GRASP"]=true,
        ["LEAP STRIKE"]=true, ["SPIRIT WALL"]=true, ["HANDGUN"]=true, ["FAKE BALL"]=true, ["PHASE DASH"]=true,
        ["BLINDFOLD"]=true, ["ASTRAL PORTAL"]=true, ["DRAGON RUSH"]=true, ["INSTANT TRAVEL"]=true, ["KI BLAST"]=true,
        ["EXTEND-O ARM"]=true, ["GUM GUM BALLOON"]=true, ["GLASS WALL"]=true, ["TIME HAKI"]=true, ["SUPER JUMP"]=true,
        ["GROUND WALLS"]=true, ["CHAIN SPEAR"]=true, ["ZAP DEFLECT"]=true, ["HANDGUN (1/2)"]=true,
        ["DREAD SPHERE (1/2)"]=true, ["SKY GLIDE"]=true, ["MANA SHOT"]=true, ["RUNEGUARD"]=true, ["NINJA RUN"]=true,
        ["SHADOW CLONE"]=true, ["TREE JUMP"]=true, ["FOX ARMOUR"]=true
    }
}

--[[ INTERFACE GRÁFICA (UI) ]]
local Window = OrionLib:MakeWindow({
    Name = "Ability Control Panel", HidePremium = false,
    SaveConfig = true, ConfigFolder = "OrionAbilityControl",
    -- NOVO: Parâmetros para tamanho e posição da janela. Altere os valores como quiser.
    Size = UDim2.new(0, 500, 0, 420), -- Largura de 500 pixels, Altura de 420 pixels
    Position = UDim2.new(0, 30, 0, 30)  -- 30 pixels da esquerda, 30 pixels do topo
})
local Tab = Window:MakeTab({
    Name = "Ability Settings", Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

--[[ ELEMENTOS DA UI ]]
Tab:AddToggle({
    Name = "Enable Auto Skill",
    Default = CONFIG.Enabled,
    Callback = function(value) CONFIG.Enabled = value end
})

Tab:AddToggle({
    Name = "Debug Mode", Default = CONFIG.Debug,
    Callback = function(value) CONFIG.Debug = value end
})

Tab:AddLabel("Prioridade de Uso das Habilidades")

local prioritySliders = {}
local function debugPrint(...)
    if CONFIG.Debug then print("[DEBUG]", ...) end
end

-- Função para aplicar presets de prioridade a partir da tabela CONFIG.Presets
local function applyPriorityPreset(presetName)
    local newPriorities = CONFIG.Presets[presetName]
    if not newPriorities then return end

    CONFIG.Priorities = newPriorities
    for i = 1, 4 do
        if prioritySliders[i] then
            prioritySliders[i]:Set(CONFIG.Priorities[i])
        end
    end
    debugPrint("Preset de prioridade aplicado:", presetName)
end

-- Dropdown para selecionar os presets, gerado dinamicamente
local presetOptions = {}
for name in pairs(CONFIG.Presets) do
    table.insert(presetOptions, name)
end
table.sort(presetOptions)

Tab:AddDropdown({
    Name = "Presets de Prioridade",
    Default = "Padrão",
    Options = presetOptions,
    Callback = function(preset)
        applyPriorityPreset(preset)
    end
})

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
            if button and button.Parent then
                button.BackgroundColor3 = originalColor
            end
        end)
    end
end

local function findReadyParryAbility(toolbarButtons)
    local abilityButtons = {}
    for i = 1, 4 do
        abilityButtons[i] = toolbarButtons:FindFirstChild("AbilityButton" .. i)
    end

    local orderedCheck = {}
    for slot, priority in ipairs(CONFIG.Priorities) do
        table.insert(orderedCheck, {slot = slot, priority = priority})
    end
    table.sort(orderedCheck, function(a, b) return a.priority < b.priority end)

    for _, item in ipairs(orderedCheck) do
        local index = item.slot
        local button = abilityButtons[index]
        if button then
            local label = button:FindFirstChild("AbilityNameLabel")
            local cooldownFrame = button:FindFirstChild("Cooldown")
            local lock = button:FindFirstChild("LockLabel")

            if label and CONFIG.ParryAbilities[label.Text] and
               cooldownFrame and not cooldownFrame.Visible and
               lock and not lock.Visible then
                debugPrint("Habilidade de maior prioridade encontrada:", label.Text, "no slot", index)
                return index, button, label.Text
            end
        end
    end
    return nil
end

local function shouldParry(ball, cooldownStartTime, abilityName)
    if not ball or not ball:IsA("BasePart") or not ball:FindFirstChild("Highlight") then
        return false
    end
    if ball.Highlight.FillColor ~= Color3.new(1, 0, 0) then
        return false
    end

    local elapsed = (time() - cooldownStartTime) * 1000
    local isFast = CONFIG.FastTriggerAbilities[abilityName]
    local threshold = isFast and 300 or 800

    return elapsed >= threshold
end

--[[ LÓGICA PRINCIPAL (BASEADA EM EVENTOS) ]]
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
            debugPrint("Verificação de parry encerrada (cooldown acabou, habilidade usada ou script desativado).")
        end)
    end
end

local function main()
    local hud = playerGui:WaitForChild("HUD", 10)
    if not hud then
        warn("HUD não encontrado. O script não será executado.")
        return
    end

    local holderBottom = hud:WaitForChild("HolderBottom", 5)
    if not holderBottom then
        warn("HolderBottom não encontrado.")
        return
    end

    local toolbarButtons = holderBottom:WaitForChild("ToolbarButtons", 5)
    if not toolbarButtons then
        warn("ToolbarButtons não encontrado.")
        return
    end

    local deflectButton = toolbarButtons:FindFirstChild("DeflectButton")
    if not deflectButton or not deflectButton:FindFirstChild("Cooldown") then
        warn("Botão de Deflect ou seu cooldown não foram encontrados.")
        return
    end

    deflectButton.Cooldown:GetPropertyChangedSignal("Visible"):Connect(function()
        onDeflectCooldownChanged(toolbarButtons)
    end)
    
    print("Auto Skill iniciado com sucesso. Aguardando cooldown do Deflect.")
end

local success, err = pcall(main)
if not success then
    warn("Erro ao inicializar o script de Auto Skill:", err)
end

OrionLib:Init()

