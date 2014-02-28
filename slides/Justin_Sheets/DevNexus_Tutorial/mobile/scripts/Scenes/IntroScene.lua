
-- =====================
-- Declarations
-- =====================
local storyboard = require( "storyboard" )
local widget = require("widget")

local scene = storyboard.newScene()

--> drawn assets
local splashBg
local welcomeText, learnText, mainMenuHeaderText, mainMenuGameText
local yesButton, noButton

-- ===========================
-- LISTENERS
-- ===========================

--[[ OnIntroButtonReleased(event)
-- Input listener for when a button is clicked and then released.  'Event' is tied to the button that was interacted with, and 
-- contains information about the touch state and the targets information.
--]]
local function OnIntroButtonReleased(event)
	local eventId = event.target.id
	
	if (yesButton ~= nil and eventId == yesButton.id) then
		storyboard.gotoScene( "scripts.Scenes.GameScene" )
	
	elseif (noButton ~= nil and eventId == noButton.id) then
		scene:UnloadSplashScreen()
		scene:LoadMainMenu()
	end
end

-- =========================
-- PUBLIC FUNCTIONS
-- =========================

--[[ LoadMainMenu()
-- Draws the MainMenu assets to the screen when called
--]]
function scene:LoadMainMenu()
	local group = self.view
	
	mainMenuHeaderText = display.newText("Just kidding! Lets make...", display.contentWidth/2, display.contentHeight * 0.25, native.systemFontBold, 46)
	mainMenuHeaderText:setFillColor(0,0,0)
	group:insert(mainMenuHeaderText)
	
	mainMenuGameText = display.newText("EGG HUNTER!!", mainMenuHeaderText.x, display.contentHeight * 0.5, native.systemFontBold, 64)
	mainMenuGameText.rotation = -16
	mainMenuGameText:setFillColor(0,0,0)
	
	group:insert(mainMenuGameText)
	
	yesButton = widget.newButton({
		id = "yesButton",
		width = 250,
		height = 175,
		x = display.contentWidth * 0.5,
		y = display.contentHeight - 200,
		label = "OK",
		fontSize = 40,
		font = native.systemFont,
		defaultFile = "images/button.png",
		overFile = "images/buttonDown.png",
		onRelease = OnIntroButtonReleased
	})
	group:insert(yesButton)
end

--[[ UnloadSplashScreen()
-- Removes the Splash Screen elements from the scene when called
--]]
function scene:UnloadSplashScreen()
	local group = self.view
	
	welcomeText:removeSelf()
	welcomeText = nil
	
	learnText:removeSelf()
	learnText = nil
	
	noButton:removeSelf()
	noButton = nil
end

-- =====================
-- SCREEN IMPLEMENTATIONS
-- =====================

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view
	
	splashBg = display.newImageRect("images/splashBg.png", display.contentWidth, display.contentHeight)
	splashBg.anchorX, splashBg.achorY = 0.5, 0.5
	splashBg.x, splashBg.y = display.contentWidth/2, display.contentHeight/2
	group:insert(splashBg)
	
	welcomeText = display.newText("Welcome to Corona!", display.contentWidth/2, display.contentHeight * 0.25, native.systemFontBold, 52)
	welcomeText:setFillColor(0, 0, 0)
	group:insert(welcomeText)
	
	learnText = display.newText("Want to learn how to make Flappy Bird?!", welcomeText.x, display.contentHeight * 0.66, native.systemFont, 30)
	learnText:setFillColor(0, 0, 0)
	group:insert(learnText)
	
	noButton = widget.newButton({
		id = "noButton",
		width = 250,
		height = 175,
		x = display.contentWidth * .5,
		y = display.contentHeight - 200,
		label = "PLEASE NO",
		fontSize = 40,
		font = native.systemFont,
		defaultFile = "images/button.png",
		overFile = "images/buttonDown.png",
		onRelease = OnIntroButtonReleased
	})	
	group:insert(noButton)
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
	
	-----------------------------------------------------------------------------
	--	INSERT code here (e.g. start timers, load audio, start listeners, etc.)
	-----------------------------------------------------------------------------
	
end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
	
	-----------------------------------------------------------------------------
	--	INSERT code here (e.g. stop timers, remove listeners, unload sounds, etc.)
	-----------------------------------------------------------------------------
	if (yesButton ~= nil) then	yesButton:removeEventListener("touch", yesButton)	end
	if (noButton ~= nil) then	noButton:removeEventListener("touch", noButton)		end
end


-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
	local group = self.view
	
	-----------------------------------------------------------------------------
	--	INSERT code here (e.g. remove listeners, widgets, save state, etc.)
	-----------------------------------------------------------------------------
	
end


-- =====================
-- LISTENERS
-- =====================

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )

-- "exitScene" event is dispatched before next scene's transition begins
scene:addEventListener( "exitScene", scene )

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )

return scene
