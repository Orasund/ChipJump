port module Main exposing (..)

import Browser
import Browser.Events
import Dict
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
    , showSettings : Bool
    , volume : Float
    , isMuted : Bool
    }


type Msg
    = NextFrameRequested Float
    | ActivatePlatform ObjectId
    | ToggleSettings
    | SetVolume Float
    | ToggleMute
    | StartGame


calcRatioToNextBeat : { msSinceLastBeat : Float } -> Game -> Float
calcRatioToNextBeat args game =
    args.msSinceLastBeat / Game.calcMaxDelta game


init : () -> ( Model, Cmd Msg )
init () =
    ( { game = Game.new
      , msSinceLastBeat = 0
      , showTitle = True
      , showSettings = False
      , volume = 0
      , isMuted = False
      }
    , Cmd.none
    )


view : Model -> Html Msg
view model =
    if model.showSettings then
        View.settingsScreen
            { close = ToggleSettings
            , setVolume = SetVolume
            , volume = model.volume
            , isMute = model.isMuted
            , mute = ToggleMute
            }

    else if model.showTitle then
        View.titleScreen
            { start = StartGame
            , toggleSettings = ToggleSettings
            }

    else
        model.game
            |> View.fromGame
                { ratioToNextBeat =
                    calcRatioToNextBeat
                        { msSinceLastBeat = model.msSinceLastBeat }
                        model.game
                , onClick = ActivatePlatform
                , start = StartGame
                , toggleSettings = ToggleSettings
                }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NextFrameRequested delta ->
            let
                msSinceLastBeat =
                    model.msSinceLastBeat + delta

                maxDelta =
                    Game.calcMaxDelta model.game
            in
            if msSinceLastBeat >= maxDelta then
                model.game
                    |> Game.nextBeat
                    |> (\( game, dict ) ->
                            ( { model
                                | msSinceLastBeat = msSinceLastBeat - maxDelta
                                , game = game
                              }
                            , dict
                                |> Dict.toList
                                |> List.map
                                    (\( instrument, notes ) ->
                                        notes
                                            |> Port.playSound instrument
                                            |> send
                                    )
                                |> Cmd.batch
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

        ToggleSettings ->
            ( { model | showSettings = not model.showSettings }
            , Cmd.none
            )

        StartGame ->
            ( { model
                | game = Game.new
                , msSinceLastBeat = 0
                , showTitle = False
              }
            , Cmd.none
            )

        SetVolume amount ->
            ( { model | volume = amount }
            , Port.setVolume amount
                |> send
            )

        ToggleMute ->
            ( { model | isMuted = not model.isMuted }
            , Port.toggleMute |> send
            )


subscriptions : Model -> Sub Msg
subscriptions model =
    if model.showTitle || model.showSettings then
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
