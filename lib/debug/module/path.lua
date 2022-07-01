local Path = {}

function Path.new( path )
    local obj = {}

    obj.path = path

    setmetatable( obj, { __index = Path } )

    return obj
end


