local imageToTable = require 'lib.imageToTable'
local TerrainGenerator = {}

local Public = {}

-- singleton
TerrainGenerator.singleton = nil

function Public:getInstance()
  if TerrainGenerator.singleton == nil then
    TerrainGenerator.singleton = TerrainGenerator:_new()
  end

  assert( TerrainGenerator.singleton ~= nil,
          'TerrainGenerator:getInstance() is not called yet.' )
  return TerrainGenerator.singleton
end

function TerrainGenerator:_new()
  local obj = {}

  setmetatable( obj, { __index = TerrainGenerator } )
  return obj
end

function TerrainGenerator:generate( imageLink, solidSize )
  local terrains = {}
  local data = imageToTable( imageLink )
  local solidSize = solidSize

  for y = 1, #data do
    for x = 1, #data[y] do
      local r, g, b, a = unpack( data[y][x] )
      if r == 0 and g == 0 and b == 0 then
        -- there should be a solid
        local solid = require 'class.solid'
        local x = (x - 1) * solidSize
        local y = (y - 1) * solidSize
        local w = solidSize
        local h = solidSize
        local solid = solid:new( x, y, w, h )
        table.insert( terrains, solid )
      end
    end
  end

  return terrains
end

return Public:getInstance()
