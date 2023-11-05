//
//  EditWorkoutView.swift
//  WorkoutTracker_v2
//
//  Created by Anthony Cianfrocco on 4/23/23.
//

import SwiftUI

struct EditWorkoutView: View {
    
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var workoutModel : WorkoutModel
    
    @Binding var workout : Workout
    
    @StateObject private var viewModel = EditWorkoutViewModel()
        
    var body: some View {
        VStack {
            HStack {
                Text("Workout Name: ")
                TextField("WorkoutName", text: $workout.name)
                    .textFieldStyle(.roundedBorder)
            }
            .padding()
            
            List (workout.exercises) { exercise in
                Text(exercise.name)
            }
            .frame(maxHeight: 200)
            
            if workout.name != "" {
                NavigationLink(
                    destination:
                        NewExerciseView(exercises: $workout.exercises,
                                        swapIdx: .constant(nil),
                                        saveToDb: false),
                    label: {
                        Text("Add new exercise")
                    })
                .padding(.bottom)
            }
            
            HStack {
                Button {
                    if(workout.name != "") {
                        workoutModel.removeWorkout(workoutName: workout.name)
                        workoutModel.addNewWorkout(workout: workout)
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
        .background(RoundedRectangle(cornerRadius: 25, style: .continuous).fill(Color(uiColor: UIColor.systemBackground)))
        .onAppear() {
            self.viewModel.setup(workoutName: workout.name)
        }
    }
}

struct EditWorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        EditWorkoutView(workout: .constant(MockData.sampleWorkout1))
    }
}
