---
title: Haskell CRDT
tags: Haskell
---

A month or two ago I read [Distributed Systems: for Fun and
Profit](http://book.mixu.net/distsys/single-page.html) by Mikito Takada, which
covers many concepts about distributed systems like the CAP Theorem and strong
versus weak consistency. Towards its end, it discusses convergent replicated
data types, or CRDTs. I found the concept pretty interesting, and went on to
read parts of
[this](http://hal.upmc.fr/file/index/docid/555588/filename/techreport.pdf) paper
about them. The paper details multiple implementations of CRDTs, each with
different behaviors. I then attended [Big Red
Hacks](http://www.bigredhacks.com/) last month, and began to create the
Observed-Removed Set implementation in Haskell.

The basic idea behind a CRDT is that it's a distributed system with eventual
consistency. Each node holds the entire data set, and any node can atomically
add or remove elements from the set without getting approval from any other
nodes. The changes to the data set will then be (eventually) transmitted to the
other nodes. If there are differences in the data sets (e.g. the other node also
added something to the set before the given node could inform it of its
additions), the operations nodes perform on their data set are designed to
follow some specific properties that make it easy to reconcile these
differences.

These properties are:

- Associativity (a+(b+c)=(a+b)+c): the grouping in which operations occur
  doesn't matter
- Commutativity (a+b=b+a): the order in which operations occur doesn't matter
- Idempotency (a+a=a): An operation applied multiple times is equivalent to
  applying the operation once

What this means is if a given node adds or removes information from its data
set, and is then informed that another node also added or removed information,
to make both nodes have the same data set one must only apply each node's
operations on the other node. The order the operations happen in doesn't matter,
and if the operation was already applied then applying it again will do nothing.

I was building this with the intent of using it to keep the set of user
information for an electronic door access system, called gatekeeper, local to
each node (and in this case each node is a door). To hold on to a user's
information, I made the `Tag` type.

```haskell
data Tag = Tag { username :: String
               , tagId    :: String
               , tagUid   :: String
               , tvclk    :: HostClock
               } deriving (Show,Eq)
```

The `Tag` type has a username and a tag, along with a couple of other fields
I'll go into later. The set of data we aim to store is a list of `Tag`s. There's
an issue in just having a single list however, that the observed-removed
variation I'm implementing aims to address. With a single list items cannot be
safely deleted, since the operations can happen out of order (see the
commutativity property) a node could see a delete operation before an add
operation, and deleting something that doesn't exist yet doesn't make much
sense.

The solution for this is to have two sets, an added (or observed) set and a
removed set. To delete something from the set, you add it to the removed set.
The items currently in the set are whatever is present in the added set minus
whatever elements are in the removed set. With this, I present the next type,
our `Set`.

```haskell
data Set = Set [Tag] [Tag] deriving (Show,Eq)
```

Here we have two lists of `Tag`s, the first one being the added set and the
second being the removed set. There's another flaw in this however, in that an
element can only be added and removed once. Once an element is present in both
the added and removed set, it cannot be added back to the added set a second
time (see the idempotency property). To work around this, the `tagUid` field
exists on the `Tag` type. Each `Tag`, when initially added, gets a random unique
identifier. To inform a given node that a `Tag` was added at some point, the
`Tag` is transmitted with the uid that was generated when the `Tag` was created.
To explicitly duplicate the `Tag`, the `Tag` is transmitted with a new uid.

There is also a second data set each node should hold: the set of all the nodes
present. To that end, I introduce the `Host` type.

```haskell
data Host = Host { nhostname :: String 
                 , nhostUid  :: String
                 , hvclk     :: HostClock
                 } deriving (Show,Eq)
```

Each `Host` has a hostname, and a uid. Same stuff as the `Tag`. The `Host` type
is then used to make the `Cluster` type.

```haskell
data Cluster = Cluster [Host] [Host] deriving (Show,Eq)
```

The nodes should also remember what host they are, and what port they're running
on, and thus the `NetState` type was born.

```haskell
data NetState = NetState { myHost   :: Host
                         , port     :: String
                         } deriving (Show,Eq)
```

And tying it all together, we can represent the state of a node with the `State`
type.

```haskell
data State = State Set Cluster [HostClock] NetState deriving (Show,Eq)
```

At this point you're probably curious what a `HostClock` is. I needed a way to
detect when nodes' data sets diverged, and [Distributed Systems: for Fun and
Profit](http://book.mixu.net/distsys/single-page.html) talked about vector
clocks, which were supposed to provide exactly that. Thus we have the
`HostClock` type.

```haskell
data HostClock = HostClock { hUid     :: String
                           , vclock   :: Int
                           } deriving (Show,Eq)
```

The `State` type contains a list of `HostClock`s, one for every node in the
cluster. Each `HostClock` has a uid for a host, and a counter. Each node's
counter is incremented whenever it adds or removes something from a set, and the
list of `HostClock`s is always transmitted along with any other message. I
notably just sat down and made this without reviewing how vector clocks work,
and this is different behavior than [Wikipedia's article on vector
clocks](http://en.wikipedia.org/wiki/Vector_clock) describes, so I suppose it
wouldn't be correct to call these vector clocks. Either way they work great at
detecting whenever a node is missing information, because its counter will be
lower than whatever other node it's communicating with.

Each `Tag` and `Host` also has a single `HostClock` field, which serves the
purpose of recording what operation added or removed that `Tag` or `Host`.
This allows a node to send just what's missing when it discovers that another
node lacks some operations.

And that's all the types that my CRDT relies on to work. There are various
utility functions to do things like get all the current tags:

```haskell
currentTags :: Set -> [Tag]
currentTags (Set a r) = filter (\(Tag _ _ u1 _) 
                                 -> foldl (\acc (Tag _ _ u2 _) 
                                            -> acc && u1 /= u2
                                          ) True r
                               ) a 
```

And add or remove one or more `Tag`s from the `State`:

```haskell
addTag :: State -> Tag -> State
addTag (State (Set a r) c v n) e = if e `elem` a
                                     then State (Set a r) c v n
                                     else State (Set (e:a) r) c v n

addManyTags :: [Tag] -> State -> State
addManyTags tags state = foldl (\s t -> addTag s t) state tags
```

The `State` is then wrapped in a
[MVar](http://chimera.labs.oreilly.com/books/1230000000929), and can be accessed
and modified by threads in a safe fashion.

Each node checks LDAP for any changes periodically, and generates a list of
any tags that have been added or removed. The changes are applied locally, and
then sent to all the other nodes. Each node also transmits a "heartbeat",
containing just the state of its `HostClock`s, to all other nodes periodically.
This allows nodes to check if they've missed anything.

All the code's available on [my github](https://github.com/dgonyeo/gatekeeper),
and the CRDT parts are fully functional. I now need to add the ability to
unlock doors and read RFID tags, along with some other tweaks like using SSL and
disabling doors when they can't get updates for too long, and then this will be
a finished project.
