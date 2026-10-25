# Bookmarks and Sessions: quick guide

Two ways to get back to where you were. **Bookmarks** remember places (folders, files, even
sessions). **Sessions** remember a whole set of open tabs.

## Bookmarks

Open the Bookmarks panel with **Ctrl+2** (or the **Bookmarks** menu). It is a tree of
categories and bookmarks, stored in `bookmarks.xml` in the settings folder.

**Add a category or bookmark**
1. Right-click in the panel and choose **Add Category** to make a folder-like group.
2. Select the category where the new item should go, switch to a file-list tab, then right-click
   in the panel and choose **Add Bookmark**. The folder shown in that tab is bookmarked.
3. **Rename** and **Delete** are on the same menu. Drag items inside the tree to reorder them or
   move them between categories.

**Quick way:** open the **Bookmarks** menu and choose **Bookmark current folder**. The folder
shown in the active tab is added at the top level of the list, and the panel does not have to
be open. (Drag it into a category afterwards if you want it there.) You can also drag a folder's
tab onto the open Bookmarks panel and drop it where you want the bookmark.

**Use a bookmark**
- Double-click a folder bookmark to open it in a **new tab**. A bookmark never replaces the folder
  of the tab you are in. Where the new tab goes and whether it is selected follow
  Tools > Options > Tabs. A single click only selects the bookmark. Right-click >
  **Open in new tab**, Alt+click or a middle-click do the same.
- Double-click a file bookmark to launch the file.

**Open a whole category at once**: select the category, then right-click > **Open All in Tabs**:
- **Open All in Tabs**: every folder in it opens in its own tab.
- **...And Launch Files**: folders open in tabs and files are launched.
- **...Launch Files Only**: only the files are launched.

**Properties...** shows a bookmark's target. You can change it, browse for another one, or store
it as a relative path.

**Add Session** puts a session in the tree (you pick one from your saved sessions). Opening that
bookmark loads the session.

Other options on the same page: **Auto expand tree** and **Auto collapse tree**.

## Sessions

A session is the set of tabs you have open: each tab's folder and settings, and which tab was
selected. Sessions are stored in `sessions.xml` in the settings folder.

**Start a new session**: **Sessions > New Session** closes all tabs (if they were not part of a
saved session they are first copied to History) and opens a single tab at **This PC**. Open the
folders you want, then use **Sessions > Save...** to give the session a name.

**Update a session once**: **Sessions > Update Current Session** saves the open tabs into the active
session right away. Use it for a one-time change (for example, adding a drive to a session that
does not have **Save changes to this session automatically**).

**Leave a session, keeping the tabs**: **Sessions > Detach from Session**. The tabs stay open but
are no longer part of the session; they are a plain tab set again (and are handled like one at
exit). A session with **Save changes to this session automatically** is brought up to date
first; any other keeps what was saved.

**Save the current tabs**: **Sessions > Save...**, type a name, OK. Using an existing name
overwrites that session. The session is written to disk at once, and it becomes the active
session (the one shown with a check mark in the Sessions menu). Tick **Save changes to this
session automatically** in the same dialog if the session should follow your tabs from now on
(see Manage, below).

**Load a session**: pick it from the **Sessions** menu (saved sessions are listed there) or from
the Sessions toolbar. **Loading closes all current tabs first**, then opens the saved ones.
If the tabs you had open were not part of a saved session, a copy of them is put in **History**
first, so you can get them back from there.

**Sessions > Manage...** lets you delete and rename sessions, change their order by dragging, and
switch **Save changes to this session automatically** for a session. While that session is the
active one, any change to your tabs (a folder, a tab added, closed or moved, the selected tab) is
saved into it within a few seconds, and again when you switch to another session or exit.

**History** (a submenu of **Sessions**) keeps automatic snapshots:
- **Add History Item** takes a snapshot now.
- **Auto Save History** takes one every time you exit. The last 10 are kept.
- **Clear History** deletes them all.

History is for tabs that are *not* part of a saved session. While a saved session is active,
exiting adds nothing to History; the program remembers the session's name instead.

**Start with your tabs back**: Tools > Options > General > **On Startup**:
- **Open default tab**: the normal start.
- **Continue from last time**: if a saved session was active when you closed the program, that
  session is loaded again exactly as saved (with **Save changes to this session automatically**
  off, it returns to the folders you saved, whatever you changed since; with it on, it returns
  to where you left off). Otherwise the tabs you had when you last closed the program are
  restored.
- **Load session**: starts with a saved session of your choice.

Note: a session holds only your open **tabs**.
