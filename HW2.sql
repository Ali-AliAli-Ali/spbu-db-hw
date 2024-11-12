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


-- 2


-- done during table creation, but nevertheless
ALTER TABLE courses ADD UNIQUE (name);

-- indexing noteably enhances search query performance, if the table is large, and may reduce it otherwise. Indexes are a specific data structure, containing a copy of the table data subset and pointers to the original, organized in a way simplifying its search. 
CREATE INDEX group_idx ON students(group_id);


-- 3
 

SELECT students.first_name, students.last_name, courses.name AS course_name
FROM students 
JOIN student_courses ON students.id=student_courses.student_id
JOIN courses ON courses.id=student_courses.course_id
LIMIT 20;


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


CREATE VIEW students_avg_grades AS
	SELECT students.id, students.first_name, students.last_name, 
		(psychology_course.grade + machine_learning_course.grade)::float/2 AS average_grade
	FROM students 
	JOIN psychology_course       ON students.id=psychology_course.student_id
	JOIN machine_learning_course ON students.id=machine_learning_course.student_id;

SELECT * FROM students_avg_grades
WHERE average_grade = (
	SELECT MAX(average_grade) FROM students_avg_grades
)
LIMIT 10;


-- 4


SELECT student_courses_count.course_id, courses.name, student_courses_count.students_number FROM courses 
JOIN (
	SELECT course_id, COUNT(*) AS students_number
	FROM student_courses
		GROUP BY course_id
		ORDER BY course_id
) AS student_courses_count ON student_courses_count.course_id=courses.id

CREATE VIEW courses_avg_grades AS (
	SELECT AVG(machine_learning_course.grade) AS ml_avg_grade, AVG(psychology_course.grade) AS psy_avg_grade
	FROM machine_learning_course OUTER JOIN psychology_course; 
);





