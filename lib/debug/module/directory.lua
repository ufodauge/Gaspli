local path = ...
path = path:gsub( 'module%..+', '' )

local Directory = {}

local Entry = require( path .. 'module.entry' )
setmetatable( Directory, { __index = Entry } )

function Directory:add( entry )
    table.insert( self.entries, entry )

    if self.first == nil then
        self.first = entry
    end

    if self.last == nil then
        self.last = entry
    end

    entry.prev = self.last
    entry.next = nil

    self.last.next = entry
    self.last = entry

    entry.index = #self.entries

    entry.parent = self

    return self
end


function Directory:remove()
    for i, entry in ipairs( self.entries ) do
        entry:remove()
    end

    self = nil
end


function Directory:getEntry( name )
    if name == nil then
        return self.first
    end

    for i, entry in ipairs( self.entries ) do
        if entry:getName() == name then
            return entry
        end
    end
end


function Directory:getEntries()
    return self.entries
end


function Directory:getFirst()
    return self.first
end


function Directory:getLast()
    return self.last
end


function Directory:execute()
    return self
end


function Directory.new( name )
    local obj = {}
    obj = Entry.new( name )

    obj.entries = {}

    obj.first = nil
    obj.last = nil

    obj.parent = nil
    obj.child = nil

    setmetatable( obj, { __index = Directory } )

    return obj
end


return Directory
