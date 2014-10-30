---
title: Multiple routing tables in FreeBSD
tags: Misc
---

*Edit: a friend just informed me this is called
[split-tunneling](http://en.wikipedia.org/wiki/Split_tunneling)*

I recently ran into an interesting problem. You can subscribe for VPN services
that route your traffic through various places, so as to keep yourself
anonymous. Most if not all of these use OpenVPN. After looking through a few
different companies, I decided to go with
[Ipredator](https://www.ipredator.se/). I hopped on their IRC, and after talking
to someone got a free trial. I followed their
[guide](https://www.ipredator.se/guide/openvpn/freebsd/native) to get OpenVPN
all configured to use their service, and started it up. Upon startup, I then
discovered that OpenVPN pushes new routes to the system's routing table, forcing
all traffic to go through it, which promptly locked me out of my machine.

I still want to be able to access my machine at it's normal location, and I only
want a few services to go through the VPN (there's a significant latency and
speed penalty for using it). The solution, was to take advantage of FreeBSD's
[fibs](http://www.freebsd.org/cgi/man.cgi?query=setfib&apropos=0&sektion=0&manpath=FreeBSD+9.2-RELEASE&arch=default&format=html).

Step one was to add a build option to the kernel and recompile it. Having
multiple fibs isn't enabled in the kernel by default, so you need to add an
option to the build to make multiple fibs available. This was surprisingly easy,
but it's worth noting that this will prevent freebsd-update from automatically 
updating your kernel. After running freebsd-update, you'll need to go rebuild 
and reinstall your custom kernel. 

Change the path you go to based on your architecture.

```bash
cd /usr/src/sys/amd64/conf/
cp GENERIC MOREROUTINGTABLES
echo "options     ROUTETABLES=16" >> MOREROUTINGTABLES
cd ..
make buildkernel KERNCONF=MOREROUTINGTABLES
make installkernel KERNCONF=MOREROUTINGTABLES
reboot
```

This will save your old kernel to `/boot/kernel.old/kernel`. For more
information on custom kernels check out the [FreeBSD
Handbook](http://www.freebsd.org/doc/handbook/kernelconfig-building.html).

The option we added enabled 16 FIBs, or Forward Information Bases. As far as I
can tell this is just a fancy word for a routing table. 16 is the maximum
amount, you can have fewer if you want. I figure add 16 so I don't need to
recompile if I want more.

Upon rebooting, you can now use the
[setfib](http://www.freebsd.org/cgi/man.cgi?query=setfib&apropos=0&sektion=0&manpath=FreeBSD+9.2-RELEASE&arch=default&format=html)
tool. This changes the fib for whatever command you want to use, which
effectively makes a given process use a different routing table than everything
else on the system. For example, you can use `netstat -r` to see the routing
table on the system. To demonstrate this, run:

```bash
netstat -r
setfib 0 netstat -r
setfib 1 netstat -r
```

You'll see that the output from `netstat -r` matches the output from `setfib 0
netstat -r`. This is because fib 0 is the default, and it's what everything on
your system is using. You'll also see that the output from `setfib 0 netstat -r`
doesn't match `setfib 1 netstat -r`. FreeBSD only populates fib 0 with all the
relevant information like your default route, so fib 1 looks rather empty. This
means that fib 1 doesn't have any of the necessary information for processes to
be able to talk to the outside world.

```bash
ping -c 5 8.8.8.8
setfib 1 ping -c 8.8.8.8
```

To fix this, let's add a default route to fib 1. If you look at `netstat -r`,
you'll see a line kind of like:

    default            xcsh-050-247.csh.r UGS         0  3159817   msk0

The destination is marked as "default", and the gateway is
`xcsh-050-247.csh.rit.edu`, or in my case `129.21.50.247`. So let's add this as
the default route for fib 1.

```bash
setfib 1 route add default 129.21.50.247
```

Now if we try to ping something using fib 1, `setfib 1 ping -c 5 8.8.8.8`, we
can reach it.

Now we're on the part where OpenVPN comes in. Set up OpenVPN following
IPredator's previously referenced
[guide](https://www.ipredator.se/guide/openvpn/freebsd/native), but don't start
it yet. Once everything's set up, open up `/usr/local/etc/rc.d/openvpn`. Find
the part towards the bottom (line 101 for me), that reads:

    command="/usr/local/sbin/openvpn"
    
and change it to:

    command="/usr/sbin/setfib"
    
This makes it so that setfib is invoked instead of openvpn. To have openvpn
still run, it needs to be one of the arguments to setfib, in addition to setting
which fib we want. Find the line further down (123 for me) that reads:

    command_args="--cd ${dir} --daemon ${name} --config ${configfile} --writepid ${pidfile}"

and change it to:

    command_args="-F 1 /usr/local/sbin/openvpn --cd ${dir} --daemon ${name} --config ${configfile} --writepid ${pidfile}"

Save and close the file. With these changes, OpenVPN will be called with setfib,
to use fib 1. The point being that when it pushes it's routes, they'll be 
pushed to the non-default routing table, everything will still flow out of the
machine as normal, and we can specify specific processes to use fib 1 and thus
use the vpn to go out. Let's start up the vpn with:

```bash
/usr/local/etc/rc.d/openvpn start
```

If everything has gone according to plan, you'll now see different routes with
`setfib 1 netstat -r`. If you ping using fib 1 `setfib 1 ping -c 5 8.8.8.8` you
should be able to still access the outside world, and you'll probably (at least
I did) have a little higher latency.

There's one thing left to do before we can say we're done though. If you recall,
we manually added a default route to fib 1 so things using it had a path to talk
to the outside world. If we reboot the system, OpenVPN will attempt to use fib 1
to get to the OpenVPN server and negotiate it's connection, but it won't be able
to contact the server without a valid default route.

The way I went about solving this was to make `/etc/rc.local` and put the
respective command in there. This is a file that the system will call on
startup, so OpenVPN can have it's default route to do it's thing. If the file
doesn't exist (it didn't for me), make it, and then open it. Mine reads as the
following:

```bash
#!/bin/sh
# file: /etc/rc.local

#Add a default route to CSH's gateway on fib 1,
#so openvpn can negotiate it's things before it
#pushes it's own routes
setfib 1 route add default 129.21.50.247
```

You'll want to change the address based on your network, and this'll break if
your default route changes. There's probably a more elegant way to do this, but
it works for me.

And with that we're done! OpenVPN begins on startup, uses fib 1 for all of it's
connections, has a valid default route on start up to negotiate it's connection,
and you can have any arbitrary process use the VPN when you start the process.

This is useful because you can easily mask your identity with this. For example,
I can hop on CSH's IRC server from Sweden now, preventing them from identifying
me (as opposed to if I join directly from my machine, which they know and will
recognize).
