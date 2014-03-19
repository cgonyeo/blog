Title: Using Libjansson
Date: 2014-2-5 18:00
Category: HFOSS
Tags: hfoss,odd
Slug: using-libjansson
Author: Derek Gonyeo
Summary: Quick summary of my experiences using libjansson

tl;dr: I go through a basic example of using libjansson to parse JSON in C. This
handles reading in and breaking down JSON, not making up some JSON to ship off
to somewhere else

I was working on Project Odd, and got to the feature that involves controlling
the pi over the network. The basic idea is some client will connect to a socket,
send some data over to the pi, and thereby be able to control it. I debated
using libwebsockets to allow browsers to be able to easily do this, but decided
against it since I don't want to design this for a specific client.

The data that will be sent will be comprised of some action (add an animation,
remove an animation, modify an animation), and then the corresponding data for
that animation (parameters of a new animation, the index of the animation to be
removed, the index of an animation and the name and value of a parameter to be
changed). For this I chose to use JSON, as I have some experience working with
it and JSON parsing libraries can be found on most, if not all platforms.

From playing around with the source to
[Bingehack4](https://github.com/ComputerScienceHouse/bingehack4) I had heard of
[libjansson](http://www.digip.org/jansson/), a library for C that handles
parsing JSON. Some googling had produced some simple 
[docs and a tutorial](https://jansson.readthedocs.org/en/latest/index.html). 

If you want to skip to the source of what I wrote, it should be available
[here](https://github.com/dgonyeo/odd/blob/master/computer_program/odd_network.c). 
The basics of how to use it are as follows.

Make a new JSON_t * variable, this'll point to the root object we're going to
parse. Also make a JSON_error_t, which will be able to tell us where we had
problems reading the JSON, if there are any.

    :::c
    JSON_t *root;
    JSON_error_t JSONError;

Now load in the JSON, passing in the address of the beginning of our buffer (in
this case a char *), some flags (I just passed in 0), and the location of where
to store errors

    :::c
    root = JSON_loads(buffer), 0, &JSONError);

Check for errors, which will occur if the string did not contain valid JSON

    :::c
    if(!root)
    {
        fprintf(stderr, "error: on line %d: %s\n", JSONError.line, JSONError.text);
        //break or exit or something, we can't use the JSON
    }

Next I want to check that what we have is an object. Depending on what you're
using this for, it could be something else, like an array.

    :::c
    if(!JSON_is_object(root)) {
        //Handle the error
    }

At this point we've loaded in our JSON, confirmed that it was valid JSON, and
confirmed that the JSON we loaded is an object. I wanted to store an action in
this, so let's get the action out of there.

    :::c
    JSON_t *actionJson = JSON_object_get(root, "action");

And I intend for this to be a string (for readability). So let's confirm that we
have a string.

    :::c
    if(!JSON_is_string(actionJson)) {
        //Handle the error
    }

Ok, we have the action, and it's a string. Let's get a pointer to the actual
value of it.

    :::c
    const char *action = JSON_string_value(actionJson);

I'm now going to have some if statements to check this action string for some 
expected values. If it matches "add", I'm going to check for an object called
"animation".

    :::c
    JSON_t *animationJson = JSON_object_get(root, "animation");

And then pull some values out of it. Note that I'm passing animationJson in to
JSON_object_get(), instead of root.
    
    :::c
    //Let's get the various parameters
    JSON_t *nameJson = JSON_object_get(animationJson, "name"); //String
    JSON_t *modifierJson = JSON_object_get(animationJson, "modifier"); //String
    JSON_t *paramsJson = JSON_object_get(animationJson, "params"); //Array
    JSON_t *colorJsonArray = JSON_object_get(animationJson, "colors"); //Array

    //Error checking
    if(!JSON_is_string(nameJson)) {
        //Handle the error
    }
    if(!JSON_is_string(modifierJson)) {
        //Handle the error
    }
    if(!JSON_is_array(paramsJson)) {
        //Handle the error
    }
    if(!JSON_is_array(colorJsonArray)) {
        //Handle the error
    }

    const char *name = JSON_string_value(nameJson);
    const char *modifier = JSON_string_value(modifierJson);

So we grabbed a couple chars related to the animations, which we've seen how to
handle, but we also grabbed some arrays. Let's look at how to deal with those.

We can grab the size of the array like this.

    :::c
    int paramCount = JSON_array_size(paramsJson);

Which means iterating through it with a for loop is pretty simple. So let's do
that to grab some values from it.

    :::c
    for(int i = 0; i < JSON_array_size(paramsJson); i++)
    {
        JSON_t *tempJson = JSON_array_get(paramsJson, i);
        if(!JSON_is_number(tempJson)) {
            //Handle the error
        }
        params[i] = JSON_number_value(tempJson);
    }

And there you have it, parsing JSON in C. Pulling values out of both objects and
arrays. If you have any questions you should check out the
[documentation](https://jansson.readthedocs.org/en/latest/apiref.html), as it
was pretty much my only resource for getting off the ground with libjansson.
