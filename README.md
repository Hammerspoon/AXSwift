# AXSwift

> [!IMPORTANT]
> This is [Hammerspoon](https://github.com/Hammerspoon/Hammerspoon2)'s fork of
> [AXSwift](https://github.com/tmandry/AXSwift) (by way of
> [mredig/AXSwift](https://github.com/mredig/AXSwift)). It carries changes that exist to suit
> Hammerspoon and aren't expected to go upstream.

## Divergences from upstream

- **Request gate** (`UIElement.requestGate`, in `Sources/RequestGate.swift`): an optional closure
  consulted before every request a `UIElement`, `Application` or `Observer` sends. It's given the
  target application's process ID and returns `nil` to let the request through, or the `AXError`
  to throw instead. Hammerspoon uses it to refuse accessibility requests to itself made off the
  main thread: the system answers an app's requests to itself by calling the app's own
  `NSAccessibility` code directly, on the requesting thread, so those would run AppKit and SwiftUI
  code on a background thread. With no gate set (the default), AXSwift behaves as upstream does.

[![Version](https://cocoapod-badges.herokuapp.com/v/AXSwift/badge.svg)](https://cocoapods.org/pods/AXSwift)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

AXSwift is a Swift wrapper for macOS's C-based accessibility client APIs. Working with these APIs is
error-prone and a huge pain, so AXSwift makes everything easier:

- Modern API that's 100% Swift
- Explicit error handling
- Complete coverage of the underlying C API
- Better documentation than Apple's, which is pretty poor

This framework is intended as a basic wrapper, and doesn't keep any state or do any "magic".
That's up to you!

## Using AXSwift

### SPM
In your Package.swift:
```
.package(url: "https://github.com/tmandry/AXSwift", from: "0.3.0"),
```

### Carthage
In your Cartfile:
```
github "tmandry/AXSwift" ~> 0.3
```

### CocoaPods
In your Podfile:
```
pod 'AXSwift', '~> 0.3'
```

See the source of [AXSwiftExample](https://github.com/tmandry/AXSwift/blob/master/AXSwiftExample/AppDelegate.swift)
and [AXSwiftObserverExample](https://github.com/tmandry/AXSwift/blob/master/AXSwiftObserverExample/AppDelegate.swift)
for an example of the API.

## Related Projects

[Swindler](https://github.com/tmandry/Swindler), a framework for building macOS window managers in Swift,
is built on top of AXSwift.
