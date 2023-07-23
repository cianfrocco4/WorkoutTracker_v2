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
                            NavigationLink(
                                destination:
                                    WorkoutView(isWorkoutSelected: $viewModel.isWorkoutSelected)
                                    .environmentObject(workout)
                                    .onDisappear(perform: {
                                        viewModel.refreshWorkouts()
                                    })
                                    .navigationTitle(workout.name),
                                label: {
                                    HStack {
                                        if workout.active {
                                            Circle()
                                                .fill(.green)
                                                .frame(width: 10, height: 10)
                                        }
                                        Text(workout.name)
                                        Spacer()
                                        VStack {
                                            Text("Last Performed:")
                                            Text(viewModel.getLastTimePerformed(workoutName: workout.name))
                                        }
                                        .font(.footnote)
                                        .opacity(0.6)
                                    }
                                })
                            .swipeActions {
                                Button("Edit") {
                                    print("Edit Workout: " + workout.name)
                                    viewModel.setEditWorkout(workoutName: workout.name)
                                }
                                .tint(.yellow)
                                
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
            .blur(radius: (viewModel.isShowingAddNewWorkout ||
                           viewModel.isShowingEditWorkout) ? 20 : 0)
            .disabled(viewModel.isShowingAddNewWorkout ||
                      viewModel.isShowingEditWorkout)

            if viewModel.isShowingAddNewWorkout {
                NewWorkoutView(isShowingNewWorkout: $viewModel.isShowingAddNewWorkout)
                .onDisappear(perform: {
                    viewModel.refreshWorkouts()
                })
            }
            else if viewModel.isShowingEditWorkout &&
                    viewModel.editWorkoutIdx != nil {
                EditWorkoutView(workout: $viewModel.workouts[viewModel.editWorkoutIdx!],
                                isShowingEditWorkout: $viewModel.isShowingEditWorkout,
                                workouts: viewModel.workouts)
                .onDisappear() {
                    viewModel.refreshWorkouts()
                }
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
