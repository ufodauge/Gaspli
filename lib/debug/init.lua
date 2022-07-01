---------------------------------------
-- Debug
-- Q で表示および非表示を切り替え
---------------------------------------
local path = ... .. '.'

-- lib
local FrameCount = require( path .. 'module.framecount' )
local FreeCamera = require( path .. 'module.camera' )
local KeyManager = require( path .. 'module.keymanager' )
local Keyboard = require( path .. 'module.keyboard' )
local Directory = require( path .. 'module.directory' )
local File = require( path .. 'module.file' )
local EntryManager = require( path .. 'module.entrymanager' )
local Cursor = require( path .. 'module.cursor' )
local printOutlined = require( path .. 'module.utils' ).printOutlined

-- defines
local syspath = path:gsub( '%.', '/' )
local DEBUG_MENU_X = 20
local DEBUG_MENU_Y = 10
local DEBUG_INFO_X = 20
local DEBUG_INFO_Y = 400
local DEBUG_FRAMECOUNT_X = love.graphics.getWidth() - 200
local DEBUG_FRAMECOUNT_Y = 5
local DEBUG_TEXT_HEIGHT = 16
local DEBUG_FONT_SIZE = 16
local DEBUG_FONT = love.graphics.newFont( syspath ..
                                              'resource/fixedsys-ligatures.ttf',
                                          DEBUG_FONT_SIZE )
DEBUG_FONT:setFilter( 'nearest', 'nearest' )

local DEBUG_CAMERA_MOVE_DISTANCE = 5

local _resize = love.resize
function love.resize( w, h )
  _resize( w, h )
  DEBUG_FRAMECOUNT_X = love.graphics.getWidth() - 200
end

--------------------------------------------------
-- Class: Debug
local Debug = {}
local Public = {}

function Public.getInstance()
  if Debug.singleton == nil then
    Debug.singleton = Debug.new()
  end

  assert( Debug.singleton ~= nil, 'Debug is not initialized.' )
  return Debug.singleton
end

function Debug:printDebugMenu( x, y )
  if not self:isMenuShowing() then
    return
  end

  -- デバッグメニュー
  self.entryManager:print( x, y, DEBUG_TEXT_HEIGHT )
  self.cursor:print( x - 10, y, DEBUG_TEXT_HEIGHT )

end

function Debug:update( dt )
  -- デバッグメニューが無効ならば更新しない
  if not self:isEnabled() then
    return
  end

  self.keyManager:update( dt )
  self.freeCamera:update( dt )
  self.frameCount:update( dt )
end

function Debug:draw()
  -- デバッグメニューが無効ならば描画しない
  if not self:isEnabled() then
    return
  end

  -- 現在のフレーム数/FPSを表示する
  love.graphics.push()
  love.graphics.setColor( 1, 1, 1, 1 )
  love.graphics.setFont( DEBUG_FONT )
  love.graphics.translate( DEBUG_FRAMECOUNT_X, DEBUG_FRAMECOUNT_Y )
  self.frameCount:printFrames( 0, 0 )
  self.frameCount:printFps( 0, 0 + DEBUG_TEXT_HEIGHT )
  self.freeCamera:printCenterPosition( 0, 0 + DEBUG_TEXT_HEIGHT * 2 )
  love.graphics.setColor( 1, 1, 1, 1 )
  love.graphics.pop()

  -- デバッグメニュー表示
  love.graphics.setFont( DEBUG_FONT )
  self:printDebugMenu( DEBUG_MENU_X, DEBUG_MENU_Y )
  self:printDebugInfo( DEBUG_INFO_X, DEBUG_INFO_Y )
end

-- デバッグメニューの有効・無効状態の取得
function Debug:isEnabled()
  return self.available
end

-- デバッグメニューの表示
function Debug:showDebugMenu()
  self.showing = true
end

-- デバッグメニューの非表示
function Debug:hideDebugMenu()
  self.showing = false
end

-- デバッグメニューの表示状態を取得
function Debug:isMenuShowing()
  return self.showing
end

function Debug:setDebugInfo( text )
  table.insert( self.debugTextList, text )
end

function Debug:printDebugInfo( x, y )
  for index, text in ipairs( self.debugTextList ) do
    printOutlined( index .. ': ' .. text, DEBUG_INFO_X,
                   DEBUG_INFO_Y + DEBUG_FONT_SIZE * (index - 1) )
  end

  self.debugTextList = {}
end

function Debug:changeFreeCameraConfig( type )
  self.freeCamera:changeConfig( type )
end

function Debug:attachFreeCamera()
  self.freeCamera:attach()
end

function Debug:detachFreeCamera()
  self.freeCamera:detach()
end

function Debug:Enable()
  self.available = true
end

-- Debug functions
function Debug.new( available )
  local obj = {
    frameCount = FrameCount:getInstance(),
    freeCamera = FreeCamera:getInstance(),
    keyManager = KeyManager:getInstance(),

    -- インスタンス変数
    -- x, y:        座標
    -- available:       デバッグメニューを有効化するか否か
    -- showing:      スクリーン表示させるか否か
    -- list:        選択肢のリスト
    -- frameCount: フレームカウント
    -- index:       選択中のインデックス
    x = DEBUG_MENU_X,
    y = DEBUG_MENU_Y,
    available = available or false,
    showing = false,
    debugTextList = {},
    entryManager = EntryManager.new( Directory.new( 'root' ) ),
    cursor = Cursor:getInstance()
  }

  obj.entryManager:addObserver( obj.cursor:getObserver() )

  local SelectEntryUp = Keyboard.new( 'pageup', function()
    -- 非表示の際は更新しない
    if not obj:isMenuShowing() then
      return
    end

    -- カーソルの上方向への移動
    -- ポインタで一つ手前のエントリに移動する
    obj.entryManager:selectPrevEntry()
  end, 'pressed' )
  local SelectEntryDown = Keyboard.new( 'pagedown', function()
    -- 非表示の際は更新しない
    if not obj:isMenuShowing() then
      return
    end

    -- カーソルの下方向への移動
    -- ポインタで一つ後のエントリに移動する
    obj.entryManager:selectNextEntry()
  end, 'pressed' )
  local SelectEntryExecute = Keyboard.new( 'end', function()
    -- 非表示の際は更新しない
    if not obj:isMenuShowing() then
      return
    end

    -- 最後に選択したものに移動or実行
    obj.entryManager:execute()
  end, 'pressed' )
  local ToggleDebugMenu = Keyboard.new( 'home', function()
    if obj:isMenuShowing() then
      obj:hideDebugMenu()
    else
      obj:showDebugMenu()
    end
  end, 'pressed' )
  local MoveFreeCameraUpWithKeypad = Keyboard.new( 'kp8', function()
    obj.freeCamera:move( 0, -DEBUG_CAMERA_MOVE_DISTANCE )
  end, 'repeat', 'pressed' )
  local MoveFreeCameraDownWithKeypad = Keyboard.new( 'kp2', function()
    obj.freeCamera:move( 0, DEBUG_CAMERA_MOVE_DISTANCE )
  end, 'repeat', 'pressed' )
  local MoveFreeCameraLeftWithKeypad = Keyboard.new( 'kp4', function()
    obj.freeCamera:move( -DEBUG_CAMERA_MOVE_DISTANCE, 0 )
  end, 'repeat', 'pressed' )
  local MoveFreeCameraRightWithKeypad = Keyboard.new( 'kp6', function()
    obj.freeCamera:move( DEBUG_CAMERA_MOVE_DISTANCE, 0 )
  end, 'repeat', 'pressed' )
  local MoveFreeCameraUpWithArrow = Keyboard.new( 'up', function()
    obj.freeCamera:move( 0, -DEBUG_CAMERA_MOVE_DISTANCE )
  end, 'repeat', 'pressed' )
  local MoveFreeCameraDownWithArrow = Keyboard.new( 'down', function()
    obj.freeCamera:move( 0, DEBUG_CAMERA_MOVE_DISTANCE )
  end, 'repeat', 'pressed' )
  local MoveFreeCameraLeftWithArrow = Keyboard.new( 'left', function()
    obj.freeCamera:move( -DEBUG_CAMERA_MOVE_DISTANCE, 0 )
  end, 'repeat', 'pressed' )
  local MoveFreeCameraRightWithArrow = Keyboard.new( 'right', function()
    obj.freeCamera:move( DEBUG_CAMERA_MOVE_DISTANCE, 0 )
  end, 'repeat', 'pressed' )

  -- ディレクトリ構造
  do
    local root = obj.entryManager:rootDirectory()

    root:add( Directory.new( 'toggle' ) )
    root:getEntry( 'toggle' ):add( File.new( 'frameCount', function()
      obj.frameCount:toggle()
    end ) )
    root:getEntry( 'toggle' ):add( File.new( 'freeCamera', function()
      obj.freeCamera:toggle()
    end ) )
    root:getEntry( 'toggle' ):add( File.new( 'return', function()
      obj.entryManager:moveParent()
    end ) )

    root:add( Directory.new( 'frameCount' ) )
    root:getEntry( 'frameCount' ):add( File.new( 'reset', function()
      obj.frameCount:reset()
    end ) )
    root:getEntry( 'frameCount' ):add( File.new( 'stop', function()
      obj.frameCount:stop()
    end ) )
    root:getEntry( 'frameCount' ):add( File.new( 'start', function()
      obj.frameCount:start()
    end ) )
    root:getEntry( 'frameCount' ):add( File.new( 'return', function()
      obj.entryManager:moveParent()
    end ) )

    root:add( Directory.new( 'freeCamera' ) )
    root:getEntry( 'freeCamera' ):add( Directory.new( 'keyconfig' ) )
    root:getEntry( 'freeCamera' ):getEntry( 'keyconfig' ):add( File.new(
                                                                   'dirkey',
                                                                   function()
          obj.keyManager:remove( MoveFreeCameraUpWithKeypad,
                                 MoveFreeCameraDownWithKeypad,
                                 MoveFreeCameraLeftWithKeypad,
                                 MoveFreeCameraRightWithKeypad )
          obj.keyManager:add( MoveFreeCameraUpWithArrow,
                              MoveFreeCameraDownWithArrow,
                              MoveFreeCameraLeftWithArrow,
                              MoveFreeCameraRightWithArrow )
        end ) )
    root:getEntry( 'freeCamera' ):getEntry( 'keyconfig' ):add( File.new(
                                                                   'numpad',
                                                                   function()
          obj.keyManager:remove( MoveFreeCameraUpWithArrow,
                                 MoveFreeCameraDownWithArrow,
                                 MoveFreeCameraLeftWithArrow,
                                 MoveFreeCameraRightWithArrow )
          obj.keyManager:add( MoveFreeCameraUpWithKeypad,
                              MoveFreeCameraDownWithKeypad,
                              MoveFreeCameraLeftWithKeypad,
                              MoveFreeCameraRightWithKeypad )
        end ) )
    root:getEntry( 'freeCamera' ):getEntry( 'keyconfig' ):add( File.new(
                                                                   'return',
                                                                   function()
          obj.entryManager:moveParent()
        end ) )
    root:getEntry( 'freeCamera' ):add( File.new( 'return', function()
      obj.entryManager:moveParent()
    end ) )

    root:add( Directory.new( 'state' ) )
    if States then
      for key, state in pairs( States ) do
        root:getEntry( 'state' ):add( File.new( state.name or key, function()
          State.switch( state )
        end ) )
      end
    end
    root:getEntry( 'state' ):add( File.new( 'return', function()
      obj.entryManager:moveParent()
    end ) )

    root:add( File.new( 'quit', function()
      love.event.quit()
    end ) )

    root:add( File.new( 'return', function()
      obj:hideDebugMenu()
    end ) )

    obj.entryManager:selectEntry( root:getEntry( 'toggle' ) )
  end

  -- 操作関数
  do
    obj.keyManager:add( ToggleDebugMenu, SelectEntryUp, SelectEntryDown,
                        SelectEntryExecute, MoveFreeCameraUpWithKeypad,
                        MoveFreeCameraDownWithKeypad,
                        MoveFreeCameraLeftWithKeypad,
                        MoveFreeCameraRightWithKeypad )
  end

  setmetatable( obj, { __index = Debug } )

  return obj
end

return Public
