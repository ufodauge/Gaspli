local path = ...
path = path:gsub( 'module%..+', '' )

local printOutlined = require( path .. 'module.utils' ).printOutlined

-- フリーカメラ
local Private = {}
local Public = {}

function Public:getInstance()
    if Private.instance == nil then
        Private.instance = Private.new()
    end

    assert( Private.instance ~= nil, 'GameInstance:getInstance() is not called yet.' )
    return Private.instance
end


local keyconfigSet = {
    wasd = { { key = 'w' }, { key = 's' }, { key = 'd' }, { key = 'a' } },
    directionKey = { { key = 'up' }, { key = 'down' }, { key = 'right' }, { key = 'left' } },
    numpad = { { key = 'kp8' }, { key = 'kp2' }, { key = 'kp6' }, { key = 'kp4' } }
}

function Private:update( dt )
end


function Private:getActive()
    return self.active
end


function Private:getPosition()
    return self.x, self.y
end


function Private:setPosition( x, y )
    self.x, self.y = x, y
end


function Private:printCenterPosition( x, y )
    if self:getActive() then
        local px, py = self:getPosition()

        printOutlined( string.format( 'x: %.2f, y: %.2f', px, py ), x, y )
    end
end


function Private:attach()
    love.graphics.push()
    love.graphics.rotate( -self.rotation )
    love.graphics.scale( 1 / self.scalex, 1 / self.scaley )
    love.graphics.translate( -self.x, -self.y )
end


function Private:detach()
    love.graphics.pop()
end


function Private:toggle()
    self.active = not self.active
end


function Private:move( x, y )
    self.x = self.x + x
    self.y = self.y + y
end


-- 初期化処理
function Private.new()
    local obj = {}

    obj.active = true

    obj.x = 0
    obj.y = 0
    obj.scalex = 1
    obj.scaley = 1
    obj.rotation = 0

    setmetatable( obj, { __index = Private } )

    return obj
end


return Public
