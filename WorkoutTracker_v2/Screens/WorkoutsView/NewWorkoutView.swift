//
//  NewWorkoutView.swift
//  WorkoutTracker_v2
//
//  Created by Anthony Cianfrocco on 3/19/23.
//

import SwiftUI

struct NewWorkoutView: View {
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var workoutModel : WorkoutModel
    
    @StateObject private var viewModel = NewWorkoutViewModel()
                
    var body: some View {
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
            
            if viewModel.newWorkout.name != "" {
                NavigationLink(
                    destination:
                        NewExerciseView(exercises: $viewModel.newWorkout.exercises,
                                        swapIdx: .constant(nil),
                                        saveToDb: false),
                    label: {
                        Text("Add new exercise")
                    })
                .padding(.bottom)
            }
            
            HStack {
                Button {
                    if viewModel.newWorkout.name != "" {
                        workoutModel.addNewWorkout(workout: viewModel.newWorkout)
                        self.presentationMode.wrappedValue.dismiss()
                    }
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
                    // FUTURE: should add pop up to confirm before canceling
                    self.presentationMode.wrappedValue.dismiss()
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
    }
}

struct NewWorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        NewWorkoutView()
    }
}
