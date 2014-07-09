class Stack extends THREE.Object3D
  constructor: ->
    super()
    @span = 30
    @textFactory = util.textFactoryGen 20, 10, true

    @pool = new THREE.Object3D
    @add @pool

    @list = []

  push: (n) ->
    mesh = @textFactory.make String(n)
    mesh.position.set 0, 0, @list.length * @span
    @pool.add mesh
    @list.push mesh
    mesh

  pop: ->
    mesh = @list.pop()
    @textFactory.dispose mesh
    @pool.remove mesh

  update: ->
    @pool.position.z = -@span * (@list.length - 1) / 2

class StackDynamic extends Stack
  constructor: (@opSpeed) ->
    super()
    @speed = 15
    @stSpeed = 5

  update: ->
    if @list.length == 0
      @pool.position.z = 0
      return

    to = -@span * (@list.length - 1) / 2
    @pool.position.z =
      if Math.abs(@pool.position.z - to) < @stSpeed
        to
      else if @pool.position.z < to
        @pool.position.z + @stSpeed
      else
        @pool.position.z - @stSpeed

  push: (n) ->
    mesh = super n
    mesh.material.transparent = true
    mesh.material.opacity = 0
    mesh.position.z += @speed / @opSpeed

    mesh.update = =>
      delete mesh.update if mesh.material.opacity >= 1
      mesh.material.opacity += @opSpeed
      mesh.position.z -= @speed

  pop: ->
    mesh = @list.pop()
    r = Math.random() * Math.PI * 2
    vec = new THREE.Vector3 Math.cos(r)*@speed, Math.sin(r)*@speed, 0
    limit = @span / @speed * 1.5
    count = 0

    mesh.update = =>
      if count == 0 && mesh.material.opacity < 1
        mesh.material.opacity += @opSpeed
        mesh.position.z -= @speed
        return

      count += 1

      if count <= limit
        mesh.position.add vec
      else
        mesh.position.z -= @speed

      mesh.material.opacity -= @opSpeed
      if mesh.material.opacity <= 0
        delete mesh.update
        @textFactory.dispose mesh
        @pool.remove mesh

