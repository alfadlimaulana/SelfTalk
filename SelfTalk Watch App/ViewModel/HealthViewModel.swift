//
//  HealthViewModel.swift
//  SelfTalk Watch App
//
//  Created by Alfadli Maulana Siddik on 18/05/24.
//

import Foundation
import HealthKit

extension Date {
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    var aWeekAgo: Date {
        guard let aWeekAgoDate = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: Date()) else {
                    fatalError("Failed to calculate a week ago date")
                }
        return aWeekAgoDate
    }
}

class HealthViewModel: NSObject, ObservableObject {
    @Published var totalMindfulMinutesToday: Int = 0
    
    // HK store adalah pusat data kesehatan
    let healthStore = HKHealthStore()
    let mindfulType = HKObjectType.categoryType(forIdentifier: .mindfulSession)!
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {

      let typesToShare: Set = [mindfulType]
      let typesToRead: Set = [mindfulType]

      HKHealthStore().requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
        completion(success)
      }
    }
    
    func getTotalMindfulMinutesForToday() {

      let mindfulType = HKObjectType.categoryType(forIdentifier: .mindfulSession)!

        let predicate = HKQuery.predicateForSamples(withStart: Date().startOfDay,
                                                  end: Date(),
                                                  options: .strictStartDate)

      let query = HKSampleQuery(sampleType: mindfulType,
                                predicate: predicate,
                                limit: HKObjectQueryNoLimit,
                                sortDescriptors: nil) { query, samples, error in

        guard let samples = samples as? [HKCategorySample] else {
            DispatchQueue.main.async {
                self.totalMindfulMinutesToday = 0
            }
          return
        }

        var totalMinutes = 0

        for sample in samples {
            let minutes = sample.endDate.timeIntervalSince(sample.startDate) / 60
            totalMinutes += Int(minutes)
        }

          DispatchQueue.main.async {
              self.totalMindfulMinutesToday = totalMinutes
          }
      }

      HKHealthStore().execute(query)
    }
    
    func saveMindfulMinutes(_ seconds: Int) {

      let endDate = Date()
      let startDate = endDate.addingTimeInterval(-(TimeInterval(seconds)))

      let sample = HKCategorySample(type: mindfulType,
                                    value: 0,
                                    start: startDate,
                                    end: endDate)

      HKHealthStore().save(sample) { success, error in
        if let error = error {
          print("Error saving mindful minutes: \(error.localizedDescription)")
        } else {
          print("Successfully saved \(seconds/60) mindful minutes")
        }
      }
    }
}
