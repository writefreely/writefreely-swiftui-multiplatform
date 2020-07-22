# How to contribute

We're happy you're considering contributing to the WriteFreely SwiftUI multiplatform app!

Before making a contribution, please be sure to familiarize yourself with our contributor's [code of conduct](CODE_OF_CONDUCT.md).

Otherwise, it won't take long to get up to speed on this. Here are our development resources:

* We accept and respond to bugs here on [GitHub](https://github.com/writeas/writefreely-swiftui-multiplatform/issues).
* We're usually in #writeas on freenode, but if not, find us on our [Slack channel](http://slack.write.as).

## Testing

We try to write tests for all public methods in the codebase, but aren't there yet. While not required, including tests with your new code will bring us closer to where we want to be and speed up our review.

## Submitting changes

Please send a [pull request](https://github.com/writeas/writefreely-swiftui-multiplatform/compare) with a clear list of what you've done.

Please follow our coding conventions below and make sure all of your commits are atomic. Larger changes should have commits with more detailed information on what changed, any impact on existing code, rationales, etc.

## Coding conventions

We strive for consistency above all. Reading the codebase should give you a good idea of the conventions we follow.

* We use [SwiftLint](https://github.com/realm/SwiftLint) as a build script
* We fix all warnings before committing anything (including linting warnings!)
* We aim to document all public methods using Swift code documentation
* Swift files are broken up into logical functional components

## Design conventions

We maintain a few high-level design principles in all decisions we make. Keep these in mind while devising new functionality:

* Updates should be backwards compatible or provide a seamless migration path from *any* previous version
* Each method should perform one action and do it well
* Each method will ideally work well in a script
* Avoid clever functionality and assume each function will be used in ways we didn't imagine
