---
layout: post
title: "The next looming, slightly less serious, 2 digit year problem"
category: 
tags: []
---
{% include JB/setup %}

Roughly 15 years ago there was an
[intense crisis](http://en.wikipedia.org/wiki/Year_2000_problem) as
people realised that the results of only storing the final two digits
of a year were about to become quite ambiguous.[^1]

A variation of this ambiguity still exists; date-parsing functions
such as `strptime` have to deal with it all the time.  The
standards[^2] pick a pivot value---69---and everything on or after
that is interpreted as 19XX, everything before as 20XX.

For example:
{% highlight C %}
#include <stdio.h>
#include <time.h>

int main(void)
{
    struct tm result;
    char buf[255];

    if (strptime("68", "%y", &result)) {
        strftime(buf, sizeof(buf), "%Y", &result);
        puts(buf);              /* 2068 */
    }

    if (strptime("69", "%y", &result)) {
        strftime(buf, sizeof(buf), "%Y", &result);
        puts(buf);              /* 1969 */
    }

    return 0;
}
{% endhighlight %}

By my reckoning, this means we are heading for another crisis in about
45 years.[^3]  I suggest you start stocking your bomb shelter with
non-perishables now.

[^1]: It was so intense that there was almost a feeling of rage
    afterwards; "What do you mean, we spent all this money preventing
    it, and then *nothing actually happened*??"

[^2]: [X/Open](http://en.wikipedia.org/wiki/X/Open) Common Application
    Environment and [POSIX](http://en.wikipedia.org/wiki/POSIX)

[^3]: Unless of course you believe the earlier-looming
    [2038 problem](http://en.wikipedia.org/wiki/Year_2038_problem)
    spells doom first.
