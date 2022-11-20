+++
title = "Cascading Complexity and the Great Cold Boot"
publish = true
date = 2022-11-14
description = """A story about cold booting"""
+++

There's a lot of chatter going on about cold boots right now, and specifically
how hard it is to recover a complex system from multiple simultaneous failures.
I have a fun cold boot story sitting in my back pocket, and hey, maybe it helps
clarify *why* this problem is so difficult, so I thought I'd share it.

Note that everything here happened a decade ago. I'm pretty sure my memory is
inaccurate—I likely have forgotten certain things, and incorrectly mapped
problems I saw some other time onto other problems. If anyone else who was there
is reading this and has corrections, I welcome them!

Also all the "error messages" and such are completely made up; while I'm
relatively certain the errors were *similar* to the ones I'm putting here, I
definitely do not remember the specific error messages.

## The Great Server Migration

In college, I was a sysadmin for our ACM chapter. Our ACM was complex; it was a
student club, it was a social group, and it was a collection of a couple dozen
other smaller clubs which we *nominally* called SIGs (Special Interest Groups)
but which often had no parallel to the actual ACM SIGs. Functionally, it was a
student hackerspace, where people gathered to work on projects, chat about
school, study for exams, prep for interviews, discuss their career plans, and
host impromptu dance parties. It was an incredible organization.

As you might imagine, sysadmin was a weird "job" to have in an organization like
that. It was fully voluntary; the people who did it were there because we wanted
to be, because the idea of rebooting servers and handling user requests for
additional storage space and fixing problems with printers[^1] were our idea of
a fun time. Since we were a student club, there wasn't any real rhyme or reason
to the services we maintained beyond "someone wanted it at some point." Most of
the servers weren't set up while I was a student there[^2], and some of them
were so old no one really knew what they did anymore.

At the same time, these were running services that students actively depended
on; this was *not* just a bunch of toy projects that no one really needed.
Plenty of students did their homework and lab work on our VMs or physical
workstations because they were convienently located and easy to use. We ran AFS,
a distributed file system with a very complex permissioning model that
technically connected to a ton of *other* universities, and students were
storing plenty of work there. We held an annual conference that brought in
pretty amazing speakers and had a full-on career fair and the website was hosted
on our servers. More than once, we had to scale to handle Reddit spikes in
traffic from a student project that had gained traction. We even hosted email,
though by my time this was mostly just used as forwarding aliases for people's
personal Gmail accounts.

My junior year (2012 or 2013; I remember it was winter but have no idea what
semester it was), the university wanted us to move to a new server room. The
room that all our equipment was in was pretty large and they wanted to repurpose
that space for classroom lab equipment and move us to a smaller space on another
floor. This all made perfect sense, but it presented us with a serious
challenge. It wasn't obvious what would happen if we turned everything off and
then back on at once.[^3]

Around 6:00 PM on a Friday night we began the work. All dozen or so of the
admins and showed up. Within an hour, we'd moved the equipment and failed to
reboot even a single service. At 3 AM, me and the few other people who had stuck
around through the worst of it were sitting at the 24/7 diner, drinking coffee
and discussing what we were going to do if we couldn't get the remaining
services up. Somehow, we were optimistic. It was just computers, we were
computer geeks, we could figure this out.

By 7 AM on Saturday morning, everything was back.[^4] I can't say that this was
the longest, most stressful, or most intense computer operation I've ever been
involved in, but it was definitely the first. It wasn't helped along by the fact
that I was the "head" admin, ostensibly the person who knew the systems
best.[^5] At the end of it all, I'd learned a lot, but I'd especially learned
two things that were very important to me: systems often have a plethora of
complex and unclear dependencies on each other, and I actually find unravelling
that sort of thing fun.[^6]

[^1]: OK, no one found the printers part of it fun.
[^2]: We did set up two very nice new servers that were donated to us while I
  was there, which virtualized a bunch of different services (including two
  virtual workstations for ACM members to use) and ran ESXi. We also ran Xen on
  a few other boxes, and some boxes weren't using any form of virtualization at
  all. There was a Solaris system. There was a USENET news server. There were
  probably a few systems I never learned about even *during* this whole mess,
  just because they managed to come back online without any issues.
[^3]: There were also physical challenges, since our rack wasn't exactly well
  organized from a cable management perspective. That said our switching setup
  wasn't *incredibly* complex and mostly consisted of a single rack switch. All
  the servers "fit" in one rack, with a KVM setup next to it to allow physical
  login into any box. Both rooms were secured with an extremely limited access
  list and both were in the same (secured) building, so we didn't have to worry
  about security while moving what amounted to a small fortune worth of
  computers. Both rooms had appropriate power, networking, and HVAC requirements
  for our needs. The ACM network was independently managaed through the CS
  department's network administration tooling. The rooms were on different
  floors but both were very near the freight elevator (the rack itself was
  overweight for the passenger elevator). There was plenty of abandoned junk in
  the old room and we had to decide what to move/save and what to recycle and
  then follow university procedures for proper electronics recycling. I am
  probably missing stuff, but this isn't the point of the post; I just want to
  illustrate how *much* can go into even a very simple move of a small student
  organization's weird hodgepodge of computers.
[^4]: Or at least, anything that wasn't back wasn't noticed as missing.
[^5]: This was a nominal position really, and the entire thing would have been
  impossible if not for several other admins who *really* understood parts of
  the system I did not. Most notably, I knew nothing about Windows or Active
  Directory, and, as you'll see, that became very important.
[^6]: This is most likely a form of brain damage, but it is also one that's
  worked out pretty well for me.

### Logging In

Let's start simple: what happens when you log into a computer? The vast majority
of the ACM services were running on Linux (Debian Squeeze, primarily) and
running under user accounts on those machines. So if something was wrong, the
first step was probably to log into the computer and take a look.

Broadly speaking there are two types of user accounts, and they're pretty
different:
* Local accounts are what you work with on your personal devices, most likely.
  All the information on the account—username, password hash, login shell, home
  directory, etc—is stored on the device itself.
* Network accounts are magic; they're what you probably use on your work or
  school computers, and they allow you to use the same account *everywhere*
  across a network, no matter what computer you sit down at. Magic!

OK, network accounts aren't exactly magic, but when you're working with
networked login and it Just Works™ it's easy to forget just how complex the
process is compared to a local login. The computer needs to go talk to an auth
server to determine if you've provided valid credentials, then it needs to
forward those credentials to the network file service to mount your home
directory, and it needs to locally map all your preferences, and it might
support logging in across different *operating systems* so those preferences can
get confusing.[^7] And it does all that so fast you don't even really
notice.[^8]

Our login service setup was appropriately confusing:
* We used Kerberos for authentication on most systems, as well as for Linux and
  OSX group membership (but not Windows!).
* We had an LDAP/Active Directory service set up for Windows setting storage,
  but it did not do primary auth; Kerberos still fronted it.
* The University also maintained an LDAP system for login; because we used the
  same usernames and our users were by university rules all affiliated with the
  university, we queried this for lots of information, but your *university*
  password was not the same as your *ACM* password (which we confusingly called
  LDAP password and Kerberos password, even though this wasn't universally
  right).
* As mentioned earlier, we used AFS as a file system; AFS has a service called
  PTS (the "protection service") which was an important *authorization* system;
  PTS membership was used to determine a whole host of things about users.

And it was *even more* complicated than that sounds, because this makes each of
those seem like a single box on a diagram when in fact none of them were: we had
two Kerberos servers which talked to each other, two PTS servers which talked to
each other and the other 5 AFS servers, and only the single LDAP server but it
was peered with the university LDAP which was mountains more complex than our
entire setup.

Maybe we didn't start simple after all. Our computers are booting back up, so
let's see; can we log in to my account?

```
krb5: Clock skew too great while getting initial ticket.
```

Cool. We're off to a good start.

[^7]: For instance, I had xmonad configured as my desktop environment when I was
  in ACM, for some contrarian reason. I *could* be sitting down at a workstation
  without xmonad even installed, since most Linux users used Gnome or KDE, and
  in that case the system would fall back on Gnome. And I could be logging in on
  Windows or OSX instead, or logging into a headless workstation via SSH, or any
  other number of ways to start sessions.
[^8]: When I was younger, one of the ways you could notice this was that the
  desktop background would often initially show a default one and then flicker
  and change into your personally configured choice.

### Does Anyone Really Know What Time It Is?

Time is likely the most evil concept humans have come up with; it is at the very
least responsible for more misery than any other basic piece of physics I can
think of. Gravity prevents me from flying, time makes me aware that tomorrow I
will be older, that I cannot stay in this moment forever, that eventually
everything I care about will be gone. It is the worst.

If you ask a computer what time it is it will probably tell you any number of
things: the actual current time, the current time in some other timezone than
the one you're in, an incomprehensible number like `133129336870000000`[^9], or,
more often than any person would ever want, "January 1, 1970, 00:00 UTC."

It is not, of course, 1970. I am pretty sure of this for many reasons; I was
born twenty years after that date, for starters, and I am far too dumb to invent
a time machine, even by accident. Unix systems begin counting time from Jan 1,
1970 (generally speaking), however, and if they lose track of time for any
reason, this is often where they wind up.

Time is very *important* though, and computers often have real reasons to know
it. Authentication is a phenominal example! Kerberos uses a "ticket" system
where you request a ticket for your user account; that ticket is signed by the
server and has a timeout on it, in order to prevent that ticket from being
compromised and reused. Normally your client will keep requesting a new one when
it's close to expiring, you'll never notice, and meanwhile you can show the
ticket to other services to show you're authenticated.

Of course, if your computer thinks it's 9:00 on a Saturday and the kerberos
server thinks it's midnight on Jan 1, 1970, you can't get a ticket that works
for you; the same problem exists if they're off in the other direction, or even
if they're close but off by a few *minutes*. And even if you can get a ticket,
if other services don't have the right time, they might look at it and reject it
for being outside of their time. In any server configuration, keeping time in
sync is very important.

NTP (Network Time Protocol) is a system that's designed to handle this problem;
computers ask a central service what time it is, they get an answer, they update
their own clocks. It allows for extraordinary precision, but at the level we're
working, we only really care about being within a few milliseconds of the right
time. "Only," I say, as if millisecond-level resolution is easy.

Now of course, we're running our own NTP server here[^10]; I say of course
because this is a student organization for a bunch of computer nerds, there's
literally no *real* reason for us to be doing this when the university already
runs an NTP service for us. And of course that server didn't come up properly,
so we need to start there. So let's switch our KVM over to that box and...

```
Debian GNU/Linux 10 tty1
login:
```

...Oh. Crap.

[^9]: Yes that's a real time, no it's not a Unix epoch based time. It's actually
  the Windows NT time format, which counts in microseconds since Jan 1, 1601. If
  you're wondering how the switch from the Julian to the Gregorian calendar
  plays into that, it doesn't! Time is misery.

[^10]: I wanna say it was stratum 3, if that's the kind of detail you care
  about; IIRC it synced directly with ntp.illinois.edu, which is stratum 2.

### Passwords? Passwords!

Remember that we can't log into anything. My normal method of access is pretty
standard; I'd log in using my own (network) account, and use `sudo` or similar
to access whatever I needed to. But my own account is a network account, and
network accounts are inaccessible, so there's no way that's working.

This is where we get lucky, and specifically we get lucky by being *insecure*,
this is something that is clearly not best practices, no "real" organization
would work this way (I hope). Most of our servers have root passwords.

In fact, we get doubly lucky here. SSH isn't supported on the root accounts (you
have to be physically at the box to use them), but several of our systems don't
use network accounts with wheel privilages at all, so there are a few things I
still needed to occasionally log in by hand for, and I had a few of the root
passwords memorized, including the ones used by the kerberos servers and the NTP
server.

That stroke of luck is essential because we *store* the root passwords in an
encrypted[^11] file on our network file storage which no one can access and
which, even if we could, no one could authenticate to an account that was
allowed to read the directories in question anyways. Had none of us known the
passwords by heart, this story might have stalled out here. Losing your login
systems is pretty difficult, and there's a *lot* that can go wrong.

Thankfully, it wasn't hard to get into the NTP server, and it was quite happy to
tell us our next major issue:

```
dhcpd: no free leases
```

Looks like we're not online at all.

[^11]: "Encrypted" in two senses here: the strong sense, where the AFS volumes
  themselves are encrypted at rest and only users with the right permissions can
  read them, but also a weird weak sense, where the file is encrypted with a key
  that sits in the same directory, alongside a perl script which decrypts the
  file and runs it through grep so that you can access a single password instead
  of dumping all of them to your screen at once. Like I said, I hope no real
  organization works this way.

### Gimme, Gimme, Gimme (An IP after Midnight)

Generally speaking, if we're dealing with servers we're dealing with computers
that are all networked together. Every computer on the network needs an IP
address, which is used to route traffic to it (both from within the local
network and from other networks on the internet).[^12]

Usually we don't refer to computers by their IP addresses but by names, like
`ntp.acm.uiuc.edu`, which in turn get translated into IP addresses by DNS. For
DNS to work it needs to know where `ntp.acm.uiuc.edu` actually is. The simplest
way to handle this is to use static IP addresses; to tell `ntp.acm.uiuc.edu`
that it's always at the exact same IP address, say, `192.168.1.17`.[^13]

Static IPs aren't always needed though, and would be annoying for something like
a home network, where every single device you connect would need to be assigned
a unique number by hand. DHCP (Dynamic Host Configuration Protocol) is a system
that can assign IP addresses automatically, based on what's available. It's also
very useful for connecting new systems to the network, since they can
immediately talk to the network—on a small network with mostly static IPs, you
can use this to connect a new computer, see what IP it gets assigned, and then
reconfigure it to always take that IP.

IP space isn't particularly organized on this network. It does have a DHCP
server, but most boxes are using static IP addresses. Of course, "most" doesn't
mean "all," and in this case, DHCP was configured to assign any available IP
address, and not told which IPs were reserved for static boxes.

Normally that's fine; the static IP is still on the network and known to the
router, so the DHCP service won't assign to it. But if that box goes offline,
it's IP address becomes "available," even though the box expects it when it
comes back. Shut everything down at once and turn it all back on and you
essentially have a race condition—will the static box get its IP before DHCP
hands it out?[^14]

In this case the answer was no.


[^12]: A full explanation of routing is definitely way out of scope of this
  already rambling post, but for footnote readers, almost all of the ACM
  computers had public space IPv4 addresses as well as private ones, if I recall
  correctly. One of the advantages of being a student club at a large university
  is that UIUC's IP space was massive, and we weren't ever really constrained by
  address exhaustion.
[^13]: I am using private space IPs for example's sake; the real boxes
  definitely had publicly-routable IP addresses. It should probably be obvious,
  but I don't remember the real IPs here either. Also, either the UIUC ACM is no
  longer running their own NTP service, or I'm wrong here and the NTP/time
  issues were independent from the dhcp issues, because there's nothing there
  anymore.
[^14]: It's pretty subtle when dealing with "normal" failures, because DHCP
  isn't guarenteed to hand out a lease with the IP address it's not supposed to
  use—even if there's an IP that should be reserved currently available, and
  even if there's a DHCP lease request, everything might still be fine.


## Why Tell This Story?

Cascading failures can make recovery incredibly difficult. I think it's pretty
tempting sometimes to turn everything off and see what breaks, but coming back
from it can be way harder than people anticipate—it is *often* harder to turn
something back on than it is to shut it down. New services are built with an
assumption that their dependencies will always exist and be available, or that
the fallbacks will be there if not; and that's only accounting for the known
dependencies. Failures like this are why a bad BGP route announcement can
physically lock people out of server rooms.

Cold boots—bringing the *entire* system back from a down state—aren't common in
software. Most people assume that the very complicated systems run by big
engineering companies are much better at this than the average system run by a
bunch of volunteer students, but the reality in my experience has been that
these more complex systems tend to have even *more* complicated paths for cold
booting; the DNS and auth of a whole data center is much more complex than our
simple setup was, and the security certainly is too.[^40]

There's a concept that's popular in software engineering (or at least, in a lot
of the circles I've inhabited) called Chesterton's fence. It comes from a story
about a person who sees an open fence and closes it, not knowing why it was left
open; the sheep who needed to pass through the fence are subsequently locked
out. Basically it says "if you don't know why something exists, you shouldn't
get rid of it until you do."

I don't think that should be followed as a hard and fast rule. There are quite
certianly exceptions; cases where turning something off will *help* figure out
what it does. After all, I learned far more from moving the servers upstairs
than I ever would have from leaving them all alone.

Suffice it to say, I'm not all-in on the idea of "just shut down all the
non-critical microservices and see what happens." It certianly seems like a wild
idea when you've lost the vast majority of the staff who understood these
systems in the first place.

[^40]: There are still ways in a "real" system to have an equivilent of root
  passwords that people have memorized; for instance, you could have a handful
  of authorized users who use personally known passwords to secure system access
  tokens with something like Shamir's Secret Sharing. This is how Vault works,
  and I have in fact worked at a company where there were a handful of us with
  the tokens to unseal core infrastructure secrets. In this case, a single
  compromised account can't do anything; you'd need several.
