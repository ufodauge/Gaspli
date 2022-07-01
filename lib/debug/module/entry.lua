local path = ...
path = path:gsub( 'module%..+', '' )

local Entry = {}

local printOutlined = require( path .. 'module.utils' ).printOutlined

function Entry:getName()
    return self.name
end


function Entry:getPath()
    return self.path
end


function Entry:remove()
    self = nil
end


function Entry:Prev()
    if self.prev then
        return self.prev
    else
        return self
    end
end


function Entry:Next()
    if self.next then
        return self.next
    else
        return self
    end
end


function Entry:getIndex()
    return self.index
end


function Entry:print( x, y )
    printOutlined( self.name, x, y )
end


function Entry:execute()
    -- none
end


function Entry:getParent()
    return self.parent
end


function Entry.new( name )
    local obj = {}

    obj.name = name

    obj.prev = nil
    obj.next = nil
    obj.index = 1
    obj.parent = nil

    setmetatable( obj, { __index = Entry } )

    return obj
end


return Entry
