---
title: Predicting Random Numbers
tags: C
---

Animations in ODD have storage. When called, one of the parameters received is a
pointer to a double, where they can store a set amount of information.  When an 
animation is declared in animations.def, it is specified there how much storage 
they get. This allows for animations like the Game Of Life to have persistence 
between renders. It can store what its state is, and know each render what state
it was last in. Most animations don't use this storage, but things like the Game 
Of Life would be much more complicated, if not impossible to do fast enough, 
without it.

Animations like Cylon Eye and the new Wave are generated solely based on one 
thing: the time. The ideal animation needs nothing more. Give it the time, and
it will give you an array of colors. Having a persistent storage can complicate
that design. To make the animation run faster, multiply the time by some number 
greater than 1 for the given animation. To see what the animation will be doing 
in ten seconds, add ten to it.

Last night I got the idea for a new animation, where each second a random
location in the strip will be selected to display a "ripple" effect at. I wished
to refrain from using the storage for this animation. I could've used it to
record where each location a ripple was occurring, and how far along the
animation had progressed, but I would've encountered problems when the
frequency of ripples was cranked up. The animations can only request a finite
amount of storage, and it would be possible for the frequency of ripples or the
duration of them to be high enough to cause there to be more visible than I had
space to take note of.

A way around this would be possible if I could know what random numbers I
would've generated at any given time. If I was rendering a frame, and based on
the time it takes for ripples to play I know that there should be five more
currently visible, I could render them if I had known what other five random
locations I had chosen. Knowing how far progressed they were was as simple as
(currenttime - ((int)currenttime - i)) / duration.

Each new random number was generated every second on the second. I'd need a
random number for 4006, 4007, 4008, etc. I'd also need to know what previous
random numbers were. If the time was 4008.7 and ripples lasted three seconds, 
I'd need to know where the ripples were randomly placed at seconds 4008, 4007, 
and 4006 so I could draw them. Ripple 4008 would be 0.7/3 percent done, ripple 
4007 would be 1.7/3 percent done, and ripple 4006 would be 2.7/3 percent done. 

My solution for this was to seed the random numbers with the current time each
time I wanted a new number (despite the top comment on a [stack
overflow](http://stackoverflow.com/questions/822323/how-to-generate-a-random-number-in-c)
response telling me not to in italicised text). This resulted in pseudo-random 
numbers each time, but the numbers were dependent on the time. 

So if totalTime is 4008.7, to get the location for the ripple that started at
4008 would be:

```c
srand((int)totalTime);
double location = rand() * 1.0 / RAND_MAX;
```

And to get the ripple at 4007 it would be:

```c
srand((int)totalTime - 1);
double location = rand() * 1.0 / RAND_MAX;
```

And with this the Rain animation has it's randomly placed ripples, and each
render I can recalculate where the ripples were without needing to store the
locations.
