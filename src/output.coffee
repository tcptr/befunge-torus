class Output extends THREE.Object3D
  constructor: ->
    super()
    @height = 16
    @textGeometryGen = util.textGeometryGen @height, 6
    @cursor = x: 0, y: 0

    @mergedGeometry = new THREE.Geometry

    @textMesh = util.flatMesh @mergedGeometry, 0xffffff
    @add @textMesh

    @position.x = 100
    @position.y = 250

    @rotation.x = Math.PI * 0.3
    @rotation.y = -Math.PI * 0.15

  insert: (text) ->
    for line, i in text.split("\n")
      if i != 0
        @cursor.x = 0
        @cursor.y -= @height

      continue if line == ""

      geo = @textGeometryGen line
      @mergedGeometry.merge geo, new THREE.Matrix4().makeTranslation(@cursor.x, @cursor.y, 0)

      geo.computeBoundingBox()
      @cursor.x += geo.boundingBox.max.x

