--[[
    GD50
    Final Project

    --PLayer Jump State --

]]

PlayerJumpState = Class{__includes = BaseState}

function PlayerJumpState:init(player, gravity)
    self.player = player
    self.gravity = gravity

    self.animation = Animation {
        frames = {4},
        interval = 1
    }
    self.player.currentAnimation = self.animation


end

function PlayerJumpState:enter(params)

    gSounds['jump']:play()
    self.player.dy = PLAYER_JUMP_VELOCITY
end

function PlayerJumpState:update(dt)

    self.player.currentAnimation:update(dt)

    self.player.dy = self.player.dy + self.gravity
    self.player.y = self.player.y + (self.player.dy * dt)

    -- go into the falling state when y velocity is positive
    if self.player.dy >= 0 then
        self.player:changeState('falling')
    end

    self.player.y = self.player.y + (self.player.dy * dt)

    -- look at two tiles above our head and check for collisions; 6 pixels of leeway for getting through gaps
    local tileLeft = self.player.map:pointToTile(self.player.x + 8, self.player.y)
    local tileRight = self.player.map:pointToTile(self.player.x + self.player.width - 20, self.player.y)

    -- if we get a collision up top, go into the falling state immediately
    if (tileLeft and tileRight) and (tileLeft:collidable() or tileRight:collidable()) then
        self.player.dy = 0
        self.player:changeState('falling')

    -- else test our sides for blocks
    elseif love.keyboard.isDown('left') then
        self.player.direction = 'left'
        self.player.x = self.player.x - PLAYER_WALK_SPEED * dt
        self.player:checkLeftCollisions(dt)
    elseif love.keyboard.isDown('right') then
        self.player.direction = 'right'
        self.player.x = self.player.x + PLAYER_WALK_SPEED * dt
        self.player:checkRightCollisions(dt)
    end

    -- check if we've collided with any collidable game objects
    for k, object in pairs(self.player.level.objects) do
        if object:collides(self.player) then
            if object.solid then
                object.onCollide(object)

                self.player.y = object.y + object.height
                self.player.dy = 0
                self.player:changeState('falling')
            elseif object.consumable then
                object.onConsume(self.player)
                table.remove(self.player.level.objects, k)
            end
        end
    end

    -- check if we've collided with any entities and die if so
    for k, entity in pairs(self.player.level.entities) do
        if entity:collides(self.player) and not self.player.invulnerable then
          self.player:damage(1)
          self.player:goInvulnerable(2)
          gSounds['hit-player']:play()

          if self.player.health == 0 then
           gSounds['death']:play()
           gStateMachine:change('game-over', {
             score = self.player.score,
             level = self.player.levelnumber
           })
          end

        end
    end
end
