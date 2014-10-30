---
title: Hack Upstate
tags: Misc
---

Last weekend was [Hack Upstate](http://hackupstate.com/), which I participated
in with [Matt Soucy](http://msoucy.me/) and [Rob
Glossop](https://github.com/robgssp). We worked on a project we've named
[Bootleg](https://github.com/robgssp/movienet), which works (well, it will once
it's done) similarly to Plex. Designed to facilitate the sharing of media
content between a group of friends, you would run a program on your machine with
your media. You would point it at directories, and it would thus be aware of 
all the media you want to be shareable. This program would talk to a central 
controller, that would display to users what was available. Once a user picked 
something, the server would stream the content to an html5 player for the user 
to watch.

My part was to get streaming to work. My goal was to be able to take any
arbitrary video file, transcode it on the spot (probably with ffmpeg), and then
stream it to an html5 client. 

Html5 has a video tag you can use, and by pointing it at the url for some video
file it enables playback of the video file. If the file is served up by
something that can handle range requests (get requests for a specific part of
the file) you can even seek through the file. I set about writing an http server
in Go to do exactly this, and serve up a video file to am html5 player.

After looking at the request and response headers Chrome sends/receives from
apache while doing this, I was able to implement the same thing in my server.
The browser makes a GET request for the file with the following header:

> Range: 0-

This is asking for bytes 0 through the end of the requested file. I reply with
the requested information, and also the following headers:

> Accept-Ranges: bytes
> Content-Length: 73150365
> Content-Range: bytes 0-73150364/73150365

This means that I'm referring to locations in bytes, I'm going to return the
first 73150365 bytes here, and the range of requested bytes is 0 through
73150364 out of a total of 73150365 bytes.

Once I was serving up these headers correctly, and sending over the requested
information, my server was able to stream video files to any html5 video player
that was pointed at it. The next step would be to transcode these as I go,
instead of just serving up a static file. The point being that the bitrate can
be changed to accommodate slower connections, and the user will be able to watch
a video file regardless of how it's encoded.

I began an attempt to do this by having ffmpeg transcode a video into a new
file, and started watching the file with the html5 player while ffmpeg was
transcoding it. This worked well and the video was watchable, but I encountered
a problem. In order to obtain the length of the video file, Chrome would request
the end of the file. In this case, the end didn't include the index of the
video, and Chrome identified the video as streaming. It would disable any
ability to seek through the video, and just play it as it came. This was not
what we wanted for video playback, so I needed to override the controls of the
html5 player, to allow seeking and to tell the server when and where we were
seeking to, so it could jump to transcoding a different part of the video.

After working my way through various tutorials on how to implement custom
controls on the html5 video tag, I decided to use
[video.js](http://www.videojs.com/), an open source theme, of sorts, for the
html5 player. It implemented it's own custom controls, and the entire thing was
very configurable. After looking through the source, I found how to set the
duration of the video manually, instead of getting it from the server. I then
worked to talk to the server via a websocket so the client can request
information like the duration, and notify the server of the timestamp to where
we're seeking to (instead of the byte). This way seeking works, and I can
respond to a seek request by killing ffmpeg, and starting it up at a different
location in the file. As soon as I got the websocket to connect though, I
decided to go to sleep so I could be rested enough in five hours to drive back
to Rochester for CSH's Spring Evals. All in all was a fun trip.
