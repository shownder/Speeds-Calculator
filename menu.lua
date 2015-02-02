local composer = require( "composer" )
local scene = composer.newScene()
local widget = require ( "widget" )
local store = require ("store")
local loadsave = require("loadsave")
local myData = require("myData")
local device = require("device")
local analytics = require( "analytics" )
display.setStatusBar(display.HiddenStatusBar)
---------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE
-- unless "composer.removeScene()" is called.
---------------------------------------------------------------------------------

local backEdgeX, backEdgeY

local rightButt, rightlabel
local obliqueButt, obliqueLabel
local sineButt, sineLabel
local boltButt, boltLabel
local speedButt, speedLabel
local counterButt, counterLabel
local chartButt, chartLabel
local matButt, matLabel
local timesOpen2, restoreBut
local back
local logo, facebookButt
local topBar
local scrollComplete, going, goingTo
local bought, storeSettings
local createTable, appleRestore, tableBuy, buyCount

local butTable, labelTable, menuList
local store
local v3 = false

local function sceneSelect()

   	if going.num == 5 then
      analytics.logEvent( "Right_Angle" )
		composer.gotoScene( "rightAngle", { effect="fromTop", time=800} )
		elseif going.num == 6 then
      analytics.logEvent( "Oblique" )
		composer.gotoScene( "oblique", { effect="fromTop", time=800} )
		elseif going.num == 7 then
      analytics.logEvent( "Sine_Bar" )
		composer.gotoScene( "sineBar", { effect="fromTop", time=800} )
		elseif going.num == 8 then
      analytics.logEvent( "Bolt" )
		composer.gotoScene( "bolt", { effect="fromTop", time=800} )
		elseif going.num == 1 then
      analytics.logEvent( "Speed" )
		composer.gotoScene( "speedFeed", { effect="fromTop", time=800} )
    elseif going.num == 2 then
      analytics.logEvent( "Counter_Sink" )
		composer.gotoScene( "counter", { effect="fromTop", time=800} )
    elseif going.num == 3 then
      analytics.logEvent( "Charts" )
		composer.gotoScene( "charts", { effect="fromTop", time=800, params = {isOverlay = false}} )
    elseif going.num == 4 then
      analytics.logEvent( "Materials_List" )
		composer.gotoScene( "materials", { effect="fromTop", time=800, params = {isOverlay = false}} )
    elseif going.num == "store" then
      analytics.logEvent( "Store" )
		composer.gotoScene( "storePage", { effect="fromTop", time=800} )
   	end
end

local function goingFacebook ( event )
	local phase = event.phase 

  analytics.logEvent( "Facebook" ) 

    if (not system.openURL("fb://profile/187552938002070")) then
      system.openURL("http://www.facebook.com/pages/Machinists-Calculator/187552938002070")
    end
    
end

local function onKeyEvent( event )

   local phase = event.phase
   local keyName = event.keyName
   print( event.phase, event.keyName )

   if ( "back" == keyName and phase == "up" ) then
      native.requestExit()
   end
   return true
end

local function alertListener ( event )
	if "clicked" == event.action then

		local i = event.index
    
    if i == 3 then
      timesOpen2.opened = "never"
      loadsave.saveTable(timesOpen2, "timesOpen2.json")
      local options =
        {
          iOSAppId = "737001001",
          supportedAndroidStores = { "google" },
        }
        
      if (string.sub(system.getInfo("model"),1,2) == "iP") then
        --We are on iOS
        local version = system.getInfo("platformVersion")
        version = string.sub(version, 1, 3)
        if tonumber(version) >= 7.1 then
          system.openURL("http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=737001001&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8")
        else
          native.showPopup("rateApp", options)
        end
      else  
        --It's on Android or Windows
        native.showPopup("rateApp", options)
      end
    elseif i == 2 then
      timesOpen2.opened = -1
      loadsave.saveTable(timesOpen2, "timesOpen2.json")
    elseif i == 1 then
      timesOpen2.opened = "never"
      loadsave.saveTable(timesOpen2, "timesOpen2.json")
    end
        
	end
end

local function moveItems()
  
 menuList:scrollToIndex( 3, 1300, scrollComplete )
  
end

scrollComplete = function()
  
  menuList:scrollToIndex( 1, 500 )

end

local function onRowRender( event )

    -- Get reference to the row group
    local row = event.row
    local buttons = event.row.params.buttons
    local labels = event.row.params.labels
    local buttons2 = event.row.params.buttons2
    local labels2 = event.row.params.labels2
    local icon, label

    -- Cache the row "contentWidth" and "contentHeight" because the row bounds can change as children objects are added
    local rowHeight = row.contentHeight
    local rowWidth = row.contentWidth
    local butImage = buttons[row.index]
    local labelImage = labels[row.index]
    
    icon = display.newImageRect(row, buttons[row.index], 56, 56)
    icon.anchorX = 0
    icon.x = 0
    icon.y = rowHeight * 0.5
    icon.alpha = 0
    if row.index > bought then
      transition.to(icon, {alpha = 0.25, time = 500})
    else
      transition.to(icon, {alpha = 0.75, time = 500})
    end    
    
    label = display.newText( { parent = row, text = labels[row.index], 0, 0, font = "BerlinSansFB-Reg", fontSize = 20, width = 100})
    label.anchorX = 0
    label.x = icon.x + icon.contentWidth + 10
    label.y = rowHeight * 0.5
    label:setFillColor(0.15, 0.4, 0.729, 0.90)
    label.alpha = 0
    if row.index > bought then
      transition.to(label, {alpha = 0.25, time = 500})
    else
      transition.to(label, {alpha = 1, time = 500})
    end
    
    if labels[row.index] == "Right Angle" then
      goingTo[row.index] = 5
    elseif labels[row.index] == "Oblique Triangle" then
      goingTo[row.index] = 6
      myData[row.index] = "Oblique Triangle"
    elseif labels[row.index] == "Sine Bar" then
      goingTo[row.index] = 7
      myData[row.index] = "Sine Bar"
    elseif labels[row.index] == "Bolt Circle" then
      goingTo[row.index] = 8
      myData[row.index] = "Bolt Circle"
    end

  return true
end

local function onRowTouch( event )
  local phase = event.phase
  local row = event.target.index
  
  if "press" == phase then
   
  elseif "release" == phase then
    if row > bought then
      going.num = "store"
      if goingTo[row] == 5 then
        myData.showing = "trig"
      elseif goingTo[row] == 6 then
        myData.showing = "trig"
      elseif goingTo[row] == 7 then
        myData.showing = "sine"
      elseif goingTo[row] == 8 then
        myData.showing = "bolt"
      end
    elseif (row > 4) then
      going.num = goingTo[row]
    else
      going.num = row
    end
    
    print(row)
    print(going.num)
    sceneSelect()
  end
end

local function transactionCallback( event )

   print("In transactionCallback", event.transaction.state)
   local transaction = event.transaction
   local tstate = event.transaction.state
   local product = event.transaction.productIdentifier
   
   if tstate == "purchased" then
     tstate = "restored"
   end

   if  tstate == "restored" then
      storeSettings.buyCount = storeSettings.buyCount + 1
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
       if storeSettings.buyCount == 1 then
        timer.performWithDelay(1500, function() composer.gotoScene( "restorePage", { effect="fade", time=100} ); end)
       end
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
      myData.refund = true
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

appleRestore = function(event)
  if event.phase == "ended" then
    store.init( "apple", transactionCallback)
    timer.performWithDelay(500, store.restore)
  end
end

tableBuy = function()
  
  if storeSettings.sinePaid then
    local temp = butTable[7]
    local temp2 = labelTable[7]
    table.insert(butTable, bought + 1, temp)
    table.insert(labelTable, bought + 1, temp2)
    table.remove(butTable, 8)
    table.remove(labelTable, 8)    
    bought = bought + 1
  end
  
  if storeSettings.trigPaid then
    local temp = butTable[5]
    local temp2 = labelTable[5]
    table.insert(butTable, bought + 1, temp)
    table.insert(labelTable, bought + 1, temp2)
    table.remove(butTable, 6)
    table.remove(labelTable, 6)    
    bought = bought + 1
  end
  
  if storeSettings.trigPaid then
    local temp = butTable[6]
    local temp2 = labelTable[6]
    table.insert(butTable, bought + 1, temp)
    table.insert(labelTable, bought + 1, temp2)
    table.remove(butTable, 7)
    table.remove(labelTable, 7)    
    bought = bought + 1
  end
  
  if storeSettings.boltPaid then
    local temp = butTable[8]
    local temp2 = labelTable[8]
    table.insert(butTable, bought + 1, temp)
    table.insert(labelTable, bought + 1, temp2)
    table.remove(butTable, 9)
    table.remove(labelTable, 9)    
    bought = bought + 1
  end
  
  timer.performWithDelay(1500, createTable)
end

googleRefund = function()
  
  if myData.refund then
    composer.gotoScene( "restorePage", { effect="fade", time=100} )
  end
end

---------------------------------------------------------------------------------

-- "scene:create()"
function scene:create( event )

  local sceneGroup = self.view
  myData.inch = false 
  myData.refund = false
  timesOpen2 = loadsave.loadTable("timesOpen2.json")
  
  if timesOpen2.opened == 5 then
    native.showAlert ( "Find this App useful?", "Leave a review and help others find it!", { "Never", "Later", "OK" }, alertListener )
  end
    
  print("Times Opened "..timesOpen2.opened)
  
  storeSettings = loadsave.loadTable("store.json")
  if (loadsave.loadTable("store.json") == nil) then
    storeSettings = {}
    storeSettings.trigPaid = false
    storeSettings.sinePaid = false
    storeSettings.boltPaid = false
    storeSettings.buyCount = 0
    loadsave.saveTable(storeSettings, "store.json")
  end
  
  if storeSettings.buyCount == nil then
    storeSettings.buyCount = 0
    loadsave.saveTable(storeSettings, "store.json")
  end

  if ( system.getInfo( "platformName" ) == "Android" ) then
    print("this is google store!")
    store = require( "plugin.google.iap.v3" )
    v3 = true
  elseif ( system.getInfo( "platformName" ) == "iPhone OS" ) then
    store = require( "store" )
  else
    native.showAlert( "Notice", "In-app purchases are not supported in the Corona Simulator.", { "OK" } )
  end
  
--  storeSettings.sinePaid = true
--  storeSettings.trigPaid = true
--  storeSettings.boltPaid = true
  
  going = {}
  goingTo = {}
  going.num = 1
  bought = 4
  
  back = display.newRect( sceneGroup, display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight )
  
  backEdgeX = back.contentBounds.xMin
	backEdgeY = back.contentBounds.yMin
  
  Runtime:addEventListener( "key", onKeyEvent )
  
  logo = display.newImageRect(sceneGroup, "Images/title.png", 175, 100)
  logo.x = backEdgeX + 10
  logo.anchorX = 0
  logo.anchorY = 0.5
  logo.y = logo.contentHeight / 2 + 40
  
  topBar = display.newRect( sceneGroup, 0, 0, display.contentWidth, 30 )
  topBar:setFillColor(0.15, 0.4, 0.729, 0.75)
  topBar.anchorX = 0
  topBar.anchorY = 0
  
  facebookButt = display.newImageRect(sceneGroup, "Images/facebook.png", 42, 42)
  facebookButt.anchorX = 0
  facebookButt.anchorY = 0.5
  facebookButt.x = logo.x
  facebookButt.y = logo.y * 2
  facebookButt:addEventListener ( "touch", goingFacebook )
  
  print(storeSettings.buyCount)
  
  if device.isApple and storeSettings.buyCount < 1 then
    restoreBut = display.newImageRect(sceneGroup, "Images/restoreBut.png", 42, 42)
    restoreBut.anchorX = 0
    restoreBut.anchorY = 0.5
    restoreBut.x = logo.x + facebookButt.contentWidth + 15
    restoreBut.y = logo.y * 2
    restoreBut.alpha = 0.6
    restoreBut:addEventListener("touch", appleRestore)
    
    local restoreLabel = display.newText( { parent = sceneGroup, text = "Restore Purchases", 0, 0, font = "BerlinSansFB-Reg", fontSize = 14, width = 85, align = "center"})
    restoreLabel.x = restoreBut.x + 21
    restoreLabel.y = restoreBut.y + 40
    restoreLabel:setFillColor(0.608, 0, 0, 0.6)
  elseif ( system.getInfo( "platformName" ) == "Android" ) then 
      timer.performWithDelay( 300, function() store.init( "google", transactionCallback ); end)
      timer.performWithDelay( 1000, store.restore)
      timer.performWithDelay( 1500, googleRefund)
  end
    
  butTable = {}
  butTable2 = {}
  labelTable = {}
  labelTable2 = {}
  
  butTable[1] = "Images/speedMenu.png"
  butTable[2] = "Images/counterButt.png"
  butTable[3] = "Images/chartMenu.png"
  butTable[4] = "Images/mattButt.png"
  butTable[5] = "Images/rightMenu.png"
  butTable[6] = "Images/obliqueMenu.png"
  butTable[7] = "Images/sineMenu.png"
  butTable[8] = "Images/boltMenu.png"
  
  labelTable[1] = "Speeds & Feeds"
  labelTable[2] = "C'Sink & Drill Point"
  labelTable[3] = "Drill Charts"
  labelTable[4] = "Materials List"
  labelTable[5] = "Right Angle"
  labelTable[6] = "Oblique Triangle"
  labelTable[7] = "Sine Bar"
  labelTable[8] = "Bolt Circle"

  menuList = widget.newTableView{
    left = logo.x + logo.contentWidth + 10,
    top = topBar.contentHeight,
    width = display.contentWidth - (logo.x + logo.contentWidth + 10) - 10,
    height = display.contentHeight - topBar.contentHeight,
    onRowTouch = onRowTouch,
    onRowRender = onRowRender,
    hideScrollBar = false,
    noLines = true,
  }
  sceneGroup:insert(menuList)
  
  tableBuy()
  
  for i = 1, 8, 1 do
    
    local isCategory = false
    local rowHeight = 65
    local rowColor = { default={ 1, 1, 1 }, over={ 0.15, 0.4, 0.729, 0.2 } }
    local lineColor = { 0.15, 0.4, 0.729 }     
       
    menuList:insertRow(
    {
      isCategory = isCategory,
      rowHeight = rowHeight,
      rowColor = rowColor,
      lineColor = lineColor,
      params = { buttons = butTable, labels = labelTable, buttons2 = butTable2, labels2 = labelTable2 }
      }
    )
  end

  local menuOpened = loadsave.loadTable("menuOpen.json")
  if menuOpened.opened == false then
    timer.performWithDelay(500, moveItems)
    menuOpened.opened = true
    loadsave.saveTable(menuOpened, "menuOpen.json")
  end

     
end

-- "scene:show()"
function scene:show( event )

   local sceneGroup = self.view
   local phase = event.phase

   if ( phase == "will" ) then
      -- Called when the scene is still off screen (but is about to come on screen).
   elseif ( phase == "did" ) then
    local sceneName = composer.getSceneName( "previous" )
			
			if sceneName ~= nil then
				composer.removeScene( sceneName, true )
			end
      
      myData.number = nil
   end
end

-- "scene:hide()"
function scene:hide( event )

   local sceneGroup = self.view
   local phase = event.phase

   if ( phase == "will" ) then
      Runtime:removeEventListener( "key", onKeyEvent )
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