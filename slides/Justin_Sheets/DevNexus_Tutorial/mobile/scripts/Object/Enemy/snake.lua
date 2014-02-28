local Snake = {}

-- =====================
-- Declarations
-- =====================
--> References
local physics = require("physics")
local storyboard = require("storyboard")
local GameplayManager = require("scripts.Managers.GameplayManager")
local GameScene = require("scripts.Scenes.GameScene")

-- =====================
-- Listeners
-- =====================
--[[ DestroySnake(pSnake)
-- params:
		pSnake		-- (displayObject) reference to snake object that will be removed
-- Listener for how long a snake should stay alive
--]]
local function DestroySnake(pSnake)
	if (pSnake ~= nil) then
		pSnake:removeSelf()
		pSnake = nil
	end
end

--[[ onGameOver(event)
-- Triggers when the 'onGameOver' event is fired at the end of a level
--]]
function Snake:onGameOver(event)
	if (self.snake ~= nil) then
		self.snake:removeSelf()
		self.snake = nil
	end
end

-- =====================
-- Public Functions
-- =====================

--[[ NewSnake()
-- returns:
		-- snake		(displayGroup) returns display group created for snake object
-- Creates a new snake object and sets up any listeners and physics bodies necessary
--]]
function Snake:NewSnake()
	local snake = display.newGroup()
	
	snake["image"] = display.newImageRect("images/snake.png", 59, 80)
	snake["id"] = "snake"
	snake:insert(snake["image"])
	
	local snakeCollisionFilter = GameplayManager:GetCollisionFilter("Snake")
	physics.addBody( snake, { density = 0, friction = 0, bounce = 0, filter = snakeCollisionFilter } )
	snake.isFixedRotation = true
	
	local isLeft = math.random(0, 1)
	
	local randomX = (isLeft == 1) and display.contentWidth or 0
	local randomY = math.random(0, display.contentHeight)
	
	snake.x, snake.y = randomX, randomY
	
	timer.performWithDelay(2500, function()
		transition.to( snake, { timer = 500, alpha = 0, onComplete = DestroySnake(snake) } )
	end)
	
	GameScene:addEventListener('onGameOver', self)
	
	Snake:BeginMoving(snake)
	
	self.snake = snake
	return snake
end

-- =====================
-- Private Functions
-- =====================
--[[ BeginMoving(pSnake)
-- params:
--		pSnake		-- (displayObj) display object of snake that should move across the screen
--
--]]
function Snake:BeginMoving(pSnake)
	local player = require("scripts.Object.Player.player")
	local playerPosX, playerPosY = player:GetPlayerPosition()
	
	--local distance = math.sqrt((playerPosX - snake.x)^2+(playerPosY - snake.y)^2)
	local vX, vY = playerPosX - pSnake.x, playerPosY - pSnake.y
	
	pSnake:setLinearVelocity(vX, vY)
end

return Snake