class Torus extends THREE.Object3D
  constructor: (program) ->
    super()
    size = x: program[0].length, y: program.length

    r1 = Math.max(16, size.y) * 2.7
    r2 = Math.max(40, size.x) * 1.7 + r1

    k = Math.max(160 / Math.max(size.x * 0.3, size.y), 16)

    mesh = util.flatMesh new THREE.TorusGeometry(r2, r1 - 15, size.y, size.x), 0xffffff
    mesh.material.wireframe = true
    mesh.material.opacity = 0.3
    mesh.material.transparent = true
    @add mesh

    @textGeometryGen = util.textGeometryGen k, 8, true

    @matrices = for y in [0...size.y]
      yrate = Math.PI * 2 * y / size.y
      for x in [0...size.x]
        xrate = Math.PI * 2 * x / size.x
        direction = new THREE.Matrix4().makeRotationZ(xrate)
            .multiply new THREE.Matrix4().makeRotationY(yrate)

        ret = new THREE.Matrix4().makeTranslation(Math.cos(xrate)*r2, Math.sin(xrate)*r2, 0)
          .multiply direction
          .multiply new THREE.Matrix4().makeTranslation(0, 0, r1)
          .multiply new THREE.Matrix4().makeRotationZ(Math.PI/2)
        ret.direction = direction
        ret

    @objects = for y in [0...size.y]
      for x in [0...size.x]
        if program[y][x] == " "
          null
        else
          ret = util.flatMesh @textGeometryGen(program[y][x]), 0xffffff
          ret.material.transparent = true
          ret.applyMatrix @matrices[y][x]
          @add ret
          ret

    # TODO reduce drawcall

  update: ->
    @rotation.x += 0.003
    @rotation.y += 0.003

  readCode: (y, x) ->
    # nothing to do

  writeCode: (y, x, to) ->
    vec = new THREE.Vector3(0, 0, 3).applyMatrix4(@matrices[y][x].direction)
    speed = 0.1

    if @objects[y][x]?
      obj = @objects[y][x]
      obj.update = =>
        obj.material.opacity -= speed
        obj.position.add vec
        @remove obj if obj.material.opacity <= 0

    @objects[y][x] = if to == " "
      null
    else
      tmp = util.flatMesh @textGeometryGen(to), 0xffffff
      tmp.material.transparent = true
      tmp.material.opacity = 0
      tmp.applyMatrix @matrices[y][x]
      tmp.position.sub vec.clone().multiplyScalar(1 / speed)
      @add tmp

      tmp.update = ->
        tmp.position.add vec
        tmp.material.opacity += speed
        if tmp.material.opacity >= 1
          tmp.material.opacity = 1
          delete tmp.update

      tmp

