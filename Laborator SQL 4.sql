-- Exercitii preluate din materialele scrie de Lect. Univ. Dr. Gabriela Mihai

-- 13. Obţineţi numărul de angajaţi din departamentul având codul 50.
-- 14. Câţi angajaţi din departamentul 80 câştigă comision?
-- 15. Determinaţi valoarea medie şi suma salariilor pentru toţi angajaţii care sunt reprezentanţi de vânzări (codul jobului este SA_MAN, SA_REP).
-- 16. Afişaţi minimul, maximul, suma şi media salariilor pentru fiecare departament.
-- 17. Obţineţi codul departamentelor şi suma salariilor angajaţilor care lucrează în acestea, în ordine crescătoare după suma salariilor. Se consideră angajaţii care au comision şi departamentele care au mai mult de 5 angajaţi.
-- 18. Determinaţi numele angajaţilor care au mai avut cel puţin două joburi.
-- 19. Afişaţi cel mai mare dintre salariile medii pe departamente.
-- 20. Să se creeze o cerere prin care să se afişeze numărul total de angajaţi şi, din acest total, numărul celor care au fost angajaţi în 1997, 1998, 1999 şi 2000. Datele vor fi afişate în forma următoare:
-- 1997 1998 1999 2000 Total
-- ---------------------------------------------------
-- 10 5 25 10 50
-- Indicaţie: SUM(DECODE(TO_CHAR(hire_date,'yyyy'),1997,1,0))

--13
select count (employee_id)
from employees
where department_id = 50;

--14
select count (employee_id)
from employees
where department_id = 80 and commission_pct > 0;

--15
select round(avg(salary), 2) "salariu mediu", sum(salary) "total"
from employees
where job_id in ('SA_MAN', 'SA_REP');

--16
select department_id, min(salary), max(salary), sum(salary), round(avg(salary), 2)
from employees
group by department_id;

--17
select department_id, sum(salary)
from employees
where commission_pct>0
group by department_id
having count(employee_id)>=5;

--18
select last_name, j.exjob
from employees e, ( select employee_id, count(job_id) exjob
                    from job_history
                    group by employee_id) j
where j.employee_id = e.employee_id and exjob >= 2;

--19
select department_id, round(avg(salary), 2) "salariu mediu maxim"
from employees
group by department_id
having avg(salary) = (select max(avg(salary))
                    from employees
                    group by department_id);


--20
select  sum (decode(to_char(hire_date, 'yyyy'), 1997, 1, 0)) "1997",
        sum (decode(to_char(hire_date, 'yyyy'), 1998, 1, 0)) "1998",
        sum (decode(to_char(hire_date, 'yyyy'), 1999, 1, 0)) "1999",
        sum (decode(to_char(hire_date, 'yyyy'), 2000, 1, 0)) "2000",
        sum (decode(to_char(hire_date, 'yyyy'), 1997, 1, 1998, 1, 1999, 1, 2000, 1, 0)) "total ani",
        count(*) "total"
from employees;