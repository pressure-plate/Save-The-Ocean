--
-- For more information on config.lua see the Project Configuration Guide at:
-- https://docs.coronalabs.com/guide/basics/configSettings
--

application =
{
	content =
	{
		-- Set content area width/height settings for 1080p resolution here
		-- Note that even for landscape-oriented apps, width should be the "short" side for Corona's purposes
		width = 1080,
		height = 1920,
		scale = "letterbox",
		fps = 60,
		
		--[[
		imageSuffix =
		{
			    ["@2x"] = 2,
			    ["@4x"] = 4,
		},
		--]]
	},
}
