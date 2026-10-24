---
title: "Adding collaborators to project"
source: claude.ai
url: "https://claude.ai/chat/9a58a299-de3e-4b92-86c9-bbad91508c1b"
created: 2026-10-24T01:14:17.418Z
updated: 2026-10-24T01:25:32.546Z
exported: 2026-10-24T01:25:42.804Z
model: "claude-sonnet-5-5"
---

# Adding collaborators to project

## You

Question about future project management...

What happens, with an interface such as ours, if we need more people involved??

The obvious issue with the current program, is that when it comes to dealing with Language support, I simply will have nothing to contribute, at all... but I'll still need you involved, because you are the master of the code base...

So how do we link another person into this project?  Or is there some other way that we can organize the support network so that multiple people can be working with each other, and with you, on this project??  And will everyone have to have Pro accounts to contribute??

## Claude

Let me check the current plan details before answering the account part.

Good news: the project is already set up so that you aren't the only way knowledge flows, and neither am I.

**I don't carry the project in my head.** Every chat starts cold and gets up to speed from the repo: `ISSUES.md`, `CHANGELOG.md`, the handoff notes and `Build_instructions.md`. Another person's Claude (or a human) could do the same. The repo is the shared brain, so keeping those docs current is what makes adding people work.

**Translators don't need me, code, or Delphi at all.** Language support is the easiest part to hand off because it's just text files. The plan would be:
- I set up the plumbing once: extract the strings into a template file (the original author's `BuildCE` folder has a gettext toolset and an `ExtractPOT.bat` for this), and make sure the program loads a language file at startup.
- A translator takes the template, translates it with a free editor like Poedit, and sends back one file for their language.
- They send it to you either as a GitHub pull request (a proposed change you review and accept with a click) or, for non-technical people, by email or an attachment on an issue, and you drop it in the repo.

Since you can't judge a translation either, the practical approach is to ask each translator for a native-speaker file and treat that language as theirs. If someone later reports a wrong string, they fix their own file.

**For people who do want to write code:** the standard route is that they fork the repo, make changes on their own copy, and open a pull request. You review it on GitHub, and nothing reaches `master` without you. `ISSUES.md` is already a decent task board for them. A short `CONTRIBUTING.md` (how to build, the code style rules, "don't save forms in the IDE while the TCE components can't load") would save everyone repeated questions. I can write that when you're ready.

**Accounts:** nobody has to pay anything to contribute. Translators and code contributors only need a free GitHub account (or just email). Your Claude subscription is what lets me work on the code with you here. If a contributor wants their own AI help, the free plan is chat-only and excludes Claude Code, so Pro is the minimum for that. They can still paste code into a free chat for questions, but it would be a clumsier workflow. Separately, the Pro plan doesn't include API access, which only matters if anyone wanted to automate things.

**Practical risks:**
- Build difficulty is the real barrier for code contributors. Delphi 13 CE plus about ten hand-installed libraries is a big ask, so `Build_instructions.md` has to stay accurate.
- Because several chats (and now several people) can edit at once, the "pull before editing" rule matters even more.
- You'd become a reviewer and merger, not just the tester. That's manageable if you keep contributions small.

I'd put this after the release and the discussion page (`CA-004`). A "Help wanted: translations" note there, plus an `ISSUES.md` entry for the language-file setup, would be the natural next step. Want me to add that entry now, or leave it until after Bookmarks and Sessions testing?

Sources:
- [Is Claude Code Free? 2026 Guide](https://ai.zenken.co.jp/en/post/claude-code-free-plan-guide/)
- [Claude Pro Plan guide](https://fast.io/resources/claude-pro-plan-guide/)

## You

okay, multiple concepts here; let me sort...

1. regarding Language support, I don't intend to initiate that at all !!!  I'll wait until someone says "I want this program to work in language X", then I'll vet them to see how much they are willing to get involved (this will really only be heavy for the first language; after that, we will hopefully have a pipeline set up), then I'll come back to you and we'll spec out the process...
2. You mention Claude Code, several times... I've been wondering about what that actually means; I keep getting pushes from your masters to start using that, but afaik, I'm still just using ordinary Claude Web interface... Is that not correct??
3. As far as “Help wanted: translations” ... yeah, item 1 applies... 


For now, I just wanted a broad vision of how we get other people involved... I think I've gotten a starter vision here, anyway...

## Claude

Understood on 1 and 3. Translations happen only when someone asks, you vet them, and then we spec the process together. I won't add any "help wanted" item or language entry to `ISSUES.md`.

On 2, your reading is right. You're using the ordinary Claude app, but it isn't limited to chat. In this project I run in a private cloud workspace where I can clone your GitHub repo, edit files, run scripts, and push to `master`. That's the "file and shell tools" side of the regular app, and it's why the push/pull loop works.

**Claude Code** is a separate product aimed at software engineers. It runs in a terminal, an editor, or its own desktop or web app, and works directly on the files on your own PC. The main practical difference is where the work happens. I work on a copy in the cloud and you `git pull` it, while Claude Code would edit your actual checkout in place.

I'd see little reason to switch for this project. The slow step is the Delphi build, and Delphi 13 Community Edition won't let anything compile from the command line. So you'd still be pressing Shift-F9 and F9 yourself and pasting errors back, with or without Claude Code. Your current loop is fine. If Anthropic's nudges are getting annoying, you can safely ignore them.

If you ever do try it, it would be worth it mainly for things that run entirely on your machine, like Python tools or Makefile work in your other projects. That's a separate decision from CubicAdventurer.

## You

Cool... thank you... I understand what is coming now...

## Claude

Glad it's clear. When you're rested, the next step is still testing Bookmarks and Sessions (`CA-006`), and that's all the release is waiting on. Have a good evening.
