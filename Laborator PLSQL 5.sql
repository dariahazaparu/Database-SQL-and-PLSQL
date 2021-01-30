-- Exercitii preluate din materialele scrise de Lect. Univ. Dr. Gabriela Mihai

-- 1. Definiţi un pachet care să permită gestiunea angajaţilor companiei. Pachetul va conţine:
-- a. o procedură care determină adăugarea unui angajat, dându-se informaţii complete despre
-- acesta:
-- - codul angajatului va fi generat automat utilizându-se o secvenţă;
-- - informaţiile personale vor fi date ca parametrii (nume, prenume, telefon, email);
-- - data angajării va fi data curentă;
-- - salariul va fi cel mai mic salariu din departamentul respectiv, pentru jobul respectiv (se
-- vor obţine cu ajutorul unei funcţii stocate în pachet);
-- - nu va avea comision;
-- - codul managerului se va obţine cu ajutorul unei funcţii stocate în pachet care va avea ca
-- parametrii numele şi prenumele managerului);
-- - codul departamentului va fi obţinut cu ajutorul unei funcţii stocate în pachet, dându-se
-- ca parametru numele acestuia;
-- - codul jobului va fi obţinut cu ajutorul unei funcţii stocate în pachet, dându-se ca
-- parametru numele acesteia.
-- Observaţie: Trataţi toate excepţiile.
-- b. o procedură care determină mutarea în alt departament a unui angajat (se dau ca parametrii
-- numele şi prenumele angajatului, respectiv numele departamentului, numele jobului şi
-- numele şi prenumele managerului acestuia):
-- - se vor actualiza informaţiile angajatului:
-- - codul de departament (se va obţine cu ajutorul funcţiei corespunzătoare definită la
-- punctul a);
-- - codul jobului (se va obţine cu ajutorul funcţiei corespunzătoare definită la punctul
-- a);
-- - codul managerului (se va obţine cu ajutorul funcţiei corespunzătoare definită la
-- punctul a);
-- - salariul va fi cel mai mic salariu din noul departament, pentru noul job dacă acesta
-- este mai mare decât salariul curent; altfel se va păstra salariul curent;
-- - comisionul va fi cel mai mic comision din acel departament, pentru acel job;
-- - data angajării va fi data curentă;
-- - se vor înregistra informaţii corespunzătoare în istoricul joburilor.
-- Observaţie: Trataţi toate excepţiile.
-- c. o funcţie care întoarce numărul de subalterni direcţi sau indirecţi ai unui angajat al cărui
-- nume şi prenume sunt date ca parametrii;
-- Observaţie: Trataţi toate excepţiile.
-- d. o procedură care determină promovarea unui angajat pe o treaptă imediat superioară în
-- departamentul său; propuneţi o variantă de restructurare a arborelui care implementează
-- ierarhia subaltern – şef din companie;
-- Observaţie: Trataţi toate excepţiile.
-- e. o procedură prin care se actualizează cu o valoare dată ca parametru salariul unui angajat al
-- cărui nume este dat ca parametru:
-- - se va verifica dacă valoarea dată pentru salariu respectă limitele impuse pentru acel job;
-- - dacă sunt mai mulţi angajaţi care au acelaşi nume, atunci se va afişa un mesaj
-- corespunzător şi de asemenea se va afişa lista acestora;
-- - dacă nu există angajaţi cu numele dat, atunci se va afişa un mesaj corespunzător;
-- f. un cursor care obţine lista angajaţilor care lucrează pe un job al cărui cod este dat ca
-- parametru;
-- g. un cursor care obţine lista tuturor joburilor din companie;
-- h. o procedură care utilizează cele două cursoare definite anterior şi obţine pentru fiecare job
-- numele acestuia şi lista angajaţilor care lucrează în prezent pe acel job; în plus, pentru
-- fiecare angajat să se specifice dacă în trecut a mai avut sau nu jobul respectiv.

CREATE OR REPLACE PACKAGE pachet_hd AS 

    --a
    PROCEDURE add_emp (
        p_first_name           employees.first_name%TYPE,
        p_last_name            employees.last_name%TYPE,
        p_phone_number         employees.phone_number%TYPE,
        p_email                employees.email%TYPE,
        p_manager_first_name   employees.first_name%TYPE,
        p_manager_last_name    employees.last_name%TYPE,
        p_department           departments.department_name%TYPE,
        p_job                  jobs.job_title%TYPE
    );

    FUNCTION get_manager (
        p_first_name   employees.first_name%TYPE,
        p_last_name    employees.last_name%TYPE
    ) RETURN employees.manager_id%TYPE;

    FUNCTION get_department (
        p_name departments.department_name%TYPE
    ) RETURN departments.department_id%TYPE;

    FUNCTION get_job (
        p_name jobs.job_title%TYPE
    ) RETURN jobs.job_id%TYPE;

    FUNCTION get_salary (
        p_dept   departments.department_id%TYPE,
        p_job    jobs.job_id%TYPE
    ) RETURN employees.salary%TYPE;
        
    --b
    PROCEDURE move_emp (
        p_first_name           employees.first_name%TYPE,
        p_last_name            employees.last_name%TYPE,
        p_manager_first_name   employees.first_name%TYPE,
        p_manager_last_name    employees.last_name%TYPE,
        p_department           departments.department_name%TYPE,
        p_job                  jobs.job_title%TYPE
    );

    FUNCTION get_emp_id (
        p_first_name   employees.first_name%TYPE,
        p_last_name    employees.last_name%TYPE
    ) RETURN employees.employee_id%TYPE;

    FUNCTION get_commission (
        p_dept   departments.department_id%TYPE,
        p_job    jobs.job_id%TYPE
    ) RETURN employees.commission_pct%TYPE;
        
    --c
    FUNCTION get_sclavi (
        p_first_name   employees.first_name%TYPE,
        p_last_name    employees.last_name%TYPE
    ) RETURN NUMBER;
        
    --d
    PROCEDURE promote (
        p_first_name   employees.first_name%TYPE,
        p_last_name    employees.last_name%TYPE
    );
                        
    --e
    PROCEDURE modify_salary (
        p_first_name   employees.first_name%TYPE,
        p_last_name    employees.last_name%TYPE,
        new_salary     employees.salary%TYPE
    );
    
    --f
    CURSOR list_emp (
        id_job employees.job_id%TYPE
    ) RETURN employees%rowtype;
    
    --g
    CURSOR list_jobs RETURN jobs%rowtype;
    
    --h
    PROCEDURE list_employees;

END pachet_hd;
/

CREATE OR REPLACE PACKAGE BODY pachet_hd AS
    
    --f

    CURSOR list_emp (
        id_job employees.job_id%TYPE
    ) RETURN employees%rowtype IS SELECT
        *
                                  FROM
        employees
                                  WHERE
        job_id = id_job;

    --g

    CURSOR list_jobs RETURN jobs%rowtype IS SELECT
        *
                                            FROM
        jobs;
    
        --a

    FUNCTION get_manager (
        p_first_name   employees.first_name%TYPE,
        p_last_name    employees.last_name%TYPE
    ) RETURN employees.manager_id%TYPE IS
        id_manager   employees.manager_id%TYPE;
    BEGIN
        SELECT
            employee_id
        INTO id_manager
        FROM
            employees
        WHERE
            lower(p_first_name) = lower(first_name)
            AND lower(p_last_name) = lower(last_name);

        RETURN id_manager;
    EXCEPTION
        WHEN no_data_found THEN
            dbms_output.put_line('No manager found.');
            RAISE;
    END;

    FUNCTION get_department (
        p_name departments.department_name%TYPE
    ) RETURN departments.department_id%TYPE IS
        id_dept   departments.department_id%TYPE;
    BEGIN
        SELECT
            department_id
        INTO id_dept
        FROM
            departments
        WHERE
            lower(department_name) = lower(p_name);

        RETURN id_dept;
    EXCEPTION
        WHEN no_data_found THEN
            dbms_output.put_line('No department found.');
            RAISE;
    END;

    FUNCTION get_job (
        p_name jobs.job_title%TYPE
    ) RETURN jobs.job_id%TYPE IS
        id_job   jobs.job_id%TYPE;
    BEGIN
        SELECT
            job_id
        INTO id_job
        FROM
            jobs
        WHERE
            lower(p_name) = lower(job_title);

        RETURN id_job;
    EXCEPTION
        WHEN no_data_found THEN
            dbms_output.put_line('No job found.');
            RAISE;
    END;

    FUNCTION get_salary (
        p_dept   departments.department_id%TYPE,
        p_job    jobs.job_id%TYPE
    ) RETURN employees.salary%TYPE IS
        p_salary   employees.salary%TYPE;
    BEGIN
        SELECT
            MIN(salary)
        INTO p_salary
        FROM
            employees
        WHERE
            department_id = p_dept
            AND job_id = p_job;

        IF
            p_salary IS NULL
        THEN
            RAISE no_data_found;
        END IF;
        RETURN p_salary;
    EXCEPTION
        WHEN no_data_found THEN
            dbms_output.put_line('No (department, job) combination found.');
            RAISE;
    END;

    PROCEDURE add_emp (
        p_first_name           employees.first_name%TYPE,
        p_last_name            employees.last_name%TYPE,
        p_phone_number         employees.phone_number%TYPE,
        p_email                employees.email%TYPE,
        p_manager_first_name   employees.first_name%TYPE,
        p_manager_last_name    employees.last_name%TYPE,
        p_department           departments.department_name%TYPE,
        p_job                  jobs.job_title%TYPE
    ) IS

        id_manager   employees.manager_id%TYPE := get_manager(p_manager_first_name,p_manager_last_name);
        id_dept      employees.department_id%TYPE := get_department(p_department);
        id_job       employees.job_id%TYPE := get_job(p_job);
        p_salary     employees.salary%TYPE := get_salary(id_dept,id_job);
    BEGIN
        INSERT INTO emp_hd VALUES (
            sec_hd.NEXTVAL,
            p_first_name,
            p_last_name,
            p_email,
            p_phone_number,
            SYSDATE,
            id_job,
            p_salary,
            0,
            id_manager,
            id_dept
        );

    END add_emp;
        
        --b

    FUNCTION get_emp_id (
        p_first_name   employees.first_name%TYPE,
        p_last_name    employees.last_name%TYPE
    ) RETURN employees.employee_id%TYPE IS
        id_emp   employees.employee_id%TYPE;
    BEGIN
        SELECT
            employee_id
        INTO id_emp
        FROM
            employees
        WHERE
            lower(p_first_name) = lower(first_name)
            AND lower(p_last_name) = lower(last_name);

        RETURN id_emp;
    EXCEPTION
        WHEN no_data_found THEN
            dbms_output.put_line('No employee found.');
            RAISE;
        WHEN too_many_rows THEN
            dbms_output.put_line('Too many employees with the same name.');
            RAISE;
    END get_emp_id;

    FUNCTION get_commission (
        p_dept   departments.department_id%TYPE,
        p_job    jobs.job_id%TYPE
    ) RETURN employees.commission_pct%TYPE IS
        p_comm   employees.commission_pct%TYPE;
    BEGIN
        SELECT
            MIN(commission_pct)
        INTO p_comm
        FROM
            employees
        WHERE
            department_id = p_dept
            AND job_id = p_job;

        RETURN p_comm;
    EXCEPTION
        WHEN no_data_found THEN
            dbms_output.put_line('No (department, job) combination found.');
            RAISE;
    END;

    PROCEDURE move_emp (
        p_first_name           employees.first_name%TYPE,
        p_last_name            employees.last_name%TYPE,
        p_manager_first_name   employees.first_name%TYPE,
        p_manager_last_name    employees.last_name%TYPE,
        p_department           departments.department_name%TYPE,
        p_job                  jobs.job_title%TYPE
    ) IS

        id_manager     employees.manager_id%TYPE := get_manager(p_manager_first_name,p_manager_last_name);
        id_dept        employees.department_id%TYPE := get_department(p_department);
        id_job         employees.job_id%TYPE := get_job(p_job);
        p_salary       employees.salary%TYPE := get_salary(id_dept,id_job);
        id_emp         employees.employee_id%TYPE := get_emp_id(p_first_name,p_last_name);
        curr_salary    employees.salary%TYPE;
        p_commission   employees.commission_pct%TYPE := get_commission(id_dept,id_job);
        p_start_date   employees.hire_date%TYPE;
        p_end_date     employees.hire_date%TYPE := SYSDATE;
        old_job        employees.job_id%TYPE;
        old_dept       employees.department_id%TYPE;
    BEGIN
        SELECT
            salary,
            hire_date,
            job_id,
            department_id
        INTO
            curr_salary,
            p_start_date,
            old_job,
            old_dept
        FROM
            employees
        WHERE
            employee_id = id_emp;

        IF
            curr_salary > p_salary
        THEN
            p_salary := curr_salary;
        END IF;
        INSERT INTO job_history_hd VALUES (
            id_emp,
            p_start_date,
            p_end_date,
            old_job,
            old_dept
        );

        UPDATE emp_hd
        SET
            manager_id = id_manager,
            department_id = id_dept,
            job_id = id_job,
            salary = p_salary,
            commission_pct = p_commission,
            hire_date = SYSDATE
        WHERE
            employee_id = id_emp;

    END;
        
        --c

    FUNCTION get_sclavi (
        p_first_name   employees.first_name%TYPE,
        p_last_name    employees.last_name%TYPE
    ) RETURN NUMBER IS
        nr_emp   NUMBER;
        id_emp   employees.employee_id%TYPE := get_emp_id(p_first_name,p_last_name);
    BEGIN
        SELECT
            COUNT(*)
        INTO nr_emp
        FROM
            employees e
        WHERE
            id_emp IN (
                SELECT
                    manager_id
                FROM
                    employees
                START WITH
                    employee_id = e.employee_id
                CONNECT BY
                    PRIOR manager_id = employee_id
            );

        RETURN nr_emp;
    END;
    
    --d

    PROCEDURE promote (
        p_first_name   employees.first_name%TYPE,
        p_last_name    employees.last_name%TYPE
    ) IS

        id_emp              employees.employee_id%TYPE := get_emp_id(p_first_name,p_last_name);
        id_first_manager    employees.employee_id%TYPE;
        id_second_manager   employees.employee_id%TYPE;
    BEGIN
        SELECT
            manager_id
        INTO id_first_manager
        FROM
            employees
        WHERE
            employee_id = id_emp;

        IF
            id_first_manager IS NOT NULL
        THEN
            SELECT
                manager_id
            INTO id_second_manager
            FROM
                employees
            WHERE
                employee_id = id_first_manager;

            IF
                id_second_manager IS NOT NULL
            THEN
                UPDATE emp_hd
                SET
                    manager_id = id_second_manager
                WHERE
                    employee_id = id_emp;

            ELSE
                UPDATE emp_hd
                SET
                    manager_id = NULL
                WHERE
                    employee_id = id_emp;

            END IF;

        END IF;

    END;
    
    --e

    PROCEDURE modify_salary (
        p_first_name   employees.first_name%TYPE,
        p_last_name    employees.last_name%TYPE,
        new_salary     employees.salary%TYPE
    ) IS

        id_emp    employees.employee_id%TYPE := get_emp_id(p_first_name,p_last_name);
        min_sal   jobs.min_salary%TYPE;
        max_sal   jobs.max_salary%TYPE;
    BEGIN
        SELECT
            min_salary,
            max_salary
        INTO
            min_sal,
            max_sal
        FROM
            jobs
        WHERE
            job_id = (
                SELECT
                    job_id
                FROM
                    employees
                WHERE
                    employee_id = id_emp
            );

        IF
            new_salary BETWEEN min_sal AND max_sal
        THEN
            UPDATE emp_hd
            SET
                salary = new_salary
            WHERE
                employee_id = id_emp;

        ELSE
            dbms_output.put_line('Salary not in range.');
        END IF;

    EXCEPTION
        WHEN too_many_rows THEN
            FOR i IN (
                SELECT
                    employee_id,
                    first_name,
                    last_name
                FROM
                    employees
                WHERE
                    lower(p_first_name) = lower(first_name)
                    AND lower(p_last_name) = lower(last_name)
            ) LOOP
                dbms_output.put_line(i.employee_id
                                       || ' '
                                       || i.first_name
                                       || ' '
                                       || i.last_name);
            END LOOP;

            RAISE;
    END modify_salary;
    
    --h

    PROCEDURE list_employees IS
        past   NUMBER;
    BEGIN
        FOR job IN list_jobs LOOP
            dbms_output.put_line(job.job_title);
            FOR employee IN list_emp(job.job_id) LOOP
                dbms_output.put(employee.first_name
                                  || ' '
                                  || employee.last_name);
                SELECT
                    COUNT(*)
                INTO past
                FROM
                    job_history jh
                WHERE
                    jh.job_id = job.job_id
                    AND jh.employee_id = employee.employee_id;

                IF
                    past <> 0
                THEN
                    dbms_output.put(' *');
                END IF;
                dbms_output.new_line;
            END LOOP;

            dbms_output.new_line;
        END LOOP;

        dbms_output.put_line('* a mai lucrat si inainte la acelasi job');
    END;

END pachet_hd;
/