---
layout: post
title: "Customising markdown-mode for Jekyll"
category: 
tags: [Emacs, Hacking]
---
{% include JB/setup %}

This blog is written using [Jekyll](http://jekyllrb.com/),[^1] a
static site generator using
[markdown](http://daringfireball.net/projects/markdown/) and
[Liquid](http://liquidmarkup.org/) templates.  It's very easy to use,
can be hosted cheaply anywhere since everything is static, and Github
will
[even compile it](https://help.github.com/articles/using-jekyll-with-pages)
for you in addition to hosting.

Naturally, there is a
[markdown-mode](http://jblevins.org/projects/markdown-mode/) for
Emacs, and it's quite good.

I did run into one issue though, due to interactions with Liquid
syntax.  By way of example, this is the syntax for a link in markdown:

    [anchor text](http://www.google.com)

(Which renders as "[anchor text](http://www.google.com)").  Jekyll also
provides a useful Liquid tag to link to previous posts, for example:

    [older post]({% raw %}{% post_url 2014-05-20-parsing-ssh-agent-variables-in-emacs %}{% endraw %})

This renders as "[older post]({% post_url 2014-05-20-parsing-ssh-agent-variables-in-emacs %})".

The issue occurs in conjunction with
[paragraph filling](http://www.emacswiki.org/emacs/FillParagraph).
Both markdown and liquid require the examples above to be unbroken on
a single line.  Markdown-mode does the right thing and ensures the
anchor text won't be broken, but also correctly assumes that the URL
won't have spaces and thus will be safe.  In conjunction with liquid
though, it's possible to have a situation like this, which will break
Jekyll:

    [older post]({% raw %}{% post_url
    2014-05-20-parsing-ssh-agent-variables-in-emacs %}{% endraw %})

Creating a fix requires some understanding of how filling commands
work.[^3] Roughly, when a command like `fill-paragraph` is invoked
Emacs starts at the beginning of a line, jumps forward to the
`fill-column`, and then looks for white-space at which it can insert a
newline.  The wrinkle is it first checks if it is *safe* to break
there, using a customisable variable called `fill-nobreak-predicate`.
To get an example, we can look at how markdown-mode ensures it won't
break inside the square brackets of a link definition:

{% highlight scheme %}
(defun markdown-nobreak-p ()
  "Return nil if it is acceptable to break the current line at the point."
  ;; inside in square brackets (e.g., link anchor text)
  (looking-back "\\[[^]]*"))
{% endhighlight %}

As you see, it just looks back to see if there's an opening bracket
(that isn't followed by a closing one).  We can use the same strategy
to check if we're in a liquid tag:

{% highlight scheme %}
(defun mh/liquid-nobreak-p ()
  (looking-back "({{ "{%" }}[^%]*"))
{% endhighlight %}

Notice that we're *not* worried about the anchor-text case here!
That's because `fill-nobreak-predicate` is a *hook variable*; that is,
a list of functions, and in this case invoked until one of them
returns non-nil, indicating that we shouldn't break at this point.[^2]
In other words, we want to add to this list, not replace or advise
anything.

So now to incorporate our addition we just use the mode hook, and
remember to also use `add-hook` with our new predicate:

{% highlight scheme %}
(add-hook 'markdown-mode-hook
          (lambda ()
            (add-hook 'fill-nobreak-predicate 'mh/liquid-nobreak-p)))
{% endhighlight %}

And now we're done, and can get back to blogging.


[^1]: Specifically, [Jekyll Bootstrap](http://jekyllbootstrap.com/),
    although I'd probably just use plain Jekyll if I was starting
    again.  It's a useful set of defaults though.

[^2]: See `run-hook-with-args-until-success`.

[^3]: See `fill-region-as-paragraph` for the details; follow down
    through `fill-move-to-break-point` then `fill-nobreak-p` for the
    invocation of `fill-nobreak-predicate`.
