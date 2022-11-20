+++
title = "Cascading Complexity and the Cold, Cold Boot"
publish = true
date = 2022-11-22
description = """Warning: resetting this system can have unexpected results."""
+++

There's a lot of chatter going on about how hard it is to recover a complex
system from multiple simultaneous failures (and why). One particular scenario
that's come up a few times on my feeds is the *cold boot*: bringing a system
back from total shutdown. This isn't a common thing we do when running modern
distributed systems. I've never seen it or even heard of it happening in my
professional career at any company with decent scale.

But I've done it once, at a much smaller and more hectic type of organization,
and since I have a fun cold boot story sitting in my back pocket, I thought I'd
share it. Maybe it helps clarify *why* this problem is so difficult, just a
little bit.

Everything here happened a decade ago. My memory is fallible—I likely have
forgotten certain things, and incorrectly mapped problems I saw some other time
onto problems that happened that night. Also all the "error messages" and such
are completely made up; while I'm relatively certain the errors were *similar*
to the ones I'm putting here, I definitely do not remember the specific error
messages.

It might make the most sense to read this as a *hypothetical* failure case. The
overall events happened, and the details describe *real failures*. I have spent
time in the here-and-now researching and confirming the way I remember things
makes sense; all of these failures can and do happen. Still, chances are this
suffers from all the usual issues of oral histories from an event long past.
Hopefully it makes for a good story, though.

## The Great Server Migration

In college, I was a sysadmin for our [ACM chapter][uiuc-acm]. Our ACM was a lot
of things: it was a student club, it was a social group, and it was a collection
of a couple dozen other smaller clubs which we *nominally* called SIGs (Special
Interest Groups) but which often had no parallel to the actual ACM SIGs.
Functionally, it was a student hackerspace, where people gathered to work on
projects, chat about school, study for exams, prep for interviews, discuss their
career plans, and host impromptu dance parties. It was an incredible
organization.

As you might imagine, sysadmin was a weird "job" to have in an organization like
that. It was fully voluntary; the people who did it were there because we wanted
to be, because rebooting servers and handling user requests for additional
storage space and fixing problems with printers[^1] was our idea of a fun time.
We had a bunch of servers and workstations which we referred to as "the
cluster." Since we were a student club, there wasn't any real rhyme or reason to
the services we maintained beyond "someone wanted it at some point." Most of the
servers weren't set up while I was a student there[^2], and some of them were so
old no one really knew what they did anymore.

At the same time, these were running services that students actively depended
on; this was *not* just a bunch of toy projects that no one really needed.
Plenty of students did their homework and lab work on our VMs or physical
workstations because they were conveniently located and easy to use. We ran AFS,
a distributed file system with a complex permissions model that connected to a
ton of *other* universities, and students were storing plenty of work there. We
had a vending machine we'd gutted and connected to a swipe card reader and
students could use their ACM accounts to buy very cheap soda (this is an
essential service). We held an annual conference that brought in pretty amazing
speakers and had a full-on career fair; the website was hosted on our servers.
One time a student-hosted toy project went viral on Reddit and we had to handle
an unprecedented amount of load to a tiny server. Our cluster was very real; we
had users, they cared that things worked.

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
  the servers "fit" in one rack. Both rooms were secured with an extremely
  limited access list and both were in the same (secured) building, so we didn't
  have to worry about security while moving what amounted to a small fortune
  worth of computers. Both rooms had appropriate power, networking, and HVAC
  requirements for our needs. The ACM network was independently managed through
  the CS department's network administration tooling. The rooms were on
  different floors but both were very near the freight elevator (the rack itself
  was overweight for the passenger elevator). There was plenty of abandoned junk
  in the old room and we had to decide what to move/save and what to recycle and
  then follow university procedures for proper electronics recycling (my request
  to "Office Space" an old printer was sadly denied). I am probably missing
  stuff, but this isn't the point of the post; I just want to illustrate how
  *much* can go into even a very simple move of a small student organization's
  weird hodgepodge of computers.
[^4]: Or at least, anything that wasn't back wasn't missed.
[^5]: This was a nominal position really, and the entire thing would have been
  impossible if not for several other admins who *really* understood parts of
  the system I did not. Most notably, I knew nothing about Windows or Active
  Directory, and, as you'll see, that became very important.
[^6]: This is most likely a form of brain damage, but it is also one that's
  worked out pretty well for me.

[uiuc-acm]: https://acm.illinois.edu/

### Logging In

Let's start simple: what happens when you log into a computer? If something is
broken or not starting up, this is usually the first step—log in and check logs,
see what's going on, test all the things you think might be the issue.

Broadly speaking there are two types of user accounts, and they're pretty
different:
* Local accounts are what you work with on your personal devices, most likely.
  All the information on the account—username, password hash, login shell, home
  directory, etc—is stored on the device itself.
* Network accounts are magic; they're what you probably use on your work or
  school computers (at least partially), and they allow you to use the same
  account *everywhere* across a network, no matter what computer you sit down
  at. Magic!

OK, network accounts aren't exactly magic, but when you're working with
networked login and it Just Works™ it's easy to forget just how complex the
process is compared to a local login. The computer needs to go talk to an
authentication server to determine if you've provided valid credentials, then it
needs to forward those credentials to the network file service to mount your
home directory, and it needs to locally map all your preferences, and it might
support logging in across different *operating systems* so those preferences can
get confusing.[^7] And it does all that so fast you don't even really
notice.[^8]

Our login service setup was appropriately confusing:
* We used [Kerberos][krb] for authentication on most systems, as well as for
  Linux and OSX group membership (but not Windows!).
* We had an [LDAP/Active Directory][ldap] service set up for Windows setting
  storage, but it did not do primary auth; Kerberos still fronted it.
* The University also maintained an LDAP system for login; because we used the
  same usernames and our users were by university rules all affiliated with the
  university, we queried this for lots of information, but your *university*
  password was not the same as your *ACM* password (we tended to refer to these
  as your LDAP password and Kerberos password, even though this wasn't
  universally right).
* As mentioned earlier, we used [AFS][afs] as a file system; AFS has a service
  called PTS (the "protection service") which was an important *authorization*
  system; PTS membership was used to determine a whole host of things about
  users. You can think of them like user groups on a Unix-based system, and they
  are, but they're coming from an independent service.

Those weren't just individual boxes either: we had two Kerberos servers which
talked to each other (and needed to be in sync), two PTS servers which talked to
each other and the other 5 AFS servers (all of which needed to be in sync), and
only the single LDAP server but it was peered with the university LDAP which was
mountains more complex than our entire setup.

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
[^8]: Or barely notice; sometimes your desktop background will show a default
  one and then flicker and change into your personally configured choice.

### Does Anyone Really Know What Time It Is?

Time is likely the most evil concept humans have come up with; it is at the very
least responsible for more misery than any other basic piece of physics I can
think of. Gravity prevents me from flying, time makes me aware that tomorrow I
will be older, that I cannot stay in this moment forever, that eventually
everything I care about will be gone. It is the worst.

If you ask a computer what time it is it will probably tell you any number of
things: the actual current time, the current time in some other timezone than
the one you're in, an incomprehensible number like `133129336870000000`,[^9] or,
more often than any person would ever want, something like "January 1, 1970,
00:03 UTC."

It is not 1970. I am pretty sure of this for many reasons; I was born twenty
years after that date, for starters, and I am far too dumb to invent a time
machine, even by accident. Unix systems begin counting time from Jan 1, 1970
(generally speaking), however, and if they lose track of time for any reason,
this is often where they wind up.

Time may be annoying, but it's also important, and computers often have a real
need to know it. Authentication is a phenomenal example! Kerberos uses a
"ticket" system where you request a ticket for your user account; that ticket is
signed by the server and has a timeout on it, in order to prevent that ticket
from being compromised and reused. Normally your client will keep requesting a
new one when it's close to expiring, you'll never notice, and meanwhile you can
show the ticket to other services to show you're authenticated.

Of course, if your computer thinks it's 9:00 on a Saturday and the kerberos
server thinks it's midnight on Jan 1, 1970, you can't get a ticket that works
for you; the same problem exists if they're off in the other direction, or even
if they're close but off by a few *minutes*. And even if you can get a ticket,
if other services don't have the right time, they might look at it and reject it
for being outside of their time. In any server configuration, keeping time in
sync is very important.

NTP (Network Time Protocol) is designed to handle this problem; computers ask a
central service what time it is, they get an answer, they update their own
clocks. It allows for extraordinary precision, but at the level we're working,
we can be off by hundreds of milliseconds without really having any issues.

Now of course, we're running our own NTP server here[^10]—I say of course
because this is a student organization for a bunch of computer nerds, there's
literally no *real* reason for us to be doing this when the university already
runs an NTP service for us. And of course that server didn't come up properly,
so we need to start there. So let's switch our KVM[^11] over to that box and...

```bash
Debian GNU/Linux 6.0 debian squeeze tty1
login:
```

...Oh. Right. Crap.

[^9]: Yes that's a real time, no it's not a Unix epoch based time. It's actually
  the Windows NT time format, which counts in microseconds since Jan 1, 1601. If
  you're wondering how the switch from the Julian to the Gregorian calendar
  plays into that, it doesn't! Time is misery.
[^10]: I wanna say it was stratum 3, if that's the kind of detail you care
  about; IIRC it synced directly with ntp.illinois.edu, which is stratum 2. That
  said, the UIUC ACM is no longer running an NTP service, and maybe they never
  were and another system was down that night and I'm misremembering why the
  times were misconfigured too.
[^11]: KVM in this case stands for "Keyboard, Video, and Mouse" and is a console
  that has a monitor and keyboard plugged into it and lets you physically
  switch them between different boxes in the rack.

### Passwords? Passwords!

Remember that we can't log into anything. My normal method of access is pretty
standard; I'd log in using my own (network) account, and use `sudo` or similar
to access whatever I needed to. But my own account is a network account, and
network accounts are inaccessible, so there's no way that's working.

This is where we get lucky, and specifically we get lucky by being *insecure*.
This is something that is clearly not best practices. No "real" organization
would work this way (I hope). Most of our servers have known root passwords.

In fact, we get doubly lucky here. SSH isn't supported on the root accounts (you
have to be physically at the box to use them), but several of our systems don't
use network accounts with wheel privileges at all, so there are a few things I
still needed to occasionally log in by hand for, and I had a few of the root
passwords memorized, including the ones used by the kerberos servers and the NTP
server (in fact, most admins had root passwords memorized, simply by virtue of
using them a *lot*).

That stroke of luck is essential because we *store* the root passwords in an
encrypted[^12] file on our network file storage which no one can access right
now (our authentication *and* our file storage systems are both offline).
Had we been working on a system where you rarely if ever needed to use root
passwords, this story might have stalled out here. Losing your login systems is
pretty difficult, and there's a *lot* that can go wrong.

Thankfully, it wasn't hard to get into the NTP server, and it was quite happy to
tell us our next major issue:

```bash
connect: network is unreachable
```

Looks like we're not online at all.

[^12]: "Encrypted" in two senses here: the strong sense, where the AFS volumes
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
network and from other networks on the internet).[^13]

Usually we don't refer to computers by their IP addresses but by names, like
`ntp.acm.uiuc.edu`, which in turn get translated into IP addresses by DNS. For
DNS to work it needs to know where `ntp.acm.uiuc.edu` actually is. The simplest
way to handle this is to use static IP addresses; to tell `ntp.acm.uiuc.edu`
that it's always at the exact same IP address, say, `192.168.1.17`.[^14]

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
hands it out?[^15]

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
get, and that something isn't the NTP server.[^16] But what is it?

[^13]: A full explanation of routing is definitely way out of scope of this
  already rambling post, but for footnote readers, almost all of the ACM
  computers had public space IPv4 addresses as well as private ones, if I recall
  correctly. One of the advantages of being a student club at a large university
  is that UIUC's IP space was massive, and we weren't ever really constrained by
  address exhaustion.
[^14]: I am using private space IPs for example's sake; the real boxes
  definitely had publicly-routable IP addresses. It should probably be obvious,
  but I don't remember the real IPs here either. Also, either the UIUC ACM is no
  longer running their own NTP service, or I'm wrong here and the NTP/time
  issues were independent from the dhcp issues, because there's nothing there
  anymore.
[^15]: It's pretty subtle when dealing with "normal" failures, because DHCP
  isn't guaranteed to hand out a lease with the IP address it's not supposed to
  use—even if there's an IP that should be reserved currently available, and
  even if there's a DHCP lease request, everything might still be fine.
[^16]: One nice property here is we didn't have boxes that blocked ICMP traffic
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
None of our servers allowed for SSH via password authentication, though, and 
none of them allow root login over SSH. This rules out SSH since network
accounts are already inaccessible; everything will tell us connection refused
without appropriate auth.

But we know what kinds of services we run in general, so we could use `nmap` (or
other tools) to try and query open ports on the box. Is it running a webserver
(ports 80 and 443)? A mail server (port 25)? Is it one of our AFS boxes (various
ports around 7000, with the exact port number actually IDing it down to the
service it's running)?

What about logs? We can look at the logs on the DHCP server, which will tell us
that indeed, a computer requested a lease and got that IP address. That computer
will be identified by its MAC address in the logs, which is a six byte address
that identifies a network card.[^17] Unfortunately, that's not much more useful
to us than the IP address; we could look up the vendor of the network card using
the address (specifically the first three bytes, or OUI), and in our case that's
almost useful (we have so many different servers acquired over the years, and if
it says it's a Sun Microsystems card we have it dead to rights), but still not
much better than just manually checking.

We could also configure the DHCP server to reserve `192.168.1.17` and not lease
it out, but there's the issue of the server that already has it. We need to
either wait for that computer to refresh its lease, force the server to drop the
lease in a hacky manner, or reconfigure it and reboot everything again. And
then, when it comes back up, it's possible *some other* IP collision has
happened; we know for sure we have dynamic hosts, and we don't know what all the
static IPs need to be.[^18]

I think we did some combination of all of this, narrowing down the options and
then ultimately just checking the boxes we did not rule out.

[^17]: We don't need the DHCP logs to get this information; we can just directly
    issue an ARP request, which asks the network to tell us who has the IP. But
    the same problems apply in using the info.
[^18]: Remember that we're still in recovery mode here; long term, this is a
    configuration change that absolutely should be made!

### Boot Loops

OK, OK, we're back online, for real this time. I'm skipping a few other things,
like messing with the switch configuration because some of the ports had been
turned off on it and we hadn't actually kept track of which ones things were
plugged into.[^19] The key thing to understand here is that we had lots of
cascading issues even getting every system back on the network—everything
depends on talking to other stuff, and things get messed up in ways they don't
during normal operation.

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
  generally well understood). In one case, a VM that wasn't booting was
  configured with a Xen flag I did not recognize, so I went to the [man
  page][man], and the man page had the words "TODO: what does this flag even
  do?" I had never before realized a man page could fail me like that. I really
  wish I could find this, it was honestly hilarious.
* [Puppet][puppet], our config orchestration service, had to come back up with
  everything else. This meant that plenty of boxes failed to pull their configs
  and fell back on defaults which were completely wrong. Some configs also had
  newly wrong information in them (like a hardcoded IP that was actually being
  assigned dynamically), so there were several hours of messing with configs.
* There was a drive in one of the AFS volume servers that had completely died;
  no data was lost, but we needed to swap the drive. This didn't cause other
  issues and might seem like "just bad timing," but a lot of electronic failures
  first present themselves on (re)boot.
* Our Windows systems had a whole separate host of problems, as did our Active
  Directory service. I did not understand this and two other admins did, so I
  didn't actually do any work on it and have no clue what they did, but based on
  their faces when it finally worked, some form of blood sacrifice was involved.
* One of the last services I got back up was our mail server, running
  [Exim 4][exim]. I spent the wee hours of the morning learning how to
  configure Exim, and promptly dumped the information out of my memory.[^20]

And that, dear reader, is the full-ish story of how I ultimately found myself
with a small crowd of admins in a [Perkins][perkins] at 3 AM in the midst of a
decent snowstorm. Coffee never tasted better.

[^19]: Later on I will make the argument that real data centers are generally
  *more* complicated than our setup here, but when it comes to cable
  management, there is nothing like the mess of a well-loved hackerspace server
  rack. Google has color coded cooling pipes; we had a label maker that had been
  helpfully used to label things "Keyboard," "Mouse," and "[Not a
  Typewriter][enotty]."
[^20]: This is a lie. We did it again a few months later, when the university
  decided to migrate everything from uiuc.edu to illinois.edu. Or maybe that was
  a few months before all this, and my memory is spotty.

[enotty]: https://en.wikipedia.org/wiki/Not_a_typewriter
[perkins]: https://en.wikipedia.org/wiki/Perkins_Restaurant_%26_Bakery
[man]: https://en.wikipedia.org/wiki/Man_page
[puppet]: https://en.wikipedia.org/wiki/Puppet_(software)
[exim]: https://en.wikipedia.org/wiki/Exim

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
very hard to design for. This is especially true at the lower levels of the
networking stack: the physical cables must be assumed to exist. The ability to
route traffic to other computers (and to know which computers to send it to)
must be assumed to exist. When the Facebook outage happened, I talked to a lot
of brilliant engineers who had never worked with BGP before and had no idea just
how catastrophic failures at this layer could be.

Big companies also have *security* on a scale ACM very much didn't. There almost
certainly aren't sysadmins at big companies who have memorized root passwords to
server rack head nodes. Physical access isn't a bike ride away from an
engineer's off-campus apartment, and badging isn't done on some independent
system. If the systems which ensure people are allowed to enter secure rooms
they need to enter don't come back, access might be gone *permanently*.

Some of the systems that need to be fixed won't be well understood. This is true
in any tech company—the industry average attrition rate is actually worse than
for a college student club, where people stick around for 3-5 years before
graduating—but usually there are also some people who have been around forever
and really know their stuff. Still, most engineers[^21] are going to rely on
things like documentation and code to understand the system during a normal
outage. Can they even access this stuff while everything is down?

Incident management is going to be a mess overall too. When big issues like this
happen normally, there are systems for people to communicate. You're going to
need a *lot* of experts on-hand, but having everyone jump in at once with ideas
is a mess, and those experts are distributed across the world. Tech companies
have systems for coordinating incidents and communicating through them, but
access to at least some of them is probably down.[^22]

There's a human cost to incident management. The people who know what they are
doing are going to immediately be energized and excited; it's a natural stress
reaction, and in my experience it's particularly pronounced among anyone who
chooses to do ops work on purpose. But you're looking at a multi-day outage at
least, and if you don't start managing sleep schedules, that's going to lead to
some real mistakes being made as people start getting exhausted.

Oh, and people will quit. Like seriously, the worse it is, the more likely
someone breaks down, gives up, and walks out. If one person does it, others
will follow. Are you giving out bonuses to keep people around? Do you have the
money to do that? Is your payroll system even working?

Let's say you get it all back online—and you will, most likely, eventually, it
was "done once before" more or less, it will be figured out, though it might
take a few days or weeks.[^23] Now what? Cold start load is going to look
entirely different from anything that came before it. Nothing is in cache.
Nothing.[^24] The traffic loads will be *weird*. They won't look like the site
does under high traffic normally, and the ways they don't are likely ways no one
ever planned for.

How long were you down for? Whether it's hours or months, there are serious
business implications here. You've lost users, and probably a lot of them.
People who made your site part of their daily routine found something else to
fill that in. You have clients you certainly owe money to in some form or
another (advertisers, subscribers, people under service contracts, and so on).

None of this is definitely the end of a business, but all of it is pretty
catastrophic. At the very least, there's going to be a hell of a postmortem.

[^21]: I'm using engineer here as a catch-all for anyone working on tech within
  the organization, including SREs, SWEs, data center operations folk, etc.
[^22]: Even if you're using third party applications like Slack and PagerDuty,
  they tend to be something you log into with your company user account.
[^23]: Or the company will go bankrupt first. These are essentially the two
  options.
[^24]: OK, you could be pre-populating caches on startup, that's a thing, but
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
simple setup was, and the security certainly is too.[^25]

The cold boot I described here is meant to illustrate how quickly a seemingly
"straightforward" concept can get complex when dealing with multiple
interweaving parts. Cold booting is not "turning it off and on again." It is far
closer to fully disassembling a car down to every individual screw and putting
it back together again.

The systems we build are generally designed to be resilient. They can handle a
drive failing, a network failing, even an entire data center failing. They are
designed to recover from these issues. When they cannot recover, people can
generally still fix it, and even update the system so that it can recover on its
own from that type of failure in the future. All the progress we've made is on
consistently adapting and improving our understanding of these failure modes. I
don't know any engineer who would attest that systems they work on cannot fail,
only that they *don't know* of any remaining major failure modes.

Without those people, every system is a ticking time bomb. Every single one. The
failures are slow at first. The system is complex and resilient, after all. It
was designed and updated by a lot of different people, each bringing their own
perspectives on what will work and what can break. But it is still just a bunch
of electronics built by humans, running software written by humans. Eventually,
without maintenance, it will fall down.

And that's terrible.

[^25]: There are still ways in a "real" system to have an equivalent of root
  passwords that people have memorized; for instance, you could have a handful
  of authorized users who use personally known passwords to secure system access
  tokens with something like Shamir's Secret Sharing. This is how Vault works,
  and I have in fact worked at a company where there were a handful of us with
  the tokens to unseal core infrastructure secrets. In this case, a single
  compromised account can't do anything; you'd need several.
