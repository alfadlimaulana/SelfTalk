//
//  SelfTalkApp.swift
//  SelfTalk Watch App
//
//  Created by Alfadli Maulana Siddik on 17/05/24.
//

import SwiftUI

@main
struct SelfTalk_Watch_AppApp: App {
    @StateObject var healthManager = HealthViewModel()
    var body: some Scene {
        WindowGroup {
            ContentView()
        }.environmentObject(healthManager)
    }
}
