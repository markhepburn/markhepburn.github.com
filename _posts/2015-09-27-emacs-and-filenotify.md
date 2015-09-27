---
layout: post
title: "Emacs and filenotify"
category: 
tags: [Emacs, Hacking, MS Tech]
---
{% include JB/setup %}

Here's another Emacs quickie.  Some time ago I wrote about
[parsing ssh agent variables in elisp]({% post_url 2014-05-20-parsing-ssh-agent-variables-in-emacs %}).
To recap, the issue was that in windows Emacs is started separately
from [git-bash](https://git-for-windows.github.io/), so it doesn't
inherit the environment variables to make it seemlessly use your ssh
keys.  My quick and dirty solution was to write a function to parse a
file containing those variables.

That works fine, but it does mean you have to manually invoke that
function.  You could run the function on load, but then you have to
remember to start git-bash first.

It's not an ideal situation, and the other day I finally wondered if
Emacs had any file-watching
library... [of course it does](https://www.gnu.org/software/emacs/manual/html_node/elisp/File-Notifications.html).

{% highlight scheme %}
(defvar ssh-file-watcher nil)

(when (require 'filenotify nil t)
  ;; We're loading up, slurp SSH envs in case in they're already
  ;; correct:
  (mh/parse-sshagent-env)
  ;; Clear any existing watcher:
  (if ssh-file-watcher
      (file-notify-rm-watch ssh-file-watcher))
  ;; Create the new watcher:
  (setq ssh-file-watcher
        (file-notify-add-watch (expand-file-name "~/.ssh/agent.env")
                               '(change attribute-change)
                               'mh/parse-sshagent-env)))
{% endhighlight %}

In other words, another 5 minutes of hacking and now we simply load
the variables just in case, clear any existing watcher, and start
watching the file for changes --- when it does, we simply slurp
again.  If you follow this verbatim, the only addition you'll need to
make is to ensure that your callback function accepts the arguments
filenotify will give it; I just ignored them: `(defun mh/parse-sshagent-env (&rest ignored)... `

Much more painless!
