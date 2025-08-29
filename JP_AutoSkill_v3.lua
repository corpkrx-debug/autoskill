--[[
   
JP - Auto Skill - Death Ball

]]

local Players = game:GetService("Players")
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/weakhoes/Roblox-UI-Libs/refs/heads/main/Orion%20Lib/Orion%20Lib%20Source.lua')))()

--[[
=================================================================================
                       PAINEL DE CONTROLE DOS PRESETS
=================================================================================
    Defina seus presets de ordem de slot aqui. Eles aparecerão no menu do jogo.

        Formato: ["Nome do Preset"] = {ordem, dos, slots, aqui}
]]
local PRESETS = {
    ["Padrão"] = {1, 2, 3, 4},
    ["Invertido"] = {4, 3, 2, 1},
    ["Foco nos Slots Externos"] = {1, 4, 2, 3},
    ["Foco nos Slots Internos"] = {2, 3, 1, 4}
}
local defaultPresetName = "Padrão"
-- =================================================================================

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

local VirtualInputManager = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Configuration
local CONFIG = {
    Debug = true,
    PriorityOrder = PRESETS[defaultPresetName],
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
        "UPPER CUT", "DEKU SMASH", "BRUTAL STEP", "FALSE RUSH", "LEAP SHREDS", "SHADOW SLASH", "ICE SLIDE", "ZAP KICKZ", "SPIRIT WRATH", "BATTLE SPIRIT", "CHAOTIC RUSH", "INSTANT SLASH", "OMNI-SLASH", "BREAKDANCE", "PHANTOM BLAST", "SIDESTEP", "RUSH PUNCH", "REAP SLASH", "JUJUMANJI SLASH", "FLASH WRATH", "SONIC SLIDE", "FROZEN WRATHS", "CHAIN SHOT", "HANZO PUNCH", "ASSAULT INTERVENTION", "LIFESTEAL INFECTION", "FORG-SMASH", "CLONE PUNCH", "PULL", "JUDGEMENT CUT", "GALAXY SLASH", "REAPER", "RAGING DEFLECTION", "SHADOW RUSH", "ICE", "WIND", "RAGING WIND", "DEATH BALL", "INFINITY", "SINGULARITY", "DEATH STEP", "RAGING DEMON", "SPECTRE", "BLINK", "INSTINCT", "PHANTOM STEP", "DEATH COUNTER", "FATAL BLADE", "ASSASSINATION", "PHANTASMAGORIA", "VOID", "DEATH GOD", "ZAP FREEZE", "GODSPEED", "ASSASSIN INVISIBILITY", "LIGHTNING INTERCEPT", "DAGGER DASH", "RULERS HOLD", "ARISE", "SHADOW RAMPAGE", "DARK REVERSAL", "DREAD SPHERE", "PHANTOM GRASP", "LEAP STRIKE", "SPIRIT WALL", "HANDGUN", "FAKE BALL", "PHASE DASH", "BLINDFOLD", "ASTRAL PORTAL", "DRAGON RUSH", "INSTANT TRAVEL", "KI BLAST", "EXTEND-O ARM", "GUM GUM BALLOON", "GLASS WALL", "TIME HAKI", "SUPER JUMP", "GROUND WALLS", "CHAIN SPEAR", "ZAP DEFLECT", "HANDGUN (1/2)", "DREAD SPHERE (1/2)", "SKY GLIDE","MANA SHOT","RUNEGUARD","NINJA RUN", "SHADOW CLONE", "TREE JUMP", "FOX ARMOUR"
    }
}

-- UI Elements --
Tab:AddToggle({
    Name = "Debug Below Mode",
    Default = CONFIG.Debug,
    Callback = function(value)
        CONFIG.Debug = value
    end
})

-- Adicionando o seletor de Presets
local presetNames = {}
for name, _ in pairs(PRESETS) do
    table.insert(presetNames, name)
end

Tab:AddDropdown({
    Name = "Selecionar Preset de Slots",
    Default = defaultPresetName,
    Options = presetNames,
    Callback = function(presetName)
        if PRESETS[presetName] then
            CONFIG.PriorityOrder = PRESETS[presetName]
            OrionLib:MakeNotification({
                Name = "Preset Ativado!",
                Content = "Ordem de slots: " .. presetName,
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end
})

Tab:AddToggle({ Name = "Fast Trigger Abilities", Default = true, Callback = function(v) for a in pairs(CONFIG.FastTriggerAbilities) do CONFIG.FastTriggerAbilities[a] = v end end })
Tab:AddToggle({ Name = "Double Press Abilities", Default = true, Callback = function(v) for a in pairs(CONFIG.DoublePressAbilities) do CONFIG.DoublePressAbilities[a] = v end end })
Tab:AddButton({ Name = "Destroy UI", Callback = function() OrionLib:Destroy() end })

-- Main Ability Logic --
local function debugPrint(...) if CONFIG.Debug then print("[DEBUG]", ...) end end
local function pressAbilityKey(index, button, abilityName)
    local key = CONFIG.Keybinds[index]
    if not key then return end
    debugPrint("Usando habilidade:", abilityName, "(Slot:", index .. ")")
    if CONFIG.DoublePressAbilities[abilityName] then
        for _ = 1, 2 do
            VirtualInputManager:SendKeyEvent(true, key, false, game); VirtualInputManager:SendKeyEvent(false, key, false, game); task.wait(0.05)
        end
    else
        VirtualInputManager:SendKeyEvent(true, key, false, game); VirtualInputManager:SendKeyEvent(false, key, false, game)
    end
    if button and button:IsA("GuiButton") then
        local originalColor = button.BackgroundColor3; button.BackgroundColor3 = Color3.new(1, 1, 0)
        task.delay(0.25, function() if button then button.BackgroundColor3 = originalColor end end)
    end
end

-- FUNÇÃO PRINCIPAL SIMPLIFICADA PARA USAR APENAS ORDEM DE SLOT
local function findReadyParryAbility(toolbarButtons)
    local abilityButtons = {
        [1] = toolbarButtons:FindFirstChild("AbilityButton1"), [2] = toolbarButtons:FindFirstChild("AbilityButton2"),
        [3] = toolbarButtons:FindFirstChild("AbilityButton3"), [4] = toolbarButtons:FindFirstChild("AbilityButton4")
    }
    
    for _, slotIndex in ipairs(CONFIG.PriorityOrder) do
        local button = abilityButtons[slotIndex]
        if button then
            local label = button:FindFirstChild("AbilityNameLabel")
            local cooldown = button:FindFirstChild("Cooldown")
            local lock = button:FindFirstChild("LockLabel")
            
            if label and table.find(CONFIG.ParryAbilities, label.Text) and (cooldown and not cooldown.Visible and lock and not lock.Visible) then
                debugPrint("Habilidade encontrada:", label.Text, "no slot", slotIndex)
                return slotIndex, button, label.Text
            end
        end
    end
    
    debugPrint("Nenhuma habilidade prioritária disponível.")
    return nil
end

local function shouldParry(ball, cooldownStart, abilityName)
    if not ball or not ball:FindFirstChild("Highlight") or ball.Highlight.FillColor ~= Color3.new(1, 0, 0) then return false end
    local elapsed = (tick() - cooldownStart) * 1000
    local fast = CONFIG.FastTriggerAbilities[abilityName] == true
    return elapsed >= (fast and 300 or 800)
end

local function main()
    local hud = playerGui:WaitForChild("HUD")
    local toolbarButtons = hud.HolderBottom.ToolbarButtons
    local deflectButton = toolbarButtons:FindFirstChild("DeflectButton")
    local cooldownStart = 0
    while task.wait(0.05) do
        if deflectButton and deflectButton.Cooldown.Visible then
            if cooldownStart == 0 then cooldownStart = tick() end
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