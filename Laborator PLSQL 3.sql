-- Exercitii preluate din materialele scrise de Lect. Univ. Dr. Gabriela Mihai

-- 1. Pentru fiecare job (titlu – care va fi afișat o singură dată) obțineți lista angajaților (nume și salariu) care lucrează în prezent pe jobul respectiv. Tratați cazul în care nu există angajați care să lucreze în prezent pe un anumit job. Rezolvați problema folosind:
-- a. cursoare clasice
-- b. ciclu cursoare
-- c. ciclu cursoare cu subcereri
-- d. expresii cursor
-- 2. Modificați exercițiul anterior astfel încât să obțineți și următoarele informații:
-- - un număr de ordine pentru fiecare angajat care va fi resetat pentru fiecare job
-- - pentru fiecare job
-- o numărul de angajați
-- o valoarea lunară a veniturilor angajaților
-- o valoarea medie a veniturilor angajaților
-- - indiferent job
-- o numărul total de angajați
-- o valoarea totală lunară a veniturilor angajaților
-- o valoarea medie a veniturilor angajaților
-- 3. Modificați exercițiul anterior astfel încât să obțineți suma totală alocată lunar pentru plata salariilor și a comisioanelor tuturor angajaților, iar pentru fiecare angajat cât la sută din această sumă câștigă lunar.
-- 4. Modificați exercițiul anterior astfel încât să obțineți pentru fiecare job primii 5 angajați care câștigă cel mai mare salariu lunar. Specificați dacă pentru un job sunt mai puțin de 5 angajați.
-- 5. Modificați exercițiul anterior astfel încât să obțineți pentru fiecare job top 5 angajați. Dacă există mai mulți angajați care respectă criteriul de selecție care au același salariu, atunci aceștia vor ocupa aceeași poziție în top 5.

--1
--c
DECLARE
    v_job       employees.job_id%TYPE;
    v_nume      employees.last_name%TYPE;
    v_salariu   employees.salary%TYPE;
BEGIN
    FOR c IN (
        SELECT
            job_id,
            job_title
        FROM
            jobs
    ) LOOP
        dbms_output.put_line('-------------------------------------');
        dbms_output.put_line('Jobul ' || c.job_title);
        dbms_output.put_line('-------------------------------------');
        FOR v IN (
            SELECT
                last_name,
                salary
            FROM
                employees
            WHERE
                job_id = c.job_id
        ) LOOP
            dbms_output.put_line(v.last_name
                                   || ' '
                                   || v.salary);
        END LOOP;

    END LOOP;
END;
/

-- b

DECLARE
--    v_job EMPLOYEES.JOB_ID%type;
--    v_nume employees.last_name%type;
--    v_salariu EMPLOYEES.SALARY%type;
    CURSOR c IS SELECT
        job_id,
        job_title
                FROM
        jobs;

BEGIN
    FOR i IN c LOOP
        dbms_output.put_line('-------------------------------------');
        dbms_output.put_line('Jobul ' || i.job_title);
        dbms_output.put_line('-------------------------------------');
        FOR v IN (
            SELECT
                last_name,
                salary
            FROM
                employees
            WHERE
                job_id = i.job_id
        ) LOOP
            dbms_output.put_line(v.last_name
                                   || ' '
                                   || v.salary);
        END LOOP;

    END LOOP;
END;
/

-- a

DECLARE
    v_job      jobs.job_title%TYPE;
    v_job_id   jobs.job_id%TYPE;
--    v_nume employees.last_name%type;
--    v_salariu EMPLOYEES.SALARY%type;
    CURSOR c IS SELECT
        job_id,
        job_title
                FROM
        jobs;

BEGIN
    OPEN c;
    LOOP
        FETCH c INTO
            v_job_id,
            v_job;
        EXIT WHEN c%notfound;
        dbms_output.put_line('-------------------------------------');
        dbms_output.put_line('Jobul ' || v_job);
        dbms_output.put_line('-------------------------------------');
        FOR v IN (
            SELECT
                last_name,
                salary
            FROM
                employees
            WHERE
                job_id = v_job_id
        ) LOOP
            dbms_output.put_line(v.last_name
                                   || ' '
                                   || v.salary);
        END LOOP;

    END LOOP;

    CLOSE c;
END;
/

-- d

DECLARE
    TYPE refc IS REF CURSOR;
    CURSOR c IS SELECT
        job_title,
        CURSOR (
            SELECT
                last_name,
                salary
            FROM
                employees e
            WHERE
                e.job_id = j.job_id
        )
                FROM
        jobs j;

    v_job       jobs.job_title%TYPE;
    v           refc;
    v_nume      employees.last_name%TYPE;
    v_salariu   employees.salary%TYPE;
BEGIN
    OPEN c;
    LOOP
        FETCH c INTO
            v_job,
            v;
        EXIT WHEN c%notfound;
        dbms_output.put_line('-------------------------------------');
        dbms_output.put_line('Jobul ' || v_job);
        dbms_output.put_line('-------------------------------------');
        LOOP
            FETCH v INTO
                v_nume,
                v_salariu;
            EXIT WHEN v%notfound;
            dbms_output.put_line(v_nume
                                   || ' '
                                   || v_salariu);
        END LOOP;

    END LOOP;

    CLOSE c;
END;
/

-- 2

DECLARE
    v_job       employees.job_id%TYPE;
    v_nume      employees.last_name%TYPE;
    v_salariu   employees.salary%TYPE;
    nr number;
    val_lunara number;
    val_medie number;
    nr_total number := 0;
    val_total number := 0;
    val_medie_total number :=0;
BEGIN
    FOR c IN (
        SELECT
            job_id,
            job_title
        FROM
            jobs
    ) LOOP
        nr := 0;
        val_lunara := 0;
        val_medie :=0;
        dbms_output.put_line('-------------------------------------');
        dbms_output.put_line('Jobul ' || c.job_title);
        dbms_output.put_line('------------');
        FOR v IN (
            SELECT
                last_name,
                salary
            FROM
                employees
            WHERE
                job_id = c.job_id
        ) LOOP
            nr := nr +1;
            nr_total := nr_total + 1;
            val_lunara := val_lunara + v.salary;
            val_total := val_total + v.salary;
            dbms_output.put_line(nr || ': ' || v.last_name
                                   || ' '
                                   || v.salary);
        END LOOP;
        if nr <> 0 then
            val_medie := val_lunara / nr;
        end if;
        dbms_output.put_line ('-> val lunara: ' || val_lunara);
        dbms_output.put_line ('-> val medie: ' || val_medie);

    END LOOP;
    
    if nr_total <> 0 then
        val_medie_total := val_total / nr_total;
    end if;
    dbms_output.put_line('-------------------------------------');
    dbms_output.put_line('-------------------------------------');
    dbms_output.put_line('Nr total ang: ' || nr_total);
    dbms_output.put_line('Val totala ' || val_total);
    dbms_output.put_line('Val medie totala ' || val_medie_total);

END;
/











