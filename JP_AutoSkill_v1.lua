--[[
   
JP - Auto Skill - Death Ball

]]

local Players = game:GetService("Players")
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/weakhoes/Roblox-UI-Libs/refs/heads/main/Orion%20Lib/Orion%20Lib%20Source.lua')))()

local Window = OrionLib:MakeWindow({
    Name = "Ability Control Panel",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "OrionAbilityControl"
})

local Tab = Window:MakeTab({
    Name = "Ability Settings",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Configuration
local CONFIG = {
    Debug = true,
    -- NOVA CONFIGURAÇÃO: Armazena a prioridade de cada slot
    Priorities = {1, 2, 3, 4}, 
    FastTriggerAbilities = {
        ["DEKU SMASH"] = true,
        ["BATTLE SPIRIT"] = true,
        ["SUPER JUMP"] = true,
        ["CHAIN SPEAR"] = true,
        ["SKY GLIDE"] = true,
		["DARK REVERSAL"] = true,
    },
    DoublePressAbilities = {
        ["SHADOW CLONE"] = true,
    },
    Keybinds = {
        Enum.KeyCode.One,
        Enum.KeyCode.Two,
        Enum.KeyCode.Three,
        Enum.KeyCode.Four
    },
    ParryAbilities = {
        "UPPER CUT", "DEKU SMASH", "BRUTAL STEP", "FALSE RUSH", "LEAP SHREDS", "SHADOW SLASH",
        "ICE SLIDE", "ZAP KICKZ", "SPIRIT WRATH", "BATTLE SPIRIT", "CHAOTIC RUSH", "INSTANT SLASH",
        "OMNI-SLASH", "BREAKDANCE", "PHANTOM BLAST", "SIDESTEP", "RUSH PUNCH", "REAP SLASH",
        "JUJUMANJI SLASH", "FLASH WRATH", "SONIC SLIDE", "FROZEN WRATHS", "CHAIN SHOT", "HANZO PUNCH",
        "ASSAULT INTERVENTION", "LIFESTEAL INFECTION", "FORG-SMASH", "CLONE PUNCH", "PULL", 
        "JUDGEMENT CUT", "GALAXY SLASH", "REAPER", "RAGING DEFLECTION", "SHADOW RUSH", "ICE", 
        "WIND", "RAGING WIND", "DEATH BALL", "INFINITY", "SINGULARITY", "DEATH STEP", "RAGING DEMON", 
        "SPECTRE", "BLINK", "INSTINCT", "PHANTOM STEP", "DEATH COUNTER", "FATAL BLADE", "ASSASSINATION", 
        "PHANTASMAGORIA", "VOID", "DEATH GOD", "ZAP FREEZE", "GODSPEED", "ASSASSIN INVISIBILITY", 
        "LIGHTNING INTERCEPT", "DAGGER DASH", "RULERS HOLD", "ARISE", "SHADOW RAMPAGE", "DARK REVERSAL", 
        "DREAD SPHERE", "PHANTOM GRASP", "LEAP STRIKE", "SPIRIT WALL", "HANDGUN", "FAKE BALL", 
        "PHASE DASH", "BLINDFOLD", "ASTRAL PORTAL", "DRAGON RUSH", "INSTANT TRAVEL", "KI BLAST", 
        "EXTEND-O ARM", "GUM GUM BALLOON", "GLASS WALL", "TIME HAKI", "SUPER JUMP", "GROUND WALLS", "CHAIN SPEAR", "ZAP DEFLECT", 		"HANDGUN (1/2)", "DREAD SPHERE (1/2)",
        "SKY GLIDE","MANA SHOT","RUNEGUARD","SINGULARITY", "NINJA RUN", "SHADOW CLONE", "TREE JUMP", "FOX ARMOUR"
    }
}

-- UI Elements --
Tab:AddToggle({
    Name = "Debug Below Mode",
    Default = CONFIG.Debug,
    Callback = function(value)
        CONFIG.Debug = value
        print("Below Mode set to: ", value)
    end
})

-- NOVO SISTEMA DE PRIORIDADE COM SLIDERS
local prioritySliders = {}
local function updatePriorities(changedSlot, newPriority)
    -- Impede o callback de rodar recursivamente
    if CONFIG.Priorities[changedSlot] == newPriority then return end

    -- Encontra qual slot já tem a nova prioridade
    for slot, priority in ipairs(CONFIG.Priorities) do
        if slot ~= changedSlot and priority == newPriority then
            -- Troca as prioridades
            local oldPriority = CONFIG.Priorities[changedSlot]
            CONFIG.Priorities[slot] = oldPriority
            prioritySliders[slot]:Set(oldPriority) -- Atualiza o slider visualmente
            break
        end
    end
    CONFIG.Priorities[changedSlot] = newPriority
    debugPrint("Prioridades atualizadas:", table.concat(CONFIG.Priorities, ", "))
end

Tab:AddLabel("Prioridade de Uso das Habilidades")

for i = 1, 4 do
    prioritySliders[i] = Tab:AddSlider({
        Name = "Prioridade Slot " .. i,
        Min = 1,
        Max = 4,
        Default = CONFIG.Priorities[i],
        Round = 0,
        Callback = function(value)
            updatePriorities(i, value)
        end
    })
end


Tab:AddToggle({
    Name = "Fast Trigger Abilities",
    Default = true,
    Callback = function(value)
        for ability in pairs(CONFIG.FastTriggerAbilities) do
            CONFIG.FastTriggerAbilities[ability] = value
        end
        print("Fast Trigger Abilities set to: ", value)
    end
})

Tab:AddToggle({
    Name = "Double Press Abilities",
    Default = true,
    Callback = function(value)
        for ability in pairs(CONFIG.DoublePressAbilities) do
            CONFIG.DoublePressAbilities[ability] = value
        end
        print("Double Press Abilities set to: ", value)
    end
})

Tab:AddButton({
    Name = "Destroy UI",
    Callback = function()
        OrionLib:Destroy()
    end
})

-- Main Ability Logic --
local function debugPrint(...)
    if CONFIG.Debug then
        print("[DEBUG]", ...)
    end
end

local function pressAbilityKey(index, button, abilityName)
    local key = CONFIG.Keybinds[index]
    if not key then return end

    debugPrint("Usando habilidade:", abilityName, "(Slot:", index .. ")")

    if CONFIG.DoublePressAbilities[abilityName] then
        for _ = 1, 2 do
            VirtualInputManager:SendKeyEvent(true, key, false, game)
            VirtualInputManager:SendKeyEvent(false, key, false, game)
            task.wait(0.05)
        end
    else
        VirtualInputManager:SendKeyEvent(true, key, false, game)
        VirtualInputManager:SendKeyEvent(false, key, false, game)
    end

    if button and button:IsA("GuiButton") then
        local originalColor = button.BackgroundColor3
        button.BackgroundColor3 = Color3.new(1, 1, 0)
        task.delay(0.25, function()
            if button then
                button.BackgroundColor3 = originalColor
            end
        end)
    end
end

-- FUNÇÃO MODIFICADA PARA ADICIONAR DEBUG DE HABILIDADES DISPONÍVEIS
local function findReadyParryAbility(toolbarButtons)
    local abilityButtons = {
        [1] = toolbarButtons:FindFirstChild("AbilityButton1"),
        [2] = toolbarButtons:FindFirstChild("AbilityButton2"),
        [3] = toolbarButtons:FindFirstChild("AbilityButton3"),
        [4] = toolbarButtons:FindFirstChild("AbilityButton4")
    }

    local orderedCheck = {}
    for slot, priority in ipairs(CONFIG.Priorities) do
        table.insert(orderedCheck, {slot = slot, priority = priority})
    end
    table.sort(orderedCheck, function(a, b) return a.priority < b.priority end)
    
    -- LÓGICA DE DEBUG ADICIONADA
    local availableAbilities = {}
    for _, item in ipairs(orderedCheck) do
        local button = abilityButtons[item.slot]
        if button then
            local label = button:FindFirstChild("AbilityNameLabel")
            local cooldownFrame = button:FindFirstChild("Cooldown")
            local lock = button:FindFirstChild("LockLabel")
            
            if label and table.find(CONFIG.ParryAbilities, label.Text) then
                if cooldownFrame and not cooldownFrame.Visible and lock and not lock.Visible then
                    table.insert(availableAbilities, label.Text .. " (P" .. item.priority .. ")")
                end
            end
        end
    end

    if #availableAbilities > 0 then
        debugPrint("Habilidades de Parry Disponíveis:", table.concat(availableAbilities, ", "))
    else
        debugPrint("Nenhuma habilidade de Parry disponível.")
    end
    -- FIM DA LÓGICA DE DEBUG

    -- Itera na ordem de prioridade definida para encontrar a primeira habilidade pronta
    for _, item in ipairs(orderedCheck) do
        local index = item.slot
        local button = abilityButtons[index]
        
        if button then
            local label = button:FindFirstChild("AbilityNameLabel")
            local cooldownFrame = button:FindFirstChild("Cooldown")
            local lock = button:FindFirstChild("LockLabel")
            
            if label and table.find(CONFIG.ParryAbilities, label.Text) then
                if cooldownFrame and not cooldownFrame.Visible and lock and not lock.Visible then
                    debugPrint("Habilidade de maior prioridade encontrada:", label.Text, "no slot", index)
                    return index, button, label.Text
                end
            end
        end
    end
    
    return nil
end


local function shouldParry(ball, cooldownStart, abilityName)
    if not ball or not ball:FindFirstChild("Highlight") then
        return false
    end
    if ball.Highlight.FillColor ~= Color3.new(1, 0, 0) then
        return false
    end

    local elapsed = (tick() - cooldownStart) * 1000
    local fast = CONFIG.FastTriggerAbilities[abilityName] == true
    local threshold = fast and 300 or 800

    return elapsed >= threshold
end

local function main()
    local hud = playerGui:WaitForChild("HUD")
    local toolbarButtons = hud.HolderBottom.ToolbarButtons
    local deflectButton = toolbarButtons:FindFirstChild("DeflectButton")

    local cooldownStart = 0

    while task.wait(0.05) do
        if not hud or not toolbarButtons then continue end

        if deflectButton and deflectButton.Cooldown.Visible then
            if cooldownStart == 0 then
                cooldownStart = tick()
            end

            local ball = workspace:FindFirstChild("Part")
            local index, button, abilityName = findReadyParryAbility(toolbarButtons)

            if index and ball and shouldParry(ball, cooldownStart, abilityName) then
                pressAbilityKey(index, button, abilityName)
                cooldownStart = 0
            end
        else
            cooldownStart = 0
        end
    end
end

main()

OrionLib:Init()