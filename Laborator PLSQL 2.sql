-- Exercitii preluate din materialele scrise de Lect. Univ. Dr. Gabriela Mihai

-- 1. Mențineți într-o colecție codurile celor mai prost plătiți 5 angajați care nu câștigă comision. Folosind această colecție măriți cu 5% salariul acestor angajați. Afișați valoarea veche a salariului, respectiv valoarea nouă a salariului.
-- 2. Definiți un tip colecție denumit tip_orase_***. Creați tabelul excursie_*** cu următoarea structură: cod_excursie NUMBER(4), denumire VARCHAR2(20), orase tip_orase_*** (ce va conține lista orașelor care se vizitează într-o excursie, într-o ordine stabilită; de exemplu, primul oraș din listă va fi primul oraș vizitat), status (disponibilă sau anulată).
-- a. Inserați 5 înregistrări în tabel.
-- b. Actualizați coloana orase pentru o excursie specificată:
-- - adăugați un oraș nou în listă, ce va fi ultimul vizitat în excursia respectivă;
-- - adăugați un oraș nou în listă, ce va fi al doilea oraș vizitat în excursia respectivă;
-- - inversați ordinea de vizitare a două dintre orașe al căror nume este specificat;
-- - eliminați din listă un oraș al cărui nume este specificat.
-- c. Pentru o excursie al cărui cod este dat, afișați numărul de orașe vizitate, respectiv numele orașelor.
-- d. Pentru fiecare excursie afișați lista orașelor vizitate.
-- e. Anulați excursiile cu cele mai puține orașe vizitate.
-- 3. Rezolvați problema anterioară folosind un alt tip de colecție studiat.

--1
DECLARE
    TYPE colectie IS
        TABLE OF employees.employee_id%TYPE;
    salariati   colectie := colectie ();
    salariu     employees.salary%TYPE;
BEGIN
    SELECT
        employee_id
    BULK COLLECT
    INTO salariati
    FROM
        (
            SELECT
                employee_id
            FROM
                employees
            WHERE
                commission_pct IS NULL
            ORDER BY
                salary
        )
    WHERE
        ROWNUM <= 5;

    FOR i IN salariati.first..salariati.last LOOP
        dbms_output.put(salariati(i)
                          || ': ');
        SELECT
            salary
        INTO salariu
        FROM
            emp_hd
        WHERE
            employee_id = salariati(i);

        dbms_output.put(salariu || ' -> ');
        UPDATE emp_hd
        SET
            salary = 1.05 * salary
        WHERE
            employee_id = salariati(i);

        SELECT
            salary
        INTO salariu
        FROM
            emp_hd
        WHERE
            employee_id = salariati(i);

        dbms_output.put(salariu);
        dbms_output.new_line;
    END LOOP;

END;
/
--2
--a

CREATE OR REPLACE TYPE tip_orase_hd IS
    TABLE OF VARCHAR2(50);
--drop type tip_orase_hd;

CREATE TABLE excursie_hd (
    cod_excursie   NUMBER(4) PRIMARY KEY,
    denumire       VARCHAR2(20),
    status         VARCHAR2(20)
);
--drop table excursie_hd;

ALTER TABLE excursie_hd ADD (
    orase   tip_orase_hd
)
NESTED TABLE orase STORE AS tabel_orase_hd;

BEGIN
    INSERT INTO excursie_hd VALUES (
        1,
        'exc_1',
        'anulata',
        tip_orase_hd('Bucuresti','Constanta')
    );

    INSERT INTO excursie_hd VALUES (
        2,
        'exc_2',
        'disponibila',
        tip_orase_hd('Vaslui','Pitesti','Brasov')
    );

    INSERT INTO excursie_hd VALUES (
        3,
        'exc_3',
        'disponibila',
        tip_orase_hd('Arad','Botosani')
    );

    INSERT INTO excursie_hd VALUES (
        4,
        'exc_4',
        'anulata',
        tip_orase_hd('Iasi','Timisoara','MiercureaCiuc','Galati')
    );

    INSERT INTO excursie_hd VALUES (
        5,
        'exc_5',
        'disponibila',
        tip_orase_hd('Slobozia','Cluj')
    );

END;
/

SELECT
    *
FROM
    excursie_hd;
    
--b

DECLARE
    excursie             excursie_hd.denumire%TYPE := '&cerere';
    id_update_excursie   excursie_hd.denumire%TYPE;
    v_orase              tip_orase_hd := tip_orase_hd ();
    oras_aux             excursie_hd.denumire%TYPE;
    oras_inversat_1      excursie_hd.denumire%TYPE := '&oras_inversat_1';
    oras_inversat_2      excursie_hd.denumire%TYPE := '&oras_inversat_2';
    oras_sters           excursie_hd.denumire%TYPE := '&oras_sters';
    n                    NUMBER;
    position_1           NUMBER;
    position_2           NUMBER;
    position_3           NUMBER;
BEGIN
    SELECT
        cod_excursie
    INTO id_update_excursie
    FROM
        excursie_hd
    WHERE
        TO_CHAR(denumire) = TO_CHAR(excursie);

    SELECT
        orase
    INTO v_orase
    FROM
        excursie_hd
    WHERE
        cod_excursie = id_update_excursie;
------

    v_orase.extend;
    v_orase(v_orase.last) := 'Oradea';
------
    v_orase.extend;
    n := v_orase.count;
    WHILE n > 1 LOOP
        v_orase(n) := v_orase(n - 1);
        n := n - 1;
    END LOOP;

    v_orase(2) := 'Sighisoara';
-------
    FOR i IN v_orase.first..v_orase.last LOOP
        IF
            oras_inversat_1 = v_orase(i)
        THEN
            position_1 := i;
        END IF;
        IF
            oras_inversat_2 = v_orase(i)
        THEN
            position_2 := i;
        END IF;
    END LOOP;

    oras_aux := v_orase(position_1);
    v_orase(position_1) := v_orase(position_2);
    v_orase(position_2) := oras_aux;
-------
    FOR i IN v_orase.first..v_orase.last LOOP
        IF
            oras_sters = v_orase(i)
        THEN
            position_3 := i;
        END IF;
    END LOOP;

    v_orase.DELETE(position_3);
    UPDATE excursie_hd
    SET
        orase = v_orase
    WHERE
        cod_excursie = id_update_excursie;

END;
/

SELECT
    *
FROM
    excursie_hd;

--c

DECLARE
    excursie   excursie_hd.cod_excursie%TYPE := '&cerere';
    v_orase    tip_orase_hd := tip_orase_hd ();
    n          NUMBER;
BEGIN
    SELECT
        orase
    INTO v_orase
    FROM
        excursie_hd
    WHERE
        cod_excursie = excursie;

    n := v_orase.count;
    dbms_output.put('Excursia '
                      || excursie
                      || ' are '
                      || n
                      || ' orase: ');

    FOR i IN v_orase.first..v_orase.last LOOP
        IF
            i = v_orase.last
        THEN
            dbms_output.put(v_orase(i)
                              || '.');
        ELSE
            dbms_output.put(v_orase(i)
                              || ', ');
        END IF;
    END LOOP;

    dbms_output.new_line;
END;
/

--d

DECLARE
    TYPE vector_ex IS
        TABLE OF excursie_hd.cod_excursie%TYPE;
    excursii   vector_ex := vector_ex ();
    v_orase    tip_orase_hd := tip_orase_hd ();
BEGIN
    SELECT
        cod_excursie
    BULK COLLECT
    INTO excursii
    FROM
        excursie_hd;

    FOR i IN excursii.first..excursii.last LOOP
        dbms_output.put(excursii(i)
                          || ': ');
        SELECT
            orase
        INTO v_orase
        FROM
            excursie_hd
        WHERE
            cod_excursie = excursii(i);

        FOR j IN v_orase.first..v_orase.last LOOP
            IF
                j = v_orase.last
            THEN
                dbms_output.put(v_orase(j)
                                  || '. ');
            ELSE
                dbms_output.put(v_orase(j)
                                  || ', ');
            END IF;
        END LOOP;

        dbms_output.new_line;
    END LOOP;

END;
/

--e

DECLARE
    n          NUMBER;
    minim      NUMBER;
    v_orase    tip_orase_hd := tip_orase_hd ();
    TYPE vector_ex IS
        TABLE OF excursie_hd.cod_excursie%TYPE;
    excursii   vector_ex := vector_ex ();
BEGIN
    SELECT
        cod_excursie
    BULK COLLECT
    INTO excursii
    FROM
        excursie_hd;

    minim := 999999999;
    FOR i IN excursii.first..excursii.last LOOP
        SELECT
            orase
        INTO v_orase
        FROM
            excursie_hd
        WHERE
            cod_excursie = excursii(i);

        IF
            v_orase.count < minim
        THEN
            minim := v_orase.count;
        END IF;
    END LOOP;

    FOR i IN excursii.first..excursii.last LOOP
        SELECT
            orase
        INTO v_orase
        FROM
            excursie_hd
        WHERE
            cod_excursie = excursii(i);

        IF
            v_orase.count = minim
        THEN
            UPDATE excursie_hd
            SET
                status = 'anulata'
            WHERE
                cod_excursie = excursii(i);

        END IF;

    END LOOP;

END;
/

SELECT
    *
FROM
    excursie_hd;
    
ROLLBACK;