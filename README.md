# Arex

An iOS application for remembering to take your medications.

## Downloading

The following commands will set up an Arex checkout. You'll need Xcode or the
Command Line Tools installed.

```sh
git clone https://github.com/a2/arex-7.git
cd arex-7
pod install
```
## Getting Started

Arex must be built with [Xcode](https://developer.apple.com/xcode/downloads/)
6.3 or better. Development must be done using `Arex.xcworkspace`, rather than
`Arex.xcodeproj`.

The project may also be built from the command line:

```sh
xcodebuild -workspace Arex.xcworkspace -scheme Arex
```

## Tech Stack

* [Swift](https://developer.apple.com/swift/) 1.2 or better.
* [CocoaPods](http://cocoapods.org)
* [MessagePack.swift](https://github.com/a2/MessagePack.swift)
* [Pistachio](https://github.com/felixjendrusch/Pistachio)
* [ReactiveCocoa](https://github.com/reactivecocoa/reactivecocoa)
* [LlamaKit](https://github.com/LlamaKit/LlamaKit)

## Story

The repository is officially `arex-7`, as it is the seventh complete rewrite with the same goals. It began and continues as a side project, and was open-sourced to make its progress visible and accountable.

Arex was open-sourced live on stage at [Swift Summit](https://www.swiftsummit.com) 2015, one of the first conferences devoted to Swift's community and practices. You can view Alex's talk, ["Death by Indecision"](https://realm.io/news/alexsander-akers-death-by-indecision/).

## Roadmap

Project planning is managed via [GitHub issues](https://github.com/a2/arex-7/issues).
