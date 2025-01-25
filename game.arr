use context starter2024
import image as I
import reactors as R


CAR = image-url("https://code.pyret.org/shared-image-contents?sharedImageId=1lk5gAQioKeD5gtYNuUX7d_ZBpAawKevS")
OBSTACLE = image-url("https://code.pyret.org/shared-image-contents?sharedImageId=1ZPIgWZyjPVzprTSzp_DvK8WIeq7QvDw7") 
WIDTH = 400
HEIGHT = 600
LANE-WIDTH = WIDTH / 2
GAME-SPEED = 30
LANE-SWITCH = 200
COLLISION-THRESHOLD = 140
BLANK-SCENE = I.empty-scene(WIDTH, HEIGHT)
ROAD = I.rectangle(WIDTH, HEIGHT, "solid", "white")
DIVIDER = I.rectangle(10, HEIGHT, "solid", "black")
BACKGROUND = I.place-image(DIVIDER, WIDTH / 2, HEIGHT / 2, ROAD)

data Posn:
  | posn(x, y)
end


data state-of-game:
  | game(
      car :: Posn, 
      obstacle :: Posn, 
      crash-and-burn :: Boolean,
      score :: Number
    )
end


INIT-STATE = game(
  posn(LANE-WIDTH / 2, HEIGHT - 100), 
  posn(LANE-WIDTH + (LANE-WIDTH / 2), 0), 
  false, 
  0
)


fun distance(p1, p2):
  fun square1(n): n * n end
  num-sqrt(square1(p1.x - p2.x) + square1(p1.y - p2.y))
end

fun are-overlapping(car-posn, obstacle-posn):
  distance(car-posn, obstacle-posn) < COLLISION-THRESHOLD
end


fun scene(state):
  bg-with-car = I.place-image(CAR, 
    state.car.x,
    state.car.y,
    BACKGROUND)
  
  scene-with-obstacle = I.place-image(OBSTACLE,
    state.obstacle.x,
    state.obstacle.y,
    bg-with-car)
  

  if state.crash-and-burn:
    I.place-image(
      text("", 50, "red"),
      WIDTH / 2,
      HEIGHT / (2 - 50),
      I.place-image(
        text("Score: " + num-to-string(state.score), 30, "black"),
        WIDTH / 2,
        HEIGHT / (2 + 50),
        scene-with-obstacle
      )
    )
  else:
    I.place-image(
      text("Score: " + num-to-string(state.score), 24, "black"),
      WIDTH - 100,
      50,
      scene-with-obstacle
    )
  end
end


fun move-obstacle-y(y):
  y + GAME-SPEED
end

fun update-obstacle(obs):
  if obs.y > HEIGHT:
    posn(if num-random(2) == 0:
        LANE-WIDTH / 2 
      else: LANE-WIDTH + (LANE-WIDTH / 2) end, 0)
  else:
    posn(obs.x, move-obstacle-y(obs.y))
  end
end


fun car-control(state, key):
  cases(state-of-game) state:
    | game(car, obstacle, crash-and-burn, score) =>
        ask:
          | key == "left" then: 
          game(posn(LANE-WIDTH / 2, car.y), obstacle, crash-and-burn, score)
          | key == "right" then:
          game(posn(LANE-WIDTH + (LANE-WIDTH / 2), car.y), obstacle, crash-and-burn, score)
          | otherwise: state
        end
    end
  end


fun tick(state):
  if state.crash-and-burn:
    state
  else:
    new-obstacle = update-obstacle(state.obstacle)
    game(
      state.car, 
      new-obstacle, 
      are-overlapping(state.car, new-obstacle),
      state.score + 1
    )
  end
end


anim = reactor:
  init: INIT-STATE,
  on-tick: tick,
  on-key: car-control,
  to-draw: scene,
  stop-when: lam(s): s.crash-and-burn end
end

R.interact(anim)