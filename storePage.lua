local composer = require( "composer" )
local scene = composer.newScene()
local widget = require ( "widget" )
local store = require ("store")
local loadsave = require ("loadsave")
local myData = require("myData")
local device = require("device")

---------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE
-- unless "composer.removeScene()" is called.
---------------------------------------------------------------------------------

-- local forward references should go here

local back, example, descBack, desc, descTitle, descScroll, buttBack, buyBut, backBut, butGroup, descGroup, price
local goBack2, butMove, goBack
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

local function onComplete( event )
    if "clicked" == event.action then
        local i = event.index
        if 1 == i then
          transition.to( butGroup, {time = 500, y = display.contentHeight + 5})
          transition.to( descGroup, {time = 500, x = display.contentWidth + 5})
          timer.performWithDelay(400, goBack)
        end
    end
end

local function transactionCallback( event )

   print("In transactionCallback", event.transaction.state)
   local transaction = event.transaction
   local tstate = event.transaction.state
   local product = event.transaction.productIdentifier
   local showing = myData.showing

   if tstate == "purchased" then
     if not device.isApple then
      storeSettings.buyCount = 1
     end
      print("Transaction succuessful!")
      if "com.speedfeed.iap.sine" == product then
        storeSettings.sinePaid = true
      elseif "com.speedfeed.iap.trig" == product then
        storeSettings.trigPaid = true
      elseif "com.speedfeed.iap.bolt" == product then
        storeSettings.boltPaid = true
--      elseif "com.speedfeed.iap.speed" == product then
--        storeSettings.speedPaid = true
      end
      loadsave.saveTable(storeSettings, "store.json")
      native.showAlert("Success", "Function is now unlocked!", {"Okay"}, onComplete)
      store.finishTransaction( transaction )
   elseif  tstate == "restored" then
      print("Transaction restored (from previous session)")
      if "com.speedfeed.iap.sine" == product then
        storeSettings.sinePaid = true
      elseif "com.speedfeed.iap.trig" == product then
        storeSettings.trigPaid = true
      elseif "com.speedfeed.iap.bolt" == product then
        storeSettings.boltPaid = true
--    elseif "com.speedfeed.iap.speed" == product then
--      storeSettings.speedPaid = true
      end
      loadsave.saveTable(storeSettings, "store.json")
      store.finishTransaction( transaction )
   elseif tstate == "refunded" then
      print("User requested a refund -- locking app back")
      if "com.speedfeed.iap.sine" == product then
        storeSettings.sinePaid = false
      elseif "com.speedfeed.iap.trig" == product then
        storeSettings.trigPaid = false
      elseif "com.speedfeed.iap.bolt" == product then
        storeSettings.boltPaid = false
--    elseif "com.speedfeed.iap.speed" == product then
--      storeSettings.speedPaid = false
      end
      loadsave.saveTable(storeSettings, "store.json")
      native.showAlert("Refund", "Purchase was refunded.", {"Okay"})
      store.finishTransaction( transaction )
   elseif tstate == "cancelled" then
      print("User cancelled transaction")
      store.finishTransaction( transaction )
   elseif tstate == "failed" then
      print("Transaction failed, type:", transaction.errorType, transaction.errorString)
      native.showAlert("Failed", transaction.errorType.." - "..transaction.errorString, {"Okay"})
      store.finishTransaction( transaction )
   else
      print("unknown event")
      store.finishTransaction( transaction )
   end

   print("done with store business for now")
end

local function purchase( event )
  if event.phase == "ended" then
    local showing = myData.showing
    
    if showing == "sine" then
      print("Purchase Sine")
      store.purchase({"com.speedfeed.iap.sine"})
      --store.purchase({"android.test.purchased"})
    elseif showing == "trig" then
      print("Purchase Speed")
      store.purchase({"com.speedfeed.iap.trig"})
      --store.purchase({"android.test.canceled"})
    elseif showing == "bolt" then
      print("Purchase Bolt")
      store.purchase({"com.speedfeed.iap.bolt"})
      --store.purchase({"android.test.item_unavailable"})
    elseif showing == "speed" then
      --purchasing speed
    end 
  end
end

goBack = function()
  
  composer.gotoScene( "menu", { effect="fromBottom", time=800})
  
end

goBack2 = function(event)
  local phase = event.phase
  
  if "ended" == phase then
    transition.to( butGroup, {time = 500, y = display.contentHeight + 5})
    transition.to( descGroup, {time = 500, x = display.contentWidth + 5})
    timer.performWithDelay(400, goBack)
  end
  
end

butMove = function()

  transition.to( butGroup, {time = 500, y = 0})
  transition.to( descGroup, {time = 500, x = 0})
end


-- "scene:create()"
function scene:create( event )

  local sceneGroup = self.view
   
  Runtime:addEventListener( "key", onKeyEvent )
  
  storeSettings = loadsave.loadTable("store.json")
  if store.availableStores.apple then
      timer.performWithDelay(1000, function() store.init( "apple", transactionCallback); end)
  end
  if store.availableStores.google then
      timer.performWithDelay( 1000, function() store.init( "google", transactionCallback ); end)
  end
  
  descGroup = display.newGroup()
  butGroup = display.newGroup()
   
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
  
  descBack = display.newRect(descGroup, 0, 0, display.contentWidth / 2 - 50, display.contentHeight)
  descBack.anchorX, descBack.anchorY = 1, 0
  descBack.x, descBack.y = display.contentWidth, 0
  descBack:setFillColor(1)
  --descBack.alpha = 0
  
  descScroll = widget.newScrollView(
    {
      x = descBack.x,
      y = 10,
      width = display.contentWidth / 2 - 50,
      height = display.contentHeight - 50,
      scrollWidth = 0,
      id = "answerScroll",
      hideBackground = true,
      horizontalScrollDisabled = true,
      verticalScrollDisabled = false,
    }
    )
  descGroup:insert(descScroll)
  descScroll.anchorX, descScroll.anchorY = 1, 0
  descScroll.x = descBack.x
  --descScroll.y = descBack.y + 50
  --descScroll.alpha = 0
  
  local options = {parent = descGroup, text="This is a test of the thing that I made ", x=0, y=0, width=descBack.contentWidth - 10, align="left", font="BerlinSansFB-Reg", fontSize=18}
  local options2 = {parent = butGroup, text="This is a Title", x=0, y=0, font="BerlinSansFB-Reg", fontSize=22}
  local options3 = {parent = butGroup, text="$0.99 USD", x=0, y=0, font="BerlinSansFB-Reg", fontSize=16}
  
  display.setDefault( "anchorX", 0 )
  display.setDefault( "anchorY", 0 )
  
  desc = display.newText(options)
  desc:setFillColor(0.15, 0.4, 0.729)
  descScroll:insert(desc)
  desc.x = 5
  desc.y = 0
  
  descTitle = display.newText(options2)
  descTitle.x = 10
  descTitle.y = display.viewableContentHeight - 55
  descTitle:setFillColor(1)
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
  
--  buttBack = display.newRect(butGroup, 0, 0, 75, 65)
--  buttBack:setFillColor(1)
--  buttBack.anchorX = 0
--  buttBack.anchorY = 1
--  buttBack.y = display.contentHeight
  
  backBut = widget.newButton(
    {
      id = "backBut",
      width = 63,
      height = 25,
      label = "BACK",
      labelColor = { default = {0.15, 0.4, 0.729}, over = {1}},
      font = "BerlinSansFB-Reg",
      fontSize = 18,
      defaultFile = "Images/backBut.png",
      overFile = "Images/backButOver.png",
      onEvent = goBack2,
		}
    )
	descGroup:insert(backBut)
  backBut.anchorX = 0.5
  backBut.anchorY = 1
  backBut.y = display.viewableContentHeight - 10
  backBut.x = display.viewableContentWidth - (desc.contentWidth / 4)
  
  buyBut = widget.newButton(
    {
      id = "backBut",
      width = 63,
      height = 25,
      label = "BUY",
      labelColor = { default = {0.076, 0.463, 0}, over = {1}},
      font = "BerlinSansFB-Reg",
      fontSize = 18,
      defaultFile = "Images/buyBut.png",
      overFile = "Images/buyButOver.png",
      onEvent = purchase,
		}
    )
	descGroup:insert(buyBut)
  buyBut.anchorX = 0.5
  buyBut.anchorY = 1
  buyBut.y = display.viewableContentHeight - 10
  buyBut.x = display.viewableContentWidth - ((desc.contentWidth / 4) * 3)
  
  price = display.newText(options3)
  price.anchorX = 0
  price.anchorY = 1
  price.x = 10
  price.y = display.viewableContentHeight - 10
  
  butGroup.anchorX = 0
  butGroup.anchorY = 0
  butGroup.x = 0
  butGroup.y = display.contentHeight + 5
  
  descGroup.anchorX = 0
  descGroup.anchorY = 0
  descGroup.x = display.contentWidth + 5
  descGroup.y = 0
  
  timer.performWithDelay(600, butMove)
  timer.performWithDelay(600, butMove)
   

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
   
   butGroup:removeSelf()
   descGroup:removeSelf()

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