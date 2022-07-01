local Keyboard = {}

local KEY_PRESSED_MAX_FRAME = 600
local KEY_PRESSED_MIN_FRAME = -600

-- キー操作の種類: 
function Keyboard:update( dt )
  --  押下時, 押下から n フレーム後, 押下のち離上時, 離上から n フレーム後
  -- -127: 無操作
  -- -126 ~ -1: 離上
  -- 0: 押下のち離上
  -- 1 ~ 128: 押下
  if love.keyboard.isDown( self.key ) then
    self.pressedframes = self.pressedframes <= 0 and 1 or
                             math.min( self.pressedframes + 1,
                                       KEY_PRESSED_MAX_FRAME )
  else
    self.pressedframes = self.pressedframes > 0 and 0 or
                             math.max( self.pressedframes - 1,
                                       KEY_PRESSED_MIN_FRAME )
  end

  -- 前提キーがあるならその押下判定を、ないなら無条件で true
  local premisekeyCondition = self.premisekey and
                                  love.keyboard.isDown( self.premisekey ) or
                                  true

  if premisekeyCondition then
    self.func( dt, self.pressedframes )
  end
end

function Keyboard:new( key, func, premisekey )
  local obj = {}

  obj.pressedframes = KEY_PRESSED_MIN_FRAME

  obj.key = key
  obj.func = func

  obj.premisekey = premisekey or nil

  setmetatable( obj, {
    __index = Keyboard,
    __tostring = function()
      return 'Keyboard'
    end
  } )

  return obj
end

return Keyboard
