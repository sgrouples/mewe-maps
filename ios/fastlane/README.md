fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

### generate_provisioning

```sh
[bundle exec] fastlane generate_provisioning
```

Updates certificates and profiles, no options.

### build

```sh
[bundle exec] fastlane build
```


    Builds Location App target.

    ##Options:

    * display_name - will set the Consumer .plist display name.
    * build_number - will set the Consumer .plist build number.
    * scheme - scheme to build, default 'Consumer'
    * configuration - scheme build configuration, default 'AdHoc'
    * commitMessageKey - key required for the lane to execute

    ##Example: usage:

      bundle exec fastlane build scheme:"Runner" build_number:"1.0.4"
    

### upload

```sh
[bundle exec] fastlane upload
```



### sync_match_development

```sh
[bundle exec] fastlane sync_match_development
```

Download or recreate provisioning profiles for development

### sync_match_adhoc

```sh
[bundle exec] fastlane sync_match_adhoc
```

Download or recreate provisioning profiles for ad-hoc

### regenerate_match_development

```sh
[bundle exec] fastlane regenerate_match_development
```

Nuke and recreate certificates and provisioning profiles for development

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
