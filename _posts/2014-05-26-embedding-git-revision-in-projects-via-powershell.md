---
layout: post
title: "Embedding Git Revision in projects, via Powershell"
category:
tags: [Hacking, MS Tech]
---
{% include JB/setup %}

[We](http://www.condense.com.au/) have been working on an
[Azure](http://azure.microsoft.com/) cloud-services project, with a
web interface.  With constant updates it suddenly occurred to us that
we had no system for determining exactly which revision was deployed.
Embedding the revision identifier from your source control system---in
our case [git](http://git-scm.com/)---is a standard approach, and this
post documents our implementation and a couple of wrinkles
encountered.[^3]

# Overview

Essentially, we need to do three things:

1. Find the git SHA of the working copy;
1. Embed this somewhere useful;
1. Make sure it does this automatically before you deploy.

^
The last step is the easiest: you just run it as a
[pre-build hook](http://msdn.microsoft.com/en-us/library/ms366724.aspx).

# How to display it

The closest description I could find of what we envisaged was
[this article](https://gist.github.com/abdullin/63cdbbe71218561820e5).[^1]
He outlines how to update the deployment label[^2] in the
`.azurepubXml`
[profile](http://msdn.microsoft.com/en-us/library/hh369934.aspx),
which was exactly what we were looking for.  We eventually abandoned
that aspect though because when you deploy directly from Visual Studio
the profile is read *before* you hit "publish", or in other words
before your pre-build script has run and done anything useful.

Instead, we just write it to an HTML template that can be sourced
anywhere: in a comment in every page, or on the administrators-only
dashboard, or in the footer... it's up to you.

The catch of course is you will now have a modified-file showing up in
your git status every time you build.  The solution to this is two-fold:

* Add the file to your .gitignore, and
* Change your `.csproj` file to only include the file if it exists.

For the latter, you will need to edit it by hand:

~~~
<Content Include="Views\Shared\_GitRev.cshtml"
         Condition=" Exists('Views\Shared\_GitRev.cshtml') " />
~~~

As a bonus third step, you might want to think about how to gracefully
fail if that template doesn't exist for some reason.  Assuming
[razor templates](http://www.asp.net/web-pages), an extension method
is a useful approach:
{% highlight csharp %}
public static MvcHtmlString PartialIfExists(this HtmlHelper html, string viewname)
{
    var controllerContext = html.ViewContext.Controller.ControllerContext;
    var result = ViewEngines.Engines.FindView(controllerContext, viewname, null);

    if (result.View != null)
    {
        return html.Partial(viewname);
    }
    else
        return MvcHtmlString.Empty;
}
{% endhighlight %}
Then your templates might contain something like

~~~
...
<!-- @Html.PartialIfExists("_GitRev") -->
...
~~~

# Attempt 1: git.exe and powershell

The first version used the git executable to find the revision:

~~~
git rev-parse HEAD
~~~

A simple
[powershell](http://technet.microsoft.com/en-us/library/bb978526.aspx)
script ties it together, and we're in business:
{% highlight powershell %}
if (Get-Command "git.exe" -ErrorAction SilentlyContinue)
{
    $revision = git rev-parse HEAD

    # make sure we don't include old versions if for some reason we
    # have one, but now can't find git.exe:
    $template = "$PSScriptRoot\..\Views\Shared\_GitRev.cshtml"
    if (Test-Path $template) {
        Remove-Item $template
    }

    Set-Content $template $revision
}
{% endhighlight %}

For completeness, it's also worth pointing out here that it may be
necessary to
[enable script execution](http://technet.microsoft.com/en-us/library/ee176949.aspx)
for powershell permissions.  I also include this line in my build
hook:

~~~
powershell -Command "Set-ExecutionPolicy -Scope CurrentUser Unrestricted"
~~~

# Attempt 2: Powershell-Native

That worked, but it introduces complications such as the need for git
to be in your path, and generally feels a little fragile.

Luckily, I remembered [libgit2](http://libgit2.github.com/), a
portable standalone implementation of core git functionality.  There
are [.NET bindings](https://github.com/libgit2/libgit2sharp) and
[nuget](http://www.nuget.org/packages/LibGit2Sharp/) handles
installation so this was much more promising:
{% highlight powershell %}
try {
    # Note use of wildcard to ignore the version.
    Add-Type -Path $PSScriptRoot\..\..\packages\LibGit2Sharp*\lib\net35\LibGit2Sharp.dll

    $repo = New-Object -TypeName LibGit2Sharp.Repository -ArgumentList "$PSScriptRoot\..\..\..\.git"

    $template = "$PSScriptRoot\..\Views\Shared\_GitRev.cshtml"
    if (Test-Path $template) {
        Remove-Item $template
    }

    $revision = $repo.Head.Tip.Sha
    $dirty = ( $repo.Index.RetrieveStatus() | ? { $_.State -eq "Modified" } ).Count -gt 0

    if ($dirty) {
        $revision = "$revision*"
    }

    Set-Content $template $revision
    Write-Host "Labelled with $revision"
}
catch
{
    Write-Host "Exception during git-rev labelling; ignoring"
}
{% endhighlight %}

We use `Add-Type` to load the DLL (the hard-coded paths here feel
slightly dirty, I admit, but we can use a wild-card to mitigate
against version changes at least), then instantiate the
[`Repository`](https://github.com/libgit2/libgit2sharp/blob/master/LibGit2Sharp/Repository.cs)
object.  The SHA can then be accessed with `$repo.Head.Tip.Sha`.  The
next line also checks if any files are modified, a tweak which wasn't
present in the previous version.

# Aftermath

This is the script now running as part of our builds.  It works like a
charm, but looking back it feels like more work than it should have
been.  I'm still relatively new to the Microsoft environment and
tool-chain, so if there's an easier way of doing this that I'm
overlooking please let me know!

[^1]: In between me finding that post and writing this, the
    [author](http://abdullin.com/) pulled it because he would do
    things differently now.  He was kind enough to place it on github
    and let me link to it though.

[^2]: In other words, instead of "MyApp - 26/05/2014 16:32:39" you now
    see "MyApp - 26/05/2014 16:32:39 -
    01c5059500fa59c0f138d2f947f8493dd0a8914a"

[^3]: It's worth pointing out that what we're about to do is a
    standard feature in
    [subversion](http://svnbook.red-bean.com/en/1.4/svn.advanced.props.special.keywords.html)
    and others.  Git doesn't, and although it's a pretty common
    question on stackoverflow, Linus is
    [not a fan](http://www.gelato.unsw.edu.au/archives/git/0610/28891.html).
