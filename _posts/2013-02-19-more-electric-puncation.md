---
layout: post
title: "More Electric Puncation"
category: 
tags: [Emacs]
---
{% include JB/setup %}

Following on from
[my post yesterday]({% post_url 2013-02-18-electric-punctuation-in-emacs %}),
here's another quicky that I added recently.  This one is shamelessly
stolen from Eclipse, which has a handy option to correctly insert a
semi-colon or `{`-bracket from deep within a conditional or similar;
for example if you have,

{% highlight java %}
Context ctx = ContextFactory.getContext(Context.nullContext(|))
{% endhighlight %}

then hitting `; ` straight away takes you to `getContext(...);|`
(mercifully, it has been a while).

I was missing this in python, where it was taking me a whole extra
keystroke or two, *every time!*, to jump to the end of the line to
insert a colon.  In the
[python mode I was using](https://github.com/fgallina/python.el)
semicolon is already electric, so this time I had to advise it:

{% highlight scheme %}
(defadvice python-indent-electric-colon (around python-electric-colon-autoplace (arg)
                                                activate)
  (if (and (looking-at ")")
           (not arg))
    (progn
      ad-do-it
      (transpose-chars 1))
    ad-do-it))
{% endhighlight %}

I.e. assuming we're not inserting multiple colons, insert then
transpose to leave the colon and cursor outside... but in fact, just
writing this I realise I didn't really go far enough at the time!  So
I've just updated to this version:

{% highlight scheme %}
(defadvice python-indent-electric-colon (around python-electric-colon-autoplace (arg)
                                                activate)
  (if (and (looking-at ")")
           (not arg))
    (progn
      (move-end-of-line nil)
      ad-do-it
      (newline-and-indent))
    ad-do-it))
{% endhighlight %}

Insert correctly, indent, then ready to keep going on a new line: much
more efficient!
