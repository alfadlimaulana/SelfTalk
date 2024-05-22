//
//  MindfulMinutesView.swift
//  SelfTalk Watch App
//
//  Created by Alfadli Maulana Siddik on 21/05/24.
//

import SwiftUI
import Charts

struct MindfulMinutesView: View {
    @EnvironmentObject var healthManager: HealthViewModel
    
    var body: some View {
        VStack (alignment: .leading) {
            Chart {
                ForEach(healthManager.totalMindfulMinutesPerDay.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                    BarMark(
                        x: .value("Date", key, unit: .day),
                        y: .value("Mindful Minutes", value)
                    )
                    .foregroundStyle(.mint)
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let dateValue = value.as(Date.self) {
                            Text("\(Calendar.current.component(.day, from: dateValue))")
                        }
                    }
                }
            }
            
            VStack (alignment: .leading) {
                Text("\(healthManager.totalMindfulMinutesThisWeek) Minutes")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.mint)
                Text("THIS WEEK")
                    .font(.system(size: 12))
                    .foregroundStyle(.gray)
            }
        }
        .navigationTitle {
            Text("Mindful Minutes").foregroundStyle(.mint)
        }
        .onAppear {
            healthManager.getTotalMindfulMinutesForLastWeek()
        }
    }
}

#Preview {
    MindfulMinutesView()
}
