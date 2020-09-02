module MU exposing (Lang, MUData, MUMsg, init, render, update)

import Html exposing (Html)
import Markdown.Data as Markdown
import Markdown.Render
import MiniLatex.EditSimple as MiniLaTeX


type MUData
    = ML MiniLaTeX.Data
    | MD Markdown.MarkdownData


type Lang
    = LMiniLaTeX
    | LMarkdown


type MUMsg
    = MLMsg MiniLaTeX.LaTeXMsg
    | MDMsg Markdown.Render.MarkdownMsg


init : Lang -> Int -> String -> MUData
init lang version content =
    case lang of
        LMiniLaTeX ->
            ML (MiniLaTeX.init version content)

        LMarkdown ->
            MD (Markdown.init version content)


update : Int -> String -> MUData -> MUData
update version content data =
    case data of
        ML data_ ->
            ML (MiniLaTeX.update version content data_)

        MD data_ ->
            MD (Markdown.update version content data_)


render : String -> MUData -> List (Html MUMsg)
render selectedId data =
    case data of
        ML data_ ->
            MiniLaTeX.get selectedId data_
                |> List.map (Html.map MLMsg)

        MD data_ ->
            Markdown.render selectedId data_
                |> List.map (Html.map MDMsg)
