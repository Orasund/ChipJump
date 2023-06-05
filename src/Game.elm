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


type alias Statistics =
    { maxBpm : Float
    , stops : Int
    }


type alias Game =
    { track : Song
    , objects : Dict ObjectId Object
    , rows : Dict Int (List ObjectId)
    , player : PlayerPos
    , songPosition : Int
    , endPosition : Int
    , running : Bool
    , bpm : Float
    , statistics : Statistics
    }


calcMaxDelta game =
    (60 * 1000) / (game.bpm * toFloat Config.maxJumpSize)


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


getNextPossibleLilyPads : Game -> ObjectId -> List ( ObjectId, Object )
getNextPossibleLilyPads game from =
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
        |> List.filterMap
            (\next ->
                game.objects
                    |> Dict.get next
                    |> Maybe.andThen
                        (\object ->
                            case object.sort of
                                LilyPad { active } ->
                                    if active then
                                        Just ( next, object )

                                    else
                                        Nothing

                                Wave ->
                                    Nothing
                        )
            )


recheckNextPlayerPos : Game -> Game
recheckNextPlayerPos game =
    case game.player of
        OnPlatform platformId ->
            if getNextPossibleLilyPads game platformId /= [] then
                { game | running = True } |> nextPlayerPos

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
    in
    currentObjectId
        |> getNextPossibleLilyPads game
        |> List.head
        |> Maybe.map
            (\( next, object ) ->
                if object.start - 1 == game.songPosition then
                    { game | player = Jumping { from = currentObjectId, to = next } }

                else
                    { game
                        | player = OnPlatform currentObjectId
                    }
            )
        |> Maybe.withDefault
            { game
                | player = OnPlatform currentObjectId
                , running = False
                , bpm = game.bpm - game.bpm * Config.bpmPercentDecrease
                , statistics =
                    game.statistics
                        |> (\statistics -> { statistics | stops = statistics.stops + 1 })
            }


nextBeat : Game -> ( Game, List Note )
nextBeat game =
    let
        bpm =
            game.bpm + Config.bpmIncrease

        songPosition =
            game.songPosition + 1
    in
    ( { game
        | songPosition = songPosition
        , bpm = bpm
        , statistics =
            game.statistics
                |> (\statistics -> { statistics | maxBpm = max game.statistics.maxBpm bpm })
      }
        |> nextPlayerPos
    , game.rows
        |> Dict.get songPosition
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

        ( rows, endPosition ) =
            objects
                |> Dict.foldl
                    (\id { start } ( d, e ) ->
                        ( d
                            |> Dict.update start
                                (\maybe ->
                                    maybe
                                        |> Maybe.withDefault []
                                        |> (::) id
                                        |> Just
                                )
                        , max e start
                        )
                    )
                    ( Dict.empty, 0 )

        player =
            OnPlatform 0

        songPosition =
            0

        running =
            False

        bpm =
            60

        statistics =
            { maxBpm = bpm
            , stops = 0
            }
    in
    { track = track
    , objects = objects
    , player = player
    , rows = rows
    , songPosition = songPosition
    , endPosition = endPosition
    , running = running
    , bpm = bpm
    , statistics = statistics
    }
