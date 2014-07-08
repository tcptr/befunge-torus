class Main extends BefungeDelegate
  constructor: (code, inputChar, inputNumber) ->
    @inputChar = inputChar.split("")
    @inputNumber = inputNumber.split(",")

    @world = new World
    @befunge = new Befunge code, @

    @root = new THREE.Object3D
    @world.scene.add @root

    @torus = new Torus @befunge.program
    @root.add @torus

    @stack = new Stack
    @torus.add @stack

    @output = new Output
    @root.add @output

    # TODO
    light = new THREE.PointLight 0x3366ff, 3, 3000
    light.position.x = -500
    @world.scene.add light
    light = new THREE.PointLight 0xff6633, 3, 3000
    light.position.z = 500
    @world.scene.add light

    @root.update = @update

  update: =>
    for _ in [0...10]
      return if @end
      @end = @befunge.doStep()

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


