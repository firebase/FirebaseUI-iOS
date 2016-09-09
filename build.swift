#!/usr/bin/env xcrun swift

// This script builds and lipos dynamic frameworks
// built by Xcode.

import Foundation

// TODO: Use NSFileManager instead of all these awful
// manual path appendings and mkdir/mv/cp

let DerivedDataDir = "artifacts/"
let BuiltProductsDir = DerivedDataDir + "FirebaseUIFrameworks/"

// TODO: DRY out these NSTask functions

func mkdir(dirname: String) -> Void {
  let task = NSTask()
  task.launchPath = "/bin/mkdir"
  task.arguments = ["-p", dirname]
  task.launch()
  task.waitUntilExit()
}

func mv(from source: String, to destination: String) -> Void {
  let task = NSTask()
  task.launchPath = "/bin/mv"
  task.arguments = ["-n", "-v", source, destination]
  task.launch()
  task.waitUntilExit()
  guard task.terminationStatus == 0 else { exit(task.terminationStatus) }
}

func cp(from source: String, to destination: String) -> Void {
  let task = NSTask()
  task.launchPath = "/bin/cp"
  task.arguments = ["-R", "-n", source, destination]
  task.launch()
  task.waitUntilExit()
  guard task.terminationStatus == 0 else { exit(task.terminationStatus) }
}

mkdir(DerivedDataDir)
mkdir(BuiltProductsDir)

// Build

// TODO: use xcrun to invoke dev tool commands

func buildTask(args args: [String] = []) -> NSTask {
  let task = NSTask()
  task.launchPath = "/usr/bin/xcodebuild"
  task.arguments = args
  return task
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

/// Map from scheme names to framework names.
/// Hopefully can avoid hard-coding this in the future
let schemes = [
  "FirebaseDatabaseUI",
  "FirebaseAuthUI",
  "FirebaseFacebookAuthUI",
  "FirebaseGoogleAuthUI",
]

// make folder structure for built products
schemes.forEach { scheme in
  let schemeDir = BuiltProductsDir + scheme
  mkdir(schemeDir)
  mkdir(schemeDir + "/Frameworks")
}

// Invoke xcodebuild, building each scheme in
// release for each target sdk
let builds = sdks.flatMap { sdk in
  return schemes.map { scheme in
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
    let task = NSTask()
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
let lipos: [Lipo] = schemes.map { scheme in
  let framework = "\(scheme).framework"
  let binary = scheme

  let lib = "\(scheme).framework/\(scheme)"
  let chunks = productsPaths.map { path in
    return path + lib
  }

  let output = "\(BuiltProductsDir)\(scheme)/Frameworks/\(framework)/\(binary)"
  return Lipo(inputs: chunks, output: output)
}

// lipo everything
lipos.forEach { $0.launch() }

exit(0)
