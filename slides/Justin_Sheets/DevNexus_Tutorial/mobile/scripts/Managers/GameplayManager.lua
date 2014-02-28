local GameplayManager = {}

-- =====================
-- Declarations
-- =====================
local storyboard = require("storyboard")

--> gameplay timers
local eggTimer, enemyTimer

--> physics rules
local physics = require("physics")
physics.start()
physics.setGravity(0, 0)
--physics.setDrawMode( "hybrid" )

local playerCollisionFilter = { categoryBits = 1, maskBits = 6 }	-- collides with egg (2) & snake (4)
local eggCollisionFilter = { categoryBits = 2, maskBits = 1 }		-- collides with player (1)
local snakeCollisionFilter = { categoryBits = 4, maskBits = 1 }		-- collides with player (1)

local collisionFilterTable = {
	["Player"] = playerCollisionFilter,
	["Egg"] = eggCollisionFilter,
	["Snake"] = snakeCollisionFilter
}

-- =====================
-- Public Functions
-- =====================

--[[ StartLevel()
-- Sets up the timers for spawning in new eggs and snakes
--]]
function GameplayManager:StartLevel()
	local Egg = require("scripts.Object.Other.egg")
	local Snake = require("scripts.Object.Enemy.snake")
	
	local newEgg, newSnake
	
	eggTimer = timer.performWithDelay(1250, function()
		newEgg = Egg:NewEgg()
	end, -1)
	
	enemyTimer = timer.performWithDelay(500, function()
		newSnake = Snake:NewSnake()
	end, -1)
end

--[[ EndLevel()
-- Stops all relvant physics actions and timers for spawning new eggs/snakes. Sends the message to
-- all listeners that game over has been called.
--]]
function GameplayManager:EndLevel()
	physics:stop()
	
	local gameScene = storyboard.getScene("scripts.Scenes.GameScene")
	gameScene:dispatchEvent({ name = "onGameOver" })
	
	timer.cancel(eggTimer)
	eggTimer = nil
	
	timer.cancel(enemyTimer)
	enemyTimer = nil
	
	for id, value in pairs(timer._runlist) do
		timer.cancel(value)
	end
end

--[[ GameplayManager:GetCollisionFilter(pFilter)
-- params:
--		pFilter			-- (string)	String of the collision filter we wish to retrieve
-- returns:
--		collisionFilter	-- (collisionFilter)
--]]
function GameplayManager:GetCollisionFilter(pFilter)
	if (collisionFilterTable[pFilter] ~= nil) then
		return collisionFilterTable[pFilter]
	else
		print("The collision filter you're looking for doesn't exist!")
	end
end

-- =====================
-- Private Functions
-- =====================


return GameplayManager

