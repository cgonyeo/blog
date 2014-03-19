Title: Hudl and Go
Date: 2014-3-1 16:00
Category: HFOSS
Tags: hfoss
Slug: hudl-and-go
Author: Derek Gonyeo
Summary: Ryan Brown gave a talk on his experiences switching to Go for Hudl

Last Wednesday Ryan Brown gave a talk at RIT on his experiences migrating Hudl's
infrastructure away from Node.js to Go. A relatively unknown language, Go
simplifies the process of having concurrent code, with easy contructs to run
functions in new threads and with built in thread safe data structures. This has
allowed him to make Hudl's infrastructure more reliable, and have a shorter 
development time for new changes. 

Go is an interesting language; it's syntax is very losely based on C, but has
many changes to it. Semicolons are nonexistent, when declaring variables you
list the name and then the type, and the placement of curly braces are much more
specifically defined. Definitely something I'll be playing around in for a
while.
