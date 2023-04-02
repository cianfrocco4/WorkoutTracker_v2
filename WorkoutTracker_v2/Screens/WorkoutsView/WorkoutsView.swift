//
//  WorkoutView.swift
//  WorkoutTracker_v2
//
//  Created by Anthony Cianfrocco on 1/18/23.
//

import SwiftUI

struct WorkoutsView: View {
    @EnvironmentObject var dbMgr : DbManager
    
    @StateObject private var viewModel = WorkoutsViewModel()
    
    var body: some View {
        ZStack {
            NavigationView {
                VStack {
                    WorkoutHistoryView(workouts: $viewModel.workoutHistory)
                        .padding(.top)
                    List {
                        ForEach(viewModel.workouts) { workout in
                            Button {
                                print("Selected workout: \(workout.name)")
                                viewModel.selectedWorkout = workout
                                viewModel.isWorkoutSelected = true
                            } label: {
                                HStack {
                                    Text(workout.name)
                                    Spacer()
                                    VStack {
                                        Text("Last Performed:")
                                        Text(viewModel.getLastTimePerformed(workoutName: workout.name))
                                    }
                                    .font(.footnote)
                                    .opacity(0.6)
                                }
                            }
                            .swipeActions {
                                Button("Remove") {                                    
                                    print("Remove Workout: " + workout.name)
                                    viewModel.removeWorkout(workoutName: workout.name)
                                }
                                .tint(.red)
                            }
                        }
                        .padding([.leading, .trailing], 5)
                        .padding([.top, .bottom], 5)
                    }
                    
                    Button {
                        viewModel.addNewWorkoutClicked()
                    } label: {
                        Text("Add new workout")
                            .multilineTextAlignment(.center)
                            .font(.body)
                            .fontWeight(.semibold)
                            .cornerRadius(10)
                    }
                    .padding()
                    .buttonStyle(.borderedProminent)
                    .tint(Color.brandPrimary)
                }
                .navigationTitle("Workouts 💪")
            }
            .blur(radius: (viewModel.isWorkoutSelected ||
                           viewModel.isShowingAddNewWorkout) ? 20 : 0)
            .disabled(viewModel.isWorkoutSelected ||
                      viewModel.isShowingAddNewWorkout)
            
            if viewModel.isWorkoutSelected {
                WorkoutView(isWorkoutSelected: $viewModel.isWorkoutSelected,
                            selectedWorkout: viewModel.selectedWorkout!)
                .onDisappear(perform: {
                    viewModel.refreshWorkouts()
                })
            }
            
            if viewModel.isShowingAddNewWorkout {
                NewWorkoutView(isShowingNewWorkout: $viewModel.isShowingAddNewWorkout)
                    .onDisappear(perform: {
                        viewModel.refreshWorkouts()
                    })
            }
        }
        .onAppear {
          self.viewModel.setup(self.dbMgr)
        }
    }
}

struct WorkoutsView_Previews: PreviewProvider {
    static let dbMgr = DbManager(db_path: "WorkoutTracker.sqlite")
    static var previews: some View {
        WorkoutsView()
            .environmentObject(dbMgr)
    }
}
