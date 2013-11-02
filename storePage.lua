local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local widget = require ( "widget" )
local store = require ("store")
local loadsave = require ("loadsave")

local back

local storeSettings, restoring
local sineButt, speedButt, boltButt, restoreButt, backButt
local sineBuy, speedBuy, boltBuy
local sineText, speedText, boltText
local sineDesc, speedDesc, boltDesc
local backEdgeX, backEdgeY, optionsBack
local sineGroup, speedGroup, boltGroup
local whichOne, sineSold, speedSold, boltSold

local function onKeyEvent( event )

   local phase = event.phase
   local keyName = event.keyName
   
   if ( "back" == keyName and phase == "up" ) then
       
       timer.performWithDelay(100,goBack2,1)
   end
   return true
end

local function transactionCallback( event )

   print("In transactionCallback", event.transaction.state)
   local transaction = event.transaction
   local tstate = event.transaction.state
   local product = event.transaction.productIdentifier

   if tstate == "purchased" then
      print("Transaction succuessful!")
      if whichOne[1] == product then
        storeSettings.sinePaid = true
        sineButt.alpha = 0.50
        sineButt:setEnabled(false)
        sineBuy.alpha = 0
      elseif whichOne[2] == product then
        storeSettings.trigPaid = true
        speedButt.alpha = 0.50
        speedButt:setEnabled(false)
        speedBuy.alpha = 0
      elseif whichOne[3] == product then
        storeSettings.boltPaid = true
        boltButt.alpha = 0.50
        boltButt:setEnabled(false)
        boltBuy.alpha = 0
      end
      loadsave.saveTable(storeSettings, "store.json")
      --native.showAlert("Success", "Function is now unlocked!", {"Okay"})
      store.finishTransaction( transaction )
   elseif  tstate == "restored" then
      print("Transaction restored (from previous session)")
      if whichOne[1] == product then
        storeSettings.sinePaid = true
        sineButt.alpha = 0.50
        sineButt:setEnabled(false)
        sineBuy.alpha = 0
      elseif whichOne[2] == product then
        storeSettings.trigPaid = true
        speedButt.alpha = 0.50
        speedButt:setEnabled(false)
        speedBuy.alpha = 0
      elseif whichOne[3] == product then
        storeSettings.boltPaid = true
        boltButt.alpha = 0.50
        boltButt:setEnabled(false)
        boltBuy.alpha = 0
      end
      loadsave.saveTable(storeSettings, "store.json")
      store.finishTransaction( transaction )
   elseif tstate == "refunded" then
      print("User requested a refund -- locking app back")
      if whichOne[1] == product then
        storeSettings.sinePaid = false
      elseif whichOne[2] == product then
        storeSettings.trigPaid = false
      elseif whichOne[3] == product then
        storeSettings.boltPaid = false
      end
      loadsave.saveTable(storeSettings, "store.json")
      native.showAlert("Refund", "Purchase was refunded.", {"Okay"})
      store.finishTransaction( transaction )
   elseif tstate == "cancelled" then
      print("User cancelled transaction")
      store.finishTransaction( transaction )
   elseif tstate == "failed" then
      print("Transaction failed, type:", transaction.errorType, transaction.errorString)
      --native.showAlert("Failed", transaction.errorType.." - "..transaction.errorString, {"Okay"})
      store.finishTransaction( transaction )
   else
      print("unknown event")
      store.finishTransaction( transaction )
   end

   print("done with store business for now")
end

local function goBack( event )
  if event.phase == "ended" then
    
    storyboard.gotoScene( "menu", { effect="slideRight", time=800})
    
  end
end

local function purchase( event )
  if event.phase == "ended" then
    
    if event.target.num == 1 then
      print("Purchase Sine")
      store.purchase({"com.speedfeed.iap.sine"})
      --store.purchase({"android.test.purchased"})
    elseif event.target.num == 2 then
      print("Purchase Speed")
      store.purchase({"com.speedfeed.iap.trig"})
      --store.purchase({"android.test.canceled"})
    elseif event.target.num == 3 then
      print("Purchase Bolt")
      store.purchase({"com.speedfeed.iap.bolt"})
      --store.purchase({"android.test.item_unavailable"})
    end
    
  end
end

local function restorePurchases( event )
  if event.phase == "ended" then
    
    print("Restore all purchases")
    store.restore()    
    
  end
end

local function descSelect ( event )
  local phase = event.phase 
   if "ended" == phase then

    if event.target.num == 1 then
        sineGroup.alpha = 1
        speedGroup.alpha = 0
        boltGroup.alpha = 0

        sineButt.alpha = 0
        sineBuy.alpha = 1
        if not storeSettings.trigPaid then 
          speedButt.alpha = 1
        end
        if not storeSettings.boltPaid then
          boltButt.alpha = 1
        end
    elseif event.target.num == 2 then
        speedGroup.alpha = 1
        sineGroup.alpha = 0
        boltGroup.alpha = 0

        speedButt.alpha = 0
        speedBuy.alpha = 1
        if not storeSettings.sinePaid then 
          sineButt.alpha = 1
        end
        if not storeSettings.boltPaid then
          boltButt.alpha = 1
        end
    elseif event.target.num == 3 then
        boltGroup.alpha = 1
        sineGroup.alpha = 0
        speedGroup.alpha = 0
        
        boltButt.alpha = 0
        boltBuy.alpha = 1
        if not storeSettings.trigPaid then 
          speedButt.alpha = 1
        end
        if not storeSettings.sinePaid then
          sineButt.alpha = 1
        end
    end

   end
end


function scene:createScene( event )
	local screenGroup = self.view

	Runtime:addEventListener( "key", onKeyEvent )

  storeSettings = loadsave.loadTable("store.json")
  if store.availableStores.apple then
      timer.performWithDelay(1000, function() store.init( "apple", transactionCallback); end)
  end
  if store.availableStores.google then
      timer.performWithDelay( 1000, function() store.init( "google", transactionCallback ); end)
  end

  whichOne = {}
  whichOne[1] = "com.speedfeed.iap.sine"
  --whichOne[1] = "android.test.purchased"
  whichOne[2] = "com.speedfeed.iap.trig"
  --whichOne[2] = "android.test.canceled"
  whichOne[3] = "com.speedfeed.iap.bolt"
  --whichOne[3] = "android.test.item_unavailable"

  sineGroup = display.newGroup ( )
  speedGroup = display.newGroup ( )
  boltGroup = display.newGroup ( )

	back = 	display.newImageRect( screenGroup, "backgrounds/background.png", 570, 360 )
	back.x = display.contentCenterX
	back.y = display.contentCenterY
  backEdgeX = back.contentBounds.xMin
	backEdgeY = back.contentBounds.yMin

  optionsBack = display.newRect(screenGroup, 0, 0, display.contentWidth/3, 365)
  optionsBack:setFillColor(255, 255, 255)
  optionsBack:setReferencePoint(display.TopRightReferencePoint)
  optionsBack.x = display.actualContentHeight
  optionsBack.y = 0

  local options = {text="", x=0, y=0, width=300, align="left", font="BerlinSansFB-Reg", fontSize=16}

  title = display.newText( screenGroup, "Function Store", 0, 5, 150, 100, "BerlinSansFB-Reg", 28 )
  title:setTextColor(35, 87, 157)
  --title:setEmbossColor({highlight = {r=0, g=0, b=0, a=200}, shadow = {r=0,g=0,b=0, a=0}})
  title.x = display.actualContentHeight-60

  sineButt = widget.newButton
  {
    id = "sineButt",
    width = 125,
    label = "Sine Bar",
    labelColor = { default = {255, 255, 255}, over = {39, 102, 186, 200}},
    font = "BerlinSansFB-Reg",
    fontSize = 20,
    defaultFile = "Images/buttonOver.png",
    overFile = "Images/button.png",
    onRelease = descSelect,    
    }
  sineButt.num = 1
  screenGroup:insert(sineButt)
  sineButt.x = display.actualContentHeight-85
  sineButt.y = 110

  sineBuy = widget.newButton
  {
    id = "sineBuy",
    width = 125,
    label = "Buy",
    labelColor = { default = {255, 255, 255}, over = {19, 124, 21}},
    font = "BerlinSansFB-Reg",
    fontSize = 16,
    defaultFile = "Images/buyOver.png",
    overFile = "Images/buy.png",
    onRelease = purchase,    
    }
  sineBuy.num = 1
  sineGroup:insert(sineBuy)
  sineBuy.x = display.actualContentHeight-85
  sineBuy.y = 110
  sineBuy.alpha = 0
--Speed is Trig in this app
  speedButt = widget.newButton
  {
    id = "speedButt",
    width = 125,
    label = "Trigonometry",
    labelColor = { default = {255, 255, 255}, over = {39, 102, 186, 200}},
    font = "BerlinSansFB-Reg",
    fontSize = 16,
    defaultFile = "Images/buttonOver.png",
    overFile = "Images/button.png",
    onRelease = descSelect,    
    }
  speedButt.num = 2
  screenGroup:insert(speedButt)
  speedButt.x = display.actualContentHeight-85
  speedButt.y = 170

  speedBuy = widget.newButton
  {
    id = "speedBuy",
    width = 125,
    label = "Buy",
    labelColor = { default = {255, 255, 255}, over = {19, 124, 21}},
    font = "BerlinSansFB-Reg",
    fontSize = 16,
    defaultFile = "Images/buyOver.png",
    overFile = "Images/buy.png",
    onRelease = purchase,    
    }
  speedBuy.num = 2
  speedGroup:insert(speedBuy)
  speedBuy.x = display.actualContentHeight-85
  speedBuy.y = 170
  speedBuy.alpha = 0

  boltButt = widget.newButton
  {
    id = "boltButt",
    width = 125,
    label = "Bolt Circle",
    labelColor = { default = {255, 255, 255}, over = {39, 102, 186, 200}},
    font = "BerlinSansFB-Reg",
    fontSize = 20,
    defaultFile = "Images/buttonOver.png",
    overFile = "Images/button.png",
    onRelease = descSelect,    
    }
  boltButt.num = 3
  screenGroup:insert(boltButt)
  boltButt.x = display.actualContentHeight-85
  boltButt.y = 230

  boltBuy = widget.newButton
  {
    id = "boltBuy",
    width = 125,
    label = "Buy",
    labelColor = { default = {255, 255, 255}, over = {19, 124, 21}},
    font = "BerlinSansFB-Reg",
    fontSize = 16,
    defaultFile = "Images/buyOver.png",
    overFile = "Images/buy.png",
    onRelease = purchase,    
    }
  boltBuy.num = 3
  boltGroup:insert(boltBuy)
  boltBuy.x = display.actualContentHeight-85
  boltBuy.y = 230
  boltBuy.alpha = 0

  restoreButt = widget.newButton
  {
    id = "restoreButt",
    width = 125,
    label = "Restore",
    labelColor = { default = {255,255,255}, over = {198,68,68}},
    font = "BerlinSansFB-Reg",
    fontSize = 20,
    defaultFile = "Images/restoreButtOver.png",
    overFile = "Images/restoreButt.png",
    onRelease = restorePurchases,    
    }
  restoreButt.num = 3
  restoreButt.pressed = false
  screenGroup:insert(restoreButt)
  restoreButt.x = display.actualContentHeight-85
  restoreButt.y = 290

  backButt = display.newImageRect(screenGroup, "Images/backButt.png", 54, 22)
  backButt:setReferencePoint(display.TopLeftReferencePoint)
  backButt:addEventListener("touch", goBack)
  backButt.isHitTestable = true
  backButt.x = 10
  backButt.y = 10

  sineDesc = display.newImageRect( sineGroup, "backgrounds/sineDesc.png", 285, 180 )
  sineDesc.x = 200
  sineDesc.y = 115

  sineText = display.newText( options )
  sineGroup:insert(sineText)
  sineText.text = "Quickly and accurately calculate precision block stack or angle for use with sine bars or sine plates. $0.99 USD"
  sineText.x = 200
  sineText.y = 230

  sineGroup.alpha = 0

--speed is replaced by Trig in this app

  speedDesc = display.newImageRect( speedGroup, "backgrounds/trig.png", 285, 180 )
  speedDesc.x = 200
  speedDesc.y = 110

  speedText = display.newText( options )
  speedGroup:insert(speedText)
  speedText.text = "Solve Right Angle and Oblique Triangle problems. Easily switch between inch and metric, and convert between degrees-decimal and degrees, minutes and seconds. $0.99 USD"
  speedText.x = 200
  speedText.y = 245

  speedGroup.alpha = 0

  boltDesc = display.newImageRect( boltGroup, "backgrounds/boltDesc.png", 285, 180 )
  boltDesc.x = 200
  boltDesc.y = 115

  boltText = display.newText( options )
  boltGroup:insert(boltText)
  boltText.text = "Calculate X-Y coordinates for equally spaced bolts. You can make the center of the circle any coordinate you need, and place the first hole at any angle. $0.99 USD"
  boltText.x = 200
  boltText.y = 245

  boltGroup.alpha = 0

  screenGroup:insert(sineGroup)
  screenGroup:insert(speedGroup)
  screenGroup:insert(boltGroup)

  if storeSettings.sinePaid then
    sineButt.alpha = 0.50
    sineButt:setEnabled(false)
  end

  if storeSettings.trigPaid then
    speedButt.alpha = 0.50
    speedButt:setEnabled(false)
  end

  if storeSettings.boltPaid then
    boltButt.alpha = 0.50
    boltButt:setEnabled(false)
  end

  if not storeSettings.sinePaid and not storeSettings.trigPaid and not storeSettings.boltPaid then
    restoreButt.alpha = 1
  else
    restoreButt.alpha = 0
  end

end

function scene:enterScene( event )
  local group = self.view
        
		storyboard.purgeScene( "menu" )

end

function scene:exitScene( event )
  local group = self.view
   
  Runtime:removeEventListener( "key", onKeyEvent )
  
	
end

scene:addEventListener( "createScene", scene )

scene:addEventListener( "enterScene", scene )

scene:addEventListener( "exitScene", scene )

function goBack2()
	
  if (storyboard.isOverlay) then
    storyboard.number = "Tap Me"
    storyboard.hideOverlay()
  else
	storyboard.gotoScene( "menu", { effect="slideRight", time=800})
  end
		
end


return scene


