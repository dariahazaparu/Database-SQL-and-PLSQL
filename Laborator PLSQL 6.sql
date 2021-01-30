-- Exercitii preluate din materialele scrise de Lect. Univ. Dr. Gabriela Mihai

-- 1. Definiți un declanșator care să permită ștergerea informațiilor din tabelul dept_*** decât dacă utilizatorul este SCOTT.
-- 2. Creați un declanșator prin care să nu se permită mărirea comisionului astfel încât să depășească 50% din valoarea salariului.
-- 3. a. Introduceți în tabelul info_dept_*** coloana numar care va reprezenta pentru fiecare departament numărul de angajați care lucrează în departamentul respectiv. Populați cu date această coloană pe baza informațiilor din schemă.
-- b. Definiți un declanșator care va actualiza automat această coloană în funcție de actualizările realizate asupra tabelului info_emp_***.
-- 4. Definiți un declanșator cu ajutorul căruia să se implementeze restricția conform căreia într-un departament nu pot lucra mai mult de 45 persoane (se vor utiliza doar tabelele emp_*** și dept_*** fără a modifica structura acestora).
-- 5. a. Pe baza informațiilor din schemă creați și populați cu date următoarele două tabele:
-- - emp_test_*** (employee_id – cheie primară, last_name, first_name, department_id);
-- - dept_test_*** (department_id – cheie primară, department_name).
-- b. Definiți un declanșator care va determina ștergeri și modificări în cascadă:
-- - ștergerea angajaților din tabelul emp_test_*** dacă este eliminat departamentul acestora din tabelul dept_test_***;
-- - modificarea codului de departament al angajaților din tabelul emp_test_*** dacă departamentul respectiv este modificat în tabelul dept_test_***.
-- Testați și rezolvați problema în următoarele situații:
-- - nu este definită constrângere de cheie externă între cele două tabele;
-- - este definită constrângerea de cheie externă între cele două tabele;
-- - este definită constrângerea de cheie externă între cele două tabele cu opțiunea ON DELETE CASCADE;
-- - este definită constrângerea de cheie externă între cele două tabele cu opțiunea ON DELETE SET NULL.
-- Comentați fiecare caz în parte.
-- 6. a. Creați un tabel cu următoarele coloane:
-- - user_id (SYS.LOGIN_USER);
-- - nume_bd (SYS.DATABASE_NAME);
-- - erori (DBMS_UTILITY.FORMAT_ERROR_STACK);
-- - data.
-- b. Definiți un declanșator sistem (la nivel de bază de date) care să introducă date în acest tabel referitoare la erorile apărute.

SELECT
    *
FROM
    dept_hd;

SELECT
    *
FROM
    emp_hd;

--1

CREATE OR REPLACE TRIGGER trig1_hd BEFORE
    DELETE ON dept_hd
BEGIN
    IF
        user NOT LIKE 'SCOTT'
    THEN
        raise_application_error(-20001,'Nu poti sterge din tabel');
    END IF;
END;
/

DROP TRIGGER trig1_hd;

DELETE FROM dept_hd
WHERE
    department_id = 20;

--2

CREATE OR REPLACE TRIGGER trig2_hd BEFORE
    UPDATE OF commission_pct ON emp_hd
    FOR EACH ROW
BEGIN
    IF
        (:new.commission_pct > 0.5 )
    THEN
        raise_application_error(-20001,'Comision prea mare');
    END IF;
END;
/

DROP TRIGGER trig2_hd;

UPDATE emp_hd
SET
    commission_pct = 0.6
WHERE
    employee_id = 100;

--3

CREATE TABLE info_dept_hd
    AS
        SELECT
            *
        FROM
            info_dept_prof;

SELECT
    *
FROM
    info_dept_hd;

ALTER TABLE info_dept_hd ADD numar NUMBER;

UPDATE info_dept_hd
SET
    numar = 0;

BEGIN
    FOR i IN (
        SELECT
            *
        FROM
            info_dept_hd
    ) LOOP
        FOR j IN (
            SELECT
                employee_id,
                department_id
            FROM
                emp_hd
        ) LOOP
            IF
                j.department_id = i.id
            THEN
                UPDATE info_dept_hd
                SET
                    numar = numar + 1
                WHERE
                    id = i.id;

            END IF;
        END LOOP;
    END LOOP;
END;
/

SELECT
    *
FROM
    info_emp_hd;

CREATE OR REPLACE TRIGGER trig3_hd AFTER
    UPDATE OR DELETE OR INSERT ON info_emp_hd
    FOR EACH ROW
BEGIN
    IF
        deleting
    THEN
        UPDATE info_dept_hd
        SET
            numar = numar - 1
        WHERE
            id =:old.id_dept;

    ELSIF inserting THEN
        UPDATE info_dept_hd
        SET
            numar = numar + 1
        WHERE
            id =:new.id_dept;

    ELSIF updating THEN
        IF
            (:new.id_dept !=:old.id_dept )
        THEN
            UPDATE info_dept_hd
            SET
                numar = numar + 1
            WHERE
                id =:new.id_dept;

            UPDATE info_dept_hd
            SET
                numar = numar - 1
            WHERE
                id =:old.id_dept;

        END IF;
    END IF;
END;
/

DROP TRIGGER trig3_hd;

UPDATE info_emp_hd
SET
    id_dept = 90
WHERE
    id = 104;

ROLLBACK;

--4

CREATE OR REPLACE TRIGGER trig4_hd BEFORE
    UPDATE OR INSERT ON emp_hd
    FOR EACH ROW
DECLARE
    nr_ang   NUMBER;
BEGIN
    SELECT
        COUNT(employee_id)
    INTO nr_ang
    FROM
        emp_hd
    WHERE
        department_id =:new.department_id;

    IF
        nr_ang + 1 > 45
    THEN
        raise_application_error(-20005,'Prea multi angajati.');
    END IF;
END;
/

SELECT
    *
FROM
    emp_hd;

SELECT
    *
FROM
    info_dept_hd;

INSERT INTO emp_hd VALUES (
    300,
    'a',
    'b',
    'c',
    'd',
    SYSDATE,
    'SA_MAN',
    10000,
    NULL,
    100,
    50
);

--5

CREATE TABLE emp_test_hd (
    employee_id     NUMBER PRIMARY KEY,
    last_name       VARCHAR2(30),
    first_name      VARCHAR2(30),
    department_id   NUMBER
);

CREATE TABLE dept_test_hd (
    department_id     NUMBER PRIMARY KEY,
    department_name   VARCHAR2(30)
);

BEGIN
    FOR i IN (
        SELECT
            employee_id,
            last_name,
            first_name,
            department_id
        FROM
            emp_hd
    ) LOOP
        INSERT INTO emp_test_hd VALUES (
            i.employee_id,
            i.last_name,
            i.first_name,
            i.department_id
        );

    END LOOP;

    FOR i IN (
        SELECT
            department_id,
            department_name
        FROM
            dept_hd
    ) LOOP
        INSERT INTO dept_test_hd VALUES (
            i.department_id,
            i.department_name
        );

    END LOOP;

END;
/

SELECT
    *
FROM
    emp_test_hd;

SELECT
    *
FROM
    dept_test_hd;

CREATE OR REPLACE TRIGGER trig5_hd AFTER
    DELETE OR UPDATE ON dept_test_hd
    FOR EACH ROW
BEGIN
    IF
        deleting
    THEN
        DELETE FROM emp_test_hd
        WHERE
            department_id =:old.department_id;

    ELSIF updating THEN
        UPDATE emp_test_hd
        SET
            department_id =:new.department_id
        WHERE
            department_id =:old.department_id;

    END IF;
END;
/

DELETE FROM dept_test_hd
WHERE
    department_id = 80;

UPDATE dept_test_hd
SET
    department_id = 500
WHERE
    department_id = 80;

ROLLBACK;

ALTER TABLE emp_test_hd
    ADD CONSTRAINT fk_100 FOREIGN KEY ( department_id )
        REFERENCES dept_test_hd ( department_id );

--6

CREATE TABLE errors_hd (
    utilizator   VARCHAR2(300),
    nume_bd      VARCHAR2(500),
    eroare       VARCHAR2(500),
    data         DATE
);

CREATE OR REPLACE TRIGGER trig6_hd AFTER SERVERERROR ON SCHEMA BEGIN
    INSERT INTO errors_hd VALUES (
        sys.login_user,
        sys.database_name,
        dbms_utility.format_error_stack,
        SYSDATE
    );

END;
/

SELECT
    *
FROM
    errors_hd;