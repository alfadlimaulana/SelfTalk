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
        TabView {
            NavigationStack(path: $path.path){
                ScrollView {
                    VStack (alignment: .leading, spacing: 4) {
                        Text("What’s On Your mind?")
                            .font(.system(size: 20, weight: .semibold))
                        Text("What is bothering you and what is your plan to solve it tomorrow?")
                            .font(.system(size: 12))
                            .foregroundStyle(.gray)
                    }
                    Spacer()
                }
                .toolbar {
                    ToolbarItem(placement: .bottomBar) {
                        Button {
                            Router.shared.path.append(.selfTalk)
                        } label: {
                            Text("Talk It Out")
                                .font(.caption)
                                .frame(maxWidth: .infinity)
                        }
                        .controlSize(.large)
                        .tint(.mint.opacity(0.32))
                    }
                }
                .navigationTitle {
                    Text("Reflect").foregroundStyle(.mint)
                }
                .navigationDestination(for: Pages.self) { page in
                    switch page {
                    case .selfTalk:
                        SelfTalkView()
                    }
                }
            }
        }
        .onAppear {
            healthManager.requestAuthorization { success in
                if success {
                    healthManager.getTotalMindfulMinutesForToday()
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
