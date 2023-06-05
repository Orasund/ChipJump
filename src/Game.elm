module Game exposing (..)

import Array
import Config
import Dict exposing (Dict)
import Note exposing (Note)
import Song exposing (Song)


type alias ObjectId =
    Int


type PlayerPos
    = OnPlatform ObjectId
    | Jumping { from : ObjectId, to : ObjectId }


type alias Object =
    { start : Int, note : Note, sort : ObjectSort }


type ObjectSort
    = LilyPad { active : Bool }
    | Wave


type alias Game =
    { track : Song
    , objects : Dict ObjectId Object
    , rows : Dict Int (List ObjectId)
    , player : PlayerPos
    , songPosition : Int
    , running : Bool
    }


activatePlatform : ObjectId -> Game -> Game
activatePlatform id game =
    { game
        | objects =
            game.objects
                |> Dict.update id
                    (Maybe.map
                        (\platform ->
                            case platform.sort of
                                LilyPad lilyPad ->
                                    { platform | sort = LilyPad { lilyPad | active = True } }

                                Wave ->
                                    platform
                        )
                    )
    }


getNextPossiblePlatforms : Game -> ObjectId -> List ObjectId
getNextPossiblePlatforms game from =
    game.objects
        |> Dict.get from
        |> Maybe.map .start
        |> Maybe.map
            (\y ->
                List.range 1 Config.maxJumpSize
                    |> List.concatMap
                        (\amount ->
                            game.rows
                                |> Dict.get (y + amount)
                                |> Maybe.withDefault []
                        )
            )
        |> Maybe.withDefault []
        |> List.filter
            (\next ->
                game.objects
                    |> Dict.get next
                    |> Maybe.map
                        (\object ->
                            case object.sort of
                                LilyPad { active } ->
                                    active

                                Wave ->
                                    False
                        )
                    |> (==) (Just True)
            )


recheckNextPlayerPos : Game -> Game
recheckNextPlayerPos game =
    case game.player of
        OnPlatform platformId ->
            if getNextPossiblePlatforms game platformId /= [] then
                { game | running = True }

            else
                game

        Jumping _ ->
            game


objectIdOfPlayer : Game -> ObjectId
objectIdOfPlayer game =
    case game.player of
        OnPlatform platformId ->
            platformId

        Jumping { to } ->
            to


nextPlayerPos : Game -> Game
nextPlayerPos game =
    let
        currentObjectId =
            objectIdOfPlayer game

        endPosition =
            game.objects
                |> Dict.get currentObjectId
                |> Maybe.map (\{ start } -> start + 1)
                |> Maybe.withDefault 0

        maybePlayer =
            currentObjectId
                |> getNextPossiblePlatforms game
                |> List.head
                |> Maybe.map
                    (\next ->
                        Jumping { from = currentObjectId, to = next }
                    )
    in
    if endPosition <= game.songPosition then
        maybePlayer
            |> Maybe.map (\player -> { game | player = player })
            |> Maybe.withDefault
                { game
                    | player = OnPlatform currentObjectId
                    , running = False
                }

    else
        { game | player = OnPlatform currentObjectId }


nextBeat : Game -> ( Game, List Note )
nextBeat game =
    ( { game | songPosition = game.songPosition + 1 } |> nextPlayerPos
    , game.rows
        |> Dict.get (game.songPosition + 1)
        |> Maybe.withDefault []
        |> List.filterMap
            (\id ->
                game.objects
                    |> Dict.get id
            )
        |> List.filterMap
            (\{ note, sort } ->
                case sort of
                    LilyPad { active } ->
                        if active then
                            Just note

                        else
                            Nothing

                    Wave ->
                        Just note
            )
    )


new : Game
new =
    let
        track =
            Song.default

        objects : Dict ObjectId Object
        objects =
            track
                |> Dict.toList
                |> List.concatMap
                    (\( instrument, array ) ->
                        array
                            |> Array.indexedMap
                                (\j list ->
                                    (if instrument == Song.lilyPadInstrument then
                                        LilyPad { active = j == 0 }
                                            |> Just

                                     else if instrument == Song.waveInstrument then
                                        Wave |> Just

                                     else
                                        Nothing
                                    )
                                        |> Maybe.map
                                            (\sort ->
                                                list
                                                    |> List.map
                                                        (\note ->
                                                            { start = j
                                                            , sort = sort
                                                            , note = note
                                                            }
                                                        )
                                            )
                                )
                            |> Array.toList
                            |> List.filterMap identity
                            |> List.concat
                    )
                |> List.indexedMap Tuple.pair
                |> Dict.fromList

        rows =
            objects
                |> Dict.foldl
                    (\id { start } ->
                        Dict.update start
                            (\maybe ->
                                maybe
                                    |> Maybe.withDefault []
                                    |> (::) id
                                    |> Just
                            )
                    )
                    Dict.empty

        player =
            OnPlatform 0

        songPosition =
            0

        running =
            False
    in
    { track = track
    , objects = objects
    , player = player
    , rows = rows
    , songPosition = songPosition
    , running = running
    }
