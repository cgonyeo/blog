---
title: FFTs in ODD
tags: ODD
---

So in [Project ODD](http://blog.gonyeo.com/category/odd.html) I handle sound. I 
use an audio splitter to take any sound going to my speakers, and pass it in to
a USB audio dongle I have on the Raspberry Pi that powers the project. The Pi
then generates some animations based upon the audio.

The most simple of these animations turns on all of the LEDs and varies their
brightness with the volume of the sound. This is a cool proof of concept, but
lacks the pretty visualizations I'm aiming for, as it's not very easy to see
subtle variations in the volume level with this strategy.

The next attempt made a bar, who's length and brightness varies with the volume
level (volume again because getting that is easy). Anchored to one end, the LEDs
will light up for a certain length towards the other end, and as the music gets
louder or quieter the number of LEDs would respectively grow or shrink. This
made a cool pulsing effect, that's interesting to look at and results in a
pulsing light cast on things around it. When combined with the "Set All"
animation as a weak background, it can be quite enjoyable.

From there I went on to use FFTs to break down the audio coming in, and
calculate which frequencies are present in the music. The goal being I can
display a spectograph across the LEDs, mapping one end of the strip to low
frequencies and as you move down the strip assigning the LEDs to higher
frequencies. This results in an animation wherein you can clearly see the
difference between the bass drum and vocals, and other sounds; something the
previous attempts fail to do. It also still results in the pulsing light on the
surrounding walls and ceiling. 

It took some time to have these animations workable; I had some conceptual
problems not understanding how to process sound. At first, I attempted to just
sum up all the values to get the sound, but I later realized half of these
values were negative. Each sample was a float, between -1 and 1. I them summed
up the absolute value of each sample, and was able to accurately get the average
sound across the sound buffer. 

Displaying this though, it didn't appear to move as well as I was expecting.
Upon conversing with another member of the Computer Science House, I learned
(remembered) that sound was logarithmic. I then scaled this volume
logarithmically and got a nice looking animation.

The next step was using the FFTs; if I could understand what frequencies were in
my sound buffer I would have more information to display in an animation. After
reading a good bit about FFTs online I wasn't sure how to tweak it however.

The various places across the internet I found can explain it much better than I
can, and I suggest googling around if you're interested in this stuff, but
pretty much what I ended up doing was having a buffer of 1024, not padding my
array with 0s, to fill in the buffer of answers I take the square root of the
sum of the sqaures (Pythagorean Theorem) from the two buffers I get as output.
The values I also get very much favor lower frequencies. While probably
accurate, this isn't what I want to show for the animation, so I apply an
exponential (going to try out a logarithmic scale soon, because apparently
that's what I actually want) to the sounds to make the higher frequencies
brighter. I also only look at the frequencies between 0 Hz and 1875 Hz (most
probably gonna start including some frequencies higher than that soon).

All in all it's been fun playing around with the sound to see what looks good,
if not a slow process. I'm excited for when I can build a larger display to see
what having a higher resolutions will look like.
