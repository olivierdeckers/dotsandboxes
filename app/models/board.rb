class Board
  attr_accessor :tiles

  def initialize(size)
    @size = size
    @tiles = []
    (0...size).each do |y|
      row = []
      (0...size).each do |x|
        row << Tile.new(x, y)
      end
      @tiles << row
    end
  end

  def fill_tile(x, y, player)
    tile = @tiles[y][x]
    if tile.captured?
      tile.owner = player
    end
  end


  def move(x, y, dir, player)
    if dir == 'left'
      @tiles[y][x].left = true
      if x > 0
        @tiles[y][x-1].right = true
        fill_tile(x-1, y, player)
      end
    elsif dir == 'top'
      @tiles[y][x].top = true
      if y > 0
        @tiles[y-1][x].bottom = true
        fill_tile(x, y-1, player)
      end
    elsif dir == 'bottom'
      @tiles[y][x].bottom = true
      if y < @size-1
        @tiles[y+1][x].top = true
        fill_tile(x, y+1, player)
      end
    elsif dir == 'right'
      @tiles[y][x].right = true
      if x < @size-1
        @tiles[y][x+1].left = true
        fill_tile(x+1, y, player)
      end
    end

    fill_tile(x, y, player)
  end

end