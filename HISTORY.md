# CubicAdventurer: issue history

This file records every item that has left `ISSUES.md`: what it was, how it ended and when. It is the
story of how the project got where it is, wrong turns included. Open work lives in `ISSUES.md`, what
changed for users is in `CHANGELOG.md`, and the code is in git.

**How it is kept.** When an item is fixed, dropped or closed, its entry is moved here from `ISSUES.md`
instead of being deleted. Newest first, grouped by the day it closed. Each entry says when it was opened
and closed, the version in progress at the time, and how it ended (fixed, dropped, closed with no action).

**How this first version was made.** It was rebuilt on 2026-11-03 from the 116 versions of `ISSUES.md` in
git, the commit messages, `CHANGELOG.md` and the saved chats of this project. Notes on reading it:

- "Closed" is the date of the commit that removed the item from `ISSUES.md`.
- "Version" is the newest changelog version at that moment. 0.97 (2026-10-24) was the first release.
- Items that first appear on 2026-10-23 were carried over from the old handoff list when `ISSUES.md` was
  created, so they may be older than the "Opened" date shown.
- Where the reason for a close was never written down, the entry says so.
- Numbers CA-009 and CA-019 were never used. Numbers CA-051 to CA-059 were each reused for different
  problems between 2026-10-24 and 2026-10-30 (the `ISSUES.md` header said "never reused", which was true
  only until 2026-10-24). A reused number is shown as, for example, "CA-053 (3rd use)". Every number from
  CA-060 on is unique.
- CA-016 once held four unrelated items. It was split on 2026-10-27 (see that day).

## 2026-11-07

### CA-005a [task] Spread the word further
Opened 2026-10-24, closed 2026-11-07 (1.01). Closed with no further action.
Wrap-up of the announcement effort. Done: r/Delphi, r/pascal and r/TrueOpenSource (a few other
groups refused the post); AlternativeTo (listed after the paid fast track; a request to link it to
CubicExplorer as its port is pending); his own Scoop bucket; portablefreeware.com, which gave the only
concrete response so far (user sl23, whose skins are now shipped). Blocked or not worth it: Hacker News
(new account, Show HN restricted), Neowin (permanently banned, no reason given), Softpedia (AI
involvement), SoftTonic (needs code signing), MajorGeeks (still in their queue). Considered and
dropped on 2026-11-07: winget (his earlier submission of another program sat in the queue for weeks
and was rejected over a changed version requirement), awesome lists (judged no longer useful). Not done,
optional: GitHub repository topics (delphi, object-pascal, file-manager, windows, cubicexplorer) and a
Website link to the Releases page, about two minutes in the repo's About box. Chocolatey was mentioned
and not pursued.

### CA-067 [task] Make preview pictures for the shipped themes
Opened 2026-11-07, closed 2026-11-07 (1.01). Done.
`tools/SkinPreview/SkinPreview.dpr` applies each skin to a sample window and saves `<skin>.png` next to
it (client area only, existing pictures kept, `/force` replaces them). Wrong turns: `CAPTUREBLT` is not
declared in Delphi's Windows unit; the tab strip at a fixed top covered the second toolbar row (now
aligned); the first pictures included the outer frame and, with WindowBlinds running, its colors on
the controls, so they were regenerated under a stock Windows theme. `/export` writes a `.skn` for the
13 skins that are built into SpTBXLib and CA (Aluminum, Athen, Dream, Eos, Human, Leopard, Xito, the
Office skins, Chrome), which have no file; the program keeps using its built-in copy. Default has no
picture. The pictures were committed with the skins.

### CA-066 [task] Check the theme preview on Options > Display
Opened 2026-11-07, closed 2026-11-07 (1.01). Done; confirmed by Derell in the installed program.
Options > Display shows `<skin file>.png` to the right of the Theme box and updates as the selection
changes, including when arrowing through the open list (the theme applies only at OK or Apply). The
skin name is not the file name, so `Main.pas` remembers which file each skin came from. Wrong turn:
the page was clipped at 441 pixels by the width cap every Options page inherits, although the dialog's
page area is 521 wide; the Display page now lifts the cap. The Restore Default Layout button was
narrowed to the Theme box's width.

## 2026-11-04

### CA-058 (2nd use) [bug] File view sometimes misses added or renamed files
Opened 2026-10-30 (formerly CA-011), closed 2026-11-04 (1.00). Fixed 2026-10-30 (0.99); confirmed by
Derell on 2026-11-04 after several days of heavy downloading: the view updated every time, whether or
not Downloads was the folder being viewed.
Symptom: a folder view, mostly the Downloads tab, stopped showing new or renamed files until F5, while
Windows Explorer always updated. Chromium-based browsers download as `.tmp`, rename to `.crdownload`, then
to the final name; CubicAdventurer kept showing the temporary name.
Cause, found with trace builds, DbgView logs and probe files written from a console: in the Mustangpeak
library's `RebuildWatchNotify` (`VirtualShellNotifier.pas`) the array that maps watch slots to views was
written but never cleared, so stale entries survived every rebuild. The Workspace panel (closed, and never
opened by Derell) built a file view at startup that registered a folder watch; it took a slot about two
seconds after launch, every later tab's slot shifted, and change signals went to the wrong view.
Fix: the array is cleared on each rebuild (a vendored copy of upstream `VirtualShellNotifier.pas` with one
marked change), and the Workspace panel's view only watches while the panel is shown. Verified in logs.
The trace builds are in git history (commits 98703df to abc896b) if it ever returns. See also CA-011.

## 2026-11-01

### CA-065 [bug] Folders panel used a different font from the file list
Opened 2026-11-01, closed 2026-11-01 (1.00). Fixed.
Reported from Derell's Windows 11 laptop: the Folders panel showed Segoe UI beside a Caligula file list.
CA-059 had made the tree follow only the file list's font size; the face still came from the Windows icon
font, which on Derell's desktop is also Caligula, so the bug could not show there. The tree now takes face,
character set and size from the file list. Confirmed on the laptop the same day.

## 2026-10-30

### CA-064 [task] Options dialog slow to open
Opened 2026-10-30, closed 2026-10-30 (0.99). Fixed, confirmed by Derell.
Opening Options took about 5 seconds. Timing builds showed the Display > Fileview page alone cost about
2.7 seconds on first open (seven color-box handle creations were about 1 second of that); every other page
was under 130 ms. Pages are now built the first time they are selected, and the dialog is hidden instead of
freed, so a reopen takes under 0.1 second. Deferring the color-box handles to save another second was
offered and declined.

### CA-063 Window position and size saved after a move or resize
Opened 2026-10-30, closed 2026-10-30 (0.99). Done, confirmed by Derell.
Before, the window position was saved only at a normal exit. It is now saved a second after a move,
resize, maximize or restore. Tested with `make stop`.

### CA-062 Options OK and Apply save `settings.xml` at once
Opened 2026-10-30, closed 2026-10-30 (0.99). Done, confirmed by Derell.
Changes made in Options were lost if the program was killed before a normal exit. OK and Apply now write
`settings.xml` immediately. Tabs, panel layout and toolbars are still saved only at exit (Derell decided
that is fine).

### CA-061 Title bar shows the program name and version
Opened 2026-10-30, closed 2026-10-30 (0.99). Done, confirmed by Derell.
With "Show Path in Title bar" off, the title bar and taskbar button read `CubicAdventurer v<version>`
(the version of the running exe). Other user-facing "CubicExplorer" strings were renamed at the same time
(startup text, tray tooltip); credits to the original author stay.

### CA-060 Folders tree top-level labels ignored the Folder text color
Opened 2026-10-30, closed 2026-10-30 (0.99). Fixed, confirmed by Derell.
Desktop, This PC, Network and the drives stayed dark on a dark background. The first attempt fixed the
labels that are not real directories (This PC, Network, ...) but not the Desktop root and the drives; the
second attempt applies the Folder text color to every node in the tree.

### CA-059 (2nd use) [task] Folders tree font size
Opened 2026-10-30, closed 2026-10-30 (0.99). Done, confirmed by Derell.
Folder names in the Folders panel now use the file list's font size, and the row height follows the font,
so descenders (g, j, p, y) are no longer cut off by the next row. Only the size was shared; the font face
was fixed later under CA-065.

## 2026-10-27

### CA-057 (2nd use) [task] Stale `Components\fcl-xml` on Derell's disk
Opened 2026-10-27, closed 2026-10-27 (0.98). Closed.
The ticket meant an untracked old copy in a repo-root `Components` folder on Derell's disk. Its wording was
unclear, and Derell deleted the live `Source/Components/fcl-xml` instead (commit 3980de6). It is the XML
library the program uses for settings and sessions; it was restored (commit 5f45e3d) before he built.
Lesson: give the full path from the repo root, and grep for the units a folder provides before calling it dead.

### CA-056 (2nd use) [task] Review `BuildCE/`
Opened 2026-10-27, closed 2026-10-27 (0.98). Done: the folder was deleted.
It held the original author's SVN snapshot scripts, NSIS installer scripts (replaced by Inno Setup) and
about 8 MB of dxgettext tools. A note in CA-020 says to fetch dxgettext again when language support is taken
up. The last commit that still has the folder is bf3816f.

### CA-055 (3rd use) [bug] Toolbar button for a missing action
Opened 2026-10-27, closed 2026-10-27 (0.98). Dropped.
Found while reviewing the settings loaders (CA-030): a `layout.xml` from another version could leave an
empty toolbar button. Never reproduced; Derell does not care about it.

### CA-054 (4th use) [bug] Tray icon options hid the window with no way back
Opened 2026-10-27, closed 2026-10-27 (0.98). Fixed, confirmed by Derell.
Derell tried the tray icon options for the first time: Minimize to tray, Close to tray and Start minimized
to tray made the window disappear for good. Cause (deduced from the JVCL source): JVCL's
`HideApplication` / `ShowApplication` do not work with `Application.MainFormOnTaskbar`, which had been
switched on the day before. Hiding and restoring is now plain Win32 in `Main.pas`. The tray menu was
simplified at Derell's suggestion to "Show main window" and Exit (the odd bookmarks list is gone).

### CA-053 (5th use) [task] Toolbar combo box SkinType (cosmetic)
Opened 2026-10-27, closed 2026-10-27 (0.98). Dropped.
Made from a `TODO` comment (`TSpTBXComboBox` no longer has `SkinType`). Derell could not see any symptom,
so the ticket was deleted and the TODO stays in the code. Lesson: do not file a bug from a TODO comment alone.

### CA-052 (3rd use) [bug] Tab strip gap
Opened 2026-10-27, closed 2026-10-27 (0.98). Dropped.
Also made from a `TODO` comment. Derell explained that the gap between tabs is simply how the active theme
draws them, and that nobody had reported a problem.

### CA-042 [task] Housekeeping, then ".gitattributes / line endings: decision"
Opened 2026-10-23, closed 2026-10-27 (0.98). Done, with one decision.
It started as a bundle of clean-ups. Done: the dead vendored Mustangpeak copies and the `Options.inc` stubs
removed (the parent of commit 6b4cd44 still has them), and the unused Default File Manager registry code and
Single Instance setting removed. The stale `fcl-xml` item became CA-057. The old item about removing
`OutputDebugString` lines from `CE_DockInfo.pas` / `CE_Layout.pas` was not recorded as done (two such calls
remain in `CE_DockInfo.pas`). Line endings: the repo has mixed
CRLF and LF, some inside one file. Derell decided to leave them alone ("many of the worst evils in the
world have come from trying to normalize line endings").

### CA-041 [task] Vendor the hand-installed libraries into the repo
Opened 2026-10-23, closed 2026-10-27 (0.98). Dropped by Derell's decision.
Vendoring would not remove the need to install the design packages, so it gains little. Toolbar2000's
license also forbids redistributing modified copies, and SpTBXLib needs a patched Toolbar2000. Library
versions and install steps stay in `Build_instructions.md`. The one exception is a single patched Mustangpeak
file added later for CA-058.

### CA-040 [task] Retire old packages
Opened 2026-10-23, closed 2026-10-27 (0.98). Done.
Removed `CEToolbar.dpk`, `CE_Actions.dpk` and their files, and the old `TNT` and `PngComponents` copies.
`CE_Design.dpk` stays (design-time only; it lets the IDE open the forms).

### CA-031 [task] Settings save check after the UTF-8 changes
Opened 2026-10-23, closed 2026-10-27 (0.98). Done.
Originally "non-ASCII test of the UTF-8 changes". Ten generated test files (ASCII, UTF-8 with and without a
byte-order mark, UTF-16 both orders, Windows-1252, multi-byte characters straddling byte 1024, an empty
file) all previewed correctly in Quick View, and settings still saved. Testing the PO editor moved to CA-020.

### CA-030 [task] Settings loaders and old files
Opened 2026-10-23, closed 2026-10-27 (0.98). Done.
Checked that every loader (settings, sessions, hotkeys, bookmarks, `layout.xml`, `perfolder.dat`) ignores
unknown keys and defaults missing ones. It became a standing rule. The one gap found became CA-055 (3rd use).

**CA-016 split (2026-10-27).** The ticket "Text editor" bundled four unrelated items. At Derell's request
it was split: highlighter color settings stayed CA-016, Alt-drag column selection became CA-051 (2nd use),
the tab strip gap CA-052 (3rd use) and the combo box SkinType CA-053 (5th use). The same day Derell froze
the built-in text editor: it stays basic, programmers have their own editors, and drag and drop from the
List view works. CA-016 and CA-051 are in "Deferred" in `ISSUES.md`.

## 2026-10-26

### CA-054 (3rd use) [task] Check the Options and Customize clean-up
Opened 2026-10-26, closed 2026-10-26 (0.98). Done.
A checklist for the Hotkeys, Customize > Buttons, General and Tips and Tricks changes of that day. All checked.

### CA-018 [bug] Options > Hotkeys page clean-up
Opened 2026-10-23, closed 2026-10-26 (0.98). Done.
The list showed dead actions, the same icon on many rows, and truncated names. Icons removed, the dialog
made 80 px wider, the Name column widened, the "Swith to Previous Tab" typo fixed (also in the Locale
files), non-command entries hidden, Archiver and the Global child page deleted, Restore Default Layout moved
to the View menu. Customize > Buttons got one icon per row and a clearer hint.

### CA-055 (2nd use) [bug] Default File Manager entry still said CubicExplorer
Opened 2026-10-26, closed 2026-10-26 (0.98). Resolved by removal.
The Register / Unregister buttons (Options > General) wrote a `Folder\shell\cubicexplorer` registry key
and were untested on current Windows. The buttons were removed that day, together with the Single Instance
option and File > New Window (only one window runs; a second start brings it forward). The registry code
behind them was removed on 2026-10-27 under CA-042.

### CA-053 (3rd and 4th use) [task] Installer: Start Menu entries for the guide
Opened 2026-10-26, closed 2026-10-26 (0.98). Done.
First a "Bookmarks and Sessions Guide" Start Menu entry, then Readme, Changelog and the guide became
`.url` shortcuts to their GitHub pages, because Windows opens `.md` files in Notepad. The installer script
was untested when the item closed; the Start Menu links were checked again under CA-054 (3rd use). The guide
link was later replaced by a "Tips and Tricks" link (see CA-052, 1st use).

### CA-054 (2nd use) [task] Selected folders keep the Folder text color
Opened 2026-10-26, closed 2026-10-26 (0.98). Fixed, confirmed by Derell.
Selected folders turned black instead of keeping the Folder text color, unlike files with extension colors.

### CA-053 (2nd use) [feature] Folders tree uses the file view's colors
Opened 2026-10-26, closed 2026-10-26 (0.98). Done, confirmed by Derell.
The Folders tree now uses the file view's background color, Folder text color, System / Read-only / Hidden
backgrounds and the glyph fallback font; expand and collapse signs stay visible on a dark background. Derell
decided on no separate setting for the tree.

### CA-052 (1st and 2nd use) [feature] Make Bookmarks easier to discover
Opened 2026-10-24, closed 2026-10-26 (0.98). Done.
Derell's own experience: he went years without finding Bookmarks. Decision: no usage hints in `README.md`;
write a short new-user document linked from the Start Menu. It became `Documents/Tips_and_Tricks.md`
(expanded on 2026-10-27 with address bar modes, tab options, file list colors, File Search, the tray icon,
settings folders and command-line switches). Closed when the Start Menu entry was added, untested at the time.

### CA-015 [bug] Folder text color not applied to selected items, other panels lack colors and fallback font
Opened 2026-10-23, closed 2026-10-26 (0.98). Closed with no code change; the open parts moved on.
The Folders tree work became CA-053 (2nd use) and the selected-folder color became CA-054 (2nd use); both
were done the same day. The worry that emoji names would show as boxes was tested on 2026-10-26 and they
display correctly in the file view.

### CA-014 [bug] `layout.xml` holds about 2000 blank lines
Opened 2026-10-23, closed 2026-10-26 (0.98). Fixed, confirmed by Derell.
Stray indentation-only text nodes in the FileView toolbar section were harmless but ugly. They are now
stripped when the file is loaded, so the saved file is clean.

### CA-012 [bug] Docking a floating panel back only works at the window edge
Opened 2026-10-23, closed 2026-10-26 (0.98). Closed with no action.
An override that docks when the panel's border touches an empty window edge was tried and reverted. The
program behaves like the original CubicExplorer here (JVCL drop-zone logic), so it was left alone.

### CA-011 [bug] File view does not auto-update when files are added
Opened 2026-10-23, closed 2026-10-26 (0.98). Closed as "Zen browser specific". **That conclusion was
wrong; see CA-058 (2nd use), 2026-10-30.**
Downloads appeared only after F5. The first suspicion, a drive-type test in `SetNotifyFolder`, was not it:
the watch was set for Downloads. A per-view directory watch fixed it but was reverted for side-effect risk.
Files made with `copy` or `ren`, and Firefox downloads, showed up at once, while downloads from Claude
chat pages in the Zen browser arrived late, so it was filed as Zen-only. Helium and Waterfox showed the same
on 2026-10-30 and the ticket was reopened as CA-058.

## 2026-10-25

### CA-059 (1st use) [task] Address bar folder suggestions
Opened 2026-10-25, closed 2026-10-25 (0.98). Done, confirmed by Derell.
The address bar text box is now a single-line edit with the Windows AutoComplete drop-down (folders only).
Typing, Enter and Esc work; the Ctrl+A check was waived; the breadcrumb toggle was checked last.

### CA-058 (1st use) [task] Test Open All in Tabs after the launch-file items were removed
Opened 2026-10-25, closed 2026-10-25 (0.98). Done, confirmed by Derell.
Derell found no use for "And Launch Files" and "Launch Files Only" under Bookmarks > Open All in Tabs, and
did not want to design tests for them, so both were removed. The plain "Open All in Tabs" item stays. A
separator before it was also removed because it looked noisy.

### CA-057 (1st use) [feature] A first-class "default" session
Opened 2026-10-25, closed 2026-10-25. Dropped by Derell's decision.
The idea: make the plain tab set a real, always-present session. Not wanted; do not propose again.

### CA-056 (1st use) [feature] Merge the Save Session and Manage Sessions dialogs
Opened 2026-10-25, closed 2026-10-25. Dropped by Derell's decision.
The two dialogs overlap, but merging them is a form redesign that would need checking on screen. Not wanted;
do not propose again.

### CA-055 (1st use) [bug] "Save settings automatically" did not do what it said
Opened 2026-10-25, closed 2026-10-25 (0.98). Fixed, tested by Derell.
The per-session flag was honored only at exit or when switching sessions. Now, while a session with the
flag is active, tab changes are written to `sessions.xml` within a few seconds (a 3 second timer). The check
box caption now says "Save changes to this session automatically" and is also in the Save Session dialog.

### CA-054 (1st use) [bug] Saved sessions were gone after restarting the program
Opened 2026-10-25, closed 2026-10-25 (0.98). Fixed; the original cause was never confirmed.
Sessions worked until the program was closed and reopened. Save only changed memory and `sessions.xml` was
written once at shutdown. Save now writes the file at once and makes the saved session the active one. A
DbgView log showed sessions surviving restarts. The 0.98 session rules (History for plain tab sets only,
Continue from last time returns to the active session) were settled the same day.

### CA-053 (1st use) [feature] "New Session" menu item
Opened 2026-10-25, closed 2026-10-25 (0.98). Done, tested by Derell.
Sessions > New Session closes all tabs (after a History snapshot) and opens one tab at This PC.

### CA-051 (1st use) [feature] "Add to Bookmarks" in the file view's right-click menu
Opened 2026-10-24, closed 2026-10-25 (0.98). Partly done; the rest was dropped, reason not recorded.
Without the Bookmarks panel open, a new user would never find how to add a bookmark. Done on 2026-10-24: the
Bookmarks menu starts with "Bookmark current folder". The right-click entry (it would mean hooking the
standard Explorer shell menu) was removed from the list on 2026-10-25 with no reason written down.

### CA-050 [feature] Background color for selected extensions
Opened 2026-10-23, closed 2026-10-25 (0.98). Done, tested by Derell in all views.
Wanted for files that should stand out (mainly `.bak`), as in Derell's `ndir32` directory lister. Each entry
in the extension color list got "Enable background color" and a second color box, stored as optional extra
fields so old `settings.xml` files still load. Attribute backgrounds win over extension backgrounds (Derell's
decision: an attribute must never be concealed).

### CA-043 [task] `command-line-build.md` is obsolete
Opened 2026-10-23, closed 2026-10-25 (0.98). Retired.
Delphi Community Edition cannot compile from the command line. Derell removed the item himself ("remove
issue from list"); the document is no longer among the project documents.

### CA-010 [feature] Attribute backgrounds in Tile and Thumbnail views
Opened 2026-10-23, closed 2026-10-25 (0.98). Done, tested by Derell in all views.
The System / Read-only / Hidden / Combined backgrounds showed only in Report, List and SmallIcon views. Added
Icon, Thumbnail and Tile view items. Filmstrip behaves like the original CubicExplorer and is accepted.

## 2026-10-24

### CA-032 (2nd use) [task] Follow-ups to the third-party notices
Opened 2026-10-24, closed 2026-10-24 (0.98). Done.
The notices now describe where `VirtualThumbnails` and `FindFileW` came from, and the unused vendored
`TB2Item.pas` was deleted (Toolbar2000 forbids redistributing modified copies).

### CA-008 [feature] Re-arrange bookmarks by dragging in the Bookmarks panel
Opened 2026-10-24, closed 2026-10-24 (0.97). Done, confirmed by Derell.
Found while testing Bookmarks (CA-006). It took seven rounds: a crash walking past the tree's root node,
a missing drop indicator and drop zones, and the real obstacle, that Virtual Treeview 8 never delivers a
Delphi (VCL) drop for internal drags. Switching the tree to an OLE drag fixed it. Along the way, opening a
bookmark no longer replaces the active tab, a folder tab can be dragged onto the panel to bookmark its
folder, and the Single click mode and Open in new tab by default options were removed.

### CA-007 (2nd use) [bug] Bookmarks panel entries show two icons
Opened 2026-10-24, closed 2026-10-24 (0.97). Fixed, confirmed by Derell.
Virtual Treeview 8 also asks for the state image, so the same icon was drawn twice. The tree now returns no
image for that request.

### CA-006 [task] Test Bookmarks and Sessions
Opened 2026-10-23, closed 2026-10-24 (0.97). Done.
The only thing the first release waited for. Derell's test notes produced CA-007 (2nd use), CA-008, CA-051
(1st use) and CA-052 (1st use).

### CA-005 [task] Announce on the old CubicExplorer forum threads
Opened 2026-10-23, closed 2026-10-24 (0.97). Done.
The first announcement reached fewer places than hoped, which became CA-005a (still open).

### CA-004 [task] Discussion page
Opened 2026-10-23, closed 2026-10-24 (0.97). Done.
GitHub Discussions was chosen and linked from `README.md` before anyone was told about the program.

### CA-003 [task] `make release` for the first version
Opened 2026-10-23, closed 2026-10-24 (0.97). Done.
Version 0.97, dated 2026-10-24, "Initial release (beta)", the first CubicAdventurer release. The item was
removed as done on 2026-10-23, restored the same day because the release had not happened, and closed on
2026-10-24.

### CA-002 [task] THIRD-PARTY-NOTICES.txt
Opened 2026-10-23, closed 2026-10-24 (0.97). Done.
Authors, sources and licenses of the libraries, with the Toolbar2000, PngComponents and Free Pascal linking
exception texts verbatim. It was first installed with a Start Menu entry. On 2026-10-25 Derell decided
developer-only documents stay out of the installer, so it lives in the repo root and is not installed.

## 2026-10-23

### CA-032 (1st use) [task] Options > Tabs "Fit tabs to labels"
Opened 2026-10-23, closed 2026-10-23 (0.97). Fixed, verified.
The "Auto fit tabs" check box worked backwards. It is now "Fit tabs to labels" and checked by default.

### CA-013 [bug] Quickview does not remember its file
Opened 2026-10-23, closed 2026-10-23 (0.97). Closed as by design.
The original CubicExplorer stores no last file either.

### CA-007 (1st use) [task] Wrap up `README.md`
Opened 2026-10-23, closed 2026-10-23 (0.97). Done.
The discussion-page link waited on CA-004.

### CA-001 [task] Installer extras
Opened 2026-10-23, closed 2026-10-23 (0.97). Closed as done.
The ticket asked for the README and other wanted files in the installer and Start Menu, a hand run of the
setup wizard, and a first run from a folder with no XML files and no `settings.path`.
