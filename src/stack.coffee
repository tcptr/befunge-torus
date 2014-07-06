class Stack extends THREE.Object3D
  constructor: ->
    super()

    @textGeometryGen = util.textGeometryGen 20, 10, true
    @list = []
    # TODO animation

  push: (n) ->
    obj = util.flatMesh @textGeometryGen(String(n)), 0xffffff
    @list.push obj

    @updatePosition()
    @add obj

  pop: ->
    obj = @list.pop()

    @updatePosition()
    @remove obj

  updatePosition: ->
    for obj, i in @list
      obj.position.z = 30 * i - (@list.length - 1)*15

