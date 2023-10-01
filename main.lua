playerRectangle = {
    x = 20,
    y = 20,
    width = 50,
    height = 50
}

ball = {
    x = 10,
    y = 10,
    radius = 20
}

player = {
    rectangle = playerRectangle,
    points = 0
}

function clamp(value, min, max)
    if value < min then
        return min
    elseif value > max then
        return max
    else
        return value
    end
end

function initGameplay()
end

function drawRectangle(rectangle)
    love.graphics.rectangle(
        "fill",
        rectangle.x,
        rectangle.y,
        rectangle.width,
        rectangle.height
    )
end

function drawBall()
    love.graphics.circle("fill", ball.x, ball.y, ball.radius)
end

function drawPlayer()
    drawRectangle(player.rectangle)
end

function love.load()
end

function love.update(dt)
    width, height = love.graphics.getDimensions()
    player.rectangle.x = clamp(love.mouse.getX() - (player.rectangle.width / 2), 0, width - player.rectangle.width)
    player.rectangle.y = clamp(love.mouse.getY() - (player.rectangle.height / 2), 0, height - player.rectangle.height)
end

function love.draw()
    drawPlayer()
    drawBall()
end
