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
import Random
import Strings
import Umui
import Widget.Button as Button exposing (ButtonStyle(..), Role(..), Size(..))
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
    { lang : Umui.Lang
    , data : Umui.MuData
    , sourceText : String
    , counter : Int
    , seed : Int
    , selectedLabel : String
    }


type Msg
    = Clear
    | GetContent String
    | GenerateSeed
    | NewSeed Int
    | About
    | MarkdownExample
    | MiniLaTeXExample
    | MarkdownMsg MarkdownMsg
    | MarkdownToMiniLaTeX
    | MiniLaTeXToMarkdown
    | MuMsg Umui.MuMsg


type alias Flags =
    {}


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        model =
            { lang = Umui.LMarkdown
            , data = Umui.init Umui.LMarkdown 0 Strings.about
            , sourceText = Strings.about
            , counter = 0
            , seed = 0
            , selectedLabel = "About Mu"
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
                , data = Umui.update model.counter str model.data
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
                | data = Umui.init model.lang model.counter ""
                , sourceText = ""
                , counter = model.counter + 1
              }
            , Cmd.none
            )

        About ->
            ( { model
                | counter = model.counter + 1
                , sourceText = Strings.about
                , data = Umui.init Umui.LMarkdown model.counter Strings.about
                , lang = Umui.LMarkdown
                , selectedLabel = "About Mu"
              }
            , Cmd.none
            )

        MarkdownExample ->
            ( { model
                | counter = model.counter + 1
                , sourceText = Strings.markdownExample
                , data = Umui.init Umui.LMarkdown model.counter Strings.markdownExample
                , lang = Umui.LMarkdown
                , selectedLabel = "Markdown Example"
              }
            , Cmd.none
            )

        MiniLaTeXExample ->
            ( { model
                | counter = model.counter + 1
                , sourceText = Strings.miniLaTeXExample
                , data = Umui.init Umui.LMiniLaTeX model.counter Strings.miniLaTeXExample
                , lang = Umui.LMiniLaTeX
                , selectedLabel = "MiniLaTeX Example"
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
                , data = Umui.init Umui.LMiniLaTeX model.counter laTeXContent
                , lang = Umui.LMiniLaTeX
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
                , data = Umui.init Umui.LMarkdown model.counter markdownContent
                , lang = Umui.LMarkdown
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
    column [ paddingXY 80 40, spacing 12, padding 15, width (px ((2 * windowWidth) + 20)) ]
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


windowWidth =
    450


textInput model =
    TextArea.make GetContent model.sourceText ""
        |> TextArea.withWidth windowWidth
        |> TextArea.withHeight windowHeight
        |> TextArea.toElement


renderedText model =
    column
        [ scrollbarY
        , width (px windowWidth)
        , height (px windowHeight)
        , Font.size 12
        , moveDown 11
        , Background.color (Element.rgb 1 1 1)
        , padding 10
        ]
        (Umui.render "-" model.data |> List.map (Html.map MuMsg >> Element.html))


footer model =
    row [ spacing 8, centerX ]
        [ aboutTextButton model.selectedLabel
        , miniLaTeXTextButton model.selectedLabel
        , markdownTextButton model.selectedLabel
        , clearButton
        , markdownToLaTeXButton
        , miniLaTeXToMarkdownButton
        ]


header model =
    row [ spacing 8, width (px ((2 * windowWidth) - 100)) ]
        [ languageIndicator model.lang, row [ centerX, Font.size 18 ] [ Element.text "Umui" ] ]


languageIndicator : Umui.Lang -> Element msg
languageIndicator lang =
    let
        label =
            case lang of
                Umui.LMarkdown ->
                    "Language: Markdown"

                Umui.LMiniLaTeX ->
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



-- BUTTONS


clearButton =
    altButton Clear "Clear" "Clear source text" 80


aboutTextButton selectedLabel =
    button About "About Mu" selectedLabel "Restore 'About Mu' text" 150


markdownTextButton selectedLabel =
    button MarkdownExample "Markdown Example" selectedLabel "Restore Markdown text" 150


miniLaTeXTextButton selectedLabel =
    button MiniLaTeXExample "MiniLaTeX Example" selectedLabel "Restore MiniLaTeX text" 150


markdownToLaTeXButton =
    blueButton MarkdownToMiniLaTeX "Markdown > MiniLaTeX" "Convert Markdown to MiniLaTeX" 165


miniLaTeXToMarkdownButton =
    blueButton MiniLaTeXToMarkdown "MiniLaTeX > Markdown" "Convert MiniLaTeX to Markdown" 165


button msg label selectedLabel title width =
    Button.make msg label
        |> Button.withWidth (Bounded width)
        |> Button.withSelected False
        |> Button.withBackgroundColor (Element.rgb 0.1 0.1 0.1)
        |> Button.withTitle title
        |> Button.withSelected (label == selectedLabel)
        |> Button.toElement


altButton msg label title width =
    let
        gray =
            1.0

        black =
            0.45
    in
    Button.make msg label
        |> Button.withWidth (Bounded width)
        |> Button.withSelected False
        |> Button.withBackgroundColor (Element.rgb black black black)
        |> Button.withFontColor (Element.rgb gray gray gray)
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
