# Umuli

Umuli is a small app which demonstrates the use of 
UMULI (Universal Markup Language Interface) to
switch between markup languages in the context
of an editing and live-rendering environment.
In the case at hand, we use a Math-flavored Markdown and MiniLaTeX.

Language integration is accomplished 
via a module `Umuli` which implements three data types and three functions.
The first data type discriminates among languages:

```elm
    type Lang
        = LMiniLaTeX
        | LMarkdown
```

The second discriminates among the data structures that
the individual languages used to store and process text:

```elm
    type MuData
        = ML MiniLaTeX.Data
        | MD Markdown.MarkdownData

```
The third defines the message types used:

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


## Installation and Issues


- I am using a development version of the MiniLaTeX compiler,
so you won't be able to build the app from source until
the next version of the compiler is published. 
Look for it on September 8 or 9, 2020.

- For some reason KaTeX is not recognizing the KaTeX fonts,
despite the fact that they are loaded with the app.  For this
reason math formulas, while they are rendered, are not rendered in what should be
glorious beauty.  I'll 
try to get this sorted out soon.