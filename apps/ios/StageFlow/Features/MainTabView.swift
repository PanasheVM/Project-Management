import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            DashboardView().tabItem { Label("Home", systemImage: "rectangle.grid.2x2") }
            PlaceholderView(title: "Projects", icon: "briefcase", message: "Your active productions will appear here.").tabItem { Label("Projects", systemImage: "briefcase") }
            PlaceholderView(title: "Calendar", icon: "calendar", message: "Load-ins, rehearsals, and deadlines will appear here.").tabItem { Label("Calendar", systemImage: "calendar") }
            PlaceholderView(title: "Notes", icon: "note.text", message: "Private and shared production notes will stay organized here.").tabItem { Label("Notes", systemImage: "note.text") }
            PlaceholderView(title: "Notifications", icon: "bell", message: "Assignments, approvals, and blockers will arrive here.").tabItem { Label("Alerts", systemImage: "bell") }
        }.tint(StageFlowTheme.gold)
    }
}

private struct DashboardView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(Date.now, format: .dateTime.weekday(.wide).day().month(.wide)).textCase(.uppercase).font(.caption.bold()).tracking(1.5).foregroundStyle(StageFlowTheme.gold)
                    Text("Production overview").font(.largeTitle.bold())
                    VStack(alignment: .leading) { Text("0").font(.system(size: 40, weight: .bold)); Text("Active productions").foregroundStyle(StageFlowTheme.secondaryText) }.frame(maxWidth: .infinity, alignment: .leading).stageFlowCard()
                    PlaceholderView(title: "Create your company", icon: "building.2.crop.circle", message: "Set up your production company, departments, and first project.")
                }.padding(20)
            }.background(StageFlowTheme.background).foregroundStyle(.white)
        }
    }
}

private struct PlaceholderView: View {
    let title: String, icon: String, message: String
    var body: some View {
        ContentUnavailableView(title, systemImage: icon, description: Text(message)).frame(maxWidth: .infinity, maxHeight: .infinity).background(StageFlowTheme.background).foregroundStyle(.white)
    }
}
