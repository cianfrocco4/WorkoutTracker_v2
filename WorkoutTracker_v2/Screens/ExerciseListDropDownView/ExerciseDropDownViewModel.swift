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
        dbMgr!.saveWorkout(workoutName: workout.name,
                           notes: "")

        for set in 0..<exercise.sets {
            dbMgr!.saveExercise(workoutName: workout.name,
                               exerciseName: exercise.name,
                               set: set,
                               reps: Int(repsArr[set].text) ?? 0,
                                weight: Float(weightArr[set].text) ?? 0.0,
                                notes: "")
        }
    }
    
    func save(workout: Workout,
              exercise: Exercise,
              set : Int,
              entries : [ExerciseEntry],
              notes: String) {
        guard let mgr = dbMgr else { return }
                
        if entries.indices.contains(set-1) {
            guard let wgt = entries[set-1].wgtLbs else { return }

            mgr.saveWorkout(workoutName: workout.name,
                            notes: "")
            
            mgr.saveExercise(workoutName: workout.name,
                             exerciseName: exercise.name,
                             set: set,
                             reps: entries[set-1].reps,
                             weight: wgt,
                             notes: notes)
            
        } else {
            print("ERROR: invalid set index: " + String(set))
        }
    }
    
    func unsave(workout: Workout,
                exercise: Exercise,
                set : Int) {
        guard let mgr = dbMgr else { return }
        
        mgr.unsaveExercise(workoutName: workout.name,
                           exerciseName: exercise.name,
                           set: set)
        
    }
    
    func saveAll(workout : Workout,
                 exercise : Exercise,
                 entries : [ExerciseEntry],
                 exerciseNotes: String) {
        guard let mgr = dbMgr else { return }
        
        mgr.saveWorkout(workoutName: workout.name,
                        notes: "")

        for set in 0..<entries.count {
            guard let wgt = entries[set].wgtLbs else { continue }
            
            mgr.saveExercise(workoutName: workout.name,
                             exerciseName: exercise.name,
                             set: entries[set].set,
                             reps: entries[set].reps,
                             weight: wgt,
                             notes: exerciseNotes)
        }
    }
    
    func getPrev(exerciseName : String,
                 set : Int) -> Float? {
        guard let mgr = dbMgr else { return nil }
        
        return mgr.getPrevWeight(exerciseName: exerciseName,
                                 set: set)
    }
}
