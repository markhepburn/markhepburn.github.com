---
layout: post
title: "Quick git tip"
category: 
tags: []
---
{% include JB/setup %}

I recently put the following couple of alias in my `~/.gitconfig`
file:

    [alias]
        dlp = diff ORIG_HEAD..FETCH_HEAD
        llp = log ORIG_HEAD..FETCH_HEAD

These stand for "diff last pull" and "log last pull" respectively.
When dealing with third-party submodules in particular, such as my
[my emacs config](https://github.com/markhepburn/dotemacs) where most
extra code is contained in submodules, I'll often just run `git pull`
to update them.  After that, either out of curiosity or occasionally
afer the fact if I'm tracking down some changed behaviour, I want to
know exactly what changed.

So this is what those two aliases accomplish.  When you fetch, git
creates an extra couple of refs referring to the HEAD before and after
the fetch.  You can then just use these to examine the new commits via
diff and log.

I'm sure they've been proposed numerous times in the past, and may
even be built-in for all I know, but they've been quite useful for me
already so you're welcome to them too!
