
local mk = {}

function mk.boulder(world, x,y)
    local c = mk.circle(world, x, y, 40)
    c:setCollisionClass("Solid")
    c:setAngularDamping(1)
    c:setMass(4)
    return c 
  end
  
function mk.rect(world, x, y, w, h)
    local r = world:newRectangleCollider(x, y, w, h) 
    -- Types can be 'static', 'dynamic' or 'kinematic'. Defaults to 'dynamic'
    r:setCollisionClass("Solid")
    return r
end
  
function mk.circle(world, x, y, r)
    local c = world:newCircleCollider(x, y, r)
    c:setCollisionClass("Solid")
    return c 
end

function mk.player(world, x, y)
    local w,h = 35, 70
    -- position players' feet at where the arrow points
    y = y - h
    leg = world:newRectangleCollider(x, y, w, h)
    leg:setCollisionClass("Player")
    leg:setObject(leg)
    leg:setFriction(10)
    leg:setMass(3.5)
    leg:setPreSolve(function(collider_1, collider_2, contact)
        local vx,vy = collider_1:getLinearVelocity()
        local v = math.abs(vx)+math.abs(vy) + math.abs(collider_1:getAngularVelocity())
    
        if(v>400) then
          assets.sfx.stortsmack:play()
        elseif(v>250)then
          assets.sfx.smack:play()
        end
    end)
    return {
      width = w,
      height = h,
      leg = leg,
      grounded = false,
      holding = false
    }
  end


function mk.chick(world, x, y)
    x,y = x, y-200
    local r = mk.rect(world, x, y, 30, 200)
    return r
end

  return mk