import SwiftUI

struct RootView: View {
    @Environment(SessionStore.self) private var session
    var body: some View {
        Group {
            switch session.state {
            case .signedIn: MainTabView()
            default: WelcomeView()
            }
        }.background(StageFlowTheme.background.ignoresSafeArea())
    }
}
