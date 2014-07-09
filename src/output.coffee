class Output extends THREE.Object3D
  constructor: (@height) ->
    super()
    @textGeometryGen = util.textGeometryGen @height, 8
    @cursor = x: 0, y: - @height - 2

    @tmpMatrix = new THREE.Matrix4()

    size = 20
    mesh = util.flatMesh new THREE.PlaneGeometry(@height * size, @height * size, size, size), 0xffffff
    mesh.material.wireframe = true
    mesh.material.transparent = true
    mesh.material.opacity = 0.5
    mesh.position.x = @height * (size / 2 - 1)
    mesh.position.y = -@height * (size / 2 - 1)

    @add mesh

    @buf = ""
    @currentLine = []

    @lines = []

  newline: ->
    @cursor.x = 0
    @cursor.y -= @height + 2

    geo = new THREE.Geometry()
    for g in @currentLine
      geo.merge g.geometry, g.matrix
      @remove g

    mesh = util.flatMesh geo, 0xffffff

    @add mesh
    @lines.push mesh

    @buf = ""
    @currentLine = []

    if @lines.length > 15
      @cursor.y += @height + 2
      @remove @lines.shift()
      for mesh in @lines
        mesh.applyMatrix @tmpMatrix.makeTranslation(0, @height + 2, 0)

    null

  insert: (text) ->
    for line, i in text.split("\n")
      @newline() if i != 0
      continue if line == ""

      if /^ +$/.test(line)
        @buf += line
        continue

      geo = @textGeometryGen(@buf + line)
      @buf = ""

      mesh = util.flatMesh geo, 0xffffff
      mesh.applyMatrix @tmpMatrix.makeTranslation(@cursor.x, @cursor.y, 0)

      @add mesh
      @currentLine.push mesh

      geo.computeBoundingBox()
      @cursor.x += geo.boundingBox.max.x + 1

    null

