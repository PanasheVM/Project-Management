# StageFlow Apple client

The client is native SwiftUI and targets iOS/iPadOS 17+. It uses Authorization Code with PKCE against Keycloak, Keychain token storage, `URLSession` for the REST API, and adaptive SwiftUI navigation.

On macOS with Xcode 16 and XcodeGen installed:

```bash
xcodegen generate
open StageFlow.xcodeproj
```

For an iOS Simulator, `localhost` reaches services running on the Mac. On a physical device, replace `APIBaseURL` and `OIDCIssuer` in `Resources/Info.plist` with a host reachable from the device. Production must use HTTPS.
