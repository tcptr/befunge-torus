class Main extends BefungeDelegate
  constructor: (code, inputChar, inputNumber) ->
    @inputChar = inputChar.split("")
    @inputNumber = inputNumber.split(",")

    @world = new World
    @befunge = new Befunge code, @

    @root = new THREE.Object3D
    @world.scene.add @root

    @torus = new Torus @befunge.program
    @torus.position.x = -50
    @root.add @torus

    @stack = new Stack
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
    for _ in [0...30]
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


