# Tracer
This repo contains example project and custom Xcode Instruments package for opentracing-like inspection of any activities in your iOS/macOS app.

## Installation
To add the package to your Instruments you have to download it from the Releases, extract, doubleclick and install.
After that it will appear in the list of instruments. Unfortunately there is no way to install andupdate it automatically.

To use the package you need to issue appropriate os_signpost calls, which is more convinient using wrapper from TracingModule directory in sample project. Wrapper could be installed via CocoaPods:

`pod 'Tracer', '~> 1.0.0'`

or manually by just moving TracingModule directory to your project and importing `Tracer.h`.

## Usage
There are two ways you can play with tracer. First is manually by using the following API:
```
- (ASScope *)addScope:(NSString *)scopeName;
- (void)removeScope:(NSString *)scopeName;
- (void)startSpan:(NSString *)spanName inScope:(NSString *)scopeName;
- (void)stopSpan:(NSString *)spanName inScope:(NSString *)scopeName success:(BOOL)success;
```
Scopes and spans are concepts describing activites you want to trace, i.e. if you want to trace your view controllers activities scope coud be a view controller and span - any activity performed within it. Span and scope names should be unique. Stopping a span you can pass `success` flag which indicates span completion status, failed spans will be displayed red on a graph lane.

Also you can use tracer to atomatically trace `NSOperation`s using `startTracingOperations` call. This will install hooks and KVO observers to track operations lifecycle.

# About Us

Looking for better debugging instrument? Try [AppSpector](https://appspector.com). With AppSpector you can remotely debug your app running in the same room or on another continent. You can measure app performance, view CoreData and SQLite content, logs, network requests and many more in realtime. This is the instrument that you've been looking for.

![](https://storage.googleapis.com/appspector-support/screenshots/appspector_twittercover2.png)
