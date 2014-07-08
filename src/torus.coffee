class Torus extends THREE.Object3D
  constructor: (program) ->
    super()

    @size =
      x: program[0].length
      y: program.length
      xrate: (i) -> Math.PI * 2 * i / @x
      yrate: (i) -> Math.PI * 2 * i / @y

    @r1 = Math.max(16, @size.y) * 2.7
    @r2 = Math.max(40, @size.x) * 1.7 + @r1

    rotateSpeed = Math.PI * 0.001

    do =>
      geometry = new THREE.Geometry()
      r = -> Math.random() * 600 - 300
      for i in [0..2000]
        geometry.vertices.push new THREE.Vector3(r(), r(), r())
      
      material = new THREE.ParticleBasicMaterial
        size: 5, color: 0x6699ff
        blending: THREE.AdditiveBlending, transparent: true, depthTest: false
      
      mesh = new THREE.ParticleSystem geometry, material
      @add mesh

    do =>
      tube = @r1 - 15

      # torus wireframe
      wireframe = util.flatMesh new THREE.TorusGeometry(@r2, tube, @size.y, @size.x), 0xffffff
      wireframe.material.wireframe = true
      wireframe.material.opacity = 0.3
      wireframe.material.transparent = true
      @add wireframe

      # rotate wireframe
      wireframe.offset_ = Math.PI * 2 / @size.y
      wireframe.update = =>
        delete wireframe.update if rotateSpeed == 0
        wireframe.offset_ -= rotateSpeed
        wireframe.geometry.verticesNeedUpdate = true
        for j in [0..@size.y]
          for i in [0..@size.x]
            u = i / @size.x * Math.PI * 2
            v = j / @size.y * Math.PI * 2 + wireframe.offset_

            idx = j * (@size.x + 1) + i
            wireframe.geometry.vertices[idx].x = ( @r2 + tube * Math.cos( v ) ) * Math.cos( u )
            wireframe.geometry.vertices[idx].y = ( @r2 + tube * Math.cos( v ) ) * Math.sin( u )
            wireframe.geometry.vertices[idx].z =  tube * Math.sin( v )

      null

    k = Math.max(160 / Math.max(@size.x * 0.3, @size.y), 16)
    @textGeometryGen = util.textGeometryGen k, 8, true

    @objects = for x in [0...@size.x]
      xrate = @size.xrate x

      base = new THREE.Object3D()
      base.position.set Math.cos(xrate)*@r2, Math.sin(xrate)*@r2, 0
      base.rotation.z = xrate
      @add base

      base.wheel = new THREE.Object3D()
      base.add base.wheel

      # rotate objects
      if rotateSpeed != 0
        base.wheel.update = -> @rotation.y += rotateSpeed

      base.ls = for y in [0...@size.y]
        if program[y][x] == " " then null else @makeCell program[y][x], y, 0, base.wheel

      base

    # TODO reduce drawcall

  update: ->
    @rotation.x += 0.003
    @rotation.y += 0.003

  makeCell: (text, y, offset, wheel) ->
    ret = util.flatMesh @textGeometryGen(text), 0xffffff
    ret.material.transparent = true
    ret.offset_ = offset
    ret.y_ = y
    @updateCell ret
    wheel.add ret
    ret

  updateCell: (cell) ->
    yrate = @size.yrate cell.y_
    cell.position.set Math.sin(yrate)*(@r1 - cell.offset_), 0, Math.cos(yrate)*(@r1 - cell.offset_)
    cell.rotation.y = yrate
    cell.rotation.z = Math.PI/2

  readCode: (y, x) ->
    # nothing to do

  writeCode: (y, x, to) ->
    speed = 3
    opSpeed = 0.05
    base = @objects[x]

    # fade out the previous character
    if base.ls[y]?
      obj = base.ls[y]
      obj.update = =>
        obj.material.opacity -= opSpeed
        obj.offset_ -= speed
        @updateCell obj

        if obj.material.opacity <= 0
          base.wheel.remove obj

    base.ls[y] = if to == " " then null else @makeCell to, y, speed/opSpeed, base.wheel

    # fade in the new character
    if base.ls[y]?
      tmp = base.ls[y]
      tmp.material.opacity = 0
      tmp.update = =>
        tmp.material.opacity += opSpeed
        tmp.offset_ -= speed
        @updateCell tmp

        if tmp.material.opacity >= 1
          tmp.material.opacity = 1
          delete tmp.update

