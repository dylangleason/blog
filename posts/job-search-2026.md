title: Job Search 2026
date: 2026-04-12 13:20
tags: work
---

After 4 months of searching for a software engineering job, I've come
away with a few observations, along with some other stray thoughts
that seem worth sharing, regarding my personal experience in current
job market.

## Specialists Over Generalists
As a software generalist, my skills are all over the map. I have
worked in startups mostly, in various languages, in different stacks,
etc. My polyglot, "jack of all trades, master of none" background
seems particularly ill-suited to this very competitive market.

Though I am searching primarily for Go jobs, these tend to bias more
toward systems programming or "highly scalable" microservice,
event-driven, _yada-yada-yada_ architectures, which all presume some
level of proficiency with Kubernetes and prior experience scaling
_billions_ of transactions per second. Unfortunately, I don't have a
ton of on-the-job experience with Kubernetes, nor have a designed
these kinds of data intensive applications from the ground up, so I am
finding trouble positioning myself with hiring managers for these
types of roles.

While I have experience in web operations ("DevOps" / "Platform
Engineering" / "SRE" / whatever) and full-stack development, my skills
are not current enough or specialized enough to be seriously
considered for these types of roles either.

## Tech Stack Alignment / "What Have You Done For Me Lately"
At the other end of the spectrum, I interviewed for a role to lead a
development team writing code for a monolithic Ruby on Rails
application. Here, too, I failed to pass muster. Per a former
colleague, who was kind enough to refer me to the hiring manager, I
learned that one of the main reasons for my rejection was because I
didn't have _recent_ experience with Rails, despite the fact that I
had shipped successful solutions to production using Ruby on Rails in
the past.

On the other hand, for a platform engineer role I applied to, I was
able to get a screening call based on adding
[Temporal](https://temporal.io/) and [NATS](https://nats.io/)
experience on my resume from my most recent role. So it seems like
tech stack alignment and recency in that tech stack is particularly
important now.

## Long Live LeetCode
LeetCode style technical assessments will unfortunately never go
away. If anything, companies using them have made the process even
more annoying, for example in their attempts to curb [AI-assisted
cheating](https://tech.yahoo.com/articles/cheating-tech-interviews-soaring-managers-080901006.html)
and interview fraud. So, I have to turn my camera on, and talk through
my solution, even when there is no one present for me to talk
to. These almost always seem to be used as part of a pre-interview
screening process and require use of special web editors that I am not
used to (though at least most of the ones I've tried support Emacs or
vi key bindings).

I am certainly not against writing code as part of an assessment, and
in fact prefer them to the "take-home" style assessment, as those
always end up taking at least double the amount of time indicated. In
a recent interview for a senior engineer role, I was asked to
implement an API endpoint for an inventory system, optimizing for read
performance and integrating with a SQL database. I discussed how I
would test it, scale it, and how it could be extended for future
requirements. In other words, it focused on real-world engineering
problems, and it felt more like structured pair programming. Fun,
actually!

It certainly would be nice if more employers used the above pair
programming format, but I suspect they won't since it requires more
effort on their part. And I can see how they may prefer pre-interview
technical screens when trying to vet hundreds of candidates for a
single role (did I mention that the job market stinks?). Still, I am
sure I am not alone in my hatred for these kinds of tests. I always go
back and forth on whether I should opt out of these entirely, but I
will probably continue to do them.

## The Elephant In the Room
Generative AI is the new wrench thrown into the interviewing
experience, at least for me. When I have been lucky to get an
interview with a real human and (even luckier still) get deep enough
into the interview process to learn about how the team uses AI, it
seems most teams are still figuring it out.

### AI Technical Interviews
From the standpoint of technical interviews, most companies I have
interviewed with thus far did not allow use of AI tools. In fact, most
seemed wholly uninterested in evaluating how I personally use these
tools. However, there was one company that specifically encouraged the
use of coding agents for their take-home challenge.

That particular challenge involved quite a few moving parts, and it
was time-boxed to 2 to 3 hours, so it seemed like a good opportunity
to get practice with Codex. I used the latter to write the tests and
the code, using a TDD-based approach, as well as steering and design
documentation to guide implementation, the latter of which I wrote.

I am not really sure what the correct approach here was, but it
evidently wasn't mine, as I was told upon rejection that it was not
"robust" enough for a senior role. Despite completing the stated
objective and implementing tests validating the requirements, the code
quality was&hellip; unremarkable. Perhaps another coding agent such as
Claude Code would have produced higher quality output, but I could
nonetheless see their point. Moving on.

At the end of the day, I think reviewers still want to review high
quality code, though I wonder how this expectation changes on the job
when reviewers presumably need to write and review a large volume of
LLM generated code on a daily basis.

### AI In Practice
Among the hiring managers and devs for the roles I interviewed with,
there was no clear consensus on how to effectively use AI as part of
their business or engineering process. However, there were some common
themes. All indicated challenges reviewing AI-generated code at scale
and defining & implementing governance for agentic workflows. One
hiring manager noted, correctly, that AI is a "force multiplier",
i.e. it can have a multiplicative impact in either a positive or
negative way. Most I talked to seemed to be taking a tactical and
measured adoption of its use, and it's good to know that engineering
teams (or at least this comparatively small sample size) are not
totally cargo culting AI.

## Where Have All the Junior Engineers Gone?
Speaking of junior engineers, it seems many of these same companies
are replacing junior talent with AI and/or hiring seniors
exclusively. Honestly, it's hard to tell how much of this dislocation
is due to AI or due to existing trends (based on experience from my
most recent roles, I have seen fewer juniors and less emphasis on
mentorship). There's a lot to parse in the current AI discourse right
now, and how this informs hiring practices of junior talent I am not
sure, but it is notable.

"We don't have the time to teach someone who is just starting out",
"we need to hit the ground running", "we aren't able to do a lot of
hand-holding" &hellip;are some of the responses I've heard. The ones
that do have junior engineers on their team, unsurprisingly, call out
mentorship explicitly in job descriptions.

## The Dreaded Job Gap Question
Job gaps. I was laid off in October, and spent two months on garden
leave, until my employment officially ended in December. I put on my
resume that my most recent role ended in October, which in hindsight
was probably a mistake. Almost everyone has asked me what I have been
doing since October. In the past, I've only been out of work around 3
months max and have never been asked this, but it seems to be a
concern this time around. Perhaps this is reflective of the very
risk-averse / buyer's market mentality of the current software job
market.

On a similar note, another hiring manager grilled me on why most of my
roles have been between 2 and 3 years. I generally try to give a
generic answer like "due to external factors beyond my control" (which
is true, by the way, at least as far as I can tell), and redirect the
conversation to express my desire for a long-term position. But this
particular hiring manager kept probing. Fair enough, I suppose. But I
am curious if they've ever been part of a layoff or have had the
authority to make those decisions themselves.

## Miscellaneous

### Recruiters
The recruiting experience is still about the same, though it seems
like ghosting is noticeably more severe this time around. I generally
expect ghosting from recruitment agencies by default, but even a
number of in-house recruiters have failed to follow up after having
gone through an interview. I suspect this is due mostly to
disorganization and trying to juggle multiple (perhaps dozens) of
candidates for various roles at a time, but it still isn't a great
feeling to be ghosted. And of course this says nothing about LinkedIn
recruitment scams and fake job postings out there.

### Hiring Managers
Hiring managers seem to be a lot pickier this time around as well,
which aligns nicely with the aforementioned "crappy job market" theme
I've been rolling with. For base qualifications, they seem to want the
sun and the moon, even for contract roles. If I manage to get an
interview with the hiring manager, they are pretty
hit-and-miss. Sometimes I knock it out of the park, other times it is
evident that they lost interest.

Though I usually do quite well on behavioral or "culture fit"
interviews, there's at least one question I get asked that I don't
have catalogued in my memory bank of
[STAR](https://resources.biginterview.com/behavioral-interviews/star-interview-method/)
method stories. Then I stumble, forget details, go down rabbit holes,
only to pause my nervous gesticulating to take note of the hiring
manager's vacant stare, as they absent-mindedly tab through their web
browser (I caught one yawning, too. Ouch.).

### Interview Preparation

Speaking of STAR method stories and GenAI, I have been using the
latter to good effect to help me refine the former. Typically, these
stories need to be delivered within a minute and with utmost clarity,
and I have found ChatGPT is particularly good at editing for
clarity. It also seems to excel at "interview" speak, which is a nice
bonus.

For technical rounds, I have also been using ChatGPT and Claude to
help brush up on certain technical topics. For example, I had an
interview where a hiring manager hinted that the system design portion
of the interview might be to implement a leaderboard or a chat
system. Prior to the interview, I used ChatGPT to structure system
design interview questions for both, then I walked through my
solution, discussed my approach and tradeoffs, and then requested
feedback.

Similarly, I wanted to brush up on various concurrency patterns in Go
using goroutines. It's one of those things in Go that one uses often
enough to justify getting quizzed on, but infrequently enough to be
able to reproduce the patterns from memory when asked randomly in the
context of an interview or technical screen. I had it generate
examples for different types of workflows using goroutines and
channels, including fan-in / fan-out pipelines, workloads using write
vs read-write mutexes, and so on. I then asked it to wrap examples in
a convenient little CLI executable that accepted flag arguments for
testing the various scenarios. All of this in a matter of
seconds. Neat!

This, along with structured learning plans (e.g. helping me build a
[project](https://codeberg.org/corginapalm/daudio/src/branch/main) to
learn basic audio DSP, from first principles), has been one of my
favorite ways to use generative AI tools during this lull in
employment.

## Conclusion
For all the rapid changes in software each new year, it is striking
how _little_ the software engineer interview process has changed. Even
the oft-hyped AI hasn't really seemed to make much of an impact on the
experience, except to perhaps make it slightly more annoying. It seems
that employers are mostly doubling down on existing tech interview
processes, there are just more of them, they're more difficult and
more time-consuming. But, for every 10 annoying multi-round gauntlets,
there are always a few gems here and there. And regardless, it's
always a good opportunity to improve my skills and clarify my
strengths, weaknesses and career goals.
