//
//  Quote_GeneratorApp.swift
//  Quote_Generator
//
//  Created by Jahaan Suthar on 7/8/26.
//

import SwiftUI
import SwiftData
import FirebaseCore
import QuoteKit

@main
struct Quote_GeneratorApp: App {
    @State private var session: SessionModel

    init() {
        FirebaseApp.configure()
        _session = State(initialValue: SessionModel(auth: FirebaseAuthService()))
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(session)
        }
        .modelContainer(for: FavoriteQuote.self)
    }
}
