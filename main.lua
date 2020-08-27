-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- load the composer
local composer = require( "composer" )

-- load the savedata module
local savedata = require( "scenes.libs.savedata" )

-- load physics module
local physics = require( "physics" )

-- trigger the first start of the engine
-- (it will be stopped in the create phase of each module and then restarted in the show phase)
physics.start()
 
-- hide status bar
display.setStatusBar( display.HiddenStatusBar )
 
-- seed the random number generator
math.randomseed( os.time() )

-- set default font params on the composer
local fontParams = {}
fontParams.path = "fonts/AlloyInk"
fontParams.colorR = 0.9
fontParams.colorG = 0.5
fontParams.colorB = 0.1
composer.setVariable( "defaultFontParams", fontParams )

-- fading times for windows
composer.setVariable( "windowFadingOpenTime", 400 )
composer.setVariable( "windowFadingClosingTime", 200 )

-- version of the game
composer.setVariable( "version", "0.9.5" )

-- reserve channel 1 for background music
audio.reserveChannels( 1 )

-- reduce the overall volume of the channel
local audioMute = savedata.getGamedata( "audioMute" )
print(audioMute)
if audioMute then
    audio.setVolume( 0, { channel=1 } )
else
    audio.setVolume( 0.7, { channel=1 } )
end

-- set audio root dir globally (this is done to simplify the introduction of different audio packs)
composer.setVariable( "audioDir", "audio/" )

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
