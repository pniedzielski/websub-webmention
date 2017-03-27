Webmentions from WebSub
===============================================================================

This project is a simple [WebSub][websub] (a.k.a. PubSubHubbub)
subscriber that sents off [webmentions][webmention] when it gets an
update from the hub.


Why?
-------------------------------------------------------------------------------

Automatic sending of webmentions is awkward to integrate with a static
site generator like [Jekyll][jekyll] for a number of reasons:

  - Webmentions have to be sent out after the URL is established and
    accessible, or else the receiver will drop them.  You probably
    don’t want to be generating your Jekyll site straight into your
    `/var/www/` directory, in case of errors during site generation,
    so we have a bit of a paradox in when the webmention can be sent
    out.

  - Webmentions should be sent out for every new and every updated
    post.  Unfortunately, there is no easy way to tell which posts are
    new or updated at site generation (save perhaps by incremental
    builds).  The easiest solution at site generation is to send out
    webmentions on every post after every site generation.
    Webmentions are idempotent, so this shouldn’t break receivers, but
    it’s neither good for site generation times nor neighborly towards
    other sites.

  - Jekyll site generation should work in a clean environment, so
    caching which webmentions have been sent already won’t necessarily
    help.

So we need to send webmentions out after site generation, but the only
shot we have at knowing which posts we should send webmentions based
on is at site generation—and even that’s not guaranteed.

Static sites, though, probably are generating RSS feeds.  Along with a
WebSub hub, which already has to do minimal caching of old results, we
can be pinged whenever there is an update on the site—either a new or
an updated post.  A really nice hub will only send those items that
are new or have updated, but even if not, we are limiting the number
of webmentions we are trying to send, and the frequency with which we
do it.

This has the nice effect of decoupling webmention sending from
site-generation.  If something goes wrong with one of them, the other
is not affected.  The two services can live on separate hosts.  Site
generation can happen anywhere (even on a localhost), and does not
necessarily cause webmentions to be sent (useful for testing).


How?
-------------------------------------------------------------------------------

This is a simple [Sinatra][sinatra] web server that acts as a WebSub
subscriber.  Whenever it receives an HTTP POST to `/callback`, it
parses the body as an RSS or Atom feed, and gets a list of all the
posts in the update.  For each post in the update, the server makes a
request to its permalink, parses the page for absolute links within an
`h-entry`, and then tries to send webmentions to each of those links.

**Note**: At the moment, the server does not handle any WebSub
subscription renewal, nor does it require an HMAC from the hub.  It
also does webmentions synchronously, which needs to be changed before
the code is ready to be deployed.


License
-------------------------------------------------------------------------------

Copyright © 2017, [Patrick M. Niedzielski][pniedzielski].

Licensed under the Apache License, Version 2.0 (the “License”); you
may not use this file except in compliance with the License.  You may
obtain a copy of the License at

<http://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an “AS IS” BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
implied.  See the License for the specific language governing
permissions and limitations under the License.


[jekyll]:       https://jekyllrb.com/
[pniedzielski]: https://pniedzielski.net/
[sinatra]:      https://sinatrarb.com/
[webmention]:   https://webmention.net/
[websub]:       https://www.w3.org/TR/websub/
