---
layout: post
title: "Org mode as exocortex: Introduction to mobile org"
category: 
tags: [Emacs]
---
{% include JB/setup %}

# Introduction

I recently read
[Pragmatic Thinking and Learning: Refactor your Wetware](http://pragprog.com/book/ahptl/pragmatic-thinking-and-learning),
after it had sat on my virtual bookshelf for a while.  I took a lot of
notes of things to try, and generally got a lot out of it
(interestingly,
[Amazon commenters](http://www.amazon.com/Pragmatic-Thinking-Learning-Refactor-Programmers/dp/1934356050)
have turned on it a bit).

This post isn't about the book itself though, but one idea in it:
out-sourcing your memory and organisation to something like a wiki or
notebook that you can use as an "exocortex" (their terminology).

As an Emacs user and finding that org-mode is increasingly taking over
my day-to-day organisation anyway, it seemed the obvious choice.  One
requirement of your exocortex was that it be always accessible, and
fortunately there is a mobile client.  Unfortunately it might not work
the way you immediately expect it to, but this can be rectified.

# Org-mode

If you've used Emacs for any length of time, there's a fair chance
you've encountered [org-mode](http://orgmode.org/).  Org-mode is a
fantastic piece of software, relatively new in the Emacs scheme of
things, still growing at quite a clip and already with an amazing
breadth of capability.

This can be a problem though: it is *massive*.  Try any tutorial
([and there are a few](http://orgmode.org/worg/org-tutorials/)) and
there's a fair risk you'll get overwhelmed: hierarchical notes --- ok;
notes can have tags --- fine; what are drawers and why?; tables seem
cool; wait, you mean you can do spreadsheet calculations in them too?;
notes can have dates associated too; you can clock in and out; column
mode; time-tracking;... on it goes!  Many of them also introduce it in
the context of
[GTD](http://en.wikipedia.org/wiki/Getting_Things_Done), which can be
a further overload if you're not already familiar with it.

So if you have previously been overwhelmed, or you haven't tried it
yet, I would offer two pieces of advice:

## 1. Just start using it

Skim the most basic tutorial you find, then just start using it for
notes; for heavens sake don't try and master everything in one
sitting.  It was originally designed for scientific note taking, and
it does this brilliantly.  Get used to the hierarchy and commands for
manipulating it, then maybe start adding functionality as you need it:
perhaps you go back over notes and start classifying sections by
adding tags, for example.  Its table editing facilities are also quite
intuitive, but just get used to those first if you find yourself
needing a tabular display; don't worry about formulae.

## 2. Trial and error

One reason the interface is so intuitive is you don't need to remember
a tonne of commands in order to be productive straight away.  Org
achieves this by over-loading most key combinations, with the result
that you can typically achieve what you want by trying one of them,
undoing if that didn't work, and trying the next most obvious
candidate.

Basically, try: `M-<return>`, `M-<arrow key>`, or `<shift>-<arrow
key>`, or even `M-<shift>-<arrow key>`, and if it doesn't do what you
want: `C-/` to undo!  `C-c C-c` is always worth trying too.  Org is
quite context-sensitive, so if you're in a heading you will typically
operate on a heading, or if you're on a date you can manipulate the
date, and so on.

Depending on the exact context, those commands are likely to shuffle
headings around or insert new ones, promote or demote them, add tags,
changes dates, or change the priority.  Again, if something happened
that you didn't expect, don't worry: undo, and move on.

# Mobile-org

Emacs isn't too mobile without some effort, but fortunately there
are org-mode clients for the [iphone](http://mobileorg.ncogni.to/) and
for [android](https://github.com/matburt/mobileorg-android).  I have
no experience with the iphone app, but apparently they operate
similarly.

However these do not offer, out of the box, the seamless experience
you might expect: changes made on the phone do not silently propagate
back to your org files.  This is partly because the apps have been
designed to include the agenda functionality (I have alluded to dates
before; the basic idea is you can create your project notes in the
hierarchy that suits, add deadlines and so on, then org-mode will
generate an agenda from this), and partly because you can pick from a
number of different server backends.

There is confusion here too, because a common back-end is
[Dropbox](https://www.dropbox.com/) --- but this is not the same as
storing your org-files themselves on dropbox so they can be accessed
from several computers!

So first of all, there are a few things to understand:

* You (initially; we will fix this) need to explicitly push any
  changes you make to the server, and pull any changes from your phone
  back again.
* This process also involves generating addtional files for the mobile
  client.

A common request is to have a directory of org files on Dropbox so
they are accessible from multiple computers (say, home and work), and
also to use dropbox as the server for the mobile client.  This is
possible, but it does mean keeping two copies of the files in dropbox
(for Emacs and for mobile-org).  I use a sub-directory of my org
directory to keep the mobile files:

    ;; My org files:
    (setq org-directory (expand-file-name (file-name-as-directory "~/Dropbox/org")))
    ;; Files for mobile-org:
    (setq org-mobile-directory (expand-file-name "MobileOrg" org-directory))

Next, you will need to tell org-mode what files it should treat as
mobile.  By default this consists of your agenda files (again, not
covered here), but you can set it to anything.  I do use the agenda
list, plus one file of general notes:

    (setq org-mobile-files (cons (expand-file-name "notes.org" org-directory)
                                  org-agenda-files))

Having changed the location of the org directory, you will find you
also need to change one last variable (don't worry about what it does
if you don't mind, it's mostly transparent):

    (setq org-mobile-inbox-for-pull (expand-file-name "from-mobile.org" org-directory))

You are now mostly there; go ahead and set up mobile-org
[for dropbox](https://github.com/matburt/mobileorg-android/wiki/Setup-Dropbox)
and read the rest of the
[documentation](https://github.com/matburt/mobileorg-android/wiki/Documentation).


## Automation

As mentioned, if you are used to something like
[Catch](http://catch.com/) where changes on the phone get
transparently synced with a server, you might find the mobile-org
operation confusing.  Fortunately, there is some elisp code in
[the FAQ](https://github.com/matburt/mobileorg-android/wiki/FAQ) for
mobile-org-android to regularly push and pull (yes, in our case this
does essentially mean copying from one dropbox folder into a
subdirectory, but this is not always the case!).  In case it ever
moves, or just if you're lazy, here are the snippets you need to include;

<style>.gist pre { font-size: 1.0em; }</style>

<script src="https://gist.github.com/markhepburn/4749358.js"> </script>

<script src="https://gist.github.com/markhepburn/4749363.js"> </script>

Combine this with a frequent update period in the mobile client, and
you will have a pretty smooth experience!
