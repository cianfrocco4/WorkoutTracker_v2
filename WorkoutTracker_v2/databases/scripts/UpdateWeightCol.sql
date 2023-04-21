DROP TABLE IF EXISTS tmp_ExerciseHistory;

CREATE TABLE tmp_ExerciseHistory ( workoutName STRING NOT NULL,
                                   exerciseName STRING NOT NULL, 
                                   setNum INTEGER NOT NULL,
                                   reps INTEGER NOT NULL,
                                   weight REAL NOT NULL,
                                   notes STRING,
                                   date STRING NOT NULL,
                                   PRIMARY KEY (workoutName, exerciseName, setNum, date),
                                   FOREIGN KEY (workoutName) REFERENCES Workout (name) 
                                   FOREIGN KEY (exerciseName) REFERENCES Exercise (name) );

insert into tmp_ExerciseHistory (workoutName, exerciseName, setNum, reps, weight, notes, date) select * from ExerciseHistory ;

DROP TABLE IF EXISTS ExerciseHistory;

CREATE TABLE ExerciseHistory ( workoutName STRING NOT NULL,
                               exerciseName STRING NOT NULL,
                               setNum INTEGER NOT NULL,
                               reps INTEGER NOT NULL,
                               weight REAL NOT NULL,
                               notes STRING,
                               date STRING NOT NULL,
                               PRIMARY KEY (workoutName, exerciseName, setNum, date),
                               FOREIGN KEY (workoutName) REFERENCES Workout (name)
                               FOREIGN KEY (exerciseName) REFERENCES Exercise (name) );

insert into ExerciseHistory (workoutName, exerciseName, setNum, reps, weight, notes, date) select * from tmp_ExerciseHistory ;

DROP TABLE IF EXISTS tmp_ExerciseHistory; 
