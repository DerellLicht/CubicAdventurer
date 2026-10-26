# Makefile for CubicAdventurer (GNU make, Windows).  Modeled on the dlGrep Makefile.
#
# The program itself is built in the Delphi IDE (Community Edition has no command-line
# compiler): File > Close All, git pull, Shift-F9.  Everything after that is here, and only
# needs CubicAdventurer.exe to exist and to carry the current version.
#
#   make version        show the version (the newest "## [x.yy]" header in CHANGELOG.md)
#   make sync-version   write that version into Source/CubicAdventurer.dproj (then rebuild in the IDE)
#   make check          check the project and the exe both carry the version
#   make installer      build the Inno Setup installer from the existing exe
#   make install        install silently with the setup that "make installer" built (builds nothing)
#   make dist           installer, zipped for upload
#   make release        first release of this version: tag, push, create the GitHub release
#   make update         refresh the release notes and uploaded zip of an existing release
#   make retag          move the tag to HEAD (solo repo only);  make re-release = retag + update
#   make clean          remove installer output
#   make help           list the targets

PYTHON   ?= python
ISCC     ?= D:/InnoSetup7/iscc.exe
GH_REPO  ?= DerellLicht/CubicAdventurer
APP      := CubicAdventurer
DPROJ    := Source/$(APP).dproj
EXE      := $(APP).exe
TAG_PREFIX ?= ca-

# The version lives only in CHANGELOG.md: the newest "## [x.yy]" header, for example 1.00.
VERSION := $(shell grep -E '^## \[[0-9]+\.[0-9]+\]' CHANGELOG.md | head -n 1 | grep -oE '[0-9]+\.[0-9]+')
ifeq ($(VERSION),)
$(error no "## [x.yy]" version header found in CHANGELOG.md)
endif
TAG       = $(TAG_PREFIX)$(VERSION)
SETUP     = installer/output/$(APP)V$(VERSION).setup.exe
SETUP_ZIP = installer/output/$(APP)V$(VERSION).setup.zip

.PHONY: all version sync-version check check-exe installer install install_raw do_inst dist stop release update retag re-release check-clean sha256 clean help

all: help

help:
	@echo "make version        show the version from CHANGELOG.md ($(VERSION))"
	@echo "make sync-version   write it into $(DPROJ); then rebuild in the Delphi IDE"
	@echo "make check          check the project and $(EXE) carry $(VERSION)"
	@echo "make installer      build the installer ($(SETUP)) from the existing $(EXE)"
	@echo "make install        install the built setup silently (builds nothing)"
	@echo "make install_raw    install the built setup interactively"
	@echo "make dist           the installer, zipped for upload"
	@echo "make release        first release of $(TAG): tag, push, GitHub release"
	@echo "make update         refresh the notes and zip of an existing release"
	@echo "make retag          move $(TAG) to HEAD;  make re-release = retag + update"
	@echo "make clean          remove installer output"

version:
	@echo $(VERSION)

# the exe cannot be replaced while it is running; this stops it only if it is running
stop:
	@$(PYTHON) tools/stop_app.py $(APP)

# Copies the changelog version into the Delphi project.  The exe is not rebuilt here.
sync-version:
	@$(PYTHON) tools/version_tool.py sync $(VERSION) $(DPROJ)

# The project and the exe must both carry the changelog version, so an installer or a
# release can never package an exe from before a version bump.
check: check-exe
	@$(PYTHON) tools/version_tool.py check-dproj $(VERSION) $(DPROJ)

check-exe:
	@$(PYTHON) tools/version_tool.py check-exe $(VERSION) $(EXE)

# "clean" runs last among the prerequisites: if "check" fails (exe has the wrong version) make
# stops before anything is deleted.  This empties installer/output so files of an earlier
# version never pile up; dist, release and update all go through this rule.
installer: check stop clean
	"$(ISCC)" /Qp /DMyAppVersion=$(VERSION) installer/$(APP).iss

# Only runs the setup program that "make installer" already built; it does not build anything.
# Silent: no wizard and no questions (Setup closes a running CubicAdventurer itself).
install: stop
	@test -f "$(SETUP)" || { echo "$(SETUP) not found -- run 'make installer' first."; exit 1; }
	"$(SETUP)" /SILENT /SUPPRESSMSGBOXES /NORESTART

# Only runs the setup program that "make installer" already built; it does not build anything.
# *Not* Silent: let me set destination folder, etc.
install_raw: stop
	@test -f "$(SETUP)" || { echo "$(SETUP) not found -- run 'make installer' first."; exit 1; }
	"$(SETUP)" 

do_inst: installer install

dist: installer
	zip -j $(SETUP_ZIP) $(SETUP)

sha256:
	certutil -hashfile $(subst /,\,$(SETUP_ZIP)) SHA256

# Refuses to release from a tree with uncommitted changes, so the tag matches what was built.
check-clean:
	@if [ -n "$$(git status --porcelain)" ]; then \
		echo "ERROR: uncommitted changes present -- commit before releasing."; \
		git status --short; \
		exit 1; \
	fi

# First release of a version: tag HEAD, push the tag, create the GitHub release with the notes
# from CHANGELOG.md and the zipped installer.  Fails at "git tag" if the tag already exists;
# use "make update" for that.  Needs the gh CLI, signed in.
release: check-clean dist stop
	@echo Preparing GitHub release $(TAG)...
	$(PYTHON) tools/release_notes.py $(VERSION) > temp_notes.md
	git tag $(TAG)
	git push origin $(TAG)
	gh release create $(TAG) $(SETUP_ZIP) --title "$(TAG)" --notes-file temp_notes.md -R $(GH_REPO)
	rm temp_notes.md
	@echo Release $(TAG) uploaded to GitHub!

# Refreshes an existing release: replaces the notes and (with --clobber) the uploaded zip; creates
# the release if it does not exist yet.  Does not move the tag; see "retag".
update: check-clean dist stop
	@echo Updating release $(TAG)...
	$(PYTHON) tools/release_notes.py $(VERSION) > temp_notes.md
	@if gh release view $(TAG) -R $(GH_REPO) >/dev/null 2>&1; then \
		echo "Release $(TAG) exists -- updating notes."; \
		gh release edit $(TAG) --notes-file temp_notes.md -R $(GH_REPO); \
	else \
		echo "Release $(TAG) not found -- creating it."; \
		gh release create $(TAG) --title "$(TAG)" --notes-file temp_notes.md -R $(GH_REPO); \
	fi
	rm temp_notes.md
	gh release upload $(TAG) $(SETUP_ZIP) --clobber -R $(GH_REPO)
	@echo Release $(TAG) assets and notes updated on GitHub!

# Recovery for "released, then committed more": force-moves the tag to HEAD and re-pushes.
# Solo repo only (force-pushing a moved tag is unsafe once anyone else has fetched it).
retag: check-clean
	@if git rev-parse $(TAG) >/dev/null 2>&1; then \
		echo "Retagging existing tag $(TAG)."; \
	else \
		echo "Note: $(TAG) does not exist yet -- this will be its first release."; \
	fi
	git tag -f $(TAG)
	git push origin $(TAG) --force

re-release: retag update
	@echo Release $(TAG) retagged and re-released.

clean:
	rm -rf installer/output
