class Torus extends THREE.Object3D
  constructor: (program, @opSpeed) ->
    super()

    @size = x: program[0].length, y: program.length
    @r1 = Math.max(16, @size.y) * 2.7
    @r2 = Math.max(40, @size.x) * 1.7 + @r1

    fontSize = Math.max(160 / Math.max(@size.x * 0.3, @size.y), 16)
    @textFactory = util.textFactoryGen fontSize, 8, true

    rotateSpeed = Math.PI * 0.001

    # torus wireframe
    do =>
      tube = @r1 - 15
      offset = Math.PI * 2 / @size.y

      wireframe = util.flatMesh new THREE.TorusGeometry(@r2, tube, @size.y, @size.x), 0xffffff
      wireframe.material.wireframe = true
      wireframe.material.opacity = 0.3
      wireframe.material.transparent = true
      @add wireframe

      # rotate
      wireframe.geometry.dynamic = true
      wireframe.update = =>
        delete wireframe.update if rotateSpeed == 0
        offset -= rotateSpeed
        for j in [0..@size.y]
          for i in [0..@size.x]
            u = i / @size.x * Math.PI * 2
            v = j / @size.y * Math.PI * 2 + offset

            idx = j * (@size.x + 1) + i
            wireframe.geometry.vertices[idx].x = ( @r2 + tube * Math.cos( v ) ) * Math.cos( u )
            wireframe.geometry.vertices[idx].y = ( @r2 + tube * Math.cos( v ) ) * Math.sin( u )
            wireframe.geometry.vertices[idx].z =  tube * Math.sin( v )

        wireframe.geometry.verticesNeedUpdate = true

    @wheels = for x in [0...@size.x]
      xrate = Math.PI * 2 * x / @size.x

      wheel = new Wheel rotateSpeed
      wheel.position.set Math.cos(xrate)*@r2, Math.sin(xrate)*@r2, 0
      wheel.rotation.z = xrate
      @add wheel

      wheel.ls = for y in [0...@size.y]
        if program[y][x] == " " then null else @makeCell program[y][x], y, 0, wheel

      wheel

  update: ->
    @rotation.x += 0.003
    @rotation.y += 0.003

  makeCell: (text, y, offset, wheel) ->
    cell = @textFactory.make text
    cell.material.transparent = true
    cell.offset_ = offset
    cell.y_ = y
    @updateCell cell
    wheel.makeDynamic()
    wheel.payload.add cell
    cell

  updateCell: (cell) ->
    yrate = Math.PI * 2 * cell.y_ / @size.y
    cell.position.set Math.sin(yrate)*(@r1 - cell.offset_), 0, Math.cos(yrate)*(@r1 - cell.offset_)
    cell.rotation.y = yrate
    cell.rotation.z = Math.PI/2

  removeCell: (cell, wheel) ->
    @textFactory.dispose cell
    wheel.makeDynamic()
    wheel.payload.remove cell

  readCode: (y, x) ->
    # nothing to do

  writeCode: (y, x, to) ->
    speed = 3
    wheel = @wheels[x]

    # fade out the previous character
    if wheel.ls[y]?
      wheel.beginAnimation()

      obj = wheel.ls[y]
      obj.update = =>
        obj.material.opacity -= @opSpeed
        obj.offset_ -= speed
        @updateCell obj

        if obj.material.opacity <= 0
          @removeCell obj, wheel
          delete obj.update
          wheel.endAnimation()

    wheel.ls[y] = if to == " " then null else @makeCell to, y, speed/@opSpeed, wheel

    # fade in the new character
    if wheel.ls[y]?
      wheel.beginAnimation()

      tmp = wheel.ls[y]
      tmp.material.opacity = 0
      tmp.update = =>
        tmp.material.opacity += @opSpeed
        tmp.offset_ -= speed
        @updateCell tmp

        if tmp.material.opacity >= 1
          tmp.material.opacity = 1
          delete tmp.update
          wheel.endAnimation()

class Wheel extends THREE.Object3D
  constructor: (@rotateSpeed) ->
    super()
    @payload = new THREE.Object3D()
    @add @payload
    @stash = null
    @currentRotation = 0
    @moving = 0

  beginAnimation: ->
    @moving += 1
    @makeDynamic()

  endAnimation: ->
    @moving -= 1

  makeDynamic: ->
    return if not @stash
    @remove @payload
    @payload = @stash
    @stash = null
    @add @payload

  makeStatic: ->
    return if @stash
    @remove @payload
    @stash = @payload

    geo = new THREE.Geometry()
    for g in @stash.children
      g.matrixAutoUpdate && g.updateMatrix()
      geo.merge g.geometry, g.matrix

    @payload = util.flatMesh geo, 0xffffff
    @add @payload

  update: ->
    @makeStatic() if @moving == 0
    @currentRotation += @rotateSpeed
    @payload.rotation.y = @currentRotation

