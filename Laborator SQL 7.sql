-- Exercitii preluate din materialele scrie de Lect. Univ. Dr. Gabriela Mihai

-- 28. a. Creaţi copii pentru tabelele work şi projects, denumite work_*** şi projects_***.
-- b. Adăugaţi constrângerile de cheie externă pentru tabelul work_*** (projects_*** şi emp_***).
-- c. Considerând că un angajat poate să lucreze în cadrul unui proiect doar o singură perioadă de timp, adăugaţi constrângerea de cheie primară tabelului work_***.
-- d. Fără a specifica numele constrângerii, eliminaţi constrângerea de cheie primară adăugată tabelului work_***.
-- e. Considerând că un angajat poate să lucreze în cadrul unui proiect în mai multe perioade de timp, adăugaţi constrângerea de cheie primară tabelului work_***.
-- f. Inserați o nouă înregistrare în tabela projects_***, respectând constrângerile impuse.
-- g. Inserați o nouă înregistrare în tabela work_***, respectând constrângerile impuse.


--28
--a
create table work_hd as select * from work;
create table project_hd as select * from projects;
desc work_hd;
desc project_hd;

--b
select * from work_hd;

alter table project_hd
add constraint pk_hd primary key (project_id);

alter table work_hd
add constraint fk1_hd foreign key(project_id) references 
    project_hd(project_id) on delete set null;

create table emp_hd as select * from employees;

alter table emp_hd
add constraint pk2_hd primary key (employee_id); 

alter table work_hd
add constraint fk2_hd foreign key (employee_id) references
    emp_hd (employee_id) on delete set null;

--c
select * from work_hd;

alter table work_hd
add constraint pk3_hd primary key(employee_id, project_id);

--d
alter table work_hd
drop primary key;

--e
alter table work_hd
add constraint pk4_hd primary key(employee_id, start_work, end_work, project_id);
-- aici nu prea inteleg ce se vrea, adica practic tabelul nu ar suferi nicio modificare, nu doar in cazul de fata
-- daca ar fi fost ca un angajat sa lucreze la un singur proiect mai multe perioade, nici aici nu sunt sigura care ar fi fost cheia primara
-- pentru ca ar trebui ca un angajat sa apara cu un singur proiect, dar de mai multe ori; nu cred ca limitarea la un singur proiect ar fi posibila

--f
insert into project_hd
values (4, to_date(sysdate - 4, 'dd-mm-yyyy'), to_date(sysdate, 'dd-mm-yyyy'), 'P4');

select * from project_hd;

--g
insert into work_hd
values (152, to_date('01-03-2000', 'dd-mm-yyyy'), to_date('05-05-2000', 'dd-mm-yyyy'), 4); 

select * from work_hd;


drop table work_hd;
drop table project_hd; 
drop table emp_hd;
