playerRectangle = {
    x = 20,
    y = 20,
    width = 100,
    height = 20
}

images = {
    background = '',
    ball = '',
    paddle = ''
}

initialVelocity = 150

ball = {
    x = 10,
    y = 10,
    direction = { x = 0.5, y = 0.5 },
    radius = 20,
    velocity = initialVelocity,
    isColliding = false
}

maxVelocity = 1100
circleRadius = 250

player = {
    rectangle = playerRectangle,
    points = 0,
    maxPoints = 0
}

COLLIDED_SIDE = {
    LEFT = "LEFT",
    RIGHT = "RIGHT",
    INSIDE = "INSIDE",
    OUTSIDE = "OUTSIDE"
}

function getRotatedPoint(point, center, angle)
    dx = point.x - center.x
    dy = point.y - center.y

    return {
        x = center.x + (dx * math.cos(angle) - dy * math.sin(angle)),
        y = center.y + (dx * math.sin(angle) + dy * math.cos(angle))
    }
end

function getRotatedRect(rectangle, angle)
    center = { x = rectangle.x + rectangle.width / 2, y = rectangle.y + rectangle.height / 2 }
    
    return {
        topLeft = getRotatedPoint({ x = rectangle.x, y = rectangle.y }, center, angle),
        topRight = getRotatedPoint({ x = rectangle.x + rectangle.width, y = rectangle.y }, center, angle),
        bottomLeft = getRotatedPoint({ x = rectangle.x, y = rectangle.y + rectangle.height }, center, angle),
        bottomRight = getRotatedPoint({ x = rectangle.x + rectangle.width, y = rectangle.y + rectangle.height }, center, angle)
    }
end

function checkCircleCollisionBetweenPoints(circle, pointA, pointB)
    pointsQuantity = 100

    for i=0,pointsQuantity do
        dx = i / pointsQuantity

        intermediaryX = pointA.x + dx * (pointB.x - pointA.x)
        intermediaryY = pointA.y + dx *(pointB.y - pointA.y)
        
        hickX = math.abs(intermediaryX - circle.x);
        hickY = math.abs(intermediaryY - circle.y);

        hypotenuse = math.sqrt((hickY * hickY) + (hickX * hickX));

        if hypotenuse <= ball.radius then
            return true
        end
    end

    return false
end

function checkCircleToRectangleCollission(circle, oldRect)
    rectangle = getRotatedRect(oldRect, getPaddleAngle())

    pointsQuantity = 100

    if checkCircleCollisionBetweenPoints(circle, rectangle.bottomLeft, rectangle.bottomRight) then
        return COLLIDED_SIDE.INSIDE
    elseif checkCircleCollisionBetweenPoints(circle, rectangle.topLeft, rectangle.bottomLeft) then
        return COLLIDED_SIDE.LEFT
    elseif checkCircleCollisionBetweenPoints(circle, rectangle.topRight, rectangle.bottomRight) then
        return COLLIDED_SIDE.RIGHT
    elseif checkCircleCollisionBetweenPoints(circle, rectangle.topLeft, rectangle.topRight) then
        return COLLIDED_SIDE.OUTSIDE
    end

    return false
end

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

function getNormalizedCenterToMouseVector()
    width, height = love.graphics.getDimensions()
    mousePoint = { x = love.mouse.getX(), y = love.mouse.getY() }
    centerPoint = { x = width / 2, y = height / 2 }
    
    centerToMouseVector = { x = mousePoint.x - centerPoint.x, y = mousePoint.y - centerPoint.y }
    return normalizeVector(centerToMouseVector)
end

function drawRectangle(rectangle)
    love.graphics.setColor(0.8, 0, 0, 0.5)
    love.graphics.rectangle(
        "fill",
        rectangle.x,
        rectangle.y,
        rectangle.width,
        rectangle.height
    )
    love.graphics.setColor(0.8, 0, 0)
end

function drawBall()
    ballImage = love.graphics.getImage

    love.graphics.draw(images.ball, ball.x - 30, ball.y - 30, 0, 0.07, 0.07)
end

function getPlayerPosition()
    return { x = player.rectangle.x + player.rectangle.width / 2, y = player.rectangle.y + player.rectangle.height / 2 }
end

function getPaddleAngle()
    width, height = love.graphics.getDimensions()

    playerPosition = getPlayerPosition()
    centerPosition = { x = width / 2, y = height / 2 }

    playerPositionToCenter = { x = playerPosition.x - centerPosition.x, y = playerPosition.y - centerPosition.y }
    centerPositionToFlat = {} 
    
    if playerPosition.x < centerPosition.x then
        centerPositionToFlat = { x = 0, y = circleRadius }
    elseif playerPosition.x >= centerPosition.x then
        centerPositionToFlat = { x = 0, y = -circleRadius }
    end

    return getAngleBetween(centerPositionToFlat, playerPositionToCenter)
end

function drawPlayer()
    playerPosition = getPlayerPosition()

    love.graphics.setColor(0.8, 0, 0)
    love.graphics.translate(playerPosition.x, playerPosition.y)
	love.graphics.rotate(getPaddleAngle())
	love.graphics.translate(-playerPosition.x, -playerPosition.y)
    drawRectangle(player.rectangle)
    love.graphics.draw(images.paddle, player.rectangle.x, player.rectangle.y, 0, 0.36, 0.45)
    love.graphics.origin()
    love.graphics.setColor(1, 1, 1)
end

function updateRectangle()
    normalizedCenterToMouseVector = getNormalizedCenterToMouseVector()

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

function updateBall(dt)
    ball.x = ball.x + ball.direction.x * ball.velocity * dt
    ball.y = ball.y + ball.direction.y * ball.velocity * dt

    if checkCircleToRectangleCollission(ball, player.rectangle) and not ball.isColliding then
        normalizedCenterToMouseVector = getNormalizedCenterToMouseVector()

        player.points = player.points + 1
        if player.points > player.maxPoints then
            player.maxPoints = player.points
        end

        ball.direction.x = normalizedCenterToMouseVector.x * -1
        ball.direction.y = normalizedCenterToMouseVector.y * -1
        ball.velocity = clamp(ball.velocity + 50, ball.velocity, maxVelocity)
        ball.isColliding = true
    end
    if not checkCircleToRectangleCollission(ball, player.rectangle) then
        ball.isColliding = false
    end

    width, height = love.graphics.getDimensions()

    if ball.x + ball.radius < 0 or ball.x - ball.radius > width or ball.y + ball.radius < 0 or ball.y - ball.radius > height then
        ball.x = width / 2
        ball.y = height / 2
        ball.velocity = initialVelocity

        player.points = 0
    end
end

function drawUI()
    local font = love.graphics.getFont()
    marginX = 40
    marginY = 20

    love.graphics.setColor(0, 0, 0)
    pointsText = "Points: " .. player.points
    highScoreText = "High score: " .. player.maxPoints
    developersText = "Developed by Juan Digilio and Maximiliano Feldman"
    fontText = "Font by Steve Matteson"
    local pointsTextWidth = font:getWidth(pointsText)
    local pointsTextHeight = font:getHeight(pointsText)
	local highScoreTextWidth = font:getWidth(highScoreText)
    local highScoreTextHeight = font:getHeight(highScoreText)
    local developersTextHeight = font:getHeight(developersText)
    local developersTextWidth = font:getWidth(developersText)
    local fontTextWidth = font:getWidth(fontText)
    local fontTextHeight = font:getHeight(fontText)

    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill", marginX - 5, marginY - 5, pointsTextWidth + 10, pointsTextHeight + 10, 10, 10)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(pointsText, marginX, marginY)

    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill", width - highScoreTextWidth - marginX - 5, marginY - 5, highScoreTextWidth + 10, highScoreTextHeight + 10, 10, 10)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(highScoreText, width - highScoreTextWidth - marginX, marginY)
    
    
    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill", marginX - 5, height - marginY + 15 - developersTextHeight - 5, developersTextWidth + 10, developersTextHeight + 10, 10, 10)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(developersText, marginX, height - marginY + 15 - developersTextHeight)
    
    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill", width - fontTextWidth - marginX - 5, height - marginY + 15 - fontTextHeight - 5, fontTextWidth + 10, fontTextHeight + 10, 10, 10)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(fontText, width - fontTextWidth - marginX, height - marginY + 15 - fontTextHeight)
    
    love.graphics.setColor(1, 1, 1)
end

function love.load()
    love.window.setMode(900, 600)
    width, height = love.graphics.getDimensions()

    ball.x = width / 2
    ball.y = height / 2

    love.graphics.setNewFont("OpenSans.ttf", 20)
    
    images.background = love.graphics.newImage("blackHole.jpg")
    images.ball = love.graphics.newImage("ball.png")
    images.paddle = love.graphics.newImage("paddle.png")
end

function love.update(dt)
    updateRectangle()
    updateBall(dt)
end

function love.draw()
    love.graphics.draw(images.background, -230, -75, 0, 0.35, 0.35)
    drawPlayer()
    drawBall()
    drawUI()
end
