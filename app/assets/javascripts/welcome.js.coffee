
size = undefined
ctx = undefined
tileWidth = undefined
board = []
my_turn = false
dispatcher = undefined
game_id = undefined
player = undefined
other_player = undefined


render = () ->
  for row,y in board
    for tile,x in row
      if tile.owner == true
        ctx.fillStyle = "blue"
        ctx.fillRect(x * tileWidth+5, y * tileWidth+5, tileWidth, tileWidth)
      else if tile.owner == false
        ctx.fillStyle = "red"
        ctx.fillRect(x * tileWidth+5, y * tileWidth+5, tileWidth, tileWidth)
      ctx.fillStyle = "black"

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


fillTile = (x, y, player) ->
  tile = board[y][x]
  if tile.top && tile.bottom && tile.left && tile.right
    tile.owner = player
    return true
  return false


updateBoard = (x, y, dir, player) ->
  filledTile = false
  if dir == "left"
    board[y][x].left = true
    if x > 0
      board[y][x-1].right = true
      filledTile = filledTile || fillTile(x-1, y, player)
  else if dir == "top"
    board[y][x].top = true
    if y > 0
      board[y-1][x].bottom = true
      filledTile = filledTile || fillTile(x, y-1, player)
  else if dir == "bottom"
    board[y][x].bottom = true
    if y < size-1
      board[y+1][x].top = true
      filledTile = filledTile || fillTile(x, y+1, player)
  else if dir == "right"
    board[y][x].right = true
    if x < size-1
      board[y][x+1].left = true
      filledTile = filledTile || fillTile(x+1, y, player)
  filledTile = filledTile || fillTile(x, y, player)

  render()
  return filledTile


click = (event) ->
  if !my_turn
    return

  x = event.offsetX / tileWidth
  y = event.offsetY / tileWidth
  tileX = Math.floor(x)
  tileY = Math.floor(y)

  if tileX < 0 || tileY < 0 || tileX >= size || tileY >= size
    return #todo use neighbouring position for better UX

  direction = undefined
  if x % 1 < 0.2
    direction = "left"
  else if y % 1 < 0.2
    direction = "top"
  else if y % 1 > 0.8
    direction = "bottom"
  else if x % 1 > 0.8
    direction = "right"

  if direction == undefined
    return

  if board[tileY][tileX][direction] == true
    return # todo user feedback

  my_turn = false
  filledTile = updateBoard(tileX, tileY, direction, true)
  if filledTile == true
    my_turn = true

  dispatcher.trigger('move', {game_id: game_id, player: player, x: tileX, y: tileY, direction: direction}, (->), (msg) ->
    console.error(msg)
  )

ready = () ->
  canvas = $('canvas')[0]
  $('canvas').click(click)
  ctx = canvas.getContext("2d")

  size = window.size
  tileWidth = 400 / size
  game_id = window.game_id
  player = window.player

  for _ in [1..size]
    row = []
    for _ in [1..size]
      row.push({top: false, right: false, bottom: false, left: false, owner: undefined})
    board.push(row)

  render()

  dispatcher = new WebSocketRails('localhost:3000/websocket')

  dispatcher.on_open = (data) ->
    console.log('Connection has been established: ', data)

    channel = dispatcher.subscribe(game_id)

    channel.bind('connected', (data) ->
      console.log("connected: ", data)
      if data.player != player
        connected(data.player, data.first_player)
    )
    channel.bind('moved', (data) ->
      if data.player != player
        console.log("received move: ", data)
        moved(data.x, data.y, data.direction)
    )

    dispatcher.trigger('connect', {game_id: game_id, size: size, player: player}, (data) ->
      console.log('connected')
    , (msg) ->
      console.error(msg)
    )


connected = (player, first_player) ->
  other_player = player
  if first_player == false
    my_turn = true


moved = (x, y, direction) ->
  filledTile = updateBoard(x, y, direction, false)
  if !filledTile
    my_turn = true


$(document).ready(ready)