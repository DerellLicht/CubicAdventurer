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

**Use a bookmark**
- Double-click a folder bookmark to open it in the current tab. With **Open in new tab by default**
  turned on (Tools > Options > Display > Bookmarks), it opens in a new tab instead. Right-click >
  **Open in new tab** or a middle-click also opens a new tab.
- Double-click a file bookmark to launch the file.
- With **Single click mode** (same options page), one click is enough.

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

**Save the current tabs**: **Sessions > Save...**, type a name, OK. Using an existing name
overwrites that session.

**Load a session**: pick it from the **Sessions** menu (saved sessions are listed there) or from
the Sessions toolbar. **Loading closes all current tabs first**, then opens the saved ones.

**Sessions > Manage...** lets you delete sessions, change their order by dragging, and switch
**Save settings automatically** for a session (the session is updated with your current tabs when
you switch away from it).

**History** (a submenu of **Sessions**) keeps automatic snapshots:
- **Add History Item** takes a snapshot now.
- **Auto Save History** takes one every time you exit. The last 10 are kept.
- **Clear History** deletes them all.

**Start with your tabs back**: Tools > Options > General > **On Startup**:
- **Open default tab**: the normal start.
- **Continue from last time**: restores the tabs you had when you last closed the program.
- **Load session**: starts with a saved session of your choice.

Note: for now only **tabs** are saved in a session. The Bookmarks and Layouts check boxes in the
Manage dialog have no effect yet.
