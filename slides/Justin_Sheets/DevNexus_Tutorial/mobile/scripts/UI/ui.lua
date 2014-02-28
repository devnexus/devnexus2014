-- ui.lua (currently includes Button class with labels, font selection and optional event model)
 
-- Version 2.4
-- Based on the folowing original provided by Ansca Inc.
-- Version 1.5 (works with multitouch, adds setText() method to buttons)
--
-- Copyright (C) 2010 ANSCA Inc. All Rights Reserved.
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy of 
-- this software and associated documentation files (the "Software"), to deal in the 
-- Software without restriction, including without limitation the rights to use, copy, 
-- modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, 
-- and to permit persons to whom the Software is furnished to do so, subject to the 
-- following conditions:
-- 
-- The above copyright notice and this permission notice shall be included in all copies 
-- or substantial portions of the Software.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
-- INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR 
-- PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE 
-- FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
-- DEALINGS IN THE SOFTWARE.
 
-- Version 1.6 Works with Dynamic Scaling.
-- Based on the work edited by William Flagello, williamflagello.com
-- Original from https://developer.anscamobile.com/code/ui-library
--
-- Version 1.7 Dynamic Scaling text fixes by Jonathan Bebe
-- http://developer.anscamobile.com/forum/2010/12/17/easily-make-your-text-sharp-retina-displays#comment-18164
-- Provided in Ghosts & Monsters Sample Project
--
-- Version 1.71 Retina Updates by Jonathan Bebe
-- http://developer.anscamobile.com/forum/2010/12/17/easily-make-your-text-sharp-retina-displays#comment-38284
-- Adapted to 1.7 base code by E. Gonenc, pixelenvision.com
--
-- Version 1.8 added support for providing already realized display-objects for use in Tiled/Lime
-- Based on the file changed by Frank Siebenlist
-- http://developer.anscamobile.com/forum/2011/02/19/enhanced-uilua-v15
-- Adapted to 1.7 base code by E. Gonenc, pixelenvision.com
--
-- Version 1.9 
-- Added transparency & scaling options to use as over state. newLabel updated to support retina text.
-- Edited by E. Gonenc, pixelenvision.com
--
-- Version 1.91 
-- Added suggested fix for overlapping buttons by Jonathan Bebe
-- http://jonbeebe.net/to-return-true-or-not-to
-- Adapted by E. Gonenc, pixelenvision.com
--
-- Version 2.02
-- Button text will now follow scaling & alpha states of over button
-- Edited by E. Gonenc, pixelenvision.com
--
-- Version 2.1
-- Added suggested .isActive update by monoxgas http://developer.anscamobile.com/code/enhanced-ui-library-uilua#comment-49272
-- Edited by E. Gonenc, pixelenvision.com
--
-- Version 2.2
-- Updated to eliminate the use of LUAs deprecated module() function. This is an internal change only, usage stays the same.
-- http://blog.anscamobile.com/2011/09/a-better-approach-to-external-modules/
-- Edited by E. Gonenc, pixelenvision.com
--
-- Version 2.3
-- Updated to use object.contentBounds instead of deprecated object.stageBounds
-- Added event support, now returns even.target, event.x & event.y values. You can use x/y values to provide different actions
-- based on the coordinates of the touch event reative to the x/y size of the button image.
-- Edited by E. Gonenc, pixelenvision.com
--
-- Version 2.4
-- isActive state enhanced to button can be enabled/disabled without checking current isActive state with if-then.
-- ie. btn.isActive = true (Default state, button is enabled) btn.isActive = false (button is disabled, no animation and action)
-- Edited by E. Gonenc, pixelenvision.com
--
-- Version 2.5 ~ 8/3/2012
-- JS: Re-worked how params are passed in to buttons (and other functions that create elements). An image path, width, and height,
-- are now mandatory, and optional params are passed in thru a 'params' table and documented at top of class.
-- Added a command to create a 'newImage' thru the ui class.
-- 'text' is no longer a valid parameter. If an object needs text, just call myObj:setText() after creating the object.

--local widget  = require("widget")

-- JS: require("widget") now includes widget v2.0, which has changed drastically since widget v1.0. require "widget-v1" is pulling the original v1 source from our
-- project folder which was supplied by Corona. 
local widget = require "widget-v1"
local myAudio = require("myAudio")

local M = {}

-------------
-- convenience test functions added by Frank.
 
local coronaMetaTable = getmetatable(display.getCurrentStage())
 
--- Test function that returns whether object is a Corona display object.
-- Note that all Corona types seem to share the same metatable...
local isDisplayObject = function(o)
	return type(o) == "table" and getmetatable(o) == coronaMetaTable
end
M.isDisplayObject = isDisplayObject

-- =====================
-- Declarations
-- =====================

local layoutType = {
	["vertical"] = 1,
	["horizontal"] = 2
}
M.layoutType = layoutType

-- =====================
-- Screen Locations
-- =====================

local screenLeft = display.screenOriginX
M.screenLeft = screenLeft

local screenRight = display.screenOriginX + display.viewableContentWidth
M.screenRight = screenRight

local screenCenterX = display.screenOriginX + display.viewableContentWidth * 0.5
M.screenCenterX = screenCenterX

local screenTop = display.screenOriginY
M.screenTop = screenTop

local screenBottom = display.screenOriginY + display.viewableContentHeight
M.screenBottom = screenBottom

local screenCenterY = display.screenOriginY + display.viewableContentHeight * 0.5
M.screenCenterY = screenCenterY

local screenWidth = display.viewableContentWidth
M.screenWidth = screenWidth

local screenHeight = display.viewableContentHeight
M.screenHeight = screenHeight

local screenWidthRatio = display.viewableContentWidth / 640
M.screenWidthRatio = screenWidthRatio

local screenHeightRatio = display.viewableContentHeight / 960
M.screenHeightRatio = screenHeightRatio

local smallestScreenRatio = (screenWidthRatio >= screenHeightRatio) and screenHeightRatio or screenWidthRatio
M.smallestScreenRatio = smallestScreenRatio

-- only here for printing purposes... config.lua uses this aspect ratio
local myAspect = display.pixelHeight / display.pixelWidth

print("~ UI Screen size : (" .. screenWidth .. " X " .. screenHeight .. ")")
print("~ UI Screen ratio: (" .. screenWidthRatio .. " X " .. screenHeightRatio .. ")")
print("~ UI Smallest    :  " .. smallestScreenRatio)
print("~ UI myAspect    : " .. myAspect)

-- =====================
-- Public Functions
-- =====================

function getStatusBarHeight()
	local height
	if system.getInfo("model") == "iPhone" then
		height = 40
	elseif system.getInfo("model") == "iPad" then
		height = 20
	else
		height = 40
	end
	return height
end
M.getStatusBarHeight = getStatusBarHeight

function IsRetina()
	local deviceModel = system.getInfo("model")
	local screenHeight = display.contentHeight
	
	if deviceModel == "iPhone" then
		if screenHeight > 480 then
			return true
		end
	elseif deviceModel == "iPad" then
		if screenHeight > 768 then
			return true
		end
	end
	
	return false
end
M.IsRetina = IsRetina

--[[ HandleMoveInScroller(event, scroller)
-- Should be used in any UI component's event listener if it is contained within a scroller.
-- Set that component's onMoved function to the same as its onRelease. Then, have an [if event.phase == "moved"]
-- check before running any release callbacks. Call this in the "if moved" code, and pass the event parameter
-- and the scroller object that should take focus if user moves mouse too much while clicking the UI object.
--]]
function HandleMoveInScroller(event, scroller, parentGroup, id)
	local dx = math.abs( event.x - event.xStart )
	local dy = math.abs( event.y - event.yStart )

	if dx > 5 or dy > 5 then
		scroller:takeFocus( event )
		
		if parentGroup ~= nil and id ~= nil then
			if parentGroup[id] ~= nil then
				parentGroup[id]:Reset()
			end
		end
	end
    scroller.content.x = 0
end
M.HandleMoveInScroller = HandleMoveInScroller

--[[ cleanGroup( pGroup, pCleanParentGroup )
-- Use: 	"clean" the passed display group by removing all children listeners, then remove and nil children.
-- 			If pCleanParentGroup is true, will also clear and nil the parent group container. pCleanParentGroup is optional.
-- 			MUST still manually nil the passed display group after calling this function, as noted below in syntax notes.
-- Syntax:  cleanGroup( myGroup, true )
--			myGroup = nil
-- Syntax2:	cleanGroup( myGroup )  : if left out, pCleanParentGroup will default to true
--]]
function cleanGroup( pGroup, pCleanParentGroup )
	-- this style of looping thru children obtained from  http://cl.ly/58zl
	local function RemoveMyself(pObject)
		local numOfChildren = pObject.numChildren

		if numOfChildren then
			for i = numOfChildren, 1, -1 do
				if pObject[i].touch then
					pObject[i]:removeEventListener( "touch", pObject[i] )
					pObject[i].touch = nil
				end
				
				RemoveMyself(pObject[i])
			end
		end
		
		pObject:removeSelf()
		pObject = nil
	end
	
	if pGroup == nil then
		print("WARNING: Attempt to clean a display group that is nil!! Skipped.")
		return
	end

	local numChildren = pGroup.numChildren
	
	if numChildren == 0 or type(numChildren) ~= "number" then
		print("WARNING: Attempt to clean a display group with zero/NaN children!! Skipped.")
		return
	end
	
	-- if pCleanParentGroup is not a valid type or not included, force false
	if pCleanParentGroup == nil or type(pCleanParentGroup) ~= "boolean" then
		pCleanParentGroup = true
	end
	
	-- group:removeSelf must iterate backwards as it shifts other elements when one is removed
	for i = numChildren, 1, -1 do
		-- remove any touch listeners
		if pGroup[i].touch then
			pGroup[i]:removeEventListener( "touch", pGroup[i] )
			pGroup[i].touch = nil
		end

		--print("REMOVING " .. pGroup[i]._id)
		RemoveMyself(pGroup[i])
	end
	
	-- now clean out the group object once all children are removed
	if pGroup.touch then
		pGroup:removeEventListener( "touch", pGroup )
		pGroup.touch = nil
	end
	
	-- clear any keyed objects if this display group was created via ui class
	if pGroup.keys then
		pGroup:DeleteAll()
	end
	
	-- if we want to destroy the parent group, remove it now since all childs are clear
	if pCleanParentGroup == true then	
		RemoveMyself(pGroup)
	end
end
M.cleanGroup = cleanGroup

--[[ isObjectAlive(pGroupObject, pKeyName [, pShouldPrint])
-- Use:		Determine if a UI component within a group exists or not.
--			Returns true if object is alive, otherwise false.
--			If pShouldPrint is true, also print object status to console (true by default)
-- Syntax:	isObjectAlive(titleScreenGroup, "playButton")
--]]
local function isObjectAlive(pGroupObject, pKeyName, pShouldPrint)
	-- TODO: Control if the print commands process. Won't want prints for a final build
	-- 		 if we're using isObjectAlive() to ensure objects are deleted.
	
	if pShouldPrint == nil then
		pShouldPrint = true
	end
	
	if pGroupObject == nil then
		if pShouldPrint == true then print("isObjectAlive: Group is nil!! (searched for " .. pKeyName .. ")") end
		return false
	end
	
	if isDisplayObject(pGroupObject) == false then
		if pShouldPrint == true then print("isObjectAlive: Group is not a display object!! (searched for " .. pKeyName .. ")") end
		return false
	end
	
	if pGroupObject.keys then
		if #pGroupObject.keys == 0 then
			if pShouldPrint == true then print("isObjectAlive: Group is valid, but contains no keys!! (searched " .. pKeyName .. ")") end
			return false
		end
	
		for i = 1, #pGroupObject.keys do
			if pGroupObject.keys[i] == pKeyName then
				if pShouldPrint == true then print("isObjectAlive: Found " .. pKeyName .. "!!") end
				return true
			end
		end
		
		if pShouldPrint == true then print("isObjectAlive: Group is valid, but could not find keyName: " .. pKeyName .. "!!") end
		return false
	else
		if pShouldPrint == true then print("isObjectAlive: Group not a ui class, as it does not have a 'keys' table!! (searched for " .. pKeyName .. ")") end
		return false
	end
end
M.isObjectAlive = isObjectAlive

local function newGroup()
	-- object to be returned
	local group
	
	-- create a new display group
	group = display.newGroup()
	
	-- add a table called 'keys' which will hold a reference to all the IDs stored in the table
	group.keys = { }
	
	--[[ group:Add( pObject, keyName )
	-- Use: 	Adds a component from ui.lua into this group object. You can then access the component
	-- 			by accessing the array index equal to the object ID name. See syntax below.
	-- Syntax: 	myGroup:Add( myPlayBtn, "playButton" )
	-- later: 	myGroup["playButton"] gives you the myPlayBtn object, which can you access any data like ID and position
	--]]
	function group:Add(pObject, keyName)
		self:insert(pObject)
		self[keyName] = pObject
		table.insert(self.keys, keyName)
	end
	
	--[[ group:Link( pObject, keyName )
	-- Use: 	"Links" a component from ui.lua into this group object. This is similar to :Add() except it only
				adds a reference to the object. The object is not actually inserted into this group. Currently should
				only be used for newMasks.
	-- Syntax: 	myGroup:Link( myMask, "myGroupMask" )
	-- later: 	myGroup["myGroupMask"] gives you the myMask object, which can you access any data like ID and position
	--]]
	function group:Link(pObject, keyName)
		self[keyName] = pObject
		table.insert(self.keys, keyName)
	end
	
	--[[ group:Delete(keyName)
	-- Use:		Removes an individual component from the group. The key name to remove the component is
	--			the same used to add the component to the group (via group:Add() method)
	-- Syntax:	myGroup:Delete("playButton")
	--]]
	function group:Delete(keyName)
		for i = 1, #self.keys do
			if self.keys[i] == keyName then
				--print("Removing " .. self.keys[i])
				
				self[keyName]:removeSelf()
				self[keyName] = nil
				table.remove(self.keys, i)
				break
			end
		end
	end
	
	--[[ group:DeleteAll( )
	-- Use: 	Deletes all the objects that are stored in the group and clears the keys table.
	-- 			NOTE: The group will be empty after this executes.
	-- Syntax: 	myGroup:DeleteAll()
	--]]
	function group:DeleteAll()
		for i = 1, #self.keys do
			self[self.keys[i]] = nil
		end
		
		self.keys = { }
	end
	
	--[[ group:ChangeKey(pObject, newId)
	-- Use:		Changes the key that the given object is associated with. The object must still exist
	--			within the group for it to work.
	-- Syntax:	myGroup:ChangeKey(myFirstObject, "mySecondId")
	--]]
	function group:ChangeKey(pObject, newId)
		local objId = pObject._id
		for i = 1, #self.keys do
			if self.keys[i] == objId then
				table.remove(self.keys, i)
				self[objId] = nil
				self[newId] = pObject
				pObject._id = newId
				
				break
			end
		end
	end
	
	--[[ group:SetAllVisible(pBool)
	-- Use:		Sets all objects within the group to be visible or not (pBool)
	-- Syntax:	myGroup:SetAllVisible(true)
	--]]
	function group:SetAllVisible(pBool)
		for i = 1, #self.keys do
			self[self.keys[i]].isVisible = pBool
		end
	end
	
	return group
end
M.newGroup = newGroup

-- ==================================
-- BUTTON CLASS
-- ==================================

-- Helper function for newButton utility function
local function newButtonHandler( self, event )
	local result = true

	local default	= self["default"]
	local over 		= self["hover"]
	local disable	= self["disabled"]
	local hitBox	= self["hitBox"]
	
	-- General "onEvent" function overrides onPress and onRelease, if present
	local onEvent = self._onEvent

	local onPress = self._onPress
	local onRelease = self._onRelease
	local onMoved = self._onMoved
	
	-- Sounds
	local onPressSound = self.onPressSound
	local onReleaseSound = self.onReleaseSound
	
	local isDisabled = self.isDisabled
	
	event.parentGroup = self.parentGroup

	local buttonEvent = {}
	if (self._id) then
		--> JS
		event.id = self._id;
		--> END JS
		buttonEvent.id = self._id
	end
	
	buttonEvent.isActive = self.isActive
	buttonEvent.target = self
	local phase = event.phase
	
	if self.isActive then
        if "began" == phase then
			if isDisabled then return end
			
			if over then 
				default.isVisible = false
				over.isVisible = true
			end
			
			if onEvent then
				buttonEvent.phase = "press"
				buttonEvent.x = event.x - self.contentBounds.xMin
				buttonEvent.y = event.y - self.contentBounds.yMin
				result = onEvent( buttonEvent )
			elseif onPress then
				if onPressSound then
					myAudio.PlayAudio(onPressSound)
				end
				
				result = onPress( event )
			end
 
			-- Subsequent touch events will target button even if they are outside the contentBounds of button
			display.getCurrentStage():setFocus( self )
			self.isFocus = true
                
        elseif self.isFocus then
			local bounds = self.contentBounds
			local x,y = event.x,event.y
			local isWithinBounds = 
				bounds.xMin <= x and bounds.xMax >= x and bounds.yMin <= y and bounds.yMax >= y
				
			local canReleaseOutsideBounds = self.canReleaseOutsideBounds

			if "moved" == phase then
				if isDisabled then return end
				
				if over then
					-- The rollover image should only be visible while the finger is within button's stageBounds
					default.isVisible = not isWithinBounds
					over.isVisible = isWithinBounds
				end
					
				if onMoved then
					result = onMoved( event )
				end
					
			elseif "ended" == phase or "cancelled" == phase then 
				if isDisabled then return end
				
				if over then 
					default.isVisible = true
					over.isVisible = false
				end
				
				if "ended" == phase then
					-- Only consider this a "click" if the user lifts their finger inside button's stageBounds
					if isWithinBounds or canReleaseOutsideBounds then
						if onEvent then
							buttonEvent.phase = "release"
							buttonEvent.x = event.x - bounds.xMin
							buttonEvent.y = event.y - bounds.yMin
							result = onEvent( buttonEvent )
						elseif onRelease then
							if onReleaseSound then
								myAudio.PlayAudio(onReleaseSound)
							end
							
							result = onRelease( event )
						end
					end
				end
				
				-- Allow touch events to be sent normally to the objects they "hit"
				display.getCurrentStage():setFocus( self, nil )
				self.isFocus = false
			end
        end
        
	end
	
	return true
end
 
-- Button class
local function newButton( imageSrc, width, height, params )
	-- object to be returned
	local button
	
	--[[ optional params ===========
	x, y										--> left, top position of the image on-screen
	adjustX, adjustY							--> typically small values that we use to adjust x, y positions if screen is zoomed
	alpha										--> change the alpha level of the default state of button
	overSrc, overWidth, overHeight				--> change the image, width, and height for the 'over' state of image
	scale, overScale							--> scale entire image group size (1.0 = 100%, 0.5 = 50%, 2.0 = 200%)
	overAlpha									--> change the alpha of the 'over' state image
	referencePoint								--> change how the object is anchored (i.e., display.TopLeftReferencePoint)
	disabledSrc, disabledWidth, disabledHeight	--> change the image, width and height for the 'disabled' state
	disabledAlpha								--> change the alpha of the image when its disabled
	customHitBox								--> an image to use as a hitBox for the button, expanding its area to be touched (should be a transparent image!)
	hitBoxSize									--> table that contains width and height of the customHitBox (hitBoxSize = { 100, 80 }, is 100px width and 80px height)
	canReleaseOutsideBounds						--> default false, if true, can call release code even if release touch outside of 
	
	id											--> a string identifer that uniquely identifies this button
	parentGroup									--> a display group that the button will be inserted into
	doesNotRequireGroup							--> if true, do not throw an error if parentGroup or an id does not exist (defaults to false)
	
	onPress, onRelease, onMoved					--> listener functions that will trigger on press, release, moved
	onPressSound, onReleaseSound				--> audio sounds that will accompany onPress and onRelease functions
	-- ============================ --]]
        
	local sizeDivide = 1
	local sizeMultiply = 1
	
	local default, over, disabled, hitBox, size, font, textColor, offset
 
	if display.contentScaleX < 1.0 or display.contentScaleY < 1.0 then
		sizeMultiply = 2
		sizeDivide = 0.5                
	end
        
	button = display.newGroup()
	if isDisplayObject(imageSrc) then
		default = imageSrc
	else
		default = display.newImageRect ( imageSrc , width , height )
	end
	
	if params.alpha then
		default.alpha = params.alpha
	end
	
	button:insert( default, false )
	button["default"] = default
        
	if params.overSrc then
		if isDisplayObject(params.overSrc) then
			over = params.overSrc
		else
			local oWidth, oHeight
			if params.selectedWidth  then oWidth = params.selectedWidth   else oWidth = width   end
			if params.selectedHeight then oHeight = params.selectedHeight else oHeight = height end
		
			over = display.newImageRect ( params.overSrc , oWidth , oHeight )
		end
		
		if params.overAlpha then
			over.alpha = params.overAlpha
		end
		
		if params.overScale then
			over:scale(params.overScale,params.overScale)
		end
		
		over.isVisible = false
		button:insert( over, false )
		button["hover"] = over
	else
		button["hover"] = nil
	end
	
	if params.disabledSrc then
		if isDisplayObject(params.toggleSrc) then
			disabled = params.disabledSrc
		else
			local dWidth, dHeight
			if params.disabledWidth then dWidth = params.disabledWidth else dWidth = width end
			if params.disabledHeight then dHeight = params.disabledHeight else dHeight = height end
			
			disabled = display.newImageRect ( params.disabledSrc , dWidth, dHeight )
		end
		
		disabled.isVisible = false
		button:insert( disabled, false )
		button["disabled"] = disabled
	else
		button["disabled"] = nil
	end
	
	if params.disabledAlpha then
		button.disabledAlpha = params.disabledAlpha
	else
		button.disabledAlpha = 0.5
	end
	
	if params.referencePoint then
		button:setReferencePoint( params.referencePoint )
	end
	
	button.canReleaseOutsideBounds = false
	if params.canReleaseOutsideBounds then
		button.canReleaseOutsideBounds = params.canReleaseOutsideBounds
	end
	
	if params.scale then
		button:scale(params.scale, params.scale)
	end

	if ( params.onPress and ( type(params.onPress) == "function" ) ) then
		button._onPress = params.onPress
	end
	
	if ( params.onRelease and ( type(params.onRelease) == "function" ) ) then
		button._onRelease = params.onRelease
	end
	
	if ( params.onMoved and ( type(params.onMoved) == "function" ) ) then
		button._onMoved = params.onMoved
	end
	
	if (params.onEvent and ( type(params.onEvent) == "function" ) ) then
		button._onEvent = params.onEvent
	end
	
	if params.onPressSound then
		button.onPressSound = params.onPressSound
	end
	
	if params.onReleaseSound then
		button.onReleaseSound = params.onReleaseSound
	end
        
	-- set button to active (meaning, can be pushed)
	button.isActive = true
	button.isDisabled = false
	
	-- Set button as a table listener by setting a table method and adding the button as its own table listener for "touch" events
	button.touch = newButtonHandler
	button:addEventListener( "touch", button )
	
	if params.x then
		if params.adjustX then
			button.x = params.x + params.adjustX;
		else
			button.x = params.x
		end
	end
	
	if params.y then
		if params.adjustY then
			button.y = params.y + params.adjustY;
		else
			button.y = params.y
		end
	end
	
	if params.id then
		button._id = params.id
	end
	
	if params.customHitBox then
		if params.hitBoxSize then
			if isDisplayObject(params.customHitBox) then
				hitBox = params.customHitBox
			else
				hitBox = display.newImageRect( params.customHitBox, params.hitBoxSize[1], params.hitBoxSize[2] )
			end
			
			button:insert( hitBox, false )
			button["hitBox"] = hitBox
			hitBox:toBack()
		else
			print("WARNING: Button with ID of " .. params.id .. " has a customHitBox param, but no hitBoxSize! No hitBox added!")
			button["hitBox"] = nil
		end
		
		hitBox.x, hitBox.y = default.contentWidth * 0.5, default.contentHeight * 0.5
	else
		button["hitBox"] = nil
	end
	
	if params.doesNotRequireGroup == nil then
		params.doesNotRequireGroup = false
	end
	
	if params.parentGroup then
		params.parentGroup:Add(button, button._id)
		button.parentGroup = params.parentGroup
	else
		if params.doesNotRequireGroup == false then
			print("ERROR: Button ID " .. button._id .. " does not have a valid parentGroup! Fix this.")
			button:removeSelf()
		end
	end	

	-- ==================================================
	-- Public methods
	-- ==================================================
	function button:setText( newText, params )
		local labelText = self.text
		if ( labelText ) then
			labelText:removeSelf()
			self.text = nil
		end

		local labelShadow = self.shadow
		if ( labelShadow ) then
			labelShadow:removeSelf()
			self.shadow = nil
		end

		local labelHighlight = self.highlight
		if ( labelHighlight ) then
			labelHighlight:removeSelf()
			self.highlight = nil
		end
		
		if ( params.size and type(params.size) == "number" ) then size=params.size else size=20 end
		if ( params.font ) then font=params.font:getFont() else font=native.systemFontBold end
		if ( params.textColor ) then textColor=params.textColor else textColor={ 255, 255, 255, 255 } end
		
		size = size * sizeMultiply
		
		-- Optional vertical correction for fonts with unusual baselines (I'm looking at you, Zapfino)
		if ( params.offset and type(params.offset) == "number" ) then offset=params.offset else offset = 0 end
		
		if ( params.emboss ) then
			-- Make the label text look "embossed" (also adjusts effect for textColor brightness)
			local textBrightness = ( textColor[1] + textColor[2] + textColor[3] ) / 3
			
			labelHighlight = display.newText( newText, 0, 0, font, size )
			if ( textBrightness > 127) then
				labelHighlight:setTextColor( 255, 255, 255, 20 )
			else
				labelHighlight:setTextColor( 255, 255, 255, 140 )
			end
			button:insert( labelHighlight, true )
			labelHighlight.x = labelHighlight.x + 1.5; labelHighlight.y = labelHighlight.y + 1.5 + offset
			self.highlight = labelHighlight

			labelShadow = display.newText( newText, 0, 0, font, size )
			if ( textBrightness > 127) then
				labelShadow:setTextColor( 0, 0, 0, 128 )
			else
				labelShadow:setTextColor( 0, 0, 0, 20 )
			end
			button:insert( labelShadow, true )
			labelShadow.x = labelShadow.x - 1; labelShadow.y = labelShadow.y - 1 + offset
			self.shadow = labelShadow
			
			labelHighlight.xScale = sizeDivide; labelHighlight.yScale = sizeDivide
			labelShadow.xScale = sizeDivide; labelShadow.yScale = sizeDivide
		end
		
		labelText = display.newText( newText, 0, 0, font, size )
		labelText:setTextColor( textColor[1], textColor[2], textColor[3], textColor[4] )
		button:insert( labelText, true )
		labelText.y = labelText.y + offset
		self.text = labelText
		
		if params.font.yOffset then
			labelText.y = labelText.y + params.font.yOffset
		end
		
		labelText.xScale = sizeDivide; labelText.yScale = sizeDivide
	end
	
	--[[ Enable()
	-- Use: 	Set the button to either an enabled or disabled state
	-- Syntax:  myButton:Enable();
	--]]
	function button:Enable(pBool)
		self.isDisabled = not pBool
		
		if self["disabled"] then 
			self["default"].isVisible = pBool	-- default
		else
			self["default"].isVisible = true	-- default
		end
	
		if self["hover"] 	then self["hover"].isVisible = false 		end	-- over
		if self["disabled"] then self["disabled"].isVisible = not pBool end	-- disable
		
		if pBool == true then
			if self["disabled"] then 
				self["disabled"].alpha = 1.0
			else 
				self["default"].alpha = 1.0
			end
		else
			if self["disabled"] then
				if self["disabled"] then self["disabled"].alpha = self.disabledAlpha end
			else
				self["default"].alpha = self.disabledAlpha
			end
		end
	end
	
	function button:FocusTouch(pId)
		display.getCurrentStage():setFocus( self, pId )
		self.isFocus = true
	end
	
	function button:ReleaseTouch()
		-- release the focus of the currently touched button
		display.getCurrentStage():setFocus( self, nil )
		self.isFocus = false
	end
	
	--[[ SetReleaseCallback(pFunc)
	-- Use:		Change the button's onRelease callback after it has been declared.
	--			pFunc must be a valid function.
	-- Syntax:	myButton:SetReleaseCallback(newReleaseFunction)
	--]]
	function button:SetReleaseCallback(pReleaseFunc)
		if ( pReleaseFunc and ( type(pReleaseFunc) == "function" ) ) then
			self._onRelease = pReleaseFunc
		end
	end
	
	--[[ Reset()
	-- Use:		reset the button to its normal state, showing 'default' image and hiding all others.
	-- Syntax:	myButton:Reset()
	--]]
	function button:Reset()
		self["default"].isVisible = true
		
		if self["hover"] 	then self["hover"].isVisible = false 	end
		if self["disabled"] then self["disabled"].isVisible = false end
	end
	
	function button:InsertObject(pObject, pKeyName)
		self:insert(pObject, false)
		self[pKeyName] = pObject
		
		pObject:toFront()
	end
	
	return button
end
M.newButton = newButton

-- ==================================
-- TOGGLE BUTTON CLASS
-- ==================================

-- Helper function for newToggleButton utility function
local function newToggleButtonHandler( self, event )
	local result = true

	local default 		= self["default"]
	local over			= self["hover"]
	local toggle		= self["toggle"]
	local toggleOver	= self["toggleOver"]
	
	-- General "onEvent" function overrides onPress and onRelease, if present
	local onEvent = self._onEvent

	local onPress = self._onPress
	local onRelease = self._onRelease
	local onMoved = self._onMoved
	local onMovedRelease = self._onMovedRelease
	
	event.hasMoved = self.hasMoved
	
	-- Sounds
	local onPressSound = self.onPressSound
	local onReleaseSound = self.onReleaseSound
	
	local isDisabled = self.isDisabled
 
	local buttonEvent = {}
	if (self._id) then
		--> JS
		event.id = self._id;
		event.toggledState = self.toggledState
		--> END JS
		buttonEvent.id = self._id
	end
	
	buttonEvent.isActive = self.isActive
	buttonEvent.target = self
	local phase = event.phase
	
	if self.isActive then
        if "began" == phase then
			if isDisabled then return end
			
			if over or toggleOver then 
				default.isVisible = false
				if toggle then toggle.isVisible = false end
				
				-- show either over or toggleOver, depending on toggledState
				if over then over.isVisible = not self.toggledState end
				if toggleOver then toggleOver.isVisible = self.toggledState end
			end
			
			self.hasMoved = false
			self.clickX = event.x
			self.clickY = event.y

			if onEvent then
				buttonEvent.phase = "press"
				buttonEvent.x = event.x - self.contentBounds.xMin
				buttonEvent.y = event.y - self.contentBounds.yMin
				result = onEvent( buttonEvent )
			elseif onPress then
				if onPressSound then
					myAudio.PlayAudio(onPressSound)
				end
			
				result = onPress( event )
			end

			-- Subsequent touch events will target button even if they are outside the contentBounds of button
			display.getCurrentStage():setFocus( self )
			self.isFocus = true
                
        elseif self.isFocus then
			local bounds = self.contentBounds
			local x,y = event.x,event.y
			local isWithinBounds = 
					bounds.xMin <= x and bounds.xMax >= x and bounds.yMin <= y and bounds.yMax >= y
			
			if "moved" == phase then
				if isDisabled then return end
				
				if over or toggleOver then
					-- The rollover image should only be visible while the finger is within button's stageBounds
					if self.toggledState == false then
						default.isVisible = not isWithinBounds
						if over then over.isVisible = isWithinBounds end
					else
						toggle.isVisible = not isWithinBounds
						if toggleOver then toggleOver.isVisible = isWithinBounds end
					end
				end
				
				if onMoved then
					-- JS: old version
					--result = onMoved( event )
					
					local xDiff = (x - self.clickX)
					local yDiff = (y - self.clickY)
					
					-- only send an onMoved if I've moved over a certain threshhold
					if math.abs(xDiff) > 5 or math.abs(yDiff) > 5 then
						self.hasMoved = true
						result = onMoved( event )
					end
				end
                        
			elseif "ended" == phase or "cancelled" == phase then 
				if isDisabled then return end
				
				if (over or toggle) and isWithinBounds then
					if self.hasMoved then
						default.isVisible = not self.toggledState
						if toggle then toggle.isVisible = self.toggledState end
						if over then over.isVisible = false end
						if toggleOver then toggleOver.isVisible = false end
					else
						self.toggledState = not self.toggledState
						event.toggledState = self.toggledState
					
						default.isVisible = not self.toggledState
						if toggle then toggle.isVisible = self.toggledState end
						if over then over.isVisible = false end
						if toggleOver then toggleOver.isVisible = false end
					end
				end
				
				if "ended" == phase then
					-- Only consider this a "click" if the user lifts their finger inside button's stageBounds
					if isWithinBounds and not self.hasMoved then
						if onEvent then
							buttonEvent.phase = "release"
							buttonEvent.x = event.x - bounds.xMin
							buttonEvent.y = event.y - bounds.yMin
							result = onEvent( buttonEvent )
						elseif onRelease then
							if onReleaseSound then
								myAudio.PlayAudio(onReleaseSound)
							end
				
							result = onRelease( event )
						end
					elseif onMovedRelease then
						-- user let go of a dragged state, return to bottom position
						result = onMovedRelease( event )
					end
				end
				
				-- Allow touch events to be sent normally to the objects they "hit"
				display.getCurrentStage():setFocus( self, nil )
				self.isFocus = false
			end
		end
	end
	
	return true
end

-- Toggle Button class 
local function newToggleButton( imageSrc, width, height, params )
	-- object to be returned
	local button
	
	--[[ optional params ===========
	x, y                                            --> left, top position of the image on-screen
	adjustX, adjustY                                --> typically small values that we use to adjust x, y positions if screen is zoomed
	alpha                                           --> change the alpha level of the default image
	overSrc, overWidth, overHeight                  --> change the image, width, and height for the 'over' state of image
	toggleSrc, toggleWidth, toggleHeight            --> change the image, width, and height for the 'toggled' state of image
	toggleOverSrc, tOverWidth, tOverHeight          --> change the image, width, and height for the 'toggleOver' state of image
	overAlpha, toggleAlpha, OverAlpha               --> change the alpha of the 'over', 'toggled', and 'toggleOver' states
    disabledSrc, disabledWidth, disabledHeight      --> sets if a disabled image is used when the button state is set to disabled
	scale                                           --> scale entire image group size (1.0 = 100%, 0.5 = 50%, 2.0 = 200%)
	referencePoint                                  --> change how the object is anchored (i.e., display.TopLeftReferencePoint)
	customHitBox                                    --> an image to use as a hitBox for the button, expanding its area to be touched (should be a transparent image!)
	hitBoxSize                                      --> table that contains width and height of the customHitBox (hitBoxSize = { 100, 80 }, is 100px width and 80px height)
	
	id                                              --> a string identifer that uniquely identifies this button
	parentGroup                                     --> a display group that the button will be inserted into
	doesNotRequireGroup                             --> if true, do not throw an error if parentGroup or an id does not exist (defaults to false)
	
	onPress, onRelease, onMoved                     --> listener functions that will trigger on press, release, and moved
	onMovedRelease                                  --> listener function that triggers when an object is moved, and then released from the drag
	
	onPressSound, onReleaseSound                    --> audio sounds that will accompany onPress and onRelease functions
	-- ============================ --]] 
        
	local sizeDivide = 1
	local sizeMultiply = 1
 
	if display.contentScaleX < 1.0 or display.contentScaleY < 1.0 then
		sizeMultiply = 2
		sizeDivide = 0.5                
	end
        
	button = display.newGroup()
	local default, over, toggle, overToggle, disabled, toggleDisabled, hitBox = nil
	
	if isDisplayObject(imageSrc) then
		default = imageSrc
	else
		default = display.newImageRect ( imageSrc , width , height )
	end             
	
	if params.alpha then
		default.alpha = params.alpha
	end
	
	button:insert( default, false )
	button["default"] = default
        
	if params.overSrc then
		if isDisplayObject(params.overSrc) then
			over = params.overSrc
		else
			local oWidth, oHeight
			if params.overWidth then oWidth = params.overWidth else oWidth = width end
			if params.overHeight then oHeight = params.overHeight else oHeight = height end
		
			over = display.newImageRect ( params.overSrc , oWidth, oHeight )
		end
		
		if params.overAlpha then
			over.alpha = params.overAlpha
		end

		over.isVisible = false
		button:insert( over, false )
		
		button["hover"] = over
	else
		button["hover"] = nil
	end
		
	if params.toggleSrc then
		if isDisplayObject(params.toggleSrc) then
			toggle = params.toggleSrc
		else
			local tWidth, tHeight
			if params.toggleWidth then tWidth = params.toggleWidth else tWidth = width end
			if params.toggleHeight then tHeight = params.toggleHeight else tHeight = height end
			
			toggle = display.newImageRect ( params.toggleSrc, tWidth, tHeight )
		end
		
		if params.toggleAlpha then
			toggle.alpha = params.toggleAlpha
		end

		toggle.isVisible = false
		button:insert( toggle, false )
		
		button["toggle"] = toggle
	else
		button["toggle"] = nil
	end
	
	if params.toggleOverSrc then
		if isDisplayObject(params.toggleOverSrc) then
			overToggle = params.toggleOverSrc
		else
			local tWidth, tHeight
			if params.tOverWidth then tWidth = params.tOverWidth elseif params.toggleWidth then tWidth = params.toggleWidth else tWidth = width end
			if params.tOverHeight then tHeight = params.tOverHeight elseif params.toggleHeight then tHeight = params.toggleHeight else tHeight = height end
			
			overToggle = display.newImageRect ( params.toggleOverSrc, tWidth, tHeight )
		end
		
		if params.tOverAlpha then
			overToggle.alpha = params.tOverAlpha
		end
		
		overToggle.isVisible = false
		button:insert( overToggle, false )
		
		button["toggleOver"] = overToggle
	end
    
    if params.disabledSrc then
		if isDisplayObject(params.toggleSrc) then
			disabled = params.disabledSrc
		else
			local dWidth, dHeight
			if params.disabledWidth then dWidth = params.disabledWidth else dWidth = width end
			if params.disabledHeight then dHeight = params.disabledHeight else dHeight = height end
            
			disabled = display.newImageRect ( params.disabledSrc , dWidth, dHeight )
		end
		
		disabled.isVisible = false
		button:insert( disabled, false )
		button["disabled"] = disabled
	else
		button["disabled"] = nil
	end
    
    if params.toggleDisabledSrc then
		if isDisplayObject(params.toggleSrc) then
			toggleDisabled = params.toggleDisabledSrc
		else
			local dWidth, dHeight
			if params.disabledWidth then dWidth = params.disabledWidth else dWidth = width end
			if params.disabledHeight then dHeight = params.disabledHeight else dHeight = height end
            
			toggleDisabled = display.newImageRect ( params.toggleDisabledSrc , dWidth, dHeight )
		end
		
		toggleDisabled.isVisible = false
		button:insert( toggleDisabled, false )
		button["toggleDisabled"] = toggleDisabled
	else
		button["toggleDisabled"] = nil
	end
	
	if params.referencePoint then
		button:setReferencePoint( params.referencePoint )
	end
	
	if params.scale then
		button:scale(params.scale, params.scale)
	end

	if ( params.onPress and ( type(params.onPress) == "function" ) ) then
		button._onPress = params.onPress
	end
	
	if ( params.onRelease and ( type(params.onRelease) == "function" ) ) then
		button._onRelease = params.onRelease
	end
	
	if ( params.onMovedRelease and ( type(params.onMovedRelease) == "function" ) ) then
		button._onMovedRelease = params.onMovedRelease
	end
	
	if ( params.onMoved and ( type(params.onMoved) == "function" ) ) then
		button._onMoved = params.onMoved
	end
	
	if (params.onEvent and ( type(params.onEvent) == "function" ) ) then
		button._onEvent = params.onEvent
	end
	
	if params.onPressSound then
		button.onPressSound = params.onPressSound
	end
		
	if params.onReleaseSound then
		button.onReleaseSound = params.onReleaseSound
	end
	
	-- if user doesn't specify a disabledAlpha, default to 0.5
	if params.disabledAlpha then
		button.disabledAlpha = params.disabledAlpha
	else
		button.disabledAlpha = 0.5
	end
	
	-- default toggledState to false
	button.toggledState = false
	
	-- set button to active (meaning, can be pushed)
	button.isActive = true
	
	-- Set button as a table listener by setting a table method and adding the button as its own table listener for "touch" events
	button.touch = newToggleButtonHandler
	button:addEventListener( "touch", button )

	if params.x then
		if params.adjustX then
			button.x = params.x + params.adjustX;
		else
			button.x = params.x
		end
	end
	
	if params.y then
		if params.adjustY then
			button.y = params.y + params.adjustY;
		else
			button.y = params.y
		end
	end
	
	if params.id then
		button._id = params.id
	end
	
	if params.customHitBox then
		if params.hitBoxSize then
			if isDisplayObject(params.customHitBox) then
				hitBox = params.customHitBox
			else
				hitBox = display.newImageRect( params.customHitBox, params.hitBoxSize[1], params.hitBoxSize[2] )
			end
			
			button:insert( hitBox, false )
			button["hitBox"] = hitBox
			hitBox:toBack()
		else
			print("WARNING: Button with ID of " .. params.id .. " has a customHitBox param, but no hitBoxSize! No hitBox added!")
			button["hitBox"] = nil
		end
		
		hitBox.x, hitBox.y = default.contentWidth * 0.5, default.contentHeight * 0.5
		--[[if params.hitBoxOffset then
			hitBox.x, hitBox.y = params.hitBoxOffset[1], params.hitBoxOffset[2]
		end--]]
	else
		button["hitBox"] = nil
	end
	
	if params.doesNotRequireGroup == nil then
		params.doesNotRequireGroup = false
	end
	
	if params.parentGroup then
		params.parentGroup:Add(button, button._id)
	else
		if params.doesNotRequireGroup == false then
			print("ERROR: Button ID " .. button._id .. " does not have a valid parentGroup! Fix this.")
			button:removeSelf()
		end
	end	
	
	-- ==================================================
	-- Public methods
	-- ==================================================
	--[[ Enable()
	-- Use: 	Set the button to either an enabled or disabled state
	-- Syntax:  myButton:Enable();
	--]]
	function button:Enable(pBool)
		self.isDisabled = not pBool
				
		-- over states always hidden
		if self["hover"] then self["hover"].isVisible = false end				-- over
		if self["toggleOver"] then self["toggleOver"].isVisible = false end	-- toggleOver
        
        if not self.toggledState then
			self["default"].isVisible = (pBool and not self.toggledState) or (self["disabled"] == nil)					-- default
			if self["disabled"] then self["disabled"].isVisible = not pBool and not self.toggledState end               -- disabled default
		else
			self["toggle"].isVisible = (pBool and self.toggledState) or (self["toggleDisabled"] == nil)                 -- toggled
			if self["toggleDisabled"] then self["toggleDisabled"].isVisible = not pBool and self.toggledState end       -- disabled toggle
		end
		
		if pBool == true then
			self["default"].alpha = 1.0
			if self["disabled"] then self["disabled"].alpha = 1.0 end
			if self["toggleDisabled"] then self["toggleDisabled"].alpha = 1.0 end
		else
			self["default"].alpha = self.disabledAlpha
			if self["disabled"] then self["disabled"].alpha = self.disabledAlpha end
			if self["toggleDisabled"] then self["toggleDisabled"].alpha = self.disabledAlpha end
		end
	end
	
	--[[ ForceState()
	-- Use: 	pass in a bool, force the toggleButton to a default or toggled state
	-- Syntax:  myToggleButton:ForceState( bool );
	--]]
	function button:ForceState( pToggleState )
		self.toggledState = pToggleState

		self["default"].isVisible = not self.toggledState

		if self["hover"] 		then self["hover"].isVisible = false 				end	-- over always hidden
		if self["toggleOver"]	then self["toggleOver"].isVisible = false 			end	-- overToggle always hidden
		if self["toggle"] 		then self["toggle"].isVisible = self.toggledState 	end	-- toggle
	end
		
	--[[ GetCurrentState()
	-- Use: 	returns a toggleButton's toggledState
	-- Syntax:  myBool = myToggleButton:GetCurrentState();
	--]]
	function button:GetCurrentState()
		return self.toggledState;
	end
	
	--[[ Reset()
	-- Use:		reset the button to its normal state, showing 'default' image and hiding all others.
	-- Syntax:	myButton:Reset()
	--]]
	function button:Reset()
		self["default"].isVisible = not self.toggledState												 -- default
		
		if self["hover"] 		then self["hover"].isVisible = false 				end	 -- over
		if self["toggleOver"]	then self["toggleOver"].isVisible = false 			end	 -- overToggle
		if self["toggle"] 		then self["toggle"].isVisible = self.toggledState 	end	 -- toggle
	end
	
	function button:setText( newText, params )
		local labelText = self.text
		if ( labelText ) then
			labelText:removeSelf()
			self.text = nil
		end

		local labelShadow = self.shadow
		if ( labelShadow ) then
			labelShadow:removeSelf()
			self.shadow = nil
		end

		local labelHighlight = self.highlight
		if ( labelHighlight ) then
			labelHighlight:removeSelf()
			self.highlight = nil
		end
		
		if ( params.size and type(params.size) == "number" ) then size=params.size else size=20 end
		if ( params.font ) then font=params.font:getFont() else font=native.systemFontBold end
		if ( params.textColor ) then textColor=params.textColor else textColor={ 255, 255, 255, 255 } end
		
		size = size * sizeMultiply
		
		-- Optional vertical correction for fonts with unusual baselines (I'm looking at you, Zapfino)
		if ( params.offset and type(params.offset) == "number" ) then offset=params.offset else offset = 0 end
		
		if ( params.emboss ) then
			-- Make the label text look "embossed" (also adjusts effect for textColor brightness)
			local textBrightness = ( textColor[1] + textColor[2] + textColor[3] ) / 3
			
			labelHighlight = display.newText( newText, 0, 0, font, size )
			if ( textBrightness > 127) then
				labelHighlight:setTextColor( 255, 255, 255, 20 )
			else
				labelHighlight:setTextColor( 255, 255, 255, 140 )
			end
			button:insert( labelHighlight, true )
			labelHighlight.x = labelHighlight.x + 1.5; labelHighlight.y = labelHighlight.y + 1.5 + offset
			self.highlight = labelHighlight

			labelShadow = display.newText( newText, 0, 0, font, size )
			if ( textBrightness > 127) then
				labelShadow:setTextColor( 0, 0, 0, 128 )
			else
				labelShadow:setTextColor( 0, 0, 0, 20 )
			end
			button:insert( labelShadow, true )
			labelShadow.x = labelShadow.x - 1; labelShadow.y = labelShadow.y - 1 + offset
			self.shadow = labelShadow
			
			labelHighlight.xScale = sizeDivide; labelHighlight.yScale = sizeDivide
			labelShadow.xScale = sizeDivide; labelShadow.yScale = sizeDivide
		end
		
		labelText = display.newText( newText, 0, 0, font, size )
		labelText:setTextColor( textColor[1], textColor[2], textColor[3], textColor[4] )
		button:insert( labelText, true )
		labelText.y = labelText.y + offset
		self.text = labelText
		
		if params.font.yOffset then
			labelText.y = labelText.y + params.font.yOffset
		end
		
		labelText.xScale = sizeDivide; labelText.yScale = sizeDivide
	end

	return button
end
M.newToggleButton = newToggleButton

-- ==================================
-- LABEL/TEXT CLASSES
-- ==================================

-- Label class
local function newLabel( params )
	-- object to be returned
	local label
	
	--[[ required params ===========
	bounds							--> a table that has position/size properties: { top, left, width, height }
	text							--> string of text that will be displayed
	
		optional params ===========
	size							--> font size (defaults to 20)
	font							--> font type to use (defaults to native system bold)
	textColor						--> a table that tells font color: {r, g, b, a} (defaults to white)
    isGradient                      --> if the given textColor is a gradient, this must be true!
	align							--> "center", "left", or "right" aligned text. (defaults to center)
	verticalAlign					--> "top", "center", or "bottom" aligned text. (defaults to top)
	ignoreYOffset					--> custom fonts can have yOffsets built-in. If this is true, ignore those yOffsets. (should set to true if you're positioning text based on another text's position)
	
	id								--> a string identifer that uniquely identifies this button
	parentGroup						--> a display group that the button will be inserted into
	doesNotRequireGroup				--> if true, do not throw an error if parentGroup or an id does not exist (defaults to false)
	-- ============================ --]] 
	
	local size, font, textColor, align
	
	local sizeDivide = 1
	local sizeMultiply = 1
 
	if ( params.bounds ) then
		local bounds = params.bounds
		local top = bounds[1]
		local left = bounds[2]
		local width = bounds[3]
		local height = bounds[4]

		if ( params.size and type(params.size) == "number" ) then size=params.size else size=20 end
		if ( params.font ) then font=params.font:getFont() else font=native.systemFont end
		if ( params.textColor ) then textColor=params.textColor else textColor={ 255, 255, 255, 255 } end
		if ( params.align ) then align = params.align else align = "center" end
		
		if ( params.text ) then
			label = display.newText( params.text, 0, 0, font, size * 2 )
			label.xScale = 0.5; label.yScale = 0.5
            
            if params.isGradient then
                label:setTextColor( textColor )
            else
                label:setTextColor( textColor[1], textColor[2], textColor[3], textColor[4] or 255 )
            end

			-- TODO: handle no-initial-text case by creating a field with an empty string?

			if ( align == "left" ) then
				label.x = left + label.contentWidth * 0.5
			elseif ( align == "right" ) then
				label.x = (left + width) - label.contentWidth * 0.5
			else
				label.x = ((2 * left) + width) * 0.5
			end
		end
		
		label.y = top + label.contentHeight * 0.5
		
		if params.verticalAlign then
			if params.verticalAlign == "center" then
				label.y = label.y - label.contentHeight/2
			elseif params.verticalAlign == "bottom" then
				label.y = label.y - label.contentHeight
			end
		end
		
		if params.font.yOffset then
			if params.ignoreYOffset ~= true then
				label.y = label.y + params.font.yOffset
			end
		end
		
		if params.id then
			label._id = params.id
		end
		
		if params.doesNotRequireGroup == nil then
			params.doesNotRequireGroup = false
		end
		
		if params.parentGroup then
			params.parentGroup:Add(label, label._id)
		else
			if params.doesNotRequireGroup == false then
				print("ERROR: Label ID " .. label._id .. " does not have a valid parentGroup! Fix this.")
				label:removeSelf()
			end
		end	

		-- ==================================================
		-- Public methods
		-- ==================================================
		function label:setText( newText )
			if ( newText ) then
				label.text = newText
				
				if ( "left" == align ) then
					label.x = self.x + label.contentWidth * 0.5
				elseif ( "right" == align ) then
					label.x = (self.x + width) - label.contentWidth * 0.5
				else
					label.x = ((2 * self.x) + width) * 0.5
				end
			end
		end
		
		function label:setSize( newSize )
			if type(newSize) == "number" then
				-- label font size is always twice as large as specified due to scaling being set to 0.5
				label.size = newSize * 2
				
				if ( "left" == align ) then
					label.x = left + label.contentWidth * 0.5
				elseif ( "right" == align ) then
					label.x = (left + width) - label.contentWidth * 0.5
				else
					label.x = ((2 * left) + width) * 0.5
				end
			end
		end
        
        function label:updatePos( x, y )
            if x ~= nil then
                label.x = x
            end
            
            if y ~= nil then
                label.y = y
            end
            
            if ( "left" == align ) then
                label.x = left + label.contentWidth * 0.5
            elseif ( "right" == align ) then
                label.x = (left + width) - label.contentWidth * 0.5
            else
                label.x = ((2 * left) + width) * 0.5
            end
        end
		
		function label:UpdateColor(color1, color2, color3, color4)
			label:setTextColor( color1 or 255, color2 or 255, color3 or 255, color4 or 255 )
		end
	end
	
	-- Return instance
	return label
end
M.newLabel = newLabel

-- AutoWrapping Label class
local function newAutoWrapText(text, pFont, size, color, width, params)
	if text == '' then return false end
	
	-- object to be returned
	local result = display.newGroup()
	
	--[[ required params ===========
	text							--> string of text that will be displayed
	pFont							--> font type to use (defaults to native system bold)
	size							--> font size (defaults to 20)
	color							--> a table that tells font color: {r, g, b, a} (defaults to black)
	width							--> the total allowed length of a line before text will wrap
	
		optional params ===========
	x, y							--> left, top position of the image on-screen
	adjustX, adjustY				--> typically small values that we use to adjust x, y positions if screen is zoomed
	referencePoint					--> change the anchor reference point of the display group (defaults to TopLeft)
	align 							--> string that can be set to "center" and "right". Since Left is defaulted, "left" is ignored
	verticalAlign					--> string that can be set to "center" and "bottom". Since Top is defaulted, "top" is ignored
	center							--> 
	ignoreYOffset					--> custom fonts can have yOffsets built-in. If this is true, ignore those yOffsets. (should set to true if you're positioning text based on another text's position)
	
	id								--> a string identifer that uniquely identifies this button
	parentGroup						--> a display group that the button will be inserted into
	doesNotRequireGroup				--> if true, do not throw an error if parentGroup or an id does not exist (defaults to false)
	-- ============================ --]] 
	
	myFont = pFont.isCustomFont ~= nil and pFont:getFont() or native.systemFontBold
	size = tonumber(size) or 12
	color = color or {255, 255, 255}
	width = width or display.contentWidth
	
	local alignment = params.align
	
	if params.center then
		alignment = "center"
	end
	
	function DoTextWrap(pText)
		-- clear out old wrapped text, if any
		for i = result.numChildren, 1, -1 do
			result[i]:removeSelf()
		end
		
		local myText = (pText ~= nil) and pText or text
	
		local lineCount = 0
		local textLength = string.len(myText)
		
		-- do each line separately
		for line in string.gmatch(myText, "[^%c]*\n?") do
			local currentLine = ''
			local currentLineLength = 0 -- the current length of the string in chars
			local currentLineWidth = 0 -- the current width of the string in pixs
			local testLineLength = 0 -- the target length of the string (starts at 0)
			
			-- iterate by each word
			for word, spacer in string.gmatch(line, "([^%s%-]+)([%s%-]*)") do
				local tempLine = currentLine..word..spacer
				local tempLineLength = string.len(tempLine)
				
				-- test to see if we are at a point to try to render the string
				if testLineLength > tempLineLength then
					currentLine = tempLine
					currentLineLength = tempLineLength
				else
					-- line could be long enough, try to render and compare against the max width
					local tempDisplayLine = display.newText(tempLine, 0, 0, myFont, size * 2)
					tempDisplayLine.yScale = 0.5; tempDisplayLine.xScale = 0.5;
					local tempDisplayWidth = tempDisplayLine.width / 2;
					tempDisplayLine:removeSelf();
					tempDisplayLine=nil;
					
					if tempDisplayWidth <= width then
						-- line not long enough yet, save line and recalculate for the next render test
						currentLine = tempLine
						currentLineLength = tempLineLength
						testLineLength = math.floor((width*0.9) / textLength)
					else
						-- line long enough, show the old line then start the new one
						local newDisplayLine = display.newText(currentLine, 0, (size * 1.3) * (lineCount - 1), myFont, size * 2)
						newDisplayLine:setReferencePoint(display.TopLeftReferencePoint)
						newDisplayLine.yScale = 0.5; newDisplayLine.xScale = 0.5;
						newDisplayLine:setTextColor(color[1], color[2], color[3])
						result:insert(newDisplayLine)
						lineCount = lineCount + 1
						currentLine = word..spacer
						currentLineLength = string.len(word)
						
						if alignment == "center" then
							newDisplayLine.x = (width - newDisplayLine.contentWidth)/2
						elseif alignment == "right" then
							newDisplayLine.x = (width - newDisplayLine.contentWidth)
						end
					end
				end
			end
			
			-- finally display any remaining text for the current line
			local newDisplayLine = display.newText(currentLine, 0, (size * 1.3) * (lineCount - 1), myFont, size * 2)
			newDisplayLine:setReferencePoint(display.TopLeftReferencePoint)
			newDisplayLine.yScale = 0.5; newDisplayLine.xScale = 0.5;
			newDisplayLine:setTextColor(color[1], color[2], color[3])
			result:insert(newDisplayLine)
			lineCount = lineCount + 1
			currentLine = ''
			currentLineLength = 0
			
			if alignment == "center" then
				newDisplayLine.x = (width - newDisplayLine.contentWidth)/2
			elseif alignment == "right" then
				newDisplayLine.x = (width - newDisplayLine.contentWidth)
			end
		end
	end
	
	DoTextWrap()
	
	if params.referencePoint then
		result:setReferencePoint( params.referencePoint )
	else
		result:setReferencePoint(display.TopLeftReferencePoint)
	end
	
	if params.x then
		result.x = params.x

		if params.adjustX then
			result.x = result.x + params.adjustX;
		end
	end
	
	if params.y then
		result.y = params.y
		
		if params.adjustY then
			result.y = result.y + params.adjustY;
		end
	end
	
	if params.verticalAlign then
		if params.verticalAlign == "center" then
			result.y = result.y - result.contentHeight/2
		elseif params.verticalAlign == "bottom" then
			result.y = result.y - result.contentHeight
		end
	end
	
	if pFont.isCustomFont ~= nil and pFont.yOffset then
		if params.ignoreYOffset ~= true then
			result.y = result.y + pFont.yOffset
		end
	end
	
	if params.id then
		result._id = params.id
	end
	
	if params.doesNotRequireGroup == nil then
		params.doesNotRequireGroup = false
	end
	
	if params.parentGroup then
		params.parentGroup:Add(result, result._id)
	else
		if params.doesNotRequireGroup == false then
			print("ERROR: AutoWrapText ID " .. result._id .. " does not have a valid parentGroup! Fix this.")
			result:removeSelf()
		end
	end
	
	-- ==================================================
	-- Public methods
	-- ==================================================
	
	--[[ setText(pNewText)
	-- Use:		Run the DoTextWrap logic again with a new text, pNewText.
	-- 			Will erase the old wrapped text before drawing the new text.
	-- Syntax:	myWrappedText:setText("This is my new text!")
	--]]
	function result:setText(pNewText)
		DoTextWrap(pNewText)
	end
	
	--[[ clearText()
	-- Use:		Clears out any text contained within this autoWrapText object.
	-- Syntax:	myWrappedText:clearText()
	--]]
	function result:clearText()
		for i = result.numChildren, 1, -1 do
			result[i]:removeSelf()
		end
	end
	
	function result:getText()
		local myText = ""
		
		for i = 1, result.numChildren do
			myText = myText .. result[i].text
		end
		
		return myText
	end
	
	function result:UpdateColor(color1, color2, color3, color4)
		for i=1, result.numChildren do
			--result[i]:SetTextColor(color1, color2, color3, color4)
		end
	end
	
	return result
end
M.newAutoWrapText = newAutoWrapText

-- ==================================
-- IMAGE CLASS
-- ==================================

-- Helper function for newImage utility function
local function newImageHandler( self, event )
	-- only purpose at the moment is to block touch events on objects that appear behind the image
	return self.blockInput
end

-- Image class
local function newImage( imageSrc, width, height, params )
	-- returned object
	local image
	
	--[[ optional params ===========
	x, y								--> left, top position of the image on-screen
	adjustX, adjustY					--> typically small values that we use to adjust x, y positions if screen is zoomed
	overSrc, overWidth, overHeight		--> change the image, width, and height for the 'over' state of image
	scale								--> scale entire image group size (1.0 = 100%, 0.5 = 50%, 2.0 = 200%)
	referencePoint						--> change how the object is anchored (i.e., display.TopLeftReferencePoint)
	alpha								--> adjust the alpha level of the image
	customHitBox						--> an image to use as a hitBox for this image, expanding its area to be touched (should be a transparent image!)
	hitBoxSize							--> table that contains width and height of the customHitBox (hitBoxSize = { 100, 80 }, is 100px width and 80px height)
	
	blockInput							--> if true, object will block input of other objects drawn behind it
	onTouch								--> if supplied, will use this function as the touch callback, not default newImageHandler
	id									--> a string identifer that uniquely identifies this button
	parentGroup							--> a display group that the button will be inserted into
	doesNotRequireGroup					--> if true, do not throw an error if parentGroup or an id does not exist (defaults to false)
	
	imageDirectory						--> specifies which directory to find the image in
	-- ============================ --]] 
        
	local sizeDivide = 1
	local sizeMultiply = 1
	
	local default, over, hitBox, size, font, textColor, offset, offsetX
 
	if display.contentScaleX < 1.0 or display.contentScaleY < 1.0 then
		sizeMultiply = 2
		sizeDivide = 0.5
	end

	image = display.newGroup()
	
	if isDisplayObject(imageSrc) then
		default = imageSrc
	else
		if params.imageDirectory == nil then
			default = display.newImageRect ( imageSrc , width , height )
		else
			default = display.newImageRect ( imageSrc , params.imageDirectory , width , height )
		end
		
		if params.alpha then
			default.alpha = params.alpha
		end
	end
	
	image:insert( default, false )
	image["default"] = default
        
	if params.overSrc then
		if isDisplayObject(params.overSrc) then
			over = params.overSrc
		else
			if params.imageDirectory == nil then
				over = display.newImageRect ( params.overSrc , params.overWidth , params.overHeight )
			else
				over = display.newImageRect ( params.overSrc , params.imageDirectory , params.overWidth , params.overHeight )
			end
		end
		if params.overAlpha then
			over.alpha = params.overAlpha
		end

		over.isVisible = false
		image:insert( over, false )
		image["hover"] = over
	else
		image["hover"] = nil
	end

	if params.referencePoint then
		image:setReferencePoint( params.referencePoint )
	end
	
	if params.scale then
		image:scale(params.scale, params.scale)
	end
	
	if params.blockInput then
		image.blockInput = params.blockInput
	else
		image.blockInput = false
	end
	
	local onTouch = newImageHandler
	if params.onTouch and (type(params.onTouch) == "function") then
		onTouch = params.onTouch
	end

	image.touch = onTouch
	image:addEventListener( "touch", image )

	if params.x then
		image.x = params.x
		
		if params.adjustX then
			image.x = image.x + params.adjustX;
		end
	end
	
	if params.y then
		image.y = params.y
		
		if params.adjustY then
			image.y = image.y + params.adjustY;
		end
	end

	if params.id then
		image._id = params.id
	end
	
	if params.customHitBox then
		if params.hitBoxSize then
			if isDisplayObject(params.customHitBox) then
				hitBox = params.customHitBox
			else
				hitBox = display.newImageRect( params.customHitBox, params.hitBoxSize[1], params.hitBoxSize[2] )
			end
			
			image:insert( hitBox, false )
			image["hitBox"] = hitBox
			hitBox:toBack()
		else
			print("WARNING: Image with ID of " .. params.id .. " has a customHitBox param, but no hitBoxSize! No hitBox added!")
			image["hitBox"] = nil
		end
		
		hitBox.x, hitBox.y = default.contentWidth * 0.5, default.contentHeight * 0.5
	else
		image["hitBox"] = nil
	end
	
	if params.doesNotRequireGroup == nil then
		params.doesNotRequireGroup = false
	end

	if params.parentGroup then
		params.parentGroup:Add(image, image._id)
	else
		if params.doesNotRequireGroup == false then
			print("ERROR: Image ID " .. image._id .. " does not have a valid parentGroup! Fix this.")
			image:removeSelf()
		end
	end
	
	-- ==================================================
	-- Public methods
	-- ==================================================
	function image:setText( newText, params )
		local labelText = self.text
		if ( labelText ) then
			labelText:removeSelf()
			self.text = nil
		end

		local labelShadow = self.shadow
		if ( labelShadow ) then
			labelShadow:removeSelf()
			self.shadow = nil
		end

		local labelHighlight = self.highlight
		if ( labelHighlight ) then
			labelHighlight:removeSelf()
			self.highlight = nil
		end
		
		if ( params.size and type(params.size) == "number" ) then size=params.size else size=20 end
		if ( params.font ) then font=params.font:getFont() else font=native.systemFontBold end
        if ( params.textColor ) then 
            textColor = params.textColor
        else 
            textColor={ 255, 255, 255, 255 } 
        end
		
		size = size * sizeMultiply
		
		-- Optional vertical correction for fonts with unusual baselines (I'm looking at you, Zapfino)
		if ( params.offset and type(params.offset) == "number" ) then offset=params.offset else offset = 0 end
		
		if ( params.offsetX and type(params.offsetX) == "number" ) then offsetX=params.offsetX else offsetX = 0 end
		
		if ( params.emboss ) then
			-- Make the label text look "embossed" (also adjusts effect for textColor brightness)
			local textBrightness = ( textColor[1] + textColor[2] + textColor[3] ) / 3
			
			labelHighlight = display.newText( newText, 0, 0, font, size )
			if ( textBrightness > 127) then
				labelHighlight:setTextColor( 255, 255, 255, 20 )
			else
				labelHighlight:setTextColor( 255, 255, 255, 140 )
			end
			image:insert( labelHighlight, true )
			labelHighlight.x = labelHighlight.x + 1.5 + offsetX; labelHighlight.y = labelHighlight.y + 1.5 + offset
			self.highlight = labelHighlight

			labelShadow = display.newText( newText, 0, 0, font, size )
			if ( textBrightness > 127) then
				labelShadow:setTextColor( 0, 0, 0, 128 )
			else
				labelShadow:setTextColor( 0, 0, 0, 20 )
			end
			image:insert( labelShadow, true )
			labelShadow.x = labelShadow.x - 1 + offsetX; labelShadow.y = labelShadow.y - 1 + offset
			self.shadow = labelShadow
			
			labelHighlight.xScale = sizeDivide; labelHighlight.yScale = sizeDivide
			labelShadow.xScale = sizeDivide; labelShadow.yScale = sizeDivide
		end
		
		labelText = display.newText( newText, 0, 0, font, size )
        
        if params.isGradient then
            labelText:setTextColor( textColor )
        else
            labelText:setTextColor( textColor[1], textColor[2], textColor[3], textColor[4] )
        end
        
		image:insert( labelText, true )
		labelText.y = labelText.y + offset
		labelText.x = labelText.x + offsetX
		
		if self.contentWidth %2 == 1 then
			labelText.x = labelText.x + 1
		end
		
		if params.font.yOffset then
			labelText.y = labelText.y + params.font.yOffset
		end
		
		self.text = labelText
		
		labelText.xScale = sizeDivide; labelText.yScale = sizeDivide
	end

	--[[ Reset()
	-- Use:		reset the image to its normal state, showing 'default' image and hiding all others.
	-- Syntax:	myImage:Reset()
	--]]
	function image:Reset()
		self["default"].isVisible = true
		
		if self["hover"] then self["hover"].isVisible = false end
	end
    
    --[[ UpdateImage()
    -- Use:     change the image being used by a key name (such as 'default' or 'over').
    -- Syntax:  myImage:UpdateImage("images/myNewImage.png", "default")
    --]]
    function image:UpdateImage(pNewImagePath, pKeyName, pWidth, pHeight)
        if self[pKeyName] then
            local curImage = self[pKeyName]
            local width, height = curImage.contentWidth, curImage.contentHeight
			
			if pWidth ~= nil then width = pWidth end
			if pHeight ~= nil then height = pHeight end
            
            self[pKeyName]:removeSelf()
            
            local newImage = display.newImageRect ( pNewImagePath , width , height )
            
            self:insert(newImage, false)
            self[pKeyName] = newImage
        end
    end
	
	function image:InsertObject(pObject, pKeyName)
		self:insert(pObject, false)
		self[pKeyName] = pObject
	end
    
    return image
end
M.newImage = newImage

-- ==================================
-- TAB CLASS
-- ==================================

-- Helper function for newTabButton utility function
local function newTabButtonHandler( self, event )
	local result = true

	local default       = self["default"]
    local over          = self["hover"]
	local selected      = self["selected"]
    local selectedOver  = self["selectedOver"]
	
	-- General "onEvent" function overrides onPress and onRelease, if present
	local onEvent = self._onEvent

	local onPress = self._onPress
	local onRelease = self._onRelease
	local onErase = self._onErase
	local onMoved = self._onMoved
    
    local isActivated = self.activated
	
	-- Sounds
	local onPressSound = self.onPressSound
	local onReleaseSound = self.onReleaseSound

	local buttonEvent = {}
	if (self._id) then
		--> JS
		event.id = self._id
		event.uiContent = self.uiContent
		--> END JS
		buttonEvent.id = self._id
	end
	
	buttonEvent.isActive = self.isActive
	buttonEvent.target = self
	local phase = event.phase
    
	if self.isActive then
        if "began" == phase then
			if over or selectedOver then
				default.isVisible = false
                if selected then selected.isVisible = false end
                
                -- show either over or selectedOver, depending on isActivated state
                if over then over.isVisible = not isActivated end
                if selectedOver then selectedOver.isVisible = isActivated end
            end
 
			if onEvent then
				buttonEvent.phase = "press"
				buttonEvent.x = event.x - self.contentBounds.xMin
				buttonEvent.y = event.y - self.contentBounds.yMin
				result = onEvent( buttonEvent )
			elseif onPress then
				if onPressSound then
					myAudio.PlayAudio(onPressSound)
				end
				
				result = onPress( event )
			end
 
			-- Subsequent touch events will target button even if they are outside the contentBounds of button
			display.getCurrentStage():setFocus( self, event.id )
			self.isFocus = true
                
        elseif self.isFocus then
			local bounds = self.contentBounds
			local x,y = event.x,event.y
			local isWithinBounds = 
				bounds.xMin <= x and bounds.xMax >= x and bounds.yMin <= y and bounds.yMax >= y

			if "moved" == phase then    
                if over or selectedOver then
                    print("MOVED (" .. tostring(isWithinBounds) .. ")")
                    if isActivated then
                        selected.isVisible = not isWithinBounds
                        selectedOver.isVisible = isWithinBounds
                    else
                        default.isVisible = not isWithinBounds
                        over.isVisible = isWithinBounds
                    end
                end
                
                if onMoved then
                    result = onMoved( event )
                end
					
			elseif "ended" == phase or "cancelled" == phase then 
				if over or selectedOver then
                    default.isVisible = not isActivated
                    if selected then selected.isVisible = isActivated end
                    
                    if over then over.isVisible = false end
                    if selectedOver then selectedOver.isVisible = false end
                end
				
				if "ended" == phase then
					-- Only consider this a "click" if the user lifts their finger inside button's stageBounds
					if isWithinBounds then
						if onEvent then
							buttonEvent.phase = "release"
							buttonEvent.x = event.x - bounds.xMin
							buttonEvent.y = event.y - bounds.yMin
							result = onEvent( buttonEvent )
						elseif onRelease then
							local isAButtonActive = self.parent:IsAButtonActive()
							local oldButton
							local iAmTheOldButton = false
							
							if isAButtonActive == true then 
								oldButton = self.parent:GetActiveButton()
								
								if oldButton._id == self._id then
									iAmTheOldButton = true
								end
							end
							
							-- run any cleanup for old button content, if it exists and if it isn't the button we just clicked
							if onErase and isAButtonActive and not iAmTheOldButton then
								local oldBtnEvent = {}

								oldBtnEvent.phase = "release"
								oldBtnEvent.id = oldButton._id
								oldBtnEvent.uiContent = oldButton.uiContent
							
								onErase( oldBtnEvent )
							end
							
							-- after cleanup, draw the new content, if this isn't the button that is already active
							if not iAmTheOldButton then
								if onReleaseSound then
									myAudio.PlayAudio(onReleaseSound)
								end
								
								result = onRelease( event )
								self.parent:ActivateTabButton( self )
							end
						end
					end
				end
				
				-- Allow touch events to be sent normally to the objects they "hit"
				display.getCurrentStage():setFocus( self, nil )
				self.isFocus = false
			end
        end
        
	end
    
	return true
end
 
-- TabButton class
local function newTabButton( imageSrc, width, height, uiContent, params )
	-- object to be returned
	local button
	
	--[[ required params ===========
	imageSrc										--> path to the fileName of the image to be drawn
	width, height									--> size of the image to be displayed
	uiContent										--> the display group that any content drawn due to clicking a tab button will be inserted into
	
		optional params ===========
	x, y											--> left, top position of the image on-screen
	adjustX, adjustY								--> typically small values that we use to adjust x, y positions if screen is zoomed
	selectedSrc, selectedWidth, selectedHeight		--> change the image, width, and height for the 'selected' state of image
	scale, selectedScale							--> scale entire image group size (1.0 = 100%, 0.5 = 50%, 2.0 = 200%)
	selectedAlpha									--> change the alpha of the 'selected' state image
	referencePoint									--> change how the object is anchored (i.e., display.TopLeftReferencePoint)
	customHitBox									--> an image to use as a hitBox for the button, expanding its area to be touched (should be a transparent image!)
	hitBoxSize										--> table that contains width and height of the customHitBox (hitBoxSize = { 100, 80 }, is 100px width and 80px height)
	
	id												--> a string identifer that uniquely identifies this button
	parentGroup										--> a display group that the button will be inserted into
	
	onPress, onRelease, onMoved						--> listener functions that will trigger on press, release, moved
	onErase											--> listener functions that will trigger when the button is deactivated
	onPressSound, onReleaseSound					--> audio sounds that will accompany onPress and onRelease functions
	-- ============================ --]] 
        
	local sizeDivide = 1
	local sizeMultiply = 1
 
	if display.contentScaleX < 1.0 or display.contentScaleY < 1.0 then
		sizeMultiply = 2
		sizeDivide = 0.5                
	end
        
	button = display.newGroup()
	if isDisplayObject(imageSrc) then
		default = imageSrc
	else
		default = display.newImageRect ( imageSrc , width , height )
	end
	button:insert( default, false )
	button["default"] = default
    
    if params.overSrc then
        if isDisplayObject(params.overSrc) then
			over = params.selectedSrc
		else
			over = display.newImageRect ( params.overSrc , width , height )
		end
        
        over.isVisible = false
		button:insert( over, false )    
		button["hover"] = over
    end
        
	if params.selectedSrc then
		if isDisplayObject(params.selectedSrc) then
			selected = params.selectedSrc
		else
			selected = display.newImageRect ( params.selectedSrc , params.selectedWidth , params.selectedHeight )
		end
		
		if params.selectedAlpha then
			selected.alpha = params.selectedAlpha
		end
		
		if params.selectedScale then
			selected:scale(params.selectedScale, params.selectedScale)
		end
		
		selected.isVisible = false
		button:insert( selected, false )    
		button["selected"] = selected
	end
    
    if params.selectedOverSrc then
		if isDisplayObject(params.selectedOverSrc) then
			selectedOver = params.selectedSrc
		else
			selectedOver = display.newImageRect ( params.selectedOverSrc , params.selectedWidth , params.selectedHeight )
		end
		
		if params.selectedAlpha then
			selected.alpha = params.selectedAlpha
		end
		
		if params.selectedScale then
			selected:scale(params.selectedScale, params.selectedScale)
		end
		
		selectedOver.isVisible = false
		button:insert( selectedOver, false )    
		button["selectedOver"] = selectedOver
	end
	
	button.uiContent = uiContent
	if button.uiContent == nil then
		print("ERROR: Tab Buttons need a uiContent object so we can draw this button's active content to a display group!")
		return
	end
	
	if params.referencePoint then
		button:setReferencePoint( params.referencePoint )
	end
	
	if params.scale then
		button:scale(params.scale, params.scale)
	end

	if ( params.onPress and ( type(params.onPress) == "function" ) ) then
		button._onPress = params.onPress
	end
	
	if ( params.onRelease and ( type(params.onRelease) == "function" ) ) then
		button._onRelease = params.onRelease
	end
	
	if ( params.onMoved and ( type(params.onMoved) == "function" ) ) then
		button._onMoved = params.onMoved
	end
	
	if ( params.onErase and ( type(params.onErase) == "function" ) ) then
		button._onErase = params.onErase
	end
	
	if (params.onEvent and ( type(params.onEvent) == "function" ) ) then
		button._onEvent = params.onEvent
	end
	
	if params.onPressSound then
		button.onPressSound = params.onPressSound
	end
		
	if params.onReleaseSound then
		button.onReleaseSound = params.onReleaseSound
	end
        
	-- set button to active (meaning, can be pushed)
	button.isActive = true
	
	-- tab buttons are deactivated by default
	button.activated = false
	
	-- Set button as a table listener by setting a table method and adding the button as its own table listener for "touch" events
	button.touch = newTabButtonHandler
	button:addEventListener( "touch", button )
	
	if params.x then
		if params.adjustX then
			button.x = params.x + params.adjustX;
		else
			button.x = params.x
		end
	end
	
	if params.y then
		if params.adjustY then
			button.y = params.y + params.adjustY;
		else
			button.y = params.y
		end
	end
	
	if params.id then
		button._id = params.id
	end
	
	if params.customHitBox then
		if params.hitBoxSize then
			if isDisplayObject(params.customHitBox) then
				hitBox = params.customHitBox
			else
				hitBox = display.newImageRect( params.customHitBox, params.hitBoxSize[1], params.hitBoxSize[2] )
			end
			
			button:insert( hitBox, false )
			button["hitBox"] = hitBox
			hitBox:toBack()
		else
			print("WARNING: Button with ID of " .. params.id .. " has a customHitBox param, but no hitBoxSize! No hitBox added!")
			button["hitBox"] = nil
		end
		
		hitBox.x, hitBox.y = default.contentWidth * 0.5, default.contentHeight * 0.5
	else
		button["hitBox"] = nil
	end

	-- ==================================================
	-- Public methods
	-- ==================================================
	
	--[[ Activate()
	-- Use: 	set the button to its 'selected' image source -- showing that it is the active button
	-- Syntax:  tabButton:Activate( bool );
	--]]
	function button:Activate()
		self.activated = true
        
		self["default"].isVisible = false
		if self["selected"]     then self["selected"].isVisible = true end
        
        if self["hover"]        then self["hover"].isVisible = false end
        if self["selectedOver"] then self["selectedOver"].isVisible = false end
	end
	
	--[[ Deactivate()
	-- Use: 	set the button back to its default image source
	-- Syntax:  tabButton:Deactivate( bool );
	--]]
	function button:Deactivate()
		self.activated = false
        
		self["default"].isVisible = true
		if self["selected"]     then self["selected"].isVisible = false end
        
        if self["hover"]        then self["hover"].isVisible = false end
        if self["selectedOver"] then self["selectedOver"].isVisible = false end
	end
	
	--[[ Reset()
	-- Use:		reset the button to its normal state, showing 'default' image and hiding all others.
	-- Syntax:	myButton:Reset()
	--]]
	function button:Reset()
		self["default"].isVisible = not self.activated
		
		if self["selected"] then self["selected"].isVisible = self.activated end
	end

	function button:setText( newText, params )
		local labelText = self.text
		if ( labelText ) then
			labelText:removeSelf()
			self.text = nil
		end

		local labelShadow = self.shadow
		if ( labelShadow ) then
			labelShadow:removeSelf()
			self.shadow = nil
		end

		local labelHighlight = self.highlight
		if ( labelHighlight ) then
			labelHighlight:removeSelf()
			self.highlight = nil
		end
		
		if ( params.size and type(params.size) == "number" ) then size=params.size else size=20 end
		if ( params.font ) then font=params.font:getFont() else font=native.systemFontBold end
		if ( params.textColor ) then textColor=params.textColor else textColor={ 255, 255, 255, 255 } end
		
		size = size * sizeMultiply
		
		-- Optional vertical correction for fonts with unusual baselines (I'm looking at you, Zapfino)
		if ( params.offset and type(params.offset) == "number" ) then offset=params.offset else offset = 0 end
		
		if ( params.emboss ) then
			-- Make the label text look "embossed" (also adjusts effect for textColor brightness)
			local textBrightness = ( textColor[1] + textColor[2] + textColor[3] ) / 3
			
			labelHighlight = display.newText( newText, 0, 0, font, size )
			if ( textBrightness > 127) then
				labelHighlight:setTextColor( 255, 255, 255, 20 )
			else
				labelHighlight:setTextColor( 255, 255, 255, 140 )
			end
			button:insert( labelHighlight, true )
			labelHighlight.x = labelHighlight.x + 1.5; labelHighlight.y = labelHighlight.y + 1.5 + offset
			self.highlight = labelHighlight

			labelShadow = display.newText( newText, 0, 0, font, size )
			if ( textBrightness > 127) then
				labelShadow:setTextColor( 0, 0, 0, 128 )
			else
				labelShadow:setTextColor( 0, 0, 0, 20 )
			end
			button:insert( labelShadow, true )
			labelShadow.x = labelShadow.x - 1; labelShadow.y = labelShadow.y - 1 + offset
			self.shadow = labelShadow
			
			labelHighlight.xScale = sizeDivide; labelHighlight.yScale = sizeDivide
			labelShadow.xScale = sizeDivide; labelShadow.yScale = sizeDivide
		end
		
		labelText = display.newText( newText, 0, 0, font, size )
		labelText:setTextColor( textColor[1], textColor[2], textColor[3], textColor[4] )
		button:insert( labelText, true )
		labelText.y = labelText.y + offset
		self.text = labelText
		
		if params.font.yOffset then
			labelText.y = labelText.y + params.font.yOffset
		end
		
		labelText.xScale = sizeDivide; labelText.yScale = sizeDivide
	end
	
	return button
end
M.newTabButton = newTabButton

-- Tab class
local function newTab( uiContent, buttonWidth, buttonHeight, layout, buttons, params )
	-- object to be returned
	local tab
	
	--[[ required params ===========
	uiContent							--> a display group that any content drawn due to clicking a tab button will be inserted into
	buttonWidth, buttonHeight			--> dimensions that all buttons under this tab group will use
	layout								--> a value from layoutType table that describes how buttons will be organized ("horizontal", "vertical", etc.)
	buttons								--> a table containing the tab buttons that will be drawn: { {button1 params}, {button2 params}, etc... }
	
		required buttons params ===
	buttonImage							--> image to use for button in its default state
	selectedImage						--> image to use for button when it is selected
	id									--> Identifier for the tab button
	onRelease							--> event to trigger when finish touching a button
	onErase								--> event to trigger when a new tab has been selected, and previously active tab button needs to be cleaned up
	
		optional buttons params ===
	selectedWidth, selectedHeight		--> width, height to use for button when in its selected state.
	scale								--> scales the button by a percentage of its original size (100% = normal, 50% = half-size)
	referencePoint						--> change the reference point from which the buttons are drawn
	onReleaseSound						--> a sound that will play when the button is released
	customHitBox						--> an image to use as a hitBox for the button, expanding its area to be touched (should be a transparent image!)
	hitBoxSize							--> table that contains width and height of the customHitBox (hitBoxSize = { 100, 80 }, is 100px width and 80px height)
	
		optional params ===========
	id									--> Identifier for the tab
	x, y								--> Starting x and y positions for first button in tab list
	spacing								--> Amount of spacing (if any) to place between buttons in tab list
	scale								--> Scale all buttons in this tab list by an amount (1.0 = normal, 0.5 = 50%, 2.0 = 200%)
	parentGroup							--> a display group that the button will be inserted into
	doesNotRequireGroup					--> if true, do not throw an error if parentGroup or an id does not exist (defaults to false)
	-- ============================ --]] 
	
	if buttonWidth <= 0 or buttonHeight <= 0 then 
		print("newTab needs a positive buttonWidth and ButtonHeight")
		return
	end
	
	tab = newGroup()
	
	tab.layout = layout
	
	tab.activeButton = nil
	
	if isDisplayObject(uiContent) then
		tab.uiContent = uiContent
	else
		-- create a new UI group
		tab.uiContent = newGroup()
	end
	
	-- store 1 if tab layout matches the given type, otherwise 0
	local isHoriz = (tab.layout == layoutType["horizontal"]) and 1 or 0
	local isVert = (tab.layout == layoutType["vertical"]) and 1 or 0
	
	if params.id then
		tab._id = params.id
	end
	
	if params.scale then
		tab.scale = params.scale
	else
		tab.scale = 1
	end
	
	if params.spacing then
		tab.spacing = params.spacing
	end
	
	if buttons then
		for i = 1, #buttons do
			local myScale = buttons[i].scale or 1
			
			local thisButton = 	newTabButton( buttons[i].buttonImage, buttonWidth, buttonHeight, tab.uiContent, {
                                    overSrc = buttons[i].buttonOverImage or nil,
                                    selectedSrc = buttons[i].selectedImage or nil,
                                    selectedOverSrc = buttons[i].selectedOverImage or nil,
									selectedWidth = buttons[i].selectedWidth or buttonWidth,
									selectedHeight = buttons[i].selectedHeight or buttonHeight,
									x = tab.x + ( (i-1) * ((buttonWidth * myScale) + tab.spacing) * isHoriz ),
									y = tab.y + ( (i-1) * ((buttonHeight * myScale) + tab.spacing) * isVert ),
									referencePoint = buttons[i].referencePoint or nil,
									id = buttons[i].id,
									scale = myScale,
									customHitBox = buttons[i].customHitBox or nil,
									hitBoxSize = buttons[i].hitBoxSize or nil,
									onRelease = buttons[i].onRelease,
									onMoved = buttons[i].onMoved or nil,
									onErase = buttons[i].onErase,
									onReleaseSound = buttons[i].onReleaseSound or nil
								})
            
			-- tab can use Add() function because it is also a ui.newGroup()
			tab:Add( thisButton, thisButton._id )
		end
		
		tab.buttons = buttons
	end
	
	if params.referencePoint then
		tab:setReferencePoint(params.referencePoint)
	end
	
	if params.x then
		tab.x = params.x
	else
		tab.x = 0
	end
	
	if params.y then
		tab.y = params.y
	else
		tab.y = 0
	end
	
	if params.doesNotRequireGroup == nil then
		params.doesNotRequireGroup = false
	end
	
	if params.parentGroup then
		params.parentGroup:Add(tab, tab._id)
	else
		if params.doesNotRequireGroup == false then
			print("ERROR: Tab ID " .. tab._id .. " does not have a valid parentGroup! Fix this.")
			tab:removeSelf()
		end
	end	
	
	-- ==================================================
	-- Public methods
	-- ==================================================
	--[[ ActivateTabButton( pButton )
	-- Use: 	"Activate" one of the tab buttons, which changes their image and displays content based on selected button.
	-- 			Should be called from within the tabButtonHandler class. See syntax below for how to access tab from there.
	-- Syntax:  self.parent:ActivateTabButton( self )
	--			This is assuming within the newTabButtonHandler class. 
	--]]
	function tab:ActivateTabButton(pButton)
		-- deactivate the current activeButton, if there is one
		if self.activeButton ~= nil then
			self.activeButton:Deactivate()
		end
	
		-- 'buttons' property contains how many buttons, while 'self' property contains all the button objects within the tab group
		for i = 1, #self.buttons do
			if pButton._id == self[i]._id then
				self.activeButton = pButton
				pButton:Activate()
			end
		end
	end

	--[[ IsAButtonActive()
	-- Use: Allows us to ask the tab class if it currently as an "active" button. (If no buttons have been clicked, it will not)
	--]]
	function tab:IsAButtonActive()
		return (self.activeButton ~= nil)
	end
	
	--[[ GetActiveButton()
	-- Use: Returns the current "active" button.
	-- 		Should either call after confirming IsAButtonActive() returns true, or check the result to ensure it is not nil!
	--]]
	function tab:GetActiveButton()
		return self.activeButton
	end

	-- ==================================================
	-- Public "setup" methods
	-- Should be called only directly after the tab has been setup
	-- ==================================================
	--[[ SetButtonActive(pButtonId)
	-- Use: 	Pass in an ID that matches one of the tab buttons. That button will become active and show its content.
	-- Syntax:	myTab:SetButtonActive("InviteButton")
	--]]
	function tab:SetButtonActive(pButtonId)
		-- 'buttons' property contains how many buttons, while 'self' property contains all the button objects within the tab group
		for i = 1, #self.buttons do
			if pButtonId == self[i]._id then
				local buttonEvent = {}
				buttonEvent.phase = "release"
				buttonEvent.id = self[i]._id
				
				self[i]._onRelease( buttonEvent )
				self:ActivateTabButton(self[i])
				break
			end
		end
	end
	
	function tab:ScaleAndRepositionButtons(pScale)
		local isHoriz = (tab.layout == layoutType["horizontal"]) and 1 or 0
		local isVert = (tab.layout == layoutType["vertical"]) and 1 or 0
		
		for i = 1, #self.buttons do
			local oldWidth = self[i].contentWidth
			self[i]:scale(pScale, pScale)
			self[i].x = -(oldWidth - self[i].contentWidth)/2
			self[i].y = (i-1) * ((buttonHeight * self[i].yScale) + tab.spacing) * isVert
		end
	end
	
	return tab
end
M.newTab = newTab

-- ==================================
-- SCROLL VIEW CLASS
-- ==================================

-- Scroll view class
local function newScrollView( scrollWidth, scrollHeight, params )
	-- object to be returned
	local scrollView
	
	--[[ required params ==========
	scrollWidth, scrollHeight			--> Total size of the total scrollable area. CANNOT be changed after creation.
	
		scrollView widget params ===========
	left, top							--> Specify top left the scrollView will be placed at
	width, height						--> Screen width and height of the scrollView in pixels
	hideBackground						--> Boolean that determines if background is visible
	maskFile							--> Apply a bitmap mask to the scrollView (see Corona docs for this)
	listener							--> Callback function to listen to all scrollView events
	
		optional params ===========
	id									--> Identifier for the scroller
	parentGroup							--> A display group that the button will be inserted into
	-- ============================ --]]
	
	scrollView = widget.newScrollView{
		left = params.left or 0,
		top = params.top or 0,
		width = params.width or display.contentWidth,
		height = params.height or display.contentHeight,
		scrollWidth = scrollWidth,
		scrollHeight = scrollHeight,
		maskFile = params.maskFile or nil,
		hideBackground = hideBackground or true,
		listener = params.listener or nil
	}

    scrollView.myWidth = params.width or display.contentWidth
    scrollView.myHeight = params.height or display.contentHeight
	
	if params.id then
		scrollView._id = params.id
	end
	
	if params.doesNotRequireGroup == nil then
		params.doesNotRequireGroup = false
	end
	
	if params.parentGroup then
		params.parentGroup:Add(scrollView, scrollView._id)
	else
		print("WARNING: ScrollView ID " .. scrollView._id .. " does not have a \n" ..
			  "         valid parentGroup! This is technically okay, since scrollView\n" ..
			  "         also functions as a display group, but not recommended!")
	end	
	
	return scrollView
end
M.newScrollView = newScrollView

-- ==================================
-- AUTOWRAP COMBO CLASS (Auto wrap text wrapped around images)
-- ==================================

function splitString(inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        t={} ; i=1
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                t[i] = str
                i = i + 1
        end
        return t
end

local function newAutoWrapCombo( text,font,size,color,xCap,componentKey,components,params)
	--[[ required params ===========
	x
	y
	text							--> string of text that will be displayed
	font							--> font type to use (defaults to native system bold)
	size							--> font size (defaults to 20)
	color							--> a table that tells font color: {r, g, b, a} (defaults to black)
	xCap							--> xPos of the right edge 
	componentKey					--> String to see if we should replace the current string with a image for ex: "#"
	components						--> Table of components ex:
											{
												id = "W"
												,
												images = 
												{
													{
														image = "images/gameplay/wordValue_green.png",
														width = 36,
														height = 40,
														addTextOnTop = 
														{
															text = "1",
															font = font.helvetica,
															size = 25
														},
														params = 
														{
															x = 0,
															y = 0,
															id = "1",
															parentGroup = scrollGroup,
														}
													}
												}
											}
	
	Note: using the above examples, "#W1" will be replaced with a image
	
		optional params ===========
	x, y							--> starting X, Y position
	referencePoint					--> change the anchor reference point of the display group (defaults to TopLeft)
	align 							--> string that can be set to "right". Since Left is defaulted, "left" is ignored
	linePadding						--> adds padding between the lines if this is 2 then it will be double spaced (default: 0.3)
	parentGroup						--> a display group that the button will be inserted into
	id								--> id of this object
	-- ============================ --]] 
	
	local result = display.newGroup()
	
	local font = font:getFont()
	
	tempVar = display.newText( " ", 0, 0, font, size )
	spaceWidth = tempVar.contentWidth
	lineHeight = tempVar.contentHeight
	tempVar:removeSelf()
	textAr = splitString(text,"%s")

	local startX, startY = 0, 0

	if xCap < startX then
		print("xCap is less than startX! Fix this!")
		return nil
	end
	
	curX = startX
	curY = startY
	
	nextY = -1
	
	nextLinePadding = lineHeight *.3
	
	if params.linePadding ~= nil then
		nextLinePadding = params.linePadding * lineHeight
	end
	
	if params.id then
		result._id = params.id
	end
	
	curLine = {}
	droppedY = 0
	
	--print()
	--print()
	--print("Printing textAr")
	--for i = 1, table.getn(textAr),1 do
	--	print("textAr[i]: " .. textAr[i])
	--end
	--print()
	--print()
	
	for i = 1, table.getn(textAr),1 do
		str = textAr[i]
		
		if string.find(str,componentKey) ~= nil  then
			--tempVar = tonumber(string.sub(str, 2,2))
			--print("tempVar: " .. tempVar)
			
			componentTable = {}
			
			tempVar = string.sub(str, 2,2)
			
			for j = 1, table.getn(components),1 do
				if components[j] ~= nil and components[j].id ~= nil and tempVar == components[j].id and components[j].images ~= nil then
					componentTable = components[j].images
					break
				end
			end
			
			tempVar = tonumber(string.sub(str, 3))
			if componentTable[tempVar] ~= nil then
				--print()
				--print()
				--print("Adding A Image: " .. str)
				--print("1: " .. "droppedY: " .. droppedY.. "    curX: " .. curX .."    curY: " .. curY)
				--print("adding Comp: " .. componentTable[tempVar].image)
				tParam = componentTable[tempVar].params
				
				if tParam.x == nil then
					tParam.x = curX
				else
					tParam.x = tParam.x + curX
				end
				if tParam.y == nil then
					tParam.y = curY
				else
					tParam.y = tParam.y + curY
				end
				
				tParam.referencePoint = display.CenterReferencePoint
				tParam.doesNotRequireGroup = true
				
				img = newImage( componentTable[tempVar].image, componentTable[tempVar].width, componentTable[tempVar].height, tParam)
				
				img.x = tParam.x + (img.contentWidth/2)
				img.y = tParam.y
				
				curX = curX + img.contentWidth
				
				--print("2: " .. "droppedY: " .. droppedY.. "    curX: " .. curX .."    curY: " .. curY)
				--print("         img.x: " .. img.x .. "    img.y: " .. img.y)
				
				--[[
				if droppedY < (img.contentHeight/2) then
					for i = 1, table.getn(curLine),1 do
						curLine[i].y = curLine[i].y + (img.contentHeight/2) - droppedY
					end
					
					curY = curY + (img.contentHeight/2) - droppedY
					img.y = tParam.y
					
					droppedY = (img.contentHeight/2)
				end
				--]]
				
				--print("3: " .. "droppedY: " .. droppedY.. "    curX: " .. curX .."    curY: " .. curY)
				--print("         img.x: " .. img.x .. "    img.y: " .. img.y)
				
				
				if curX > xCap then
					if params.align == "right" then
						alignWrapRight(curLine,xCap)
                    elseif params.align == "center" then
                        alignWrapCenter(curLine,params.x,xCap)
					end
					curLine = {}
					img.x = startX + (img.contentWidth/2)
					if nextY ~= -1 then
						curY = nextY + nextLinePadding + (img.contentHeight/2)
						nextY = -1
					else
						curY = curY + (img.contentHeight/2) + nextLinePadding + (lineHeight/2)
					end
					img.y = tParam.y
                    
					curX = startX + img.contentWidth
				end
				
				
				
				table.insert(curLine, img)
				
				-- JS: This was causing lines to drop down a lot more than needed when an image is inserted into that line
--				if nextY < curY + (img.contentHeight/2) + nextLinePadding then
--					nextY = curY + (img.contentHeight/2) + nextLinePadding
--				end
				
				
				--print("4: " .. "droppedY: " .. droppedY.. "    curX: " .. curX .."    curY: " .. curY)
				--print("         img.x: " .. img.x .. "    img.y: " .. img.y)
				
				--print(componentTable[tempVar].addTextOnTop)
				if componentTable[tempVar].addTextOnTop ~= nil then
					centerText = display.newText(componentTable[tempVar].addTextOnTop.text, 0, 0, componentTable[tempVar].addTextOnTop.font:getFont(),componentTable[tempVar].addTextOnTop.size)
					centerText.x = (componentTable[tempVar].addTextOnTop.x) and componentTable[tempVar].addTextOnTop or 0
					centerText.y = (componentTable[tempVar].addTextOnTop.y) and componentTable[tempVar].addTextOnTop.y or 0
					
					if componentTable[tempVar].addTextOnTop.color == nil then
						centerText:setTextColor(255, 0, 0,255)
					else
						centerText:setTextColor(componentTable[tempVar].addTextOnTop.color[1], componentTable[tempVar].addTextOnTop.color[2], componentTable[tempVar].addTextOnTop.color[3], componentTable[tempVar].addTextOnTop.color[4])
					end
					
					img:insert(centerText)
					--table.insert(curLine, centerText)
					--[[
					img:setText(componentTable[tempVar].addTextOnTop.text,
					{
						font = componentTable[tempVar].addTextOnTop.font,
						size = componentTable[tempVar].addTextOnTop.size--,
						--textColor = componentTable[tempVar].addTextOnTop.color
					})
					--]]
				end
				
				
				--print("5: " .. "droppedY: " .. droppedY.. "    curX: " .. curX .."    curY: " .. curY)
				--print("         img.x: " .. img.x .. "    img.y: " .. img.y)
				
				result:insert(img, false)
				
				--print("6: " .. "droppedY: " .. droppedY.. "    curX: " .. curX .."    curY: " .. curY)
				--print("         img.x: " .. img.x .. "    img.y: " .. img.y)
			end
		else
			--print()
			--print()
			--print("Adding A Text: " .. str)
			tempVar = display.newText(str, 0, 0, font, size)
			
			tempVar.x = curX + (tempVar.contentWidth/2)
			tempVar.y = curY
			--print("1: tempVar.x: " .. tempVar.x .. "    tempVar.y: " .. tempVar.y .. "    tempVar.width: " .. tempVar.contentWidth .. "    tempVar.height: " .. tempVar.contentHeight)
			curX = curX + (tempVar.contentWidth - 2)	-- "-2" so that we don't pad quite as much space between objects
			
			if curX > xCap then
				if params.align == "right" then
					alignWrapRight(curLine,xCap)
                elseif params.align == "center" then
                    alignWrapCenter(curLine,params.x,xCap)
				end
				
				droppedY = 0
				curLine = {}
				tempVar.x = startX + (tempVar.contentWidth/2)
				curX = startX + tempVar.contentWidth
				
				if nextY ~= -1 then
					curY = nextY
					nextY = -1
				else
					curY = curY + lineHeight + nextLinePadding
				end
				tempVar.y = curY
			end
			
			if color == nil then
				tempVar:setTextColor(0, 0, 0,255)
			else
				tempVar:setTextColor(color[1], color[2], color[3],color[4])
			end
			
			table.insert(curLine, tempVar)
			
			result:insert(tempVar, false)
			--print("2: tempVar.x: " .. tempVar.x .. "    tempVar.y: " .. tempVar.y .. "    tempVar.width: " .. tempVar.contentWidth .. "    tempVar.height: " .. tempVar.contentHeight)
		end

		curX = curX + spaceWidth
	end
	
	
	
	if params.referencePoint then
		result:setReferencePoint(params.referencePoint)
	end
	
	if params.x then
		result.x = params.x
	end
	
	if params.y then
		result.y = params.y
	end
	
	if params.align == "right" then
		alignWrapRight(curLine,xCap)
    elseif params.align == "center" then
        alignWrapCenter(curLine,params.x,xCap)
	end
	
	if params.parentGroup ~= nil then
		if result ~= nil and result._id ~= nil then
			params.parentGroup:Add(result,result._id)
		end
	end
	
	return result
end
M.newAutoWrapCombo = newAutoWrapCombo

function alignWrapRight(curLine,rightEdge)
	--print("rightEdge: " .. rightEdge)
	slideX = -1
	for i = #curLine,1,-1 do
		if slideX == -1 then
			slideX = rightEdge - curLine[i].x - (curLine[i].contentWidth/2)
			--print(" slideX: " .. slideX)
		end
		curLine[i].x = curLine[i].x + slideX
		--print("curLine[i].x: " .. curLine[i].x)
	end
end

function alignWrapCenter(curLine, startX, rightEdge)
	-- TODO: Fuck this function... If we're wrapping only a single line, we
	-- need to have this function NOT run. As in, do NOT put "align = center" in the params.
	-- However, if there is more than one line, this function MUST run, meaning we need
	-- to put "align = center". This is currently an issue if we're unsure if a message will
	-- wrap or not. 
	
	
	local leftmostX = curLine[1].x - curLine[1].contentWidth/2
	local rightmostX = curLine[#curLine].x + curLine[#curLine].contentWidth/2
	
	local totalContentWidth = rightmostX - leftmostX
	local maxWidth = rightEdge - startX
	local shiftAmount = (maxWidth - totalContentWidth) / 2
	
	for i=#curLine, 1, -1 do
		curLine[i].x = curLine[i].x + shiftAmount
	end
	
end

-- ==================================
-- MASK CLASS
-- ==================================

local function newMask( imageSrc, params )
	-- returned object
	local mask
	
	--[[ optional params ===========
	imageDirectory						--> specifies which directory to find the image in
	
	id									--> a string identifer that uniquely identifies this button
	parentGroup							--> a display group that the button will be inserted into
	-- ============================ --]]
	
	if params.imageDictionary then
		mask = graphics.newMask(imageSrc, imageDirectory)
	else
		mask = graphics.newMask(imageSrc)
	end
	
	if params.parentGroup then
		params.parentGroup:Link(mask, params.id)
	end
	
	return mask
end
M.newMask = newMask

return M