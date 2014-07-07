class Output extends THREE.Object3D
  constructor: ->
    super()
    @height = 14
    @textGeometryGen = util.textGeometryGen @height, 8
    @cursor = x: 0, y: - @height - 2

    @tmpMatrix = new THREE.Matrix4()

    @position.x = 150
    @position.y = 250

    @rotation.x = Math.PI * 0.3
    @rotation.y = -Math.PI * 0.15

    mesh = util.flatMesh new THREE.PlaneGeometry(400, 400, 16, 16), 0xffffff
    mesh.material.wireframe = true
    mesh.material.opacity = 0.3
    mesh.material.transparent = true
    mesh.position.x = 180
    mesh.position.y = -180

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

    if @lines.length > 20
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

