import SwiftUI

struct WelcomeView: View {
    @Environment(SessionStore.self) private var session
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Label("StageFlow", systemImage: "waveform.path.ecg.rectangle").font(.title2.bold()).foregroundStyle(StageFlowTheme.gold)
            Spacer()
            Text("EVENT PRODUCTION, IN SYNC").font(.caption.bold()).tracking(2).foregroundStyle(StageFlowTheme.gold)
            Text("Every crew. Every cue. One clear view.").font(.system(size: 44, weight: .bold, design: .rounded))
            Text("Plan productions, align departments, and keep critical work moving from load-in to show close.").font(.title3).foregroundStyle(StageFlowTheme.secondaryText)
            Spacer()
            if case .failed(let message) = session.state { Text(message).foregroundStyle(.red).font(.footnote) }
            Button { Task { await session.signIn() } } label: {
                Group { if case .signingIn = session.state { ProgressView() } else { Text("Sign in securely") } }
                    .frame(maxWidth: .infinity).frame(height: 56).fontWeight(.bold)
            }.buttonStyle(.borderedProminent).tint(StageFlowTheme.gold).foregroundStyle(StageFlowTheme.background).disabled({ if case .signingIn = session.state { true } else { false } }())
        }.padding(24).foregroundStyle(.white).background(StageFlowTheme.background)
    }
}
