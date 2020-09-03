module Mu exposing
    ( Lang(..)
    , MuData(..)
    , MuMsg
    , init
    , render
    , update
    )

import Html exposing (Html)
import Markdown.Data as Markdown
import Markdown.Render
import MiniLatex.EditSimple as MiniLaTeX


type MuData
    = ML MiniLaTeX.Data
    | MD Markdown.MarkdownData


type Lang
    = LMiniLaTeX
    | LMarkdown


type MuMsg
    = MLMsg MiniLaTeX.LaTeXMsg
    | MDMsg Markdown.Render.MarkdownMsg



-- muMsg : Lang -> unknown -> MuMsg
--
--muMsg lang =
--    case lang of
--        LMarkdown ->
--            MDMsg
--
--        LMiniLaTeX ->
--            MLMsg


init : Lang -> Int -> String -> MuData
init lang version content =
    case lang of
        LMiniLaTeX ->
            ML (MiniLaTeX.init version content)

        LMarkdown ->
            MD (Markdown.init version content)


update : Int -> String -> MuData -> MuData
update version content data =
    case data of
        ML data_ ->
            ML (MiniLaTeX.update version content data_)

        MD data_ ->
            MD (Markdown.update version content data_)


render : String -> MuData -> List (Html MuMsg)
render selectedId data =
    case data of
        ML data_ ->
            MiniLaTeX.get selectedId data_
                |> List.map (Html.map MLMsg)

        MD data_ ->
            Markdown.render selectedId data_
                |> List.map (Html.map MDMsg)
