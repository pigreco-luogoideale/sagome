module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import List.Extra
import Puzzles exposing (..)


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
                |> Maybe.withDefault []
    in
    { puzzleIdx = idx
    , solution = solution
    , selected = []
    }



-- UPDATE


type Msg
    = ToggleLayer String
    | Reset
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

        NextLevel ->
            let
                nextIdx =
                    modBy (List.length puzzles) (model.puzzleIdx + 1)
            in
            ( loadPuzzle nextIdx, Cmd.none )



-- VIEW


isSolved : Model -> Bool
isSolved model =
    model.selected == model.solution


view : Model -> Browser.Document Msg
view model =
    { title = "Che sagoma la geometria!"
    , body =
        [ div [ class "min-h-screen bg-gray-950 text-white flex flex-col items-center p-4 font-sans" ]
            [ h1 [ class "text-2xl font-bold mb-4 tracking-wide text-yellow-400" ]
                [ text "Che sagoma la geometria!" ]
            , div [ class "w-full max-w-2xl flex flex-col gap-4" ]
                [ -- Target + Composite panels
                  div [ class "grid grid-cols-2 gap-4 h-56" ]
                    [ imagePanel "Target" model.solution False
                    , imagePanel
                        (if isSolved model then
                            "Composite ✓"

                         else
                            "Composite"
                        )
                        model.selected
                        (isSolved model)
                    ]

                -- Layer grid
                , div [ class "grid grid-cols-4 gap-2" ]
                    (List.map (layerThumb model.selected) allLayers)

                -- Reset button
                , button
                    [ class "w-full py-2 rounded-lg bg-gray-700 hover:bg-gray-600 active:bg-gray-500 transition font-semibold text-lg"
                    , onClick Reset
                    ]
                    [ text "⟳ Reset" ]
                ]

            -- Win overlay
            , if isSolved model then
                winOverlay

              else
                text ""
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
    in
    div [ class ("relative rounded-lg border-2 bg-gray-900 overflow-hidden flex flex-col " ++ borderColor) ]
        [ span [ class ("text-xs text-center py-1 " ++ labelColor) ] [ text label ]
        , div [ class "relative flex-1" ]
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
        [ img [ src (layerPath id), class "w-full h-full object-contain" ] []
        , case order of
            Just n ->
                span
                    [ class "absolute top-1 right-1 w-6 h-6 rounded-full bg-yellow-400 text-black text-xs font-bold flex items-center justify-center" ]
                    [ text (String.fromInt n) ]

            Nothing ->
                text ""
        ]


winOverlay : Html Msg
winOverlay =
    div [ class "fixed inset-0 bg-black/70 flex flex-col items-center justify-center gap-8 z-50" ]
        [ p [ class "text-6xl font-bold text-yellow-400 drop-shadow-lg" ] [ text "🎉 Solved!" ]
        , div [ class "flex gap-4" ]
            [ button
                [ class "px-6 py-3 rounded-xl bg-gray-700 hover:bg-gray-600 text-white font-semibold text-lg transition"
                , onClick Reset
                ]
                [ text "Play Again" ]
            , button
                [ class "px-6 py-3 rounded-xl bg-yellow-400 hover:bg-yellow-300 text-black font-semibold text-lg transition"
                , onClick NextLevel
                ]
                [ text "Next Level" ]
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
