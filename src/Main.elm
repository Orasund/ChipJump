port module Main exposing (..)

import Array
import Browser
import Browser.Events
import Config
import Dict
import Game exposing (Game, PlatformId, PlayerPos(..))
import Html exposing (Html)
import Json.Encode exposing (Value)
import Port
import View


port receive : (Value -> msg) -> Sub msg


port send : Value -> Cmd msg


type alias Model =
    { game : Game
    , msSinceLastBeat : Float
    , beatsPlayed : Int
    , showTitle : Bool
    }


type Msg
    = NextFrameRequested Float
    | ActivatePlatform PlatformId
    | StartGame


maxDelta =
    (60 * 1000) / Config.bpm


calcRatioToNextBeat : { msSinceLastBeat : Float } -> Float
calcRatioToNextBeat args =
    args.msSinceLastBeat / maxDelta


init : () -> ( Model, Cmd Msg )
init () =
    ( { game = Game.new
      , msSinceLastBeat = 0
      , beatsPlayed = 0
      , showTitle = True
      }
    , Cmd.none
    )


view : Model -> Html Msg
view model =
    model.game
        |> View.fromGame
            { ratioToNextBeat =
                calcRatioToNextBeat
                    { msSinceLastBeat = model.msSinceLastBeat }
            , onClick = ActivatePlatform
            , beatsPlayed = model.beatsPlayed
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
                ( { model
                    | msSinceLastBeat = msSinceLastBeat - maxDelta
                    , beatsPlayed = model.beatsPlayed + 1
                    , game = model.game |> Game.nextPlayerPos
                  }
                , model.game.platforms
                    |> Dict.get (Game.platformIdOfPlayer model.game)
                    |> Maybe.andThen
                        (\{ position } ->
                            let
                                ( _, y1 ) =
                                    position
                            in
                            model.game.track |> Array.get y1
                        )
                    |> Maybe.withDefault []
                    |> Port.playSound
                    |> send
                )

            else
                ( { model | msSinceLastBeat = msSinceLastBeat }, Cmd.none )

        ActivatePlatform platformId ->
            ( { model | game = model.game |> Game.togglePlatform platformId |> Game.recheckNextPlayerPos }
            , Cmd.none
            )

        StartGame ->
            ( { model | showTitle = False }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    if model.showTitle then
        Sub.none

    else
        case model.game.player of
            OnPlatform _ ->
                Sub.none

            Jumping _ ->
                Browser.Events.onAnimationFrameDelta
                    NextFrameRequested


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
