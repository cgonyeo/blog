---
title: Brandreth
tags: Projects
---

In the summer of 2013 a friend of mine went through the guest book from another
[friend's cabin](http://en.wikipedia.org/wiki/Brandreth_Park), and entered all
20 years worth of entries into a spreadsheet. I built a site around accessing
the data, and it served as a pretty cool way for CSH members and alumni to look
back and reminisce about past trips to the cabin.  The site itself was pretty
scary when you looked under the hood though, so this past summer I remade the
site to be less of an abomination. The goal was to have the site be faster, look
similar if not better, and use Go and Postgres.

And thus [Brandreth2.0](https://github.com/dgonyeo/brandreth2.0) was written.
It's live at [https://brandreth.csh.rit.edu/](https://brandreth.csh.rit.edu/)
(requires a CSH account to access). It took some time to get off the ground, as
I wasn't very familiar with Go or SQL, but the finished product has (almost) all
the functionality of the previous implementation and is far faster. This also
ultimately helped me get a project off the ground at
[Hudl](http://www.hudl.com/) faster, since it had a very similar design (a Go
web app that uses Postgres).

This implementation also includes the ability to add entries from the website
directly instead of mucking around in the database, which will maybe allow me to
hand off maintaining it to someone else, but this process needs some serious
polishing before I'd be comfortable asking someone else to use it. 

It was a fun little project that ate up a few weeks of spare time this past
summer. Hopefully I get back to it at some point, there's a couple extra
features that would be nice.

<div class="text-center">
![](/images/brandreth-trips.png)

----------

![](/images/brandreth-trip.png)

----------

![](/images/brandreth-person.png)

----------

![](/images/brandreth-people.png)

----------

![](/images/brandreth-stats.png)

----------

![](/images/brandreth-leaderboard.png)
</div>
