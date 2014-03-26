# JGORegExpBuilder

[![Build Status](https://travis-ci.org/JanGorman/JGORegExpBuilder.png)](https://travis-ci.org/JanGorman/JGORegExpBuilder)

## Usage

To run the example project; clone the repo, and run `pod install` from the Demo directory first.

You can use the builder in your project like this:

```objc
JGORegExpBuilder *builder = RegExpBuilder().exactly(1).of(@"p");
builder.test(@"p");

// If you want to access the underlying NSRegularExpression
NSRegularExpression *regularExpression = builder.regularExpression;
```

For simple matches use the builder directly. If you want to do more, simply access the `NSRegularExpression`, e.g. to search and replace inside a string.

See the `DemoTests.m` file for some more examples of what you can do

## Installation

JGORegExpBuilder is available through [CocoaPods](http://cocoapods.org), to install
it simply add the following line to your Podfile:

`pod "JGORegExpBuilder"`

## Inspiration

Based on the JavaScript builder by [thebinarysearchtree](https://github.com/thebinarysearchtree/regexpbuilderjs/wiki).

## License

JGORegExpBuilder is available under the MIT license. See the LICENSE file for more info.

