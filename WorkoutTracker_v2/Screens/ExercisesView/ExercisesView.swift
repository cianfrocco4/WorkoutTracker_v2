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
        ZStack {
            VStack {
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
                        }
                        .foregroundColor(.primary)
                        .background(Color.buttonBackground)
                        .fontWeight(.semibold)
                        .buttonStyle(.bordered)
                        .cornerRadius(10)
                        .swipeActions {
                            Button("Swap") {
                                // Temporary swap
                                
                                print("Swap exercise: " + exercise.name)
                                
                                let idx = exercises.firstIndex(where: { $0.name == exercise.name })
                                
                                if (idx != nil) {
                                    // TODO do this here or in NewExerciseView???
//                                    exercises.remove(at: idx!)
                                    viewModel.isShowingSwapExer = true
                                    viewModel.swapIdx = idx!
                                }
                            }
                            .tint(.yellow)
                            
                            Button("Remove") {
                                print("Remove exercise: " + exercise.name)
                                
                                let idx = exercises.firstIndex(where: { $0.name == exercise.name })
                                
                                if (idx != nil) {
                                    exercises.remove(at: idx!)
                                }
                            }
                            .tint(.red)
                        }
                        
                        if viewModel.isExerciseSelected &&
                            viewModel.selectedExercise!.id == exercise.id {
                            //                    ExerciseListDropDownView(workout: workout,
                            //                                             exercise: viewModel.selectedExercise!,
                            //                                             repsArr: $viewModel.repsArr,
                            //                                             weightArr: $viewModel.weightArr)
                            ExerciseDropDownTableView(workout: workout,
                                                      exercise: viewModel.selectedExercise!,
                                                      repsArr: $viewModel.repsArr,
                                                      weightArr: $viewModel.weightArr,
                                                      entries: $viewModel.exerciseEntries,
                                                      notes: $viewModel.notes)
                            .frame(width: 325,
                                   height: 330)
                        }
                    }
                }
                
                Button {
                    viewModel.addNewExerciseClicked()
                } label: {
                    Text("Add new exercise")
                        .multilineTextAlignment(.center)
                        .font(.body)
                        .fontWeight(.semibold)
                        .cornerRadius(10)
                }
                .padding()
                .buttonStyle(.borderedProminent)
                .tint(Color.brandPrimary)
            }
            .blur(radius: viewModel.isShwoingAddNewExer ||
                          viewModel.isShowingSwapExer ? 20 : 0)
            .disabled(viewModel.isShwoingAddNewExer ||
                      viewModel.isShowingSwapExer)
            
            if viewModel.isShwoingAddNewExer ||
                viewModel.isShowingSwapExer {
                NewExerciseView(workout: workout,
                                isShwoingAddNewExer: $viewModel.isShwoingAddNewExer,
                                isShowingSwapExer: $viewModel.isShowingSwapExer,
                                exercises: $exercises,
                                swapIdx: $viewModel.swapIdx)
            }
        }
        .onAppear {
            self.viewModel.setup(self.dbMgr, workout: workout)
        }
    }
}

struct ExercisesView_Previews: PreviewProvider {
    static let dbMgr = DbManager(db_path: "WorkoutTracker.sqlite")
    static var previews: some View {
        ExercisesView(workout: MockData.sampleWorkout1,
                      exercises: MockData.sampleExercises)
            .environmentObject(dbMgr)
    }
}
