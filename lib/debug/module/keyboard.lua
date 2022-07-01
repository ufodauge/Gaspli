local Keyboard = {}

local keyrepeattypes = { 'repeat' }
local triggertypes = { 'pressed', 'released' }

local meta = {}
function meta:has( key )
    for i, k in ipairs( self ) do
        if k == key then
            return true
        end
    end
    return false
end


setmetatable( keyrepeattypes, { __index = meta } )
setmetatable( triggertypes, { __index = meta } )

function Keyboard:update( dt )
    if love.keyboard.isDown( self.key ) then
        self.pressedframes = self.pressedframes <= 0 and 1 or math.min( self.pressedframes + 1, 128 )
    else
        self.pressedframes = self.pressedframes > 0 and 0 or math.max( self.pressedframes - 1, -127 )
    end

    -- 前提キーがあるならその押下判定を、ないなら無条件で true
    local premisekeyCondition = self.premisekey and love.keyboard.isDown( self.premisekey ) or true
    local triggertypeCondition = (self.trigger == 'pressed' and self.pressedframes > 0) or (self.trigger == 'released' and self.pressedframes <= 0)
    local keyrepeattypeCondition = self.keyrepeat and (self.pressedframes >= 1 or self.pressedframes <= 0) or
                                       (self.pressedframes == 1 or self.pressedframes == 0)

    if premisekeyCondition and triggertypeCondition and keyrepeattypeCondition then
        self.func( dt )
    end

end


function Keyboard:getKey()
    return self.key
end


function Keyboard.new( key, func, ... )
    local args = { ... }

    local obj = {}

    obj.pressedframes = 0

    obj.key = key
    obj.func = func

    obj.premisekey = nil
    obj.keyrepeat = false
    obj.trigger = 'pressed'
    for index, value in ipairs( args ) do
        if keyrepeattypes:has( value ) then
            obj.keyrepeat = true
        elseif triggertypes:has( value ) then
            obj.trigger = value
        elseif type( value ) == 'string' then
            obj.premisekey = value
        end
    end

    setmetatable( obj, { __index = Keyboard } )

    return obj
end


return Keyboard
