---
title: Imagine RIT
tags: Misc
---

Project ODD is finally along far enough to show to other people, so I'm going to
be showing it off in a few weeks at [Imagine RIT](http://www.rit.edu/imagine/).
I'll be walking through a sequence of animations to describe how it works, and
show off some of the things it can do. 

<div class="text-center">
<iframe width="560" height="315" src="//www.youtube.com/embed/QDDMUI2R8Rw" frameborder="0" allowfullscreen></iframe>
</div>

Right now ODD is controlled over the network; to alter what it is doing
something must connect to a socket and send over json detailing what to do. This
is accomplished with python scripts. I have scripts to remove animations, and
scripts to add animations. To do something, I generally run removeall.py and
then something like rainbow.py. This works great for my personal use, but it 
takes multiple seconds for the pi to load in python while the processor is 
chugging along controlling the LEDs. Lots of typing and then 10 seconds of 
awkward waiting for something to happen does not a good demo make.

To alleviate this I wrote a new python script, a slide show of sorts. It has a
list of animations, and I can step through them by using the right and left
arrow keys. The details for each "slide" are displayed on the screen in a curses
ui. This limits me to quickly being able to access only specific animations with
specific parameters, but for giving the same 2 minute speech over and over again
over the course of Imagine RIT it should prove pretty valuable. 

Possible improvements: reading in the slides from a config file would make this
tool far more useful, and being able to jump to an arbitrary slide instead of
hitting left 10 times while each slide is displayed.
