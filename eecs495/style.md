# IPD Style for \*SL

## Naming

  - If the homework assignment specifies a function name, you *must* use
    that function name.

  - Function and parameter names must be in `hyphenated-lowercase`;
    write the words in lowercase and join with hyphens.

  - Constant names must be in `HYPHENATED-UPPERCASE`;
    write the words in uppercase and join with hyphens.

  - Data definition names must be in `UpperCamelCase`;
    capitalize the initial letter of each word and append them.

  - Names of things must reflect their purposes. Do not use generic
    names such as `number` or `function`.

  - Names with larger scope, such as function names, should generally be
    more descriptive (and longer) than names with smaller scope, such as
    function parameters.

## Code formatting

### Line breaking

  - Lines must be at most 80 characters long.

      - Longer lines must be broken; insert line breaks where you think
        they will maximize readability. Prefer to break between larger
        syntactic elements rather than smaller.

        Not great:
        ```racket
        (check-expect (my-function arg1 arg2
                                   arg3 arg4) result)
        ```

        Better:
        ```racket
        (check-expect (my-function arg1 arg2
                                   arg3 arg4)
                      result)
        ```

        Better still:
        ```racket
        (check-expect
          (my-function arg1 arg2 arg3 arg4)
          result)
        ```

      - DrRacket can help you with this. In *Preferences*, go to the
        *Editing* section, and select “Maximum character width guide”
        with a width of 80. This will cause DrRacket to draw a right
        margin in your editor window.

  - In function definitions, a mandatory line break follows the function
    name and arguments list:

    Bad:
    ```racket
    (define (my-function arg1 arg2) function-body-stuff)
    ```

    Good:
    ```racket
    (define (my-function arg1 arg2)
      function-body-stuff)
    ```

  - Parentheses and square brackets (`(`, `)`, `[`, `]`) must never
    appear on lines by themselves.

      - Put left delimiters on the same line as the code that follows.

      - Put right delimiters on the same line as the code that precedes.

    Bad:
    ```racket
    (define (foo bar) (
      cond
        [(test1? bar) ...]
        [(test2? bar) ...]
    )
    ```

    Good:
    ```racket
    (define (foo bar)
      (cond
        [(test1? bar) ...]
        [(test2? bar) ...])
    ```

### Horizontal spacing

  - You must indent your code properly, which means that the indentation
    follows the nesting structure.

      - The easiest way to do this in DrRacket is to select the code you
        wish to re-indent and press the *Tab* key.

      - It’s a good idea to reindent everything before submitting.

  - Adjacent items *must* have space between them, except that adjacent
    delimiters of the same direction *must not* have space between them.

      - Delimiters must have no space inside them—that is, the next token
        must follow without space in between.

        Bad:
        ```racket
        ( cond
          [ (test? qux)
            ( cons 4 ( list 3 2 1 ) ) ]
          ...
        ```

        Good:
        ```racket
        (cond
          [(test? qux)
           (cons 4 (list 3 2 1))]
          ...
        ```

      - Delimiters must have space outside them except when directly inside
        another delimiter:

        Bad:
        ```racket
        (+(* a(+ b c)(f e))d)
        ```

        Good:
        ```racket
        (+ (* a (+ b c) (f e)) d)
        ```

## Program layout

Programs must be laid out in the following order:

1.  Data definitions (for the whole program)

2.  Constants (for the whole program)

3.  The most important or main function:

    1.  Signature

    2.  Purpose

    3.  Functional examples

    4.  Strategy

    5.  Code of function

    6.  Tests

4.  Each secondary or auxiliary function in turn:

    1.  Signature

    2.  Purpose

    3.  Functional examples (optional for trivial helpers)

    4.  Strategy

    5.  Code of function

    6.  Tests (optional for trivial helpers)

Note that:

  - Data definitions and constants come before all function definitions.

  - Each function definition holds together, with no other functions,
    data definitions, or constants in the middle of it.

## Design recipe details

### Step 1

  - If the problem does not require new data definitions, this step may
    not result in anything in your source code. This is okay.

### Step 2

  - The signature is a formal specification of the data types consumed
    and produced by a function. Thus, the names that appear must be
    defined in a data definition unless provided by the language.

  - The primitive (built-in) data types in a signature should typically
    be about type rather than semantics. That is, a function that takes
    someone’s name as a string takes a `String`, not a `Name`.

  - A signature is written with the type of each parameter, separated by
    spaces, then an arrow `->` (surrounded by spaces), and then the
    result.

    Bad:
    ```racket
    ;; Integer, String-> Boolean
    ```

    Good:
    ```racket
    ;; Integer String -> Boolean
    ```

  - A purpose statement is one sentence, usually fitting on one
    80-character line, summarizing the purpose of a function. 

  - A purpose statement is *client-oriented*—it’s about what the
    function is for, not how it works.

  - If a function requires further client documentation, skip a line
    after the purpose statement and begin the additional documentation
    there. Do not include details of how a function works in the
    documentation. **This should be very rare.**

### Step 4

  - Templates are **only** used in the *structural decomposition* strategy.

  - The design strategy must be specified right after the examples and
    before the beginning of the function definition itself.

  - Available strategies (as of Oct. 6) include:

      - Structural decomposition

      - Domain knowledge (*specify domain*)

      - Function composition

    It is common for a function design to use more than one strategy—for
    example, you use structural decomposition to analyze a value and
    then in some case use functional composition to produce the result.
    In such cases, list the *main* design strategy for the function. The
    main strategy is typically higher on the above list: structural
    decomposition usually supersedes the other two, and domain
    knowledge usually supersedes function composition.

  - **Only** the *structural decomposition* strategy uses a template.

### Step 6

  - Tests must fully cover your code. One exception: a “run” function
    that just called `big-bang`.

  - Tests must be sufficient to show that a function uses its parameters
    rather than being hard-coded. (One test is never enough.)

  - Tests whose purpose is non-obvious must have a comment explaining
    the reason for the test.

