#  Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- A support link in the Settings screen lets you access the help forum.
- You can now delete local posts.
- You are now prompted for action when viewing a post that was deleted from the server.
- You can now choose a default font for new local drafts in the Settings screen.
- The post editor shows your content in the set typeface.
- Placeholder text has been added to the post editor.

### Changed

- The collection list now shows the WriteFreely instance name (or just "WriteFreely" if logged out).
- The Publish and Reload buttons are disabled if there's no network connection.
- The post editor's status badge has been moved to the top of the screen.
- The layout of the post editor has been improved to provide a larger editing area on iPhone.
- The app now launches to either the last draft you were working on, or a new blank post.
- Empty local posts are discarded when you navigate away from the post editor.
- Server addresses with an insecure protocol ("http://") are upgraded to a secure protocol ("https://") before login is attempted.

### Fixed

- Language-related properties "lang" and "rtl" are set for new posts based on the system's locale.
- The keyboard is now dismissed on publishing a post.
- Server addresses can now be entered without the protocol ("https://") when logging in.

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

[Unreleased]: https://github.com/writeas/writefreely-swiftui-multiplatform/compare/v0.1.1...HEAD
[0.1.1]: https://github.com/writeas/writefreely-swiftui-multiplatform/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/writeas/writefreely-swiftui-multiplatform/compare/v0.0.2...v0.1.0
[0.0.2]: https://github.com/writeas/writefreely-swiftui-multiplatform/compare/v0.0.1...v0.0.2
[0.0.1]: https://github.com/writeas/writefreely-swiftui-multiplatform/releases/tag/v0.0.1
