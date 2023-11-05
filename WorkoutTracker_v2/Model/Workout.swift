//
//  Workout.swift
//  WorkoutTracker_v2
//
//  Created by Anthony Cianfrocco on 4/2/23.
//

import Foundation


final class Workout: Decodable, Identifiable, Equatable, ObservableObject {
    var id          : Int
    var name        : String
    var exercises   : [Exercise]
    var restTimeSec : UInt
    var active      : Bool
    
    init(id: Int, name: String, exercises: [Exercise], restTimeSec: UInt){
        self.id = id
        self.name = name
        self.exercises = exercises
        self.restTimeSec = restTimeSec
        self.active = false
    }
    
    static func == (lhs: Workout, rhs: Workout) -> Bool {
        return lhs.name == rhs.name
    }
    
    /**
     * Update this workout with the latest data in the database.
     *
     * @return None.
     * @throw None.
     */
    func refreshFromDb() -> Void {
        guard let updatedWkout = DbManager.shared.getWorkoutFromDb(oldWorkout: self) else {
            print("Workout not in the database: \(self.name)")
            return
        }
        
        self.id = updatedWkout.id
        self.name = updatedWkout.name
        self.exercises = updatedWkout.exercises
        self.restTimeSec = updatedWkout.restTimeSec
        self.active = updatedWkout.active
        
    }
}

struct MockData {
    static let sampleWorkout1 = Workout(id: 0, name: "Pull 1", exercises: sampleExercises, restTimeSec: 60)
    static let sampleWorkout2 = Workout(id: 1, name: "Pull 2", exercises: sampleExercises, restTimeSec: 60)
    
    static let sampleRepsWeightArr = Array(repeating: TextBindingManager(limit: 3),
                                           count: 3)
}
