/* 
	Las Sentencias Compuestas (Compound Statements) se encuentran en: 
    https://dev.mysql.com/doc/refman/9.7/en/sql-compound-statements.html 
    
    A compound statement is a block that can contain other blocks; 
    declarations for variables, condition handlers, and cursors;
    and flow control constructs such as loops and conditional tests.
*/

/* 
	Estructuras de Control (Flow Control Constructs). 

	Sentencias para el Control del Flujo de Ejecucion de un Script (Conjunto de 
    sentencias de SQL que tiene relacion entre ellas)
    
    1- Sentencias Condicionales, que como su nombre indica, evaluan una condicion
    , es decir, una expresion que tiene como resultado un valor buleano (boolean), 
    verdadero o falso, para que la ejecucion del script continue por una via u otra.
    
		- IF-THEN-ELSE
        
        La sintaxis: 
        
        IF search_condition THEN statement_list
			[ELSEIF search_condition THEN statement_list] ...
			[ELSE statement_list]
		END IF
        
        A modo de ejemplo vamos a crear la funcion: SimpleCompare, que esta en la 
        documentacion oficial: 
        https://dev.mysql.com/doc/refman/9.7/en/if.html
        
        Como la funcion no utiliza sentencias de SQL, mejor crear
        una base de datos aparte:
*/

drop database if exists test;
create database test;
use test;

DELIMITER $$
CREATE DEFINER=`root`@`%` FUNCTION `SimpleCompare`(n int, m int) RETURNS varchar(20) CHARSET utf8mb4
    NO SQL
BEGIN
	declare s varchar(20);
    
    if n > m then 
		
			set s = "Hola Pepito";
			set s = '>';

	elseif n = m then 
		set s = '=';
	else 
		set s = '<';
	end if;
    
    set s = concat(n, ' ', s, ' ', m);
    
	RETURN s;
END$$
DELIMITER ;

/* Llamada de la funcion: */
select `test`.`SimpleCompare`(10, 5);
select `test`.`SimpleCompare`(10, 10);
select `test`.`SimpleCompare`(5, 10);

/* Sentencia Condicional CASE, que es una alternativa a la sentencia IF-THEN-ELSE
recomendable cuando hay que evaluar muchas condiciones

https://dev.mysql.com/doc/refman/9.7/en/case.html

A modo de ejemplo:

Definir el siguiente SP que muestra un mensaje en relacion con el dia de la semana
que se recibe como parametro 

¿Por que no creamos una funcion? 

En este caso podriamos haber creado una funcion porque solamente se devuelve un resultado,
si fueramos a devolver mas de un resultado entonces si que un SP habria sido lo mejor.

*/

DELIMITER $$
CREATE DEFINER=`root`@`%` PROCEDURE `case_example`(in dayOfWeek varchar(50), out message varchar(100))
BEGIN
	declare dia varchar(50) default " ";
    
    set dia = dayOfWeek;
    
    case dia
		when "Lunes" then set message = "Hoy es lunes";
        when "Martes" then set message = "Hoy es Martes";
        when "Miercoles" then set message = "Hoy es Miercoles";
        when "Jueves" then set message = "Hoy es Juernes, los nuevos viernes";
        when "Viernes" then set message = "Hoy es Viernes y el cuerpo lo sabe";
        else set message = "Es fin de semana, si?";
    end case;
END$$
DELIMITER ;

set @dia = "Viernes";

CALL `test`.`case_example`(@dia, @result);

select @result;

/* 
	EJERCICIO # 1 del Viernes 27 de Noviembre.

	Crear una funcion que reciba como parametro un fecha y le extraiga el dia de la semana
    y muestre un mensaje en dependencia del dia de la semana en cuestion, es decir, muy 
    similar al SP case_example
*/

-- Solucion de Eduardo

DELIMITER $$
CREATE DEFINER=`root`@`%` FUNCTION `ejercicio1`(fecha VARCHAR(20)) RETURNS varchar(100) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
    DECLARE dia VARCHAR(50) DEFAULT " ";
    DECLARE idioma_actual VARCHAR(20);
    DECLARE diaSemana VARCHAR(100);

    SET idioma_actual = (SELECT @@lc_time_names);
    SET @@lc_time_names = 'es_ES';
    SET dia = DAYNAME(fecha);

    CASE dia
        WHEN "Lunes" THEN SET diaSemana = "Hoy es Lunes";
        WHEN "Martes" THEN SET diaSemana = "Hoy es Martes";
        WHEN "Miercoles" THEN SET diaSemana = "Hoy es Miercoles";
        WHEN "Jueves" THEN SET diaSemana = "Hoy es Juernes, los nuevos viernes";
        WHEN "Viernes" THEN SET diaSemana = "Hoy es Viernes y el cuerpo lo sabe";
        ELSE SET diaSemana = "Es fin de semana, si?";
    END CASE;

    SET @@lc_time_names = idioma_actual;

    RETURN diaSemana;
END$$
DELIMITER ;

-- Solucion de Vivian
DELIMITER $$
CREATE DEFINER=`root`@`%` FUNCTION `Mensaje del Dia`(fecha DATE) RETURNS varchar(100) CHARSET utf8mb4
DETERMINISTIC
BEGIN
declare message varchar(100);

case dayofweek(fecha)
when "1" then set message = "Hoy es Domigo";
when "2" then set message = "Hoy es Lunes";
when "3" then set message = "Hoy es Martes";
when "4" then set message = "Hoy es Miercoles";
when "5" then set message = "Hoy es Jueves";
when "6" then set message = "Hoy es Viernes";
when "7" then set message = "Hoy es Sabado";
end case;
RETURN message;
END$$
DELIMITER ;




