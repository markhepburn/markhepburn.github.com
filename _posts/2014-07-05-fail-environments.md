---
layout: post
title: "Fail Environments"
category: 
tags: [MS Tech]
---
{% include JB/setup %}

Friends of mine have recently starting using the term "fail
environment", as in "you created a...".  It hasn't even hit
[Urban Dictionary](http://www.urbandictionary.com/) yet so I think
they can safely claim it, but it's a brilliant expression.  Roughly,
it means

> *Creating circumstances, typically by omission of information,
> through which another person is more likely to fail.*

I'm perhaps overly dramatising since I was first introduced to it when
I said *"Meet me at Cafe X"* when there were in fact two of them; none
the less, I believe it deserves to be in common usage.

Unfortunately, I was witness to a much more serious example only
yesterday.  I've been doing some work with Microsoft's SQL Server,
working on a local copy of a database (importing data, writing
procedures, and so on).  It came time to reconcile some changes, and
to be cautious we decided to do it manually, using the
backup-and-restore feature to copy my database to the destination
server.

The Management Studio has a nice interface to backing up a database,
pretty much as you'd expect a GUI environment to provide: right-click,
select "backup" and a save location, and you have a single portable
file.

*Restoring* from this file is a little less intuitive, but the 2012
update made it
[much, much worse](http://connect.microsoft.com/SQLServer/feedback/details/779190/sql-server-2012-ssms-silently-overwrites-db-name-and-can-cause-accidental-overwrites-and-data-loss).

By default, when you restore a file it will restore the entire
database, to a database of the *same name* (granted, probably the main
use-case).  In our case though we were going to restore to a temporary
database on a different server, and manually copy selected changes
across to the original that way.

The process is basically to create a new database, right-click and
select "restore"... and now the fail environment emerges.  You have to
switch to a different tab to find your backup file, and when you
select it *the destination database silently changes, on the first
hidden tab, to the one with the same name as the original database,
NOT the temporary one you just selected*.  My colleague doing this is
very competent and experienced and actually knew this complication,
but while we were checking something else he forgot...[^1] and overwrote
the last three days of his work with mine.

I call that a fail environment.

[^1]: In part there's a few other complications to performing this
    procedure; you have to manually edit some file names as well for
    example.
