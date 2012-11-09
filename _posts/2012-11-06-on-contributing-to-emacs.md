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
managed to ignore, which is remarkabley lucky since it is also quite
prevalent where I work.

One day though, I was morosely looking over a... rather organic mass
of matlab, and got so depressed I started procrastinating.  I started
watching the latest episode of [Emacs
Rocks](http://emacsrocks.com/e09.html), which was demonstrating a new
minor mode to successively expand a selection around greater semantic
units (for example, just on a page of text it would first select the
word under the cursor, then the sentence, then paragraph, and so on).

This was much more interesting!  I started hacking on it to make it
work with matlab.  Admirably, it also came with a [test
suite](http://ecukes.info/) and a request that all contributions
include tests.
