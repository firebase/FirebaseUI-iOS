Swift Samples
-----

This directory contains a collection of swift code samples. 

In order to run the project you'll need a valid app in Firebase and 
the `GoogleService-Info.plist` file for that project. Drag the plist into the 
project root and the project should build correctly. 

![](https://raw.githubusercontent.com/firebase/FirebaseUI-iOS/master/samples/swift/drag_plist_into_the_project.gif)

Find more instructions
and download a plist file from the [Firebase console](https://console.firebase.google.com). 

###Chat Sample

This sample uses [anonymous authentication](https://firebase.google.com/docs/auth/ios/anonymous-auth),
so make sure anonymous auth is enabled in Firebase console.

###Auth Sample

This sample uses [email/password](https://firebase.google.com/docs/auth/ios/password-auth), 
[Google](https://firebase.google.com/docs/auth/ios/google-signin), 
and [Facebook](https://firebase.google.com/docs/auth/ios/facebook-login) 
auth, so make sure those are enabled in Firebase console.

The auth example requires a little more setup (adding url schemes, etc)
since it depends on the various keys and tokens for the different auth 
services your app will support. Take a look at the source files for more
information. 
