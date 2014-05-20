---
layout: post
title: "Parsing ssh agent variables in Emacs"
category: 
tags: [Hacking, Emacs]
---
{% include JB/setup %}

Recently I have found myself working in Windows land, for the first
time in quite a while.  It wasn't long before I had
[Emacs](http://ftp.gnu.org/gnu/emacs/windows/) installed of course,
but my main incentive was actually
[magit](http://magit.github.io/).[^1]

The only problem was I still couldn't fetch or push using magit,
because it didn't have the ssh-agent environment variables.  This was
because I wasn't launching Emacs from a shell, but fortunately I
remembered that the bit of shell code I'd
[cribbed from github](https://help.github.com/articles/working-with-ssh-key-passphrases)
to set up ssh-agent there also handily left them in a file.

The file looks like this:

    SSH_AUTH_SOCK=/tmp/ssh-WOAJeX1728/agent.1728; export SSH_AUTH_SOCK;
    SSH_AGENT_PID=4880; export SSH_AGENT_PID;
    echo Agent pid 4880;


After realising this it was just a few minutes of rolling up the
sleeves and writing some elisp to parse this and set the variables
locally:

```scheme
;;; Set variables for ssh interaction, assuming they exist in a file ~/.ssh/agent.env.
;;; See https://help.github.com/articles/working-with-ssh-key-passphrases
(defun mh/parse-sshagent-env ()
  (interactive)
  (with-temp-buffer
    (insert-file-contents (expand-file-name "~/.ssh/agent.env"))
    (dolist (varname '("SSH_AUTH_SOCK" "SSH_AGENT_PID"))
      (goto-char 0)
      (re-search-forward (concat varname "=\\([^;]+\\)"))
      (setenv varname (match-string 1)))))
```

It's very quicky and dirty, but it works for me:

* slurp the file into a temporary buffer;
* for each of the variables we're interested in, look for its value
  (the regexp simply grabs everything in between the equals and the
  following semi-colon);
* finally, use
  [`setenv`](http://www.gnu.org/software/emacs/manual/html_node/elisp/System-Environment.html)
  to make it available inside Emacs.

Of course, I was able to develop this without leaving Emacs once;
searching the documentation to remember how to access captured groups,
testing the regexp, incrementally developing and finally "installing"
the function and getting back to work.  I'm sure this particular hack
has been done many times before, but it was just as much fun and
didn't take much longer to do it myself---this is why I love working
in Emacs!

[^1]: Unfortunately I still use the command-line most of the time;
    magit on windows is frustratingly slow.  Simply expanding a diff
    takes around 3 seconds.  If anyone has any fixes I'd be very
    grateful.
