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


-- 3
 
SELECT students.first_name, students.last_name, courses.name AS course_name
FROM students 
JOIN student_courses ON students.id=student_courses.student_id
JOIN courses ON courses.id=student_courses.course_id;


CREATE TABLE machine_learning_course (
	id          serial PRIMARY KEY UNIQUE NOT NULL, 
	student_id  integer REFERENCES students(id)
		ON UPDATE CASCADE
		ON DELETE CASCADE, 
	grade_str   varchar(1) CHECK (grade_str SIMILAR TO '[A-F]'),
	grade       integer NOT NULL
);

CREATE TRIGGER set_grade_with_grade_str_mac
BEFORE INSERT OR UPDATE ON machine_learning_course
FOR EACH ROW EXECUTE FUNCTION set_grade();

SELECT student_id FROM student_courses 
WHERE course_id = 3
LIMIT 15;

INSERT INTO machine_learning_course(student_id, grade_str) VALUES
(1, 'B'),
(2, 'A'),
(6, 'D'),
(7, 'C'),
(8, 'A'),
(10, 'A');

SELECT students.first_name, students.last_name 
FROM students 
JOIN student_courses ON students.id=student_courses.student_id
JOIN courses ON courses.id=student_courses.course_id
    GROUP BY 
;





