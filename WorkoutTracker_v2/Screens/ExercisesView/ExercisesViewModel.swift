//
//  ExercisesViewModel.swift
//  WorkoutTracker_v2
//
//  Created by Anthony Cianfrocco on 2/4/23.
//

import SwiftUI
import Foundation

final class ExercisesViewModel: ObservableObject {
    private var workout : Workout?
    
    @Published var isExerciseSelected : Bool = false
    @Published var repsArr : [TextBindingManager] = []
    @Published var weightArr : [TextBindingManager] = []
    @Published var selectedExercise : Exercise?
    @Published var exerciseEntries : [ExerciseEntry] = []
    @Published var swapIdx : Int?
    @Published var notes : String = ""
    
    func setup(workout: Workout?) {
        self.workout = workout
        setRepsAndWeight()
    }
    
    func setRepsAndWeight() {
        notes = ""
        
        if selectedExercise != nil {
            for set in 0..<selectedExercise!.sets {
                if let result = DbManager.shared.getLastTimePerformed(workoutName: nil, exerciseName: selectedExercise!.name, setNum: set + 1) {
                    if result.notes != "" {
                        notes = result.notes
                    }
                    
                    if set < repsArr.count && set < weightArr.count {
                        repsArr[set].text = String(result.reps)
                        weightArr[set].text = String(result.weight)
                        
                        exerciseEntries[set].wgtLbs = Float(result.weight)
                        exerciseEntries[set].reps = result.reps
                    }
                    else {
                        repsArr[set].text = ""
                        weightArr[set].text = ""
                        
                        exerciseEntries[set].wgtLbs = 0
                        exerciseEntries[set].reps = 0
                    }
                }
                else {
                    repsArr[set].text = ""
                    weightArr[set].text = ""
                    
                    exerciseEntries[set].wgtLbs = 0
                    exerciseEntries[set].reps = 0
                }
            }
        }
    }
    
    func selectExercise(exercise : Exercise) {
        exerciseEntries.removeAll()
        
        if selectedExercise == nil ||
            exercise.name == selectedExercise!.name {
            // only update if the same exercise is selected or no exercise is selected
            isExerciseSelected = !isExerciseSelected
        }
        else if selectedExercise != nil &&
                    selectedExercise!.name != exercise.name {
            isExerciseSelected = true
        }
        
        selectedExercise = exercise
        
        let len = exerciseEntries.count //repsArr.count
        if(len < selectedExercise!.sets) {
            for set in 0..<selectedExercise!.sets {
                repsArr.append(TextBindingManager(limit: 2))
                weightArr.append(TextBindingManager(limit: 3))
                
                let completedToday = getPrevDateToday(exerciseName: selectedExercise!.name,
                                                      set: set+1)
                
                
                exerciseEntries.append(ExerciseEntry(set: set+1,
                                                     prevWgtLbs: (selectedExercise != nil) ? getPrev(exerciseName: selectedExercise!.name, set: set+1) : nil,
                                                     reps: 0,
                                                     saved: completedToday))
            }
        }
        
        setRepsAndWeight()
    }
    
    func getPrev(exerciseName : String,
                 set : Int) -> Float? {
        return DbManager.shared.getPrevWeight(exerciseName: exerciseName,
                                 set: set)
    }
    
    func getPrevDateToday(exerciseName : String,
                     set : Int) -> Bool {
        guard let wkout = workout else { return false }
        
        let date =  DbManager.shared.getPrevDate(workoutName: wkout.name,
                                    exerciseName: exerciseName,
                                    set: set)
        
        if date != nil {
            let dbComponents = Calendar.current.dateComponents([.day, .year, .month], from: date!)
            let currComponents = Calendar.current.dateComponents([.day, .year, .month], from: Date.now)
            
            return dbComponents.year == currComponents.year &&
                    dbComponents.month == currComponents.month &&
                    dbComponents.day == currComponents.day
        }
        else {
            return false
        }
    }
    
    func getColorForExercise(exercise: Exercise) -> Color {
        
        var lbExerciseCompletedForAllSets = exercise.sets > 0 ? true : false
        var lbExerciseCompletedForAtleastOneSet = false

        for set in 1..<exercise.sets+1 {
            lbExerciseCompletedForAllSets = lbExerciseCompletedForAllSets &&
                                            getPrevDateToday(exerciseName: exercise.name,
                                                             set: set)
            lbExerciseCompletedForAtleastOneSet = lbExerciseCompletedForAtleastOneSet ||
                                                  getPrevDateToday(exerciseName: exercise.name,
                                                                   set: set)
            
        }
        
        if lbExerciseCompletedForAllSets {
            return .green
        }
        else if lbExerciseCompletedForAtleastOneSet {
            return .yellow
        }
        else {
            return .red
        }
    }
    
    func removeExercise(exercise: Exercise) {
        guard let w = workout else { return }
        DbManager.shared.removeExerciseFromWorkout(workout: w, exercise: exercise)
    }
}
