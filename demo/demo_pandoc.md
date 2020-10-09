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

## Inserting labels

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
referece. Let's do that here

``` {.python .numberLines #lst:pyimports}
import numpy as np
import matplotlib.pyplot as plt
import sympy.integrate as In
```

## Referencing Labels

Now I am going to insert some labels. The reference to figure 1 is inserted as
[@fig:myfig1]. The listing reference is inserted as [@lst:pyimports]. Lets
insert some new figures and labels above. Lets insert reference to newly added
figures: [@fig:myfig2; @fig:myfig3]. That's all !

