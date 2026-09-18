import UIKit
import SDWebImage

@_exported import FirebaseStorageUI
@_exported import FirebaseStorage

extension UIImageView {

  public func sd_setImageWithStorageReference(
    _ storageRef: StorageReference,
    maxImageSize size: UInt64? = nil,
    placeholderImage placeholder: UIImage? = nil,
    options: SDWebImageOptions = [],
    context: [SDWebImageContextOption: Any]? = nil,
    completion: ((UIImage?, Error?, SDImageCacheType, StorageReference) -> Void)? = nil
  ) {
    sd_setImageWithStorageReference(
      storageRef,
      maxImageSize: size,
      placeholderImage: placeholder,
      options: options,
      context: context,
      progress: nil,
      completion: completion
    )
  }

  public func sd_setImageWithStorageReference(
    _ storageRef: StorageReference,
    maxImageSize size: UInt64? = nil,
    placeholderImage placeholder: UIImage? = nil,
    options: SDWebImageOptions = [],
    context: [SDWebImageContextOption: Any]? = nil,
    progress progressBlock: ((Int, Int, StorageReference) -> Void)?,
    completion: ((UIImage?, Error?, SDImageCacheType, StorageReference) -> Void)? = nil
  ) {
    guard let url = Self.storageURL(for: storageRef) else { return }

    var ctx = context ?? [:]
    ctx[.imageLoader] = StorageImageLoader.shared
    ctx[.fuiStorageMaxImageSize] = size ?? StorageImageLoader.shared.defaultMaxImageSize

    let sdProgress: SDImageLoaderProgressBlock? = progressBlock.map { block in
      { received, expected, _ in block(Int(received), Int(expected), storageRef) }
    }
    let sdCompletion: SDExternalCompletionBlock? = completion.map { block in
      { image, error, cacheType, _ in block(image, error, cacheType, storageRef) }
    }

    sd_setImage(
      with: url,
      placeholderImage: placeholder,
      options: options,
      context: ctx,
      progress: sdProgress,
      completed: sdCompletion
    )
  }

  private static func storageURL(for storageRef: StorageReference) -> URL? {
    guard !storageRef.bucket.isEmpty else { return nil }
    var components = URLComponents()
    components.scheme = "gs"
    components.host = storageRef.bucket
    components.path = "/" + storageRef.fullPath
    return components.url
  }
}
