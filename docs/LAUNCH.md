# Launch Playbook

This document is the launch plan for Agent Devbox. It deliberately describes
the project as a public preview until the manual VM acceptance matrix in
[`RELEASE.md`](../RELEASE.md) has been completed on real hardware.

## Objective

During the first 30 days after the public repository opens:

- collect 10 substantive reports about installation, isolation choices, or
  missing workflows;
- confirm at least five successful macOS or Ubuntu installations outside the
  maintainer's machine;
- attract three contributors who open an issue, improve documentation, or send
  a pull request; and
- learn which profile people actually want: native macOS UI, Ubuntu RDP, or
  both.

Stars and page views are useful reach signals, but they are not acceptance
evidence. Track GitHub clones, unique visitors, issues, discussions, first-time
contributors, and self-reported successful installs separately.

## Audience and message

### Primary audiences

1. Developers who use Codex, Claude, browsers, editors, and other graphical AI
   harnesses but do not want them operating directly on an everyday Mac.
2. Security-conscious AI builders who want a reviewable starting point for
   account and filesystem isolation.
3. Mac developers interested in practical use of Apple's Virtualization
   framework and VirtualBuddy.

### Core message

Run graphical coding agents inside a disposable VM with no host folders,
credentials, SSH agent, or clipboard shared by default.

### Proof points

- Native macOS UI profile and an automated Ubuntu Desktop profile.
- Explicit threat model and honest residual-risk documentation.
- Separate administrator and everyday agent identities.
- Repeatable bootstrap, diagnostic commands, tests, and CI.
- MIT-licensed source that can be audited and changed.

Never claim that the setup is "secure," "safe," or a sandbox in the absolute.
Use "reduces host exposure" and name the limits: signed-in accounts, guest
files, network access, hypervisor defects, and user-enabled sharing remain
risks. The project is independent and is not endorsed by any named vendor.

## Release gates

### Public preview gate

- [ ] Public GitHub repository exists with an OSI-approved license.
- [ ] CI passes on the exact public commit.
- [ ] Security policy, threat model, and contribution guide are visible.
- [ ] GitHub Discussions and private vulnerability reporting are enabled.
- [ ] The README says that full VM installation remains manually validated.
- [ ] A maintainer can stay available for questions during each launch window.

### Stable release gate

- [ ] The complete macOS and Ubuntu manual matrices in `RELEASE.md` pass.
- [ ] At least one installation is performed from a clean clone.
- [ ] Screenshots and recordings contain no personal account, repository, host,
      notification, or credential data.
- [ ] Known limitations from early testers are documented.

Until the stable gate passes, use a prerelease such as `v0.1.0-alpha.1` and say
"public preview" in every launch post.

## Channel sequence

| When | Channel | Purpose | Action |
| --- | --- | --- | --- |
| Day 0 | GitHub | Source of truth | Publish the prerelease, enable Discussions, and open a pinned feedback thread. |
| Day 0 | LinkedIn | Founder story and broad discovery | Publish the personal problem, the design choices, and a specific request for testers. |
| Day 1-2 | Direct peers | High-quality first feedback | Invite 5-10 relevant peers individually; do not ask for stars or votes. |
| Day 3-5 | Reddit | Technical critique from one relevant community | Choose one subreddit, re-read its rules that day, disclose authorship, and use a native text post. |
| Day 5-7 | Discord/community forums | Focused implementation feedback | Ask moderators where project showcases belong, then post only in the approved channel. |
| Week 2 | Hacker News | Broader technical review | Use Show HN only after a stranger can run the project and the maintainer can answer live. |
| Week 2-3 | DEV/Hashnode/personal blog | Durable technical explanation | Publish the threat-model and VM-boundary lessons, then link to the repository once. |

Do not submit to `r/selfhosted`: this project provisions a local development VM
and does not replace a hosted service. Do not paste identical copy into several
subreddits. Reddit's site-wide policy prohibits repeated or unsolicited mass
engagement, and each community may impose stricter rules.

For Discord, prefer an explicit `showcase`, `projects`, `tools`, or
`self-promotion` channel. If none exists, ask a moderator before linking. In the
VirtualBuddy community, lead with implementation findings or compatibility
feedback rather than treating its discussion board as an advertising surface.

## Launch assets

Prepare these from a clean guest with newly created demo accounts:

- one 20-30 second recording: open the VM, launch an agent UI, show the guest
  workspace, and show that host sharing is disabled;
- one architecture image showing Mac host, VM boundary, guest accounts, and
  provider network access;
- one terminal capture of `make macos-doctor` or `make linux-doctor` with no IP,
  username, or path that identifies the maintainer; and
- one screenshot of the threat-model summary.

Alt text should describe the VM boundary and the UI shown, not repeat the post.

## Ready-to-edit posts

Replace `<REPO_URL>` and any bracketed evidence before publishing. Do not call
the manual acceptance matrix complete unless it has actually passed.

### LinkedIn

I use graphical coding agents every day, but I did not want every agent harness
to have direct access to my normal Mac, SSH keys, browser sessions, and personal
files.

So I built Agent Devbox, an open source setup for running Codex, Claude, editors,
and browsers inside a disposable VM.

The macOS profile gives the agents a full native UI through VirtualBuddy. The
Ubuntu profile gives a more automated desktop over RDP. Both start from the same
rule: no host folders, credentials, SSH agent, or clipboard are shared by
default.

This is a public preview, not a claim of perfect security. Signed-in accounts,
guest files, network access, and the virtualization layer are still part of the
threat model. I documented those limits instead of hiding them.

The code, setup guides, tests, and threat model are here:
<REPO_URL>

I would especially value feedback from people already using multiple agent
harnesses: which workflow would you test first, and what isolation gap do you
see?

### Reddit

Suggested title:

> I built an open source macOS VM devbox for graphical coding agents

Body:

> Disclosure: I built this project.
>
> I use several graphical agent harnesses and wanted them off my everyday Mac,
> without giving up their full UI. Agent Devbox is a reviewable setup for running
> Codex, Claude, editors, and browsers in a disposable macOS VM, with an Ubuntu
> RDP profile as an alternative.
>
> The defaults do not share host folders, keychain data, SSH agents, or the
> clipboard. The everyday guest account is not an administrator. I also wrote
> down what the boundary does not solve, including provider-account actions,
> guest data exposure, network access, and virtualization defects.
>
> It is an MIT-licensed public preview. The scripts and static checks pass, while
> the complete clean-hardware acceptance matrix is still being collected.
>
> Repository: <REPO_URL>
>
> I am looking for technical criticism, especially around the threat model and
> any Mac UI workflow the defaults would break. What would you change before
> calling this ready for daily use?

Adapt the first paragraph to the selected community and remove the link if its
rules require link-free discussion. Never ask for upvotes.

### Hacker News

Title:

> Show HN: Agent Devbox - graphical coding agents inside disposable VMs

First comment:

> I built Agent Devbox because the coding-agent tools I use are increasingly
> graphical, while most isolation recipes assume a CLI in a container. This
> project uses VirtualBuddy for a native macOS guest and Multipass plus RDP for
> an automated Ubuntu alternative.
>
> The important design choice is what is absent: no host working-directory
> mount, credential copy, SSH-agent forwarding, or clipboard integration by
> default. I included a threat model because a VM still cannot prevent actions
> performed through accounts you sign into inside the guest.
>
> The current release is an early public preview. I would appreciate feedback on
> the boundary, bootstrap reproducibility, and which GUI harnesses should be in
> the compatibility matrix.

Show HN submissions must point to something people can run without a signup
gate. The maintainer should be present to discuss it and must not ask others to
upvote or comment.

### Discord

> I built an MIT-licensed public preview for running graphical coding agents in
> a disposable macOS or Ubuntu VM, without sharing host folders, credentials,
> SSH agents, or the clipboard by default. I am looking for feedback on the
> threat model and broken UI workflows, not stars. If project links are welcome
> here: <REPO_URL>

### Direct tester invitation

> I am testing an open source VM setup for keeping graphical coding agents off
> an everyday Mac. Would you be willing to try one clean install and tell me
> where the instructions or isolation model fail? It is a public preview, and I
> am specifically looking for honest breakage reports. <REPO_URL>

## Response plan

For the first 48 hours after each post:

1. Answer setup failures before debating architecture preferences.
2. Convert reproducible failures into labeled GitHub issues.
3. Link to an existing threat-model section instead of improvising security
   guarantees in comments.
4. Thank critics without promising unsupported timelines.
5. Publish a short seven-day follow-up with installs, failures, fixes, and
   deferred gaps, not only stars.

## Measurement log

Capture a baseline immediately before each post and results after 24 hours and
seven days:

| Channel | Date/time | Visitors | Clones | Stars | Discussions/issues | Confirmed installs | Notes |
| --- | --- | ---: | ---: | ---: | ---: | ---: | --- |
| GitHub release | | | | | | | |
| LinkedIn | | | | | | | |
| Reddit | | | | | | | |
| Discord/forum | | | | | | | |
| Hacker News | | | | | | | |

Use GitHub's traffic referrers where available. Avoid link shorteners in
technical communities; a direct repository URL is easier to inspect and trust.

## Community-policy references

- [Reddit spam policy](https://support.reddithelp.com/hc/en-us/articles/360043504051-Spam)
- [Show HN guidelines](https://news.ycombinator.com/showhn.html)
- [Current Show HN participation notice](https://news.ycombinator.com/showlim)
