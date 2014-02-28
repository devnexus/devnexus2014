--> Allows all other scripts to access main without having to explicity require
module("main", package.seeall)

--> Allows logs to be retrieved from device at runtime
io.output():setvbuf("no")
display.setStatusBar( display.HiddenStatusBar )

local M = {}

-- =====================
-- Declarations
-- =====================
local storyboard = require("storyboard")

-- =====================
-- Start Up
-- =====================
local function RunGame()
	storyboard.gotoScene( "scripts.Scenes.IntroScene" )
end

-- =====================
-- Public Functions
-- =====================


-- =====================
-- System Events
-- =====================
local function onSystemEvent( event ) 
    if event.type == "applicationStart" then
		RunGame()
		
	elseif event.type == "applicationResume" then
		
    end
end

Runtime:addEventListener( "system", onSystemEvent )

return M
