# This application is based on the DJI iOS-GSDemo using DJI iOS SDK 3.5.1
It can load waypoints path from files.
The format of the files are shown in the VCCReader.h/cpp.
If you wanna use it, you need read the informaiton below.
This application won't be update anymore, I guess.
![image](https://github.com/sqhuang/mavicWaypoint/blob/master/1.png)

![image](https://github.com/sqhuang/mavicWaypoint/blob/master/2.png)

# iOS-GSDemo

## Introduction

From this demo, you will learn how to implement the DJIWaypoint Mission feature and get familiar with the usages of DJIMissionManager. Also, you will know how to test the Waypoint Mission API with DJI PC Simulator too.

## Requirements

 - iOS 9.0+
 - Xcode 8.0+
 - DJI iOS SDK 3.5.1

## SDK Installation with CocoaPods

Since this project has been integrated with [DJI iOS SDK CocoaPods](https://cocoapods.org/pods/DJI-SDK-iOS) now, please check the following steps to install **DJISDK.framework** using CocoaPods after you downloading this project:

**1.** Install CocoaPods

Open Terminal and change to the download project's directory, enter the following command to install it:

~~~
sudo gem install cocoapods
~~~

The process may take a long time, please wait. For further installation instructions, please check [this guide](https://guides.cocoapods.org/using/getting-started.html#getting-started).

**2.** Install SDK with CocoaPods in the Project

Run the following command in the project's path:

~~~
pod install
~~~

If you install it successfully, you should get the messages similar to the following:

~~~
Analyzing dependencies
Downloading dependencies
Installing DJI-SDK-iOS (3.5.1)
Generating Pods project
Integrating client project

[!] Please close any current Xcode sessions and use `GSDemo.xcworkspace` for this project from now on.
Pod installation complete! There is 1 dependency from the Podfile and 1 total pod
installed.
~~~

> **Note**: If you saw "Unable to satisfy the following requirements" issue during pod install, please run the following commands to update your pod repo and install the pod again:
> 
> ~~~
> pod repo update
> pod install
> ~~~

## Tutorial

For this demo's tutorial: **Creating a MapView and Waypoint Application**, please refer to <https://developer.dji.com/mobile-sdk/documentation/ios-tutorials/GSDemo.html>.

## Feedback

We’d love to hear your feedback on this demo and tutorial.

Please use **Github Issue** or **email** [oliver.ou@dji.com](oliver.ou@dji.com) when you meet any problems of using this demo. At a minimum please let us know:

* Which DJI Product you are using?
* Which iOS Device and iOS version you are using?
* A short description of your problem includes debugging logs or screenshots.
* Any bugs or typos you come across.

## License

iOS-GSDemo is available under the MIT license. Please see the LICENSE file for more info.

