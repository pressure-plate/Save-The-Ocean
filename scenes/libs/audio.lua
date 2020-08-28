local M = {}

-- load the savedata module
local savedata = require( "scenes.libs.savedata" )


function M.toggleMusic()

    local audioMute = savedata.getGamedata( "audioMute" )
    if audioMute then
        audio.setVolume( 0.7, { channel=1 } )
        savedata.setGamedata( "audioMute", false)
    else
        audio.setVolume( 0, { channel=1 } )
        savedata.setGamedata( "audioMute", true)
    end 
end


function M.setFromSave()
    local audioMute = savedata.getGamedata( "audioMute" )

    if audioMute then
        audio.setVolume( 0, { channel=1 } )
    else
        audio.setVolume( 0.7, { channel=1 } )
    end
end 


-- return module table
return M
