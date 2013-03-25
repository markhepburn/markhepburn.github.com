---
layout: post
title: "Query by example in Django"
category: 
tags: [Hacking, Django]
---
{% include JB/setup %}

# Introduction

This is a quick hack, but I'm throwing it out there in case anyone
knows of a better solution (or better yet, if I'm missing something
obvious in the standard distribution).

The [Hibernate](http://www.hibernate.org/) ORM for Java includes a
query-by-example facility: you create a template object, setting the
relevant fields to the values you're interested in, then it retrieves
all records that match that template (fields left un-set are ignored
in the query).

To the best of my knowledge, the
[Django ORM](https://docs.djangoproject.com/en/1.5/topics/db/queries/)
doesn't support this style of querying.  I found myself wanting it
though,[^fn-reason] and this post is what I came up with.

[^fn-reason]: Specifically, I had a configuration model pre-populated,
and wanted to find if there was an existing result for that
configuration.  Basically I wanted caching, but there were reasons
that view caching (or even the low-level cache API) were not
appropriate.

# Implementation

The implementation is fairly simple: we use the meta attribute to get
the list of fields, and create a
[filter](https://docs.djangoproject.com/en/dev/topics/db/queries/#retrieving-specific-objects-with-filters)
query from all non-`None` fields.  As simplification, I'm currently
ignoring non-direct fields and many-many fields (in part because the
object I was working with hadn't been saved yet).  The id is also
skipped, because of course that should be unique!

{% highlight python %}
class QBEManager(Manager):
    """A custom manager that adds query-by-example functionality (inspired
    by Hibernate)"""
    def similar_to(self, template):
        """Find all objects that have fields matching those in the template
        object.  Fields that are set to None are ignored."""
        vals = {}
        for f in template._meta.get_all_field_names():
            _,_,direct,m2m = template._meta.get_field_by_name(f)
            if not direct or m2m or f == 'id':
                continue
            val = getattr(template, f, None)
            if val is not None:
                vals[f] = val

        return super(QBEManager, self).get_query_set().filter(**vals)
{% endhighlight %}

Then it can be used just like a regular manager:
{% highlight python %}
class Config(Model):
    # ...
    objects = QBEManager()
{% endhighlight %}

Using it anger is up to you:
{% highlight python %}
def some_view(request):
    # ...
    c = Config()
    c.start_time = datetime.date(2012, 3, 27)
    c.length = 5
    # get all configs that start on 27/3/2013 and have length 5:
    matching_configs = Config.objects.similar_to(c)
{% endhighlight %}

# Improvements

This solved my problem, but it's probably not fit for prime-time just
yet.  In particular, handling many-many fields could be added for
objects that are already saved (and hence are able to have m2m fields
established).

It is probably also better off written as a mixin; in particular, my
case was actually based off a GeoManager, and a mixin would enable
both base managers to be used.  Something like:
{% highlight python %}
class QBEManagerMixin(object):
    # ...

class QBEManager(QBEManagerMixin, Manager): # ...
class QBEGeoManager(QBEManagerMixin, GeoManager): # ...
{% endhighlight %}
