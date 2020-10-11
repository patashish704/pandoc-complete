---
author: Pandoc Complete
title: "A demo of Pandoc Completion"
year: 2020
bibliography: demo-citation.bib
---

# Header Level 1

In this document, I will insert some equations, figures, listings and
citations. With the help of the pandoc-complete plugin, I will reference them
later.

## Inserting labels {#sec:ins-section}

Here I am inserting a figure.

![This is my first figure](demo-fig/figure1.png){#fig:myfig1 width=100%}

![Second figure](demo-fig/someotherfig.png){#fig:myfig2 width=100%}

![Third figure](demo-fig/thirdfig.png){#fig:myfig3 width=100%}

Let's add some equations. What's in a academic paper if there are no equations?

$$
a^2 + b^2 = c^2
$$ {#eq:pythagorean}

$$
\frac{\partial u}{\partial t} + \frac{\partial u}{\partial x} = 0
$$ {#eq:mywave}

Say I am writing my notes and I need to put in some piece of code for later
reference. Let's do that here

``` {.python .numberLines #lst:pyimports}
import numpy as np
import matplotlib.pyplot as plt
import sympy.integrate as In
```

## Referencing Labels

Now I am going to insert some references to the labels inserted above. The
reference to figure 1 is inserted as [@fig:myfig1]. The listing reference as
[@lst:pyimports]. Lets insert some new figures and labels above. The references
to the newly added figures can be entered as [@fig:myfig2;@fig:myfig3].

If you wish to refer to the labels at the beginning of sentences, then insert a
capital letter and then press `CTRL-X CTRL-O`. For example to insert
[@Fig:myfig2], insert `[@F` and then press `CTRL-X CTRL-O` to get a popup menu
listing figure labels beginning with `F`.

That's all folks !
