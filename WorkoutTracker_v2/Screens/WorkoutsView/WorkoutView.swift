//
//  WorkoutView.swift
//  WorkoutTracker_v2
//
//  Created by Anthony Cianfrocco on 1/22/23.
//

import SwiftUI

struct WorkoutView: View {
    @Binding var isWorkoutSelected : Bool
    
    @State var selectedWorkout : Workout
    
    var body: some View {
        NavigationView {
            VStack {
                ExercisesView(workout: selectedWorkout,
                              exercises: selectedWorkout.exercises)
            }
            .navigationTitle(selectedWorkout.name)
        }
        .overlay(alignment: .topTrailing) {
            Button {
                isWorkoutSelected = false
            } label: {
                XDismissButton()
            }
        }
    }
}

struct WorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutView(isWorkoutSelected: .constant(true),
                    selectedWorkout: MockData.sampleWorkout1)
    }
}
