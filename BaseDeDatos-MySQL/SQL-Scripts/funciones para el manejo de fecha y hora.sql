/*
 * En la documentacion oficial de MySQL 9.7 
 * 
 * https://dev.mysql.com/doc/refman/9.7/en/date-and-time-functions.html
 * 
 * Utilizaremos la base de datos jardineria
 */

use jardineria;

-- Para recuperar la fecha actual
select CURDATE();

-- Sumar 31 dias a la fecha actual
select DATE_ADD(CURDATE(), INTERVAL 31 day); 

-- Recuperar el nombre del dia de hoy
select DAYNAME(CURDATE());

/* Para poder mostrar el nombre de los dias de la semana y los meses del año, 
 * en un idioma concreto */

-- Primero: Recuperamos el valor de la variable que nos permite establecer el idioma
select @@lc_time_names;

-- Para establecer el idioma a español de España
set @@lc_time_names = 'es_ES';

/* Utilizando la base de datos jardineria:
 * 
 * Recuperar los pedidos que se han efectuado en los ultimos 5 dias del mes */

use jardineria;

/* VARIANTE # 1 de Solucion: 
 * 
 * Consideramos el campo fecha_pedido de la tabla pedido */

select *
from pedido
where fecha_pedido >= date_sub(last_day(fecha_pedido), interval 5 day);



