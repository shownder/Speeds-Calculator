local composer = require( "composer" )
local scene = composer.newScene()
local widget = require ( "widget" )
local store = require ("store")
local loadsave = require ("loadsave")
local myData = require("myData")

---------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE
-- unless "composer.removeScene()" is called.
---------------------------------------------------------------------------------

-- local forward references should go here

local back, example, descBack, desc, descTitle, descScroll, buttBack, buyBut, backBut
local goBack2
local backEdgeX, backEdgeY
local showing

---------------------------------------------------------------------------------

local function onKeyEvent( event )

  local phase = event.phase
  local keyName = event.keyName
   
  if ( "back" == keyName and phase == "up" ) then
    timer.performWithDelay(100,goBack2,1)
  end
  return true
end

goBack2 = function()
	
	omposer.gotoScene( "menu", { effect="fromBottom", time=800})
  
end

-- "scene:create()"
function scene:create( event )

  local sceneGroup = self.view
   
  Runtime:addEventListener( "key", onKeyEvent )
   
  back = display.newImageRect( sceneGroup, "backgrounds/background.png", 570, 360 )
  back.x = display.contentCenterX
	back.y = display.contentCenterY
  backEdgeX = back.contentBounds.xMin
	backEdgeY = back.contentBounds.yMin
  
  print(myData.showing)
  
  if myData.showing == "trig" then
    example = display.newImageRect(sceneGroup, "backgrounds/trigDesc.png", 570, 360)
  elseif myData.showing == "speed" then
    example = display.newImageRect(sceneGroup, "backgrounds/speedDesc.png", 570, 360)
  elseif myData.showing == "sine" then
    example = display.newImageRect(sceneGroup, "backgrounds/sineDesc.png", 570, 360)
  elseif myData.showing == "bolt" then
    example = display.newImageRect(sceneGroup, "backgrounds/boltDesc.png", 570, 360)
  end
  
  example.anchorX = 0
  example.anchorY = 0
  example.x, example.y = 0, 0
  
  descBack = display.newRect(sceneGroup, 0, 0, display.contentWidth / 2 - 50, display.contentHeight)
  descBack.anchorX, descBack.anchorY = 1, 0
  descBack.x, descBack.y = display.contentWidth, 0
  descBack:setFillColor(1)
  --descBack.alpha = 0
  
  descScroll = widget.newScrollView(
    {
      x = descBack.x,
      y = descBack.y + 50,
      width = display.contentWidth / 2 - 50,
      height = display.contentHeight - 50,
      scrollWidth = 0,
      id = "answerScroll",
      hideBackground = true,
      horizontalScrollDisabled = true,
      verticalScrollDisabled = false,
    }
    )
  sceneGroup:insert(descScroll)
  descScroll.anchorX, descScroll.anchorY = 1, 0
  descScroll.x = descBack.x
  descScroll.y = descBack.y + 50
  --descScroll.alpha = 0
  
  local options = {parent = sceneGroup, text="This is a test of the thing that I made ", x=0, y=0, width=descBack.contentWidth - 10, align="left", font="BerlinSansFB-Reg", fontSize=18}
  local options2 = {parent = sceneGroup, text="This is a Title", x=0, y=0, width=descBack.contentWidth - 10, align="left", font="BerlinSansFB-Reg", fontSize=20}
  
  display.setDefault( "anchorX", 0 )
  display.setDefault( "anchorY", 0 )
  
  desc = display.newText(options)
  desc:setFillColor(0.15, 0.4, 0.729)
  descScroll:insert(desc)
  desc.x = 5
  desc.y = 0
  
  descTitle = display.newText(options2)
  descTitle.x = display.contentWidth - descBack.contentWidth + 5
  descTitle.y = 5
  descTitle:setFillColor(0.15, 0.4, 0.729)
  display.setDefault( "anchorX", 0.5 )
  display.setDefault( "anchorY", 0.5 )
  
  if myData.showing == "trig" then
    desc.text = "Solve Right Angle Triangle and Oblique Triangle problems easily and quickly with just a few taps. Quickly switch between inch and metric, and convert between degrees-decimal and degrees, minutes and seconds."
    descTitle.text = "Trigonometry Functions"
  elseif myData.showing == "speed" then
    desc.text = "4 Functions Included! Calculate cutting speeds & feeds for drills, milling cutters, and lathe workpieces. Calculate between RPM and feet or meters per minute, and between feed per rev and feed per minute.\n \nAlso includes Counter Sink Depth & Drill Point calculator function, Drill Chart list, and Materials List with over 200 materials that can easily be used in both Speeds & Feeds and C'Sink & Drill Point Functions."
    descTitle.text = "Speeds & Feeds"
  elseif myData.showing == "sine" then
    desc.text = "Quickly and accurately calculate precision block stack or angle for use with sine bars or sine plates.\nQuickly switch between inch and metric, and convert between degrees-decimal and degrees, minutes and seconds."
    descTitle.text = "Sine Bar Function"
  elseif myData.showing == "bolt" then    
    desc.text = "Quickly calculate X and Y coordinates for points equally spaced around a circle.\n* Make center of circle any coordinate you require\n* Place first hole at any angle\n* Automatically add list of coordinates into email\n* Quickly switch between inch and metric, and convert between degrees-decimal and degrees, minutes and seconds."
    descTitle.text = "Bolt Circle Calculator"
  end
   

   -- Initialize the scene here.
   -- Example: add display objects to "sceneGroup", add touch listeners, etc.
end

-- "scene:show()"
function scene:show( event )

   local sceneGroup = self.view
   local phase = event.phase

   if ( phase == "will" ) then
      -- Called when the scene is still off screen (but is about to come on screen).
   elseif ( phase == "did" ) then
     composer.removeScene( "menu", true)
      -- Called when the scene is now on screen.
      -- Insert code here to make the scene come alive.
      -- Example: start timers, begin animation, play audio, etc.
   end
end

-- "scene:hide()"
function scene:hide( event )

   local sceneGroup = self.view
   local phase = event.phase

   if ( phase == "will" ) then
     Runtime:removeEventListener( "key", onKeyEvent )
      -- Called when the scene is on screen (but is about to go off screen).
      -- Insert code here to "pause" the scene.
      -- Example: stop timers, stop animation, stop audio, etc.
   elseif ( phase == "did" ) then
      -- Called immediately after scene goes off screen.
   end
end

-- "scene:destroy()"
function scene:destroy( event )

   local sceneGroup = self.view

   -- Called prior to the removal of scene's view ("sceneGroup").
   -- Insert code here to clean up the scene.
   -- Example: remove display objects, save state, etc.
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------------

return scene