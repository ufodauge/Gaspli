local Solid = {}

Solid.debugmode = false

local Solids = {}

function Solid:draw()
  if not Solid.debugmode then
    return
  end

  love.graphics.setColor( 1, 0, 0 )
  love.graphics.rectangle( 'line', self.x, self.y, self.w, self.h )
  love.graphics.rectangle( 'line', self.x + 1, self.y + 1, self.w - 2,
                           self.h - 2 )
  love.graphics.setColor( 1, 1, 1, 1 )
end

function Solid:update( dt )
end

function Solid:delete()
  for i, v in ipairs( Solids ) do
    if v == self then
      table.remove( Solids, i )
      break
    end
  end
  self = nil
end

function Solid:left()
  return self.x
end

function Solid:right()
  return self.x + self.w
end

function Solid:top()
  return self.y
end

function Solid:bottom()
  return self.y + self.h
end

-- class method
-- Method for checking if there exists a solid colliding with the given point.
function Solid:getSolids()
  return Solids
end

function Solid:new( x, y, w, h )
  local obj = {}
  obj.x = x
  obj.y = y
  obj.w = w
  obj.h = h

  setmetatable( obj, { __index = Solid } )
  table.insert( Solids, obj )
  return obj
end

return Solid
