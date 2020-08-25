local M = {}

local composer = require( "composer" )

-- initialize variables -------------------------------------------------------

-- assets directory
local uiDir = "assets/ui/" -- user interface assets dir

-- init vars
local group


M.badgesOffset = 180 -- the offet between each badge in the top right corner
M.badgesScaleFactor = 0.3
M.badgesDescriptor = {}
M.position = 'top-right'

local loadedBadges = {}


-- get the x, y coords for the given position
local function computePosition()
    local xOffset = yOffset
    local yOffset

    if M.position == 'top-right' then
        xOffset = display.contentWidth/2.3
        yOffset = display.contentHeight/2.5 * -1 -- negative value
    end
    return xOffset, yOffset
end


-- private function to display the badges
local function loadBadges()

    -- if the badgesDescriptor is void Abort
    if not M.badgesDescriptor then 
        return
    end
    
    local xOffset, yOffset = computePosition()

    for badgeCount = 1, #M.badgesDescriptor do
		local badge = M.badgesDescriptor[badgeCount]
		local badgeDir = badge[1]
		local badgeCallback = badge[2]

		local badgeItem = display.newImage(group, uiDir .. badgeDir) -- set mask
		badgeItem:scale( M.badgesScaleFactor, M.badgesScaleFactor )
		badgeItem.x = display.contentCenterX + xOffset - M.badgesOffset * (badgeCount - 1)
		badgeItem.y = display.contentCenterY + yOffset
        badgeItem:addEventListener( "tap", badgeCallback ) -- tap listener
        table.insert(loadedBadges, badgeItem)
    end
end

-- remove badges from the view
-- if you want to hide the badge temporarely, this command will destroy them
-- to reload the badges use M.reloadBadges
function M.removeBadges()
    for i=0, table.getn(M.badgesDescriptor) do 
        display.remove( M.badgesDescriptor[i] )
    end
    M.badgesDescriptor = {}
end


-- reload badges if there are changes to apply
-- example a new badge
function M.reloadBadges()
    M.removeBadges()
    loadBadges()
end


-- init function
function M.init( displayGroup, badgesDescriptor )
    --[[
        an example of badgesDescriptor
        {
            {"badgeEdit.png", windowMod.openWorldsMenu},
            {"badgeSubmarine.png", windowMod.openSubmarinesMenu},
            {"badgeBubbles.png", windowMod.openBubblesMenu},
            {"badgeMute.png", muteMusicCallback}
        }

        you can edit the anytime changing the global var badgesDescriptor
        and use reloadBadges() to apply changes
    ]]--
    
    M.badgesDescriptor = badgesDescriptor
    -- init vars
    group = displayGroup
    loadBadges()
end


return M
