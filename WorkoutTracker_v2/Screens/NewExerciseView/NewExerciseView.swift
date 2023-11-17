//
//  NewExerciseView.swift
//  WorkoutTracker_v2
//
//  Created by Anthony Cianfrocco on 3/5/23.
//

import SwiftUI

struct NewExerciseView: View {
    enum ExerciseType: String, CaseIterable, Identifiable {
        case permanent, temporary
        var id: Self { self }
    }
    
    enum Field: Hashable {
        case eeNumSets
        case eeMinNumReps
        case eeMaxNumReps
        case eeRestTime
    }
    
    @Environment(\.presentationMode) var presentation

    @State private var selectedType: ExerciseType = .temporary
    @State private var exerciseName = ""
    @State private var exerciseSearchTerm = ""
        
    @State var numberOfSets : Int?
    @State var minNumberOfReps : Int?
    @State var maxNumberOfReps : Int?
    @State var allExerciseNames : [String] = []
    
    @FocusState var focusedField : Field?
        
    @Binding var exercises : [Exercise]
    @Binding var swapIdx : Int?
    
    var selectedWkout : Workout?
    var saveToDb : Bool
    
    private let MAX_REST_TIME_SEC = 600
    
    var filteredExercises: [String] {
        allExerciseNames.filter {
            exerciseSearchTerm.isEmpty ? true :
                                         $0.lowercased().contains(exerciseSearchTerm.lowercased())
        }
    }

    var body: some View {
        VStack {
            
            if swapIdx != nil &&
                exercises.indices.contains(swapIdx!) {
                Text("Swapping: \(exercises[swapIdx!].name)")
                    .font(.title3)
            }
            
            HStack {
                VStack {
                    HStack {
                        Text("Exercise Name:")
                        Spacer()
                    }
                    .padding([.leading, .top], 3)
                    
                    VStack {
                        SearchBar(text: $exerciseSearchTerm, placeholder: "Search Exercises")
                        Picker(selection: $exerciseName,
                               label: Text("Exercise Name")) {
                            ForEach(filteredExercises, id: \.self) { exer in
                                Text(exer).tag(exer)
                            }
                        }
                       .pickerStyle(.wheel)
                       .frame(minHeight: 100)
                    }
                    .background(RoundedRectangle(cornerRadius: 20).fill(Color(uiColor: UIColor.secondarySystemBackground)))
                }
            }
            .padding(.bottom)
            
            HStack {
                Text("Number of Sets:")
                TextField("# of Sets", value: $numberOfSets, format: .number)
                    .keyboardType(.numberPad)
                    .focused($focusedField, equals: .eeNumSets)
            }
            
            HStack {
                Text("Number of Reps:")
                TextField("Rep Min", value: $minNumberOfReps, format: .number)
                    .focused($focusedField, equals: .eeMinNumReps)
                TextField("Rep Max", value: $maxNumberOfReps, format: .number)
                    .focused($focusedField, equals: .eeMaxNumReps)
            }
            .keyboardType(.numberPad)
            
            if saveToDb {
                HStack {
                    Text("Exercise Type:")
                    Picker (selection: $selectedType, label: Text("Type")) {
                        Text("Temporary").tag(ExerciseType.temporary)
                        Text("Permenant").tag(ExerciseType.permanent)
                    }
                    .pickerStyle(.segmented)
                    
                    Spacer()
                }
            }
            
            HStack {
                Button {
                    if (exerciseName != "" &&
                        !exercises.contains(where: {$0.name == exerciseName}) && // don't add a duplicate exercise
                        numberOfSets != nil &&
                        minNumberOfReps != nil &&
                        maxNumberOfReps != nil) {
                        
                        let id = exercises.last != nil ? exercises.last!.id + 1 : 0
                        let e = Exercise(id: id,
                                         name: exerciseName,
                                         sets: numberOfSets!,
                                         minReps: minNumberOfReps!,
                                         maxReps: maxNumberOfReps!,
                                         weight: 0)
                        
                        var eToRemove : Exercise? = nil
                                                
                        if swapIdx == nil {
                            exercises.append(e)
                        }
                        else {
                            // get the exercise to remove before it is removed from the local list
                            eToRemove = swapIdx == nil ? nil : exercises[swapIdx!]

                            // Remove the swapped from item
                            exercises.remove(at: swapIdx!)
                            
                            // Add the swapped to item
                            exercises.insert(e, at: swapIdx!)
                        }
                        
                        if selectedWkout != nil &&
                            selectedType == ExerciseType.permanent &&
                            saveToDb {
                            // Upate the database
                            DbManager.shared.addExerciseToWorkout(workout: selectedWkout!, //workout,
                                                       exercise: e)
                            
                            if eToRemove != nil {
                                // remove the swapped from exercise from the workout
                                DbManager.shared.removeExerciseFromWorkout(workout: selectedWkout!, //workout,
                                                                exercise: eToRemove!)
                            }
                        }
                        
                        self.presentation.wrappedValue.dismiss()
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
                    self.presentation.wrappedValue.dismiss()
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
            .padding(.top)
        }
        .padding()
        .textFieldStyle(.roundedBorder)
        .background(RoundedRectangle(cornerRadius: 25, style: .continuous).fill(Color(uiColor: UIColor.systemBackground)))
        .onAppear() {
            // re-query to get updated list of exercises
            allExerciseNames = DbManager.shared.getExercises()
            exerciseName = allExerciseNames.first ?? ""
        }
        .onDisappear() {
            swapIdx = nil // nullify this field on disappear
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()

                Button("Done") {
                    focusedField = nil
                }
            }
        }
    }
}

struct NewExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        NewExerciseView(exercises: .constant(MockData.sampleExercises),
                        swapIdx: .constant(nil), 
                        selectedWkout: MockData.sampleWorkout1,
                        saveToDb: true)
    }
}
