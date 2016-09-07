#!/usr/bin/env xcrun swift

// This script builds and lipos static libraries, but doesn't
// bundle assets for any of them.

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
      // can't remember what this line is supposed to do
      let value = self.params[key].flatMap { return $0 }
      if let value = value {
        params.append(value)
      }
    }
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
let frameworkMapping = [
  "Database": "FirebaseDatabaseUI",
  "Auth":     "FirebaseAuthUI",
  "Facebook": "FirebaseFacebookAuthUI",
  "Google":   "FirebaseGoogleAuthUI",
]
let schemes = Array(frameworkMapping.keys)
print("Schemes: \(schemes)")

// Create folder structure for built products
schemes.forEach { scheme in
  let schemeDir = BuiltProductsDir + scheme
  mkdir(schemeDir)
  mkdir(schemeDir + "/Frameworks")
  mkdir(schemeDir + "/Resources")

  let frameworkDir = schemeDir + "/Frameworks/" 
    + frameworkMapping[scheme]! + ".framework"
  mkdir(frameworkDir + "/Modules")
}

// Create xcodebuild tasks from schemes and target sdks
let builds = sdks.flatMap { sdk in
  return schemes.map { scheme in
    return Build([
      "-workspace"      : "FirebaseUI.xcworkspace",
      "-scheme"         : scheme,
      "-configuration"  : "Release",
      "-sdk"            : sdk,
      "-derivedDataPath": DerivedDataDir
    ])
  }
}

// build everything in release
builds.forEach { build in
  build.launch()

  let scheme = build.params["-scheme"]!
  let sdk = build.params["-sdk"]!
  let headerPath = DerivedDataDir + "Build/Products/Release-"
    + sdk + "/usr/local/include"
  let framework = frameworkMapping[scheme]! + ".framework"
  let destination = BuiltProductsDir + scheme + "/Frameworks/"
    + framework + "/Headers"

  // Headers only need to be moved once.
  if (sdk == "iphoneos") {
    mv(from: headerPath, to: destination)
  }
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
  let lib = "lib" + scheme + ".a"
  let chunks = productsPaths.map { path in
    return path + lib
  }

  let framework = frameworkMapping[scheme]! + ".framework"
  let binary = frameworkMapping[scheme]!

  let output = "\(BuiltProductsDir)\(scheme)/Frameworks/\(framework)/\(binary)"
  return Lipo(inputs: chunks, output: output)
}

// lipo everything
lipos.forEach { $0.launch() }

exit(0)

