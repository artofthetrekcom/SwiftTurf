# SwiftTurf

[![Version](https://img.shields.io/cocoapods/v/SwiftTurf.svg?style=flat)](http://cocoapods.org/pods/SwiftTurf)
[![License](https://img.shields.io/cocoapods/l/SwiftTurf.svg?style=flat)](http://cocoapods.org/pods/SwiftTurf)
[![Platform](https://img.shields.io/cocoapods/p/SwiftTurf.svg?style=flat)](http://cocoapods.org/pods/SwiftTurf)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

### CocoaPods

SwiftTurf is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "SwiftTurf"
```

### Bundle JS assets to `dist/bundle.js` 
- Setup [nodejs](https://nodejs.org/en/) (use the LTS version)
- Install [Browserify](http://browserify.org/#install) globally - `npm install -g browserify`
- Open terminal and change directory `cd Assets/js`
- Run `browserify lib.js -o dist/bundle.js`     
    * If any issue occurs at brows try removing `node_modules` directory and run the command again 

### Carthage

```
github "AirMap/SwiftTurf" ~> 0.3.1
```

## Author

Adolfo Martinelli, adolfo@airmap.com

## License

SwiftTurf is available under the MIT license. See the LICENSE file for more info.
