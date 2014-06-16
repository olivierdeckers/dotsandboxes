class Tile
  attr_accessor :top, :bottom, :left, :right, :owner, :x, :y

  def initialize(x, y)
    @x = x
    @y = y

    @top = false
    @bottom = false
    @left = false
    @right = false
    @owner = nil
  end

  def captured?
    @top && @bottom && @left && @right
  end

end