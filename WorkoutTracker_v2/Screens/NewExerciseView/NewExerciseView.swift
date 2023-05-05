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

    @State private var selectedType: ExerciseType = .temporary
    @State private var exerciseName = ""
    @State private var exerciseSearchTerm = ""
        
    @State var numberOfSets : Int?
    @State var minNumberOfReps : Int?
    @State var maxNumberOfReps : Int?
    @State var allExerciseNames : [String] = []
        
    @Binding var isShwoingAddNewExer : Bool
    @Binding var isShowingSwapExer : Bool
    @Binding var exercises : [Exercise]
    @Binding var swapIdx : Int?
    
    @EnvironmentObject var dbMgr : DbManager
    @EnvironmentObject private var selectedWkout : Workout
    
    var filteredExercises: [String] {
        allExerciseNames.filter {
            exerciseSearchTerm.isEmpty ? true :
                                         $0.lowercased().contains(exerciseSearchTerm.lowercased())
        }
    }

    var body: some View {
        VStack {
            
            if isShowingSwapExer &&
                swapIdx != nil &&
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
                    .padding([.leading, .top])
                    
                    SearchBar(text: $exerciseSearchTerm, placeholder: "Search Exercises")
                    Picker(selection: $exerciseName,
                           label: Text("Exercise Name")) {
                        ForEach(filteredExercises, id: \.self) { exer in
                            Text(exer).tag(exer)
                        }
                    }
                           .pickerStyle(.wheel)
                           .frame(maxHeight: 100)
                }
                .background(RoundedRectangle(cornerRadius: 20).fill(Color(uiColor: UIColor.secondarySystemBackground)))
                Spacer()
            }
            .padding(.bottom)
            
            HStack {
                Text("Number of Sets:")
                TextField("# of Sets", value: $numberOfSets, format: .number)
                    .keyboardType(.numberPad)
            }
            
            HStack {
                Text("Number of Reps:")
                TextField("Rep Min", value: $minNumberOfReps, format: .number)
                TextField("Rep Max", value: $maxNumberOfReps, format: .number)
            }
            .keyboardType(.numberPad)
            
            HStack {
                Text("Exercise Type:")
                Picker (selection: $selectedType, label: Text("Type")) {
                    Text("Temporary").tag(ExerciseType.temporary)
                    Text("Permenant").tag(ExerciseType.permanent)
                }
                .pickerStyle(.segmented)
                
                Spacer()
            }
            
            HStack {
                Button {
                    if (exerciseName != "" &&
                        !exercises.contains(where: {$0.name == exerciseName}) && // don't add a duplicate exercise
                        numberOfSets != nil &&
                        minNumberOfReps != nil &&
                        maxNumberOfReps != nil) {
                        
                        isShwoingAddNewExer = false
                        isShowingSwapExer = false
                        
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
                        
                        if selectedType == ExerciseType.permanent {
                            // Upate the database
                            dbMgr.addExerciseToWorkout(workout: selectedWkout, //workout,
                                                       exercise: e)
                            
                            if eToRemove != nil {
                                // remove the swapped from exercise from the workout
                                dbMgr.removeExerciseFromWorkout(workout: selectedWkout, //workout,
                                                                exercise: eToRemove!)
                            }                        }
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
                    isShwoingAddNewExer = false
                    isShowingSwapExer = false
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
            allExerciseNames = dbMgr.getExercises()
            exerciseName = allExerciseNames.first ?? ""
        }
        .onDisappear() {
            swapIdx = nil // nullify this field on disappear
        }
    }
}

struct NewExerciseView_Previews: PreviewProvider {
    static let dbMgr = DbManager(db_path: "WorkoutTracker.sqlite")
    static var previews: some View {
        NewExerciseView(isShwoingAddNewExer: .constant(true),
                        isShowingSwapExer: .constant(false),
                        exercises: .constant(MockData.sampleExercises),
                        swapIdx: .constant(nil))
        .environmentObject(dbMgr)
        .environmentObject(MockData.sampleWorkout1)
    }
}
