//
//  ExercisesViewModel.swift
//  WorkoutTracker_v2
//
//  Created by Anthony Cianfrocco on 2/4/23.
//

import Foundation

final class ExercisesViewModel: ObservableObject {
    var dbMgr : DbManager?
    
    @Published var isExerciseSelected : Bool = false
    @Published var repsArr : [TextBindingManager] = []
    @Published var weightArr : [TextBindingManager] = []
    @Published var selectedExercise : Exercise?
    
    func setup(_ dbMgr : DbManager) {
        self.dbMgr = dbMgr
        setRepsAndWeight()
    }
    
    func setRepsAndWeight() {
        if selectedExercise != nil &&
           dbMgr != nil {
            for set in 0..<selectedExercise!.sets {
                if let result = self.dbMgr!.getLastTimePerformed(workoutName: nil, exerciseName: selectedExercise!.name, setNum: set + 1) {
                    if set < repsArr.count && set < weightArr.count {
                        repsArr[set].text = String(result.reps)
                        weightArr[set].text = String(result.weight)
                    }
                    else {
                        repsArr[set].text = ""
                        weightArr[set].text = ""
                    }
                }
                else {
                    repsArr[set].text = ""
                    weightArr[set].text = ""
                }
            }
        }
    }
    
    func selectExercise(exercise : Exercise) {
        
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
        
        let len = repsArr.count
        if(len < selectedExercise!.sets) {
            for _ in len-1..<selectedExercise!.sets {
                repsArr.append(TextBindingManager(limit: 2))
                weightArr.append(TextBindingManager(limit: 3))
            }
        }
        
        setRepsAndWeight()
    }
}
