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
    @Published var totalMindfulMinutesPerDay: [Date: Int] = [:]
    @Published var totalMindfulMinutesThisWeek: Int = 0
    
    @Published var totalSleepPerDay: [String: Int] = [:]
    @Published var totalSleepThisWeek: Int = 0
    
    // HK store adalah pusat data kesehatan
    let healthStore = HKHealthStore()
    let mindfulType = HKObjectType.categoryType(forIdentifier: .mindfulSession)!
    let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        
        let typesToShare: Set = [mindfulType]
        let typesToRead: Set = [mindfulType, sleepType]
        
        HKHealthStore().requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
            completion(success)
        }
    }
    
    func addDays(date: Date, value: Int) -> Date {
        let calendar = Calendar.current
        if let tomorrow = calendar.date(byAdding: .day, value: value, to: date) {
            return tomorrow
        }
        
        return date
    }
    
    func getDateInt(date: Date) -> Int {
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        return day
    }
    
    func getHourInt(date: Date) -> Int {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        return hour
    }
    
    func getTotalMindfulMinutesForLastWeek() {
        let startDate = Date().aWeekAgo.startOfDay
        let endDate = Date()
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: mindfulType,
                                  predicate: predicate,
                                  limit: HKObjectQueryNoLimit,
                                  sortDescriptors: nil) { query, samples, error in
            guard let samples = samples as? [HKCategorySample] else {
                DispatchQueue.main.async {
                    self.totalMindfulMinutesPerDay = [:]
                }
                return
            }
            
            var dailyMindfulMinutes: [Date: Int] = [:]
            var totalMindfulMinutes: Int = 0
            
            for sample in samples {
                let minutes = sample.endDate.timeIntervalSince(sample.startDate) / 60
                let startDate = Calendar.current.startOfDay(for: sample.startDate)
                
                totalMindfulMinutes += Int(minutes)
                
                if let existingMinutes = dailyMindfulMinutes[startDate] {
                    dailyMindfulMinutes[startDate] = existingMinutes + Int(minutes)
                } else {
                    dailyMindfulMinutes[startDate] = Int(minutes)
                }
            }
            
            let allDates = stride(from: startDate, to: endDate, by: 24 * 60 * 60)
            for date in allDates {
                if dailyMindfulMinutes[date] == nil {
                    dailyMindfulMinutes[date] = 0
                }
            }
            
            DispatchQueue.main.async {
                self.totalMindfulMinutesPerDay = dailyMindfulMinutes
                self.totalMindfulMinutesThisWeek = totalMindfulMinutes
            }
        }
        
        healthStore.execute(query)
    }
    
    func getTotalSleepForLastWeek() {
        let startDate = Date().aWeekAgo.startOfDay
        let endDate = Date()
        
        let sleepPredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: sleepType,
                                   predicate: sleepPredicate,
                                   limit: HKObjectQueryNoLimit,
                                   sortDescriptors: nil) { [weak self] query, samples, error in
            guard let samples = samples as? [HKCategorySample] else {
                DispatchQueue.main.async {
                    self?.totalSleepPerDay = [:]
                }
                return
            }
            
            var dailySleepMinutes: [String: Int] = [:]
            var totalSleepMinutes: Int = 0
            
            for sample in samples {
                if sample.value == HKCategoryValueSleepAnalysis.inBed.rawValue {
                    let minutes = sample.endDate.timeIntervalSince(sample.startDate) / 3600
                    
                    let hour = self!.getHourInt(date: sample.startDate)
                    var date = self!.getDateInt(date: sample.startDate)
                    
                    if (hour >= 7 && hour < 24) {
                        date = date + 1
                    }
                    
                    print("\(sample.startDate) : \(minutes)")
                    print("tanggal \(date)")
                    print("jam \(hour)")
                    print("\(date) : \(minutes)")
                    print("------------------------------------------------------------")
                    
                    totalSleepMinutes += Int(minutes)
                    
                    if let existingMinutes = dailySleepMinutes[String(date)] {
                        dailySleepMinutes[String(date)] = existingMinutes + Int(minutes)
                    } else {
                        dailySleepMinutes[String(date)] = Int(minutes)
                    }
                }
            }
            
            DispatchQueue.main.async {
                self?.totalSleepPerDay = dailySleepMinutes
                self?.totalSleepThisWeek = totalSleepMinutes
            }
        }
        
        healthStore.execute(query)
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
