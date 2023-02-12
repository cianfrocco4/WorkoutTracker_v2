//
//  ExerciseDropDownViewModel.swift
//  WorkoutTracker_v2
//
//  Created by Anthony Cianfrocco on 2/4/23.
//

import Foundation

final class ExerciseDropDownViewModel: ObservableObject {
    var dbMgr : DbManager?
    
    func setup(_ dbMgr : DbManager) {
        self.dbMgr = dbMgr
    }
    
    func save(workout: Workout,
              exercise: Exercise,
              repsArr: [TextBindingManager],
              weightArr: [TextBindingManager]) {
        dbMgr!.saveWorkout(workoutName: workout.name)
        
        for set in 0..<exercise.sets {
            dbMgr!.saveExercise(workoutName: workout.name,
                               exerciseName: exercise.name,
                               set: set,
                               reps: Int(repsArr[set].text) ?? 0,
                               weight: Float(weightArr[set].text) ?? 0.0)
        }
    }
}
