--[[
    GD50
    Final Project

    Author: Maggie Crocamo
    mjcrocamo@gmail.com

    This is a classic platformer designed game. The goal is to navigate various
    levels from a side perspective as blue beard the pirate. Jumping onto enemies
    inflicts damage, using a sword inflicts damage and kills enemies,
    and certain friends (like bluebeard's parrot) are able tp pick up extra objects
    for points and health. The goal is to get to the end of the level, grab the key,
    and unlock the treasure chest.

    Art pack:
    https://www.gamedeveloperstudio.com/
    https://opengameart.org/

    Music:
    https://freesound.org/people/Sirkoto51/sounds/393818/
    https://opengameart.org/
]]

require 'src/Dependencies'

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.graphics.setFont(gFonts['medium'])
    love.window.setTitle("Blue Beard's Adventure")

    math.randomseed(os.time())

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        vsync = true,
        resizable = true,
        canvas = false
    })

    gStateMachine = StateMachine {
        ['start'] = function() return StartState() end,
        ['play'] = function() return PlayState() end,
        ['game-over'] = function() return GameOverState() end
    }
    gStateMachine:change('start')

    gSounds['music']:setLooping(true)
    gSounds['music']:setVolume(0.5)
    gSounds['music']:play()

    love.keyboard.keysPressed = {}
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end

    love.keyboard.keysPressed[key] = true
end

function love.keyboard.wasPressed(key)
    return love.keyboard.keysPressed[key]
end

function love.update(dt)
    Timer.update(dt)
    gStateMachine:update(dt)

    love.keyboard.keysPressed = {}
end

function love.draw()
    push:start()
    gStateMachine:render()
    push:finish()
end
