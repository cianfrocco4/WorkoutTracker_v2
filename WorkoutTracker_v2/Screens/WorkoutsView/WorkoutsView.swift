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
                        }
                        .padding([.leading, .trailing], 5)
                        .padding([.top, .bottom], 5)
                    }
                }
                .navigationTitle("Workouts 💪")
            }
            .blur(radius: viewModel.isWorkoutSelected ? 30 : 0)
            .disabled(viewModel.isWorkoutSelected)
            
            if viewModel.isWorkoutSelected {
                WorkoutView(isWorkoutSelected: $viewModel.isWorkoutSelected,
                            selectedWorkout: viewModel.selectedWorkout!)
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

struct Workout: Decodable, Identifiable {
    var id        : Int
    var name      : String
    var exercises : [Exercise]
}

struct Exercise: Decodable, Identifiable {
    var id      : Int
    var name    : String
    var sets    : Int
    var minReps : Int
    var maxReps : Int
    var weight  : Int
}

struct ExerciseData : Identifiable {
    var id   : Int
    var set  : String
    var reps : TextBindingManager
    var wgt  : TextBindingManager
}

struct MockData {
    static let sampleExercises = [
        Exercise(id: 0, name: "Pull ups", sets: 3, minReps: 8, maxReps: 10, weight: 30),
        Exercise(id: 1, name: "Barbell Curls", sets: 3, minReps: 10, maxReps: 12, weight: 50),
        Exercise(id: 2, name: "Lat Pulldowns", sets: 3, minReps: 10, maxReps: 12, weight: 120)
    ]
    
    static let sampleWorkout1 = Workout(id: 0, name: "Pull 1", exercises: sampleExercises)
    static let sampleWorkout2 = Workout(id: 1, name: "Pull 2", exercises: sampleExercises)
    
    static let sampleRepsWeightArr = Array(repeating: TextBindingManager(limit: 3),
                                           count: 3) 
}
