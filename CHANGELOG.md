#  Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- [Mac] Added the launch-to-last-draft functionality in the Editor Launching Policy.
- [Mac] Holding the Shift key when launching clears the app's "last draft" state and instead loads a new blank draft.
- [Mac] Added a menu item for toggling the toolbar.
- [Mac] In a post with unpublished changes (i.e., with "local" or "edited" status), the post is autosaved after a one-second pause in typing.
- [iOS/Mac] Added a context-menu item to delete local posts from the post list.
- [iOS/Mac] Added methods to fetch device logs.
- [iOS] Added a settings option to generate a log file as a new local draft (iOS 15+).

### Changed

- [Mac] The published date now reflects the time a post was published, not created.
- [Mac] If the option is set, the app now silently checks for updates on launch.
- [Mac] New drafts are created in the currently-selected blog, rather than being created in Drafts (or "Anonymous" for Write.as accounts).
- [Mac] Updated the URL and minimum version of the WriteFreely Swift package.
- [Mac] Upgraded the Sparkle package to v2.
- [Mac] The app now prompts you to reach out to our user forums if it detects a crash.

### Fixed

- [Mac] Improved reliability of the toolbar when a post is selected.
- [Mac] Find and replace now works as expected in the post editor.
- [Mac] Formatting is stripped from text that is pasted into the post editor.
- [Mac] New posts use proper linespacing.
- [Mac] The post status updates correctly after publishing local changes to an existing post.
- [Mac] The server URL field is better validated when logging in to a WriteFreely instance/Write.as.
- [Mac] Fixed a regression where text color did not adapt to dark mode correctly.
- [Mac] Sharing a post now uses the custom domain (if any).
- [Mac] The window is now restored when clicking on the app icon in the dock.
- [Mac] Fixed a potential crash if the system keychain wasn't available at app launch.
- [Mac] Cleaned up some straggling project warnings.
- [Mac] Improved error-handling under the hood for better app stability.
- [Mac] Selecting another collection while a blank draft is in the editor now works as expected.
- [Mac] Fixed a bug where the new-post button doesn't appear in the iOS 16 beta.
- [Mac] Fixed a bug where the list of posts published outside of a blog didn't update its title (Drafts/Anonymous).
- [Mac] Fixed a bug where alerts weren't presented for login errors.
- [Mac] Fixed some build warnings in the project.
- [Mac] Bumped WriteFreely package to v0.3.6 to handle decoding of fractional seconds in dates.

## [1.0.14-ios] - 2022-12-18

- [iOS] Temporarily removed the new-draft-on-launch feature while investigating a crashing bug.

## [1.0.13-ios] - 2022-11-13

- [iOS] Fixed an issue that made it tricky to scroll in the post editor.
- [iOS] Fixed a bug that didn't navigate to the post editor after tapping the new-post button. 

## [1.0.12-ios] - 2022-10-06

### Changed

- [iOS] The post editor now scrolls the title as well as the post body to better use all screen real estate.

### Fixed

- [iOS] Bumped WriteFreely package to v0.3.6 to handle decoding of fractional seconds in dates. 

## [1.0.11-ios] - 2022-09-07

### Fixed

- [iOS] Fixed a bug where the new-post button doesn't appear in the iOS 16 beta.
- [iOS] Fixed a bug where the list of posts published outside of a blog didn't update its title (Drafts/Anonymous).
- [iOS] Fixed a bug where alerts weren't presented for login errors.
- [iOS] Fixed some build warnings in the project.

## [1.0.10-ios] - 2022-07-28

### Added

- [iOS] The app now prompts you to reach out to our user forums if it detects a crash.

### Fixed

- [iOS] Improved error-handling and alerting under the hood, for better app stability.

## [1.0.9-ios] - 2022-04-02

- [iOS] Fixed an issue when building for iOS 15 on Xcode 13 that caused the post list to underlap the navigation bar.
- [iOS] Cleaned up some straggling project warnings.

## [1.0.8-ios] - 2021-12-03

### Added

- The app now includes an action extension; activate it in Safari by tapping the Share button, and choosing "Create WriteFreely draft" from the available actions.

### Changes

- To enable sharing of data between the app and the action extension, both the Core Data local store and User Defaults have been moved to an App Group.

## [1.0.7-ios] - 2021-10-01

### Fixed

- Fixed a bug that would cause the app to cancel navigation from the post list to the blog list on iPhone.
- Fixed a potential crash if the system keychain wasn't available at app launch.
- Fixed a bug that prevented navigation to the post list when selecting a blog on iPhone on iOS 15.
- Fixed a bug that prevented the Settings sheet from displaying on iOS 15.

## [1.0.6-ios] - 2021-06-10

### Changed

- Updated the URL and minimum version of the WriteFreely Swift package.

## [1.0.5-ios] - 2021-04-12

### Fixed

- Sharing a post now uses the custom domain (if any).
- Creating a new post no longer navigates away from the currently selected blog to the Drafts list.

## [1.0.4-ios] - 2021-02-15

### Changed

- The published date now reflects the time a post was published, not created.

### Fixed

- Restored the launch-to-last-draft functionality in the Editor Launching Policy.
- The post status updates correctly after publishing local changes to an existing post.
- The server URL field is better validated when logging in to a WriteFreely instance/Write.as.

## [1.0.2-ios] - 2021-01-20

### Added

- A link has been added to the the Settings sheet to review the app on the App Store.

### Fixed

- Multiple accessibility issues with VoiceOver text were fixed.
- Navigating through the app now animates properly.
- Fixed a bug on iPhone where leaving the post editor would sometimes send you right back to the editor. 

## [1.0.1-ios] - 2020-11-18

This version rolls up the iOS beta releases for publishing on the App Store. From this point forward, tags will use the `-ios` and `-mac`
suffixes to differentiate between platforms, until both are at feature parity.

## [1.0.1b3-ios] - 2020-11-13

### Fixed

- Fixed a bug where adding certain characters to your post (like emoji, for example) would cause the cursor to jump to the end of the post.  

## [1.0.1b2-ios] - 2020-11-11

### Added

- Added short extracts of the post body to the post list when the post has no title.

### Fixed

- Fixed a silent failure where the app would appear to login but could not get a valid access token from the server.
- Fixed a bug that would jump the cursor to the end of the post when typing in the middle of the post body.

## [1.0.1b1-ios] - 2020-11-09

### Added

- A link in the Settings screen of the app now points to the How-To guide in the forum.
- A link in the README to the App Store product page for the iOS app.
- An alert now warns you if you try to perform a task that requires an internet connection when there is no network connection.

### Changed

- Local posts are no longer deleted when logging out.
- The app now requires you to confirm when logging out, and indicates how many local edits will be lost by doing so.
- Various editor improvements:
    - The cursor now focuses on the title field and brings up the keyboard when loading a post in the editor.
    - The Return key navigates from the title field to the body field.
    - The title field now automatically increases its height as the text wraps.
    - Increased the line spacing in both the title and body fields.
- When logged out, the app now only shows the "Drafts" list, rather than the "All Posts" list.
- Buttons that handle network requests (e.g. publishing, reloading from server) now show a busy indicator while waiting to complete the task.

### Fixed

- After moving a post from Drafts/Anonymous to a blog, the share link format retained the old single-post format. This is now fixed.
- The placeholder text on new (empty) posts now shows reliably.
- The title and body fields in the editor are better aligned. 
- The app more consistently loads the last draft (or a new draft) on launch.
- Fixed a crash on launch that was caused by the list of posts from local storage was being changed while being fetched. 

## [1.0.0] - 2020-10-20

### Known Issues

- Publishing changes to the server doesn't update the badge status from 'Edited' to 'Published' until you tap the Publish button a second time.
- When moving a published post from Drafts to a blog, the share link does not update accordingly.
    - **Workaround:** Log out of your account and then log back in. This will **permanently delete** any unpublished posts and changes!

### Added

- A new Menu button has been added to the post editor to collect all post-related functions.
- When you first publish a local draft, you're now asked where it should be published (i.e. to Drafts, or to one of your blogs).
- You can now move a post to a collection from the post editor menu.

### Changed

- New local posts are now always created as Drafts.
- The post editor's Publish and Share buttons are now found under a new Menu button.
- Logging in now ignores any path added to the server URL.
- The WriteFreely Swift package now requires v0.3.0 as the minimum version. 

### Fixed

- Fixed a bug where entering an invalid server URL would hang the login attempt. 
- Fixed a crash that could occur when sharing a post on iPad.
- Fixed a bug that set the post status to 'Edited' after updating a published post to a newer version from the server.
- Fixed a release name in this change log.

## [1.0.0b1] - 2020-10-02

### Added

- The "All Posts" list now shows which blog a post belongs to.

### Fixed

- Fixed a crash that could occur when tapping the share button.
- Fixed a visual glitch that made the post list overlap the navigation bar when scrolling on iPhone and iPad. 
- Fixed a link in the change log; added date to the 1.0.0a1 release.

## [1.0.0a1] - 2020-09-30

### Added

- A support link in the Settings screen lets you access the help forum.
- You can now delete local posts.
- You are now prompted for action when viewing a post that was deleted from the server.
- You can now choose a default font for new local drafts in the Settings screen.
- The post editor shows your content in the set typeface.
- Placeholder text has been added to the post editor.
- [iOS] The URL of published posts can be shared from the post editor via the system share sheet.

### Changed

- The collection list now shows the WriteFreely instance name (or just "WriteFreely" if logged out).
- The Publish and Reload buttons are disabled if there's no network connection.
- The post editor's status badge has been moved to the top of the screen.
- The layout of the post editor has been improved to provide a larger editing area on iPhone.
- The app now launches to either the last draft you were working on, or a new blank post.
- Empty local posts are discarded when you navigate away from the post editor.
- Server addresses with an insecure protocol ("http://") are upgraded to a secure protocol ("https://") before login is attempted.
- Attempting to publish a post when you're not logged in presents the login form.

### Fixed

- Language-related properties "lang" and "rtl" are set for new posts based on the system's locale.
- The keyboard is now dismissed on publishing a post.
- Server addresses can now be entered without the protocol ("https://") when logging in.
- [iPadOS] Fixed a crash when dismissing a blank post.

## [0.1.1] - 2020-09-14

### Added

- Icon asset for App Store.
- [iOS] LaunchScreen storyboard added for iPad multitasking requirements .

## [0.1.0] - 2020-09-11

### Added

- Post editor now has a Publish button to publish a post.
- Collections sidebar to choose a specific collection (i.e., blog).
- Settings to provide the user interface for logging in, setting preferred color scheme.
- The WriteFreelyModel type consolidates other models as Published properties in a single EnvironmentObject.
- Logging in and out a WriteFreely instance is now possible.
- Collections and Posts are now persisted to local storage between app launches.
- Content can be reloaded from the server.
- Collections and Posts are purged from the database on logout.
- Apps now have app icons.

### Changed

- Updated license from AGPLv3 to GPLv3.
- Types have been renamed to be more consistent.
- WriteFreely Swift package version bumped to v0.2.1.
- Local posts are now badged as `local` instead of `draft`.

## [0.0.2] - 2020-07-30

### Added

- Basic post list for displaying (local) posts.
- Basic post editor for:
    - Creating a new local draft (title and content only)
    - Updating a (local) post
- Badge for post status (`draft`, `edited`, `published`).

## [0.0.1] - 2020-07-22

### Added

- WriteFreely Swift package.
- SwiftLint build phase for both macOS and iOS targets.
- Project metadocuments, including:
    - Project readme
    - APGL v3 license
    - Code of conduct
    - Contributing guide
    - This changelog

[Unreleased]: https://github.com/writeas/writefreely-swiftui-multiplatform/compare/v1.0.14-ios...HEAD
[1.0.14-ios]: https://github.com/writeas/writefreely-swiftui-multiplatform/compare/v1.0.13-ios...v1.0.14-ios
[1.0.13-ios]: https://github.com/writeas/writefreely-swiftui-multiplatform/compare/v1.0.12-ios...v1.0.13-ios
[1.0.12-ios]: https://github.com/writeas/writefreely-swiftui-multiplatform/compare/v1.0.11-ios...v1.0.12-ios
[1.0.11-ios]: https://github.com/writeas/writefreely-swiftui-multiplatform/compare/v1.0.10-ios...v1.0.11-ios
[1.0.10-ios]: https://github.com/writeas/writefreely-swiftui-multiplatform/compare/v1.0.9-ios...v1.0.10-ios
[1.0.9-ios]: https://github.com/writeas/writefreely-swiftui-multiplatform/compare/v1.0.8-ios...v1.0.9-ios
[1.0.8-ios]: https://github.com/writeas/writefreely-swiftui-multiplatform/compare/v1.0.7-ios...v1.0.8-ios
[1.0.7-ios]: https://github.com/writeas/writefreely-swiftui-multiplatform/compare/v1.0.6-ios...v1.0.7-ios
[1.0.6-ios]: https://github.com/writeas/writefreely-swiftui-multiplatform/compare/v1.0.5-ios...v1.0.6-ios
[1.0.5-ios]: https://github.com/writeas/writefreely-swiftui-multiplatform/compare/v1.0.4-ios...v1.0.5-ios
[1.0.4-ios]: https://github.com/writeas/writefreely-swiftui-multiplatform/compare/v1.0.2-ios...v1.0.4-ios
[1.0.2-ios]: https://github.com/writeas/writefreely-swiftui-multiplatform/compare/v1.0.1-ios...v1.0.2-ios
[1.0.1-ios]: https://github.com/writeas/writefreely-swiftui-multiplatform/compare/v1.0.0...v1.0.1-ios
[1.0.1b3-ios]: https://github.com/writeas/writefreely-swiftui-multiplatform/compare/v1.0.1b2-ios...v1.0.1b3-ios
[1.0.1b2-ios]: https://github.com/writeas/writefreely-swiftui-multiplatform/compare/v1.0.1b1-ios...v1.0.1b2-ios
[1.0.1b1-ios]: https://github.com/writeas/writefreely-swiftui-multiplatform/compare/v1.0.0...v1.0.1b1-ios
[1.0.0]: https://github.com/writeas/writefreely-swiftui-multiplatform/compare/v1.0.0b1...v1.0.0
[1.0.0b1]: https://github.com/writeas/writefreely-swiftui-multiplatform/compare/v1.0.0a1...v1.0.0b1
[1.0.0a1]: https://github.com/writeas/writefreely-swiftui-multiplatform/compare/v0.1.1...v1.0.0a1
[0.1.1]: https://github.com/writeas/writefreely-swiftui-multiplatform/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/writeas/writefreely-swiftui-multiplatform/compare/v0.0.2...v0.1.0
[0.0.2]: https://github.com/writeas/writefreely-swiftui-multiplatform/compare/v0.0.1...v0.0.2
[0.0.1]: https://github.com/writeas/writefreely-swiftui-multiplatform/releases/tag/v0.0.1
