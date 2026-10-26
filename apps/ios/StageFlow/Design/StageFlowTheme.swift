import SwiftUI

enum StageFlowTheme {
    static let background = Color(red: 13/255, green: 15/255, blue: 20/255)
    static let surface = Color(red: 23/255, green: 26/255, blue: 34/255)
    static let card = Color(red: 32/255, green: 36/255, blue: 46/255)
    static let gold = Color(red: 212/255, green: 166/255, blue: 60/255)
    static let violet = Color(red: 124/255, green: 108/255, blue: 1)
    static let success = Color(red: 39/255, green: 197/255, blue: 139/255)
    static let secondaryText = Color(red: 156/255, green: 163/255, blue: 178/255)
}

struct StageFlowCard: ViewModifier {
    func body(content: Content) -> some View {
        content.padding(20).background(StageFlowTheme.card, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

extension View { func stageFlowCard() -> some View { modifier(StageFlowCard()) } }
