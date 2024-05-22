//
//  SleepView.swift
//  SelfTalk Watch App
//
//  Created by Alfadli Maulana Siddik on 21/05/24.
//

import SwiftUI
import Charts

struct SleepView: View {
    @EnvironmentObject var healthManager: HealthViewModel
    
    var body: some View {
        VStack (alignment: .leading) {
            Chart {
                ForEach(healthManager.totalSleepPerDay.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                    BarMark(
                        x: .value("Date", key),
                        y: .value("Sleep Hours", value)
                    )
                    .foregroundStyle(.mint)
                }
            }
            
            VStack (alignment: .leading) {
                Text("\(healthManager.totalSleepThisWeek) Hours")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.mint)
                Text("THIS WEEK")
                    .font(.system(size: 12))
                    .foregroundStyle(.gray)
            }
        }
        .navigationTitle {
            Text("Sleep").foregroundStyle(.mint)
        }
        .onAppear {
            healthManager.getTotalSleepForLastWeek()
        }
    }
}

#Preview {
    SleepView()
}
