---
title: "High-DPI support scope"
source: claude.ai
url: "https://claude.ai/chat/1ed80f24-6d69-4789-b556-f8941f5af89a"
created: 2026-11-03T21:52:33.973Z
updated: 2026-11-04T00:57:55.280Z
exported: 2026-11-04T00:58:04.439Z
model: "claude-sonnet-5-5"
---

# High-DPI support scope

## You

One of the items that we still have pending on this project, is high-DPI support.  Could you give me some insight into what this is going to involve?

## Claude

I'll check what the ticket says and what the code does today before answering.

Let me look at how the project is currently set up for scaling before I answer.

Short version: it is a bigger job than the one-line ticket (CA-022) suggests, but it breaks into pieces we can test one at a time. I haven't compiled or run anything, so what follows comes from reading the repo.

**First, an unknown I'd like to settle.** `CubicAdventurer.dproj` already has `AppDPIAwarenessMode` set to `PerMonitorV2` for both the Debug and Release Win32 configurations. That is probably just Delphi's default for a new project, and I can't tell from here whether it reaches the exe's manifest. The README still says "No support for high-DPI displays". The exe could be in one of three states: unaware (Windows stretches it, blurry but proportional), or aware but not actually scaling (tiny, cramped UI at 150%). Task Manager can tell us. On the Details tab, right-click a column header, choose Select columns, and add "DPI awareness". Then look at the CubicAdventurer row.

**What the work involves, roughly in order of cost:**

1. **Icons.** The five image lists (`SmallIcons`, `MediumIcons`, `BookmarkImages`, `MiscImages`, `QuickViewImages`) are fixed at 16 or 24 pixels. At 150% or 200% they need scaled versions, either larger icon art or a virtual image list that picks the right size. This is the largest piece, and part of it is artwork, not code.
2. **Third-party components.** This decides how far we can get.
   - A good sign: the SpTBXLib drawing calls in our code already take a `CurrentPPI` argument.
   - Unknown: the Toolbar2000 patch (from 2008), the Mustangpeak list view and tree, and the JVCL docking. If one of them can't scale, we can't fix it without vendoring, which we dropped.
   - The ten `.skn` skins are bitmaps drawn at one size, so they may look wrong at scaled sizes.
3. **Forms.** All 27 forms with a recorded value are designed at 96 DPI, which is what the VCL wants. It can scale forms itself when the monitor changes, but our hand-edited `.dfm` files, the docked and floating panels, and any pixel sizes hard-coded in the Pascal code are where I'd expect problems.
4. **Saved layout.** `layout.xml` dock sizes, column widths and window position are stored in pixels. If you copy your XML files to a laptop running at a different scale, panels could come up the wrong size. That matters for the way you already move settings between machines.

**Effort and testing.** The cheap first step is to make sure the exe is declared PerMonitorV2 and see how bad it looks at 150%. That is one build. Making it good is probably several sessions, mostly driven by the libraries. I can't see a scaled display, so the loop is: set Windows scaling to 125% or 150%, run the program, and send me a screenshot of what looks wrong. Do you have a monitor or laptop already running above 100% that you could use for that, and can you do the Task Manager check first?

## You

Yes, it *is* `Per-Monitor (v2)`

## Claude

That helps, because it means Windows is not stretching the window. Everything on screen at 125% or higher is drawn by the program itself, so any gap shows up as mismatched or too-small elements, not blur.

I'd expect the Delphi forms layer to already be scaling the forms and the font sizes. The likely failures are the places the VCL can't help with:

- The 16 and 24 pixel icons stay the same physical size while the text grows.
- The skin bitmaps and the third-party drawing may not grow.
- Row heights and docked panel sizes may not match the text.
- Any pixel sizes hard-coded in our code stay at 96 DPI.

So the next step is a look, not a code change. Set Windows scaling to 150% and run CubicAdventurer, then send me a screenshot or two. A main window with a couple of panels open, and the Options dialog, would cover most of the cases. Because the program is per-monitor aware, it should react to the scale change live, but some other programs may want a sign-out after you change it.

If you'd rather not change the scaling on your desktop, the Windows 11 laptop may already run at 125% or 150%. In that case a screenshot from there would do the job.

Which machine is easier for you to use?

## You

I don't really want to do that on my desktop; last time I did that (years ago, on an earlier version of Windows), I messed up a bunch of things permanently, even after I switched back to 100% !!!  Of course, Windows 10 *might* be more capable than whatever I was using back then.

Anyway, I got the general answer that I wanted; I wasn't planning on pursuing yet, I just wanted an idea of how much work it would be... sounds like *a lot* ... and I don't know *what* we'll do to generate new images; I have *no* artistic skills at all!!

## Claude

Fair enough, and I wouldn't touch your desktop either. "A lot" is a fair summary. There is no deadline, and the ticket can sit where it is. The one useful fact from today is that the exe is already per-monitor aware, so nothing about this is blocking anyone from running the program.

On the images, you wouldn't need artistic skills. The realistic options, cheapest first:

- **Scale up what we have.** Draw the existing 24 pixel icons at 32 or 36 pixels. They come out slightly soft, but they are usable. This is the zero-art route, and it could be done in code.
- **Use a permissively licensed icon set that comes as vector files.** These scale cleanly to any size. Sets such as Lucide, Tabler and Material Icons are, as far as I know, under MIT, ISC or Apache licenses, but I would check each license before we used any of them. The cost is replacing the artwork and finding a way to render it in Delphi.
- **Offer larger icons only at high scaling.** Do the cheap scaling for most people and make the hand-picked artwork a later refinement.

If you ever want to pick this up, the first step is still just that 150% screenshot, from the laptop or from a user who reported the problem. Until then I'll leave it alone.

## You

Let me ask one more question about high-DPI support... no, don't write any code!!
You previously mentioned issues related to resizing icons...
What will have to be done with themes??  
As an example, I use the `DeviantDark` theme, which looks like the attached image... 
I don't know how the themes are actually generated... if they are drawn live, we are probably fine... if they are fixed images, though... that may be another headache...

## Claude

I can answer that from the skin files themselves, so let me look at one.

Good news, and I need to correct something I told you earlier. I said the ten `.skn` skins were bitmaps drawn at one size. That was wrong: I hadn't opened one when I wrote it. I have now, and I looked at `Deviant Dark.skn`.

A skin is a plain text file of about 6 KB with no images in it. It lists a color or a two-color gradient for the body and borders of each kind of control: menu bar, toolbar, tab, panel title bar, header, edit frame and so on. SpTBXLib draws the shapes live from those colors, and the draw calls we have in our code already pass the current scale to it. So the themes should not need any new artwork. All ten skins are the same kind of file.

Two small things could still look off at 150% or 200%, and I can't tell without seeing it:

- **Thin lines.** The skin's borders are one pixel wide, so they could look finer than the rest of the interface. The title bar border is a fixed 4 pixels.
- **Anything in the screenshot that isn't a theme.** The folder icons on the tabs, the blue download arrow, the drive icons in the Folders panel, and the tab close marks are not part of the skin. They come from the image lists, so they are the same icon problem as before, not a theme problem.

The text in your screenshot is a font, and fonts scale with their point size, so it should be fine.

So the only artwork cost is still the icons, not the themes.

## You

Thank you!!!  
I'm really not looking forward to dealing with this issue, but I follow other software groups, and high-DPI support is a commonly-discussed issue, so I suspect that it is a little land-mine that will go off at some point...

## Claude

That's a reasonable instinct. High-DPI screens are getting more common, especially on laptops, and a lot of Delphi programs from this era have had the same problem. Today's findings do give us a head start. The exe is already per-monitor aware, the themes are drawn live, and the real cost is concentrated in the icons, so it is a contained problem and not a rewrite.

If a user does report it, the most useful things they can send are a screenshot and their Windows scaling percentage. With those we can skip the guessing stage.

Do you want me to add a few lines to CA-022 in `ISSUES.md` with what we found today? That would save re-deriving it later. I'll leave the ticket alone unless you say yes.

## You

YES!!!  Excellent idea !!  I keep forgetting about that resource, it has been invaluable!!
Yes, add what we now know to a ticket number...

## Claude

The pull brought in a new file, `Documents/High-DPI support plan.md`, that wasn't there when I looked earlier. I'll read it before touching the ticket.

CA-022 now holds what we found today, and it's pushed to `master` (commit 26379a0, docs only). It's still in Deferred, and the "Last updated" date in the header is bumped.

The entry covers:
- the exe being Per-Monitor (v2) aware
- the skins being live-drawn color files
- the five fixed-size icon lists as the main cost
- the unknowns in Toolbar2000, the Mustangpeak list view and tree, and JVCL docking
- the settings saved in pixels
- the first step when it's taken up: 150% screenshots from the laptop or a user, not from your desktop

The `Documents/High-DPI support plan.md` file you committed is an export from before my skin correction, so it still says the skins are bitmaps. I left it alone, and the ticket notes that this one remark in it is wrong. If you re-export this chat later, the export will have the corrected version.

## You

Excellent - that will work beautifully, because I intend to click that "Claude as Markdown" icon as soon as I send this!!!

## Claude

Then the export will carry the corrected skin answer, and the ticket and the document will agree. Enjoy the rest of your afternoon.
