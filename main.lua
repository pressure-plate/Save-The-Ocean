-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Load the composer
local composer = require( "composer" )
 
-- Hide status bar
display.setStatusBar( display.HiddenStatusBar )
 
-- Seed the random number generator
math.randomseed( os.time() )

-- set default font params on the composer
local fontParams = {}
fontParams.path = "fonts/AlloyInk"
fontParams.colorR = 0.9
fontParams.colorG = 0.5
fontParams.colorB = 0.1
composer.setVariable( "defaultFontParams", fontParams )


-- @DEBUG -----------------------------------------------------------------------------------------

local debugMode = false

-- monitor Memory Usage
local function printMemUsage()  
    local memUsed = (collectgarbage("count"))
    local texUsed = system.getInfo( "textureMemoryUsed" ) / 1048576 -- Reported in Bytes
   
    print("\n---------MEMORY USAGE INFORMATION---------")
    print("System Memory: ", string.format("%.00f", memUsed), "KB")
    print("Texture Memory:", string.format("%.03f", texUsed), "MB")
    print("------------------------------------------\n")
end

-- collect garbage and then print memory usage
local function collectAndPrint()
    collectgarbage("collect")
    printMemUsage()
end

-- only load monitor if running in simulator and debugMode is active
if (system.getInfo("environment") == "simulator" and debugMode == true) then
    --Runtime:addEventListener( "enterFrame", printMemUsage) -- print memory usage for every frame

    -- continuosly print mem and launch garbage collector
    timer.performWithDelay(4000, collectAndPrint, 0)
end

-- ------------------------------------------------------------------------------------------------


-- Go to the menu screen
composer.gotoScene( "scenes.menu" )
