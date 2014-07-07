Direction =
  Up: 0
  Down: 1
  Left: 2
  Right: 3

State =
  Run: 0
  Read: 1

class BefungeDelegate
  getNum: -> 0
  getChar: -> "@"
  putNum: (n) -> console.log n
  putChar: (c) -> console.log c
  pushStack: (n) ->
  popStack: ->
  readCode: (y, x, c) ->
  writeCode: (y, x, from, to) ->

class Befunge
  constructor: (code, @delegate = new BefungeDelegate) ->
    @program = (line.split "" for line in code.split "\n")
    @size =
      x: Math.max (line.length for line in @program)...
      y: @program.length

    throw "Empty program!" if @size.x == 0 or @size.y == 0

    @point = x: 0, y: 0
    @stack = []
    @direction = Direction.Right
    @state = State.Run

    for line in @program
      k = @size.x - line.length
      line.length = @size.x
      for i in [@size.x - k ... @size.x]
        line[i] = " "

  execute: (step = Number.MAX_VALUE) ->
    for i in [0..step]
      break if @doStep()

  push: (n) ->
    @stack.push n
    @delegate.pushStack n

  pop: ->
    if @stack.length == 0
      0
    else
      @delegate.popStack()
      @stack.pop()

  movePoint: ->
    switch @direction
      when Direction.Left
        @point.x -= 1
        @point.x = @size.x - 1 if @point.x < 0
      when Direction.Right
        @point.x += 1
        @point.x = 0 if @point.x >= @size.x
      when Direction.Up
        @point.y -= 1
        @point.y = @size.y - 1 if @point.y < 0
      when Direction.Down
        @point.y += 1
        @point.y = 0 if @point.y >= @size.y

  doStep: ->
    c = @program[@point.y][@point.x]
    switch @state
      when State.Read
        if c == '"'
          @state = State.Run
        else
          @push c.charCodeAt(0)
        @movePoint()
      when State.Run
        @doCommand(c)

  doCommand: (c) ->
    switch c
      when "<"
        @direction = Direction.Left
      when ">"
        @direction = Direction.Right
      when "^"
        @direction = Direction.Up
      when "v"
        @direction = Direction.Down
      when "_"
        @direction = if @pop() == 0 then Direction.Right else Direction.Left
      when "|"
        @direction = if @pop() == 0 then Direction.Down else Direction.Up
      when "?"
        @direction = Math.floor(Math.random()*4)
      when " "
        break
      when "#"
        @movePoint()
      when "@"
        return true
      when "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"
        @push(c.charCodeAt(0) - '0'.charCodeAt(0))
      when '"'
        @state = State.Read
      when "&"
        n = @delegate.getNum()
        @push n
      when "~"
        c = @delegate.getChar()
        @push c.charCodeAt(0)
      when "."
        num = @pop()
        @delegate.putNum num
      when ","
        a = @pop()
        @delegate.putChar String.fromCharCode(a)
      when "+"
        a = @pop()
        b = @pop()
        @push(b + a)
      when "-"
        a = @pop()
        b = @pop()
        @push(b - a)
      when "*"
        a = @pop()
        b = @pop()
        @push(b * a)
      when "/"
        a = @pop()
        b = @pop()
        @push(Math.floor(b / a))
      when "%"
        a = @pop()
        b = @pop()
        @push(b % a)
      when "`"
        a = @pop()
        b = @pop()
        @push(if b > a then 1 else 0)
      when "!"
        a = @pop()
        @push(if a == 0 then 1 else 0)
      when ":"
        a = @pop()
        @push a
        @push a
      when "\\"
        a = @pop()
        b = @pop()
        @push a
        @push b
      when "$"
        @pop()
      when "g"
        y = @pop()
        x = @pop()
        c = @program[y][x]
        @delegate.readCode y, x, c
        @push c.charCodeAt(0)
      when "p"
        y = @pop()
        x = @pop()
        from = @program[y][x]
        to = String.fromCharCode @pop()
        @delegate.writeCode y, x, from, to
        @program[y][x] = to
      else
        throw "undefined operator " + c.charCodeAt(0)

    @movePoint()
    false

