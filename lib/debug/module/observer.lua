local Observer = {}

function Observer:update( ... )
    self.func( ... )
end


function Observer.new( func )
    local obj = {}

    obj.func = func

    setmetatable( obj, { __index = Observer } )

    return obj
end


return Observer
