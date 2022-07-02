local Player = {}

local PlainDebug = require( 'lib.debug' ):getInstance()

local Actor = require 'class.actor'
local KeyManager = require 'class.keyboard.manager'
local Keyboard = require 'class.keyboard'

local JSON = require 'lib.json'
local data, errormsg = JSON.decode( love.filesystem.read( 'config.json' ) )
if not data then
  error( errormsg )
end

local sprites = {}
local image = love.graphics.newImage( data.player.sprite.image )
for name, spritedata in pairs( data.player.sprite.frames ) do
  sprites[name] = love.graphics.newQuad( spritedata.x, spritedata.y,
                                         spritedata.w, spritedata.h,
                                         image:getWidth(), image:getHeight() )
end

function Player:draw()
  if self.direction > 0 then
    love.graphics.draw( image, sprites.idle, self.x, self.y )
  else
    love.graphics.draw( image, sprites.idle, self.x + data.mapData[1].solidSize,
                        self.y, 0, -1, 1 )
  end
end

function Player:update( dt )
  self._keyManager:update( dt )
  if self.vx ~= 0 then
    self.actor:moveX( self.vx, function()
      self.vx = 0
    end )
  end
  if self.vx > 0.5 then
    self.direction = 1
  elseif self.vx < -0.5 then
    self.direction = -1
  end

  if self.vy ~= 0 then
    self.actor:moveY( self.vy, function()
      self.vy = 0
    end )
  end

  self.vy = self.vy + 1
  if self.vy >= data.player.maxSpeedVert then
    -- 落下速度調節
    self.vy = data.player.maxSpeedVert
  end

  -- sync with Actor
  self.x, self.y = self.actor:getPosition()
end

function Player:delete()
end

function Player:getX()
  return self.x
end

function Player:getY()
  return self.y
end

function Player:setX( x )
  self.actor:setX( x )
end

function Player:setY( y )
  self.actor:setY( y )
end

local nidotomentesurumonkaframe = 0

function Player:new( x, y, w, h )
  local obj = {}
  obj.x = x
  obj.y = y
  obj.w = w
  obj.h = h

  obj.actor = Actor:new( x, y, w, h )
  obj.vx, obj.vy = 0, 0
  obj.jumpable = obj.actor:isStanding()
  obj.jumpframe = 0
  obj.accel = data.player.accel
  obj.maxSpeed = data.player.maxSpeed
  obj.direction = 1

  local keyA = Keyboard:new( 'a', function( dt, f )
    local click = love.mouse.isDown( 1 )
    local mx, my = love.mouse.getPosition()
    if click and mx < love.graphics.getWidth() / 2 then
      f = 1
    end

    local rate = dt * data.system.expectFPS
    if f > 0 then
      if obj.vx - obj.accel * rate < -obj.maxSpeed then
        -- 加速しすぎる場合
        obj.vx = -obj.maxSpeed
      else
        obj.vx = obj.vx - obj.accel * rate
      end
    else
      if obj.vx >= 0 then
        -- do nothing
      elseif obj.vx + obj.accel * rate > 0 then
        obj.vx = 0
      else
        obj.vx = obj.vx + obj.accel * rate
      end
    end
  end )
  local keyD = Keyboard:new( 'd', function( dt, f )
    local click = love.mouse.isDown( 1 )
    local mx, my = love.mouse.getPosition()
    if click and mx > love.graphics.getWidth() / 2 then
      f = 1
    end

    local rate = dt * data.system.expectFPS
    PlainDebug:setDebugInfo( tostring( obj.accel ) )
    if f > 0 then
      if obj.vx + obj.accel * rate > obj.maxSpeed then
        -- 加速しすぎる場合
        obj.vx = obj.maxSpeed
      else
        obj.vx = obj.vx + obj.accel * rate
      end
    else
      -- 減速処理
      if obj.vx <= 0 then
        -- do nothing
      elseif obj.vx - obj.accel * rate < 0 then
        obj.vx = 0
      else
        obj.vx = obj.vx - obj.accel * rate
      end
    end
  end )
  local keyK = Keyboard:new( 'k', function( dt, f )
    local click = love.mouse.isDown( 1 )
    local mx, my = love.mouse.getPosition()
    if click then
      f = 1
    end

    if f > 0 then
      obj.maxSpeed = data.player.maxSpeedDash
    else
      obj.maxSpeed = data.player.maxSpeed
    end
  end )
  local keyJ = Keyboard:new( 'j', function( dt, f )
    local standing = obj.actor:isStanding()
    local headbutting = obj.actor:isHeadbutting()

    local click = love.mouse.isDown( 1 )
    local mx, my = love.mouse.getPosition()
    if click and my < love.graphics.getHeight() / 2 then
      nidotomentesurumonkaframe = nidotomentesurumonkaframe <= 0 and 1 or
                                      math.min( nidotomentesurumonkaframe + 1,
                                                600 )
      f = nidotomentesurumonkaframe
    else
      nidotomentesurumonkaframe = nidotomentesurumonkaframe > 0 and 0 or
                                      math.max( nidotomentesurumonkaframe - 1,
                                                -600 )
    end

    if ((f == 1 and standing) or (f > 1 and not standing)) and obj.jumpframe > 0 then
      obj.jumpframe = obj.jumpframe - 1
      if obj.jumpframe > 0 then
        obj.vy = -data.player.jumpforce
      end
      if headbutting then
        obj.jumpframe = 0
      end
    elseif ((f == 1 and not standing) or (f > 1 and standing)) and obj.jumpframe <=
        0 then
      obj.jumpframe = 0
    elseif (f <= 0 and standing) and obj.jumpframe <= 0 then
      obj.jumpframe = data.player.jumpframe
    elseif (f <= 0 and not standing) and obj.jumpframe > 0 then
      obj.jumpframe = 0
    end
  end )

  obj._keyManager = KeyManager:new()
  obj._keyManager:add( keyA, keyD, keyJ, keyK )

  setmetatable( obj, { __index = Player } )
  return obj
end

return Player
