/* Comprobar la existencia de las tablas t1 y t2, eliminandolas si
 * existen */

drop table if exists t1, t2;

create temporary table t1 (c1 int not null, c2 int not null, c3 int not null);
create temporary table t2 (c1 int not null, c2 int not null, c3 int not null);

insert into t1 values (1,2,3), (2, 2, 2), (3, 3, 3);
insert into t2 values (5, 5, 5), (2, 2, 2), (4, 4, 4), (3, 3, 3);

table t1;
table t2;

select c1, c2, c3
from t2
where row(c1,c2,c3) > (select c1, c2, c3 from t1 limit 1,1);

/* Creacion de tablas temporales a partir de tablas existentes.
 * 
 * Por ejemplo, de la base de datos world y de la tabla country crear 
 * una tabla temporal */

use world;

drop table if exists t3;

create temporary table t3 
select Name, Continent, Region, SurfaceArea, IndepYear, Population  from country;

table t3;

/* Ejercicio # 1 del Martes 24 de Noviembre 
 * 
 * 1- Crear tabla temporal t4 con los campos Code, Name, Continent,
 * Region, SurfaceArea, IndepYear, Population. Hacer que el campo Code
 * sea PK.  
 * 2- Crear una tabla temporal t5 a partir de la tabla countryLanguage 
 * 3- Eliminar de la tabla t4 los paises que tengan menos de 4 lenguas 
 * oficiales 
 * 
 * No olvidar hacer la operacion de borrado en el marco de una transacion
 * 
 * Nota: Previamente, crear una tabla temporal t6 con los paises que tengan
 * menos de 4 lenguas oficiales */

/* Solucion:
 * 
 * Pto. 1 - Comprobar si la tabla t4 existe y eliminarla si es asi. */

use world;

drop table if exists t4;

create temporary table t4 
select Code, Name, Continent, Region, SurfaceArea, IndepYear, Population
from country; 

table t4;

-- La tabla t4 no tiene PK ¿Como lo sé?
describe t4;

ALTER TABLE t4 ADD CONSTRAINT PRIMARY KEY (Code);

/* Pto. 2 */

drop table if exists t5;

create temporary table t5
select * from countrylanguage;

describe t5;

alter table t5
add constraint primary key (CountryCode, Language);

/* Pto 3 
 * 
 * Previamente crear la tabla t6 */

drop table if exists t6;

create temporary table t6
select co.Code, count(cl.Language) as `Total idiomas`
from country as co left join countrylanguage as cl on co.Code = cl.CountryCode
and cl.IsOfficial = 'T' 
group by co.Code
having `Total idiomas` < 4 
order by `Total idiomas` desc;

table t6;

start transaction;

delete t4
from t4 join t6 as dt on t4.Code = dt.Code;

table t4;

-- commit;
-- rollback;


table country; 
describe countrylanguage; 