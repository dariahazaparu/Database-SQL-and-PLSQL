-- Exercitii preluate din materialele scrise de Lect. Univ. Dr. Gabriela Mihai

-- 1. Creați tabelul info_*** cu următoarele coloane:
-- - utilizator (numele utilizatorului care a inițiat o comandă)
-- - data (data și timpul la care utilizatorul a inițiat comanda)
-- - comanda (comanda care a fost inițiată de utilizatorul respectiv)
-- - nr_linii (numărul de linii selectate/modificate de comandă)
-- - eroare (un mesaj pentru excepții).
-- 2. Modificați funcția definită la exercițiul 2, respectiv procedura definită la exercițiul 4 astfel încât să determine inserarea în tabelul info_*** a informațiile corespunzătoare fiecărui caz determinat de valoarea dată pentru parametru:
-- - există un singur angajat cu numele specificat;
-- - există mai mulți angajați cu numele specificat;
-- - nu există angajați cu numele specificat.
-- 3. Definiți o funcție stocată care determină numărul de angajați care au avut cel puțin 2 joburi diferite și care în prezent lucrează într-un oraș dat ca parametru. Tratați cazul în care orașul dat ca parametru nu există, respectiv cazul în care în orașul dat nu lucrează niciun angajat. Inserați în tabelul info_*** informațiile corespunzătoare fiecărui caz determinat de valoarea dată pentru parametru.
-- 4. Definiți o procedură stocată care mărește cu 10% salariile tuturor angajaților conduși direct sau indirect de către un manager al cărui cod este dat ca parametru. Tratați cazul în care nu există niciun manager cu codul dat. Inserați în tabelul info_*** informațiile corespunzătoare fiecărui caz determinat de valoarea dată pentru parametru.
-- 5. Definiți un subprogram care obține pentru fiecare nume de departament ziua din săptămână în care au fost angajate cele mai multe persoane, lista cu numele acestora, vechimea și venitul lor lunar. Afișați mesaje corespunzătoare următoarelor cazuri:
-- - într-un departament nu lucrează niciun angajat;
-- - într-o zi din săptămână nu a fost nimeni angajat.
-- Observații:
-- a. Numele departamentului și ziua apar o singură dată în rezultat.
-- b. Rezolvați problema în două variante, după cum se ține cont sau nu de istoricul joburilor angajaților.
-- 6. Modificați exercițiul anterior astfel încât lista cu numele angajaților să apară într-un clasament creat în funcție de vechimea acestora în departament. Specificați numărul poziției din clasament și apoi lista angajaților care ocupă acel loc. Dacă doi angajați au aceeași vechime, atunci aceștia ocupă aceeași poziție în clasament.

--1

CREATE TABLE info_hd (
    utilizator   VARCHAR2(30),
    data         TIMESTAMP,
    comanda      VARCHAR2(30),
    nr_linii     NUMBER(5),
    eroare       VARCHAR2(50)
);
    
--2

CREATE OR REPLACE FUNCTION f2_hd (
    v_nume   employees.last_name%TYPE DEFAULT 'Bell'
) RETURN NUMBER IS
    salariu   employees.salary%TYPE;
    nr        NUMBER(5);
BEGIN
    SELECT
        COUNT(*)
    INTO nr
    FROM
        employees
    WHERE
        last_name = v_nume;

    INSERT INTO info_hd VALUES (
        user,
        current_timestamp,
        'f2_hd ' || v_nume,
        nr,
        NULL
    );

    SELECT
        salary
    INTO salariu
    FROM
        employees
    WHERE
        last_name = v_nume;

    RETURN salariu;
EXCEPTION
    WHEN no_data_found THEN
        UPDATE info_hd
        SET
            eroare = 'Nu exista angajati cu numele dat',
            nr_linii = 0
        WHERE
            utilizator = user
            AND data = current_timestamp
            AND comanda = 'f2_hd ' || v_nume;

        dbms_output.put_line('Nu exista angajati cu numele dat');
        RETURN 0;
    WHEN too_many_rows THEN
        UPDATE info_hd
        SET
            eroare = 'Exista mai multi angajati cu numele dat',
            nr_linii = nr
        WHERE
            utilizator = user
            AND data = current_timestamp
            AND comanda = 'f2_hd ' || v_nume;

        dbms_output.put_line('Exista mai multi angajati cu numele dat');
        RETURN 0;
    WHEN OTHERS THEN
    
        UPDATE info_hd
        SET
            eroare = 'Alta eroare!',
            nr_linii = nr
        WHERE
            utilizator = user
            AND data = current_timestamp
            AND comanda = 'f2_hd ' || v_nume;

        dbms_output.put_line('Alta eroare!');
        RETURN 0;
END f2_hd;
/

BEGIN
    dbms_output.put_line('Salariul este ' || f2_hd('King') );
END;
/


--3

CREATE OR REPLACE FUNCTION f3_hd (
    oras   locations.city%TYPE DEFAULT 'Roma'
) RETURN NUMBER IS

    nr        NUMBER(5);
    TYPE vector IS
        TABLE OF employees.employee_id%TYPE;
    in_town   vector;
    job_h     vector;
    n         NUMBER(5) := 0;
    no_city_found EXCEPTION;
    nobody_works_in EXCEPTION;
BEGIN
    INSERT INTO info_hd VALUES (
        user,
        current_timestamp,
        'f3_hd ' || oras,
        n,
        NULL
    );

    SELECT
        COUNT(*)
    INTO nr
    FROM
        locations
    WHERE
        city = oras;

    IF
        nr = 0
    THEN
        RAISE no_city_found;
    END IF;

-- ang care lucreaza in oras
    SELECT
        employee_id
    BULK COLLECT
    INTO in_town
    FROM
        employees e
        JOIN departments d ON e.department_id = d.department_id
        JOIN locations l ON d.location_id = l.location_id
    WHERE
        city = oras;

    IF
        in_town.count = 0
    THEN
        RAISE nobody_works_in;
    END IF;
    
--ang cu 2 job uri
    SELECT DISTINCT
        employee_id
    BULK COLLECT
    INTO job_h
    FROM
        job_history jh
    WHERE
        (
            SELECT
                COUNT(DISTINCT job_id)
            FROM
                job_history
            WHERE
                employee_id = jh.employee_id
        ) >= 2;

    FOR i IN in_town.first..in_town.last LOOP
        FOR j IN job_h.first..job_h.last LOOP
            IF
                in_town(i) = job_h(j)
            THEN
                n := n + 1;
            END IF;
        END LOOP;
    END LOOP;

    UPDATE info_hd
    SET
        nr_linii = n
    WHERE
        utilizator = user
        AND data = current_timestamp
        AND comanda = 'f3_hd ' || oras;

    RETURN n;
EXCEPTION
    WHEN no_city_found THEN
        UPDATE info_hd
        SET
            eroare = 'Nu exista un oras cu numele dat.',
            nr_linii = 0
        WHERE
            utilizator = user
            AND data = current_timestamp
            AND comanda = 'f3_hd ' || oras;

        dbms_output.put_line('Nu exista un oras cu numele dat.');
        RETURN 0;
    WHEN nobody_works_in THEN
        UPDATE info_hd
        SET
            eroare = 'Nu lucreaza nimeni in orasul dat',
            nr_linii = 0
        WHERE
            utilizator = user
            AND data = current_timestamp
            AND comanda = 'f3_hd ' || oras;

        dbms_output.put_line('Nu lucreaza nimeni in orasul dat');
        RETURN 0;
    WHEN OTHERS THEN
        UPDATE info_hd
        SET
            eroare = 'Alta eroare!',
            nr_linii = 0
        WHERE
            utilizator = user
            AND data = current_timestamp
            AND comanda = 'f3_hd ' || oras;

        dbms_output.put_line('Alta eroare!');
        RETURN 0;
END;
/

BEGIN
    dbms_output.put_line('Nr este ' || f3_hd('Seattle') );
END;
/


--4

CREATE OR REPLACE PROCEDURE p4_hd (
    cod emp_hd.employee_id%TYPE
) IS
    n    NUMBER := 0;
    nr   NUMBER;
    no_man_found EXCEPTION;
BEGIN
    INSERT INTO info_hd VALUES (
        user,
        current_timestamp,
        'p4_hd ' || cod,
        n,
        NULL
    );

    SELECT
        COUNT(*)
    INTO nr
    FROM
        employees
    WHERE
        manager_id = cod;

    IF
        nr = 0
    THEN
        RAISE no_man_found;
    END IF;
    UPDATE emp_hd e
    SET
        salary = 1.1 * salary
    WHERE
        cod IN (
            SELECT
                manager_id
            FROM
                employees
                -- arbore pt indirect
            START WITH
                employee_id = e.employee_id
            CONNECT BY
                PRIOR manager_id = employee_id
        );

EXCEPTION
    WHEN no_man_found THEN
        UPDATE info_hd
        SET
            eroare = 'Nu exista manager cu codul dat.'
        WHERE
            utilizator = user
            AND data = current_timestamp
            AND comanda = 'p4_hd ' || cod;

        dbms_output.put_line('Nu exista manager cu codul dat.');
END;
/

BEGIN
    p4_hd(100);
END;
/

SELECT
    *
FROM
    info_hd;
    
--5

CREATE OR REPLACE PROCEDURE p5_hd AS

    TYPE zile IS
        TABLE OF NUMBER;
    sapt    zile := zile ();
    w       NUMBER;
    ang     NUMBER;
    maxim   NUMBER;
    pos     NUMBER;
BEGIN
    FOR i IN 1..7 LOOP
        sapt.extend ();
        sapt(i) := i;
    END LOOP;

    FOR i IN (
        SELECT
            department_id d_id,
            department_name d_name
        FROM
            departments
    ) LOOP
        dbms_output.put_line('=================================');
        dbms_output.put_line(i.d_name);
        dbms_output.put_line('---------------------------------');
        SELECT
            COUNT(*)
        INTO w
        FROM
            employees
        WHERE
            department_id = i.d_id;

        IF
            w = 0
        THEN
            dbms_output.put_line('Aici nu lucreaza nimeni.');
            dbms_output.new_line ();
        ELSE
            maxim := 0;
            pos := 0;
            FOR j IN sapt.first..sapt.last LOOP
                IF
                    sapt(j) = 1
                THEN
                    dbms_output.put('Luni      (1) -> ');
                ELSIF sapt(j) = 2 THEN
                    dbms_output.put('Marti     (2) -> ');
                ELSIF sapt(j) = 3 THEN
                    dbms_output.put('Miercuri  (3) -> ');
                ELSIF sapt(j) = 4 THEN
                    dbms_output.put('Joi       (4) -> ');
                ELSIF sapt(j) = 5 THEN
                    dbms_output.put('Vineri    (5) -> ');
                ELSIF sapt(j) = 6 THEN
                    dbms_output.put('Sambata   (6) -> ');
                ELSIF sapt(j) = 7 THEN
                    dbms_output.put('Duminica  (7) -> ');
                END IF;

                ang := 0;
                SELECT
                    COUNT(*)
                INTO ang
                FROM
                    employees
                WHERE
                    TO_CHAR(hire_date,'d') = TO_CHAR(sapt(j) )
                    AND department_id = i.d_id;

                IF
                    ang = 0
                THEN
                    dbms_output.put('nu s-au facut angajari');
                ELSE
                    dbms_output.put(ang);
                END IF;

                IF
                    maxim < ang
                THEN
                    maxim := ang;
                    pos := j;
                END IF;
                dbms_output.new_line ();
            END LOOP;

            dbms_output.put_line('^^^ Maxim: '
                                   || maxim
                                   || ' angajari in ziua '
                                   || pos);
            FOR k IN (
                SELECT
                    employee_id,
                    last_name,
                    department_id,
                    hire_date,
                    salary
                FROM
                    employees
            ) LOOP
                IF
                    TO_CHAR(k.hire_date,'d') = pos AND k.department_id = i.d_id
                THEN
                    dbms_output.put_line('-> '
                                           || k.last_name
                                           || ' cu o vechime de '
                                           || TO_CHAR(round(SYSDATE - k.hire_date) )
                                           || ' zile si un venit lunar de '
                                           || k.salary);

                END IF;
            END LOOP;

            dbms_output.new_line ();
        END IF;

    END LOOP;

END;
/

BEGIN
    p5_hd;
END;
/

--6

CREATE OR REPLACE PROCEDURE p6_hd AS

    TYPE zile IS
        TABLE OF NUMBER;
    TYPE ang_rec IS RECORD ( e_id            employees.employee_id%TYPE,
    nume            employees.last_name%TYPE,
    vechime         NUMBER,
    dept            employees.department_id%TYPE,
    salariu         employees.salary%TYPE );
    TYPE t_ang_rec IS
        TABLE OF ang_rec;
    sapt            zile := zile ();
    emp             ang_rec;
    clasament       t_ang_rec := t_ang_rec ();
    iindex          NUMBER := 1;
    w               NUMBER;
    ang             NUMBER;
    maxim           NUMBER;
    pos             NUMBER;
    pos_clasament   NUMBER;
BEGIN
    FOR i IN 1..7 LOOP
        sapt.extend ();
        sapt(i) := i;
    END LOOP;

    FOR i IN (
        SELECT
            department_id d_id,
            department_name d_name
        FROM
            departments
    ) LOOP
        dbms_output.put_line('=================================');
        dbms_output.put_line(i.d_name);
        dbms_output.put_line('---------------------------------');
        SELECT
            COUNT(*)
        INTO w
        FROM
            employees
        WHERE
            department_id = i.d_id;

        IF
            w = 0
        THEN
            dbms_output.put_line('Aici nu lucreaza nimeni.');
            dbms_output.new_line ();
        ELSE
            maxim := 0;
            pos := 0;
            FOR j IN sapt.first..sapt.last LOOP
                IF
                    sapt(j) = 1
                THEN
                    dbms_output.put('Luni      (1) -> ');
                ELSIF sapt(j) = 2 THEN
                    dbms_output.put('Marti     (2) -> ');
                ELSIF sapt(j) = 3 THEN
                    dbms_output.put('Miercuri  (3) -> ');
                ELSIF sapt(j) = 4 THEN
                    dbms_output.put('Joi       (4) -> ');
                ELSIF sapt(j) = 5 THEN
                    dbms_output.put('Vineri    (5) -> ');
                ELSIF sapt(j) = 6 THEN
                    dbms_output.put('Sambata   (6) -> ');
                ELSIF sapt(j) = 7 THEN
                    dbms_output.put('Duminica  (7) -> ');
                END IF;

                ang := 0;
                SELECT
                    COUNT(*)
                INTO ang
                FROM
                    employees
                WHERE
                    TO_CHAR(hire_date,'d') = TO_CHAR(sapt(j) )
                    AND department_id = i.d_id;

                IF
                    ang = 0
                THEN
                    dbms_output.put('nu s-au facut angajari');
                ELSE
                    dbms_output.put(ang);
                END IF;

                IF
                    maxim < ang
                THEN
                    maxim := ang;
                    pos := j;
                END IF;
                dbms_output.new_line ();
            END LOOP;

            dbms_output.put_line('^^^ Maxim: '
                                   || maxim
                                   || ' angajari in ziua '
                                   || pos);
            SELECT
                employee_id,
                last_name,
                round(SYSDATE - hire_date),
                department_id,
                salary
            BULK COLLECT
            INTO clasament
            FROM
                employees
            WHERE
                department_id = i.d_id
                AND TO_CHAR(hire_date,'d') = pos;

            FOR a IN clasament.first..clasament.last LOOP
                FOR b IN a + 1..clasament.last LOOP
                    IF
                        clasament(a).vechime < clasament(b).vechime
                    THEN
                        emp := clasament(a);
                        clasament(a) := clasament(b);
                        clasament(b) := emp;
                    END IF;
                END LOOP;
            END LOOP;

            pos_clasament := 1;
            FOR k IN clasament.first..clasament.last LOOP
                IF
                    k > 1
                THEN
                    IF
                        clasament(k).vechime <> clasament(k - 1).vechime
                    THEN
                        pos_clasament := pos_clasament + 1;
                    END IF;
                END IF;

                dbms_output.put_line(pos_clasament
                                       || ' -> '
                                       || clasament(k).nume
                                       || ' cu o vechime de '
                                       || clasament(k).vechime
                                       || ' zile si un venit lunar de '
                                       || clasament(k).salariu);

            END LOOP;

            dbms_output.new_line ();
        END IF;

    END LOOP;

END;
/

BEGIN
    p6_hd;
END;
/