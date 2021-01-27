-- Exercitii preluate din materialele scrie de Lect. Univ. Dr. Gabriela Mihai

-- 28. Folosind data curentă afişaţi următoarele informaţii:
-- - numele zilei, numărul zilei din săptămână, numărul zilei din luna, respectiv numărul zilei din an;
-- - numărul lunii din an, numele lunii cu abreviere la 3 caractere, respectiv numele complet al lunii;
-- - ora curentă (ora, minute, secunde).
-- 29. Listaţi numele departamentelor care funcţionează în locaţia având codul 1700 şi al căror manager este cunoscut.
-- 30. Afişaţi codurile departamentelor în care lucrează salariaţi.
-- 31. Afişaţi numele şi prenumele salariaţilor angajaţi în luna iunie 1987.
-- 32. Listaţi codurile angajaţilor care au avut şi alte joburi faţă de cel prezent. Ordonaţi rezultatul descrescător după codul angajatului.
-- 33. Afişaţi numele şi data angajării pentru cei care lucrează în departamentul 80 şi au fost angajaţi în luna martie a anului 1997.
-- 34. Afişaţi numele joburilor care permit un salariu mai mare de 8000$.
-- 35. Afişaţi informaţii complete despre subordonaţii direcţi ai angajatului având codul 123.
-- 36. Afişaţi numele, salariul, comisionul şi venitul lunar total pentru toţi angajaţii care câştigă comision, dar un comision ce nu depăşeşte 25% din salariu.

--28
select 'azi este' || to_char(sysdate, ' "ziua" d "a sapt, ziua" fmdd "a lunii, ziua" fmddd "a anului"') data
from dual;
select 'este luna '|| to_char(sysdate, 'fmmm "/" mon "/" month') data
from dual;
select to_char(sysdate, 'hh12:mi:ss')
from dual;

--29
select department_name
from departments
where location_id = 1700 and manager_id is not null;

--30


--31
select first_name, last_name
from employees
where to_char(hire_date, 'mm-yyyy') = '06-1987';

--32
select employee_id
from job_history
order by employee_id;

--33
select last_name, hire_date
from employees
where department_id = 80 and to_char(hire_date, 'mm-yy') = '03-97';

--34
select job_title
from jobs
where max_salary >= 8000;

--35
select *
from employees
where manager_id = 123;

--36
select last_name, salary, commission_pct, (salary + salary*commission_pct) as "venit lunar"
from employees
where commission_pct <= 0.25;