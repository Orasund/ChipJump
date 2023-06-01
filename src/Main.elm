module Main exposing (..)

import Browser
import Browser.Events
import Config
import Game exposing (Game, PlatformId, PlayerPos(..))
import Html exposing (Html)
import View


type alias Model =
    { game : Game
    , msSinceLastBeat : Float
    , beatsPlayed : Int
    }


type Msg
    = NextFrameRequested Float
    | ActivatePlatform PlatformId


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
            ( if msSinceLastBeat >= maxDelta then
                { model
                    | msSinceLastBeat = msSinceLastBeat - maxDelta
                    , beatsPlayed = model.beatsPlayed + 1
                    , game = model.game |> Game.nextPlayerPos
                }

              else
                { model | msSinceLastBeat = msSinceLastBeat }
            , Cmd.none
            )

        ActivatePlatform platformId ->
            ( { model | game = model.game |> Game.togglePlatform platformId |> Game.recheckNextPlayerPos }
            , Cmd.none
            )


subscriptions : Model -> Sub Msg
subscriptions model =
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
