Want to contribute? Great! First, read this page (including the small print at
the end).

### Before you contribute

Before we can use your code, you must sign the [Google Individual Contributor
License Agreement](https://cla.developers.google.com/about/google-individual)
(CLA), which you can do online. The CLA is necessary mainly because you own the
copyright to your changes, even after your contribution becomes part of our
codebase, so we need your permission to use and distribute your code. We also
need to be sure of various other things—for instance that you'll tell us if you
know that your code infringes on other people's patents. You don't have to sign
the CLA until after you've submitted your code for review and a member has
approved it, but you must do it before we can put your code into our codebase.

### Adding new features

Before you start working on a larger contribution, you should get in touch with
us first through the issue tracker with your idea so that we can help out and
possibly guide you. Coordinating up front makes it much easier to avoid
frustration later on.

If this has been discussed in an issue, make sure to mention the issue number.
If not, go file an issue about this to make sure this is a desirable change.

If this is a new feature please co-ordinate with someone on [FirebaseUI-Android](https://github.com/firebase/FirebaseUI-Android)
to make sure that we can implement this on both platforms and maintain feature parity.
Feature parity (where it makes sense) is a strict requirement for feature development in FirebaseUI.

### Code reviews

All submissions, including submissions by project members, require review. We
use Github pull requests for this purpose. We adhere to the
[Google Objective-C style guide](https://google.github.io/styleguide/objcguide.xml).

### Running SwiftUI Auth checks locally

The SwiftUI Auth GitHub Actions workflow can be run locally with:

```bash
./swiftui-tests.sh
```

By default, this runs the package unit tests, integration tests, and UI tests.
You can run individual checks with `--unit`, `--integration`, or `--ui`.
Pass `--lint` to run `lint-swift.sh` before the selected tests.

Examples:

```bash
./swiftui-tests.sh --unit
./swiftui-tests.sh --integration --ui
./swiftui-tests.sh --lint --all
./swiftui-tests.sh --device "iPhone 17 Pro" --ui
```

Integration and UI tests require the Firebase CLI, Node.js, and npm because
they run against the Firebase Auth emulator.

### The small print

Contributions made by corporations are covered by a different agreement than the
one above, the [Software Grant and Corporate Contributor License
Agreement](https://cla.developers.google.com/about/google-corporate).
