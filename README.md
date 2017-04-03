# JSONSerializable
[![GitHub release](https://img.shields.io/github/release/mvanallen/JSONSerializable.svg)]()
[![Supported platforms](https://img.shields.io/badge/platforms-_macOS_%7C%20iOS_%7C%20watchOS_%7C%20tvOS_%7C%20Linux-000000.svg)]()
[![license](https://img.shields.io/github/license/mvanallen/JSONSerializable.svg)]()
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg)](https://github.com/Carthage/Carthage)
[![Swift Package Manager compatible](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)

**JSONSerializable** is multi-platform library for quick and easy serialization of Swift data structures to JSON. It supports any combination of the following types:

- Struct
- Dictionary, Array
- String, Number, Bool, NSNull
- Date, URL

The implementation is massively based on *Emil Loer*'s excellent post [An easy way to convert Swift structs to JSON][codelle-original-post],
so he deserves all the credit for it. If you haven't done so already, then you should definitely check out his [blog][codelle-blog].


## Requirements

- XCode 8
- Swift 3


## Installation

### Carthage

Add the library as a dependency to your `Cartfile`:

 ```sh
 # Create/update cartfile
 $ echo 'github "mvanallen/JSONSerializable" ~> 1.0' >> Cartfile
 
 $ carthage update JSONSerializable
 ```

Afterwards, integrate the framework into your build phase according to [Carthage's installation instructions][carthage-installation].

### Swift Package Manager

Add the library to the `dependencies` of your `Package.swift`:

 ```sh
 dependencies: [
     .Package(url: "https://github.com/mvanallen/JSONSerializable.git", majorVersion: 1)
 ]
 ```
 ```
 $ swift package fetch
 ```

For more information, please refer to the [Swift Package Manager][swiftpm-installation] documentation.

### Manually

You can also integrate the framework manually into your project.

#### …as a submodule

 ```sh
 $ git submodule add https://github.com/mvanallen/JSONSerializable.git
 ```

#### …by building from source

 ```sh
 $ git clone https://github.com/mvanallen/JSONSerializable.git
 ```

Open the project, select the appropriate build target and create a release archive using `XCode > Product > Archive`.

Alternatively, as the source is small and has no external dependencies, you can just drop `JSONSerialization.swift` into your own project and be done with it.


## Usage

The library consists of 2 protocols that you can adopt:

1. **JSONRepresentable** – Used by objects to provide a representation of their value that is
	serializable by Foundation's `JSONSerialization` class. In practice, you mostly don't adopt it directly,
	as it is generally meant for direct extension of "single-value" type classes (i.e. `Date` or `URL).
	
	For example, this is the complete implementation that adds serialization support to `URL`:
	
	```swift
	extension URL: JSONRepresentable {
		public var JSONRepresentation: Any {
			return self.absoluteString
		}
	}
	```
	
2. **JSONSerializable** – Adopt this protocol to support serialization of collection- (or "multi-value"-) classes
	and structs. Its default implementation of `JSONRepresentation` recursively collects serializable representations
	of its internal subvalues.
	
To make a struct serializable, formally adopt the `JSONSerializable` protocol..

```swift
struct Entry: JSONSerializable {
	var name: String
	var timestamp: Date
	var urls: [URL]
}
```

..then call the `toJSON()` method to have the protocol extension automatically convert the instance into a serializable
structure, do the conversion and return the corresponding JSON string:

```swift
let entry = Entry(name: "log", timestamp: Date(), urls: [URL(string: "http://google.com")!, URL(string: "http://apple.com")!])

if let json = entry.toJSON() {
	print("### JSON: \(json)")
}

// ### JSON: {"timestamp":"2017-04-03T15:09:49.087Z","name":"log","urls":["http://google.com","http://apple.com"]}
```

**Important:** If the serialization encounters a type that it cannot serialize, it will opt to **skip** the value, output a warning
to the console and continue normally (instead of failing). For example:

```swift
struct Entry: JSONSerializable {
	var name: String
	var binary: Data
}

let entry = Entry(name: "log", binary: "CAFE".data(using: .utf8)!)

if let json = entry.toJSON() {
	print("### JSON: \(json)")
}

// [JSONSerializable.JSONRepresentation] *** WARNING – (Entry #1): OMITTING property 'binary: Data' w/ non-representable value: 4 bytes
// ### JSON: {"name":"log"}
```


## Development Notes

### Testing on Linux

If you have `Docker` installed, here's an easy way to quickly check the testcases in a Linux container:

```sh
 $ docker run --rm -v "$(pwd)":/home/src swift:3.1 /bin/bash -c "cd /home/src && swift package fetch && swift package clean && swift test"
```

### Building releases with Carthage

To quickly build a release `.zip` of all targets for binary deployment, use:

```sh
carthage build --no-skip-current && carthage archive
```


## License

JSONSerializable is released under the MIT license. [See LICENSE](https://github.com/mvanallen/JSONSerializable/blob/master/LICENSE) for details.


## Links

- [Codelle Blog: An easy way to convert Swift structs to JSON][codelle-original-post]

[codelle-original-post]: http://codelle.com/blog/2016/5/an-easy-way-to-convert-swift-structs-to-json/
[codelle-blog]: http://codelle.com/blog/
[carthage-installation]: https://github.com/Carthage/Carthage#adding-frameworks-to-an-application
[swiftpm-installation]: https://swift.org/package-manager/
