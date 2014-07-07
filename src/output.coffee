class Output extends THREE.Object3D
  constructor: ->
    super()
    @height = 12
    @textGeometryGen = util.textGeometryGen @height, 8
    @cursor = x: 0, y: 0

    @mergedGeometry = new THREE.Geometry
    @mergedGeometry.dynamic = true

    @position.x = 100
    @position.y = 250

    @rotation.x = Math.PI * 0.3
    @rotation.y = -Math.PI * 0.15

    @buf = ""

  insert: (text) ->
    for line, i in text.split("\n")
      if i != 0
        @cursor.x = 0
        @cursor.y -= @height + 2
        @buf = ""

      if line == ""
        continue

      if /^ +$/.test(line)
        @buf += line
        continue

      geo = @textGeometryGen(@buf + line)
      @buf = ""
      @mergedGeometry.merge geo, new THREE.Matrix4().makeTranslation(@cursor.x, @cursor.y, 0)

      # TODO Is there any method to update rendered Mesh's Geometry
      #      or reduce drawcall by packing by lines
      @remove @textMesh if @textMesh?
      @textMesh = util.flatMesh @mergedGeometry.clone(), 0xffffff
      @add @textMesh

      geo.computeBoundingBox()
      @cursor.x += geo.boundingBox.max.x + 1

