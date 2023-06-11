module View exposing (..)

import Config
import Dict
import Game exposing (Game, ObjectId, ObjectSort(..), PlayerPos(..))
import Html exposing (Html)
import Html.Attributes
import Html.Events
import Layout
import Note exposing (Note(..))
import View.Common
import View.Object


titleScreen : { start : msg, toggleSettings : msg } -> Html msg
titleScreen args =
    [ [ "Ode to the toad"
            |> Html.text
            |> Layout.heading1 [ Html.Attributes.style "color" Config.playerColor ]
      , "By Lucas Payr & Lilith-Isa Samer" |> Layout.text [ Html.Attributes.style "color" Config.lilyPadColor ]
      ]
        |> Layout.column [ Layout.gap 8 ]
    , Layout.textButton [ Html.Attributes.class "button" ] { onPress = Just args.start, label = "Start" }
    , settingsButton { onClick = args.toggleSettings }
    ]
        |> Layout.column [ Layout.gap 100 ]
        |> Layout.el
            (Layout.centered
                ++ [ Html.Attributes.style "position" "relative"
                   , Html.Attributes.style "background-color" Config.backgroundColor
                   , Html.Attributes.style "height" (String.fromFloat Config.screenHeight ++ "px")
                   , Html.Attributes.style "width" (String.fromFloat Config.screenWidth ++ "px")
                   ]
            )


settingsScreen :
    { close : msg
    , setVolume : Float -> msg
    , volume : Float
    , isMute : Bool
    , mute : msg
    }
    -> Html msg
settingsScreen args =
    [ [ "Settings"
            |> Html.text
            |> Layout.heading1 [ Html.Attributes.style "color" Config.playerColor ]
      , "Volume:" |> Layout.text []
      , Html.input
            [ Html.Attributes.type_ "range"
            , Html.Attributes.min "-1"
            , Html.Attributes.max "1"
            , Html.Attributes.step "any"
            , Html.Attributes.value (String.fromFloat args.volume)
            , Html.Events.onInput
                (\string ->
                    string
                        |> String.toFloat
                        |> Maybe.withDefault 0
                        |> args.setVolume
                )
            ]
            []
      , [ "Mute" |> Layout.text []
        , Html.input
            [ Html.Attributes.type_ "checkbox"
            , Html.Attributes.checked args.isMute
            , Html.Events.onInput
                (\_ ->
                    args.mute
                )
            ]
            []
        ]
            |> Layout.row [ Layout.gap 8 ]
      ]
        |> Layout.column [ Layout.gap 8 ]
    , Layout.textButton [ Html.Attributes.class "button" ] { onPress = Just args.close, label = "Back" }
    ]
        |> Layout.column [ Layout.gap 100 ]
        |> Layout.el
            (Layout.centered
                ++ [ Html.Attributes.style "position" "relative"
                   , Html.Attributes.style "background-color" Config.backgroundColor
                   , Html.Attributes.style "color" Config.lilyPadColor
                   , Html.Attributes.style "height" (String.fromFloat Config.screenHeight ++ "px")
                   , Html.Attributes.style "width" (String.fromFloat Config.screenWidth ++ "px")
                   ]
            )


fromGame :
    { ratioToNextBeat : Float
    , onClick : ObjectId -> msg
    , toggleSettings : msg
    , start : msg
    }
    -> Game
    -> Html msg
fromGame args game =
    let
        getPlatformPosition id =
            game.objects
                |> Dict.get id
                |> Maybe.map (\{ start, note } -> ( note, start ))
                |> Maybe.withDefault ( Note.bang, 0 )

        playerPos =
            case game.player of
                OnPlatform id ->
                    getPlatformPosition id
                        |> calcPlayerPositionOnPlatform
                            { ratioToNextBeat = args.ratioToNextBeat
                            , beatsPlayed = game.songPosition
                            }

                Jumping { from, to } ->
                    calcPlayerJumpingPosition
                        { from = getPlatformPosition from
                        , to = getPlatformPosition to
                        , ratioToNextBeat = args.ratioToNextBeat
                        , beatsPlayed = game.songPosition
                        }
    in
    [ game.objects
        |> View.Object.fromDict
            { ratioToNextBeat = args.ratioToNextBeat
            , onClick = args.onClick
            , beatsPlayed = game.songPosition
            }
    , if game.songPosition == game.endPosition then
        [ endgame { start = args.start } game ]

      else
        []
    , [ playerPos |> player
      , settingsButton { onClick = args.toggleSettings }
      ]
    , overlay
    ]
        |> List.concat
        |> Html.div
            [ Html.Attributes.style "position" "relative"
            , Html.Attributes.style "background-color" Config.backgroundColor
            , Html.Attributes.style "height" (String.fromFloat Config.screenHeight ++ "px")
            , Html.Attributes.style "width" (String.fromFloat Config.screenWidth ++ "px")
            , Html.Attributes.style "overflow" "hidden"
            ]


settingsButton : { onClick : msg } -> Html msg
settingsButton args =
    Layout.textButton
        [ Html.Attributes.style "position" "absolute"
        , Html.Attributes.style "top" "8px"
        , Html.Attributes.style "right" "8px"
        , Html.Attributes.class "button"
        ]
        { label = "Settings"
        , onPress = Just args.onClick
        }


endgame : { start : msg } -> Game -> Html msg
endgame args game =
    [ "Thanks for Playing"
        |> Html.text
        |> Layout.heading2 [ Html.Attributes.style "color" Config.playerColor ]
    , "Max Bpm: "
        ++ String.fromFloat (game.statistics.maxBpm * 100 |> round |> toFloat |> (\f -> f / 100))
        |> Layout.text []
    , "Stops: "
        ++ String.fromInt game.statistics.stops
        |> Layout.text []
    , "Notes missed: "
        ++ (game.objects
                |> Dict.filter
                    (\_ object ->
                        case object.sort of
                            LilyPad { active } ->
                                not active

                            _ ->
                                False
                    )
                |> Dict.size
                |> String.fromInt
           )
        |> Layout.text []
    , Layout.textButton [ Html.Attributes.class "button" ] { onPress = Just args.start, label = "Restart" }
    ]
        |> Layout.column [ Layout.gap 8 ]
        |> Layout.el
            [ Html.Attributes.style "position" "absolute"
            , Html.Attributes.style "top" (String.fromFloat Config.lilyPadSize ++ "px")
            , Html.Attributes.style "width" "100%"
            , Html.Attributes.style "color" Config.lilyPadColor
            , Layout.contentCentered
            ]


player : ( Float, Float ) -> Html msg
player ( x, y ) =
    Html.img
        [ Html.Attributes.style "width" (String.fromFloat Config.playerSize ++ "px")
        , Html.Attributes.style "height" (String.fromFloat Config.playerSize ++ "px")
        , Html.Attributes.style "position" "absolute"
        , Html.Attributes.style "top" (String.fromFloat y ++ "px")
        , Html.Attributes.style "left" (String.fromFloat x ++ "px")
        , Html.Attributes.src "assets/images/frog.png"
        , Html.Attributes.style "z-index" (String.fromInt Config.playerZIndex)
        ]
        []


calcPlayerJumpingPosition :
    { from : ( Note, Int )
    , to : ( Note, Int )
    , ratioToNextBeat : Float
    , beatsPlayed : Int
    }
    -> ( Float, Float )
calcPlayerJumpingPosition args =
    let
        calcPosition =
            calcPlayerPositionOnPlatform
                { ratioToNextBeat = args.ratioToNextBeat
                , beatsPlayed = args.beatsPlayed
                }

        ( x1, y1 ) =
            calcPosition args.to

        ( x2, y2 ) =
            calcPosition args.from

        ratio =
            if args.ratioToNextBeat > (1 - Config.jumpTime) then
                (args.ratioToNextBeat - (1 - Config.jumpTime)) / Config.jumpTime

            else
                0
    in
    ( x2 + (x1 - x2) * ratio, y2 + (y1 - y2) * ratio )


calcPlayerPositionOnPlatform :
    { ratioToNextBeat : Float
    , beatsPlayed : Int
    }
    -> ( Note, Int )
    -> ( Float, Float )
calcPlayerPositionOnPlatform args ( note, start ) =
    let
        ( x, y ) =
            View.Common.calcLilyPadPosition
                { ratioToNextBeat = args.ratioToNextBeat
                , beatsPlayed = args.beatsPlayed
                , start = start
                , note = note
                }
    in
    ( x + Config.lilyPadSize / 2 - Config.playerSize / 2
    , y + Config.lilyPadSize / 2 - Config.playerSize / 2
    )


overlay =
    List.range 0 (Config.grassDensity - 1)
        |> List.map
            (\i ->
                Config.screenHeight * toFloat i / toFloat Config.grassDensity
            )
        |> List.concatMap (\y -> [ gras False ( 0, y ), gras True ( Config.screenWidth - Config.sidePaddings, y ) ])


gras : Bool -> ( Float, Float ) -> Html msg
gras flip ( x, y ) =
    Html.img
        ([ Html.Attributes.style "width" (String.fromFloat Config.sidePaddings ++ "px")
         , Html.Attributes.style "position" "absolute"
         , Html.Attributes.style "top" (String.fromFloat y ++ "px")
         , Html.Attributes.style "left" (String.fromFloat x ++ "px")
         , Html.Attributes.src "assets/images/margin.png"
         , Html.Attributes.style "background-size" "100%"
         ]
            ++ (if flip then
                    [ Html.Attributes.style "transform" "scaleX(-1)" ]

                else
                    []
               )
        )
        []
