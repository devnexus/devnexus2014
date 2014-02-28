local Player = {}

-- =====================
-- Declarations
-- =====================
--> References
local storyboard = require("storyboard")
local physics = require("physics")

local GameplayManager = require("scripts.Managers.GameplayManager")
local gameScene = storyboard.getScene("scripts.Scenes.GameScene")

--> player vars
--local player
local currentPlayer
local movementTransition = nil

-- =====================
-- Listeners
-- =====================

--[[ onTouch(event)
-- Fires when the screen is touched, and determines which phase the touch is occuring (begin, moved, ended)
--]]
local function onTouch(event)
	if (currentPlayer ~= nil) then
		if event.phase == "began" then

			currentPlayer.markX = currentPlayer.x    -- store x location of object
			currentPlayer.markY = currentPlayer.y    -- store y location of object

		elseif event.phase == "moved" then
				
			if (currentPlayer.markX == nil) then return end
			local x = (event.x - event.xStart) + currentPlayer.markX
			local y = (event.y - event.yStart) + currentPlayer.markY

			currentPlayer.x, currentPlayer.y = x, y    -- move object based on calculations above
		end

		return true
	end
end

--[[ onLocalCollision(self, event)
-- Fires when the Player object collides with another physics body.  You can retrieve information about both
-- colliding bodies and choose how to handle these collision.
--]]
local function onLocalCollision( self, event )
	if ( event.phase == "began" ) then
		local otherObjId = event.other.id
		
		if (otherObjId == "egg") then
			gameScene:UpdateScore(1)
			event.other:removeSelf()
			
		elseif (otherObjId == "snake") then
			gameScene:UpdateLives(-1)
			gameScene:ShowCollisionPopup(self.x - (self.x - event.other.x)/2, self.y - (self.y - event.other.y)/2)
			Player:AddInvicibility()
			event.other:removeSelf()
		end
	end
end


-- =====================
-- Public Functions
-- =====================
--[[ CreatePlayer(params)
-- Creates a new Player with optional parameters. Sets up the physics body and listeners for the new player object.
	
		Optional Parameters =====================================
			
			x					-- (INT) X position of where the player should spawn
			y					-- (INT) Y position of where the player should spawn
--]]
function Player:CreatePlayer(params)
	if (params == nil) then params = {} end
	
	local player = display.newGroup()
	
	player["image"] = display.newImageRect("images/bunny.png", 68, 100)
	player["shield"] = display.newImageRect("images/shield.png", 110, 110)
	player["shield"].alpha = 0
	
	player:insert(player["image"])
	player:insert(player["shield"])
	
	player["id"] = "player"
	
	local playerCollisionFilter = GameplayManager:GetCollisionFilter("Player")
	physics.addBody( player, "kinematic", { density = 0, friction = 0, bounce = 0, filter = playerCollisionFilter } )
	player.isFixedRotation = true
	
	player.collision = onLocalCollision
	player:addEventListener( "collision", player )
	
	Runtime:addEventListener("touch", onTouch);
	gameScene:addEventListener('onGameOver', self)
	
	player.x = (params.x ~= nil) and params.x or display.contentWidth/2
	player.y = (params.y ~= nil) and params.y or display.contentHeight/2
	
	currentPlayer = player
	return player
end

--[[ AddInvicibility()
-- Removes the players physics body for a brief period of time so that the player is 'immune' to other collisions
-- and will not interact with them.  The players physics body is then re-added and will be able to be hit, removing the shield.
--]]
function Player:AddInvicibility()
	if (currentPlayer == nil) then return end
	
	-- calling physics.removeBody() on same frame as collision will always fail.  Need to wait briefly.
	timer.performWithDelay(10, function()
		physics.removeBody( currentPlayer )
		currentPlayer.image.alpha = 0.5
	
		currentPlayer["shield"].alpha = 1.0
	end)
	
	timer.performWithDelay(1500, function()
		local playerCollisionFilter = GameplayManager:GetCollisionFilter("Player")
		physics.addBody( currentPlayer, "kinematic", { density = 0, friction = 0, bounce = 0, filter = playerCollisionFilter } )
		currentPlayer.image.alpha = 1.0
		
		currentPlayer["shield"].alpha = 0
	end)
end

--[[ GetPlayerPosition()
-- returns:
		X		-- (int) pos X of the players current position
		Y		-- (int) pos Y of the players current position
-- Retrusn where the player currently is in the world
--]]
function Player:GetPlayerPosition()
	return currentPlayer.x, currentPlayer.y
end

--[[ onGameOver()
-- Listener function for when the game is finished.  This is fired from the GameScene storyboard.  Removes the
-- player from the world upon game over.
--]]
function Player:onGameOver()
	if (currentPlayer ~= nil) then
		currentPlayer:removeSelf()
		currentPlayer = nil
	end
end

-- =====================
-- Private Functions
-- =====================

return Player