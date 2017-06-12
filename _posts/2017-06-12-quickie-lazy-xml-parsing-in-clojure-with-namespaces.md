---
layout: post
title: "Quickie: Lazy XML Parsing in Clojure with Namespaces"
category: 
tags: [Clojure]
---
{% include JB/setup %}

# TL;DR:

* Idiomatic XML processing in Clojure is possible and even easy, but
  under-documented;
* Namespace-XML support seems to be particularly hidden;
* It works naturally by mapping to namespaced keywords.

# The Details

I still occasionally find myself writing XML processing code in
Clojure, either for production or one-off data munging tasks.  XML
support is quite good, and quite idiomatic, but I've found that
getting started is often confusing.
Is [data.xml](https://github.com/clojure/data.xml) all you need?
Where does [data.zip](https://clojure.github.io/data.zip/) fit in?

The short explanation is that the first function you are likely to
find returns a Clojure structure with maps representing elements, but
then there's a similar function that is *lazy*, and there's also a
zipper library with some awesome processing functions that is probably
what you want, at least on the input side.  The best overview I've
found is
[this blog post](http://blog.korny.info/2014/03/08/xml-for-fun-and-profit.html).

My code usually starts off something like this:[^fn]
```clj
(:require [clojure.data.xml :as xml]
            [clojure.data.zip.xml :as zx]
            [clojure.java.io :as io]
            [clojure.zip :as zip])

(-> filename io/resource slurp xml/parse-str zip/xml-zip)
```
which you can then process using
the [data.zip.xml](https://clojure.github.io/data.zip/) utilities,
generally starting with either `xml->` or `xml1->` (the latter
just produces a single result), and using keywords to traverse down
tag names:

```clj
(zx/xml-> zipped-xml :RootElement :SomeChild custom-processing-fn)
```

(where `custom-processing-fn` is probably returns a structure out of
the `<SomeChild>` element)

The problem is: what if your document is namespaced, such as
`<myns:SomeChild>`?  Fortunately, it turns out that you can map these
exactly to Clojure namespaced-keywords.  The trick is the `alias-uri`
function:
```clj
(xml/alias-uri 'sld "http://www.opengis.net/sld")
```
and then you can proceed exactly as before, but with namespaces:
```clj
(zx/xml-> zipped-xml ::sld/StyledLayerDescriptor ....)
```

[^fn]: Note that while this uses the lazy versions of the parsing
    functions, the input is read eagerly.
