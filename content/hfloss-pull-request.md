Title: Making a pull request for great FOSS
Date: 2014-3-3 14:00
Category: HFOSS
Tags: hfoss
Slug: hfoss-pull-request
Author: Derek Gonyeo
Summary: For the HFOSS class I make a pull request to an open source project

For the assignment [bugfix](http://hfoss-fossrit.rhcloud.com/hw/bugfix) I
was tasked with finding an open source project, and making a pull request to it.
This could be anything from fixing a typo to addig major functionality. I had
grand ambitions of adding a load balancer to
[Fargo](https://github.com/hudl/fargo), which is a client for Netflix's
[Eureka](https://github.com/Netflix/eureka). Right now, it just randomly selects
a server, but could do fancy things basd on geography, remembering which servers
it failed to connect to, and other things. As an added bonus, I could practice
my go.

Alas, I did not expect to run in to one of my old rivals: Ruby. The language has
a burning hatred towards me for no good reason, and the tool recommended to me
to provision the vms was [Vagrant](http://www.vagrantup.com/). As is typical for
most things I attempt to use in Ruby, I spent multiple days to get it working
and ultimately was only able to get it to barely work. In the end it locked both
me and itself out of my vms for no apparent reason and I gave up.

After my multi-day vagrant saga, I was still left with my assignment to
complete. Luckily Ryan Brown and Ross Delinger have been working on a cool
little project called [Lego Web
Services](https://github.com/ryansb/legowebservices). There was a file called
m.go, that could use some clarification. I added a little one line comment to
rectify this, and made a [pull
request](https://github.com/ryansb/legowebservices/pull/5) with the change,
which was promptly accepted. 
