//
//  NewWorkoutView.swift
//  WorkoutTracker_v2
//
//  Created by Anthony Cianfrocco on 3/19/23.
//

import SwiftUI

struct NewWorkoutView: View {
    @StateObject private var viewModel = NewWorkoutViewModel()
    
    @Binding var isShowingNewWorkout : Bool
        
    @EnvironmentObject var dbMgr : DbManager
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Text("Workout Name:")
                    TextField("Workout Name", text: $viewModel.newWorkout.name)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit {
                            viewModel.loadDeletedWorkout()
                        }
                }
                .padding()
                
                List (viewModel.newWorkout.exercises) { exercise in
                    Text(exercise.name)
                }
                .frame(maxHeight: 200)
                
                Button {
                    if viewModel.newWorkout.name != "" {
                        viewModel.isShowingNewExer = true
                    }
                    else {
                        print("Workout name must be set to add exercise!")
                    }
                } label: {
                    Text("Add new exercise")
                }
                .padding(.bottom)
                
                HStack {
                    Button {
                        viewModel.addNewWorkout()
                        isShowingNewWorkout = false
                    } label: {
                        Text("Save")
                            .multilineTextAlignment(.center)
                            .font(.body)
                            .fontWeight(.semibold)
                            .frame(width: 130, height: 30)
                            .foregroundColor(.primary)
                            .cornerRadius(10)
                    }
                    .background(Color(UIColor.tertiarySystemBackground))
                    
                    Button {
                        isShowingNewWorkout = false
                    } label: {
                        Text("Cancel")
                            .multilineTextAlignment(.center)
                            .font(.body)
                            .fontWeight(.semibold)
                            .frame(width: 130, height: 30)
                            .foregroundColor(.primary)
                            .cornerRadius(10)
                    }
                    .background(Color(UIColor.tertiarySystemBackground))
                }
                .buttonStyle(.bordered)
            }
            .disabled(viewModel.isShowingNewExer)
            .blur(radius: viewModel.isShowingNewExer ? 20 : 0)
            
            if viewModel.isShowingNewExer {
                NewExerciseView(workout: viewModel.newWorkout,
                                isShwoingAddNewExer: $viewModel.isShowingNewExer,
                                isShowingSwapExer: .constant(false),
                                exercises: $viewModel.newWorkout.exercises,
                                swapIdx: .constant(nil))
            }
        }
    }
}

struct NewWorkoutView_Previews: PreviewProvider {
    static let dbMgr = DbManager(db_path: "WorkoutTracker.sqlite")

    static var previews: some View {
        NewWorkoutView(isShowingNewWorkout: .constant(true))
            .environmentObject(dbMgr)
    }
}
