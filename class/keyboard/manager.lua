local KeyManager = {}

-- key:     入力するキー
-- func:    入力されたときに呼び出される関数
-- (prem:   前提となるキー)
-- (rep:    "repeat")
-- (act:    "pressed" or "released")
function KeyManager:add( ... )
    local keyboards = { ... }
    for i, keyboard in ipairs( keyboards ) do
        table.insert( self.keys, keyboard )
    end
end

function KeyManager:remove( ... )
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

function KeyManager:update( dt )
    for i, key in ipairs( self.keys ) do
        key:update( dt )
    end
end

-- 初期化処理
function KeyManager:new()

    local obj = {}

    obj.keys = {}

    setmetatable( obj, {
        __index = KeyManager,
        __tostring = function()
            return 'KeyManager'
        end
    } )

    return obj
end

return KeyManager
