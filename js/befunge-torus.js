(function() {
  var Befunge, BefungeDelegate, Direction, Examples, Main, Output, Stack, State, Torus, World, util,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Direction = {
    Up: 0,
    Down: 1,
    Left: 2,
    Right: 3
  };

  State = {
    Run: 0,
    Read: 1
  };

  BefungeDelegate = (function() {
    function BefungeDelegate() {}

    BefungeDelegate.prototype.getNum = function() {
      return 0;
    };

    BefungeDelegate.prototype.getChar = function() {
      return "@";
    };

    BefungeDelegate.prototype.putNum = function(n) {
      return console.log(n);
    };

    BefungeDelegate.prototype.putChar = function(c) {
      return console.log(c);
    };

    BefungeDelegate.prototype.pushStack = function(n) {};

    BefungeDelegate.prototype.popStack = function() {};

    BefungeDelegate.prototype.readCode = function(y, x, c) {};

    BefungeDelegate.prototype.writeCode = function(y, x, from, to) {};

    return BefungeDelegate;

  })();

  Befunge = (function() {
    function Befunge(code, delegate) {
      var i, k, line, _i, _j, _len, _ref, _ref1, _ref2;
      this.delegate = delegate != null ? delegate : new BefungeDelegate;
      this.program = (function() {
        var _i, _len, _ref, _results;
        _ref = code.split("\n");
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          line = _ref[_i];
          _results.push(line.split(""));
        }
        return _results;
      })();
      this.size = {
        x: Math.max.apply(Math, (function() {
          var _i, _len, _ref, _results;
          _ref = this.program;
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            line = _ref[_i];
            _results.push(line.length);
          }
          return _results;
        }).call(this)),
        y: this.program.length
      };
      if (this.size.x === 0 || this.size.y === 0) {
        throw "Empty program!";
      }
      this.point = {
        x: 0,
        y: 0
      };
      this.stack = [];
      this.direction = Direction.Right;
      this.state = State.Run;
      _ref = this.program;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        line = _ref[_i];
        k = this.size.x - line.length;
        line.length = this.size.x;
        for (i = _j = _ref1 = this.size.x - k, _ref2 = this.size.x; _ref1 <= _ref2 ? _j < _ref2 : _j > _ref2; i = _ref1 <= _ref2 ? ++_j : --_j) {
          line[i] = " ";
        }
      }
    }

    Befunge.prototype.execute = function(step) {
      var i, _i, _results;
      if (step == null) {
        step = Number.MAX_VALUE;
      }
      _results = [];
      for (i = _i = 0; 0 <= step ? _i <= step : _i >= step; i = 0 <= step ? ++_i : --_i) {
        if (this.doStep()) {
          break;
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    Befunge.prototype.push = function(n) {
      this.stack.push(n);
      return this.delegate.pushStack(n);
    };

    Befunge.prototype.pop = function() {
      if (this.stack.length === 0) {
        return 0;
      } else {
        this.delegate.popStack();
        return this.stack.pop();
      }
    };

    Befunge.prototype.movePoint = function() {
      switch (this.direction) {
        case Direction.Left:
          this.point.x -= 1;
          if (this.point.x < 0) {
            return this.point.x = this.size.x - 1;
          }
          break;
        case Direction.Right:
          this.point.x += 1;
          if (this.point.x >= this.size.x) {
            return this.point.x = 0;
          }
          break;
        case Direction.Up:
          this.point.y -= 1;
          if (this.point.y < 0) {
            return this.point.y = this.size.y - 1;
          }
          break;
        case Direction.Down:
          this.point.y += 1;
          if (this.point.y >= this.size.y) {
            return this.point.y = 0;
          }
      }
    };

    Befunge.prototype.doStep = function() {
      var c;
      c = this.program[this.point.y][this.point.x];
      switch (this.state) {
        case State.Read:
          if (c === '"') {
            this.state = State.Run;
          } else {
            this.push(c.charCodeAt(0));
          }
          return this.movePoint();
        case State.Run:
          return this.doCommand(c);
      }
    };

    Befunge.prototype.doCommand = function(c) {
      var a, b, from, n, num, to, x, y;
      switch (c) {
        case "<":
          this.direction = Direction.Left;
          break;
        case ">":
          this.direction = Direction.Right;
          break;
        case "^":
          this.direction = Direction.Up;
          break;
        case "v":
          this.direction = Direction.Down;
          break;
        case "_":
          this.direction = this.pop() === 0 ? Direction.Right : Direction.Left;
          break;
        case "|":
          this.direction = this.pop() === 0 ? Direction.Down : Direction.Up;
          break;
        case "?":
          this.direction = Math.floor(Math.random() * 4);
          break;
        case " ":
          break;
        case "#":
          this.movePoint();
          break;
        case "@":
          return true;
        case "0":
        case "1":
        case "2":
        case "3":
        case "4":
        case "5":
        case "6":
        case "7":
        case "8":
        case "9":
          this.push(c.charCodeAt(0) - '0'.charCodeAt(0));
          break;
        case '"':
          this.state = State.Read;
          break;
        case "&":
          n = this.delegate.getNum();
          this.push(n);
          break;
        case "~":
          c = this.delegate.getChar();
          this.push(c.charCodeAt(0));
          break;
        case ".":
          num = this.pop();
          this.delegate.putNum(num);
          break;
        case ",":
          a = this.pop();
          this.delegate.putChar(String.fromCharCode(a));
          break;
        case "+":
          a = this.pop();
          b = this.pop();
          this.push(b + a);
          break;
        case "-":
          a = this.pop();
          b = this.pop();
          this.push(b - a);
          break;
        case "*":
          a = this.pop();
          b = this.pop();
          this.push(b * a);
          break;
        case "/":
          a = this.pop();
          b = this.pop();
          this.push(Math.floor(b / a));
          break;
        case "%":
          a = this.pop();
          b = this.pop();
          this.push(b % a);
          break;
        case "`":
          a = this.pop();
          b = this.pop();
          this.push(b > a ? 1 : 0);
          break;
        case "!":
          a = this.pop();
          this.push(a === 0 ? 1 : 0);
          break;
        case ":":
          a = this.pop();
          this.push(a);
          this.push(a);
          break;
        case "\\":
          a = this.pop();
          b = this.pop();
          this.push(a);
          this.push(b);
          break;
        case "$":
          this.pop();
          break;
        case "g":
          y = this.pop();
          x = this.pop();
          c = this.program[y][x];
          this.delegate.readCode(y, x, c);
          this.push(c.charCodeAt(0));
          break;
        case "p":
          y = this.pop();
          x = this.pop();
          from = this.program[y][x];
          to = String.fromCharCode(this.pop());
          this.delegate.writeCode(y, x, from, to);
          this.program[y][x] = to;
          break;
        default:
          throw "undefined operator " + c.charCodeAt(0);
      }
      this.movePoint();
      return false;
    };

    return Befunge;

  })();

  $(function() {
    var _ref;
    $('#code').val((_ref = Examples[location.hash]) != null ? _ref : Examples["#hello"]);
    $('.example').on('click', function() {
      return $('#code').val(Examples[$(this).attr('href')]);
    });
    return $('#launch').on('click', function() {
      new Main($('#code').val(), $('#inputchar').val(), $('#inputnumber').val());
      $('#entry').remove();
      $('#back').show();
      return false;
    });
  });

  Examples = {
    "#hello": "v @_       v\n>0\"!dlroW\"v \nv  :#     < \n>\" ,olleH\" v\n   ^       <",
    "#fizzbuzz": ">1+\".\"05pv\n,        >:3%!v\n+    v,,\"Fizz\"_v\n5    >,,\"$\"05p v\n5         v!%5:<\n.v,,\"Buzz\"_v\n:>,,\"$\"05p v\n^_@#-+\"22\":<",
    "#lifegame": "v>>31g> ::51gg:2v++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n9p BXY|-+<v3*89<%+ *                                                      *   +\n21 >98 *7^>+\\-0|<+ *                                                     *    +\n*5 ^:+ 1pg15\\,:< + *                                                     ***  +\n10^  <>$25*,51g1v+                                                            +\n-^ p<| -*46p15:+<+                                                            +\n> 31^> 151p>92*4v+                                                            +\n ^_ \".\",   ^ vp1<+                                                            +\n>v >41p      >0 v+                                                            +\n:5! vg-1g15-1g14<+                                                            +\n+1-+>+41g1-51gg+v+                                                            +\n1p-1vg+1g15-1g14<+                                                            +\ng61g>+41g51g1-g+v+                                                            +\n14*1v4+g+1g15g14<+                           * *                              +\n5>^4>1g1+51g1-g+v+                           * *                              +\n^ _^v4+gg15+1g14<+                           ***                              +\n>v! >1g1+51g1+g+v+                                                            +\ng8-v14/*25-*4*88<+                                                            +\n19+>g51gg\" \"- v  +                                                            +\n4*5  v<   v-2:_3v+                                                            +\n >^   |!-3_$  v<-+                                                            +\n^    < <      <|<+                                                         ***+\n>g51gp ^ >51gp^>v+                                                            +\n^14\"+\"<  ^g14\"!\"<++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++",
    "#bottles": "5:*4*1-           >:1    v\n           v.:<\n           #  |:\\<       <     \n>v\"No more \"0 <          0     \n,:                       :     \n^_$        v             |!-1       <\n>v\"bottle\"0<      | :,*25<           \n,:           >\"s\"v@      \n^_$1-        |   ,\n>v\" of beer\"0<   <\n,:               >v                  \n^_$            :!|    \n>v\" on the wall\"0<\n,:                     >\".\"v\n^_$               >:2-!|\n                       >\",\">,25*,:  |\n>v\"Take one down, pass it around,\"0$<\n,:                                   \n^_$25*,1-      :2v",
    "#aturley": ">84*>:#v_55+\"ude.ub@yelruta\">:#,_@>188*+>\\02p\\12p\\:22p#v_$    55+,1-         v\n    ^  0 v +1\\                   _^#-+*<               >22g02g*\"_@\"*-!1- #v_v>\n       >:>::3g: ,\\188                  ^^               -1\\g21\\g22<p3\\\"_\":<\n________________________________@_________________________________^  p3\\\"@\":<"
  };

  Main = (function(_super) {
    __extends(Main, _super);

    function Main(code, inputChar, inputNumber) {
      this.update = __bind(this.update, this);
      var light;
      this.inputChar = inputChar.split("");
      this.inputNumber = inputNumber.split(",");
      this.world = new World;
      this.befunge = new Befunge(code, this);
      this.root = new THREE.Object3D;
      this.world.scene.add(this.root);
      this.torus = new Torus(this.befunge.program);
      this.root.add(this.torus);
      this.stack = new Stack;
      this.torus.add(this.stack);
      this.output = new Output;
      this.root.add(this.output);
      light = new THREE.PointLight(0x3366ff, 3, 3000);
      light.position.x = -500;
      this.world.scene.add(light);
      light = new THREE.PointLight(0xff6633, 3, 3000);
      light.position.z = 500;
      this.world.scene.add(light);
      this.root.update = this.update;
    }

    Main.prototype.update = function() {
      var _, _i;
      for (_ = _i = 0; _i < 1; _ = ++_i) {
        if (this.end) {
          return;
        }
        this.end = this.befunge.doStep();
      }
    };

    Main.prototype.putNum = function(n) {
      return this.output.insert("" + n + " ");
    };

    Main.prototype.putChar = function(c) {
      return this.output.insert(c);
    };

    Main.prototype.pushStack = function(n) {
      return this.stack.push(n);
    };

    Main.prototype.popStack = function() {
      return this.stack.pop();
    };

    Main.prototype.readCode = function(y, x, c) {
      return this.torus.readCode(y, x);
    };

    Main.prototype.writeCode = function(y, x, from, to) {
      return this.torus.writeCode(y, x, to);
    };

    Main.prototype.getNum = function() {
      if (this.inputNumber.length > 0) {
        return Number(this.inputNumber.shift());
      } else {
        return 0;
      }
    };

    Main.prototype.getChar = function() {
      if (this.inputChar.length > 0) {
        return this.inputChar.shift();
      } else {
        return "\n";
      }
    };

    return Main;

  })(BefungeDelegate);

  Output = (function(_super) {
    __extends(Output, _super);

    function Output() {
      Output.__super__.constructor.call(this);
      this.height = 12;
      this.textGeometryGen = util.textGeometryGen(this.height, 8);
      this.cursor = {
        x: 0,
        y: 0
      };
      this.mergedGeometry = new THREE.Geometry;
      this.mergedGeometry.dynamic = true;
      this.position.x = 100;
      this.position.y = 250;
      this.rotation.x = Math.PI * 0.3;
      this.rotation.y = -Math.PI * 0.15;
      this.buf = "";
    }

    Output.prototype.insert = function(text) {
      var geo, i, line, _i, _len, _ref, _results;
      _ref = text.split("\n");
      _results = [];
      for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
        line = _ref[i];
        if (i !== 0) {
          this.cursor.x = 0;
          this.cursor.y -= this.height + 2;
          this.buf = "";
        }
        if (line === "") {
          continue;
        }
        if (/^ +$/.test(line)) {
          this.buf += line;
          continue;
        }
        geo = this.textGeometryGen(this.buf + line);
        this.buf = "";
        this.mergedGeometry.merge(geo, new THREE.Matrix4().makeTranslation(this.cursor.x, this.cursor.y, 0));
        if (this.textMesh != null) {
          this.remove(this.textMesh);
        }
        this.textMesh = util.flatMesh(this.mergedGeometry.clone(), 0xffffff);
        this.add(this.textMesh);
        geo.computeBoundingBox();
        _results.push(this.cursor.x += geo.boundingBox.max.x + 1);
      }
      return _results;
    };

    return Output;

  })(THREE.Object3D);

  Stack = (function(_super) {
    __extends(Stack, _super);

    function Stack() {
      Stack.__super__.constructor.call(this);
      this.textGeometryGen = util.textGeometryGen(20, 10, true);
      this.list = [];
    }

    Stack.prototype.push = function(n) {
      var obj;
      obj = util.flatMesh(this.textGeometryGen(String(n)), 0xffffff);
      this.list.push(obj);
      this.updatePosition();
      return this.add(obj);
    };

    Stack.prototype.pop = function() {
      var obj;
      obj = this.list.pop();
      this.updatePosition();
      return this.remove(obj);
    };

    Stack.prototype.updatePosition = function() {
      var i, obj, _i, _len, _ref, _results;
      _ref = this.list;
      _results = [];
      for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
        obj = _ref[i];
        _results.push(obj.position.z = 30 * i - (this.list.length - 1) * 15);
      }
      return _results;
    };

    return Stack;

  })(THREE.Object3D);

  Torus = (function(_super) {
    __extends(Torus, _super);

    function Torus(program) {
      var k, r1, r2, ret, size, x, xrate, y, yrate;
      Torus.__super__.constructor.call(this);
      size = {
        x: program[0].length,
        y: program.length
      };
      r1 = Math.max(16, size.y) * 2.7;
      r2 = Math.max(40, size.x) * 1.7 + r1;
      k = Math.max(160 / Math.max(size.x * 0.3, size.y), 16);
      this.wireframe = util.flatMesh(new THREE.TorusGeometry(r2, r1 - 15, size.y, size.x), 0xffffff);
      this.wireframe.material.wireframe = true;
      this.wireframe.material.opacity = 0.3;
      this.wireframe.material.transparent = true;
      this.add(this.wireframe);
      this.textGeometryGen = util.textGeometryGen(k, 8, true);
      this.matrices = (function() {
        var _i, _ref, _results;
        _results = [];
        for (y = _i = 0, _ref = size.y; 0 <= _ref ? _i < _ref : _i > _ref; y = 0 <= _ref ? ++_i : --_i) {
          yrate = Math.PI * 2 * y / size.y;
          _results.push((function() {
            var _j, _ref1, _results1;
            _results1 = [];
            for (x = _j = 0, _ref1 = size.x; 0 <= _ref1 ? _j < _ref1 : _j > _ref1; x = 0 <= _ref1 ? ++_j : --_j) {
              xrate = Math.PI * 2 * x / size.x;
              _results1.push(new THREE.Matrix4().multiply(new THREE.Matrix4().makeTranslation(Math.cos(xrate) * r2, Math.sin(xrate) * r2, 0)).multiply(new THREE.Matrix4().makeRotationZ(xrate)).multiply(new THREE.Matrix4().makeRotationY(yrate)).multiply(new THREE.Matrix4().makeTranslation(0, 0, r1)).multiply(new THREE.Matrix4().makeRotationZ(Math.PI / 2)));
            }
            return _results1;
          })());
        }
        return _results;
      })();
      this.objects = (function() {
        var _i, _ref, _results;
        _results = [];
        for (y = _i = 0, _ref = size.y; 0 <= _ref ? _i < _ref : _i > _ref; y = 0 <= _ref ? ++_i : --_i) {
          _results.push((function() {
            var _j, _ref1, _results1;
            _results1 = [];
            for (x = _j = 0, _ref1 = size.x; 0 <= _ref1 ? _j < _ref1 : _j > _ref1; x = 0 <= _ref1 ? ++_j : --_j) {
              if (program[y][x] === " ") {
                _results1.push(null);
              } else {
                ret = util.flatMesh(this.textGeometryGen(program[y][x]), 0xffffff);
                ret.applyMatrix(this.matrices[y][x]);
                this.add(ret);
                _results1.push(ret);
              }
            }
            return _results1;
          }).call(this));
        }
        return _results;
      }).call(this);
    }

    Torus.prototype.update = function() {
      this.rotation.x += 0.003;
      return this.rotation.y += 0.003;
    };

    Torus.prototype.readCode = function(y, x) {};

    Torus.prototype.writeCode = function(y, x, to) {
      var tmp;
      if (this.objects[y][x] != null) {
        this.remove(this.objects[y][x]);
      }
      return this.objects[y][x] = to === " " ? null : (tmp = util.flatMesh(this.textGeometryGen(to), 0xffffff), tmp.applyMatrix(this.matrices[y][x]), this.add(tmp), tmp);
    };

    return Torus;

  })(THREE.Object3D);

  util = {
    flatMesh: function(geometry, color) {
      if (color == null) {
        color = 0xffffff;
      }
      return new THREE.Mesh(geometry, util.flatMaterial(color));
    },
    basicMesh: function(geometry, color) {
      if (color == null) {
        color = 0xffffff;
      }
      return new THREE.Mesh(geometry, util.basicMaterial(color));
    },
    flatMaterial: function(color) {
      if (color == null) {
        color = 0xffffff;
      }
      return new THREE.MeshPhongMaterial({
        color: color,
        shading: THREE.FlatShading
      });
    },
    basicMaterial: function(color) {
      if (color == null) {
        color = 0xffffff;
      }
      return new THREE.MeshBasicMaterial({
        color: color
      });
    },
    textGeometryGen: function(size, height, centering) {
      var cache, options;
      if (centering == null) {
        centering = false;
      }
      cache = {};
      options = {
        font: "misakigothic",
        size: size,
        height: height,
        curveSegments: 4,
        weight: "normal",
        style: "normal"
      };
      return function(text) {
        var a, offsets, ret, _ref;
        if (cache[text] != null) {
          return cache[text];
        }
        cache[text] = ret = new THREE.TextGeometry(text, options);
        if (centering) {
          ret.computeBoundingBox();
          offsets = (function() {
            var _i, _len, _ref, _results;
            _ref = ["x", "y", "z"];
            _results = [];
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              a = _ref[_i];
              _results.push(-0.5 * (ret.boundingBox.max[a] - ret.boundingBox.min[a]));
            }
            return _results;
          })();
          ret.applyMatrix((_ref = new THREE.Matrix4()).makeTranslation.apply(_ref, offsets));
        }
        return ret;
      };
    }
  };

  THREE.Object3D.prototype.update = function() {};

  THREE.Object3D.prototype.visit = function() {
    var child, _i, _len, _ref, _results;
    this.update();
    _ref = this.children;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      child = _ref[_i];
      _results.push(child.visit());
    }
    return _results;
  };

  THREE.Object3D.prototype.removeAll = function() {
    var child, _i, _len, _ref, _results;
    _ref = this.children.slice();
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      child = _ref[_i];
      _results.push(this.remove(child));
    }
    return _results;
  };

  World = (function() {
    function World() {
      this.onWindowResize = __bind(this.onWindowResize, this);
      this.animate = __bind(this.animate, this);
      var container;
      container = document.createElement('div');
      document.body.appendChild(container);
      this.camera = new THREE.PerspectiveCamera(45, 1.0, 1, 1000);
      this.camera.position.y = -400;
      this.camera.position.z = 300;
      this.camera.lookAt(new THREE.Vector3(0, 0, 0));
      this.scene = new THREE.Scene;
      this.scene.fog = new THREE.FogExp2(0x000000, 0.002);
      this.renderer = new THREE.WebGLRenderer({
        antialias: true
      });
      this.renderer.setClearColor(this.scene.fog.color, 1);
      this.renderer.autoClear = false;
      container.appendChild(this.renderer.domElement);
      this.passes = {
        render: new THREE.RenderPass(this.scene, this.camera),
        fxaa: new THREE.ShaderPass(THREE.FXAAShader),
        bloom: new THREE.BloomPass(1.0),
        copy: new THREE.ShaderPass(THREE.CopyShader)
      };
      this.passes.copy.renderToScreen = true;
      this.composer = new THREE.EffectComposer(this.renderer);
      this.composer.addPass(this.passes.render);
      this.composer.addPass(this.passes.fxaa);
      this.composer.addPass(this.passes.bloom);
      this.composer.addPass(this.passes.copy);
      window.addEventListener('resize', this.onWindowResize);
      this.onWindowResize();
      this.animate();
    }

    World.prototype.animate = function(timestamp) {
      var _ref;
      this.delta = timestamp - ((_ref = this.prevTimestamp) != null ? _ref : timestamp);
      this.prevTimestamp = timestamp;
      requestAnimationFrame(this.animate);
      this.scene.visit();
      return this.render();
    };

    World.prototype.render = function() {
      this.renderer.clear();
      return this.composer.render(0.05);
    };

    World.prototype.onWindowResize = function() {
      this.windowHalf = {
        x: window.innerWidth / 2,
        y: window.innerHeight / 2
      };
      this.camera.aspect = window.innerWidth / window.innerHeight;
      this.camera.updateProjectionMatrix();
      this.renderer.setSize(window.innerWidth, window.innerHeight);
      this.passes.fxaa.uniforms['resolution'].value.set(1 / window.innerWidth, 1 / window.innerHeight);
      return this.composer.reset();
    };

    return World;

  })();

}).call(this);
