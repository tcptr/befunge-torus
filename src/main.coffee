class Main extends BefungeDelegate
  constructor: (code) ->
    @world = new World
    @befunge = new Befunge code, @

    @root = new THREE.Object3D
    @world.scene.add @root

    @torus = new Torus @befunge.program
    @root.add @torus

    @stack = new Stack
    @root.add @stack

    @output = new Output
    @root.add @output

    # test
    light = new THREE.PointLight 0x0000ff, 3, 3000
    light.position.x = -500
    @world.scene.add light
    light = new THREE.PointLight 0x00ff00, 3, 3000
    light.position.y = -500
    @world.scene.add light
    light = new THREE.PointLight 0xff0000, 3, 3000
    light.position.z = 500
    @world.scene.add light

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

  # TODO getNum, getChar


