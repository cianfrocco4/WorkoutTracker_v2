//
//  ExercisesView.swift
//  WorkoutTracker_v2
//
//  Created by Anthony Cianfrocco on 1/22/23.
//

import SwiftUI

struct ExercisesView: View {
    @EnvironmentObject private var workoutModel : WorkoutModel
    
    @StateObject private var viewModel = ExercisesViewModel()
    
    @Binding var selectedWkout : Workout
    @Binding var restTimeRemaining : UInt
    @Binding var restTimeRunning : Bool

    var isRestTimerOn : Bool
    
    @ViewBuilder
    var selectedExerciseDestination : some View {
        Text("test")
    }
        
    var body: some View {
        ZStack {
            VStack {
                List {
                    ForEach(selectedWkout.exercises) { exercise in
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
                                // TODO: removing swap for now
                                //                                Button("Swap") {
                                //                                    // Temporary swap
                                //
                                //                                    print("Swap exercise: " + exercise.name)
                                //
                                //                                    let idx = exercises.firstIndex(where: { $0.name == exercise.name })
                                //
                                //                                    if (idx != nil) {
                                //                                        viewModel.swapIdx = idx!
                                //                                        NavigationLink(
                                //                                            destination:
                                //                                                NewExerciseView(exercises: $exercises,
                                //                                                                swapIdx: $viewModel.swapIdx,
                                //                                                                selectedWkout: selectedWkout,
                                //                                                                saveToDb: true)
                                //                                                .navigationTitle("New Exercise"),
                                //                                            label: {
                                //                                                Text("Add new exercise")
                                //                                                    .multilineTextAlignment(.center)
                                //                                                    .font(.body)
                                //                                                    .fontWeight(.semibold)
                                //                                                    .cornerRadius(10)
                                //                                            }
                                //                                        )
                                //                                        .padding()
                                //                                        .buttonStyle(.borderedProminent)
                                //                                        .tint(Color.brandPrimary)
                                //                                    }
                                //                                }
                                //                                .tint(.yellow)
                                
                                Button("Remove") {
                                    print("Remove exercise: " + exercise.name)
                                    workoutModel.removeExercise(
                                        workoutName: selectedWkout.name,
                                        exerciseName: exercise.name)
                                    
//                                    let idx = selectedWkout.exercises.firstIndex(where: { $0.name == exercise.name })
//                                    
//                                    if (idx != nil) {
//                                        // Remove from database
//                                        viewModel.removeExercise(exercise: selectedWkout.exercises[idx!])
//                                        // Remove locally
//                                        selectedWkout.exercises.remove(at: idx!)
//                                    }
                                }
                                .tint(.red)
                            }
                            
                            if viewModel.isExerciseSelected &&
                                viewModel.selectedExercise!.id == exercise.id {
                                
                                ExerciseDropDownTableView(exercise: viewModel.selectedExercise!,
                                                          restTime: selectedWkout.restTimeSec,
                                                          repsArr: $viewModel.repsArr,
                                                          weightArr: $viewModel.weightArr,
                                                          entries: $viewModel.exerciseEntries,
                                                          notes: $viewModel.notes,
                                                          restTimeRunning: $restTimeRunning,
                                                          restTimeRemaining: $restTimeRemaining,
                                                          isRestTimerOn: isRestTimerOn)
                                .disabled(!workoutModel.isWorkoutRunning())
                            }
                        }
                    }
                    .onMove(perform: move)
                    
                    HStack {
                        Spacer()
                        NavigationLink(
                            destination:
                                NewExerciseView(exercises: $selectedWkout.exercises,
                                                swapIdx: $viewModel.swapIdx,
                                                selectedWkout: selectedWkout,
                                                saveToDb: true)
                                .navigationTitle("New Exercise"),
                            label: {
                                Text("Add new exercise")
                                    .multilineTextAlignment(.center)
                                    .font(.body)
                                    .fontWeight(.semibold)
                                    .cornerRadius(10)
                            }
                        )
                        .padding()
                        .buttonStyle(.borderedProminent)
                        .tint(Color.brandPrimary)
                        
                        Spacer()
                    }
                }
            }
        }
        .onAppear {
            self.viewModel.setup(workout: selectedWkout)
        }
    }
    
    func move(from source: IndexSet, to destination: Int) {
        selectedWkout.exercises.move(fromOffsets: source, toOffset: destination)
    }
}

struct ExercisesView_Previews: PreviewProvider {
    static var previews: some View {
        ExercisesView(
            selectedWkout: .constant(MockData.sampleWorkout1),
                      restTimeRemaining: .constant(60),
                      restTimeRunning: .constant(false),
                      isRestTimerOn: false)
            .environmentObject(MockData.sampleWorkout1)
    }
}

class dropDelegate: DropDelegate {

    func performDrop(info: DropInfo) -> Bool {
        print("drop success")
        return true
    }
}
