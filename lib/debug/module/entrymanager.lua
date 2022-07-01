local EntryManager = {}

function EntryManager:rootDirectory()
    return self.root
end


function EntryManager:selectPrevEntry()
    if self.selected then
        self.selected = self.selected:Prev()
    end
    self:notifyObservers()
end


function EntryManager:selectNextEntry()
    if self.selected then
        self.selected = self.selected:Next()
    end
    self:notifyObservers()
end


function EntryManager:selectEntry( entry )
    self.selected = entry
    self:notifyObservers()
end


function EntryManager:getCurrent()
    return self.selected
end


function EntryManager:moveParent()
    if self.selected then
        self.selected = self.selected:getParent()
        self.current = self.selected:getParent()
    end
    self:notifyObservers()
end


function EntryManager:execute()
    self.current = self.selected:execute() or self.current
    self.selected = (self.current == self.selected) and self.current:getFirst() or self.selected
    self:notifyObservers()
end


function EntryManager:addObserver( observer )
    table.insert( self.observers, observer )
end


function EntryManager:removeObserver( observer )
    for i, v in ipairs( self.observers ) do
        if v == observer then
            table.remove( self.observers, i )
            return
        end
    end
end


function EntryManager:notifyObservers()
    for i, observer in ipairs( self.observers ) do
        observer:update( self )
    end
end


function EntryManager:print( x, y, textheight )
    for i, entry in ipairs( self.current:getEntries() ) do
        entry:print( x, y + (i - 1) * textheight )
    end
end


function EntryManager.new( directory )
    local obj = {}

    obj.root = directory
    obj.current = directory
    obj.selected = nil
    obj.observers = {}

    setmetatable( obj, { __index = EntryManager } )

    return obj
end


return EntryManager
