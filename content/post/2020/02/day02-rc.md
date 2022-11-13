+++
title = "RC Day 2: Pair-ity"
publish = true
date = 2020-02-18
description = """Networks. The Final Frontier. These are the voyages of the
Recurse Center. Its continuing mission: to make education something you do, not
something done to you."""
aliases = ["/post/day02-rc/"]
+++

Like I said at the end of my post yesterday, my goal for today was to focus on
paring. It wound up being an extremely social day; I met more people and hung
out with several of the people I'd talked to yesterday, and had a lot of fun.

Yesterday when I was chatting with Ori he told me about emulators for the
PDP-10. The PDP-10 was a 36-bit architecture, whereas most modern architectures
are 32-bit architectures. This is an issue because a lot of computer components
assume the memory will be addressable in 8-bit bytes, but 36 doesn't divide into
8. Emulators get around this by using the [parity bit](https://en.wikipedia.org/wiki/Parity_bit)
in error-correcting RAM as actual data, disabling their error correcting
functionality. They call this the _disparity bit_.

So there's a bit of what I learned yesterday and it fits in with the punny title
to this post.[^1]  I'm not gonna stop with the pun titles until I run out of
them.  That will either be never or next Thursday.

[^1]: I also played a card game involving pairs yesterday, but I'm not gonna do
  _two_ punny leads. Unless you're the kind of person who reads the footnotes.

## Who's That? The Mastermind

There was an excellent pairing workshop this morning run by Allison and Bill.
Right before the workshop Shean and I briefly looked over the DNS server,[^2]
then I paired off with Alex to work on an implementation of the game Mastermind.
The game is a fun guessing game. Four pegs of different colors are picked and
then you get ten guesses to get the combination, with each guess telling you how
many answers are right and how many are the right color but in the wrong place.

We called our version [Mmastermind](https://gist.github.com/Dylnuge/50021d55c14e3faf129fc3f2804cd152),
in honor of the tragically broken m key on my Macbook's butterfly keyboard.[^3]
I had a lot of fun learning how ANSI terminal colors work; it turns out that a
"Bold Red" is often just an entirely different color from "Red" to get around
the relatively limited set of colors (8 regular and 8 bold) a terminal has to
work with.

[^2]: I keep debating whether to call it Montague or not in these posts; I
  haven't been using that name much recently so maybe that's why I'm avoiding it
  here. An A record by any other name would smell as sweet, but maybe a
  different server name would be less silly.

[^3]: I plan on getting it fixed but I'm not sure what I'll do without a laptop.

## Coffee Chats and Network Hacks

The coffee chat bot at RC pairs people off daily, so today I got to have coffee
with Nathan! Thanks to my morning of pairing, that became a lunch instead of a
coffee. I learned about what Nathan was working on at Recurse and about [NixOS](https://nixos.org/)
and shell configurations and a lot more. I really like the daily pairing of
coffee chats; it makes every day have a bit of randomness to the interactions
I'm having and mixes things up a bit. There's also a pairing bot which I signed
up for, so I'll see how that goes tomorrow!

With a decently large group of people who expressed various interest in
Montague[^4], I spent the rest of the afternoon pairing and working through some
arbitrary stuff. This segued off into a really great in-depth set of
conversations about how DNS and networking in general worked. There's a bit of
interest in starting a networking club to talk about this more!

For understanding DNS better, I'm a fan of the [comic series](https://howdns.works/)
DNSimple put together as well as James Routley's article,
_[Let's hand write DNS messages](https://routley.io/posts/hand-writing-dns-messages/)_.
I also chatted with Sam about his super cool project to try and build isolated
private networking clusters; we talked a bit about the Data Link and Network
layers of networking and how traffic is ultimately routed via autonomous
systems. I don't have nearly as solid of a grasp on BGP as I do DNS, so it was a
lot of fun to run through this and find where I'm missing a full understanding.

[^4]: And now I am using the name. I bet that's confusing for people who _don't_
  read footnotes.

## DNS is WEIRD

Bernardo and I worked out how to make the DNS server not crash when it received
EDNS OPT records [by adding support for OPT's weird recycling of the RRType class
field](https://github.com/Dylnuge/montague/commit/14e8eddc7eb409fcbc5bcf7f4cc89aad6ecb1527).
The code we put together didn't feel quite right to either of us; because the
new value technically isn't a class, putting it in the class field feels wrong,
but that's also effectively what the spec is already doing. Bernardo suggested
making class itself into an enum, which I also like, and might look into more
tomorrow.

Bernardo also pointed out there might be even more pseudo-RRs[^5] like this. I'm
entirely unsure how to confirm that we're handling all the appropriate edge
cases!

After we did this, we got sidetracked noticing that a query for ALL records was
being rejected by a handrolled request we built but not by a (seemingly
identical) request from `dig`. We opened up Wireshark to trace down what was
going on and after a few dead ends realized that `dig` would _recreate_ the
request over TCP when it was truncated and rejected over UDP. Apparently, some
DNS servers will serve a request for ALL records, but only when it's coming over
TCP. Presumably this is a preventative measure for [amplification
attacks](https://www.cloudflare.com/learning/ddos/dns-amplification-ddos-attack/).

Even more interesting, not all the servers we tried behaved the same way; Quad9
and Google both behaved like this (with different sets of records included in
the responses, though), but Cloudflare DNS refused an ALL record request even
coming over TCP directly. Clearly I still have a lot of stuff I need a better
understanding of to be capable of this project.

At the end of the day there were a bunch of non-technical presentations I
thoroughly enjoyed. Some of the themes covered included the history of Pong, the
beauty of Arabic cursive and calligraphy, and how to poop in the woods.

Overall it was a wonderful second day at RC. I look forward to tomorrow!

[^5]: That's not meant to be mean to OPT records; the RFC literally calls them
  pseudo-RRs.
