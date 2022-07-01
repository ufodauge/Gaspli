local path = ...
path = path:gsub( 'module%..+', '' )

local printOutlined = require( path .. 'module.utils' ).printOutlined

local Private = {}
local Public = {}

function Public:getInstance()
    if Private.instance == nil then
        Private.instance = Private.new()
    end

    assert( Private.instance ~= nil, 'GameInstance:getInstance() is not called yet.' )
    return Private.instance
end


function Private:update( dt )
    if self.counting then
        self.frames = self.frames + 1
        self.times = self.times + dt

        if self:getFrame() % 60 == 0 then
            self.fps = (self.frames - self.framesbefore20frame) / (self.times - self.timesbefore20frames)
            self.framesbefore20frame = self.frames
            self.timesbefore20frames = self.times
        end
    end
end


function Private:stop()
    self.counting = false
end


function Private:start()
    self.counting = true
end


function Private:getFrame()
    return self.frames
end


function Private:getFps()
    return self.fps
end


function Private:reset()
    self.frames = 0
    self.framesbefore20frame = 0
end


function Private:toggle()
    self.active = not self.active
end


function Private:getActive()
    return self.active
end


function Private:printFrames( x, y )
    if self:getActive() then
        printOutlined( ('Frames: %.0f'):format( self:getFrame() ), x, y )
    end
end


function Private:printFps( x, y )
    if self:getActive() then
        printOutlined( ('FPS: %.2f'):format( self:getFps() ), x, y )
    end
end


-- 初期化処理
function Private.new()
    local obj = {}

    obj.frames = 0
    obj.times = 0
    obj.framesbefore20frame = 0
    obj.timesbefore20frames = 0
    obj.fps = 0
    obj.counting = true
    obj.active = true

    setmetatable( obj, { __index = Private } )

    return obj
end


return Public
