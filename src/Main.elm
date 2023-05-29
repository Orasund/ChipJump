module Main exposing (..)

import Browser
import Browser.Events
import Dict
import Game exposing (Game)
import Html exposing (Html)
import View


type alias Model =
    { game : Game
    }


type Msg
    = NextFrameRequested Float


init : () -> ( Model, Cmd Msg )
init () =
    ( { game = Game.new }, Cmd.none )


view : Model -> Html Msg
view model =
    model.game |> View.fromGame


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NextFrameRequested delta ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Browser.Events.onAnimationFrameDelta NextFrameRequested


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
