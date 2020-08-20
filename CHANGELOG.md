#  Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Post editor now has a Publish button to change post status 
- Collections sidebar to choose a specific collection (i.e., blog)
- Settings to provide the user interface for logging in, setting preferred color scheme 
- The WriteFreelyModel type consolidates other models as Published properties in a single EnvironmentObject
- Logging in and out a WriteFreely instance is now possible

### Changed

- Updated license from AGPLv3 to GPLv3
- Types have been renamed to be more consistent
- WriteFreely Swift package version bumped to v0.2.1

## [0.0.2] - 2020-07-30

### Added

- Basic post list for displaying (local) posts
- Basic post editor for:
    - Creating a new local draft (title and content only)
    - Updating a (local) post
- Badge for post status (`draft`, `edited`, `published`) 

## [0.0.1] - 2020-07-22

### Added

- WriteFreely Swift package
- SwiftLint build phase for both macOS and iOS targets
- Project metadocuments, including:
    - Project readme
    - APGL v3 license
    - Code of conduct
    - Contributing guide
    - This changelog

[Unreleased]: https://github.com/writeas/writefreely-swiftui-multiplatform/compare/v0.0.2...HEAD
[0.0.2]: https://github.com/writeas/writefreely-swiftui-multiplatform/compare/v0.0.1...v0.0.2
[0.0.1]: https://github.com/writeas/writefreely-swiftui-multiplatform/releases/tag/v0.0.1
