module Strings exposing (Strings, it)

{-| UI text, kept in one place so the game is easy to translate.

To add another language, define a new value of type `Strings` (e.g. `en`)
and switch on it where `it` is currently used in `Main`.

-}


type alias Strings =
    { title : String
    , backToSite : String
    , target : String
    , composite : String
    , compositeSolved : String
    , prevLevel : String
    , reset : String
    , nextLevel : String
    , solved : String
    }


{-| Italian — the default language.
-}
it : Strings
it =
    { title = "📐 Che sagoma la geometria! 💠"
    , backToSite = "← Torna al sito di PiGreco"
    , target = "Modello"
    , composite = "Composizione"
    , compositeSolved = "Composizione ✓"
    , prevLevel = "◀ Precedente"
    , reset = "⟳ Ricomincia"
    , nextLevel = "Successivo ▶"
    , solved = "🎉 Risolto!"
    }
