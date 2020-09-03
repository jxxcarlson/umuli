module Main exposing (..)

import Browser
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import File.Download as Download
import Html exposing (..)
import Html.Attributes as HA exposing (style)
import Markdown.LaTeX
import Markdown.Option exposing (MarkdownOption(..), OutputOption(..))
import Markdown.Render exposing (MarkdownMsg, MarkdownOutput)
import Mu
import Random
import Strings
import Widget.Button as Button exposing (ButtonStyle(..), Size(..))
import Widget.Style
import Widget.TextArea as TextArea


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
    | MarkdownToMiniLaTeX
    | MiniLaTeXToMarkdown
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

        MarkdownToMiniLaTeX ->
            let
                laTeXContent =
                    Markdown.LaTeX.export model.sourceText
            in
            ( { model
                | counter = model.counter + 1
                , sourceText = laTeXContent
                , data = Mu.init Mu.LMiniLaTeX model.counter laTeXContent
                , lang = Mu.LMiniLaTeX
              }
            , Cmd.none
            )

        MiniLaTeXToMarkdown ->
            let
                markdownContent =
                    "# MiniLaTeX to Markdown\n\n*Not yet implemented.*"
            in
            ( { model
                | counter = model.counter + 1
                , sourceText = markdownContent
                , data = Mu.init Mu.LMarkdown model.counter markdownContent
                , lang = Mu.LMarkdown
              }
            , Cmd.none
            )

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
        [ header model
        , editor model
        , footer model
        ]


editor model =
    row [ spacing 12, moveUp 10 ]
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
        , Font.size 12
        , moveDown 11
        , Background.color (Element.rgb 1 1 1)
        , padding 10
        ]
        (Mu.render "-" model.data |> List.map (Html.map MuMsg >> Element.html))


footer model =
    row [ spacing 8 ]
        [ miniLaTeXTextButton
        , markdownTextButton
        , clearButton
        , markdownToLaTeXButton
        , miniLaTeXToMarkdownButton
        ]


header model =
    row [ spacing 8 ]
        [ languageIndicator model.lang ]


languageIndicator : Mu.Lang -> Element msg
languageIndicator lang =
    let
        label =
            case lang of
                Mu.LMarkdown ->
                    "Language: Markdown"

                Mu.LMiniLaTeX ->
                    "Language: MiniLaTeX"
    in
    el
        [ Font.size 14
        , Font.color (Element.rgb 0.1 0.1 0.1)
        , Background.color (Element.rgb 1.0 1.0 1.0)
        , Border.width 1
        , height (px 30)
        , padding 8
        ]
        (Element.text label)


clearButton =
    redButton Clear "Clear" "Clear source text" 80


markdownTextButton =
    button MarkdownExample "Markdown Example" "Restore Markdown text" 150


miniLaTeXTextButton =
    button MiniLaTeXExample "MiniLaTeX Example" "Restore MiniLaTeX text" 150


markdownToLaTeXButton =
    blueButton MarkdownToMiniLaTeX "Markdown > MiniLaTeX" "Convert Markdown to MiniLaTeX" 165


miniLaTeXToMarkdownButton =
    blueButton MiniLaTeXToMarkdown "MiniLaTeX > Markdown" "Convert MiniLaTeX to Markdown" 165


button msg label title width =
    Button.make msg label
        |> Button.withWidth (Bounded width)
        |> Button.withSelected False
        |> Button.withBackgroundColor (Element.rgb 0.1 0.1 0.1)
        |> Button.withTitle title
        |> Button.toElement


blueButton msg label title width =
    Button.make msg label
        |> Button.withWidth (Bounded width)
        |> Button.withSelected False
        |> Button.withTitle title
        |> Button.withBackgroundColor (Element.rgb 0 0 0.65)
        |> Button.toElement


redButton msg label title width =
    Button.make msg label
        |> Button.withWidth (Bounded width)
        |> Button.withSelected False
        |> Button.withTitle title
        |> Button.withBackgroundColor (Element.rgb 0.55 0 0)
        |> Button.toElement


elementAttribute : String -> String -> Element.Attribute msg
elementAttribute key value =
    Element.htmlAttribute (HA.attribute key value)
