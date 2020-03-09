+++
title = "RC Days 4-15: Call Me By My Nameserver"
publish = true
date = 2020-03-09
description = """I really need to stop using punny titles for my RC posts. This
is becoming a problem."""
+++

I'm going to be writing my Recurse Center posts less frequently.[^1] I want to
write up more in-depth technical explorations of what I'm working on, and if I'm
writing every day it's easier and more tempting to just do basic journaling. The
posts I wrote in the first week (especially the day 2 and 3 ones) don't look
substantially different from long-form variants of my check-ins.[^2]

So instead, here's a summary of the projects I've been working on or am going to
start working on, in a pretty arbitrary order that still feels right to me.

[^1]: I technically already _have_ been writing them less frequently, since this
  is the first post in several weeks.

[^2]: Internally at Recurse Center we have daily check-ins about the work we're
  doing and have done on Zulip, our chat system. It's kind of like a standup.

## Montague

The project I've put the most time and energy into over the last two weeks has
been [Montague](https://github.com/Dylnuge/montague), my DNS server. There's
still a lot of functionality missing from it—adding a cache for lookups is
probably the one I want to tackle next—but I'm going to step back from it for a
little bit. I've hit the point where I'm decently happy with where it is.

It's not even close to a production server, but I want to constantly be working
on projects that are forcing me to learn more. I think I have a decent
understanding of the things I wanted to get out of Montague: Rust as a language,
DNS resolvers as a concept, and DNS implementation specifics and minutia. The
main thing left to learn, I think, would be building a distributed cache in
Rust, which while interesting, is kind of its own project. So I'm going to hold
off on that for the moment.

## Open Source Contributions

On the other hand, I was learning Rust in part to get more involved in the
community; most of the development work I've done in my life has been
proprietary, and I want to work on more open-source things. Plus, one way to
learn a lot about a language very fast is to jump straight into the compiler
source code. I've now made two very small contributions to the Rust repo. I look
forward to tackling more complex changes and bugfixes in the near future.

## Technical Writing and Speaking

Another reason for me to stop with the daily update posts is that the form of
writing in them felt like it wasn't furthering any learning goals of mine. I
have a few more detailed technical blog posts that aren't tied to any one day of
RC work in my drafts; hopefully one of them will be ready to share by the end of
the week. Though I intend to keep doing occasional public checkins here, they're
not _really_ in-depth technical writing, just a stream-of-consciousness journal
on what I've been thinking about recently.[^3] I want to write some posts on
this blog that hold up to the writing in [Chernobyl DevOps](https://medium.com/@dylnuge/chernobyl-devops-software-engineering-disaster-management-and-observability-8a50a7ea98d6),
which I still consider my best work.

I also entered Recurse Center with the goal of getting better at technical
speaking. I'm excited to announce that I submitted a talk proposal to
[!!Con 2020](http://bangbangcon.com/index.html). It's a selective conference[^4]
but if I don't get in there I'll probably submit a talk for a smaller, less
selective audience like a meetup. Beyond that I've done a couple talks at RC so
far, and I do feel like I'm making progress here.

[^3]: I _like_ journaling. I tend to think verbally, and journaling is a great
  way to both meditate on what I've done and crystallize what I want to do. It's
  unlikely I'll stop doing this because I still get something out of it; I just
  want to be clear that journaling is a different form of writing from the one
  I'm talking about here.

[^4]: There's also no word yet on if COVID-19 concerns will cause the conference
  to be canceled; it wouldn't be the first May event I was planning on
  attending that's been canceled.

## Revisiting Web Development

This blog will need some design changes to accommodate my technical writing
goals; right now I don't have support for images, for instance, which I need to
add at some point, and I don't love the footnotes all gathering at the bottom.
There's also a lot of tweaks I want to make; the site doesn't look very good on
mobile, the open graph unrolling is pretty bare-bones, and so on. So expect some
upcoming redesign work.

I also want to add _more_ to this site, including a section for the projects
I've worked on, and maybe a section for talks and workshops once I've given some
publicly, but those are mostly writing goals and won't take a ton of design
effort.

I haven't seriously developed for the web in a long time; I did build a React
frontend and a Django server at Two Chairs while I was there, but that was
pretty quick-and-dirty and the hard work there was mostly in data imports.[^5]
This website itself isn't interesting in that respect (it's just a static site),
but my next major project at RC might be to do some frontend web development. A
lot has changed since I last worked on frontend teams, and I'd love to learn
about web assembly.

[^5]: "Isn't it always?" says the (recovering) data engineer.

## Revisiting Cryptography

Over Christmas in 2017 I did [most of the first two problem
sets](https://github.com/Dylnuge/cryptopals) of the [Cryptopals
challenges](https://cryptopals.com/). I'm pretty sure I only stopped because I
went back to work and just let this languish. There are other people here at RC
working through these challenges, so I intend to revisit them.

I originally was working on them in Go to learn Go; I'll probably keep them in
Go because there's not a great reason to change it up, though I realize now that
the major conceptually interesting things in go, goroutines and channels, are
not really things I'd use in Cryptopals at all, so it probably wasn't a great
project to choose for learning the language.

## Personal Workflow and Organization

The final category here is more open-ended, but something I'm constantly working
on improving while at Recurse. On my second day I had a great conversation with
Nathan about how as programmers we usually spend a lot less time investing in
improving our workflows and tooling than we do using those things, and I've
noticed that. I tend to "put up with" things that frustrate me in my vim config
rather than actually go and fix it, for instance—not because fixing it is
impossible or even difficult, but because it seems like a distraction from the
thing I'm actually working on, and I can always fix it later (though I never
do).

So I'm now trying to be more proactive about identifying and handling workflow
improvements when they come up; just doing things in the moment tends to work
better for me than making long todo lists of things I seem to never get to. I'm
also trying to be more organized around what I'm working on in general. For RC,
it's made sense for me to have _themes_ and allow myself to deviate from a
specific task so long as it fits the theme. For instance, my theme in the last
few weeks was discovery; to that theme, I was happy diving down a rabbit hole if
I was discovering how something new works.

My theme for this week is organization. I'm a little more than a quarter of the
way through my time here; organizing this blog/website, getting my resume and
job search plans in order, and organizing my tooling and configurations all seem
worthwhile. Since that's not a programming-centric goal, I'll likely be focused
on open-source contributions and pairing this week; it's a way to identify my
organizational shortcomings while programming on interesting things.

That's all for this update!
