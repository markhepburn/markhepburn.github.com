---
layout: post
title: "On contributing to Emacs"
category: 
tags: [Emacs]
---
{% include JB/setup %}

# TL;DR

Writing patch: a couple of hours.  Getting permission from employers
to submit patch: a couple of months.  Contributing to Emacs:
priceless.

# Introduction

Matlab is not my favourite language.  In fact, it's one I've largely
managed to ignore, which is remarkably lucky since it is also quite
prevalent where I work.

One day though, I was morosely looking over a... rather organic mass
of Matlab, and got so depressed I started procrastinating.  I started
watching the latest episode of [Emacs
Rocks](http://emacsrocks.com/e09.html), which was demonstrating a new
minor mode to successively expand a selection around greater semantic
units (for example, just on a page of text it would first select the
word under the cursor, then the sentence, then paragraph, and so on).

This was much more interesting!  I started hacking on it to make it
work with Matlab.  Admirably, it also came with a [test
suite](http://ecukes.info/) and a request that all contributions
include tests.  These I finished on the weekend, fixing up a couple of
corner cases they found along the way.

Flushed with a sense of achievement, I pushed to github and submitted
a pull request.

# Trials and Tribulations

All stories are fundamentally about conflict or struggle in some
sense, and this is where mine started.  The maintainer thanked me, and
more-over informed me that his package had already been accepted into
Emacs itself, and therefore so would my small contribution!  I have
had a long love affair with Emacs and virtually live in it, so I was
ecstatic.

Well, ecstatic, and also rather nervous.  The Free Software Foundation
requires that all contributors must [assign
copyright](http://www.gnu.org/licenses/why-assign.html) over to them.
Under local law, I do not in fact own the copyright, my employer does.
Now, I work in a research organisation, and as it is their life-blood
they are understandably twitchy about signing over IP.  Clearly my
patch was not going to leak valuable secrets, but it did put me in the
position of needing someone in a large bureaucracy to accept
responsibility for something that goes against the organisation's
grain, with absolutely no upside for them.

Merely getting to the stage of discovering what level of people might
have the authority took a decent amount of time, and after the first
apologetic rejection I did lose hope and let the trail go cold for a
while.  Eventually though I found someone who agreed, with experience
releasing projects as open source and an "ask forgiveness not
permission" attitude, to whom I will remain inordinately grateful.
Actually getting the physical signature then took a week or so longer,
but I was finally done.

# Aftermath

All was **not** finally done, as it turned out.  I gleefully informed
the (patient, long-suffering) maintainer that all was finally good to
go.  He in turn pulled the patch in, and informed me that my tests
were all failing!  As it turned out, I had written my code against
Emacs version 23 and he was using version 24, and the Matlab mode had
received a major face-lift in between with many breaking changes.  This
was mainly due to me simply using what shipped with Ubuntu, but I did
derive some hollow amusement that it felt like the process had taken
so long my changes were all out of date!  At any rate, I tweaked the
patch to work against both version, and *now* I'm finally in a
package, that at some point in the future will be in Emacs.  In a very
small way.

# Colophon: Emacs Rhapsody

Browse any geek news site for long enough and eventually someone will
mention Emacs, and someone else will reply "oh yeah, it's a great
operating system, but needs a good text editor, har har".  Very droll.
The joke, in my opinion, is on them though because it *is* an
operating system!

Some time, read up on the history of the Lisp Machines and [watch a
movie](http://www.youtube.com/watch?v=5Xl-EgAe_a0) or two of one in
action.  For various reasons, not all technical, this vision of
computing did not take off and we are poorer for it.  Every aspect of
the system, down to the metal, was not only written in Lisp but could
be examined **and changed** by the user.  Emacs makes sense in light
of this: it's essentially a poor-man's Lisp Machine.

Emacs Lisp is not the nicest Lisp, but hacking on Emacs is fun both
because what you write immediately improves how you work, and because
you have that instant-turn-around where (nearly) every bit of
functionality can be examined and updated, all without restarting.

Finally, if you've never really looked into Emacs, or only used it
under sufferance as part of a Unix course or something, have a look at
the [Emacs Rocks](http://emacsrocks.com/) movies some time.  The guy
is single-handedly doing an amazing publicity job, showing just what
can be accomplished and surprising even veterans.  And if I may say
so, he also makes a very gracious and incredibly patient project
maintainer :)
