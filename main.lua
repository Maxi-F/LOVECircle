playerRectangle = {
    x = 20,
    y = 20,
    width = 100,
    height = 50
}

ball = {
    x = 10,
    y = 10,
    radius = 20
}

circleRadius = 250

player = {
    rectangle = playerRectangle,
    points = 0
}

function getScalarProductBetween(aVector, anotherVector)
    return aVector.x * anotherVector.x + aVector.y * anotherVector.y
end

function getMagnitudeFor(vector)
    return math.sqrt(vector.x^2 + vector.y^2)
end

function getAngleBetween(aVector, anotherVector)
    return math.acos(
        getScalarProductBetween(aVector, anotherVector) / 
        (getMagnitudeFor(aVector) * getMagnitudeFor(anotherVector))
    )
end

function normalizeVector(vector)
    magnitude = getMagnitudeFor(vector)
    if magnitude ~= 0 then
      return { x = vector.x / magnitude, y = vector.y / magnitude }
    end
    return vector
  end

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

function drawCenter()
    width, height = love.graphics.getDimensions()

    love.graphics.circle("line", width / 2, height / 2, circleRadius)
end

function drawPlayer()
    width, height = love.graphics.getDimensions()

    playerPosition = { x = player.rectangle.x + player.rectangle.width / 2, y = player.rectangle.y + player.rectangle.height / 2 }
    centerPosition = { x = width / 2, y = height / 2 }

    playerPositionToCenter = { x = playerPosition.x - centerPosition.x, y = playerPosition.y - centerPosition.y }
    centerPositionToFlat = {} 
    
    if playerPosition.x < centerPosition.x then
        centerPositionToFlat = { x = 0, y = circleRadius }
    elseif playerPosition.x >= centerPosition.x then
        centerPositionToFlat = { x = 0, y = -circleRadius }
    end


    angle = getAngleBetween(centerPositionToFlat, playerPositionToCenter)

    love.graphics.translate(playerPosition.x, playerPosition.y)
	love.graphics.rotate(angle)
	love.graphics.translate(-playerPosition.x, -playerPosition.y)
    drawRectangle(player.rectangle)
    love.graphics.origin()
end

function love.load()
    love.window.setMode(900, 600)
end

function love.update(dt)
    width, height = love.graphics.getDimensions()
    mousePoint = { x = love.mouse.getX(), y = love.mouse.getY() }
    centerPoint = { x = width / 2, y = height / 2 }
    
    centerToMouseVector = { x = mousePoint.x - centerPoint.x, y = mousePoint.y - centerPoint.y }
    normalizedCenterToMouseVector = normalizeVector(centerToMouseVector)
    positionVector = { 
        x = 
            (width / 2) -
            player.rectangle.width / 2 +
            normalizedCenterToMouseVector.x * circleRadius,
        y = 
            (height / 2) -
            player.rectangle.height / 2 + 
            normalizedCenterToMouseVector.y * circleRadius 
        }

    player.rectangle.x = positionVector.x
    player.rectangle.y = positionVector.y
end

function love.draw()
    drawPlayer()
    drawBall()
    drawCenter()
end
