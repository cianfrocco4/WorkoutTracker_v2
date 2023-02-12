//
//  ExerciseTableDropDownView.swift
//  WorkoutTracker_v2
//
//  Created by Anthony Cianfrocco on 2/4/23.
//

import SwiftUI

struct ExerciseTableDropDownView: View {
    @State var workout  : Workout
    @State var exercise : Exercise
    @State var exerciseData : [ExerciseData] = []
    
    @StateObject private var viewModel = ExerciseDropDownViewModel()
    
    @EnvironmentObject var dbMgr : DbManager
    
    @Binding var repsArr : [TextBindingManager]
    @Binding var weightArr : [TextBindingManager]
    
    var body: some View {
        Table(exerciseData) {
            TableColumn("Set", value: \.set)
//            TableColumn("Reps") { $item in
//                TextField("Placeholder", text: $item.text)
//            }
        }
        .onAppear {
            self.viewModel.setup(self.dbMgr)
            for i in 0..<exercise.sets {
                let data = ExerciseData(id: i, set: String(i+1), reps: repsArr[i], wgt: weightArr[i])
                exerciseData.append(data)
            }
        }
    }
}

struct ExerciseTableDropDownView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseTableDropDownView(workout: MockData.sampleWorkout1,
                                  exercise: MockData.sampleExercises[0],
                                  repsArr: .constant(MockData.sampleRepsWeightArr),
                                  weightArr: .constant(MockData.sampleRepsWeightArr))
    }
}
