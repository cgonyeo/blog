---
title: Brandreth Rewrite
tags: Projects
---

Last summer I looked at the website for Brandreth that I had made, came to the
conclusion that it was a steaming pile of crap, and rewrote the entire thing
from the ground up. My writeup of the results of that is
[here](https://blog.gonyeo.com/posts/2014-11-04-brandreth.html).

A week and a half ago I looked at the rewrite I had done, came to the conclusion
that it was a steaming pile of crap, and just yesterday finished rewriting the
entire thing from the ground up.

This time the site was implemented in Haskell using the [Yesod
Framework](http://www.yesodweb.com/). I had some experience coming in to this
with yesod, from a project I started a few months ago that ended up being left
30% done (like the vast majority of my projects). This time the point was on
making a functional application, instead of getting familiar with new
technologies. After about 9 days, I think I've accomplished exactly that.

The biggest issue with the last iteration was an _almost_ completely broken
interface for logging new entries. All entries for the trip were entered on the
same page. If you accidentally clicked the "add person" button too many times,
you had to start over. If you took too long transcribing the entries and your
WebAuth credentials expired, you had to start over. If you typed someone's name
or a trip reason wrong, the database would be left in an incorrect state (with
duplicate rows). There are probably other problems I've forgotten.

It being so broken, I didn't open access to it to anyone else. If I had, they
would have discovered it was broken and complained a lot. So entering all the
new trips fell on me, and I have a tendency to forget to do things.

The new version fixes all of this. You enter in entries one at a time, so when
your WebAuth credentials expire you've only lost the current entry you were
working on. You can't accidentally add too many people to a trip. You can't
misspell someone's name, or a trip reason. The whole UI is a little more
intuitive in my opinion, too.

There's also a handful of other improvements, the biggest one being new support
for doodles and images of the original entries. If a visitor draws a little
thing in the guestbook, the website can now display that on the page next to the
typed up copy of the entry. If you think there's an issue in the transcription,
or you just want to see the person's original entry anyway, you can click a
button and view the picture that was taken of that page in the guestbook.

There's also a secondary leaderboard now. The one based on number of trips is
still accessible, but you can also rank people based on the number of nights
they've spent at Brandreth.

All in all it was an enjoyable experience to rewrite. Development went way
faster than I had expected, even though the complexity for the site had
significantly increased between new features and a vastly improved admin
interface. CSH members can visit
[https://brandreth.csh.rit.edu](https://brandreth.csh.rit.edu) to see the new
version, and other Brandreth visitors can talk to Potter about getting access if
they want to see.

The code for the site lives on [GitHub](https://github.com/dgonyeo/brandskell).
Disclaimer: there are still a handful of rather sloppy things in the codebase.
The focus was on getting all the features to work correctly in a timely fashion,
not to build the most efficient thing possible. The average number of daily
unique visitors for the site is probably less than 1.
