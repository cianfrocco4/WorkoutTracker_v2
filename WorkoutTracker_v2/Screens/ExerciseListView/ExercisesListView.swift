//
//  ExercisesListView.swift
//  WorkoutTracker_v2
//
//  Created by Anthony Cianfrocco on 2/12/23.
//

import SwiftUI

struct ExercisesListView: View {
    @StateObject private var viewModel = ExerciseListViewModel()
    
    @State private var filterStr = ""
    @State private var isShowingAddNewExer = false
    @State private var newExerciseName : String = ""
    
    @Binding var selectedExercise : String?

    var body: some View {
        ZStack {
            NavigationView {
                VStack {
                    SearchBar(text: $filterStr, placeholder: "Search Exercises")
                    TextField("Search", text: $filterStr)
                        .padding([.top, .leading, .trailing], 30)
                    List (selection: $selectedExercise){
                        ForEach(viewModel.exercises.filter({$0.caseInsensitiveCompare(filterStr).rawValue > 0}), id: \.self) { exercise in
                            Text(exercise)
                        }
                    }
                    
                    Button {
                        isShowingAddNewExer = true
                    } label: {
                        Text("Add New Exercise")
                    }
                }
                .navigationTitle("Exercises 🏋️")
            }
            .blur(radius: isShowingAddNewExer ? 20 : 0)
            .disabled(isShowingAddNewExer)
            
            if isShowingAddNewExer {
                VStack {
                    HStack {
                        Text("Exercise Name:")
                        TextField("Exercise Name", text: $newExerciseName)
                    }
                    
                    HStack {
                        Button {
                            isShowingAddNewExer = !isShowingAddNewExer
                            viewModel.addNewExercise(name: newExerciseName)
                        } label: {
                            Text("Save")
                                .multilineTextAlignment(.center)
                                .font(.body)
                                .fontWeight(.semibold)
                                .frame(width: 130, height: 30)
                                .foregroundColor(.primary)
                        }
                        .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Color(uiColor: UIColor.tertiarySystemBackground)))
                        
                        Button {
                            isShowingAddNewExer = !isShowingAddNewExer
                        } label: {
                            Text("Cancel")
                                .multilineTextAlignment(.center)
                                .font(.body)
                                .fontWeight(.semibold)
                                .frame(width: 130, height: 30)
                                .foregroundColor(.primary)
                        }
                        .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Color(uiColor: UIColor.tertiarySystemBackground)))
                    }
                }
                .padding([.top, .bottom])
                .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Color(uiColor: UIColor.systemBackground)))
            }
        }
    }
}

struct ExercisesListView_Previews: PreviewProvider {
    static var previews: some View {
        ExercisesListView(selectedExercise: .constant(""))
    }
}
