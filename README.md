[![Actions Status](https://github.com/kaz-utashiro/App-ansiecho/workflows/test/badge.svg)](https://github.com/kaz-utashiro/App-ansiecho/actions) [![MetaCPAN Release](https://badge.fury.io/pl/App-ansiecho.svg)](https://metacpan.org/release/App-ansiecho)
# NAME

ansiecho - Colored echo command using ANSI terminal sequence

# VERSION

Version 0.02

# SYNOPSIS

ansiecho -c R Red -c M/551 Magenta/Yellow -c FSDB BlinkReverseBoldBlue

ansiecho -f '\[ %12s \]' -c SR -f '%+06d' 123

ansiecho -C '555/(132,0,41)' d i g i t a l

# DESCRIPTION

## ECHO

**ansiecho** print arguments with ANSI terminal escape sequence
according to the given color specification.

In a simple case, **ansiecho** behave exactly same as [echo](https://metacpan.org/pod/echo) command.

    ansiecho a b c

Like [echo](https://metacpan.org/pod/echo) command, option **-n** disables to print newline at the
end.  Option **-j** (or **--join**) removes white space between
arguments.

Arguments can include backslash escaped characters, such as `\n` for
a new line.  There is an bash-echo-comptible **-e** option, but it is
enabled by default.  You can include control and named Unicode
characters using this.

    ansiecho '\t\N{ALARM CLOCK}\a'

See ["STRING LITERAL"](#string-literal) section for detail.

## COLOR and EFFECT

You can specify color of each argument by preceding with **-c** option:

    ansiecho -c R a -c GI b -c BD c

This command print strings `a`, `b` and `c` according to the color
spec of `R` (Red), `GI` (_Green Italic_) and `BD` (**Blue Bold**)
respectively.

Foreground and background color is specified in the form of
`fore/back`.

    ansiecho -c B/M 'Blue on Magenta' -c '<pink>/<salmon>' fish

Color can be described by 8+8 standard colors, 24 gray scales, 6x6x6
216 colors, RGB values or color names, with special effects such as I
(Italic), D (Double-struck; Bold), S (Stand-out; Reverse Video) and
such.  More information is described in ["COLOR SPEC"](#color-spec) section.

## FORMAT

Format string can be specified by **-f** option, and it behaves like a
[printf](https://metacpan.org/pod/printf) command.

    ansiecho -f '[ %5s : %5s : %5s ]' -c R RED -c G GREEN -c B BLUE

As in above example, colored text can be given as an argument for
**-f** option, and string width is calculated as you expect.

Formatted result becomes a single argument, and can be a subject of
other operation.  In the next example, numbers are formatted, colored,
and gave to other format.

    ansiecho -f '\N{ALARM CLOCK} %s' -c KF/544 -f ' %02d:%02d:%02d ' 1 2 3

Formatting is done by Perl `sprintf` function.  See
["sprintf" in perlfunc](https://metacpan.org/pod/perlfunc#sprintf) for detail.

## ANSI SEQUENCE

To get desired ANSI sequence, use **-S** option.  Next example produce
ANSI terminal sequence to indicate `deeppink` color with
`lightyellow` background.

    ansiecho -n -S '<deeppink>/<lightyellow>'

You will get the next result with 256-color terminal:

    ^[[38;5;198;48;5;230m

and the next with full-color terminal:

    ^[[38;2;255;20;147;48;2;255;255;224m

Using **-S** option, you can set multiple ANSI sequences at once in a
shell script.  Next **bash** code will initialize array variable
`color` with the sequence for given color specs.

    read -a color < <( ansiecho -S ZE -S K/544 -S K/454 -S K/445 )

Then use this variable like:

    reset=${color[0]}
    echo "${color[1]} COLOR 1 ${reset}"
    echo "${color[2]} COLOR 2 ${reset}"
    echo "${color[3]} COLOR 3 ${reset}"

Of course, you can do the same thing by calling **ansiecho** command
directly.

    ansiecho -c K/544 " COLOR 1 "
    ansiecho -c K/454 " COLOR 2 "
    ansiecho -c K/544 " COLOR 3 "

However, calling **ansiecho** many times is not a good idea when the
script is time-conscious.

# OPTIONS

- **-n**

    Do not print newline at the end.

- **-e**, **--**\[**no-**\]**escape**

    Enable interpretation of backslash escapes in the normal string
    argument.  This option is enabled by default, unlike bash built-in
    [echo(1)](http://man.he.net/man1/echo) command.  Use **--no-escape** to disable it.

- **-j**, **--join**

    Do not print space between arguments.  This is a short-cut for
    `--separate ''`.

Above options can be mixed up together, like `-nej`.  Following
options have to appear individually.

- **-c** _spec_ _string_

    Print _string_ in a color given by _spec_.

- **-f** _format_ _args_ ...

    Print _args_ in a given _format_.  Backslash escape is always
    interpreted in the format string.

    The result of **-f** sequence ends up to a single argument, and can be
    a subject of other **-c** or **-f** option.

    Number of arguments are calculated from the number of `%` characters
    in the format string except `%%`.  Variable width and precision
    parameter `*` can be used like `%*s` or `%*.*s`.

    Format string also can be made by **-f** option.  Next command works,
    but second one is better.

        ansiecho -f -f '%%%ds' 16 hello

        ansiecho -f '%*s' 16 hello

- **-C** _spec_

    Option **-C** set permanent color which is applied to all following
    arguments until option **-E** found.

    Next command prints only a word `Yellow` in yellow, but second one
    print `Yellow`, `Brick`, and `Road` in yellow.

        ansiecho Follow the -cYS Yellow Brick Road

        ansiecho Follow the -CYS Yellow Brick Road

    You may want to color the phrase instead.

        ansiecho Follow the -cYS "Yellow Brick Road"

    Option `-C` can be used multiple times mixed with `-F` option.  See
    below.

- **-F** _format_

    As with the `-C` option, `-F` defines a format which is applied to
    all arguments until option **-E** found.  Format string have to include
    single `%s` placeholder.

        ansiecho Follow the -CYS -F ' %s ' Yellow Brick Road

    Option **-C** and **-F** can be used repeatedly, and they will take
    effect in the reverse order of their appearance.

    Next command show argument `A` in underline/bold with blinking red
    arrow.

        ansiecho -cRF -f'->%s' -cUD A B C

    Next one does the same thing for all arguments.

        ansiecho -CRF -F'->%s' -CUD A B C

- **-E** _spec_

    Terminate **-C** and **-F** effects.

- **-s** _spec_
- **-z** _spec_

    Add raw ANSI sequence given by _spec_.  Option **-s** add the sequence
    to the next argument, while **-z** add to the final argument.

    Next two commands are equivalent.

        ansiecho -c R Red
        ansiecho -s R Red -z ZE

    Color spec `ZE` produces RESET and ERASE LINE sequence.

    Because **-s** and **-z** does not produce RESET sequence, you can use
    them to accumulate the effects.

        ansiecho -s R R -s U RU -s I RUI -s S RUIS -s F RUISF -z Z

- **-S** _spec_

    Echo raw ANSI sequence given by _spec_ as an argument.

- **--separate** _string_

    Set separator string between each arguments.  Option **-j** is a
    short-cut for **--separate ''**.

- **--**\[**no**\]**rgb24**

    Produce 24bit full-color sequence for 12bit/24bit specified colors.
    They are converted to 216 colors by default.

# STRING LITERAL

This is a backslash escape samples described in ["Quote and
Quote-like Operators" in perlop](https://metacpan.org/pod/perlop#Quote-and-Quote-like-Operators).

    Sequence     Description
    \t           tab               (HT, TAB)
    \n           newline           (NL)
    \r           return            (CR)
    \f           form feed         (FF)
    \b           backspace         (BS)
    \a           alarm (bell)      (BEL)
    \e           escape            (ESC)
    \x{263A}     hex char          (example: SMILEY)
    \x1b         restricted range hex char (example: ESC)
    \N{name}     named Unicode character or character sequence
    \N{U+263D}   Unicode character (example: FIRST QUARTER MOON)
    \c[          control char      (example: chr(27))
    \o{23072}    octal char        (example: SMILEY)
    \033         restricted range octal char  (example: ESC)

# COLOR SPEC

This is a brief summary.  Read ["COLOR SPEC" in Getopt::EX::Colormap](https://metacpan.org/pod/Getopt::EX::Colormap#COLOR-SPEC) for
complete description.

Color specification is a combination of single uppercase character
representing 8 colors, and alternative (usually brighter) colors in
lowercase :

    R  r  Red
    G  g  Green
    B  b  Blue
    C  c  Cyan
    M  m  Magenta
    Y  y  Yellow
    K  k  Black
    W  w  White

or RGB values and 24 grey levels if using ANSI 256 or full color
terminal :

    (255,255,255)      : 24bit decimal RGB colors
    #000000 .. #FFFFFF : 24bit hex RGB colors
    #000    .. #FFF    : 12bit hex RGB 4096 colors
    000 .. 555         : 6x6x6 RGB 216 colors
    L00 .. L25         : Black (L00), 24 grey levels, White (L25)

or color names enclosed by angle bracket :

    <red> <blue> <green> <cyan> <magenta> <yellow>
    <aliceblue> <honeydue> <hotpink> <mooccasin>
    <medium_aqua_marine>

with other special effects :

    N    None
    Z  0 Zero (reset)
    D  1 Double-struck (boldface)
    P  2 Pale (dark)
    I  3 Italic
    U  4 Underline
    F  5 Flash (blink: slow)
    Q  6 Quick (blink: rapid)
    S  7 Stand-out (reverse video)
    V  8 Vanish (concealed)
    X  9 Crossed out

    E    Erase Line

    ;    No effect
    /    Toggle foreground/background
    ^    Reset to foreground
    ~    Cancel following effect

Samples:

    RGB  6x6x6    12bit      24bit           color name
    ===  =======  =========  =============  ==================
    B    005      #00F       (0,0,255)      <blue>
     /M     /505      /#F0F   /(255,0,255)  /<magenta>
    K/W  000/555  #000/#FFF  000000/FFFFFF  <black>/<white>
    R/G  500/050  #F00/#0F0  FF0000/00FF00  <red>/<green>
    W/w  L03/L20  #333/#ccc  303030/c6c6c6  <dimgrey>/<lightgrey>

# 256/24BIT COLORS

12bit/24bit colors are converted to 216 colors because most terminal
can not display them.  If you are using full-color terminal, such as
iTerm2 on Mac, use **--rgb24** option or set `GETOPTEX_RGB24`
environment variable to produce full-color sequence.

# INSTALL

## CPANMINUS

From CPAN archive:

    $ cpanm App::ansiecho
    or
    $ curl -sL http://cpanmin.us | perl - App::ansiecho

From GIT repository:

    cpanm https://github.com/kaz-utashiro/App-ansiecho.git

# SEE ALSO

["Quote and Quote-like Operators" in perlop](https://metacpan.org/pod/perlop#Quote-and-Quote-like-Operators)

[Getopt::EX::Colormap](https://metacpan.org/pod/Getopt::EX::Colormap)

[https://en.wikipedia.org/wiki/ANSI\_escape\_code](https://en.wikipedia.org/wiki/ANSI_escape_code)

[Graphics::ColorNames::X](https://metacpan.org/pod/Graphics::ColorNames::X)

[https://en.wikipedia.org/wiki/X11\_color\_names](https://en.wikipedia.org/wiki/X11_color_names)

[App::ansifold](https://metacpan.org/pod/App::ansifold), [App::ansicolumn](https://metacpan.org/pod/App::ansicolumn)

# AUTHOR

Kazumasa Utashiro

# LICENSE

Copyright 2021 Kazumasa Utashiro.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
