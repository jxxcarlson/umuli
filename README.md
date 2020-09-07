# Umui Demo

Umui Demo is a small app which demonstrates the use of 
UMUI (Universal Markup Interface)

to show how one can combine an editor,
in this case a simple TextArea, with more than one 
Markup to Html compiler.  By "Markup," we mean any Markup 
language, .e.g, Markdown or MiniLaTeX.

This language integration accomplished 
by a module `Umui` which implements three data types and three functions.
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
