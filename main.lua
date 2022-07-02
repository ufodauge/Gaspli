-- modules
State = require 'lib.hump.gamestate'
local Actor = require 'class.actor'
local Solid = require 'class.solid'

States = {}
States.dummy = require 'state.dummy'
States.testMap = require 'state.testMap'

-- PlainDebug
local PlainDebug = require( 'lib.debug' ):getInstance()

function love.load()
  PlainDebug:Enable()
  -- Actor.debugmode = true
  -- Solid.debugmode = true

  local handlers = love.handlers
  table.insert( handlers, 'update' )
  State.registerEvents( handlers )
  State.switch( States.testMap )
end

function love.update( dt )
  PlainDebug:update( dt )
end

function love.draw()
  PlainDebug:attachFreeCamera()
  State.current():draw()
  PlainDebug:detachFreeCamera()

  love.graphics.setColor( 1, 1, 1, 1 )
  PlainDebug:draw()
end

function love.keypressed( key, scancode, isrepeat )
  if key == 'escape' then
    love.event.quit()
  end
end
