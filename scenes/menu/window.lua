
local M = {}

local composer = require( "composer" )

-- initialize variables -------------------------------------------------------

-- assets directory
local uiDir = "assets/ui/" -- user interface assets di

local group
local settingsWindow
local closeButton
local closeButtonScaleRateo = 3


function M.closeWindow()
    display.remove( settingsWindow )
    display.remove( closeButton )
end


function M.openWindow()
    -- set title on the menu
	settingsWindow = display.newImageRect(group, uiDir .. "window.png", display.contentWidth/1.2, display.contentHeight/1.2) -- set title
	settingsWindow.x = display.contentCenterX
    settingsWindow.y = display.contentCenterY
    
    -- set the close button
	closeButton = display.newImageRect(group, uiDir .. "closeBadge.png", 512/closeButtonScaleRateo, 512/closeButtonScaleRateo) -- set mask
	closeButton.x = display.contentCenterX + settingsWindow.x/1.5
	closeButton.y = display.contentCenterY - settingsWindow.y/1.6
	closeButton:addEventListener( "tap", M.closeWindow ) -- tap listener
end

-- init function
function M.init( displayGroup )

    -- init vars
    group = displayGroup
end

return M
