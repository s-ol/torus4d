local lg = love.graphics
local w, h = lg.getDimensions()
local scale = math.min(w, h) * 0.3

lg.setLineJoin "none"
love.keyboard.setKeyRepeat(true)
local stepsize = 1900
local time = 0

function sphere()
  local four_d = {}
  for i=-2,2,0.001 do
    local phi = i * math.pi * 10
    local xi = math.cos(i*math.pi/2)
    local p = {
      math.cos(phi) * xi,
      math.sin(phi) * xi,
      i,
    }
    four_d[#four_d+1] = p
  end
  return four_d
end

function torus(loops, edge)
  local four_d = {}

  local a, b = math.max(1, loops), math.max(1, 1/loops)
  local stepsize = edge * math.max(a,b)

  for i=-1,1,2/stepsize do
    local phi = i * math.pi * a
    local the = i * math.pi * b
    local kl_z = math.cos(the)
    local kl_x = math.cos(phi) * math.sin(the)
    local kl_y = math.sin(phi) * math.sin(the)
    local p = {
      math.cos(phi) + kl_x * 0.6,
      math.sin(phi) + kl_y * 0.6,
      kl_z,
    }
    four_d[#four_d+1] = p
  end
  return four_d
end

function asx(alpha, beta, ...)
  if not beta then
    return { math.cos(alpha), math.sin(alpha) }
  end

  local n = {
    math.cos(alpha),
    unpack(asx(beta, ...))
  }

  n[2] = n[2] + math.sin(alpha) * math.cos(beta)
  n[3] = n[3] + math.sin(alpha) * math.sin(beta)
  return n
end

function rtorus(loops) -- loops, edge)
  local four_d, angles = {}, {}
  local d = #loops

  local n = math.min(unpack(loops))
  for i=1,d do
    loops[i] = loops[i] / n
  end

  for i=0,1,1/stepsize do
    for j=1,d do
      angles[j] = 2 * math.pi * i * loops[j]
    end
    local p = asx(unpack(angles))
    for j=1,d+1 do
      p[j] = p[j] / d
    end
    four_d[#four_d+1] = p
  end
  return four_d
end

local mult, paused, showthree = 1
local four_d, hilight = nil, 1

function draw(points, aa, bb, cc, dd, other)
  local two_d = {}
  local x_z, y_z = love.mouse.getX()/w-0.5, love.mouse.getY()/h-0.5

  for i,p in ipairs(points) do
    local a, b, c, d = p[aa] or 0, p[bb] or 0, p[cc] or 0, p[dd] or 0

    local x = scale * (a + c * x_z)
    local y = scale * (b + c * y_z)

    local color = (180 + c * 70) / 255
    if math.floor(hilight) == i then
      lg.setColor(255, 255, 255)
    elseif other then
      lg.setColor(color*245, color*66, color*98)
    else
      lg.setColor(color*66, color*244, color*98)
    end
    lg.circle('fill', x, y, (color + 2) * 3)

    two_d[#two_d+1] = x
    two_d[#two_d+1] = y
  end
end

function love.draw()
  lg.setBlendMode('lighten', 'premultiplied')

  lg.push()
  lg.translate(w/4, h/4)
  draw(four_d, 1, 2, 3, 4)
  if showthree then
    draw(three_d, 1, 2, 3, 0, true)
  end
  lg.pop()

  lg.push()
  lg.translate(3*w/4, h/4)
  draw(four_d, 1, 4, 2, 3)
  if showthree then
    draw(three_d, 1, 0, 2, 3, true)
  end
  lg.pop()

  lg.push()
  lg.translate(w/4, 3*h/4)
  draw(four_d, 3, 2, 4, 1)
  if showthree then
    draw(three_d, 3, 2, 0, 1, true)
  end
  lg.pop()

  lg.push()
  lg.translate(3*w/4, 3*h/4)
  draw(four_d, 3, 4, 1, 2)
  if showthree then
    draw(three_d, 3, 0, 1, 2, true)
  end
  lg.pop()


  lg.setColor(255, 255, 255)
  lg.setBlendMode('alpha')
  lg.print(string.format('%.2f + %f', loopz, mult), 10, 10)
  --lg.line(two_d)
end

function love.keypressed(key)
  if key == 'space' then
    paused = not paused
  elseif key == 'up' then
    mult = mult + 1
  elseif key == 'left' then
    time = 200 * (math.ceil(loopz) - 2)
  elseif key == 'right' then
    time = 200 * math.floor(loopz)
  elseif key == 'down' then
    mult = mult - 1
  elseif key == 'a' then
    hilight = (hilight - 10) % stepsize
  elseif key == 'd' then
    hilight = (hilight + 10) % stepsize
  elseif key == 'q' then
    showthree = not showthree
  elseif key == 'w' then
    mirror = not mirror
  end
end

function love.update(dt)
  if not paused then
    local delta = dt * math.pow(2, mult)
    if love.keyboard.isDown'lshift' then
      delta = - delta
    end
    time = time + delta
  end
  loopz = 1 + time / 200
  if mirror then
    four_d = rtorus({1/loopz, 1, 1/4})
    three_d = rtorus({1/loopz, 1})
  else
    four_d = rtorus({loopz, 1, 4})
    three_d = rtorus({loopz, 1})
  end
end
