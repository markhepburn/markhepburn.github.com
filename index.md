---
layout: page
title: Everything Tastes Better With Chilli
---
{% include JB/setup %}

Welcome to the blog of [Mark Hepburn](http://www.markhepburn.com).
I'm gradually moving this site over from posterous, with the aid of
[Jekyll Bootstrap](http://jekyllbootstrap.com) and
[github-pages](http://pages.github.com/).

Here's the content so far &mdash; more soon I promise!

<ul class="posts">
  {% for post in site.posts %}
    <li><span>{{ post.date | date_to_string }}</span> &raquo; <a href="{{ BASE_PATH }}{{ post.url }}">{{ post.title | xml_escape }}</a></li>
  {% endfor %}
</ul>


