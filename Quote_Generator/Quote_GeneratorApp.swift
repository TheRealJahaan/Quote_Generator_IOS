//
//  Quote_GeneratorApp.swift
//  Quote_Generator
//
//  Created by Jahaan Suthar on 7/8/26.
//

import SwiftUI
import SwiftData
import FirebaseCore
import FirebaseAuth

@main
struct Quote_GeneratorApp: App {
    
    init(){
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            LoginView()
        }
        .modelContainer(for: User.self)
    }
    
}
