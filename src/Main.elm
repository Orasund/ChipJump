port module Main exposing (..)

import Browser
import Browser.Events
import Config
import Game exposing (Game, ObjectId, PlayerPos(..))
import Html exposing (Html)
import Json.Encode exposing (Value)
import Port
import View


port receive : (Value -> msg) -> Sub msg


port send : Value -> Cmd msg


type alias Model =
    { game : Game
    , msSinceLastBeat : Float
    , showTitle : Bool
    }


type Msg
    = NextFrameRequested Float
    | ActivatePlatform ObjectId
    | StartGame


maxDelta =
    (60 * 1000) / (Config.bpm * toFloat Config.maxJumpSize)


calcRatioToNextBeat : { msSinceLastBeat : Float } -> Float
calcRatioToNextBeat args =
    args.msSinceLastBeat / maxDelta


init : () -> ( Model, Cmd Msg )
init () =
    ( { game = Game.new
      , msSinceLastBeat = 0
      , showTitle = True
      }
    , Cmd.none
    )


view : Model -> Html Msg
view model =
    if model.showTitle then
        View.titleScreen { start = StartGame }

    else
        model.game
            |> View.fromGame
                { ratioToNextBeat =
                    calcRatioToNextBeat
                        { msSinceLastBeat = model.msSinceLastBeat }
                , onClick = ActivatePlatform
                }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NextFrameRequested delta ->
            let
                msSinceLastBeat =
                    model.msSinceLastBeat + delta
            in
            if msSinceLastBeat >= maxDelta then
                model.game
                    |> Game.nextBeat
                    |> (\( game, notes ) ->
                            ( { model
                                | msSinceLastBeat = msSinceLastBeat - maxDelta
                                , game = game
                              }
                            , notes
                                |> Port.playSound
                                |> send
                            )
                       )

            else
                ( { model | msSinceLastBeat = msSinceLastBeat }, Cmd.none )

        ActivatePlatform platformId ->
            ( { model
                | game =
                    model.game
                        |> Game.activatePlatform platformId
                        |> Game.recheckNextPlayerPos
              }
            , Cmd.none
            )

        StartGame ->
            ( { model | showTitle = False }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    if model.showTitle then
        Sub.none

    else if model.game.running then
        [ Browser.Events.onAnimationFrameDelta
            NextFrameRequested
        ]
            |> Sub.batch

    else
        Sub.none


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
