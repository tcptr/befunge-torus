class Torus extends THREE.Object3D
  constructor: (program) ->
    super()
    size = x: program[0].length, y: program.length

    r1 = Math.max(16, size.y) * 2.7
    r2 = Math.max(40, size.x) * 1.7 + r1

    k = Math.max(160 / Math.max(size.x * 0.3, size.y), 16)

    @wireframe = util.flatMesh new THREE.TorusGeometry(r2, r1 - 15, size.y, size.x), 0xffffff
    @wireframe.material.wireframe = true
    @wireframe.material.opacity = 0.3
    @wireframe.material.transparent = true
    @add @wireframe

    @textGeometryGen = util.textGeometryGen k, 8, true

    @matrices = for y in [0...size.y]
      yrate = Math.PI * 2 * y / size.y
      for x in [0...size.x]
        xrate = Math.PI * 2 * x / size.x
        new THREE.Matrix4()
          .multiply new THREE.Matrix4().makeTranslation(Math.cos(xrate)*r2, Math.sin(xrate)*r2, 0)
          .multiply new THREE.Matrix4().makeRotationZ(xrate)
          .multiply new THREE.Matrix4().makeRotationY(yrate)
          .multiply new THREE.Matrix4().makeTranslation(0, 0, r1)
          .multiply new THREE.Matrix4().makeRotationZ(Math.PI/2)

    @objects = for y in [0...size.y]
      for x in [0...size.x]
        if program[y][x] == " "
          null
        else
          ret = util.flatMesh @textGeometryGen(program[y][x]), 0xffffff
          ret.applyMatrix @matrices[y][x]
          @add ret
          ret

    # TODO reduce drawcall

  update: ->
    @rotation.x += 0.003
    @rotation.y += 0.003

  readCode: (y, x) ->
    # TODO animation

  writeCode: (y, x, to) ->
    # TODO animation
    @remove @objects[y][x] if @objects[y][x]?

    @objects[y][x] = if to == " "
      null
    else
      tmp = util.flatMesh @textGeometryGen(to), 0xffffff
      tmp.applyMatrix @matrices[y][x]
      @add tmp
      tmp

