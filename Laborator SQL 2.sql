-- Exercitii preluate din materialele scrie de Lect. Univ. Dr. Gabriela Mihai

-- 18. Să se afișeze prima zi, respectiv ultima zi a lunii curente.
-- 19. Să se afişeze numele angajatului, data angajării şi data negocierii salariului, care a avut loc în prima zi de Luni, după 6 luni de serviciu. Etichetaţi această coloană “Negociere”.
-- Indicaţie: Se utilizează funcțiile NEXT_DAY și ADD_MONTHS
-- 20. Afişaţi numele salariatului şi codul departamentului în care acesta lucrează. Dacă există salariaţi care nu au un cod de departament asociat, atunci pe coloana id_department afişaţi valoarea 0.
-- 21. Afişaţi numele angajaţilor care nu au manager.
-- 22. Afişaţi numele angajaţilor şi codul managerilor lor. Pentru angajaţii care nu au manager să apară textul “nu are sef”.
-- 23. Afişaţi numele salariatului, salariul şi salariul revizuit astfel:
-- - dacă lucrează de mai mult de 200 de luni atunci salariul va fi mărit cu 20%;
-- - dacă lucrează de mai mult de 150 de luni, dar mai puţin de 200 de luni, atunci salariul va fi mărit cu 15%;
-- - dacă lucrează de mai mult de 100 de luni, dar mai puţin de 150 de luni, atunci salariul va fi mărit cu 10%;
-- - altfel, salariul va fi mărit cu 5%.

-- Lab 2 -- ce e galben ne trebuie

-- 2

select 'Func?ia salariatului ' || initcap(first_name) || ' ' || upper(last_name) || ' este ' || lower(job_id) as info
from employees
where department_id = 20;

--3

select employee_id, last_name, first_name, department_id
from employees
-- where upper(trim(last_name)) = 'HIGGINS';
-- where last_name = upper(trim('HIGGiNS')); -- asa nu o sa mearga evident
where last_name = initcap(trim('  Higgins')); -- asa e destul de bine ca mathuim formatul din bd

-- 5

-- daca vrem nr de luni lucrate, avem functia months_between, de exemplu

select last_name, first_name, round(sysdate-hire_date) as nr_zile_lucrate
from employees;

-- 6

-- 7

select to_char(sysdate + 10, 'mm-dd-yyyy hh12:mi:ss AM PM a.m. p.m.')
from dual; -- o chestie smechera pt scos o singura informatie
-- from employees; -- asa afisaza de tzaspe mii de ori

-- 8

select floor(to_date('31-12-2020', 'dd-mm-YYYY') - sysdate) nr_zile_ramase
from dual;

-- 9.1

select to_char(sysdate + 12/24, 'dd-mm-yyyy hh12:mi:ss am')
from dual;

-- 9.2

select to_char(sysdate + 5/1440, 'dd-mm-yyyy hh12:mi:ss am')
from dual;

-- 10

-- 11

select employee_id, round(months_between(sysdate, hire_date)) "luni lucrate"
from employees
order by round(months_between(sysdate, hire_date));

-- 12

SELECT last_name
FROM employees
WHERE TO_CHAR(hire_date,'yyyy')=1994;

SELECT last_name
FROM employees
-- WHERE hire_date='07-JUN-1994'; -- ruleaza daca respect formatul
WHERE hire_date=to_date('07-06-1994', 'dd-mm-yyyy');

--SELECT employee_id||' '||last_name||' '||hire_date
SELECT to_char(employee_id)||' '||last_name||' '||to_char(hire_date)
FROM employees
WHERE department_id=10;

-- 13

select last_name || ' ' || first_name
from employees
-- where to_char(hire_date, 'mm') = '05';
-- where to_char(hire_date, 'mm') = '5'; -- asa sigur nu merge
-- where to_char(hire_date, 'mm') = 5;
-- where to_char(hire_date, 'fmmm') = '5';
-- where extract(month from hire_date)=5; -- asta e destul de bine
-- where to_char(hire_date, 'month') = 'may'; -- nu merge ca spatii
-- where to_char(hire_date, 'fmmonth') = 'may';
-- where trim(to_char(hire_date, 'month')) = 'may';
where to_char(hire_date, 'mon') = 'may';

-- fm se comporta ca un  trim pe bucata / granula (gen luna, an, zi, ora etc.)

-- 15

select last_name, salary, commission_pct
from employees
where salary + salary * nvl(commission_pct, 0) >= 10000;
--order by salary desc;

-- 17


SELECT last_name, job_id, salary,
    DECODE(job_id, 'IT_PROG', salary*1.1,
        'ST_CLERK', salary*1.15,
        'SA_REP', salary*1.2,
            salary ) "salariu revizuit"
FROM employees;


SELECT last_name, job_id, salary,
    CASE job_id
        WHEN 'IT_PROG' THEN salary* 1.1
        WHEN 'ST_CLERK' THEN salary*1.15
        WHEN 'SA_REP' THEN salary*1.2
        ELSE salary
    END "salariu revizuit"
FROM employees;


SELECT last_name, job_id, salary,
    CASE
        WHEN job_id= 'IT_PROG' THEN salary* 1.1
        WHEN job_id='ST_CLERK' THEN salary*1.15
        WHEN job_id ='SA_REP' THEN salary*1.2
        ELSE salary
    END "salariu revizuit"
FROM employees;


-- 15 cu case

select last_name, salary, commission_pct
from employees
where salary + salary * (case
    when commission_pct=NULL then salary
    else salary + salary * commission_pct
end)>= 10000;