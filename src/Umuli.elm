module Umuli exposing
    ( Lang(..)
    , UmuliData(..)
    , UmuliMsg
    , init
    , render
    , update
    )

import Html exposing (Html)
import Markdown.Data as Markdown
import Markdown.Render
import MiniLatex.EditSimple as MiniLaTeX


type UmuliData
    = ML MiniLaTeX.Data
    | MD Markdown.MarkdownData


type Lang
    = LMiniLaTeX
    | LMarkdown


type UmuliMsg
    = MLMsg MiniLaTeX.LaTeXMsg
    | MDMsg Markdown.Render.MarkdownMsg


init : Lang -> Int -> String -> UmuliData
init lang version content =
    case lang of
        LMiniLaTeX ->
            ML (MiniLaTeX.init version content)

        LMarkdown ->
            MD (Markdown.init version content)


update : Int -> String -> UmuliData -> UmuliData
update version content data =
    case data of
        ML data_ ->
            ML (MiniLaTeX.update version content data_)

        MD data_ ->
            MD (Markdown.update version content data_)


render : String -> UmuliData -> List (Html UmuliMsg)
render selectedId data =
    case data of
        ML data_ ->
            MiniLaTeX.get selectedId data_
                |> List.map (Html.map MLMsg)

        MD data_ ->
            Markdown.render selectedId data_
                |> List.map (Html.map MDMsg)
