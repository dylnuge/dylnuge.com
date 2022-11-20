+++
title = "Cascading Complexity and the Great Cold Boot"
publish = true
date = 2022-11-14
description = """A story about a cold, cold boot."""
+++

There's a lot of chatter going on about cold boots right now, and specifically
how hard it is to recover a complex system from multiple simultaneous failures.
I have a fun cold boot story sitting in my back pocket, and hey, maybe it helps
clarify *why* this problem is so difficult, so I thought I'd share it.

Note that everything here happened a decade ago. I'm pretty sure my memory is
inaccurate—I likely have forgotten certain things, and incorrectly mapped
problems I saw some other time onto other problems. Also all the "error
messages" and such are completely made up; while I'm relatively certain the
errors were *similar* to the ones I'm putting here, I definitely do not remember
the specific error messages.

It might make the most sense to take this as a *hypothetical* failure case. The
overall events happened, and the details are *real failures*. I have spent
some time in the here-and-now researching and confirming the way I remember
things makes sense.

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
a fun time. We had a bunch of servers and workstations which we referred to as
"the cluster," and since we were a student club, there wasn't any real rhyme or
reason to the services we maintained beyond "someone wanted it at some point."
Most of the servers weren't set up while I was a student there[^2], and some of
them were so old no one really knew what they did anymore.

At the same time, these were running services that students actively depended
on; this was *not* just a bunch of toy projects that no one really needed.
Plenty of students did their homework and lab work on our VMs or physical
workstations because they were conveniently located and easy to use. We ran AFS,
a distributed file system with a very complex permissions model that
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
  for our needs. The ACM network was independently managed through the CS
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

```bash
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
it. Authentication is a phenomenal example! Kerberos uses a "ticket" system
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

```bash
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
use network accounts with wheel privileges at all, so there are a few things I
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

```bash
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

Well, luckily we have at least one other system with local root where we *are*
on the network, so let's check out what's going on over there.

```bash
> ping -c4 192.168.1.17
PING 192.168.1.17 (192.168.1.17) 56(84) bytes of data.
64 bytes from 192.168.1.17 icmp_seq=1 ttl=63 time=0.71 ms
64 bytes from 192.168.1.17 icmp_seq=2 ttl=63 time=1.44 ms
64 bytes from 192.168.1.17 icmp_seq=3 ttl=63 time=1.10 ms
64 bytes from 192.168.1.17 icmp_seq=4 ttl=63 time=0.89 ms
```

OK, so there's *something* running on the IP that the NTP server is supposed to
get, and that something isn't the NTP server.[^15] But what is it?

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
  isn't guaranteed to hand out a lease with the IP address it's not supposed to
  use—even if there's an IP that should be reserved currently available, and
  even if there's a DHCP lease request, everything might still be fine.
[^15]: One nice property here is we didn't have boxes that blocked ICMP traffic
  on our network, so any system connected *would* respond to a ping. Probably.
  Getting a non-answer here wouldn't rule out that something was running there
  and just not replying to our ping for any number of reasons, but an answer
  tells us there's something there for sure.

### Server in a Haystack

Just because we know something is here doesn't mean we know *where* it is. We
have a couple dozen hosts running on this network, which isn't a ton; we can
manually check them (assuming we know the root passwords), but that clearly
isn't a scalable answer. So what are our other options?

First, we can try to ssh into the box by its IP address. Most of our systems ran
sshd, which would let us on the box remotely and allow us to query the hostname.
One issue here is that none of our servers allowed for SSH via password
authentication, though, and of course none of them supported root login over SSH
either. This rules out SSH since network accounts are already inaccessible;
everything will tell us connection refused without appropriate auth.

But we know what kinds of services we run in general, so we could use `nmap` (or
other tools) to try and query open ports on the box. Is it running a webserver
(ports 80 and 443)? A mail server (port 25)? Is it one of our AFS boxes (various
ports around 7000, with the exact port number actually IDing it down to the
service it's running)?

Logs! We can look at the logs on the DHCP server, which will tell us that
indeed, a computer requested a lease and got that IP address. That computer will
be identified by its MAC address in the logs, which is a six byte address that
identifies a network card.[^16] Unfortunately, that's not much more useful to us
than the IP address; we could look up the vendor of the network card using the
address (specifically the first three bytes, or OUI), and in our case that's
almost useful (we have so many different servers acquired over the year, and if
it says it's a Sun Microsystems card we have it dead to rights), but still not
much better than just manually checking.

We could also configure the DHCP server to reserve `192.168.1.17` and not lease
it out, but there's the issue of the server that already has it. We need to
either wait for that computer to refresh its lease or, more likely, reboot
everything again. And then, when it comes back up, it's possible *some other* IP
collision has happened; we know for sure we have dynamic hosts, and we don't
know what all the static IPs need to be.[^17]

I think we did some combination of all of this, narrowing down the options and
then ultimately just checking the boxes we did not rule out.

[^16]: We don't need the DHCP logs to get this information; we can just directly
    issue an ARP request, which asks the network to tell us who has the IP. But
    the same problems apply in using the info.
[^17]: Remember that we're still in recovery mode here; long term, this is a
    configuration change that absolutely should be made!

### Boot Loops

OK, OK, we're back online, for real this time. I think I'm skipping a few other
things, like messing with the switch configuration because some of the ports had
been turned off on it and we hadn't actually kept track of which ones things
were plugged into.[^18] Whatever, let's keep moving.

Now begins the excruciating process of going service by service and seeing what
fails to start, or gets caught in a boot loop—starting up, crashing, and
rebooting. More stuff wasn't running than was, and the reasons were all across
the board and just as complicated as any of the things I've described above.

One of the major problems we had *here* was that a lot of these services had
been set up by other people. We had to learn how they were configured and how
they worked as we fixed them.

I've kept you here for a while now, though, so I'll just cover a few of the fun
ones:
* Several VMs weren't booting, mostly Xen ones (the ESXi ones were newer and
  generally happy). In one case, a VM was booting with a Xen flag I did not
  recognize, so I went to the man page, and the man page had the words "TODO:
  what does this do?" I had never before realized a man page could fail me like
  that. I really wish I could find this, it was honestly hilarious.
* Puppet, our config orchestration service, had to come back up with everything
  else. This meant that plenty of boxes failed to pull their configs and fell
  back on defaults which were completely wrong.
* Our Windows systems had a whole separate host of problems, as did our Active
  Directory service. I did not understand this and two other admins did, so I
  didn't actually do any work on it and have no clue what they did, but based on
  their faces when it finally worked, some form of blood sacrifice was involved.
* One of the last services I got back up was our mail server, running Exim 4.
  I spent the wee hours of the morning learning how to configure Exim, and
  promptly dumped the information out of my memory.[^19]

And that, dear reader, is the full-ish story of how I ultimately found myself
with a small crowd of admins in a Perkins at 3 AM in the midst of a decent
snowstorm. Coffee never tasted better.

[^18]: Later on I will make the argument that real data centers are generally
    *more* complicated than our setup here, but when it comes to cable
    management, there is nothing like the mess of a well-loved hackerspace
    server rack. Google has color coded cooling pipes; we had a label maker that
    had been helpfully used to label things "Keyboard," "Mouse," and "Not a
    Printer."
[^19]: This is a lie. We did it again a few months later, when the university
    decided to migrate everything from uiuc.edu to illinois.edu. Or maybe that
    was a few months before all this, and my memory is spotty.

## OK, Dylan, but this is The Real World™

Right. I described a handful of different ways things can go wrong, but to be
honest, I haven't talked about how *right* things went. It's natural to assume
that "real" systems are far more robust than ours, and it's also correct! The
problem is they're also far more complex, and designing for cold boot gets way
harder.

Absolutely nothing in the ACM cluster was designed to scale up or down. The
servers we had were what we had. When VMs are dynamically spun up and down based
on load, you have a huge number of additional things to keep track of:
* There is something responsible for orchestrating this: deciding how many VMs
  to start and when to terminate them. Hope the initial configs can actually
  handle the traffic surge from a previously dead host coming back online.
* There is a service discovery system which allows servers to figure out where
  other servers they need to talk to are, which is far more complex than
  hardcoded hostnames.
* There's DNS, which needs to map hostnames and IPs correctly, often with VMs
  having dynamic hostnames and addresses.
* Consensus algorithms. I don't know enough about consensus to really say how
  it's going to fail on a cold-booting data center specifically, but I do know
  enough to say you will need an *expert* on hand.
* Generally, there is more than one switch and more than one router. The
  complexity of what can happen on a large network (broadcast storms, bad BGP
  announcements, bad firewall configs, bandwidth saturation from initial startup
  traffic bursts) seriously makes our network look like nothing.

Now the people working on this (software engineers, site reliability engineers,
data center operations, etc) are all very experienced in their domains. They are
going to understand exactly how parts of their system fail, in ways that I can't
even begin to anticipate. And *those people* have said that cold boots are
nightmare scenarios they can't even begin to imagine.

We build software complexity on top of existing services. We imagine if some of
them go down but never if *all of them* go down, all at once, because that is
very hard to imagine. This is especially true at the lower levels of the
networking stack: the physical cables must be assumed to exist. The ability to
route traffic to other computers (and to know which computers to send it to)
must be assumed to exist. When the Facebook outage happened, I talked to a lot
of brilliant engineers who had never worked with BGP before and had no idea just
how catastrophic failures at this layer could be.

Big companies also have *security* on a scale ACM very much didn't. There almost
certainly aren't sysadmins at big companies who have memorized root passwords to
server rack head nodes. Physical access isn't a bike ride away from engineer's
off-campus apartment, and badging isn't done on some independent system. If the
systems which ensure people are who they say they are can't come back, access
might be gone *permanently*.

Incident management is going to be a mess overall too. When big issues like this
happen normally, there are systems for people to communicate. You put someone in
charge of just coordinating the thing, and rotate them regularly (with clear
handoffs). Having everyone jump in at once with ideas is a mess, and you need
ways to handle that. The systems you use for that are all probably down though.

There's a human cost to incident management too. The people who know what they
are doing are going to immediately be energized and excited; it's a natural
stress reaction, and in my experience it's particularly pronounced among anyone
who chooses to do ops work on purpose. But you're looking at a multi-day outage
at least, and if you don't start managing sleep schedules, that's going to lead
to some real mistakes being made as people start getting exhausted.

Oh, and people will quit. Like seriously, the worse it is, the more likely
someone breaks down, gives up, and walks out. If one person does it, others
will follow. Are you giving out bonuses to keep people around? Do you have the
money to do that? Is your payroll system even working?

Let's say you get it all back online—and you will, most likely, eventually, it
was "done once before" more or less, it will be figured out, though it might
take a few days or weeks.[^20] Now what? Cold start load is going to look
entirely different from anything that came before it. Nothing is in cache.
Nothing.[^21] The traffic loads will be *weird*. They won't look like the site
does under high traffic normally, and the ways they don't are likely ways no one
ever built for.

How long were you down for? A week? A month? There are serious business
implications here. You've lost users, and probably a lot of them. People who
made your site part of their daily routine found something else to fill that in.
You have clients you certainly owe money to in some form or another
(advertisers, subscribers, those sort of folk).

None of this is definitely the end of a business, but all of it is pretty
catastrophic. At the very least, there's going to be a hell of a postmortem.

[^20]: Or the company will go bankrupt first. These are essentially the two
  options.
[^21]: OK, you could be pre-populating caches on startup, that's a thing, but
  then you're still experiencing the problem when those caches try to all
  pre-populate at once, and I doubt every single service is doing this, just
  the ones where it makes sense under normal operating circumstances.

## So What?

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
certainly exceptions; cases where turning something off will *help* figure out
what it does. After all, I learned far more from moving the servers upstairs
than I ever would have from leaving them all alone.

Suffice it to say, I'm not all-in on the idea of "just shut down all the
non-critical microservices and see what happens." It certainly seems like a wild
idea when you've lost the vast majority of the staff who understood these
systems in the first place.

[^40]: There are still ways in a "real" system to have an equivalent of root
  passwords that people have memorized; for instance, you could have a handful
  of authorized users who use personally known passwords to secure system access
  tokens with something like Shamir's Secret Sharing. This is how Vault works,
  and I have in fact worked at a company where there were a handful of us with
  the tokens to unseal core infrastructure secrets. In this case, a single
  compromised account can't do anything; you'd need several.
