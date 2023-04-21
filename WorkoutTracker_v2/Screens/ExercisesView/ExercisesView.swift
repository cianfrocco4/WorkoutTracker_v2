//
//  ExercisesView.swift
//  WorkoutTracker_v2
//
//  Created by Anthony Cianfrocco on 1/22/23.
//

import SwiftUI

struct ExercisesView: View {
    @State var exercises : [Exercise]
    
    @EnvironmentObject var dbMgr : DbManager
    @EnvironmentObject private var selectedWkout : Workout
    
    @StateObject private var viewModel = ExercisesViewModel()
    
    @State var restTime : UInt
    @Binding var restTimeRemaining : UInt
    @Binding var restTimeRunning : Bool
        
    var body: some View {
        ZStack {
            VStack {
                List {
                    ForEach(exercises) { exercise in
                        VStack {
                            Button {
                                print("Exercise selected: \(exercise)")
                                viewModel.selectExercise(exercise: exercise)
                            } label: {
                                HStack {
                                    Circle()
                                        .fill(viewModel.getColorForExercise(exercise: exercise))
                                        .frame(width: 10, height: 10)
                                    
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
                                        viewModel.isShowingSwapExer = true
                                        viewModel.swapIdx = idx!
                                    }
                                }
                                .tint(.yellow)
                                
                                Button("Remove") {
                                    print("Remove exercise: " + exercise.name)
                                    
                                    let idx = exercises.firstIndex(where: { $0.name == exercise.name })
                                    
                                    if (idx != nil) {
                                        // Remove from database
                                        viewModel.removeExercise(exercise: exercises[idx!])
                                        // Remove locally
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
                                ExerciseDropDownTableView(exercise: viewModel.selectedExercise!,
                                                          restTime: restTime,
                                                          repsArr: $viewModel.repsArr,
                                                          weightArr: $viewModel.weightArr,
                                                          entries: $viewModel.exerciseEntries,
                                                          notes: $viewModel.notes,
                                                          restTimeRunning: $restTimeRunning,
                                                          restTimeRemaining: $restTimeRemaining)
                                .frame(width: 325,
                                       height: 330)
                            }
                        }
                    }
                    .onMove(perform: move)
                    
                    HStack {
                        Spacer()
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
                        Spacer()
                    }
                }
            }
            .blur(radius: viewModel.isShwoingAddNewExer ||
                          viewModel.isShowingSwapExer ? 20 : 0)
            .disabled(viewModel.isShwoingAddNewExer ||
                      viewModel.isShowingSwapExer)
            
            if (viewModel.isShwoingAddNewExer ||
                viewModel.isShowingSwapExer) {
                NewExerciseView(isShwoingAddNewExer: $viewModel.isShwoingAddNewExer,
                                isShowingSwapExer: $viewModel.isShowingSwapExer,
                                exercises: $exercises,
                                swapIdx: $viewModel.swapIdx)
            }
        }
        .onAppear {
            self.viewModel.setup(self.dbMgr, workout: selectedWkout) // workout)
        }
    }
    
    func move(from source: IndexSet, to destination: Int) {
        exercises.move(fromOffsets: source, toOffset: destination)
    }
}

struct ExercisesView_Previews: PreviewProvider {
    static let dbMgr = DbManager(db_path: "WorkoutTracker.sqlite")
    static var previews: some View {
        ExercisesView(exercises: MockData.sampleExercises,
                      restTime: 60,
                      restTimeRemaining: .constant(60),
                      restTimeRunning: .constant(false))
            .environmentObject(dbMgr)
            .environmentObject(MockData.sampleWorkout1)
    }
}

class dropDelegate: DropDelegate {

    func performDrop(info: DropInfo) -> Bool {
        print("drop success")
        return true
    }
}
