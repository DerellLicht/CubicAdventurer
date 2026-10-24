## You

I want to say this to you, at least once... 
Free software should be built with free tools !!!!!!!!!!
Once we get this working, and I get a release that I can hand off for other to work with, I *really* want to take the extra step to get shut of this crippled tool and switch to appropriate open-source development tools...

Whether that is Lazarus or something else, I don't know, but this is ridiculous...

## Claude

That's a fair complaint, and I agree with the principle. A free-to-download compiler that blocks command-line builds and has no scripting access is a real problem for a project that's supposed to be open and handed to others. Without a command-line build, nobody can set up CI or write a Makefile, and I can't compile your code myself, which is exactly why we're stuck doing this by screenshot.

Here is what I know about moving to Lazarus/Free Pascal, so you can weigh it when we talk:

- **The core is portable.** The Pascal itself, the settings and XML code, and the plugin and thread code should move over without much trouble.
- **The libraries are the hard part.** CubicAdventurer leans heavily on Delphi-only components: SpTBX and Toolbar2000 for the toolbars and tabs, the Mustangpeak shell components, and the JVCL docking. Lazarus has ports of Virtual Treeview and Graphics32, but there is no equivalent for those other three. Each would need replacing or rewriting.
- **It is a port, not a recompile.** It would be a project of its own, likely bigger than the Delphi 13 revival. The payoff is a build anyone can run for free, with a command-line compiler and no vendor licence in the way.

My suggestion is to finish getting a clean, tagged release on Delphi first. That gives us a known-good reference to compare a Lazarus port against. I'd add "evaluate the Lazarus/FPC route" to tomorrow's discussion list next to vendoring the libraries, since the two questions are related.

