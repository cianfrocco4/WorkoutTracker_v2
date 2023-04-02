//
//  WorkoutHistory.swift
//  WorkoutTracker_v2
//
//  Created by Anthony Cianfrocco on 4/2/23.
//

import Foundation

struct WorkoutHistory : Identifiable{
    var id : Int
    var workout : Workout?
    var date : Date
}

extension MockData {
    static let workoutHistory1 = WorkoutHistory(id: 0, workout: nil,
                                                date: Date.now.addingTimeInterval(2 * -86400))
    static let workoutHistory2 = WorkoutHistory(id: 1, workout: MockData.sampleWorkout1,
                                               date: Date.now.addingTimeInterval(-86400))
    static let workoutHistory3 = WorkoutHistory(id: 2, workout: MockData.sampleWorkout2,
                                               date: Date.now)
}
