local Private = {}
local Public = {}

local PlainDebug = require( 'lib.debug' ):getInstance()

local BOUND_DEFAULT = {
  0, 0, love.graphics.getWidth(), love.graphics.getHeight()
}

function Public:getInstance()
  if Private.instance == nil then
    Private.instance = Private.new()
  end

  assert( Private.instance ~= nil,
          'GameInstance:getInstance() is not called yet.' )
  return Private.instance
end

function Private:draw()
  if PlainDebug:isEnabled() then
    love.graphics.setColor( 1, 1, 1, 1 )
    love.graphics.rectangle( 'line', self.bound[1], self.bound[3],
                             self.bound[2] - self.bound[1],
                             self.bound[4] - self.bound[3] )
    PlainDebug:setDebugInfo( 'Camera bound: ' .. self.bound[1] .. ', ' ..
                                 self.bound[2] .. ', ' .. self.bound[3] .. ', ' ..
                                 self.bound[4] )
  end
end

function Private:update( dt )
  local width = love.graphics.getWidth()
  local height = love.graphics.getHeight()

  -- 中心にフォーカスしたい座標の中心地を取得
  local xcenter = self.getX()
  local ycenter = self.getY()

  -- 境界が決まっているならそれに従う
  -- 例えば左境界よりさらに奥はカメラに映してはならないので、
  -- 現在のカメラの左端が左境界より左に来るなら、そのズレの分だけ右に戻す
  -- 現在のカメラの左端：x
  -- 左境界：self.bound[1]
  -- 左端と左境界の差：x - self.bound[1]
  -- 他も同様
  if self.bound then
    if xcenter - width / 2 < self.bound[1] then
      -- xcenter = xcenter + (self.bound[1] - (xcenter - width / 2))
      xcenter = self.bound[1] + width / 2
    elseif xcenter + width / 2 > self.bound[2] then
      -- xcenter = xcenter - (xcenter + width / 2 - self.bound[2])
      xcenter = self.bound[2] - width / 2
    end

    if ycenter - height / 2 < self.bound[3] then
      -- ycenter = ycenter + (self.bound[3] - (ycenter - height / 2))
      ycenter = self.bound[3] + height / 2
    elseif ycenter + height / 2 > self.bound[4] then
      -- ycenter = ycenter - (ycenter + height / 2 - self.bound[4])
      ycenter = self.bound[4] - height / 2
    end
  end

  self.x = xcenter
  self.y = ycenter

  -- PlainDebug:setDebugInfo( 'Camera center: ' .. xcenter .. ', ' .. ycenter )
  -- PlainDebug:setDebugInfo( 'Camera position: ' .. self.x .. ', ' .. self.y )
end

function Private:attach()
  love.graphics.push()
  love.graphics.rotate( -self.rotation )
  love.graphics.scale( 1 / self.scalex, 1 / self.scaley )
  love.graphics.translate( -(self.x - love.graphics.getWidth() / 2),
                           -(self.y - love.graphics.getHeight() / 2) )
end

function Private:detach()
  love.graphics.pop()
end

function Private:setXGetter( xgetter )
  self.getX = xgetter
  self.x = xgetter()
end

function Private:setYGetter( ygetter )
  self.getY = ygetter
  self.y = ygetter()
end

function Private:setLeftBound( left )
  self.bound = self.bound or BOUND_DEFAULT
  self.bound[1] = left
end

function Private:setRightBound( right )
  self.bound = self.bound or BOUND_DEFAULT
  self.bound[2] = right
end

function Private:setTopBound( top )
  self.bound = self.bound or BOUND_DEFAULT
  self.bound[3] = top
end

function Private:setBottomBound( bottom )
  self.bound = self.bound or BOUND_DEFAULT
  self.bound[4] = bottom
end

function Private:getCameraX()
  return self.x
end

function Private:getCameraY()
  return self.y
end

-- 初期化処理
function Private.new()
  local obj = {}

  obj.active = true

  obj.x = 0
  obj.y = 0
  obj.getX = function()
    return 0
  end
  obj.getY = function()
    return 0
  end
  obj.scalex = 1
  obj.scaley = 1
  obj.rotation = 0

  setmetatable( obj, { __index = Private } )

  return obj
end

return Public
