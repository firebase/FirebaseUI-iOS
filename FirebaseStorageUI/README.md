# FirebaseUI for iOS — Storage

## Using FirebaseUI to download and display images

[Cloud Storage for Firebase][firebase-storage] provides secure file uploads and downloads for your Firebase apps,
regardless of network quality. You can use it to store images, audio, video, or other
user-generated content. Cloud Storage is a powerful, simple,
and cost-effective object storage service.

FirebaseUI provides bindings to download an image file stored in Cloud Storage
from a [`FIRStorageReference`][storage-reference] and display it using the popular
[SDWebImage][sdwebimage] library. This technique allows you to get all of SDWebImage's performance
benefits while leveraging Cloud Storage's authenticated storage capabilities.

To load an image from a `FIRStorageReference`, simply use the `UIImageView+FirebaseStorage` extensions:

```objective-c
// Objective-C

// Reference to an image file in Cloud Storage
FIRStorageReference *reference = ...;

// UIImageView in your ViewController
UIImageView *imageView = ...;

// Load the image using SDWebImage
[imageView sd_setImageWithStorageReference:reference placeholderImage:placeholderImage];
```

```swift
// Swift

// Reference to an image file in Cloud Storage
let reference: StorageReference = ...;

// UIImageView in your ViewController
var imageView: UIImageView = ...;

// Load the image using SDWebImage
imageView.sd_setImageWithStorageReference(reference, placeholderImage: placeholderImage)
```

Images are cached by their path in Cloud Storage, so repeated loads will be
fast and conserve bandwidth. For more information on caching in SDWebImage,
see [this guide][sdwebimage-caching].

[firebase-storage]: https://firebase.google.com/docs/storage/
[sdwebimage]: https://github.com/rs/SDWebImage
[storage-reference]: https://firebase.google.com/docs/reference/ios/firebasestorage/interface_f_i_r_storage_reference
[sdwebimage-caching]: https://github.com/rs/SDWebImage#using-asynchronous-image-caching-independently
