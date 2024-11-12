-- 1


CREATE TABLE student_courses (
	id         serial PRIMARY KEY UNIQUE NOT NULL, 
	student_id integer REFERENCES students(id),
	course_id  integer REFERENCES courses(id), 

    CONSTRAINT no_repeats_studcours UNIQUE (student_id, course_id)
);

CREATE TABLE group_courses (
	id         serial PRIMARY KEY UNIQUE NOT NULL, 
	group_id   integer REFERENCES groups(id),
	course_id  integer REFERENCES courses(id), 

    CONSTRAINT no_repeats_groucours UNIQUE (group_id, course_id)
);


INSERT INTO student_courses(student_id, course_id)
    SELECT id, UNNEST(courses_ids) AS course_id FROM students;

INSERT INTO group_courses(group_id, course_id)
    SELECT group_id, UNNEST(courses_ids) AS course_id FROM students
    ON CONFLICT DO NOTHING;


ALTER TABLE students DROP COLUMN courses_ids;

ALTER TABLE groups DROP COLUMN students_ids;




