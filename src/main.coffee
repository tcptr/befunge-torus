class Main extends BefungeDelegate
  constructor: (code, inputChar, inputNumber, stepPerFrame) ->
    @inputChar = inputChar.split("")
    @inputNumber = inputNumber.split(",")
    @stepPerFrame = Number(stepPerFrame)
    @count = 0

    @world = new World
    @befunge = new Befunge code, @

    @root = new THREE.Object3D
    @world.scene.add @root

    torusOpSpeed =
      if @stepPerFrame <= 5 then 0.02
      else if @stepPerFrame <= 100 then 0.05 else 0.10

    @torus = new Torus @befunge.program, torusOpSpeed
    @torus.position.x = -50
    @root.add @torus

    @stack =
      if @stepPerFrame <= 20
        stackOpSpeed =
          if @stepPerFrame <= 5 then 0.1
          else if @stepPerFrame <= 10 then 0.2 else 0.5

        new StackDynamic stackOpSpeed
      else
        new Stack

    @torus.add @stack

    @output = new Output 14
    @output.position.x = 100
    @output.position.y = 200

    @output.rotation.x = Math.PI * 0.3
    @output.rotation.y = -Math.PI * 0.15
    @root.add @output

    for info in [[0x3366ff, -500, 0, 0], [0xff6633, 0, 0, 500]]
      light = new THREE.PointLight info[0], 3, 3000
      light.position.set info[1..3]...
      @root.add light

    @root.update = @update

  update: =>
    @count += @stepPerFrame

    while @count >= 1
      return if @end
      @end = @befunge.doStep()
      @count -= 1

  putNum: (n) ->
    @output.insert "#{n} "

  putChar: (c) ->
    @output.insert c

  pushStack: (n) ->
    @stack.push n

  popStack: ->
    @stack.pop()

  readCode: (y, x, c) ->
    @torus.readCode y, x

  writeCode: (y, x, from, to) ->
    @torus.writeCode y, x, to

  getNum: ->
    if @inputNumber.length > 0
      Number @inputNumber.shift()
    else
      0

  getChar: ->
    if @inputChar.length > 0
      @inputChar.shift()
    else
      "\n"

