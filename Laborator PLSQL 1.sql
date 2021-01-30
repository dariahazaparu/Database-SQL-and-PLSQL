-- Exercitii preluate din materialele scrise de Lect. Univ. Dr. Gabriela Mihai

-- 1. Se dă următorul bloc:
-- DECLARE 
--     numar number(3):=100; 
--     mesaj1 varchar2(255):='text 1'; 
--     mesaj2 varchar2(255):='text 2'; 
-- BEGIN 
--     DECLARE numar number(3):=1; 
--     mesaj1 varchar2(255):='text 2'; 
--     mesaj2 varchar2(255):='text 3';
--     BEGIN 
--         numar:=numar+1; 
--         mesaj2:=mesaj2||' adaugat in sub-bloc'; 
--     END; 
--     numar:=numar+1; 
--     mesaj1:=mesaj1||' adaugat un blocul principal'; 
--     mesaj2:=mesaj2||' adaugat in blocul principal'; 
-- END;
-- a) Valoarea variabilei numar în subbloc este:
-- b) Valoarea variabilei mesaj1 în subbloc este:
-- c) Valoarea variabilei mesaj2 în subbloc este:
-- d) Valoarea variabilei numar în bloc este:
-- e) Valoarea variabilei mesaj1 în bloc este:
-- f) Valoarea variabilei mesaj2 în bloc este:
-- Verificați răspunsul.
-- 2. Se dă următorul enunț: Pentru fiecare zi a lunii octombrie (se vor lua în considerare și zilele din lună în care nu au fost realizate împrumuturi) obțineți numărul de împrumuturi efectuate.
-- a. Încercați să rezolvați problema în SQL fără a folosi structuri ajutătoare.
-- b. Definiți tabelul octombrie_*** (id, data). Folosind PL/SQL populați cu date acest tabel. Rezolvați în SQL problema dată.
-- 3. Definiți un bloc anonim în care să se determine numărul de filme (titluri) împrumutate de un membru al cărui nume este introdus de la tastatură. Tratați următoarele două situații: nu există nici un membru cu nume dat; există mai mulți membrii cu același nume.
-- 4. Modificați problema anterioară astfel încât să afișați și următorul text:
-- - Categoria 1 (a împrumutat mai mult de 75% din titlurile existente)
-- - Categoria 2 (a împrumutat mai mult de 50% din titlurile existente)
-- - Categoria 3 (a împrumutat mai mult de 25% din titlurile existente)
-- - Categoria 4 (altfel)
-- 5. Creați tabelul member_*** (o copie a tabelului member). Adăugați în acest tabel coloana discount, care va reprezenta procentul de reducere aplicat pentru membrii, în funcție de categoria din care fac parte aceștia:
-- - 10% pentru membrii din Categoria 1
-- - 5% pentru membrii din Categoria 2
-- - 3% pentru membrii din Categoria 3
-- - nimic
-- Actualizați coloana discount pentru un membru al cărui cod este dat de la tastatură. Afișați un mesaj din care să reiasă dacă actualizarea s-a produs sau nu.

--1
DECLARE
numar number(3):=100;
mesaj1 varchar2(255):='text 1';
mesaj2 varchar2(255):='text 2';
BEGIN
    DECLARE
        numar number(3):=1;
        mesaj1 varchar2(255):='text 2';
        mesaj2 varchar2(255):='text 3';
    BEGIN
        numar:=numar+1;
        mesaj2:=mesaj2||' adaugat in sub-bloc';
        dbms_output.put_line(numar);
        dbms_output.put_line(mesaj1);
        dbms_output.put_line(mesaj2);
    END;
    numar:=numar+1;
    mesaj1:=mesaj1||' adaugat un blocul principal';
    mesaj2:=mesaj2||' adaugat in blocul principal';
    dbms_output.put_line(numar);
    dbms_output.put_line(mesaj1);
    dbms_output.put_line(mesaj2);
END;

--2
--a nu stiu
--b
create table octombrie_hd (
id number not null,
data date not null,
primary key (id)
);

declare 
    v_id    NUMBER(2);
    v_data  date;
    prima_zi date := Last_Day(ADD_MONTHS('20-oct-2020',-1))+1;
    maxim number(4) := last_day('20-oct-2020') - to_date('01-oct-2020', 'dd-mm-yyyy');
begin
    FOR contor IN 0..maxim LOOP
        v_data := prima_zi + contor;
        v_id := contor + 1;
        dbms_output.put_line(v_id);
        dbms_output.put_line(v_data);
        INSERT INTO octombrie_hd
        VALUES (v_id ,v_data);
    END LOOP;
end;
/
select * from octombrie_hd;

select oct.data, count(book_date) nr
from octombrie_hd oct left outer join rental r on to_date(oct.data, 'dd-mm-yyyy') = to_date(r.book_date, 'dd-mm-yyyy')
group by oct.data
order by 1;


--3
declare 
v_nume member.last_name%type := &p_nume;
v_rezultat number;
begin
    select count(title_id) into v_rezultat
    from member m join rental r on m.member_id = r.member_id
    where m.last_name = to_char(v_nume)
    group by last_name;
    dbms_output.put_line(v_nume || ' a imprumutat ' || v_rezultat || ' filme');
EXCEPTION 
   WHEN no_data_found THEN 
      dbms_output.put_line('Nu exista un client cu acest nume.'); 
    when TOO_MANY_ROWS then
        dbms_output.put_line('Prea multi clienti cu acest nume.');
end;
/
--nu mai stiu cum sa fac fara apostrof la nume :'(

--4
declare 
v_nume member.last_name%type := &p_nume;
v_rezultat number;
v_cat varchar2(35);
maxim number;
nume varchar2(35);
begin
    select count(*) into maxim from title;
    select last_name, count(distinct title_id)
    into nume, v_rezultat
    from member m join rental r on m.member_id = r.member_id
    where m.last_name = v_nume
    group by last_name;
    case
        when v_rezultat > 0.75 * maxim
            then v_cat := 'Categoria 1';
        when v_rezultat > 0.5 * maxim
            then v_cat := 'Categoria 2';
        when v_rezultat > 0.25 * maxim
            then v_cat := 'Categoria 3';
        else v_cat := 'Categoria 4';
    end case;
    dbms_output.put_line(nume || ' a imprumutat ' || v_rezultat || ' filme si este in ' || v_cat);
EXCEPTION 
   WHEN no_data_found THEN 
      dbms_output.put_line('Nu exista un client cu acest nume.'); 
    when TOO_MANY_ROWS then
        dbms_output.put_line('Prea multi clienti cu acest nume.');
end;
/

--5
-- ce inteleg eu din enunt este ca creez tabelul nou si las coloana noua null
-- si le actualizez doar pe cele pe care le scriu de la tastatura.

create table member_hd as select * from member;
alter table member_hd
add discount number(2);
select * from member_hd;

declare 
v_nume member.last_name%type := &p_nume;
v_rezultat number;
v_cat varchar2(35);
maxim number;
nume varchar2(35);
disc number;
begin
    select count(*) into maxim from title;
    select last_name, count(distinct title_id)
    into nume, v_rezultat
    from member m join rental r on m.member_id = r.member_id
    where m.last_name = v_nume
    group by last_name;
    case
        when v_rezultat > 0.75 * maxim
            then v_cat := 'Categoria 1';
        when v_rezultat > 0.5 * maxim
            then v_cat := 'Categoria 2';
        when v_rezultat > 0.25 * maxim
            then v_cat := 'Categoria 3';
        else v_cat := 'Categoria 4';
    end case;
    if v_cat = 'Categoria 1' then disc := 10;
    elsif v_cat = 'Categoria 2' then disc := 5;
    elsif v_cat = 'Categoria 3' then disc:= 3;
    else disc := 0;
    end if;
    update member_hd
    set discount = disc
    where last_name = nume;
EXCEPTION 
   WHEN no_data_found THEN 
      dbms_output.put_line('Nu exista un client cu acest nume.'); 
    when TOO_MANY_ROWS then
        dbms_output.put_line('Prea multi clienti cu acest nume.');
end;
/
