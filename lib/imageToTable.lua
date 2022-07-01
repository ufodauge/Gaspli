return function( imgPath )
  assert( imgPath, 'imgPath is null' )

  local imgData = love.image.newImageData( imgPath )

  local tbl = {}

  for y = 1, imgData:getHeight() do
    tbl[y] = tbl[y] or {}
    for x = 1, imgData:getWidth() do
      tbl[y][x] = { imgData:getPixel( x - 1, y - 1 ) }
    end
  end

  return tbl
end
