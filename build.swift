#!/usr/bin/env xcrun swift

// This script builds and lipos dynamic frameworks
// built by Xcode.

import Foundation

/// Map from scheme names to framework names.
/// Hopefully can avoid hard-coding this in the future
let schemes = [
  "FirebaseDatabaseUI",
  "FirebaseAuthUI",
  "FirebaseFacebookAuthUI",
  "FirebaseGoogleAuthUI",
  "FirebaseTwitterAuthUI",
  "FirebasePhoneAuthUI",
  "FirebaseStorageUI",
  "FirebaseFirestoreUI"
]

let staticLibs = [
  "Database" : "FirebaseDatabaseUI",
  "Auth"     : "FirebaseAuthUI",
  "Facebook" : "FirebaseFacebookAuthUI",
  "Google"   : "FirebaseGoogleAuthUI",
  "Twitter"  : "FirebaseTwitterAuthUI",
  "Phone"    : "FirebasePhoneAuthUI",
  "Storage"  : "FirebaseStorageUI",
  "Firestore": "FirebaseFirestoreUI",
]

// TODO: Use NSFileManager instead of all these awful
// manual path appendings and mkdir/mv/cp

let DerivedDataDir = "artifacts/"
let BuiltProductsDir = "FirebaseUIFrameworks/"

// TODO: DRY out these Task functions

func mkdir(_ dirname: String) -> Void {
  let task = Process()
  task.launchPath = "/bin/mkdir"
  task.arguments = ["-p", dirname]
  task.launch()
  task.waitUntilExit()
}

func mv(from source: String, to destination: String) -> Void {
  let task = Process()
  task.launchPath = "/bin/mv"
  task.arguments = ["-n", "-v", source, destination]
  task.launch()
  task.waitUntilExit()
  guard task.terminationStatus == 0 else { exit(task.terminationStatus) }
}

func cp(from source: String, to destination: String) -> Void {
  let task = Process()
  task.launchPath = "/bin/cp"
  task.arguments = ["-R", "-n", source, destination]
  task.launch()
  task.waitUntilExit()
  guard task.terminationStatus == 0 else { exit(task.terminationStatus) }
}

func ln(from source: String, to destination: String) -> Void {
  let task = Process()
  task.launchPath = "/bin/ln"
  task.arguments = ["-s", source, destination]
  task.launch()
  task.waitUntilExit()
  guard task.terminationStatus == 0 else { exit(task.terminationStatus) }
}

/// Moves files to trash
func rm(_ path: String, isDirectory: Bool, isStrict: Bool) -> Void {
  let url = URL(fileURLWithPath: path, isDirectory: isDirectory)
  let fileManager = FileManager()
  do {
    try fileManager.trashItem(at: url, resultingItemURL: nil)
  } catch (let error) {
    if (isStrict) {
      print(fileManager.currentDirectoryPath)
      print(error)
      exit(1)
    }
  }
}

func zip(_ input: String, output: String) -> Void {
  let task = Process()
  task.launchPath = "/usr/bin/zip"
  task.arguments = ["-r", "-9", "-y", output, input]
  task.launch()
  task.waitUntilExit()
  guard task.terminationStatus == 0 else { exit(task.terminationStatus) }
}

func enableSoftwareKeyboard() -> Void {
  let task = Process()
  task.launchPath = "/usr/bin/defaults"
  task.arguments = ["write", "com.apple.iphonesimulator", "ConnectHardwareKeyboard", "-bool", "NO"]
  task.launch()
  task.waitUntilExit()
  guard task.terminationStatus == 0 else { exit(task.terminationStatus) }
}

mkdir(DerivedDataDir)
mkdir(BuiltProductsDir)
enableSoftwareKeyboard()

// Build

// TODO: use xcrun to invoke dev tool commands

func buildTask(args: [String] = []) -> Process {
  let task = Process()
  task.launchPath = "/usr/bin/xcodebuild"
  task.arguments = args
  return task
}

let test = buildTask(args: [
  "-workspace", "FirebaseUI.xcworkspace",
  "-scheme",  "FirebaseUI",
  "-sdk", "iphonesimulator",
  "-destination", "platform=iOS Simulator,name=iPhone 7",
  "test",
  "ONLY_ACTIVE_ARCH=YES", "CODE_SIGNING_REQUIRED=NO"
])
test.launch()
test.waitUntilExit()
guard test.terminationStatus == 0 else {
  exit(test.terminationStatus)
}

/// A value type representing an xcodebuild call.
/// param keys are parameters and expect leading dashes,
/// i.e. `-workspace`
struct Build {

  var params: [String: String]

  init(_ params: [String: String]) {
    self.params = params
  }

  var args: [String] {
    var params: [String] = []
    let keys = self.params.keys
    for key in keys {
      params.append(key)
      let value = self.params[key]
      if let value = value {
        params.append(value)
      }
    }
    // hard code bitcode so cocoapods dummy
    // files are built with bitcode, hope for
    // no consequences later
    params.append("BITCODE_GENERATION_MODE=bitcode")
    return params
  }

  func launch() {
    let task = buildTask(args: self.args)
    task.launch()
    task.waitUntilExit()
    guard task.terminationStatus == 0 else {
      exit(task.terminationStatus)
    }
  }
}

let sdks = ["iphoneos", "iphonesimulator"]

// make folder structure for built products
schemes.forEach { scheme in
  let schemeDir = BuiltProductsDir + scheme
  mkdir(schemeDir)
  mkdir(schemeDir + "/Frameworks")
}

// Invoke xcodebuild, building each scheme in
// release for each target sdk. Building
// dynamic frameworks so we don't have to do
// the asset bundling and folder structures manually,
// at the costs of lots of duplication. Not sure if ideal.
let builds =  schemes.map { scheme in
  return Build([
    "-workspace"      : "FirebaseUI.xcworkspace",
    "-scheme"         : scheme,
    "-configuration"  : "Release",
    "-sdk"            : sdks[0],
    "-derivedDataPath": DerivedDataDir,
  ])
}

let staticBuilds: [Build] = sdks.flatMap { sdk -> [Build] in
  let schemeNames = Array(staticLibs.keys)
  return schemeNames.map { scheme -> Build in
    return Build([
      "-workspace"      : "FirebaseUI.xcworkspace",
      "-scheme"         : scheme,
      "-configuration"  : "Release",
      "-sdk"            : sdk,
      "-derivedDataPath": DerivedDataDir,
    ])
  }
}

builds.forEach { $0.launch() }
staticBuilds.forEach { $0.launch() }

// Copy frameworks into built products dir. Don't really
// care about sdk here since we're gonna lipo everything later
schemes.forEach { scheme in
  let sdk = sdks[0] // arbitrary sdk, just need folder structure
  let frameworkDir = BuiltProductsDir + scheme + "/Frameworks"
  let framework = scheme
  let frameworkPath = "\(DerivedDataDir)Build/Products/Release-\(sdk)/\(framework).framework"
  cp(from: frameworkPath, to: frameworkDir)
}

// Lipo

/// A value type representing an invocation of `lipo -create`.
struct Lipo {
  var inputs: [String]
  var output: String

  func launch() {
    print("lipo \(output)")
    let task = Process()
    task.launchPath = "/usr/bin/lipo"
    task.arguments = ["-create"] + self.inputs
      + ["-output"] + [output]
    task.launch()
    task.waitUntilExit()
    guard task.terminationStatus == 0 else {
      exit(task.terminationStatus)
    }
  }
}

let productsPaths = sdks.map {
  return DerivedDataDir + "Build/Products/Release-" + $0 + "/"
}

// create lipo tasks from built products
let lipos: [Lipo] = Array(staticLibs.keys).map { scheme in
  let product = staticLibs[scheme]!
  let framework = "\(product).framework"
  let binary = "lib\(scheme).a"

  let chunks = productsPaths.map { path in
    return path + binary
  }

  let output = "\(BuiltProductsDir)\(product)/Frameworks/\(framework)/\(product)"
  return Lipo(inputs: chunks, output: output)
}

// lipo everything
lipos.forEach { $0.launch() }

// copy license, readme file
cp(from: "LICENSE", to: BuiltProductsDir)
cp(from: "README.md", to: BuiltProductsDir)

// copy sample projects
cp(from: "samples", to: BuiltProductsDir)
rm(BuiltProductsDir + "samples/objc/Pods", isDirectory: true, isStrict: false)
rm(BuiltProductsDir + "samples/objc/Podfile.lock", isDirectory: false, isStrict: false)
rm(BuiltProductsDir + "samples/objc/GoogleService-Info.plist", isDirectory: false, isStrict: false)
rm(BuiltProductsDir + "samples/swift/Pods", isDirectory: true, isStrict: false)
rm(BuiltProductsDir + "samples/swift/Podfile.lock", isDirectory: false, isStrict: false)
rm(BuiltProductsDir + "samples/swift/GoogleService-Info.plist", isDirectory: false, isStrict: false)
rm(BuiltProductsDir + "samples/objc/FirebaseUI-demo-objc.xcodeproj/xcuserdata", isDirectory: true, isStrict: false)
rm(BuiltProductsDir + "samples/objc/FirebaseUI-demo-objc.xcodeproj/project.xcworkspace", isDirectory: true, isStrict: false)
rm(BuiltProductsDir + "samples/objc/FirebaseUI-demo-objc.xcworkspace", isDirectory: true, isStrict: false)
rm(BuiltProductsDir + "samples/swift/FirebaseUI-demo-swift.xcodeproj/xcuserdata", isDirectory: true, isStrict: false)
rm(BuiltProductsDir + "samples/swift/FirebaseUI-demo-swift.xcodeproj/project.xcworkspace", isDirectory: true, isStrict: false)
rm(BuiltProductsDir + "samples/swift/FirebaseUI-demo-swift.xcworkspace", isDirectory: true, isStrict: false)
rm(BuiltProductsDir + "samples/demo.gif", isDirectory: false, isStrict: false)

// clean up build artifacts afterward
zip("FirebaseUIFrameworks", output: "FirebaseUIFrameworks.zip")

rm(DerivedDataDir, isDirectory: true, isStrict: true)
rm(BuiltProductsDir, isDirectory: true, isStrict: true)

exit(0)
