-- Exercitii preluate din materialele scrie de Lect. Univ. Dr. Gabriela Mihai

-- 14. Definiţi vizualizarea v_dept_*** care va conţine codul şi numele departamentului, numărul de angajaţi din departament şi suma alocată pentru plata salariilor. Această vizualizare permite actualizări?
-- 15. Definiți o vizualizare care să conțină informații despre angajați și proiectele la care aceștia au lucrat (codul și numele angajatului, codul și numele proiectului, data de la care a început să lucreze pe acel proiect, respectiv data până la care a lucrat pe acel proiect). Folosiți tabelele de bază (emp_***, work_***, projects_***).
-- a. Inserați noi linii în tabelele work_*** și projects_***. Permanentizați modificările realizate. Afișați noile informații folosind vizualizarea.
-- b. Verificați ce coloane din tabelele de bază sunt actualizabile prin intermediul vizualizării.
-- c. Inserați o nouă linie în vizualizare. Permanentizați modificările realizate. Verificați propagarea informației în tabelele de bază.
-- d. Actualizați o linie din vizualizare. Permanentizați modificările realizate. Verificați propagarea informației în tabelele de bază.
-- e. Ștergeți o linie din vizualizare. Permanentizați modificările realizate. Verificați propagarea informației în tabelele de bază.
-- 16. Definiți o secvență pentru generarea codurilor de departamente, denumită seq_dept_***. Secvenţa va începe de la 200, va creşte cu 10 la fiecare pas şi va avea valoarea maximă 20000, nu va cicla.
-- a. Afișați informații despre secvența nou creată (nume, valoare minimă, maximă, de incrementare, ultimul număr generat). Se va utiliza vizualizarea user_sequences.
-- b. Inserați o înregistrare nouă în dept_*** utilizând secvenţa creată. Anulaţi modificările efectuate.
-- c. Afișați valoarea curentă a secvenţei.
-- d. Generați o nouă valoare a secvenței
-- e. Ștergeți secvența creată.

create table emp_hd as select * from employees;
create table proj_hd as select * from projects;
create table work_hd as select * from work;
create table dept_hd as select * from departments;
---------------------------------------//-------------------------------------------------

--14
create view v_dept_hd 
as 
select d.department_id, department_name, count(employee_id) "nr. angajati", sum(salary) "plata salarii"
from departments d, employees e
where d.department_id = e.department_id
group by d.department_id, department_name;

select * from v_dept_hd;

select * 
from user_updatable_columns
where  table_name = upper('v_dept_hd');
-- nu permite actualizari

--15

create or replace view viz_hd as
select e.employee_id, last_name, w.project_id, project_name, start_work, end_work
from emp_hd e, proj_hd p, work_hd w
where e.employee_id = w.employee_id and p.project_id = w.project_id;

select * from viz_hd;

--a
insert into work_hd
values (152, to_date(sysdate-10, 'dd-mm-yyyy'), to_date(sysdate, 'dd-mm-yyyy'), 3);

insert into proj_hd
values (4, to_date('22-03-2020', 'dd-mm-yyyy'), to_date('22-04-2020', 'dd-mm-yyyy'), 'P4');

select * from viz_hd;

--b
select *
from user_updatable_columns
where table_name = upper('viz_hd');
-- project_id, start_work, end_work

--c
insert into viz_hd
values (150, 'Tucker', 4, 'P4', to_date('24-03-2020', 'dd-mm-yyyy'), to_date('10-04-2020', 'dd-mm-yyyy'));
--error: "cannot modify a column which maps to a non key-preserved table"

--d
select * from viz_hd;

update viz_hd
set start_work = to_date('16-06-1998', 'dd-mm-yyyy')
where employee_id = 114;

commit;

select * from work_hd;

--e
delete from viz_hd
where employee_id = 152;

select * from viz_hd;
select * from work_hd;

commit;

--16
create sequence sec_dept_hd
increment by 10
start with 200
maxvalue 20000
nocycle;

--a
select *
from USER_SEQUENCES
where sequence_name = upper ('sec_dept_hd');

--b
desc dept_hd;

insert into dept_hd
values (sec_dept_hd.nextval, 'new_dept', 152, 10);

select * from dept_hd;
rollback;

--c
select sec_dept_hd.currval
from dual;

--d
select sec_dept_hd.nextval
from dual;

--e
drop sequence sec_dept_hd;

---------------------------------------//-------------------------------------------------
drop table emp_hd;
drop table projects_hd;
drop table work_hd;
drop table dept_hd;
drop view v_dept_hd;
drop view viz_hd;
