local path = ...
path = path:gsub( 'module%..+', '' )

local Observer = require( path .. 'module.observer' )
local printOutlined = require( path .. 'module.utils' ).printOutlined

local Cursor = {}
local Public = {}

local instance = nil

function Public:getInstance()
    if instance == nil then
        instance = Cursor.new()
    end

    assert( instance ~= nil, 'Cursor:getInstance() is not called yet.' )
    return instance
end


function Cursor:print( x, y, textheight )
    printOutlined( '>', x, y + (self.currentIndex - 1) * textheight )
end


function Cursor:getObserver()
    return self.observer
end


function Cursor.new()
    local obj = {}

    obj.currentIndex = 1

    obj.observer = Observer.new( function( entryManager )
        obj.currentIndex = entryManager:getCurrent():getIndex()
    end
 )

    setmetatable( obj, { __index = Cursor } )

    return obj
end


return Public
