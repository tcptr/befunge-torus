util =
  flatMesh: (geometry, color = 0xffffff) ->
    new THREE.Mesh geometry, util.flatMaterial(color)

  basicMesh: (geometry, color = 0xffffff) ->
    new THREE.Mesh geometry, util.basicMaterial(color)

  flatMaterial: (color = 0xffffff) ->
    new THREE.MeshPhongMaterial color: color, shading: THREE.FlatShading

  basicMaterial: (color = 0xffffff) ->
    new THREE.MeshBasicMaterial color: color

  textGeometryGen: (size, height, centering = false) ->
    cache = {}
    options =
      font: "misakigothic"
      size: size
      height: height
      curveSegments: 4
      weight: "normal"
      style: "normal"

    (text) ->
      return cache[text] if cache[text]?
      cache[text] = ret = new THREE.TextGeometry text, options

      if centering
        ret.computeBoundingBox()
        offsets = (-0.5 * (ret.boundingBox.max[a] - ret.boundingBox.min[a]) for a in ["x", "y", "z"])
        ret.applyMatrix(new THREE.Matrix4().makeTranslation offsets...)

      ret

