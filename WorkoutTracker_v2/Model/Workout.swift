//
//  Workout.swift
//  WorkoutTracker_v2
//
//  Created by Anthony Cianfrocco on 4/2/23.
//

import Foundation


struct Workout: Decodable, Identifiable {
    var id        : Int
    var name      : String
    var exercises : [Exercise]
}

struct MockData {
    static let sampleWorkout1 = Workout(id: 0, name: "Pull 1", exercises: sampleExercises)
    static let sampleWorkout2 = Workout(id: 1, name: "Pull 2", exercises: sampleExercises)
    
    static let sampleRepsWeightArr = Array(repeating: TextBindingManager(limit: 3),
                                           count: 3)
}
