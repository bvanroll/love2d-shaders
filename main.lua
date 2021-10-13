LOGLEVEL = 2



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
	vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords )
	{
		float r = screen_coords.x/w;
		float g = screen_coords.y/h;
		float b = (r + g) / 2;
		float a = 1 - distance(screen_coords, mouse)/ (lum) ;
		color = vec4(r, g, b, a+0.5);
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
	
	h = love.graphics.getHeight( )
	w = love.graphics.getWidth( )
end


function love.update(dt)
	t = t + dt
	mouse_x, mouse_y = love.mouse.getPosition( )
	log("mouse x " .. mouse_x)
	log("mouse y " .. mouse_y)
	shader:send("w", w)
	shader:send("h", h)
	shader:send("mouse", {mouse_x, mouse_y})
	shader:send("lum", lum)
	log("dt = " .. dt)
	if love.keyboard.isDown('space') then
		lum = lum + 1
	elseif love.keyboard.isDown('rctrl') then
		lum = lum - 1
	elseif love.keyboard.isDown('lctrl') then
		lum = lum -1
  	end
end


function love.draw(dt)
	love.graphics.setShader(shader)
    love.graphics.rectangle("fill", 0, 0, w, h)
	love.graphics.setShader()
    love.graphics.rectangle("fill", 400, 400, 100, 100)

end


