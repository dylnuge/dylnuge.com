+++
title = "Hello, Recurse Center!"
publish = true
date = 2020-02-17
description = """In which I meet people, play music, make DNS queries, and get
less Rusty with Rust"""
+++

Today I started in the Spring 1 batch of [Recurse
Center](https://www.recurse.com/scout/click?t=0ed1e008055df394a2f2f5f6115f74af).
For the next 12 weeks, I'll be working on becoming a better programmer. I'm
already extremely excited for all the things I'm going to learn and do.

My plan is to write a summary blog post each day of what I worked on and
learned. Many of these will probably be pretty short compared to my regular
content,[^1] and there's not going to be a cohesive theme or structure to them.

[^1]: This blog only has a single entry so far, but I suspect some readers have seen a
  bit of my _other_ writing.

## What is Recurse Center?

The best description is probably the [about page on the RC
website](https://www.recurse.com/about). For anyone who hasn't already heard me
try and explain what I'm doing, I'll dive into why I'm here and what I'm excited
about.

Recurse Center is a community for self-directed learning in New York that's
focused on programming. I applied to a full 12 week long batch; there are also
6 week long half batches and 1 week long mini batches.[^2] Regardless of length,
you have the entire time to work on whatever projects you want. There's no rule
to what you can work on; the guideline I've been given is to set goals for
things you want to improve on and do whatever is actively helping you improve.

There's a lot of general stuff I personally want to get better at:
* I want to do challenging systems programming problems, which is something I
  haven't touched much since graduating college in 2014.
* I want to get better (and more productive!) at technical writing and
  presenting.[^3]
* I want to explore technical interests outside of the data engineering I've
  done at most of my jobs and discover what excites me.
* I want to get better at following through on my side projects instead of
  leaving them half-finished messes.

My main concern is focus; I want to do _everything_ but I know that I will need
to focus on a few specific things to get the most out of my time here.

[^2]: These are timed so they each start on the same day; a new set of batches
  starts every 6 weeks. Today was the start of the Spring 1 '20 half and full
  batches and the Mini 2 '20 batch.

[^3]: My article on [lessons learned from Chernobyl](https://medium.com/@dylnuge/chernobyl-devops-software-engineering-disaster-management-and-observability-8a50a7ea98d6)
  is a piece I'm still decently happy with, but I haven't done a _lot_ of
  technical writing, and all the presentations and talks I've given have been
  internal to companies, so writing and especially _sharing_ and getting
  feedback more is the real goal here.

## Moving to New York

Everyone who knows me personally knows I moved to Brooklyn a few weeks ago; most
of you also know I was doing Recurse Center. The move wasn't strictly motivated
by Recurse Center, but the two fit together very well. I was also fortunate
to have saved enough to make the combination of moving and not working for three
months financially doable.[^4]

Beyond wanting to do RC, I was at a point both career-wise and life-wise where I
was ready to try something different. I don't really think I consciously chose
to move to San Francisco when I graduated college; it was where all the CS
majors were moving, where the startups were, where the great programming jobs
were. I knew I wanted to work at startups, I took a job at one, and the rest
just kind of fell into place naturally.

Of course, there are tech jobs and startups in tons of places, even more so now.
Many friends of mine have been rotating in and out of the Bay Area, and I now
have a much better sense of what else is possible. San Francisco is a wonderful
but expensive place to live, and I've seen a lot of it; trying out another city
just feels right.

As for work, the startups I've been at have taught me a lot. I have gained an
incredible general understanding of how businesses and engineering interact, how
single-page web applications function, how ETL systems work, how data science
and statistics can help us understand data, how to manage incidents, how to
manage people, how to hire and recruit, and plenty of other things.

I have _not_ had the opportunity to dive deep into a single area that excites
me, though.  Startup work is usually about doing whatever is most critical
_right now_, and I feel like I've grown a lot more in my business and management
knowledge over the past few years especially while my programming knowledge gets
left behind.

I'm not sure if I'm "done" with startups in any sense, but it was time for me to
take a break and recover from a bit of burnout. I'm so excited I have the
combination of Recurse Center and New York as a backdrop for this.

[^4]: RC is free but living in New York isn't. If you're in an underrepresented
  group in tech, there are [grants on offer](https://www.recurse.com/diversity),
  though!

## Intro to the Space

OK, so on to the first day\![^5] This morning was dedicated to an introduction
to the space—we had a tour, met a bunch of people, and had a few brief
presentations.

The space itself is structured in a way I absolutely love. There's two separate
floors, one which is designated as a quiet focus floor and one which is more
social. The social floor has a lot of cool stuff; pairing stations, a computer
history "museum" of working classic computers you can play with and hack on, a
music room to work on things like synthesizers (or just to relax and play some
instruments), a few conference rooms, and of course various couches and tables
to work at. The second floor has a library, more couches and tables, and a bunch
of desks to use as workstations.

After the tour (and breakfast and coffee), we got a welcome presentation which
included lots of encouragement, sharing[^6] what we were nervous and excited
about, advice from the full batch that started six weeks ago, our own
introductions, and an explanation of the wonderful [social
rules](https://www.recurse.com/social-rules). Seriously, go read the social
rules; they're how I first heard about RC several years ago and I think they'd
be amazing implemented in every space.

There were then meet-and-greet sessions where everyone[^7] was paired off every
three minutes for a few quick chats. This was excellent; the everyone here
includes not just those of us starting today but also the full-batch Winter 2s
who'd already been around for 6 weeks and the staff. Hearing from the people I
was paired with during this helped me solidify my plans for the week, to the
point I was giving different answers to "what are you planning to work on?" by
the end of the meet-and-greets.

Following all of this I signed up for a lunch group and went out with ten or so
other Recursers. The lunch conversations were great as well (and the food was
good too). I was surprised by how many shared interests I had with others. We
talked about hiking and outdoor adventures, theater, video games, speedrunning,
and speed-cubing.[^8]

[^5]: Look, I said _many_ of these posts would be short, not all of them 😉

[^6]: RC is an extremely welcoming space and the staff made it very clear that
  people were not expected or required to share if they didn't feel comfortable.
  The structure of the space also makes it easy to find the right balance of
  socializing that work for you.

[^7]: In the same spirit as the last note, you could opt out at any time during
  the process, including in the middle of it. For me personally, the time
  scheduled was exactly the right length.

[^8]: Today I learned that this is competitive solving of Rubik's Cubes, and
  there's a lot that goes into it!

## Day One: Feeling Rust-y

After lunch,[^9] the day was wide open to work on whatever I wanted. Right on
getting back, I wound up in the music room. One of the Mini 2's (Cole) had
brought in a modular synth and was playing around with it; he told us about how
various synth components worked and another Mini 2 (rfong) showed us their mini
synth and we played with it hooked up to a keyboard.[^10] I also tuned a guitar
(for no reason except it needed tuning and it's kind of a relaxing activity) and
had a great conversation about [music theory](https://www.musictheory.net/) with
Shean, who's also in my batch.

I wanted to get some programming done today and I also at this point needed a
bit of a break from the constant social stimulation, so I wandered up to the
focus floor, found a couch, and started working on
[Montague](https://github.com/Dylnuge/montague), the Rust-based DNS server
project I started last fall and hadn't had a chance to work on recently.

The last thing I did on it, all the way back in October, was add a highly
hacked-together recursive resolver that wasn't capable of functioning without
[glue records](https://ns1.com/blog/glue-records-and-dedicated-dns). My goal
today was to add the functionality needed to process responses that were missing
glue records.

This took me longer than I thought for a couple reasons. First, this was the
project I started to learn Rust, so several months away from it meant that my
knowledge of the language itself had gotten a bit rusty, as had my knowledge of
my own project's code. Thankfully my DNS knowledge was still sharp enough that I
was able to get back up to speed.

I hit a roadblock when I realized that my naive storage of resource records,
while fine for the IP addresses in A and AAAA records, stripped out too much
information to be able to reconstruct the DNS names in nameserver records.[^11]
I spent a little while refactoring the code to support more complex
deserialization and more semantic storage of record data; [here's that change for
the A and NS records](https://github.com/Dylnuge/montague/commit/56b338f78606693526e2750bb1daf79e115cd8f7).

Once I'd tested that (and I desperately need to add better testing to this code;
that will likely be the first thing I work on tomorrow), I got started [factoring
out the glue record handling](https://github.com/Dylnuge/montague/commit/3c0e55137742ac5059d75d70d3143d7739e27b6f),
which was pretty straightforward. Finally I made the change I'd originally
planned and added [NS lookup
code](https://github.com/Dylnuge/montague/commit/907d8e24712bbe4de2188412bafdae346e06d3ce).

This has a couple flaws I know about and I'm also not totally sure how to test
it; the base case I've been using so far _requires_ glue records on every stage,
so if I just "skip" processing glue records I confirm that this code makes
queries but wind up in an infinite loop. I need to look into what kinds of
requests would return nameservers instead of answers but would _not_ return glue
records and test it with those.

That infinite loop is the big issue I have right now, too—and it's the reason we
need glue records for DNS to work in the first place! If we're told that a
nameserver exists at `ns.example.com` and contains the address for
`example.com`, for instance, how would we know how to talk to the nameserver? We
could make an NS query for `ns.example.com`, but we'd ask `.com` who to talk to
for `example.com`, and it'd tell us...`ns.example.com`. Instead, we include glue
records in the response from `.com`; the nameserver[^12] that manages `.com.`
knows the IP address(es) for `ns.example.com` already, and adds them to the
response in an "additional records" section.

Just because this isn't _supposed_ to happen doesn't mean it won't, though.
Plenty of issues could happen here; I could be talking to a malicious
nameserver, of course, but I could also just be talking to a malfunctioning
nameserver which is missing its glue records for some reason or another. Since I
want my DNS server to be robust, it needs to detect this. There's not a ton of
technical complexity to detection here; just don't look up `ns.example.com` if
we're already trying to do exactly that, and error out instead. However, the
current structure of the code is very "functions that don't know much about the
state surrounding them," which means I need to think more about how to
reorganize the code.

Anyways, I was satisfied with how much I'd gotten done for the day, and went
back down to the social floor to start drafting this blog post.

[^9]: The extremely pedantic part of my brain is uncomfortable leaving this in
  without noting that technically we were free _before_ lunch, and lunch itself
  was a self-directed part of the day.

[^10]: A Yamaha P-85, if you care, which I do.

[^11]: This is because DNS names can contain pointers to parts of other names
  written somewhere else in the packet instead of just repeating the same part
  over and over. This is done to compress the packets. One example where it's
  really useful is with the root nameservers list. They're all called things
  like `a.root-servers.net.` and `g.root-servers.net.`. It saves a lot of space
  for the packet to just have `.root-servers.net.` once and keep pointing back
  to it every other time it's used, but since these are absolute positions that
  might be anywhere in the packet, it means a DNS name is _unreadable_ if
  you don't have the exact bytes from the original response.

[^12]: When I was talking about this earlier, the difference between a simple
  nameserver, like the one that serves records for `dylnuge.com`, and the
  complex web of infrastructure that handles something like `.com` came up. I
  don't actually know how TLD nameserver infrastructure works; they have a lot
  of failover "servers" but I suspect none of them resemble individual servers
  and are much more complicated distributed systems. I'd love to research this
  more in the near future and write about it!

## Looking Forward

I had a lot of great conversations this evening! I talked about the DNS server
and learned more about what others had started working on as well. I also had a
really great conversation about low-level systems bugs with Miles and Ori. I
haven't had a conversation like that in a while, and it was a ton of fun and I
learned things I'd never have expected.[^13]

Tomorrow we have a presentation on pair programming, which is a big part of
RC's traditions and something I've constantly heard people say is worth doing a
lot! I made plans to pair on my DNS server tomorrow which I'm very excited for.
I'm not super happy with the state it's in right now, but I bet that by pairing
I'll get a lot of feedback and learn things I hadn't even been thinking about.

Thanks for reading this whole thing! I look forward to regular—and
shorter—checkins for the rest of my batch.

[^13]: OK I'm getting vaguer now because I'm ready to finish writing this post;
  it's over 2500 words and I've been writing for almost an hour!
