#  Mac Software Updater

To make updating the Mac app easy, we're using the [Sparkle framework][1].

This is added to the project via the Swift Package Manager (SPM), but at the time of writing, tagged versions of Sparkle do not yet support
SPM — the dependency can only be added from a branch or commit. To avoid any surprises arising from updates to the project's `master`
branch, we're using [WriteFreely's fork of Sparkle][2]. Updates to the forked repository from upstream should be considered dangerous and
tested thoroughly before merging into `main`.  

<!--references-->
[1]: https://sparkle-project.org
[2]: https://github.com/writefreely/Sparkle
