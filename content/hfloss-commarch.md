Title: Commarch
Date: 2014-3-19 16:30
Category: HFOSS
Tags: hfoss
Slug: hfoss-commarch
Author: Derek Gonyeo
Summary: The commarch project for the hfoss class

This is my response to the assignment located at
[http://hfoss-fossrit.rhcloud.com/static/hw/commarch.txt](http://hfoss-fossrit.rhcloud.com/static/hw/commarch.txt).

We chose to analyze the systemd project. We did have problems running
git-by-a-bus, as the systemd project is rather large. After 20 hours and about
30 GB of memory, I gave up on running the project. Information has instead been
gathered from Github's graphs on the project.

### Links ###

- IRC: #systemd on irc.freenode.org
- Source Code Repository: [http://cgit.freedesktop.org/systemd/systemd/](http://cgit.freedesktop.org/systemd/systemd/)
- General Development Mailing List Archive:
[http://lists.freedesktop.org/archives/systemd-devel/](http://lists.freedesktop.org/archives/systemd-devel/)
- Various documentation is listed on this page:
[http://www.freedesktop.org/wiki/Software/systemd/](http://www.freedesktop.org/wiki/Software/systemd/)
- Project Website:
[http://www.freedesktop.org/wiki/Software/systemd/](http://www.freedesktop.org/wiki/Software/systemd/)

### Answers ###

Describe software project, its purpose and goals.

>Systemd is a system and service manager for Linux. It aims to replace init, to do
>this in an aggressively parallel manner, and to be a drop in replacement for
>sysvinit.

Give brief history of the project. When was the Initial Commit? The latest
commit?

>The first commit was on April 26, 2005, and the most recent commit on the
>mainline was a few hours ago. The git history suggests that there were several
>independent branches that became one central systemd.

Who approves patches? How many people? 

>Patches are approved through and by the systemd mailing list.

Who has commit access, or has had patches accepted?  How many total?

>16 people have direct commit access.

Who has the highest amounts of "Unique Knowledge?" (As per your "Git-by-a-bus"
report. If there is a tie, list each contributor, with links if possible)

>Git-by-a-bus was unable to run due to the size of the repository. Based on the
>commit graphs in Github, Lennart Poettering and Kay Sievers would have the most
>intimate knowledge with the internals of the project.

What is your project's "Calloway Coefficient of Fail?"

>Looks like the systemd guys are on top of their game, they have a 0 coefficient of fail.

Has there been any turnover in the Core Team? (i.e. has the same top 20% of
contributors stayed the same over time? If not, how has it changed?)

>It does not appear that there has been any turnover in the core team.

Does the project have a BDFL, or Lead Developer? (BDFL == Benevolent Dictator
for Life)

>The lead developers appear to be Lennart Poettering and Kay Sievers

Are the front and back end developers the same people? What is the proportion of
each?

>Systemd is a low level codebase entirely written in C

What have been some of the major bugs/problems/issues that have arisen during
development? Who is responsible for quality control and bug repair?

>TODOs are handled through the mailing list, the github issue tracker is not
>used. The core mailing list is responsible for quality control and bug repair.

How is the project's participation trending and why?

>It would appear that the project’s activity has increased in the past few
>months.

In your opinion, does the project pass "The Raptor Test?" (i.e. Would the
project survive if the BDFL, or most active contributor were eaten by a
Velociraptor?) Why or why not?

>There appears to be two people with a massive amount of contributions to the
>project, so if one of them were to be eaten by a velociraptor, the other one
>would probably be able to carry on

In your opinion, would the project survive if the core team, or most active 20%
of contributors, were hit by a bus? Why or why not?

>Based on the contributor graphs on Github, definitely not. There are two people
>who own the majority of the commits to the project, and then about another 8 who
>own almost all the rest, out of 274 contributors.

Does the project have an official "on-boarding" process in place?  (new
contributor guides, quickstarts, communication leads who focus specifically on
newbies, etc...) 

>There is documentation for “Developers”, though this is more “documentation for
>people using systemd for handling their code”. There is not a lot of
>documentation for developers of systemd itself, except for the “systemd-devel”
>mailing list.

Does the project have Documentation available? Is it extensive?  Does it include
code examples?

>There is a decent amount of documentation, including example usage and
>configuration settings.

If you were going to contribute to this project, but ran into trouble or hit
blockers, who would you contact, and how?

>The best places to ask questions would be in the IRC channel (#systemd on
>Freenode), the mailing list, or the Google+ community

Based on these answers, how would you describe the decision making
structure/process of this group?  Is it hierarchical, consensus building, ruled
by a small group, barely contained chaos, or ruled by a single or pair of
individuals?

>It’s controlled by some linux wizards and their mailing list. The mailing list
>is archived and well documented but you need to be a part of that community if
>you want to contribute

Is this the kind of structure you would enjoy working in? Why, or why not?

>Joining the developers seems to have a difficult start, and the majority of work
>from people outside the core developer group involves sending the patches to a
>mailing list, which is also used for discussion about usage and development.
>These are factors that could be considered a large turn-off from new growth.
