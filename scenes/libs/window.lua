
local composer = require( "composer" )

local M = {}

local uiDir = "assets/ui/" -- user interface assets di
local audioDir = "audio/" -- audio dir

local group

local showCloseButton
local windowTitle
local windowScaleFactor
local onExitCallback

local buttonClickSound
local buttonCloseSound 

local windowObjects -- to store the objest used to create the window
local isOpen


local function closeWindow(playSound)

    -- remove oll the objects used to create the window
    for count, el in pairs ( windowObjects ) do
        display.remove( el )
    end
    windowObjects = {} -- removing reference to let garbage colletcor do its job

    -- avoid to play close sound on window switch
    if playSound then
        audio.play( buttonCloseSound )
    end

    isOpen = false
    if onExitCallback then
        onExitCallback()
    end
    return true
end


local function openWindow()

    -- Play open Window Sound
    audio.play( buttonClickSound )

    -- if a windows is already open, close it
    if isOpen == true then
        closeWindow(false)
    end

    -- show the menu window
    local settingsWindow = display.newImage(group, uiDir .. "window2.png") -- set title
    settingsWindow:scale( 1.5*windowScaleFactor, 1.2*windowScaleFactor)
	settingsWindow.x = display.contentCenterX
    settingsWindow.y = display.contentCenterY

    -- set callback on tap to hide others EventListeners
    settingsWindow:addEventListener( "tap", function () return true end )  
    table.insert(windowObjects, settingsWindow)

    local yTitleBar = settingsWindow.y/1.6 -- the level of the title bar in the window

    -- set the window title
    -- write the title only if is declared
    if windowTitle then

        local fontParams = composer.getVariable( "defaultFontParams" )

        local windowTitle = display.newText( 
            group, 
            windowTitle, 
            display.contentCenterX, 
            display.contentCenterY - yTitleBar, 
            fontParams.path, 
            100 
        )
        windowTitle:setFillColor( fontParams.colorR, fontParams.colorG, fontParams.colorB )
        table.insert(windowObjects, windowTitle)
    end

    -- set the close button
    if showCloseButton then
        local closeButton = display.newImage(group, uiDir .. "badgeClose.png") -- set mask
        closeButton:scale(0.3, 0.3)
        closeButton.x = display.contentCenterX - settingsWindow.x/1.5
        closeButton.y = display.contentCenterY - yTitleBar
        closeButton:addEventListener( "tap", function () closeWindow(true) end ) -- tap listener
        table.insert(windowObjects, closeButton)
    end
end

-- init function
function M.init( displayGroup, options )

    -- init vars
    group = displayGroup

    showCloseButton = true
    windowTitle = null
    windowScaleFactor = 1
    onExitCallback = null
    buttonCloseSound = audio.loadStream( audioDir .. "sfx/close.mp3" )
    buttonClickSound = audio.loadStream( audioDir .. "sfx/click.mp3" )

    -- showCloseButton
    if options.showCloseButton then 
        showCloseButton = options.showCloseButton 
    end

    -- windowTitle
    if options.windowTitle then 
        windowTitle = options.windowTitle 
    end

    -- windowScaleFactor
    if options.windowScaleFactor then 
        windowScaleFactor = options.windowScaleFactor 
    end

    -- onExitCallback
    if options.onExitCallback then 
        onExitCallback = options.onExitCallback 
    end

    -- buttonCloseSound
    if options.buttonCloseSound then 
        buttonCloseSound = options.buttonCloseSound 
    end

    -- buttonClickSound
    if options.buttonClickSound then 
        buttonClickSound = options.buttonClickSound 
    end

    windowObjects = {}
    isOpen = false
    openWindow()
end


function M.clear()
    audio.dispose( buttonClickSound )
    audio.dispose( buttonCloseSound )
end


return M
