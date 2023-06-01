module View exposing (..)

import Config
import Dict exposing (Dict)
import Game exposing (Game, PlatformId, PlayerPos(..))
import Html exposing (Html)
import Html.Attributes
import Html.Events


fromGame :
    { ratioToNextBeat : Float
    , onClick : PlatformId -> msg
    , beatsPlayed : Int
    }
    -> Game
    -> Html msg
fromGame args game =
    let
        getPlatformPosition id =
            game.platforms
                |> Dict.get id
                |> Maybe.map .position
                |> Maybe.withDefault ( 0, 0 )

        playerPos =
            case game.player of
                OnPlatform id ->
                    getPlatformPosition id
                        |> calcPlayerPositionOnPlatform
                            { ratioToNextBeat = args.ratioToNextBeat
                            , beatsPlayed = args.beatsPlayed
                            }

                Jumping { from, to } ->
                    calcPlayerJumpingPosition
                        { from = getPlatformPosition from
                        , to = getPlatformPosition to
                        , ratioToNextBeat = args.ratioToNextBeat
                        , beatsPlayed = args.beatsPlayed
                        }
    in
    [ game.platforms |> platforms args
    , [ playerPos |> player ]
    ]
        |> List.concat
        |> Html.div [ Html.Attributes.style "position" "relative" ]


player : ( Float, Float ) -> Html msg
player ( x, y ) =
    Html.div
        [ Html.Attributes.style "width" (String.fromFloat Config.playerSize ++ "px")
        , Html.Attributes.style "height" (String.fromFloat Config.playerSize ++ "px")
        , Html.Attributes.style "background-color" "blue"
        , Html.Attributes.style "position" "absolute"
        , Html.Attributes.style "top" (String.fromFloat y ++ "px")
        , Html.Attributes.style "left" (String.fromFloat x ++ "px")
        ]
        []


platforms :
    { ratioToNextBeat : Float
    , onClick : PlatformId -> msg
    , beatsPlayed : Int
    }
    -> Dict PlatformId { position : ( Int, Int ), active : Bool }
    -> List (Html msg)
platforms args dict =
    dict
        |> Dict.toList
        |> List.map
            (\( platformId, { position, active } ) ->
                platform { active = active, onClick = args.onClick platformId }
                    (calcPlatformPosition
                        { ratioToNextBeat = args.ratioToNextBeat
                        , beatsPlayed = args.beatsPlayed
                        }
                        position
                    )
            )


calcPlayerJumpingPosition :
    { from : ( Int, Int )
    , to : ( Int, Int )
    , ratioToNextBeat : Float
    , beatsPlayed : Int
    }
    -> ( Float, Float )
calcPlayerJumpingPosition args =
    let
        calcPosition pos =
            calcPlayerPositionOnPlatform
                { ratioToNextBeat = args.ratioToNextBeat
                , beatsPlayed = args.beatsPlayed
                }
                pos

        ( x1, y1 ) =
            calcPosition args.to

        ( x2, y2 ) =
            calcPosition args.from

        ratio =
            if args.ratioToNextBeat < Config.jumpTime then
                args.ratioToNextBeat / Config.jumpTime

            else
                1
    in
    ( x2 + (x1 - x2) * ratio, y2 + (y1 - y2) * ratio )


calcPlayerPositionOnPlatform : { ratioToNextBeat : Float, beatsPlayed : Int } -> ( Int, Int ) -> ( Float, Float )
calcPlayerPositionOnPlatform args pos =
    let
        ( x, y ) =
            calcPlatformPosition args pos
    in
    ( x + Config.platformWidth / 2 - Config.playerSize / 2, y - Config.playerSize )


calcPlatformPosition : { ratioToNextBeat : Float, beatsPlayed : Int } -> ( Int, Int ) -> ( Float, Float )
calcPlatformPosition args ( x, y ) =
    let
        ratio =
            args.ratioToNextBeat
    in
    ( (Config.platformWidth + Config.horizontalSpaceBetweenPlatforms)
        * toFloat x
        - (Config.platformWidth / 2)
        + (Config.screenWidth / 2)
    , (Config.platformHeight + Config.verticalSpaceBetweenPlatforms)
        * (toFloat -y + ratio + toFloat args.beatsPlayed)
        + Config.screenHeight
    )


platform : { active : Bool, onClick : msg } -> ( Float, Float ) -> Html msg
platform args ( x, y ) =
    Html.button
        [ Html.Attributes.style "width" (String.fromFloat Config.platformWidth ++ "px")
        , Html.Attributes.style "height" (String.fromFloat Config.platformHeight ++ "px")
        , Html.Attributes.style "background-color"
            (if args.active then
                "black"

             else
                "gray"
            )
        , Html.Attributes.style "position" "absolute"
        , Html.Attributes.style "border" "0px"
        , Html.Attributes.style "top" (String.fromFloat y ++ "px")
        , Html.Attributes.style "left" (String.fromFloat x ++ "px")
        , Html.Events.onClick args.onClick
        ]
        []
