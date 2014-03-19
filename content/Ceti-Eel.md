Title: Ceti Eel (An IRC bot in Go)
Date: 2014-3-3 02:30
Category: HFOSS
Tags: hfoss
Slug: ceti-eel
Author: Derek Gonyeo
Summary: I made a simple IRC bot in Go!

The Computer Science House runs an IRC server, which is very popular over the
summer when everyone scatters to their various homes and jobs. It serves as a
connection to the social collective we leave behind during the summers, to save
us from having to focus on our actual jobs. It is on this IRC server that a
couple of times last summer some of our more chaotic members decided to enable
an "anarchy mode", wherein everyone on the server was given admin privileges.
Partly to practice my Go, I decided to write a bot to capitalize on this. I
present: [ceti eel](https://github.com/dgonyeo/ceti-eel). (Named after the eels 
used by Khan in Star trek to effectively mind control some guys).

The bot sits in a channel and waits. When it receives admin privileges, or
receives op privileges and there are no admins in channel, it then immediately
de-ops and de-admins everyone else in the channel. If someone is made an op or
admin (probably by Chanserv), the bot will immediately reverse it. The point
being to take control of the channel and hold it. I can then rather have the bot
assign power out to who I choose, or make various demands of the channel.

The demands portion of the bot hasn't been written yet, but I'm imagining
something like forcing everything someone says to include some profane word, or
to require a random member of the channel to profess their love to another
member. The penalty for failing to meet the demands within a certain time limit
can involve a loss of voice, or even kickbanning them.

I used the library [go-ircevent](https://github.com/thoj/go-ircevent) to
facilitate the IRC connection side of things, and it was actually pretty easy to
do. I just set up the connection to the server:

    :::go
    con = irc.IRC(myNick, myNick)
    err := con.Connect(server)

then register callbacks for the events I care about:

    :::go
    con.AddCallback("001", connectionMade)
    con.AddCallback("PRIVMSG", newPrivmsg)
    con.AddCallback("MODE", modeChanged)
    con.AddCallback("353", gotNames)

and start the event loop for the server:

    :::go
    con.Loop()

From there I join the channel upon successfull connection, listen for things 
being said in the channel, listen for modes being changed, and listen for
answers to my requests for the list of everyone in channel. Going forward, it
should be easy to add functions I can call to generate the commands, and then
have functions to check if conditions have been met that I can call in a
seperate thread that'll sleep for a bit. We'll see how much chaos this can cause
this summer.
