CREATE TABLE ExerciseHistory ( workoutName STRING NOT NULL,
                               exerciseName STRING NOT NULL, 
                               setNum INTEGER NOT NULL,
                               reps INTEGER NOT NULL,
                               weight INTEGER NOT NULL,
                               notes STRING,
                               PRIMARY KEY (workoutName, exerciseName, setNum),
                               FOREIGN KEY (workoutName) REFERENCES Workout (name) 
                               FOREIGN KEY (exerciseName) REFERENCES Exercise (name) ); 
