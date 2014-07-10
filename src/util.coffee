util =
  flatMesh: (geometry, color = 0xffffff) ->
    new THREE.Mesh geometry, util.flatMaterial(color)

  basicMesh: (geometry, color = 0xffffff) ->
    new THREE.Mesh geometry, util.basicMaterial(color)

  flatMaterial: (color = 0xffffff) ->
    new THREE.MeshPhongMaterial color: color, shading: THREE.FlatShading

  basicMaterial: (color = 0xffffff) ->
    new THREE.MeshBasicMaterial color: color

  font:
    name: ""
    weight: "normal"
    style: "normal"

  textGeometryGen: (size, height, centering = false) ->
    cache = {}
    options =
      font: util.font.name
      weight: util.font.weight
      style: util.font.style
      size: size
      height: height
      curveSegments: 4

    (text) ->
      return cache[text] if cache[text]?
      cache[text] = ret = new THREE.TextGeometry text, options

      if centering
        ret.computeBoundingBox()
        offsets = (-0.5 * (ret.boundingBox.max[a] - ret.boundingBox.min[a]) for a in ["x", "y", "z"])
        ret.applyMatrix(new THREE.Matrix4().makeTranslation offsets...)

      ret

  factoryGen: (maker) ->
    cache = {}

    {
      make: (key) ->
        if cache[key]?.length > 0
          cache[key].shift()
        else
          ret = maker key
          ret.key_ = key
          ret
      dispose: (m) ->
        cache[m.key_] ?= []
        cache[m.key_].push m
    }

  textFactoryGen: (opts...) ->
    geometryGen = util.textGeometryGen opts...
    util.factoryGen (text) -> util.flatMesh geometryGen(text), 0xffffff


