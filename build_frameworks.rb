#!/usr/bin/env ruby

modules = [
    "FirebaseAuthUI",
    "FirebaseAnonymousAuthUI",
    "FirebaseDatabaseUI",
    "FirebaseEmailAuthUI",
    "FirebaseFacebookAuthUI",
    "FirebaseFirestoreUI",
    "FirebaseGoogleAuthUI",
    "FirebaseOAuthUI",
    "FirebasePhoneAuthUI",
    "FirebaseStorageUI",
]

derived_data = %x( pwd ).chomp + "/build/Firebase/"

# system("pod repo update")

# Build all the FirebaseUI frameworks
for mod in modules do
  puts("Installing pods for " + mod)
  xcodebuild = "xcodebuild -workspace #{mod}.xcworkspace -scheme #{mod} -sdk iphonesimulator -derivedDataPath #{derived_data}"
  command = "cd #{mod} && pod install && #{xcodebuild}"
  puts("Building: #{command}")
  value = %x[ #{command} ]
end

build_dir = derived_data + "Build/Products/Debug-iphonesimulator/"

firebase_dependencies = [
    "FirebaseAuth", "FirebaseDatabase", "FirebaseFirestore", "FirebaseStorage"
]
auth_ui = "FirebaseAuthUI"
auth_modules = [
    "FirebaseAnonymousAuthUI",
    "FirebaseEmailAuthUI",
    "FirebaseFacebookAuthUI",
    "FirebaseGoogleAuthUI",
    "FirebaseOAuthUI",
    "FirebasePhoneAuthUI",
]

# Copy built frameworks to root Firebase folder
for mod in modules do
    module_path = build_dir + "#{mod}.framework"
    system("cp -r #{module_path} #{derived_data}")
    destination_path = "#{derived_data}/#{mod}.framework"

    # Copy FirebaseAuthUI into frameworks that depend on it
    if auth_modules.include? mod
        auth_ui_path = build_dir + "#{auth_ui}.framework"
        system("cp -r #{auth_ui_path} #{destination_path}/#{auth_ui}.framework")
    end

    # Copy Firebase dependencies into the framework bundle, so they're discoverable by jazzy
    for dep in firebase_dependencies do
        dep_path = build_dir + "#{dep}/#{dep}.framework"
        system("cp -r #{dep_path} #{destination_path}/#{dep}.framework")
    end
end
