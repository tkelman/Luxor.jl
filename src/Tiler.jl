"""
A Tiler is an iterator that, for each iteration, returns a tuple of:

- the `x`/`y` point of the center of each tile in a set of tiles that divide up a rectangular space such as a page into rows and columns (relative to current 0/0)

- the number of the tile

    tiles = Tiler(areawidth, areaheight, nrows, ncols, margin=20)

where `width`, `height` is the dimensions of the area to be tiled, `nrows`/`ncols`
is the number of rows and columns required, and `margin` is applied to all four
edges of the area before the function calculates the tile sizes required.

    tiles = Tiler(1000, 800, 4, 5, margin=20)
    for (pos, n) in tiles
    # the point pos is the center of the tile
    end

You can access the calculated tile width and height like this:

    tiles = Tiler(1000, 800, 4, 5, margin=20)
    for (pos, n) in tiles
      ellipse(pos.x, pos.y, tiles.tilewidth, tiles.tileheight, :fill)
    end
"""
type Tiler
  width::Real
  height::Real
  tilewidth::Real
  tileheight::Real
  nrows::Int
  ncols::Int
  margin::Real
  function Tiler(areawidth, areaheight, nrows::Int, ncols::Int; margin=10)
      tilewidth  = (areawidth - 2margin)/ncols
      tileheight = (areaheight - 2margin)/nrows
      new(areawidth, areaheight, tilewidth, tileheight, nrows, ncols, margin)
  end
end

function Base.start(pt::Tiler)
# return the initial state
  x = -(pt.width/2)  + pt.margin + (pt.tilewidth/2)
  y = -(pt.height/2) + pt.margin + (pt.tileheight/2)
  return (Point(x, y), 1)
end

function Base.next(pt::Tiler, state)
  # Returns the item and the next state
  # state[1] is the Point
  x = state[1].x
  y = state[1].y
  # state[2] is the tilenumber
  tilenumber = state[2]
  x1 = x + pt.tilewidth
  y1 = y
  if x1 > (pt.width/2) - pt.margin
    y1 += pt.tileheight
    x1 = -(pt.width/2) + pt.margin + (pt.tilewidth/2)
  end
  return ((Point(x, y), tilenumber), (Point(x1, y1), tilenumber + 1))
end

function Base.done(pt::Tiler, state)
  # Tests if there are any items remaining
  state[2] > (pt.nrows * pt.ncols)
end
