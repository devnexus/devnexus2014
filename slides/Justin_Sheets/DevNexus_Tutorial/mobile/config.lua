-- config.lua
--print("System.GetInfo(model): ".. system.getInfo("model"))
--print("System.GetInfo(architectureInfo): ".. system.getInfo("architectureInfo"))

local M = {}

local model = system.getInfo("model")

local aspect_4by3   = 4/3       -- 1.33
local aspect_3by2   = 3/2       -- 1.5
local aspect_16by10 = 16/10     -- 1.6
local aspect_5by3   = 5/3       -- 1.67
local aspect_16by9  = 16/9      -- 1.77

local myAspect = display.pixelHeight / display.pixelWidth

-- SPECIFIC DEVICES --
if model == "iPhone" then	
	application =
	{
		content =
		{			
			--2:3 resolution for iPhone/iPhone4 models
			width = 640,
			height = display.pixelHeight,
			scale = "zoomEven",
			fps = 60
		},
		
		notification =
		{
			iphone =
			{
				types =
				{
					"badge", "sound", "alert"
				}
			}
		},
}
		
elseif model == "iPad" then
	application =
	{
		content =
		{
			--3:4 resolution for iPad
			width = 768,
			height = 1024,
			scale = "zoomEven",
			fps = 60
		},
		
		notification =
		{
			iphone =
			{
				types =
				{
					"badge", "sound", "alert"
				}
			}
		}
	}

-- SPECIFIC ASPECTS --
elseif myAspect >= aspect_16by9 then
    application =
    {
        content =
        {
            width = 540,
            height = 960,
            scale = "zoomEven",
			fps = 60
        },
    }

elseif myAspect >= aspect_5by3 then
    application =
    {
        content =
        {
            width = 576,
            height = 960,
            scale = "zoomEven",
			fps = 60
        },
    }

elseif myAspect >= aspect_3by2 then
    application =
    {
        content =
        {
            width = 640,
            height = 960,
            scale = "zoomEven",
			fps = 60
        },
    }

elseif myAspect >= aspect_4by3 then
    application =
    {
        content =
        {
            width = 720,
            height = 960,
            scale = "zoomEven",
			fps = 60
        },
    }

end

return M
