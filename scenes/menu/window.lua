
local M = {}

local composer = require( "composer" )

-- load background module
local loadMod = require( "scenes.menu.load" )

-- initialize variables -------------------------------------------------------

-- assets directory
local uiDir = "assets/ui/" -- user interface assets di

local group
local isOpen = false
local onExitCallback -- function called to close all the objects in the window

local windowObjects = {} -- to store the objest used to create the window

local closeButtonScaleRateo = 3


local function closeWindow()

    -- remove oll the objects used to create the window
    for i=0, table.getn(windowObjects) do
        display.remove( windowObjects[i] )
    end
    windowObjects = {} -- removing reference to let garbage colletcor do its job

    isOpen = false
    if onExitCallback ~= null then
        onExitCallback()
    end
    return true
end


local function openWindow(exitCallback, title)

    local settingsWindow
    local settingsWindow
    local closeButton

    local yTitleBar -- the level of the title bar in the window

    -- if a windows is already open, close it
    if isOpen == true then
        closeWindow()
    end

    -- show the menu window
    settingsWindow = display.newImage(group, uiDir .. "window2.png") -- set title
    settingsWindow:scale(1.5,1.2)
	settingsWindow.x = display.contentCenterX
    settingsWindow.y = display.contentCenterY
    settingsWindow:addEventListener( "tap", function () return true end )
    table.insert(windowObjects, settingsWindow)

    yTitleBar = settingsWindow.y/1.6

    if title == null then
        title = "Title"
    end

    -- set the window title
    windowTitle = display.newText( 
        group, 
        title, 
        display.contentCenterX, 
        display.contentCenterY - yTitleBar, 
        "fonts/CooperBlack.ttf", 
        100 
    )
    table.insert(windowObjects, windowTitle)

    -- set the close button
    closeButton = display.newImage(group, uiDir .. "badgeClose.png") -- set mask
    closeButton:scale(0.3, 0.3)
	closeButton.x = display.contentCenterX - settingsWindow.x/1.5
	closeButton.y = display.contentCenterY - yTitleBar
    closeButton:addEventListener( "tap", closeWindow ) -- tap listener
    table.insert(windowObjects, closeButton)

    isOpen = true
    onExitCallback = exitCallback -- set the exit call back
end


function M.openWorldsMenu()
    openWindow(loadMod.destroyTable, "Worls")
    loadMod.loadWorlds()
end


-- load submarines function
function M.openSubmarinesMenu()
    openWindow(loadMod.destroyTable, "Submarines")
    loadMod.loadSubmarines()
end


function M.openBubblesMenu()
    openWindow(loadMod.destroyTable, "Bubbles")
    loadMod.loadBubbles()
end


function M.openAboutMenu()
    local aboutText

    local function destroy()
        display.remove( aboutText )
    end
    openWindow(destroy, "About")
    aboutText = display.newImage(group, "assets/menu/about1.png") -- set title
	aboutText.x = display.contentCenterX
    aboutText.y = display.contentCenterY + display.contentHeight/15
    aboutText:addEventListener( 
        "tap",
        function () system.openURL( 'https://github.com/pressure-plate/SaveTheOcean' ) end 
    )
end


function M.openHighscoresMenu()
    openWindow(null, "High Scores")
end


-- init function
function M.init( displayGroup )

    -- init vars
    group = displayGroup

    -- init the loader
    loadMod.init(displayGroup)
end

return M
