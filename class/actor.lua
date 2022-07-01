local Solid = require 'class.solid'

local Actor = {}

Actor.debugmode = false

local Actors = {}

function Actor:collideWith( solids, dx, dy )
  -- return: collidewith
  local left = self.x + dx
  local right = left + self.w
  local top = self.y + dy
  local bottom = top + self.h

  for _, sol in ipairs( solids ) do
    if right >= sol:left() and left <= sol:right() and top <= sol:bottom() and
        bottom >= sol:top() then

      self.standing = bottom >= sol:top() and bottom <= sol:bottom()
      self.headbutt = top <= sol:bottom() and top >= sol:top()

      return true
    end
  end

  self.standing = false
  self.headbutt = false

  return false
end

function Actor:moveX( amount, onCollide )
  -- Move the actor in the X direction
  -- amount: float, the amount to move
  -- onCollide: function, the function to call when the actor collides with a solid

  self.xRemainder = self.xRemainder + amount
  local move = math.floor( self.xRemainder + 0.5 )

  -- Check if the actor can move
  if move == 0 then
    return
  end

  self.xRemainder = self.xRemainder - move
  local sign = math.floor( move / math.abs( move ) )

  while move ~= 0 do
    if self:collideWith( Solid:getSolids(), sign, 0 ) then
      if onCollide then
        onCollide()
      end
      break
    end

    self.x = self.x + sign
    move = move - sign
  end
end

function Actor:moveY( amount, onCollide )
  -- Move the actor in the X direction
  -- amount: float, the amount to move
  -- onCollide: function, the function to call when the actor collides with a solid

  self.yRemainder = self.yRemainder + amount
  local move = math.floor( self.yRemainder + 0.5 )

  -- Check if the actor can move
  if move == 0 then
    return
  end

  self.yRemainder = self.yRemainder - move
  local sign = math.floor( move / math.abs( move ) )

  while move ~= 0 do
    if self:collideWith( Solid:getSolids(), 0, sign ) then
      if onCollide then
        onCollide()
      end
      break
    end

    self.y = self.y + sign
    move = move - sign
  end
end

function Actor:update( dt )
  -- body
end

function Actor:getPosition()
  return self.x, self.y
end

function Actor:setX( x )
  self.x = x
end

function Actor:setY( y )
  self.y = y
end

function Actor:isStanding()
  return self.standing
end

function Actor:isHeadbutting()
  return self.headbutt
end

function Actor:draw()
  if not Actor.debugmode then
    return
  end
  love.graphics.setColor( 0, 1, 0 )
  love.graphics.rectangle( 'line', self.x, self.y, self.w, self.h )
  love.graphics.rectangle( 'line', self.x + 1, self.y + 1, self.w - 2,
                           self.h - 2 )
  love.graphics.setColor( 1, 1, 1, 1 )
end

function Actor:delete()
  for i, v in ipairs( Actors ) do
    if v == self then
      table.remove( Actors, i )
      break
    end
  end
  self = nil
end

function Actor:new( x, y, w, h )
  local obj = {}
  obj.x = x
  obj.y = y
  obj.w = w
  obj.h = h

  obj.xRemainder = 0
  obj.yRemainder = 0
  obj.standing = false

  setmetatable( obj, { __index = Actor } )

  table.insert( Actors, obj )

  return obj
end

return Actor
