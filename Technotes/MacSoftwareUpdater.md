#  Mac Software Updater

To make updating the Mac app easy, we're using the [Sparkle framework][1].

This is added to the project via the Swift Package Manager (SPM), but at the time of writing, tagged versions of Sparkle do not yet support
SPM — the dependency can only be added from a branch or commit. To avoid any surprises arising from updates to the project's `master`
branch, we're using [WriteFreely's fork of Sparkle][2]. Updates to the forked repository from upstream should be considered dangerous and
tested thoroughly before merging into `main`.  

WriteFreely for Mac uses the v1.x branch of Sparkle, and is therefore not a sandboxed app.

## Troubleshooting

### If Xcode throws an error when you try to build the project

You may need to reset the package caches:

1. From the **File** menu in Xcode, choose **Swift Packages** &rarr; **Reset Package Caches**
2. Again from the **File** menu, choose **Swift Packages** &rarr; **Update to Latest Package Versions**

You should then be able to build and run the Mac target.

### If you can't run `generate_keys` because "Apple cannot check it for malicious software"

There may be a code signing issue with Sparkle. Right-click on `generate_keys` in the Finder and choose Open ([reference][3]). 

## Deploying Updates

To [publish an update to the app][5], you'll need the **Sparkle-for-Swift-Package-Manager.zip** [archive][4] — specifically, you'll need the
`generate_appcast` tool. Download and de-compress the archive.

You will need some credentials and signing certificates to proceed with this process; speak to the project maintainer if you're responsible for
creating the update, and confirm you have:

- the app's Developer ID Application certificate (check your Mac's system Keychain)
- the Sparkle EdDSA signing key (again, check your Mac's system Keychain)

Sign and notarize the app archive, then click on **Export Notarized App** in Xcode's Organizer window. Open the Terminal and navigate to
where you de-compressed the Sparkle-for-Swift-Package-Manager archive, then create a zip file that preserves symlinks:

```bash
% ditto -c -k --sequesterRsrc --keepParent <source_path_to_app> <zip_destination>
```

For example, if you export the notarized app to the desktop, all prior updates are located in `~/Developer/WriteFreely/Updates`, and
the final archive should be called `WFMac.zip`, you would run:

```bash
% ditto -c -k --sequesterRsrc --keepParent ~/Desktop/WriteFreely\ for\ Mac.app ~/Developer/WriteFreely/Updates/WFMac.zip
```

Then, generate an appcast file:

```bash
% ./bin/generate_appcast ~/Developer/WriteFreely/Updates
```

Once that's done, upload the appcast.xml and WFMac.zip files to the update distribution server (`files.writefreely.org/apps/mac`)
and they'll be made available to users.

<!--references-->
[1]: https://sparkle-project.org
[2]: https://github.com/writefreely/Sparkle
[3]: https://github.com/sparkle-project/Sparkle/issues/1701#issuecomment-752249920
[4]: https://github.com/sparkle-project/Sparkle/releases/tag/1.24.0
[5]: https://sparkle-project.org/documentation/publishing/
