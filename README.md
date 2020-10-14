# Pandoc-Complete: Your completion buddy for editing Pandoc-style markdown files

## Table of Contents

- [Introduction](#introduction)
- [Pre-requisites](#pre-requisites)
- [Installation](#installation)
- [Usage](#Usage)
- [Configuration](#configuration)
    - [Completion Menu](#completion-menu)
    - [Global Variables](#global-variables-gpandoccomplete_figdirtype-and-gpandoccomplete_figdirpre)
    - [Autocompletion](#autocompletion)
- [Quick Start](#quick-start)
- [License](#license)

## Introduction

You will find this plugin useful if:

- You write academic documents or take notes in vim using
  [Pandoc](https://github.com/jgm/pandoc) style markdown files. AND
- Utilize the [pandoc-crossref](https://github.com/lierdakil/pandoc-crossref)
  and [pandoc-citeproc](https://github.com/jgm/pandoc-citeproc) filters for
  cross-referencing and citations.

This plugin sets the `'omnifunc'` option (`:h compl-omni`) and populates the
completion menu with reference labels for figures, equations, tables, listings,
sections, citations and more.

Let's look at an example to understand the functionality that this plugin
provides. Say the currently edited markdown file has a number of places where
figures are inserted. Each figure has a label written in `pandoc-crossref`
style: `#fig:somefigname`. There are several such labels scattered across
current markdown file. Now you start to enter text and you need to insert
reference to a particular label but do not exactly remember what the name of
the label is.  If you have `pandoc-complete` installed, you could fire-up a
completion menu in insert mode by entering (`CTRL-X CTRL-O`). You will get a
popup menu list containing all the labels that are defined in the current
buffer (document). You could keep on typing few more characters and this list
keeps getting shorter dynamically, responding to the typed characters. When
your list gets sufficiently shorter, you could use `CTRL-N` or `CTRL-P` to
accept the suggested entry.

Relying on the completion menu to insert your references ensures accuracy by
eliminating the chances of a typo.

![A demonstration of how the CTRL-X CTRL-O key-chord fires up a completion menu](demo/Peek-demo.gif "Peek-demo")

This plugin makes use of the built-in omnicomplete feature of vim, and is
therefore superlight. For more detailed information on omni completion and
insert completion in general please read the help docs (`:h ins-completion`).

## Pre-requisites

`Pandoc-complete` is written in pure Vimscript. No other installation is
required to be able to use this plugin.

## Installation

Use your favorite plugin manager to install `pandoc-complete`, which is
recommended because you can easily keep all your plugins updated.

If instead you wish to manually install `pandoc-complete` using vim's native
plugin manager, you can do so by following these steps:

- `mkdir -p ~/.vim/pack/myplugins/start`
- `cd !$`
- `git clone https://github.com/patashish704/pandoc-complete.git`

Here you can change `myplugins` to any other directory name, but the rest of the
components of the path should remain the same.

## Usage

`Pandoc-complete` populates the omni-completion menu from the following sources

- `[Figure], [Equation], [Listing], [Section], [Table]`: Labels of figures,
  equations, listings, sections and tables that are present in the currently
  edited markdown file. Example: `#fig:myfig1`.
- `[Citation]` Keys in your bibliography file (.bib file). Example: `Smith2014`
- `[ins-Figure]`: Name of figure (relative path) that you wish to insert in the
  currently edited markdown file. Note that authors usually keep their figures
  in a separate folder. Only those figure names will appear in the
  omni-completion menu that are not yet inserted in the currently edited
  markdown file. This has been done to keep the completion menu short. Example:
  the figure path in `![This is a caption](figures/myfig1.png)`

While in insert mode, enter `CTRL-X CTRL-O`, which is the builtin key-chord for
launching omni-completion menu. You will see all the items listed above in this
menu. Keep on typing more characters to narrow down your search; the menu will
dynamically become shorter. When the menu becomes sufficiently short (usually
to 3-4 entries), you can press `CTRL-N` or `CTRL-P` to make a selection.

If you wish to refer to the labels at the beginning of sentences, then in
insert mode enter a capital letter and then press `CTRL-X CTRL-O`. For example
to insert [@Fig:myfig2], type `[@F` in insert mode and then press `CTRL-X
CTRL-O` to get a popup menu listing figure labels beginning with `F`.

The bibliography file can be included in the yaml header in one of the
following two formats:

``` yaml
bibliography: mycitations.bib
```

or

``` yaml
bibliography:
    - citations/mycitations.bib
    - someothersource.bib
```

In the omni-completion menu, additional info (title) is shown for each citation
key that is selected.

The current plugin reads from currently edited buffer. You can add new labels
for figures, tables etc. and they will automatically get introduced into the
omni-completion menu. You do not need to save the edited markdown file for
populating the completion menu.

## Configuration

### Completion-menu

In your `~/.vimrc` file, set the following option:

``` vim
set completeopt=menuone,noinsert,popup
```

This  will allow you to dynamically filter completion menu entries as you type
in more characters in insert mode. The `popup` is required to show extra
information for each citation key.

You may further use the Vim's built-in options and highlight-groups to
customize the look of completion menu. See `:h completeopt, :h completepopup,
:h highlight`.

*Example*: I added the following options to `~/.vimrc` to customize the visual
appearance of completion menu in the demo gif shown above.

``` vim
set completepopup=border:off
highlight Pmenu ctermbg=237 ctermfg=250
highlight PmenuSel ctermbg=109 ctermfg=234 cterm=bold
```

If you edit text in gvim, then these options should be set in `~/.gvimrc`,
e.g.,

``` vim
hi Pmenu guibg=#474747
hi PmenuSel guibg=#607865 guifg=#171717 gui=bold
```

Additionally, the following global variables are available to tailor this
plugin to suit individual needs:

### Global variables: `g:PandocComplete_figdirtype` and `g:PandocComplete_figdirpre`

These global variables apply to the `[ins-Figure]` entries described above. If
you have inserted images in your markdown file, and your images are not in
the current directory, then you need to set these variables in your `~/.vimrc`.

If `g:PandocComplete_figdirtype` is set to `1` and `g:PandocComplete_figdirpre`
is set to a string, say `"figures"`, then the image file is searched in that
directory, e.g., `figures/example.png` will appear in the omni-completion menu.

If `g:PandocComplete_figdirtype` is set to `2` and `g:PandocComplete_figdirpre`
is set to a string say, `"_fig-"`, and your current markdown buffer name is,
say `myexamplemarkdown.md`, then the image files are searched in a directory
called `_fig-myexamplemarkdown/`. The entry
`_fig-myexamplemarkdown/example.png` will appear in the completion menu.

*Default Values* (Refers to current directory):

    g:PandocComplete_figdirtype : 0
    g:PandocComplete_figdirpre : ""

*Example*: For the demo in the gif above, I have used the following settings:

``` vim
let g:PandocComplete_figdirtype = 1
let g:PandocComplete_figdirpre = 'demo-fig'
```

### Autocompletion

If you ever get tired of typing `CTRL-X CTRL-O` over and over again, you may
add the following snippet to your `~/.vimrc`.

``` vim
inoremap @ @<C-X><C-O>
```

This will automatically launch the completion menu whenever you type @ symbol
while in insert mode. However, to insert reference labels beginning with a
capital letter, you will have to press `CTRL-X CTRL-O` again. For example, if
you wish to insert `@Fig:myfig1`, type `@F` in insert mode and then press
`CTRL-X CTRL-O` to launch the completion menu containing relevant entries.

## Quick Start

After installing pandoc-complete, `cd` into the `demo` directory that ships
with this plugin and open `demo_pandoc.md` in vim editor. Try inserting some
references by entering `CTRL-X CTRL-O` while in insert mode. Take hints from
the gif file included in the `demo` directory or inserted in this README file.

## License

MIT
