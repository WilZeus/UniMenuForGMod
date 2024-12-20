local script = [[
print("wil zeus's unimenu menu executed successfully")
RunConsoleCommand("check_for_updates")
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

local REPO_URL = "https://raw.githubusercontent.com/WilZeus/UniMenuForGMod/main/version.txt"
local LOCAL_VERSION = "1.5" -- Replace with the actual local version.

-- Function to check for updates
local function CheckForUpdates()
    print("Checking for updates...")

    -- Use a timer to perform the HTTP fetch outside of the main thread
    timer.Simple(0, function()
        http.Fetch(REPO_URL, function(body, length, headers, code)
            -- Ensure we received a valid response
            if code == 200 then
                -- Extract the remote version number from the response
                local remote_version = string.Trim(body) -- Clean up any whitespace
                print("Fetched remote version:", remote_version)

                -- Compare versions
                if remote_version > LOCAL_VERSION then
                    print("Update available! Current version:", LOCAL_VERSION, "New version:", remote_version)
                    Derma_Query("An update is available. Would you like to update?", "Update Available",
                        "Yes", function()
                            gui.OpenURL("https://github.com/WilZeus/UniMenuForGMod/")
                        end,
                        "No", function()
                            print("Update declined.")
                        end
                    )
                else
                    print("No update needed; UniMenu is up-to-date.")
                end
            else
                print("Failed to fetch version info. HTTP error code:", code)
            end
        end,
        function(error)
            print("HTTP fetch failed with error:", error)
        end)
    end)
end

-- Console command to trigger the update check
concommand.Add("check_for_updates", CheckForUpdates)


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

-- Create a loader frame with animations and "Loading..." text
local function CreateLoader()
    local loader = vgui.Create("DFrame")
    loader:SetSize(300, 100)
    loader:Center()
    loader:SetTitle("")
    loader:SetDraggable(false)
    loader:ShowCloseButton(false)
    loader:MakePopup()

    local alpha = 0
    local increasing = true

    loader.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(40, 40, 40))
        draw.SimpleText("Loading...", "MenuFont", w / 2, h / 2, Color(255, 255, 255, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        -- Animate the "Loading..." text alpha
        if increasing then
            alpha = alpha + 2
            if alpha >= 255 then
                increasing = false
            end
        else
            alpha = alpha - 2
            if alpha <= 0 then
                increasing = true
            end
        end
    end

    return loader
end
-- Checks for any updates
CheckForUpdates()

-- If an update is available, show a message
if updateAvailable then
    Derma_Message("An update is available. Would you like to update?", "Update Available",
        "Yes", function()
            gui.OpenURL("https://github.com/WilZeus/UniMenuForGMod/")
        end,
        "No", function()
            print("Update declined.")
        end
    )
end

local loader = CreateLoader()
timer.Simple(2, function()
    loader:Close()
    Createunimenu()
end)


hook.Add("PlayerSay", "unimenuCommand", function(ply, text)
    if text == "!openmenu" then
        Createunimenu()
    end
end)
]]
RunString(script)

