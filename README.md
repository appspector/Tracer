# Tracer
This repo contains example project and custom Xcode Instruments package for opentracing-like inspection of any activities in your iOS/macOS app.

## Requirements
`os_signpost` API is available starting from iOS 12 and macOS 10.14.
To install custom package you need Xcode 10.

## Installation
To add the package to your Instruments you have to download it from the [Releases](https://github.com/appspector/Tracer/releases/tag/1.0.1), extract, doubleclick and install.
After that it will appear in the list of instruments. Unfortunately there is no way to install and update it automatically.

To use the package you need to issue appropriate os_signpost calls, which is more convinient using wrapper from TracingModule directory in sample project. Wrapper could be installed via CocoaPods:

`pod 'Tracer', '~> 1.0.1'`

or manually by just moving TracingModule directory to your project and importing `Tracer.h`.

## Usage
#### Manual
There are two ways you can play with tracer. First is manually by using the following API:
```objective-c
- (ASScope *)addScope:(NSString *)scopeName;
- (void)removeScope:(NSString *)scopeName;
- (void)startSpan:(NSString *)spanName inScope:(NSString *)scopeName;
- (void)stopSpan:(NSString *)spanName inScope:(NSString *)scopeName success:(BOOL)success;
```
Scopes and spans are concepts describing activites you want to trace, i.e. if you want to trace your view controllers activities scope coud be a view controller and span - any activity performed within it. Span and scope names should be unique. Stopping a span you can pass `success` flag which indicates span completion status, failed spans will be displayed red on a graph lane.

![](https://github.com/appspector/Tracer/blob/master/image-manual.png)

#### Tracing NSOperations
Also you can use tracer to atomatically trace `NSOperation`s using `startTracingOperations` call. This will install hooks and KVO observers to track operations lifecycle.

![](https://github.com/appspector/Tracer/blob/master/image-operations.png)

# Sample app
If you want to play with package yo ucan use Tracer app in the package Xcode project. It allows to create `NSOperationQueue`s and operations inside them and automatically starts tracing them. Install package then start Tracer app, run Instruments, choose blank template add Tracer package to it and start recording:

![](https://github.com/appspector/Tracer/blob/master/image-sample.png)

# Resources
- Article about building custom Instruments pakages:<br>
https://medium.com/appspector/building-custom-instruments-package-9d84fd9339b6
- WWDC session 410 'Creating Custom Instruments'<br>
  https://developer.apple.com/videos/play/wwdc2018/410/
- John Sundell article about os_signpost API<br>
  https://www.swiftbysundell.com/daily-wwdc/getting-started-with-signposts
- Apple Instruments documentation<br>
  https://help.apple.com/instruments/developer/mac/10.0/#/
- CLIPS reference<br>
  http://sequoia.ict.pwr.wroc.pl/~witold/ai/CLIPS_tutorial/


# About Us

Looking for better debugging instrument? Try [AppSpector](https://appspector.com). With AppSpector you can remotely debug your app running in the same room or on another continent. You can measure app performance, view CoreData and SQLite content, logs, network requests and many more in realtime. This is the instrument that you've been looking for.

![](https://storage.googleapis.com/appspector-support/screenshots/appspector_twittercover2.png)
