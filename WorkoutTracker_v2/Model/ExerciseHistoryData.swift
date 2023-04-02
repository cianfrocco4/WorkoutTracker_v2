//
//  ExerciseHistoryData.swift
//  WorkoutTracker_v2
//
//  Created by Anthony Cianfrocco on 4/2/23.
//

import Foundation

struct ExerciseHistoryData : Identifiable {
    var id : Int
    var workoutName : String
    var exerciseName : String
    var date : Date
    var weights : [Float]  // 1 per set
    var reps : [Int]  // 1 per set
    var notes : String
}
