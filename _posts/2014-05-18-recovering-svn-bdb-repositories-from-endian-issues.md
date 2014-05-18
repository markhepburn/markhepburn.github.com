---
layout: post
title: "Recovering svn bdb repositories from endian issues"
category: 
tags: [Hacking]
---
{% include JB/setup %}

The other day I came across the old
[subversion](http://subversion.apache.org/) repository for my thesis[^2],
and thought it would be a good idea to convert it to
[git](http://git-scm.com/) and back it up
[somewhere](https://github.com/). Immediate problem: I couldn't even
read it!  This post is a short description of what the problem was,
and how it was resolved.

# The Problem

The repository uses the old (deprecated) BerkelyDB file-system type.
Let's try and browse it:

~~~
$ svn ls file:///home/mark/_SVNREPOS/thesis
svn: E180001: Unable to connect to a repository at URL 'file:///home/mark/_SVNREPOS/thesis'
svn: E180001: Unable to open an ra_local session to URL
svn: E180001: Unable to open repository 'file:///home/mark/_SVNREPOS/thesis'
svn: E160029: Berkeley DB error for filesystem '/home/mark/_SVNREPOS/thesis/db' while opening environment:

svn: E160029: BDB0087 DB_RUNRECOVERY: Fatal error, run database recovery
svn: E160029: bdb: BDB2530 Ignoring log file: /home/mark/_SVNREPOS/thesis/db/log.0000000018: magic number 88090400, not 40988
svn: E160029: bdb: BDB2527 Invalid log file: log.0000000018: Invalid argument
svn: E160029: bdb: BDB0061 PANIC: Invalid argument
svn: E160029: bdb: BDB1546 unable to join the environment
~~~

Oops.  The key is in the fragment "`magic number 88090400, not
40988`", which looks suspiciously like an
[endianness](https://en.wikipedia.org/wiki/Endianness) issue
(88-09-04-00 / 00-04-09-88).  It was created on a PPC Mac and I'm now
trying to access it from an Intel box, so that seems like a reasonable
explanation.

At this point though I ran into something of a black-hole.  It was
hard to even find confirmation that it might be possible; "bdb is
platform-independent" is the prevailing opinion.  Some
[evidence](http://svn.haxx.se/users/archive-2007-02/0456.shtml) did
exist but was otherwise thin on the ground, which is one reason I'm
writing this.  One helpful
[post](https://community.oracle.com/message/3727053) mentioned that
while the main database is platform-independent the *log files* are
not, and hence my problem.

# Solution

I no longer had access to a PPC machine, but the solution came when a
friend pointed out that [QEMU](http://wiki.qemu.org/Main_Page) can
virtualise big-endian architectures, even on a little-endian host.
After that, it was just a matter of implementation details.

Create a PPC guest
: With [this post](http://omega.cs.iit.edu/~bharatkris/blog/?p=211) as
  a guide, grab a
  [pre-configured Debian image](http://people.debian.org/~aurel32/qemu/powerpc/),
  and apply the
  [openbios](https://lists.ubuntu.com/archives/ubuntu-users/2011-November/254572.html)
  fix as well.  Install subversion on it (`apt-get install subversion`).

Copy the repository onto the guest
: QEMU doesn't provide out-of-the-box shared folders (well, apparently
  it has a built-in SMB server, but I didn't investigate), but it does
  make the host addressable on 10.0.2.2 which is all we need.  Tar up
  the repository and run `python -m http.server`[^1] from the same
  directory on the host, then from the guest download it with `wget
  http://10.0.2.2:8000/repo.tar`.

Migrate the repository
: The reason we're here; we'll convert it to the
  [FSFS format](http://web.mit.edu/Ghudson/info/fsfs).  This is
  actually slightly fiddly; essentially you create a new repository in
  the FSFS format, dump from your old repository and import into the
  new one.  Assuming it has been extracted to `oldrepo`:

  1. `svnadmin create ./fsfsrepo --fs-type fsfs`
  1. `svnadmin dump ./oldrepo -q | svnadmin load ./fsfsrepo`

Copy the recovered repository back to the host
: Once again there are probably smoother ways, but I used a
  quick-and-dirty approach (good old `netcat`!):

  1. (from the host) `nc -l -p 8000 > fsfsrepo.tar`
  1. (on the guest) `tar cvf - fsfsrepo | nc -p 8000 10.0.2.2`

Import your recovered repository into git
: This step is entirely optional of course, but I'm mentioning it for
  the sake of completeness since that was my goal in this exercise.  I
  used [svn2git](https://github.com/nirvdrum/svn2git), which is a
  wrapper around `git-svn`.

# Conclusion

I hope this helps someone else in the future, and at the very least
adds Google-weight to the problem.  Thanks to the
[fine folk on Google+](https://plus.google.com/+MarkHepburn/posts/PxpMzPmVqXo)
for their suggestions, and Paul for the QEMU tip!

[^1]: Or `python -m SimpleHTTPServer` if you're still using python 2.

[^2]: Way to make me feel old.  Not only was it in a long-deprecated
    format, but this was actually the *rewrite* of my thesis.  The
    first version was written under
    [CVS](http://en.wikipedia.org/wiki/Concurrent_Versions_System)...
    (Remember when people were excited about the upcoming release of
    subversion, and new announcements about it made the front page of
    Slashdot?  Hell, remember Slashdot?  I think I'm going to go drink
    now, and feel like a fossil.)
