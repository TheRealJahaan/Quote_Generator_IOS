//
//  Quote_GeneratorApp.swift
//  Quote_Generator
//
//  Created by Jahaan Suthar on 7/8/26.
//

import SwiftUI
import SwiftData


@main
struct Quote_GeneratorApp: App {
    var body: some Scene {
        WindowGroup {
            LoginView()
        }
        .modelContainer(for: User.self)
    }
    
}
