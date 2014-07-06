THREE.Object3D::update = ->
  # override it

THREE.Object3D::visit = ->
  @update()
  for child in @children
    child.visit()

THREE.Object3D::removeAll = ->
  for child in @children.slice()
    @remove child

class World
  constructor: ->
    container = document.createElement 'div'
    document.body.appendChild container

    @camera = new THREE.PerspectiveCamera 45, 1.0, 1, 1000
    @camera.position.y = -400
    @camera.position.z = 300
    @camera.lookAt new THREE.Vector3(0, 0, 0)

    @scene = new THREE.Scene
    @scene.fog = new THREE.FogExp2 0x000000, 0.002

    @renderer = new THREE.WebGLRenderer antialias: true
    @renderer.setClearColor @scene.fog.color, 1
    @renderer.autoClear = false
    container.appendChild @renderer.domElement

    @passes =
      render: new THREE.RenderPass @scene, @camera
      fxaa:  new THREE.ShaderPass THREE.FXAAShader
      bloom: new THREE.BloomPass 1.0
      copy:  new THREE.ShaderPass THREE.CopyShader

    @passes.copy.renderToScreen = true

    @composer = new THREE.EffectComposer @renderer
    @composer.addPass @passes.render
    @composer.addPass @passes.fxaa
    @composer.addPass @passes.bloom
    @composer.addPass @passes.copy

    window.addEventListener 'resize', @onWindowResize
    @onWindowResize()

    @animate()

  animate: (timestamp) =>
    @delta = timestamp - (@prevTimestamp ? timestamp)
    @prevTimestamp = timestamp
    requestAnimationFrame @animate
    @scene.visit()
    @render()

  render: ->
    @renderer.clear()
    @composer.render 0.05

  onWindowResize: =>
    @windowHalf =
      x: window.innerWidth / 2
      y: window.innerHeight / 2

    @camera.aspect = window.innerWidth / window.innerHeight
    @camera.updateProjectionMatrix()

    @renderer.setSize window.innerWidth, window.innerHeight

    @passes.fxaa.uniforms['resolution'].value.set 1/window.innerWidth, 1/window.innerHeight
    @composer.reset()

