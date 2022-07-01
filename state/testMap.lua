local Player = require 'class.player'
local Camera = require( 'class.camera' ):getInstance()

local TerrainGenerator = require 'class.terrainGenerator'
assert( TerrainGenerator ~= nil )

local JSON = require 'lib.json'
local data, errormsg = JSON.decode( love.filesystem.read( 'config.json' ) )
if not data then
  error( errormsg )
end

local background = love.graphics.newImage( data.mapData[1].backgroudImage )
local texture = love.graphics.newImage( data.mapData[1].textureImage )

background:setFilter( 'nearest', 'nearest' )
texture:setFilter( 'nearest', 'nearest' )

local testMap = {}

function testMap:init()
end

function testMap:enter()
  -- Create a new player
  -- x, y, w, h
  self.player = Player:new( data.mapData[1].player.x, data.mapData[1].player.y,
                            data.mapData[1].solidSize, data.mapData[1].solidSize )

  -- Create new solids
  -- terrainImageLink, solidSize
  self.solids = TerrainGenerator:generate( data.mapData[1].terrainImage,
                                           data.mapData[1].solidSize )

  -- Create a new Camera
  -- X delegate, Y delegate
  Camera:setXGetter( function()
    return self.player:getX() + data.mapData[1].solidSize / 2
  end )
  Camera:setYGetter( function()
    return self.player:getY() + data.mapData[1].solidSize / 2
  end )

  Camera:setLeftBound( data.mapData[1].bound.left )
  Camera:setRightBound( data.mapData[1].bound.right )
  Camera:setTopBound( data.mapData[1].bound.top )
  Camera:setBottomBound( data.mapData[1].bound.bottom )
end

function testMap:update( dt )
  Camera:update( dt )
  self.player:update( dt )
  if self.player:getY() > data.mapData[1].bound.bottom then
    self.player:setX( data.mapData[1].player.x )
    self.player:setY( data.mapData[1].player.y )
  end
  if self.player:getX() > data.mapData[1].bound.right -
      data.mapData[1].solidSize * 3 then
    self.player:setX( data.mapData[1].player.x )
    self.player:setY( data.mapData[1].player.y )
  end
  for i, sol in ipairs( self.solids ) do
    sol:update( dt )
  end
end

function testMap:draw()
  Camera:attach()

  -- repeat draw background
  -- 適当すぎる
  love.graphics.push()
  love.graphics.translate(
      (Camera:getCameraX() - love.graphics.getWidth() / 2) / 1.4, 0 )
  love.graphics.setColor( 0.6, 0.6, 0.6, 1 )
  for i = 0, 100 do
    for j = 0, 2 do
      love.graphics.draw( background, i * background:getWidth(),
                          j * background:getHeight() )
    end
  end
  love.graphics.setColor( 1, 1, 1, 1 )
  love.graphics.pop()

  for i, sol in ipairs( self.solids ) do
    sol:draw()
  end
  love.graphics.draw( texture, 0, 0, 0, data.mapData[1].solidSize )
  self.player:draw()
  Camera:draw()
  Camera:detach()
end

function testMap:leave()
end

return testMap
