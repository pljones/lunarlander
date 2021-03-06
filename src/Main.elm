module Main where

import Keyboard exposing (wasd,arrows)
import StartApp exposing (App)
import Task exposing (Task)
import Html exposing (..)
import Html.Attributes exposing (..)
import Effects exposing (..)
import Signal exposing (Address)
import GameView
import System exposing (..)
import Time exposing (fps,Time)
import Signal exposing ((<~))

------------------------------------------------------------

instructions : String
instructions = """
Land the ship slowly and safely on the landing pad at the bottom of the screen to earn a point.

Use WASD or the arrow keys to thrust your ship, but don't run out of fuel!
"""

rootView : Address Action -> Model -> Html
rootView channel model =
  div [style [("text-align", "center")]]
      [h1 [] [text "Lunar Lander"]
      ,p [] [text instructions]
      ,GameView.root model]

------------------------------------------------------------

update : Action -> Model -> (Model, Effects Action)
update action model =
  (case action of
     Tick t -> let newMomentum = { dx = model.momentum.dx
                                 , dy = model.momentum.dy + gravity}
                   newPosition = { x = model.position.x + newMomentum.dx
                                 , y = model.position.y + newMomentum.dy }
               in if newPosition.y > canvasSize.height
                  then {initialModel | score <- model.score + (if newMomentum.dy < maxImpactSpeed && (model.position.x > landingPad.left && (model.position.x - landingPad.left) < landingPad.width)
                                                               then 1
                                                               else -1)}
                  else {model | momentum <- newMomentum
                              , position <- newPosition}

     Thrust direction -> let newMomentum = { dx = model.momentum.dx + ((toFloat direction.x * thrustSize) * gravity)
                                           , dy = model.momentum.dy - (toFloat direction.y * thrustSize)}
               in if model.fuel > 0
                  then {model | fuel <- model.fuel - (abs direction.x + abs direction.y)
                              , momentum <- newMomentum}
                  else model
  ,none)

------------------------------------------------------------

app : App Model
app = StartApp.start {init = (initialModel, none)
                     ,view = rootView
                     ,update = update
                     ,inputs = [Tick <~ fps 25
                               ,Thrust <~ arrows
                               ,Thrust <~ wasd]}

main : Signal Html
main = app.html

port tasks : Signal (Task.Task Never ())
port tasks = app.tasks
