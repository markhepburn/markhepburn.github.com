---
layout: post
title: "Electric Punctuation in Emacs"
category: 
tags: [Emacs]
---
{% include JB/setup %}

Funnily enough, the idea for this Emacs hack comes from my smart-phone
keyboard.

The awkward nature of pecking at glass, with no tactile feedback, also
means that there is a certain necessity for invention in order to
recapture the usability of a regular keyboard, and some nice ideas
come out of it.  Some of these make use of the different nature of the
surface itself, such as
["swipe" typing](http://www.youtube.com/watch?v=WuP6AQPRpUg), while
others might provide a greater efficiency (in the average case), such
as automatically inserting punctuation, aggressive history-based
auto-completion, etc.

I swear by [SwiftKey keyboard](http://www.swiftkey.net/), and it has
been worth every one of the five dollars I think I spent on it --- in
fact of all the examples I just provided they actually implement all
of them (now that they are
[developing swipe typing](http://www.swiftkey.net/flow/) as well).

The other day at work, at a regular keyboard, I realised I was
actually missing one feature in particular, but luckily since I was in
Emacs it only took 10 minutes to implement!  That particular feature
was the way punctuation is correctly inserted in SwiftKey; if you
choose an auto-completion it will also insert a space, for example
leaving you with "word |" (where | is the cursor; note the trailing
space).  However, if you then type a comma it is inserted in the
correct place: "word, |".

Basically, you never have to think about punctuation or spacing too
much, as it just works.  Here was the result of my
procrastination:[^fn-electric]

{% highlight scheme %}
(defun mh/electric-punctuation ()
  "Tidy up whitespace around punctuation: delete any preceding
  whitespace and insert one space afterwards.  Idea stolen from
  the SwiftKey android keyboard."
  (interactive)
  (when (looking-back "\s+" nil t)
    (delete-region (match-beginning 0) (match-end 0)))
  (call-interactively 'self-insert-command)
  (just-one-space))
{% endhighlight %}

In other words (assuming this function is triggered by punctuation),
if there is some preceding space then delete it, insert the original
character, and add a space afterwards.

Then to trigger this whenever I type a comma, semicolon, or period
within regular text, I add it to the base `text-mode` hook:

{% highlight scheme %}
(dolist (punc '(?, ?\; ?.))
  (define-key text-mode-map `[,punc] 'mh/electric-punctuation))
{% endhighlight %}

I will admit that it is taking me a little getting used to (it turns
out I have ingrained habits of typing punctuation+space, resulting in
lots of double-spacing!), and there's room for improvement.  In
particular, I suspect it needs a special case to handle numbers (you
don't want "3.14" to end up as "3. 14").  I really appreciate SwiftKey
for the way they continually sand down corners, and there are no doubt
lots of corner-cases remaining here.  Still, it was the sort of
easy-to-implement idea that I love about Emacs!

[^fn-electric]: "Electric" is common terminology in Emacs for keys ---
typically punctuation --- that perform some other action as well as
self-insertion.  These are particularly common in programming modes
where it may also indent, or even insert matching brace and
newline-and-indent.
