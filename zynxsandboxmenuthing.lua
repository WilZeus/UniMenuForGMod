print("wil zeus's unimenu menu executed successfully")
surface.PlaySound("buttons/button3.wav") -- Play a sound when the lua successfully loads

-- Show tutorial when the lua is loaded
if not file.Exists("unimenu/ignoremessage.txt", "DATA") then
    local frame = Derma_Message("Press F8 to open the unimenu menu. You can also do !openmenu in chat or open_unimenu_menu in console to open the menu! Menu created by Wil Zeus, so hope you enjoy!", "Introductionairy Message", "OK")
    local checkmark = vgui.Create("DCheckBoxLabel", frame)
    checkmark:SetText("Never show this message again")
    checkmark:SetPos(10, 70)
    checkmark.OnChange = function(self, value)
        if value then
            if not file.Exists("unimenu", "DATA") then
                file.CreateDir("unimenu")
            end
            file.Write("unimenu/ignoremessage.txt", "true")
        else
            file.Delete("unimenu/ignoremessage.txt")
        end
    end
end

-- Define fonts
surface.CreateFont("MenuFont", {
    font = "Tahoma",
    size = 16,
    weight = 600,
})

surface.CreateFont("MenuHeaderFont", {
    font = "Tahoma",
    size = 18,
    weight = 800,
})

local adminPanelOpen = false
local keyCooldown = false  
local openKey = KEY_F8
local unimenuOpen = false
local firstLoad = true -- Track if it's the first time the script is loaded

local function DrawRoundedRect(x, y, w, h, radius, color)
    surface.SetDrawColor(color)
    draw.RoundedBox(radius, x, y, w, h, color)
end

local function CreateButton(parent, text, onClick)
    local button = vgui.Create("DButton", parent)
    button:SetSize(parent:GetWide(), 40)
    button:SetText("")  

    button.Paint = function(self, w, h)
        local bgColor = self:IsHovered() and Color(40, 40, 40) or Color(60, 60, 60)
        DrawRoundedRect(0, 0, w, h, 4, bgColor)
        draw.SimpleText(text, "MenuFont", w / 2, h / 2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    button.DoClick = function()
        onClick()
    end

    return button
end

-- Function to create the Player List menu in the content panel
local function CreatePlayerListMenu(contentPanel)
    contentPanel:Clear()  -- Clear any existing content

    -- Title Label for the Player List
    local titleLabel = vgui.Create("DLabel", contentPanel)
    titleLabel:SetPos(20, 20)
    titleLabel:SetSize(contentPanel:GetWide() - 40, 30)
    titleLabel:SetFont("MenuHeaderFont")
    titleLabel:SetText("Online Players:")
    titleLabel:SetTextColor(Color(255, 255, 255))

    -- Scrollable Panel to display player list
    local scrollPanel = vgui.Create("DScrollPanel", contentPanel)
    scrollPanel:SetPos(20, 60)
    scrollPanel:SetSize(contentPanel:GetWide() - 40, contentPanel:GetTall() - 80)

    -- Fetching and displaying each player's name
    for _, ply in ipairs(player.GetAll()) do
        local playerLabel = scrollPanel:Add("DLabel")
        playerLabel:SetText(ply:Nick())
        playerLabel:SetFont("MenuFont")
        playerLabel:SetSize(scrollPanel:GetWide(), 20)
        playerLabel:SetTextColor(Color(255, 255, 255))
        playerLabel:Dock(TOP)
        playerLabel:DockMargin(0, 0, 0, 5)  -- Margin between player names
    end
end

local REPO_URL = "https://github.com/WilZeus/UniMenuForGMod/blob/main/version.txt"
local UPDATE_URL = "https://github.com/WilZeus/UniMenuForGMod/blob/main/zynxsandboxmenuthing.lua"
local LOCAL_VERSION = "1.1" -- Set to the current version

local function CheckForUpdate()
    http.Fetch(REPO_URL,
        function(body, length, headers, code)
            if code == 200 then
                local remoteVersion = string.Trim(body)
                if remoteVersion > LOCAL_VERSION then
                    -- If there is a newer version, prompt the user
                    Derma_Query(
                        "A new update is available for UniMenu. Would you like to update now?",
                        "Update Available",
                        "Yes", function()
                            gui.OpenURL(UPDATE_URL) -- Open the GitHub page if the user agrees
                        end,
                        "No", function() end
                    )
                else
                    print("UniMenu is up to date.")
                end
            else
                print("Failed to check for updates. Error code:", code)
            end
        end,
        function(error)
            print("Error fetching update info:", error)
        end
    ) -- This closing parenthesis should end the http.Fetch function.
end

-- Add console command for manual update checking
concommand.Add("uni_menu_check_update", function()
    CheckForUpdate()
end)

-- Automatically check for updates when the script is run
RunConsoleCommand("uni_menu_check_update")


-- Call the update check whenever the admin panel opens
hook.Add("Initialize", "CheckForUniMenuUpdate", CheckForUpdate)

-- unimenu Layout
local function Createunimenu()
    if unimenuOpen then return end
    unimenuOpen = true

    local panel = vgui.Create("DFrame")
    panel:SetTitle("unimenu")
    panel:SetSize(700, 450)
    panel:Center()
    panel:MakePopup()
    panel:SetDraggable(true)  -- Make the panel draggable

    panel.Paint = function(self, w, h)
        DrawRoundedRect(0, 0, w, h, 6, Color(40, 40, 40))
    end

    panel.OnClose = function()
        unimenuOpen = false
    end

    -- Left Panel for buttons
    local leftPanel = vgui.Create("DPanel", panel)
    leftPanel:SetSize(200, 450)
    leftPanel:SetPos(0, 0)

    leftPanel.Paint = function(self, w, h)
        DrawRoundedRect(0, 0, w, h, 6, Color(54, 54, 54))
    end

    -- Right/Middle Panel for content
    local contentPanel = vgui.Create("DPanel", panel)
    contentPanel:SetSize(500, 450)
    contentPanel:SetPos(200, 0)

    contentPanel.Paint = function(self, w, h)
        DrawRoundedRect(0, 0, w, h, 6, Color(50, 50, 50))
    end

    -- Add buttons to the left panel
    local buttons = {
        {text = "Toggle Build & PVP Mode", command = function()
            RunConsoleCommand("say", "!god")
        end},
        {text = "Player List", command = function()
            CreatePlayerListMenu(contentPanel)
        end},
        {text = "RTV", command = function()
            RunConsoleCommand("say", "!rtv")
        end},
        {text = "Kill", command = function()
            RunConsoleCommand("kill")
        end},
        {text = "Rules", command = function()
            Derma_Message("Rules:\n1. No Cheating.\n2. Use common sense (No NSFW, No Racism, etc.).\n3. Don't abuse E2's or Starfall's (ex: esp, blinders, etc.).\n4. No self-promotion of any kind.\n5. Dont lag or crash the server.\n6.No propblock, propspam or proppush.", "Server Rules")
        end},
        {text = "Toggle Goto", command = function()
            RunConsoleCommand("say", "!tgo")
        end},
        {text = "Zoltin's Discord server" , command = function()
            gui.OpenURL("https://discord.gg/ySrqZmRwnE")
        end},
        {text = "Zoltin's Content Pack", command = function()
            gui.OpenURL("https://steamcommunity.com/sharedfiles/filedetails/?id=1800091571")
        end},
        {text = "Show Credits" , command = function()
            Derma_Message("Menu created by Wil Zeus", "Credits")
        end},
    }

    -- Create the buttons on the left side
    for i, btn in ipairs(buttons) do
        CreateButton(leftPanel, btn.text, btn.command):SetPos(0, (i - 1) * 50)
    end

    -- Add close button "X" in the top-right corner
    local closeButton = vgui.Create("DButton", panel)
    closeButton:SetText("X")
    closeButton:SetPos(panel:GetWide() - 35, 5)
    closeButton:SetSize(30, 30)
    closeButton.DoClick = function()
        panel:Close()
    end

    closeButton.Paint = function(self, w, h)
        local bgColor = self:IsHovered() and Color(200, 0, 0) or Color(180, 0, 0)
        DrawRoundedRect(0, 0, w, h, 4, bgColor)
        draw.SimpleText("X", "MenuHeaderFont", w / 2, h / 2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

-- Register a console command to open the unimenu menu
concommand.Add("open_unimenu", function()
    if not unimenuOpen then  -- Check to prevent multiple panels from opening
        Createunimenu()
    else
        print("unimenu menu is already open.")
    end
end)

hook.Add("PlayerSay", "unimenuCommand", function(ply, text)
    if text == "!openmenu" then
        Createunimenu()
    end
end)


