-- table creation


CREATE TABLE groups (
	id           serial PRIMARY KEY UNIQUE NOT NULL, 
	full_name    varchar UNIQUE NOT NULL, 
	short_name   varchar UNIQUE NOT NULL, 
	students_ids integer[] 
);


CREATE TABLE students (
	id          serial PRIMARY KEY UNIQUE NOT NULL, 
	first_name  varchar NOT NULL, 
	last_name   varchar NOT NULL, 
	group_id    integer REFERENCES groups(id), 
	courses_ids integer[], 

	CONSTRAINT student_in_group FOREIGN KEY(group_id)
		REFERENCES groups(id)
		ON UPDATE CASCADE 
		ON DELETE SET NULL
);


CREATE TABLE courses (
	id 		  serial PRIMARY KEY UNIQUE NOT NULL, 
	name 	  varchar UNIQUE NOT NULL, 
	is_exam   boolean NOT NULL DEFAULT true, 
	min_grade varchar(1) CHECK (min_grade SIMILAR TO '[A-F]'),
	max_grade varchar(1) CHECK (max_grade SIMILAR TO '[A-F]' AND max_grade <= min_grade)
);


CREATE TABLE psychology_course (
	id          serial PRIMARY KEY UNIQUE NOT NULL, 
	student_id  integer REFERENCES students(id)
		ON UPDATE CASCADE
		ON DELETE CASCADE, 
	grade_str   varchar(1) CHECK (grade_str SIMILAR TO '[A-F]'),
	grade       integer NOT NULL
);


CREATE OR REPLACE FUNCTION set_grade()
RETURNS TRIGGER AS $$
BEGIN
	CASE 
		WHEN NEW.grade_str = 'A' THEN NEW.grade = 5;
		WHEN NEW.grade_str = 'B' OR NEW.grade_str = 'C' THEN NEW.grade = 4;
		WHEN NEW.grade_str = 'D' OR NEW.grade_str = 'E' THEN NEW.grade = 3;
		WHEN NEW.grade_str = 'F' THEN NEW.grade = 2;
	END CASE;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_grade_with_grade_str
BEFORE INSERT OR UPDATE ON psychology_course
FOR EACH ROW EXECUTE FUNCTION set_grade();


CREATE OR REPLACE FUNCTION check_valid_grade() 
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.grade_str > (SELECT min_grade FROM courses WHERE name = 'Психология') THEN
        RAISE EXCEPTION 'grade_str must be larger than min_grade set in table "courses"';
    END IF;
	IF NEW.grade_str < (SELECT max_grade FROM courses WHERE name = 'Психология') THEN
        RAISE EXCEPTION 'grade_str must be less than max_grade set in table "courses"';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_valid_grade_str
BEFORE INSERT OR UPDATE ON psychology_course
FOR EACH ROW EXECUTE FUNCTION check_valid_grade();


-- table filling


INSERT INTO groups(full_name, short_name) VALUES
('21.Б13-ММ', '431'),
('22.Б13-ММ', '331'),
('23.Б13-ММ', '231'),
('24.Б31-ММ', '131'),
('24.М81-ММ', '181м'),
('24.М82-ММ', '182м');

INSERT INTO courses(name, is_exam, min_grade, max_grade) VALUES
('Математический анализ', true, 'F', 'A'),
('Алгебра и теория чисел', true, 'F', 'C'),
('Машинное обучение', true, 'F', 'A'),
('Психология', false, 'F', 'A'),
('Теория байесовских сетей', true, 'F', 'A'),
('Геометрия', true, 'F', 'A');

INSERT INTO students(first_name, last_name, group_id, courses_ids) VALUES
('Алексей', 'Савельев', 1, '{3,4}'),
('Анна', 'Мясникова', 2, '{3}'),
('Дмитрий', 'Валерьев', 3, '{1,2,6}'),
('Елена', 'Морозова', 3, '{1,2,6}'),
('Сергей', 'Овчинников', 3, '{1,2,6}'),
('Ольга', 'Федоровская', 6, '{3,4,5}'),
('Александр', 'Золотарев', 1, '{3,4}'),
('Ксения', 'Рябинина', 1, '{3}'),
('Максим', 'Волков', 4, '{1,2,3,6}'),
('Наталья', 'Светличная', 6, '{3,4,5}');

INSERT INTO psychology_course(student_id, grade_str) VALUES
(1, 'A'),
(6, 'C'),
(7, 'C'),
(10, 'B');


-- filtering


SELECT * FROM students WHERE 4=ANY(courses_ids);

SELECT full_name, students_ids FROM GROUPS WHERE short_name LIKE '18%';

SELECT students.last_name, courses.name, courses.is_exam FROM courses JOIN students 
	ON courses.id = ANY(students.courses_ids) 
	WHERE students.group_id > 3;


-- agregation


SELECT AVG(grade) FROM psychology_course;
SELECT BOOL_AND(is_exam) FROM courses 
	WHERE courses.name ILIKE '%теория%';
SELECT COUNT(DISTINCT group_id) FROM students;

	