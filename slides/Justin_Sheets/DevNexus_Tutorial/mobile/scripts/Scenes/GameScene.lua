-- =====================
-- Declarations
-- =====================
local storyboard = require( "storyboard" )
local widget = require("widget")
local GameplayManager = require("scripts.Managers.GameplayManager")

local scene = storyboard.newScene()

--> UI elements
local gameBg
local scoreText, livesText, gameOverText
local livesIcon
local yesButton, noButton, playAgainButton

--> Game HUD info
local livesNum = 3
local scoreNum = 0

-- =====================
-- LISTENERS
-- =====================

--[[ OnGameSceneButtonReleased(event)
-- Fires when a button is pressed on the Game scene and passes information about the touch state and the touched object
--]]
local function OnGameSceneButtonReleased(event)
	local eventId = event.target.id
	
	if (eventId == playAgainButton.id) then
		scene:RemoveGameOver()
		storyboard.gotoScene( "scripts.Scenes.GameScene" )
	end
end

-- =====================
-- PUBLIC FUNCTIONS
-- =====================

--[[ ShowPopupCollision(posX, posY)
-- params:
--		posX		-- (int) position.x where the poup image will show
--		posY		-- (int) position.y where the poup image will show
-- Draws an image at a set location when the player collides with something harmful (in our case, a snake)
--]]
function scene:ShowCollisionPopup(posX, posY)
	
	--[[ RemoveCollisionPopup(pImg)
	-- params:
	--		pImg		-- (displayObj) image reference to the display object that will be destroyed
	-- Removes the drawn popup from the screen after a set amount of time
	--]]
	local function RemoveCollisionPopup(pImg)
		timer.performWithDelay(500, function()
			pImg:removeSelf()
		end)
	end
	
	local group = self.view
	
	local kapowPopup = display.newImageRect("images/kapow.png", 105, 100)
	kapowPopup.x, kapowPopup.y = posX, posY
	group:insert(kapowPopup)
	
	RemoveCollisionPopup(kapowPopup)
end

--[[ UpdateScore(pScore)
-- params:
--		pScore		-- (int) score amount to add to our existing total
-- Updates our existing score amount by a new increment and updates our GUI to show the new value
--]]
function scene:UpdateScore(pScore)
	scoreNum = tonumber(scoreNum + pScore)
	scoreText.text = "Score: " .. scoreNum
end

--[[ UpdateLives(pLives)
-- params:
--		pLives		-- (int) score amount to decrement our existing lives by
-- Updates our existing lives by the amount passed and updates our GUI to show the new value
--]]
function scene:UpdateLives(pLives)
	livesNum = tonumber(livesNum + pLives)
	
	if (livesNum <= 0) then
		livesNum = 0
		GameplayManager:EndLevel()
		scene:DrawGameOver()
	end
	
	livesText.text = "x" .. livesNum
end

--[[ DrawGameOver()
-- Draws the GameOver screen to the world and registers the touch listeners for relevant buttons
--]]
function scene:DrawGameOver()
	local group = self.view
	
	gameOverText = display.newText("GAME OVER", display.contentWidth/2, display.contentHeight/2, native.systemFontBold, 50)
	gameOverText:setFillColor(0,0,0)
	group:insert(gameOverText)
	
	playAgainButton= widget.newButton({
		id = "playAgainButton",
		width = 250,
		height = 175,
		x = display.contentWidth/2,
		y = gameOverText.y + gameOverText.contentHeight + 150,
		label = "Play Again?",
		fontSize = 40,
		font = native.systemFont,
		defaultFile = "images/button.png",
		overFile = "images/buttonDown.png",
		onRelease = OnGameSceneButtonReleased
	})
	group:insert(playAgainButton)
end

--[[ RemoveGameOver()
-- Removes the elements in the Game Over screen from the display
--]]
function scene:RemoveGameOver()
	gameOverText:removeSelf()
	gameOverText = nil
	
	playAgainButton:removeSelf()
	playAgainButton = nil
end

-- =====================
-- SCREEN IMPLEMENTATIONS
-- =====================
-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view
	
	gameBg = display.newImage("images/gameBG.png", display.contentWidth, display.contentHeight)
	gameBg.x, gameBg.y = display.contentWidth/2, display.contentHeight/2
	group:insert(gameBg)

	scoreText = display.newText("Score: 0", 20, 20, native.systemFontBold, 30)
	scoreText.anchorX, scoreText.anchorY = 0, 0
	group:insert(scoreText)
	
	livesText = display.newText("x3", display.contentWidth - 20, 20, native.systemFontBold, 30)
	livesText.anchorX, livesText.anchorY = 1, 0
	group:insert(livesText)
	
	livesIcon = display.newImageRect("images/heart.png", 50, 50)
	livesIcon.x, livesIcon.y = livesText.x - livesText.contentWidth - livesIcon.contentWidth, 20
	livesIcon.anchorX, livesIcon.anchorY = 0, 0.15
	group:insert(livesIcon)
end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
	
	-----------------------------------------------------------------------------
		
	--	INSERT code here (e.g. start timers, load audio, start listeners, etc.)
	
	-----------------------------------------------------------------------------
	local Player = require("scripts.Object.Player.player")
	local GameplayManager = require("scripts.Managers.GameplayManager")
	
	Player:CreatePlayer()
	GameplayManager:StartLevel()
	
	livesNum = 3
	scoreNum = 0
	
	scene:UpdateLives(0)
	scene:UpdateScore(0)
end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
	
	-----------------------------------------------------------------------------
	
	--	INSERT code here (e.g. stop timers, remove listeners, unload sounds, etc.)
	
	-----------------------------------------------------------------------------
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
