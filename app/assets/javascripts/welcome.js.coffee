
size = undefined
ctx = undefined
tileWidth = undefined
board = []


render = () ->
  ctx.fillStyle = "black"
  for row,y in board
    for tile,x in row
      ctx.fillRect(x * tileWidth, y * tileWidth, 10, 10)
      ctx.fillRect((x+1) * tileWidth, y * tileWidth, 10, 10)
      ctx.fillRect(x * tileWidth, (y+1) * tileWidth, 10, 10)
      ctx.fillRect((x+1) * tileWidth, (y+1) * tileWidth, 10, 10)

      if tile.left
        ctx.fillRect(x * tileWidth+2, y * tileWidth, 6, tileWidth)
      if tile.right
        ctx.fillRect((x+1) * tileWidth+2, y * tileWidth, 6, tileWidth)
      if tile.top
        ctx.fillRect(x * tileWidth, y * tileWidth+2, tileWidth, 6)
      if tile.bottom
        ctx.fillRect(x * tileWidth, (y+1) * tileWidth+2, tileWidth, 6)


click = (event) ->
  x = event.offsetX / tileWidth
  y = event.offsetY / tileWidth
  tileX = Math.floor(x)
  tileY = Math.floor(y)
  if x % 1 < 0.2
    board[tileY][tileX].left = true
    board[tileY][tileX-1].right = true if tileX > 0
  else if y % 1 < 0.2
    board[tileY][tileX].top = true
    board[tileY-1][tileX].bottom = true if tileY > 0
  else if y % 1 > 0.8
    board[tileY][tileX].bottom = true
    board[tileY+1][tileX].top = true if tileY < size-1
  else if x % 1 > 0.8
    board[tileY][tileX].right = true
    board[tileY][tileX+1].left = true if tileX < size-1

  render()

ready = () ->
  canvas = $('canvas')[0]
  $('canvas').click(click)
  ctx = canvas.getContext("2d")

  size = window.size
  tileWidth = 400 / size

  for i in [1..size]
    row = []
    for j in [1..size]
      row.push({top: false, right: false, bottom: false, left: false})
    board.push(row)

  render()


$(document).ready(ready)