LOGLEVEL = 0
HC = require 'lib/HC'


-- severity levels:
-- 0 DEBUG
-- 1 GEN
-- 2 ERR
-- 3 CRIT

local pixelcode = [[
	extern number w;
	extern number h;
	extern number lum;
	extern vec2 mouse;
	extern vec2 player;
	vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords )
	{
		float r = screen_coords.x/w;
		float g = screen_coords.y/h;
		float b = 1 - distance(screen_coords, mouse)/ (lum) ;
		float a = 1 - distance(screen_coords, player)/ (lum) ;
		color = vec4(r, g, b, a+1);
		return Texel(tex, texture_coords) * color;
	}
]]


local vertexcode = [[
	vec4 position( mat4 transform_projection, vec4 vertex_position )
	{
		return transform_projection * vertex_position;
	}
]]

w = 1
h = 1
lum = 50
t = 0

function log(message, severity)
	severity = severity or 0;
	if severity >= LOGLEVEL then
		print(message)
	end
end




function love.load()

	shader = love.graphics.newShader(pixelcode, vertexcode)
	world = love.physics.newWorld( 0, 0, true )
	h = love.graphics.getHeight( )
	w = love.graphics.getWidth( )
	player = love.physics.newBody( world, 500, 500, "dynamic")
	circle = HC.circle(400,300,20)
end


function love.update(dt)
	t = t + dt
	mouse_x, mouse_y = love.mouse.getPosition( )
	player_x, player_y = mouse_x, mouse_y
	--player:applyForce()
	shader:send("w", w)
	shader:send("h", h)
	shader:send("mouse", {mouse_x, mouse_y})
	shader:send("player", {player_x, player_y})
	shader:send("lum", lum)
	if love.keyboard.isDown('space') then
		lum = lum + 1
	elseif love.keyboard.isDown('rctrl') then
		lum = lum - 1
	elseif love.keyboard.isDown('lctrl') then
		lum = lum -1
  	end
end

function getAngle(x1, y1, x2, y2)
	return math.atan2(y2 - y1, x2 - x1) * 180 / math.pi
end

function drawPlayer()
	x, y = player:getPosition( )
	angle = getAngle(x, y, mouse_x, mouse_y)
	love.graphics.print( angle, 0, 0, 0, 1, 1, 0, 0, 0, 0 )
	player:setAngle(angle)
	player:applyForce(100, 100)
	log(player:getAngularVelocity())

	love.graphics.circle( "fill", x, y, 5 )
end


function love.draw(dt)
	love.graphics.setShader(shader)
    love.graphics.rectangle("fill", 0, 0, w, h)
	love.graphics.setShader()
    drawPlayer()
end


