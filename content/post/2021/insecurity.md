+++
title = "(In)security — FUD, Facts, and Confusion"
publish = true
date = 2021-12-26
+++

2021's most memorable security fault is likely going to be log4shell
(CVE-2021-44228), but I still find myself thinking back to "Trojan Source" from
November. In the style of modern security research, [Trojan
Source](https://trojansource.codes/) launched with a fancy marketing website.
Spooky fog literally drifts across the page. The opening statement is "Some
Vulnerabilities Are Invisible."

The crux of the bug isn't exactly stunning. Most modern programming languages
allow code to be written using Unicode characters (or a permissive subset
thereof). This is a crucial aspect of internationalization that goes beyond just
strings: comments, variables, method and function names, and the like should all
be able to be written in languages other than English.

At the same time, Unicode's extensive set of characters creates issues.  Some
characters are homoglyphs, meaning they look identical to other characters
within the same font. For instance, a Cyrillic Es (с) or a Greek omicron (ο) in
many fonts look identical (or very nearly identical) to a Latin c or o. An
attack where someone registers a unicode domain name (IDN) with lookalike
characters replacing those in a well known property like "google.com" or
"bankofamerica.com" is extremely well-known; the [wikipedia
page](https://en.wikipedia.org/wiki/IDN_homograph_attack) has existed since
2005.

While Trojan Source is bold enough to bring up homoglyph attacks in source code
as if it was a new attack[^1], the thing they *focus* on is an abuse of the RTL and
LTR control characters. These characters don't display anything, but they're
used to instruct a program to render text right-to-left instead of left-to-right
(e.g. for Hebrew or Arabic). The "trick" in Trojan Source is the realization
that if you use these maliciously in source code, you can make source code look
like it does something different than what it actually does, since the RTL
*display* doesn't affect how the compiler parses the code—to the lexer, it's
just a glyph sitting inside an identifier.

And don't get me wrong, this is clever. If it showed up in a CTF or as part of a
DEFCON talk on how someone got into a system we'd all be smiling and nodding
along and going "ooh, I knew there were issues with unicode, but I'd never
thought of doing that specific thing.[^2]" But this exploit was *marketed*.
There's really not another way to look at it. And unlike other vulnerabilities
from this year, there's an easy way to detect whether someone has done this to a
codebase, especially an open source one. Quickly after it was published, people
searched Github and other open source hubs, looking for unexplaned control
characters in code. None were found.

Reaction on infosec twitter was...decidedly mixed. A decent number of people
made fun of it, especially for the "prestige." I have no doubt the exploit was
important work for the two security researchers who discovered it.

But if you google "Trojan Source," as of this writing, the first result is still
that marketing page. The second result is the GitHub with proofs of concept from
the researchers. And the third result, the first independent result, is an
article by Brian Krebs with the incredible title ["'Trojan Source' Bug Threatens
the Security of All Code"](https://krebsonsecurity.com/2021/11/trojan-source-bug-threatens-the-security-of-all-code/).

I'm personally concerned that Trojan Source did showcase a rather severe
vulnerability in our information security systems—namely, our inability to avoid
hype. Krebs' article includes [xkcd 2347](https://xkcd.com/2347/), which of
course has also been going around in discussing log4shell. But whereas in
log4shell it's describing a real thing—a small project maintained by two people
that is one of the most widely used Java libraries had a massive exploit in
it—Krebs uses it in his Trojan Source writeup to describe a theoretical thing
that *didn't happen*, that such a hypothetical project *might* be exploited in
this way.

When alarmism becomes the default of our community standard bearers[^3], all
alarms start sounding the same. Log4Shell is a legitimately bad exploit, and
Krebs' only article mentioning it is the bizarrely titled ["Microsoft Patch
Tuesday, December 2021 Edition"](https://krebsonsecurity.com/2021/12/microsoft-patch-tuesday-december-2021-edition/).
It's a regular feature that Krebs acknowledges is "overshadowed" by log4shell.
Apparently, when the security exploit is scary, Krebs doesn't need to be the one
sounding the alarm?

[^1]: It's so obviously not novel that the mitigation for Rust was just ["we
  already protect against this exact thing, and have since the minute we started
  allowing Unicode identifiers"](https://blog.rust-lang.org/2021/11/01/cve-2021-42574.html#appendix-homoglyph-attacks)

[^2]: As it was, there were quite a few people pointing out that this was
  already known and had come up on GitHub in the past. If nothing else, the
  marketing drew attention to those issues, but practically, the idea that
  Unicode can be used to disguise the intent of something didn't surprise
  many.

[^3]: Regardless of your personal feelings on Krebs, he's definitely one of the
  most prolific security bloggers currently working. Bruce Schneier, another
  such person, briefly wrote about the vuln and linked to Krebs' post.
