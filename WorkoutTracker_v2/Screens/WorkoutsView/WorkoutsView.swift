//
//  WorkoutView.swift
//  WorkoutTracker_v2
//
//  Created by Anthony Cianfrocco on 1/18/23.
//

import SwiftUI

struct WorkoutsView: View {
    
    @EnvironmentObject private var workoutModel : WorkoutModel
    
    @StateObject private var viewModel = WorkoutsViewModel()
        
    var body: some View {
        ZStack {
            NavigationView {
                VStack {
                    WorkoutHistoryView(workouts: $workoutModel.historicalWorkouts)
                        .padding(.top)
                    List {
                        ForEach($workoutModel.workouts) { $workout in
                            NavigationLink(
                                destination:
                                    WorkoutView()
                                    .environmentObject(workout)
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
                                NavigationLink(
                                    destination: EditWorkoutView(workout: $workout),
                                    label: {
                                        Text("Edit workout")
                                    })
                                .tint(.yellow)
                                
                                Button("Remove") {
                                    print("Remove Workout: " + workout.name)
                                    workoutModel.removeWorkout(workoutName: workout.name)
                                }
                                .tint(.red)
                            }
                        }
                        .padding([.leading, .trailing], 5)
                        .padding([.top, .bottom], 5)
                    }
                    
                    NavigationLink(
                        destination: NewWorkoutView(),
                        label: {
                            Text("Add new workout")
                        })
                    .padding()
                    .buttonStyle(.borderedProminent)
                    .tint(Color.brandPrimary)
                }
                .navigationTitle("Workouts 💪")
            }
        }
        .onAppear() {
            viewModel.setup()
        }
    }
}

struct WorkoutsView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutsView()
    }
}
