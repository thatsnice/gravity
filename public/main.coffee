###

Improvement ideas

* Move default config to its own file
* UI for editing scene
* toggleable drawing of forces
* Normalize starting barycenter and momentum to keep everything centered
* Different radii for different bodies
* Console interface (manage scene with typed commands)

###

Vector = Phaser.Math.Vector2

Vector::scaled = (scalar) -> @clone().scale scalar

now = -> Date.now()

gameState =
  bodies:     []
  timeScale:  5.0 * 10**-14
  G:          1.0 * 10**-29

accessors = (names..., definer) ->
  for name in names
    {get, set} = definer name

    Object.defineProperty @, name,
      {get, set, configurable: true, enumerable: true}

preload = ->
  return null

create = ->
  addBody = (name, color, pos, vel, mass) =>
    [{x, y}] =
      [pos, vel] =
      [pos, vel].map (v) -> new Vector v

    gameState.bodies.push body = @add.circle x, y, 5, color, 1
    Object.assign body, {name, pos, vel, mass, acc: new Vector}
    
  addBody 'sun',     0xFFFF00,  {x: 1220,       y: 600}, {x: 0, y: 0        }, 1.00e31
  addBody 'earth',   0x0000FF,  {x: 1850,       y: 600}, {x: 0, y:-1.100e12 }, 5.00e24
  addBody 'moon',    0xFFFFFF,  {x: 1850.00400, y: 600}, {x: 0, y:-1.100e12 }, 1.00e21
  addBody 'no moon',  0x000000, {x: 0,          y:   0}, {x: 0, y: 0.000e1  }, 1e1

  gameState.lastUpdate = now()

  return null

update = ->
  dt  = -gameState.lastUpdate + t = now()
  dt *=  gameState.timeScale
  gameState.lastUpdate = t

  for   a, i in gameState.bodies
    for b    in gameState.bodies[i + 1 ..   ]
      dist = new Vector(b.pos).subtract a.pos
      GMm = a.mass * b.mass * gameState.G
      r   = GMm / dist.lengthSq()
      th  = dist.angle()

      f = (new Vector).setToPolar th, r

      a.acc.add      f
      b.acc.subtract f

    a.vel.add a.acc.scaled dt if i
    a.pos.add a.vel.scaled dt
    a.acc.set 0, 0
    {x: a.x, y: a.y} = a.pos

  return null

config =
  width:  '100%'
  height: '100%'
  fps: 1

  scene: { preload, create, update }


Object.assign window, {
    game      : new Phaser.Game config
    gameState
    Vector
  }
