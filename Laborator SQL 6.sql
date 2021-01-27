-- Exercitii preluate din materialele scrie de Lect. Univ. Dr. Gabriela Mihai

-- 18. Dați 5 exemple la alegere de utilizare ale comenzilor LCD (COMMIT, SAVEPOINT, ROLLBACK), folosind tabele copie pentru tabelele din diagrama HR. Adăugați comentarii sugestive pentru fiecare comandă dintr-o tranzacție.
-- 19. Ştergeţi angajaţii care nu conduc departamente sau alţi angajaţi şi care nu au avut alte joburi în trecut. Anulaţi efectele tranzacţiei.
-- 20. Ştergeţi un angajat al cărui cod este dat de la tastatură. Menţineţi numele acestuia într-o variabilă de legătură. Afişaţi valoarea acestei variabile. Anulaţi modificările.
-- 21. Pentru angajaţii departamentului 80 s-a luat decizia că nu vor mai avea comision, iar comisionul pe care l-au avut până în acest moment va fi integrat în salariu. Realizaţi aceste modificări. Verificaţi rezultatul obţinut. Anulaţi efectele tranzacţiei.
-- 22. Pentru fiecare departament să se mărească salariul celor care au fost angajaţi primii astfel încât să devină media salariilor din companie. Anulaţi efectele tranzacţiei.
-- 23. Modificaţi valoarea emailului pentru angajaţii care câştigă cel mai mult în departamentul în care lucrează astfel încât acesta să devină iniţiala numelui concatenată cu „_“ concatenat cu prenumele. Anulaţi efectele tranzacţiei.
-- 24. Modificaţi comanda de la exerciţiul anterior astfel încât actualizarea coloanei email să fie realizată doar pentru angajatul având codul 200. Menţineţi numele şi emailul acestuia în două variabile de legătură. Anulaţi efectele tranzacţiei.
-- 25. Măriţi cu 1000 salariul unui angajat al cărui cod este introdus de la tastatură.

create table empl as select * from employees;
--------------------------------------------------------------
--18 
create table dep as select * from departments;

select department_id
from dep
where department_id between 50 and 150;

savepoint s1;

delete from dep
where department_id between 10 and 60;

insert into dep values (300,'special',152,1200);

savepoint s2;

insert into dep values (310,'mai special', 154, 1300);

rollback to s2; -- s-a anulat ultima insertie

commit; -- toate schimbarile sunt permanente

rollback to s2; -- nu poate fi utilizata pentru ca schimbarile sunt definitive si savepoint urile nu mai exista

savepoint s3;

delete from dep;

rollback to s3; 

drop table dep;

commit;

--19
delete from empl
where employee_id not in (
                            select nvl(manager_id, 0)
                            from departments)
and employee_id not in (
                        select employee_id
                        from job_history);
select * from empl;

rollback;

--20
undefine e_id
variable nume varchar2(20)

accept e_id prompt 'introduceti id ul angajatului'

delete from empl
where employee_id = &e_id
returning last_name into: nume;

print nume;

rollback;

--21
update empl
set salary = salary + salary * nvl(commission_pct, 0),
    commission_pct = 0
where department_id = 80;

select *
from empl
where department_id = 80;

rollback;

--22
select department_id, max(to_number(sysdate - hire_date))
from empl
group by department_id
order by 1;

with data_ang as (
                    select department_id, max(to_number(sysdate - hire_date))
                    from empl
                    group by department_id)
select department_id, employee_id
from empl 
where (department_id, to_number(sysdate-hire_date)) in (
                                                        select *
                                                        from data_ang);

update empl
set salary = ( select avg(salary) from employees)
where employee_id in (
                        select employee_id
                        from employees
                        where (department_id, to_number(sysdate - hire_date)) in (
                                                                select department_id, max(to_number(sysdate - hire_date))
                                                                from empl
                                                                group by department_id));
select * from empl;

rollback;

--23
update empl
set email = substr(last_name, 1, 1) || '_' || upper(first_name)
where (department_id, salary) in (  select department_id, max(salary) 
                                    from employees
                                    group by department_id);
rollback;

--24
variable nume_200 varchar2(25)
variable email_200 varchar2(25)

update empl
set email = substr(last_name, 1, 1) || '_' || upper(first_name)
where employee_id = 200
returning last_name, email 
into :nume_200, :email_200;

print nume_200;
print email_200;

rollback;

--25
undefine empl_id

accept empl_id prompt 'introduceti codul angajatului'

update empl
set salary = salary + 1000
where employee_id = &empl_id;

rollback;

------------------------------------------------------------
drop table empl;