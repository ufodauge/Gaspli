local Private = {}
local Public = {}

function Public:getInstance()
    if Private.instance == nil then
        Private.instance = Private.new()
    end

    assert( Private.instance ~= nil, 'GameInstance:getInstance() is not called yet.' )
    return Private.instance
end


-- key:     入力するキー
-- func:    入力されたときに呼び出される関数
-- (prem:   前提となるキー)
-- (rep:    "repeat")
-- (act:    "pressed" or "released")
function Private:add( ... )
    local keyboards = { ... }
    for i, keyboard in ipairs( keyboards ) do
        table.insert( self.keys, keyboard )
    end
end


function Private:remove( ... )
    local keyboards = { ... }
    for i, keyboard in ipairs( keyboards ) do
        for j, key in ipairs( self.keys ) do
            if key == keyboard then
                table.remove( self.keys, j )
                break
            end
        end
    end
end


function Private:update( dt )
    for i, key in ipairs( self.keys ) do
        key:update( dt )
    end
end


-- 初期化処理
function Private.new()
    local obj = {}

    obj.keys = {}

    setmetatable( obj, { __index = Private } )

    return obj
end


return Public
