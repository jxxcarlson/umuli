module Main exposing (..)

import Browser
import Element exposing (..)
import Element.Background as Background
import Element.Font as Font
import Element.Keyed as Keyed
import File.Download as Download
import Html exposing (..)
import Html.Attributes as HA exposing (style)
import Html.Events exposing (onClick, onInput)
import Html.Keyed as Keyed
import Markdown.LaTeX
import Markdown.Option exposing (MarkdownOption(..), OutputOption(..))
import Markdown.Render exposing (MarkdownMsg, MarkdownOutput)
import Mu
import Random
import Strings
import Style exposing (..)
import Widget.Button as Button exposing (ButtonStyle(..), Size(..))
import Widget.Style
import Widget.TextArea as TextArea
import Widget.TextField as TextField exposing (LabelPosition(..), Role(..))


main : Program Flags Model Msg
main =
    Browser.element
        { view = view
        , update = update
        , init = init
        , subscriptions = subscriptions
        }


type alias Model =
    { lang : Mu.Lang
    , data : Mu.MuData
    , sourceText : String
    , counter : Int
    , seed : Int
    }


type Msg
    = Clear
    | GetContent String
    | GenerateSeed
    | NewSeed Int
    | MarkdownExample
    | MiniLaTeXExample
    | MarkdownMsg MarkdownMsg
    | ExportToLaTeX
    | MuMsg Mu.MuMsg


type alias Flags =
    {}


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        model =
            { lang = Mu.LMarkdown
            , data = Mu.init Mu.LMarkdown 0 Strings.markdownExample
            , sourceText = Strings.markdownExample
            , counter = 0
            , seed = 0
            }
    in
    ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetContent str ->
            ( { model
                | sourceText = str
                , data = Mu.update model.counter str model.data
                , counter = model.counter + 1
              }
            , Cmd.none
            )

        GenerateSeed ->
            ( model, Random.generate NewSeed (Random.int 1 10000) )

        NewSeed newSeed ->
            ( { model | seed = newSeed }, Cmd.none )

        Clear ->
            ( { model
                | data = Mu.init model.lang model.counter ""
                , sourceText = ""
                , counter = model.counter + 1
              }
            , Cmd.none
            )

        MarkdownExample ->
            ( { model
                | counter = model.counter + 1
                , sourceText = Strings.markdownExample
                , data = Mu.init Mu.LMarkdown model.counter Strings.markdownExample
                , lang = Mu.LMarkdown
              }
            , Cmd.none
            )

        MiniLaTeXExample ->
            ( { model
                | counter = model.counter + 1
                , sourceText = Strings.miniLaTeXExample
                , data = Mu.init Mu.LMiniLaTeX model.counter Strings.miniLaTeXExample
                , lang = Mu.LMiniLaTeX
              }
            , Cmd.none
            )

        MarkdownMsg _ ->
            ( model, Cmd.none )

        ExportToLaTeX ->
            let
                laTeXContent =
                    Markdown.LaTeX.export model.sourceText
            in
            ( model, download laTeXContent )

        MuMsg _ ->
            ( model, Cmd.none )


download : String -> Cmd msg
download latexContent =
    Download.string "exported.tex" "application/x-latex" latexContent



--
-- VIEW FUNCTIONS
---


view : Model -> Html Msg
view model =
    Element.layoutWith { options = [ focusStyle Widget.Style.noFocus ] }
        [ width fill, height fill, Background.color (Element.rgb 0.9 0.9 0.9) ]
        (mainColumn model)


mainColumn model =
    column [ paddingXY 80 40, spacing 12, padding 15 ]
        [ editor model
        , footer model
        ]


editor model =
    row [ spacing 12 ]
        [ textInput model
        , renderedText model
        ]


windowHeight =
    550


textInput model =
    TextArea.make GetContent model.sourceText ""
        |> TextArea.withWidth 400
        |> TextArea.withHeight windowHeight
        |> TextArea.toElement


renderedText model =
    column
        [ scrollbarY
        , width (px 400)
        , height (px windowHeight)
        , elementAttribute "line-height" "150%"
        , Font.size 12
        , moveDown 11
        , Background.color (Element.rgb 1 1 1)
        , padding 10
        ]
        (Mu.render "-" model.data |> List.map (Html.map MuMsg >> Element.html))


footer model =
    row [ spacing 8 ] [ miniLaTeXTextButton, markdownTextButton, clearButton ]


clearButton =
    button Clear "Clear" "Clear source text" 80


markdownTextButton =
    button MarkdownExample "Markdown Example" "Restore Markdown text" 150


miniLaTeXTextButton =
    button MiniLaTeXExample "MiniLaTeX Example" "Restore MiniLaTeX text" 150


button msg label title width =
    Button.make msg label
        |> Button.withWidth (Bounded width)
        |> Button.withSelected False
        |> Button.withTitle title
        |> Button.toElement


elementAttribute : String -> String -> Element.Attribute msg
elementAttribute key value =
    Element.htmlAttribute (HA.attribute key value)



--
--display : Model -> Html Msg
--display model =
--    div []
--        [ h2 [ style "margin-left" "20px", style "margin-bottom" "0px", style "margin-top" "0px" ] [ text "Multi-Language Markup  Processor" ]
--        , p [ style "margin-left" "20px", style "margin-top" "0", style "font-size" "14pt" ] [ text "Markdown + Math, MiniLaTeX" ]
--        , editor model
--        , div [ style "width" "500px" ] [ Mu.render "-" model.data |> List.map (Html.map MuMsg) |> (\x -> div [] x) ]
--        , p [ style "clear" "left", style "margin-left" "20px", style "margin-top" "-20px" ]
--            [ clearButton 60
--            , exportToLaTeXButton 100
--            ]
--        , a [ HA.href "https://minilatex.io", style "clear" "left", style "margin-left" "20px", style "margin-top" "0px" ] [ text "minilatex.io" ]
--        , a [ HA.href "https://package.elm-lang.org/packages/jxxcarlson/elm-markdown/latest/", style "clear" "left", style "margin-left" "20px", style "margin-top" "0px" ] [ text "package.elm-lang.org" ]
--        ]
--
--
--label text_ =
--    p labelStyle [ text text_ ]
--
-- BUTTONS --
--
--
--
--exportToLaTeXButton width =
--    button ([ onClick ExportToLaTeX ] ++ buttonStyle colorBlue width) [ text "To LaTeX" ]
