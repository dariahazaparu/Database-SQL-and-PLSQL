-- Exercitii preluate din materialele scrie de Lect. Univ. Dr. Gabriela Mihai

-- 22. Determinați cele mai prost plătite 3 job-uri, din punct de vedere al mediei salariilor.
-- 23. Obţineți top 5 departamente din punct de vedere al numărului de angajaţi.
-- 24. Determinați salariaţii care nu au subordonaţi.
-- 25. Obţineți numele salariaților care cea mai mare vechime în fiecare departament.
-- 26. Rezolvați exercițiul anterior ținând cont de vechimea cumulată în timp (se ține cont și de istoric).
-- 27. Obţineți numele salariaţilor care lucrează într-un departament în care există cel puţin 2 angajaţi cu salariul în grila de salarizare 1.
-- 28. Obţineți codurile angajaţilor care nu au avut joburi anterioare:
-- a) utilizând operatorul MINUS;
-- b) utilizând operatorul NOT IN.
-- 29. Obţineți codul, job-ul şi departamentul angajaţilor care în trecut au lucrat pe alte joburi sau în alte departamente faţă de prezent. Utilizaţi operatorul MINUS.
-- 30. a) Determinați codurile locaţiilor în care nu există departamente. Utilizaţi operatorul MINUS.
-- b) Daţi o altă metodă de rezolvare.
-- c) Modificați cererile anterioare astfel încât să obțineți orașele în care nu funcționează departamente.
-- 31. Folosind operatorul EXISTS determinaţi codul şi numele departamentelor în care nu lucrează nimeni.
-- 32. Afişaţi codul locaţiei şi oraşul în care nu funcţionează departamente, utilizând:
--      1. NOT IN;
--      2. MINUS;
--      3. NOT EXISTS;
--      4. Outer Join.
-- 33. Determinaţi numele angajaţilor care au lucrat cel puţin la aceleaşi proiecte ca şi angajatul având codul 202 (au lucrat la toate proiectele la care a lucrat angajatul 202 şi eventual la alte proiecte).
-- Observaţie: A ⊆ B ⟺ A \ B = Ø
-- 34. Determinaţi numele angajaţilor care au lucrat cel mult la aceleaşi proiecte ca şi angajatul având codul 202.
-- 35. Determinaţi numele angajaţilor care au lucrat exact la aceleaşi proiecte ca şi angajatul având codul 202.
-- Observaţie: A = B ⟺ A \ B = Ø şi B \ A = Ø

--22
with mfncd as (select avg(salary) salariu
                from employees 
                group by job_id)
select job_id, avg(salary)
from employees e
where 3 > (    select count(*)
                from mfncd
                where salariu <= e.salary )
group by job_id
order by 2;

--23
with ang as (select department_id, count(employee_id) nr 
            from employees
            where department_id is not null
            group by department_id)
select department_id, nr
from ang e
where 5 > ( select count(nr)
            from ang
            where nr > e.nr)
order by nr desc;

--24
with man as (select manager_id, count(employee_id) nr
            from employees
            group by manager_id)
select employee_id
from employees
minus
select manager_id
from man
where manager_id is not null
order by 1;

--25
with dat as (select distinct department_id, max(round(to_number(sysdate-hire_date))) zile
            from employees
            where department_id is not null
            group by department_id
            order by 1)
select department_id, last_name, round(to_number(sysdate-hire_date))
from employees e
where round(to_number(sysdate-hire_date)) = (select zile
                                            from dat
                                            where department_id = e.department_id)
order by 1;

--26
select employee_id, to_number ( end_date - start_date)
from job_history;

select employee_id, sum(to_number(end_date - start_date)) zile_jh
from job_history
group by employee_id
union
select employee_id, round(to_number(sysdate - hire_date)) zile_jh
from employees;

with tabel as ( select employee_id, sum(to_number(end_date - start_date)) zile_jh
                from job_history
                group by employee_id
                union
                select employee_id, round(to_number(sysdate - hire_date)) zile_jh
                from employees)
select employee_id, sum(zile_jh)
from tabel
group by employee_id
order by 1;


with tabel as ( select employee_id, sum(to_number(end_date - start_date)) zile_jh
                from job_history
                group by employee_id
                union
                select employee_id, round(to_number(sysdate - hire_date)) zile_jh
                from employees),
tabel2 as ( select employee_id, sum(zile_jh) zile
            from tabel
            group by employee_id
            order by 1)
select department_id, max(zile)
from employees e, tabel2 t
where e.employee_id = t.employee_id
group by department_id
order by 1;

with tabel as ( select employee_id, sum(to_number(end_date - start_date)) zile_jh
                from job_history
                group by employee_id
                union
                select employee_id, round(to_number(sysdate - hire_date)) zile_jh
                from employees),
tabel2 as ( select employee_id, sum(zile_jh) zile
            from tabel
            group by employee_id
            order by 1), 
tabel3 as (
            select department_id, max(zile) zilee
            from employees e, tabel2 t
            where e.employee_id = t.employee_id
            group by department_id
            order by 1)
select department_id, last_name
from employees e, tabel2 t
where e.employee_id = t.employee_id 
and (department_id, t.zile) in (select * from tabel3)
order by 1;

--27
select lowest_sal, highest_sal
from job_grades
where grade_level = 1;

with grad as (
                select lowest_sal, highest_sal
                from job_grades
                where grade_level = 1)
select employee_id, salary
from employees e, grad g
where salary between lowest_sal and highest_sal
order by 1;

with grad as (
                select lowest_sal, highest_sal
                from job_grades
                where grade_level = 1),
ang as (
         select employee_id, salary
         from employees e, grad g
         where salary between lowest_sal and highest_sal
        order by 1)
select department_id, count(e.employee_id) nr
from employees e, ang a
where e.employee_id = a.employee_id
group by department_id;

with grad as (
                select lowest_sal, highest_sal
                from job_grades
                where grade_level = 1),
ang as (
         select employee_id, salary
         from employees e, grad g
         where salary between lowest_sal and highest_sal
         order by 1), 
dep as (
        select department_id, count(e.employee_id) nr
        from employees e, ang a
        where e.employee_id = a.employee_id
        group by department_id)
select last_name, e.department_id, d.nr
from employees e, dep d, grad gg
where e.department_id = d.department_id
and d.nr >= 2
and e.salary between gg.lowest_sal and gg.highest_sal;

--28
select employee_id
from employees
minus
select distinct employee_id
from job_history;

select employee_id
from employees
where employee_id not in (  select employee_id from job_history)
order by 1;

--29
select e.employee_id, e.job_id, e.department_id
from employees e, job_history jh
where e.employee_id = jh.employee_id
minus 
select jh.employee_id, jh.job_id, jh.department_id
from job_history jh, employees e
where jh.job_id <> e.job_id and jh.employee_id = e.employee_id and jh.department_id = e.department_id;

--30
select location_id
from locations
minus 
select distinct location_id
from departments;

select location_id
from locations
where location_id not in (
                            select location_id
                            from departments);
              
select city
from locations
minus 
select distinct l.city
from departments d, locations l
where d.location_id = l.location_id;              
                            
select city
from locations
where location_id not in (
                            select location_id
                            from departments);

--31
select d.department_id
from departments d
where not exists (
                    select *
                    from employees
                    where department_id = d.department_id);

--32
select d.department_id, count(e.employee_id) nr
from employees e, departments d
where e.department_id = d.department_id
group by d.department_id
order by 1;

with dep as (
                select d.department_id, count(e.employee_id) nr
                from employees e, departments d
                where e.department_id = d.department_id
                group by d.department_id)
select department_id
from departments d
where department_id not in (
                                select department_id
                                from dep)
order by 1;


with dep as (
                select d.department_id, count(e.employee_id) nr
                from employees e, departments d
                where e.department_id = d.department_id
                group by d.department_id
            )
select distinct l.location_id, l.city
from locations l, departments d
where l.location_id  = d.location_id 
and d.department_id not in (
                        select department_id
                        from dep)
order by 1;

--32 b

with dep as (
                select d.department_id, count(e.employee_id) nr
                from employees e, departments d
                where e.department_id = d.department_id
                group by d.department_id
            )
select department_id
from departments d
where department_id not in (
                                select department_id
                                from dep)
order by 1;

with dep as (
                select d.department_id, count(e.employee_id) nr
                from employees e, departments d
                where e.department_id = d.department_id
                group by d.department_id
            )
select location_id, department_id
from departments
minus
select location_id, department_id
from departments
where department_id in (
                            select department_id
                            from dep);


with dep as (
                select d.department_id, count(e.employee_id) nr
                from employees e, departments d
                where e.department_id = d.department_id
                group by d.department_id
            ),
non_loc as (
                select location_id, department_id
                from departments
                minus
                select location_id, department_id
                from departments
                where department_id in (
                                            select department_id
                                            from dep)
            )
select distinct nl.location_id, l.city
from non_loc nl, locations l
where nl.location_id = l.location_id;


--32 c
with dep as (
                select d.department_id, count(e.employee_id) nr
                from employees e, departments d
                where e.department_id = d.department_id
                group by d.department_id
            )
select department_id, location_id
from departments d
where not exists (
                    select nr
                    from dep
                    where department_id = d.department_id);
                    
                    
                    
with dep as (
                select d.department_id, count(e.employee_id) nr
                from employees e, departments d
                where e.department_id = d.department_id
                group by d.department_id
            ), 
non_dep as (
            select department_id, location_id
            from departments d
            where not exists (
                                select nr
                                from dep
                                where department_id = d.department_id)
            )
select distinct nl.location_id, l.city
from non_dep nl, locations l
where nl.location_id = l.location_id;
                    
--32 d
with dep as (
                select d.department_id, count(e.employee_id) nr
                from employees e, departments d
                where e.department_id = d.department_id
                group by d.department_id
            )
select d.department_id, p.nr
from departments d, dep p
where d.department_id = p.department_id(+)
order by 1;
          
        
with dep as (
                select d.department_id, count(e.employee_id) nr
                from employees e, departments d
                where e.department_id = d.department_id
                group by d.department_id
            ), 
dep_2 as (
            select d.department_id, p.nr
            from departments d, dep p
            where d.department_id = p.department_id(+)
        )
select distinct d.location_id, l.city
from departments d, dep_2 q, locations l
where d.department_id = q.department_id
and nr is null
and d.location_id  = l.location_id;

--33
select project_id
from work
where employee_id = 202;

with p202 as (
                select project_id
                from work
                where employee_id = 202
            )
select distinct e.last_name
from employees e, work w
where e.employee_id = w.employee_id and not exists(
                                            select project_id
                                            from p202
                                            minus
                                            select project_id
                                            from work w1
                                            where w1.employee_id = w.employee_id);


--34
with p202 as (
                select project_id
                from work
                where employee_id = 202
            )
select distinct e.last_name
from employees e, work w
where e.employee_id = w.employee_id and 3 not in (
                                            select project_id
                                            from work w1
                                            where w1.employee_id = w.employee_id);

--35
select employee_id, count(project_id)
from work
group by employee_id
order by 1;

with p202 as (
                select project_id
                from work
                where employee_id = 202
            ), 
nr_p as (
            select employee_id, count(project_id) nr
            from work
            group by employee_id)
select distinct e.last_name
from employees e, work w
where e.employee_id = w.employee_id and 3 not in (
                                            select project_id
                                            from work w1
                                            where w1.employee_id = w.employee_id)
                                    and 2 = (
                                                select nr
                                                from nr_p n
                                                where n.employee_id = w.employee_id);