class Tile
  attr_accessor :top, :bottom, :left, :right

  def initialize
    @top = false
    @bottom = false
    @left = false
    @right = false
  end

  def captured?
    @top && @bottom && @left && @right
  end

end