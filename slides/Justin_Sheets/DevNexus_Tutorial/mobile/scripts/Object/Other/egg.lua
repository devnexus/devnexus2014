local Egg = {}

-- =====================
-- Declarations
-- =====================
--> References
local physics = require("physics")
local storyboard = require("storyboard")
local GameplayManager = require("scripts.Managers.GameplayManager")
local GameScene = require("scripts.Scenes.GameScene")

--> Spawning vars
local spawnMinX = 40
local spawnMaxX = display.contentWidth - 40
local spawnMinY = 80
local spawnMaxY = display.contentHeight - 40

-- =====================
-- Listeners
-- =====================
--[[ DestroyEgg(pEgg)
-- params:
--		pEgg		-- (displayObj) display object of the egg that will be destroyed
--]]
local function DestroyEgg(pEgg)
	if (pEgg ~= nil) then
		pEgg:removeSelf()
		pEgg = nil
	end
end

function Egg:onGameOver(event)
	if (self.egg ~= nil) then
		self.egg:removeSelf()
		self.egg = nil
	end
end

-- =====================
-- Public Functions
-- =====================

--[[ NewEgg()
-- returns:
--		egg		-- (displayObject) display group holding reference to egg object
--]]
function Egg:NewEgg()
	local egg = display.newGroup()
	
	egg["image"] = display.newImageRect("images/egg.png", 63, 80)
	egg["id"] = "egg"
	egg:insert(egg["image"])
	
	local eggCollisionFilter = GameplayManager:GetCollisionFilter("Egg")
	physics.addBody( egg, { density = 0, friction = 0, bounce = 0, filter = eggCollisionFilter } )
	egg.isFixedRotation = true
	
	local randomX = math.random(spawnMinX, spawnMaxX)
	local randomY = math.random(spawnMinY, spawnMaxY)
	
	egg.x, egg.y = randomX, randomY
	
	GameScene:addEventListener('onGameOver', self)
	
	timer.performWithDelay(2500, function()
		transition.to( egg, { timer = 500, alpha = 0, onComplete = DestroyEgg(egg) } )
	end)
	
	self.egg = egg
	
	return egg
end

-- =====================
-- Private Functions
-- =====================

return Egg