//
//  HomeView.swift
//  SelfTalk Watch App
//
//  Created by Alfadli Maulana Siddik on 21/05/24.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var healthManager: HealthViewModel
    
    var body: some View {
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
        .onAppear {
            healthManager.getTotalMindfulMinutesForLastWeek()
        }
    }
}

#Preview {
    HomeView()
}
