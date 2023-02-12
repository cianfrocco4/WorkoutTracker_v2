//
//  ExercisesView.swift
//  WorkoutTracker_v2
//
//  Created by Anthony Cianfrocco on 1/22/23.
//

import SwiftUI

struct ExercisesView: View {
    @State var workout   : Workout
    @State var exercises : [Exercise]
    
    @EnvironmentObject var dbMgr : DbManager
    
    @StateObject private var viewModel = ExercisesViewModel()
        
    var body: some View {
        List(exercises) { exercise in
            VStack {
                Button {
                    print("Exercise selected: \(exercise)")
                    viewModel.selectExercise(exercise: exercise)
                } label: {
                    HStack {
                        Text(exercise.name)
                            .font(.title3)
                            .frame(alignment: .leading)
                            .allowsTightening(true)
                            .minimumScaleFactor(0.9)
                        Spacer()
                        
                        VStack {
                            Text("Sets: \(exercise.sets)")
                                .font(.body)
                                .frame(width: 85, alignment: .leading)
                                .allowsTightening(true)
                                .minimumScaleFactor(0.9)
                            Text("Reps: \(exercise.minReps)-\(exercise.maxReps)")
                                .font(.body)
                                .frame(width: 90, alignment: .leading)
                                .allowsTightening(true)
                                .minimumScaleFactor(0.9)
                        }
                        .padding(.trailing)

                        Image(systemName: (viewModel.isExerciseSelected && exercise.id == viewModel.selectedExercise!.id) ? "chevron.down" : "chevron.right")
                            .scaledToFit()
                            .imageScale(.small)
                            .foregroundColor(.black)
                    }
                    .foregroundColor(.primary)
                    .fontWeight(.semibold)
                }
                .buttonStyle(.bordered)
                .background(Color.buttonBackground)
                .cornerRadius(10)
                
                if viewModel.isExerciseSelected &&
                    viewModel.selectedExercise!.id == exercise.id {
                    ExerciseListDropDownView(workout: workout,
                                             exercise: viewModel.selectedExercise!,
                                             repsArr: $viewModel.repsArr,
                                             weightArr: $viewModel.weightArr)
//                    ExerciseTableDropDownView(workout: workout,
//                                             exercise: viewModel.selectedExercise!,
//                                             repsArr: $viewModel.repsArr,
//                                             weightArr: $viewModel.weightArr)
                }
            }
        }
        .onAppear {
          self.viewModel.setup(self.dbMgr)
        }
    }
}

struct ExercisesView_Previews: PreviewProvider {
    static var previews: some View {
        ExercisesView(workout: MockData.sampleWorkout1,
                      exercises: MockData.sampleExercises)
    }
}
