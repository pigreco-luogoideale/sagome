module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import List.Extra
import Puzzles exposing (..)
import Strings exposing (it)


layerPath : String -> String
layerPath id =
    "layers/" ++ id ++ ".svg"



-- MODEL


type alias Model =
    { puzzleIdx : Int
    , solution : Puzzle
    , selected : List String -- ordered bottom-to-top
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( loadPuzzle 0, Cmd.none )


loadPuzzle : Int -> Model
loadPuzzle idx =
    let
        solution =
            puzzles
                |> List.Extra.getAt idx
                |> Maybe.withDefault ( -1, [], \_ -> False )
    in
    { puzzleIdx = idx
    , solution = solution
    , selected = []
    }



-- UPDATE


type Msg
    = ToggleLayer String
    | Reset
    | PrevLevel
    | NextLevel


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ToggleLayer id ->
            let
                newSelected =
                    if List.member id model.selected then
                        List.filter (\s -> s /= id) model.selected

                    else
                        model.selected ++ [ id ]
            in
            ( { model | selected = newSelected }, Cmd.none )

        Reset ->
            ( { model | selected = [] }, Cmd.none )

        PrevLevel ->
            let
                prevIdx =
                    modBy (List.length puzzles) (model.puzzleIdx - 1)
            in
            ( loadPuzzle prevIdx, Cmd.none )

        NextLevel ->
            let
                nextIdx =
                    modBy (List.length puzzles) (model.puzzleIdx + 1)
            in
            ( loadPuzzle nextIdx, Cmd.none )



-- VIEW


isSolved : Model -> Bool
isSolved model =
    let
        ( _, _, solution ) =
            model.solution
    in
    solution model.selected


view : Model -> Browser.Document Msg
view model =
    let
        ( layer, solutionRender, _ ) =
            model.solution

        currentLayers =
            allLayers
                |> List.Extra.getAt layer
                |> Maybe.withDefault []
    in
    { title = it.title
    , body =
        [ div [ class "min-h-screen bg-gray-950 text-white flex flex-col items-center p-4 font-sans" ]
            [ h1 [ class "text-2xl font-bold mb-1 tracking-wide text-yellow-400" ]
                [ text it.title ]
            , a
                [ href "https://www.luogoideale.org"
                , Html.Attributes.target "_blank"
                , rel "noopener noreferrer"
                , class "text-sm font-semibold animated-gradient-text transition mb-4"
                ]
                [ text it.backToSite ]
            , div [ class "w-full max-w-2xl flex flex-col gap-4" ]
                [ -- Target + Composite panels
                  div
                    [ class
                        "grid grid-cols-2 gap-4 h-56 rounded-xl transition"
                    ]
                    [ imagePanel it.target solutionRender (isSolved model)
                    , imagePanel
                        (if isSolved model then
                            it.compositeSolved

                         else
                            it.composite
                        )
                        model.selected
                        (isSolved model)
                    ]

                -- Win message, right below the squares (space reserved when unsolved)
                , winOverlay (isSolved model)

                -- Layer grid
                , div [ class "grid grid-cols-4 gap-2" ]
                    (List.map (layerThumb model.selected) currentLayers)

                -- Navigation + Reset buttons
                , div [ class "grid grid-cols-3 gap-2" ]
                    [ button
                        [ class "py-2 rounded-lg bg-gray-700 hover:bg-gray-600 active:bg-gray-500 transition font-semibold text-lg"
                        , onClick PrevLevel
                        ]
                        [ text it.prevLevel ]
                    , button
                        [ class "py-2 rounded-lg bg-gray-700 hover:bg-gray-600 active:bg-gray-500 transition font-semibold text-lg"
                        , onClick Reset
                        ]
                        [ text it.reset ]
                    , button
                        [ class "py-2 rounded-lg bg-gray-700 hover:bg-gray-600 active:bg-gray-500 transition font-semibold text-lg"
                        , onClick NextLevel
                        ]
                        [ text it.nextLevel ]
                    ]
                ]
            ]
        ]
    }


imagePanel : String -> List String -> Bool -> Html Msg
imagePanel label layers highlighted =
    let
        borderColor =
            if highlighted then
                "border-green-500"

            else
                "border-gray-600"

        labelColor =
            if highlighted then
                "text-green-400"

            else
                "text-gray-400"

        bgColor =
            if highlighted then
                "bg-green-950"

            else
                "bg-gray-900"
    in
    div [ class ("relative rounded-lg border-2 overflow-hidden flex flex-col " ++ borderColor ++ " " ++ bgColor) ]
        [ span [ class ("text-xs text-center py-1 " ++ labelColor) ] [ text label ]
        , div [ class "relative flex-1 mb-2" ]
            (List.map
                (\id ->
                    img
                        [ src (layerPath id)
                        , class "absolute inset-0 w-full h-full object-contain"
                        ]
                        []
                )
                layers
            )
        ]


layerThumb : List String -> String -> Html Msg
layerThumb selected id =
    let
        order =
            List.Extra.elemIndex id selected
                |> Maybe.map ((+) 1)

        isSelected =
            order /= Nothing

        borderColor =
            if isSelected then
                "border-yellow-400"

            else
                "border-gray-600"

        bg =
            if isSelected then
                "bg-gray-800"

            else
                "bg-gray-900"
    in
    div
        [ class ("relative rounded-lg border-2 cursor-pointer overflow-hidden aspect-square " ++ borderColor ++ " " ++ bg)
        , onClick (ToggleLayer id)
        ]
        [ img [ src (layerPath id), class "w-full h-full object-contain", title id ] []
        , case order of
            Just n ->
                span
                    [ class "absolute top-1 right-1 w-6 h-6 rounded-full bg-yellow-400 text-black text-xs font-bold flex items-center justify-center" ]
                    [ text (String.fromInt n) ]

            Nothing ->
                text ""
        ]


winOverlay : Bool -> Html Msg
winOverlay solved =
    div [ class "-my-3 flex justify-center" ]
        [ p [ class "text-lg font-bold text-green-400" ]
            [ text
                (if solved then
                    it.solved

                 else
                    "\u{00A0}"
                )
            ]
        ]



-- MAIN


main : Program () Model Msg
main =
    Browser.document
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }
