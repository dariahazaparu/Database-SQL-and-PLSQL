-- Exercitii preluate din materialele scrie de Lect. Univ. Dr. Gabriela Mihai

-- 23. Afişaţi salariaţii care au acelaşi manager ca şi angajatul având codul 140.
-- 24. Afişaţi numele departamentelor care funcţionează în America.
-- 25. Afişaţi numele angajatului, numele şefului său direct, respectiv numele şefului căruia i se subordonează şeful său direct.
-- 26. Afişaţi pentru fiecare salariat angajat în luna martie numele său, data angajării şi numele jobului.
-- 27. Afişaţi pentru fiecare salariat al cărui câştig total lunar este mai mare decât 12000 numele său, câştigul total lunar şi numele departamentului în care lucrează.
-- 28. Afişaţi pentru fiecare angajat codul său şi numele joburilor sale anterioare, precum şi intervalul de timp în care a lucrat pe jobul respectiv.
-- 29. Modificaţi cererea de la punctul 28 astfel încât să se afişeze şi numele angajatului, respectiv codul jobului său curent.
-- 30. Modificaţi cererea de la punctul 29 astfel încât să se afişeze şi numele jobului său curent.
-- 31. Modificaţi cererea de la punctul 30 astfel încât să se afişeze informaţiile cerute doar pentru angajaţii care au lucrat în trecut pe acelaşi job pe care lucrează în prezent.
-- 32. Modificaţi cererea de la punctul 31 astfel încât să se afişeze în plus numele departamentului în care a lucrat angajatul în trecut, respectiv numele departamentului în care lucrează în prezent.
-- 33. Modificaţi cererea de la punctul 32 încât să se afişeze informaţiile cerute doar pentru angajaţii care au lucrat în trecut pe acelaşi job pe care lucrează în prezent, dar în departamente diferite.

--23
select a.last_name
from employees a, employees b
where b.employee_id = 140
and b.manager_id = a.manager_id;

--24
select department_name
from departments d, locations l
where d.location_id = l.location_id
and country_id = 'US';

--25
select ang.last_name "Angajat", sef.last_name "Sef direct", sef2.last_name "Sef mare"
from employees ang, employees sef, employees sef2
where ang.manager_id = sef.employee_id
and sef.manager_id = sef2.employee_id;

--26
select e.last_name, e.hire_date, j.job_title
from employees e, jobs j
where e.job_id = j.job_id
and to_char(hire_date, 'mm') = '03';

--27
select last_name, salary + salary*commission_pct as "castig total", d.department_name
from employees e, departments d
where e.department_id = d.department_id
and salary + salary*commission_pct >= 12000;

--28
select e.employee_id, j.job_title, jh.start_date, jh.end_date
from employees e, jobs j, job_history jh
where e.employee_id = jh.employee_id
and j.job_id = jh.job_id;

--29
select e.employee_id, e.last_name, e.job_id, j.job_title, jh.start_date, jh.end_date
from employees e, jobs j, jobs j2, job_history jh
where e.employee_id = jh.employee_id
and j.job_id = jh.job_id
and j.job_id = j2.job_id;

--30
select e.employee_id, e.last_name, e.job_id, j3.job_title, j.job_title, jh.start_date, jh.end_date
from employees e, jobs j, jobs j2, jobs j3, job_history jh
where e.employee_id = jh.employee_id
and j.job_id = jh.job_id
and j.job_id = j2.job_id
and e.job_id = j3.job_id;

--31
select e.employee_id, e.last_name, e.job_id, j3.job_title, j.job_title, jh.start_date, jh.end_date
from employees e, jobs j, jobs j2, jobs j3, job_history jh
where e.employee_id = jh.employee_id
and j.job_id = jh.job_id
and j.job_id = j2.job_id
and e.job_id = j3.job_id
and j2.job_id = j3.job_id;

--32
select e.employee_id, e.last_name, e.job_id, 
    j3.job_title, j.job_title, jh.start_date, jh.end_date,
    d.department_name, d2.department_name
from employees e, jobs j, jobs j2, jobs j3, job_history jh,
    departments d, departments d2
where e.employee_id = jh.employee_id
and j.job_id = jh.job_id
and j.job_id = j2.job_id
and e.job_id = j3.job_id
and j2.job_id = j3.job_id
and e.department_id = d.department_id
and jh.department_id = d2.department_id;

--33
select e.employee_id, e.last_name, e.job_id, 
    j3.job_title, j.job_title, jh.start_date, jh.end_date,
    d.department_name, d2.department_name
from employees e, jobs j, jobs j2, jobs j3, job_history jh,
    departments d, departments d2
where e.employee_id = jh.employee_id
and j.job_id = jh.job_id
and j.job_id = j2.job_id
and e.job_id = j3.job_id
and j2.job_id = j3.job_id
and e.department_id != jh.department_id
and e.department_id = d.department_id
and jh.department_id = d2.department_id;