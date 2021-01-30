-- Exercitii preluate din materialele scrise de Lect. Univ. Dr. Gabriela Mihai

-- 1. Să se creeze un bloc PL/SQL care afişează radicalul unei variabile introduse de la tastatură. Să se trateze cazul în care valoarea variabilei este negativă. Gestiunea erorii se va realiza prin definirea unei excepţii de către utilizator, respectiv prin captarea erorii interne a sistemului. Codul şi mesajul erorii vor fi introduse în tabelul error_***(cod, mesaj).
-- 2. Să se creeze un bloc PL/SQL prin care să se afişeze numele salariatului (din tabelul emp_***) care câştigă un anumit salariu. Valoarea salariului se introduce de la tastatură. Se va testa programul pentru următoarele valori: 500, 3000 şi 5000.
-- Dacă interogarea nu întoarce nicio linie, atunci să se trateze excepţia şi să se afişeze mesajul “nu exista salariati care sa castige acest salariu ”. Dacă interogarea întoarce o singură linie, atunci să se afişeze numele salariatului. Dacă interogarea întoarce mai multe linii, atunci să se afişeze mesajul “exista mai mulţi salariati care castiga acest salariu”.
-- . Să se creeze un bloc PL/SQL care tratează eroarea apărută în cazul în care se modifică codul unui departament în care lucrează angajaţi.
-- 4. Să se creeze un bloc PL/SQL prin care se afişează numele departamentului 10 dacă numărul său de angajaţi este într-un interval dat de la tastatură. Să se trateze cazul în care departamentul nu îndeplineşte această condiţie.
-- 5. Să se modifice numele unui departament al cărui cod este dat de la tastatură. Să se trateze cazul în care nu există acel departament. Tratarea excepţie se va face în secţiunea executabilă.
-- 6. Să se creeze un bloc PL/SQL care afişează numele departamentului ce se află într-o anumită locaţie şi numele departamentului ce are un anumit cod (se vor folosi două comenzi SELECT). Să se trateze excepţia NO_DATA_FOUND şi să se afişeze care dintre comenzi a determinat eroarea. Să se rezolve problema în două moduri.

CREATE TABLE error_hd (
    cod     NUMBER,
    mesaj   VARCHAR2(255)
);

CREATE SEQUENCE error_seq_hd MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER NOCYCLE;

DROP SEQUENCE error_hd;

DECLARE
    v_nr   NUMBER := &a;
BEGIN
    dbms_output.put_line(sqrt(v_nr) );
EXCEPTION
    WHEN value_error THEN
        INSERT INTO error_hd VALUES (
            error_seq_hd.NEXTVAL,
            'negativ'
        );

END;
/

SELECT
    *
FROM
    error_hd;

--2

SELECT
    *
FROM
    emp_hd;

DECLARE
    v_nr    NUMBER := &a;
    v_cox   emp_hd.last_name%TYPE;
BEGIN
    SELECT
        last_name
    INTO v_cox
    FROM
        emp_hd
    WHERE
        salary = v_nr;

    dbms_output.put_line(v_cox);
EXCEPTION
    WHEN no_data_found THEN
        dbms_output.put_line('Nu are nimeni acest salariu');
    WHEN too_many_rows THEN
        dbms_output.put_line('Mai multi angajati au acest salariu');
END;
/

--3

DECLARE
    nr     NUMBER;
    dept   NUMBER := 10;
    do_not_delete EXCEPTION;
BEGIN
    SELECT
        COUNT(*)
    INTO nr
    FROM
        employees
    WHERE
        department_id = dept;

    IF
        nr <> 0
    THEN
        RAISE do_not_delete;
    END IF;
    DELETE FROM dept_hd
    WHERE
        department_id = dept;

EXCEPTION
    WHEN do_not_delete THEN
        raise_application_error(-20355,'in this department work employees.');
END;
/

--4

DECLARE
    nr_begin   NUMBER := &nr1;
    nr_end     NUMBER := &nr2;
    nr         NUMBER;
    dept       departments.department_name%TYPE;
    not_condition EXCEPTION;
BEGIN
    SELECT
        COUNT(*)
    INTO nr
    FROM
        employees
    WHERE
        department_id = 10;

    IF
        nr > nr_begin AND nr < nr_end
    THEN
        SELECT
            department_name
        INTO dept
        FROM
            departments
        WHERE
            department_id = 10;

        dbms_output.put_line(dept);
    ELSE
        RAISE not_condition;
    END IF;

EXCEPTION
    WHEN not_condition THEN
        raise_application_error(-20356,'nr of employees not in the given interval.');
END;
/

--5

DECLARE
    cod   NUMBER := &nr;
    nr    NUMBER;
BEGIN
    SELECT
        COUNT(*)
    INTO nr
    FROM
        departments
    WHERE
        department_id = cod;

    IF
        nr = 0
    THEN
        raise_application_error(-20344,'No such department.');
    END IF;
    UPDATE dept_hd
    SET
        department_name = 'adm'
    WHERE
        department_id = cod;

END;
/

ROLLBACK;

--6

DECLARE
    dept_1   departments.department_name%TYPE;
    dept_2   departments.department_name%TYPE;
    nr       NUMBER;
BEGIN
    SELECT
        department_name
    INTO dept_1
    FROM
        departments
    --where location_id = 2600;
    WHERE
        location_id = 2500;

    dbms_output.put_line(dept_1);
    SELECT
        department_name
    INTO dept_2
    FROM
        departments
    WHERE
        department_id = 15;
    --where department_id = 10;

    dbms_output.put_line(dept_2);
EXCEPTION
    WHEN no_data_found THEN
        SELECT
            COUNT(*)
        INTO nr
        FROM
            departments
        WHERE
            location_id = 2500;

        IF
            nr = 0
        THEN
            raise_application_error(-20358,'No departments in this location.');
        END IF;
        SELECT
            COUNT(*)
        INTO nr
        FROM
            departments
        WHERE
            department_id = 15;

        IF
            nr = 0
        THEN
            raise_application_error(-20358,'No departments with this id.');
        END IF;
END;
/