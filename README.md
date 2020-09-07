# Umuli

Umuli is a small app which demonstrates the use of 
UMULI (Universal Markup Language Interface) to
switch between markup languages in the context
of an editing and live-rendering environment.
In the case at hand, we use Markdown and MiniLaTeX.

Language integration is accomplished 
via a module `Umuli` which implements three data types and three functions.
The first data type discriminates among languages, which for 
purposes of illustration are MiniLaTeX and a flavor of Markdown:

```elm
    type Lang
        = LMiniLaTeX
        | LMarkdown
```

The second discriminates among the data structures that
the individual languages use to store and process text.

```elm
    type MuData
        = ML MiniLaTeX.Data
        | MD Markdown.MarkdownData

```
The third defines the message types used.

```elm
    type MuMsg
        = MLMsg MiniLaTeX.LaTeXMsg
        | MDMsg Markdown.Render.MarkdownMsg
```

The three functions are

```elm
    init : Lang -> Int -> String -> MuData

    update : Int -> String -> MuData -> MuData

    render : String -> MuData -> List (Html MuMsg)
```

Thus, if a markup language provides suitable functions
`init`, `update`, and `render`, it can be used in this context.

## Conversions

In addition to supporting editing and rendering of documents
in MiniLaTeX and Math-flavored Markdown, the app shows
how documents can be converted from one markup language to another.
These conversions should be regarded as "first-draft" efforts.


## Installation

Not ready yet: I have to publish latest version of the MiniLaTeX compiler.
Look for it on September 8 or 9, 2020.