//
//  ContentView.swift
//  SelfTalk Watch App
//
//  Created by Alfadli Maulana Siddik on 17/05/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject var path = Router.shared
    @EnvironmentObject var healthManager: HealthViewModel
    
    var body: some View {
        NavigationStack(path: $path.path){
            TabView {
                HomeView()
                MindfulMinutesView()
                SleepView()
                AudioFilesView()
            }
            .tabViewStyle(.verticalPage)
            .navigationDestination(for: Pages.self) { page in
                switch page {
                case .selfTalk:
                    SelfTalkView()
                case .audioPlayer(let filename):
                    AudioPlayerView(audioFileName: filename)
                }
            }
        }
        .onAppear {
            healthManager.requestAuthorization { success in
                if success {
                    print("Access granted")
                } else {
                    print("Error Authorization")
                }
            }
        }
    }
}

//#Preview {
//    ContentView()
//}
