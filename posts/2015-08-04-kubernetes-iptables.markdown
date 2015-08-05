---
title: Securing Kubernetes on CoreOS with iptables
tags: Linux
---

As of lately I've been playing around with [Kubernetes](http://kubernetes.io/)
on [CoreOS](https://coreos.com/). I've been installing it on real hardware
(well, VMs for now), none of this AWS/GCE shit. I aim to deploy a Kubernetes
setup for the [Computer Science House](http://csh.rit.edu/) early in Fall
semester of this year, and run our webs environment in it.

One nice thing about CSH is that we have publicly routable subnets through RIT.
The downside to this is that anyone on the open internet can poke at our things
from anywhere, so we need to make sure that our things are locked down.

To address this, enter `iptables`. Instead of allowing random people on the
internet to push pods to our nodes (as fun as that sounds) I googled around and
found a [blog post on how to set up iptables rules in a cloud
config](http://www.jimmycuadra.com/posts/securing-coreos-with-iptables/).
Huzzah! I added rules to only allow incoming traffic from the other machines in
the setup, added it to the cloud config, and went about my day.

```yaml
write-files:
  - path: /var/lib/iptables/rules-save
    permissions: 0644
    owner: root:root
    content: |
      *filter
      :INPUT DROP [0:0]
      :FORWARD DROP [0:0]
      :OUTPUT ACCEPT [0:0]
      -A INPUT -i lo -j ACCEPT
      -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
      -A INPUT -p tcp -m tcp --dport 22 -j ACCEPT
      -A INPUT --src 129.21.49.49 -j ACCEPT
      -A INPUT --src 129.21.49.48 -j ACCEPT
      -A INPUT --src 129.21.49.53 -j ACCEPT
      -A INPUT --src 129.21.49.54 -j ACCEPT
      -A INPUT -p icmp -m icmp --icmp-type 0 -j ACCEPT
      -A INPUT -p icmp -m icmp --icmp-type 3 -j ACCEPT
      -A INPUT -p icmp -m icmp --icmp-type 11 -j ACCEPT
      COMMIT
  - path: /var/lib/ip6tables/rules-save
    permissions: 0644
    owner: root:root
    content: |
      *filter
      :INPUT DROP [0:0]
      :FORWARD DROP [0:0]
      :OUTPUT ACCEPT [0:0]
      -A INPUT -i lo -j ACCEPT
      -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
      -A INPUT -p tcp -m tcp --dport 22 -j ACCEPT
      -A INPUT -p icmpv6 -j ACCEPT
      COMMIT
coreos:
  units:
    - name: iptables-restore.service
      enable: true
      command: start
    - name: ip6tables-restore.service
      enable: true
      command: start
```

This appeared to work great. The four IP addresses I added were my master, my
two workers, and my load balancer, so they could all talk to each other. The
load balancer didn't have these rules, so HTTP requests could get to it from
anywhere and it would then forward the requests on to the workers.

There was some weirdness I noticed a little while later though. I was working on
setting up a mediawiki pod, and only had a single replica of it running. Exactly
half the requests that the load balancer got were hanging for a few seconds, and
then returning proxy errors. A web environment that returns 500 errors 50% of
the time is no good, and upon closer inspection only one of my workers was
correctly responding to requests for that service, which was bizarre.

After some back and forth on `#coreos` on [freenode](http://freenode.net/) with
a super helpful person going by the handle of `kayrus`, it was discovered that
disabling iptables fixed my problem. `kayrus` set up a local Kubernetes instance
with my iptables rules to help see what was wrong with them, and he suggested
that I add `-A INPUT --src 10.244.0.0/16 -j ACCEPT`. The `10.244.0.0/16` network
is the subnet that flannel is configured to use.  With that rule in place, the
nodes were able to ping each other over flannel. This wasn't the whole
solution though, as the second node was still not able to handle the HTTP
requests.

With a little more poking, I noticed that the second worker could ping the other
worker over flannel, but it couldn't reach the IP address for the pod that was
running on the other worker over flannel. Turns out, the rules as I had them
allowed incoming traffic over flannel, but preventing any forwarding of that
traffic. I added rules matching all my `INPUT` rules with the `--src` flags, but
put them in the `FORWARD` chain. With that, everything is now working perfectly.

Here's the resulting snippets from my cloud config.

```yaml
write-files:
  - path: /var/lib/iptables/rules-save
    permissions: 0644
    owner: root:root
    content: |
      *filter
      :INPUT DROP [0:0]
      :FORWARD DROP [0:0]
      :OUTPUT ACCEPT [0:0]
      -A INPUT -i lo -j ACCEPT
      -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
      -A INPUT -p tcp -m tcp --dport 22 -j ACCEPT
      -A INPUT --src 129.21.49.49 -j ACCEPT
      -A INPUT --src 129.21.49.48 -j ACCEPT
      -A INPUT --src 129.21.49.53 -j ACCEPT
      -A INPUT --src 129.21.49.54 -j ACCEPT
      -A INPUT --src 10.244.0.0/16 -j ACCEPT
      -A INPUT -p icmp -m icmp --icmp-type 0 -j ACCEPT
      -A INPUT -p icmp -m icmp --icmp-type 3 -j ACCEPT
      -A INPUT -p icmp -m icmp --icmp-type 11 -j ACCEPT
      -A FORWARD --src 129.21.49.49 -j ACCEPT
      -A FORWARD --src 129.21.49.48 -j ACCEPT
      -A FORWARD --src 129.21.49.53 -j ACCEPT
      -A FORWARD --src 129.21.49.54 -j ACCEPT
      -A FORWARD --src 10.244.0.0/16 -j ACCEPT
      COMMIT
  - path: /var/lib/ip6tables/rules-save
    permissions: 0644
    owner: root:root
    content: |
      *filter
      :INPUT DROP [0:0]
      :FORWARD DROP [0:0]
      :OUTPUT ACCEPT [0:0]
      -A INPUT -i lo -j ACCEPT
      -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
      -A INPUT -p tcp -m tcp --dport 22 -j ACCEPT
      -A INPUT -p icmpv6 -j ACCEPT
      COMMIT
coreos:
  units:
    - name: iptables-restore.service
      enable: true
      command: start
    - name: ip6tables-restore.service
      enable: true
      command: start
```
