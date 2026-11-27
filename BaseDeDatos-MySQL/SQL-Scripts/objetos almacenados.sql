/*
	¿Que son los objetos almacenados?
    
    Cada vez que se va a ejecutar una consulta, entra en accion un componente del Sisteme de Gestion de Base de Datos
    denominado Analizador/Obtimizador de Consulta, que estudia el plan de ejecucion de la consulta, es decir, lo 
    que tiene que hacer para devolvernos lo se pide, unas veces con solo ir al indice sera suficiente, otras habra que 
    unir tablas, etc, pero en cualquier caso es un tiempo que se pierde o se emplea que puede penalizar el rendimiento del 
    sistema.
    
    Los objetos almacenados son un conjunto de sentencias de SQL que ya se guardan compilados, es decir, en el lenguaje
    que entiende el motor de base de datos, de forma tal que el Analizador de Consultas no tiene que pensar como ejecutar
    esas sentencias porque el plan de ejecucion ya esta guardado, compilado, conjuntamente con todas las demas sentencias.
    
    Tipos de objetos almacenados:
    
    1- Funciones
    2- Procedimientos Almacenados
    
    3- Triggers (Son creados por los DBA y odiados por los programadores). Realmente las reglas de negocio de la empresa
    se implemntan en los Triggers. Un Trigger es un codigo que responde a un evento (insertar, borrar, actualizar datos de 
    una o varias tablas, y cuando se alcanza una condicion concreta pues se dispara el codigo.
    
*/

/* ¿Que es una Funcion Almacenada, tambien conocida por Funcion Definida por el Usuario (User Defined Function), 
en lo adelante simplemente Funcion: ? 

Es un objeto que se crea con la sentencia CREATE FUNCTION y se invoca, es decir, se llama con una Clausula SELECT  o
dentro de una expresion. Una funcion puede tener cero o muchos parametros de entrada y siempre tiene que devolver
un valor, asociado al nombre de la funcion */

/* ¿Que es un Procedimiento Almacenado (Stored Procedure) en lo adelante SP? 

Es un objeto que se crea con la sentencia CREATE PROCEDURE y se invoca con la sentecian CALL. Un SP puede 
tener cero o muchos parametros de entrada y cero o muchos valores de salida  */

/* CREACION DE OBJETOS ALMACENADOS

Los objetos almecenados se guardan a nivel de la base de datos, no a nivel de tabla */

use jardineria;

/* Creacion de nuestro primer SP. 

Para listar los productos de una gama concreta, que se recibe como parametro */

DELIMITER $$
/*
	DELIMITER: Para definir un SP es necesario modificar temporalmente el caracter separador
    que se utiliza para delimitar las sentencia de SQL, el punto y coma en este caso.
    
    No siempre tiene que ser $$, tambien puede ser //, o cualquier caracter que no estes usando 
    en el SP
*/

DELIMITER $$
CREATE DEFINER=`root`@`%` PROCEDURE `listar_productos`(in gama varchar(50))
BEGIN
	select * from producto p where p.gama = gama;
END$$
DELIMITER ;

/* Invocar o llamar al SP listar_productos */
set @x = "Frutales";
call listar_productos(@x);

/* Otro ejemplo de creacion de SP:
	
   Contar los productos que sean de una gama que se recibe como parametro y devolver el resultado 
*/

DELIMITER $$
CREATE DEFINER=`root`@`%` PROCEDURE `contar_productos`(in gama varchar(50), out total int)
BEGIN
	select count(*) into total from producto p where p.gama = gama;
END$$
DELIMITER ;

/* Variante # 2 De guardar el resultado en el parametro de salida "total", en este caso */

DELIMITER $$
CREATE DEFINER=`root`@`%` PROCEDURE `contar_productos_variante_2`(in gama varchar(50), out total int)
BEGIN
	 set total = (select count(*) from producto p where p.gama = gama);
END$$
DELIMITER ;

/* Variante # 3. La clausula INTO se ubica al final de la consulta, lo cual es muy util
cuando queremos devolver varios valores, y veremos un ejemplo de ello en breve */

DELIMITER $$
CREATE DEFINER=`root`@`%` PROCEDURE `contar_productos_variante_3`(in gama varchar(50), out total int)
BEGIN
	 select count(*) from producto p where p.gama = gama into total;
END$$
DELIMITER ;


/* Invocar el SP contar_productos */
set @resultado = 0;
call contar_productos(@x, @resultado);

/* Invocando la Variante # 2 */
CALL `jardineria`.`contar_productos_variante_2`(@x, @resultado);

/* Invocando la Variante # 3 */
CALL `jardineria`.`contar_productos_variante_3`(@x, @resultado);

/* ¿Como consultar el parametro de salida o el resultado del SP anterior? */

select @resultado `Total de Productos`;

select concat("El total de productos de la gama: ", @x, ", es: ", @resultado);

/* PARAMETROS DE UN PROCEDIMIENTO ALMACENADO 

	1- Entrada (IN): Se indica poniendo la palabra IN delante del nombre del parametro. Los parametros de entrad
    NO pueden cambiar su valor dentro de procedimiento, es decir, no se pueden modificar. En los lenguajes de 
    programacion, como Java, por ejemplo, seria equivalente a pasar un parametro por valor.
    2- Salida (OUT): Se indica poniendo la palabra OUT delante del nombre del parametro. Cuando se invoca el SP
    empiezan con un valor inicial y cuando finaliza la ejecucion del SP pueden terminar con un valor diferente. 
    En programacion es equivalente a pasar un parametro por referencia (se pasa la direccion de donde esta 
    almacenado el valor, en lugar del valor en si).
    3- Entra/Salida (INOUT): Es una combinacion de los tipos IN y OUT. 

*/

/* Tipos de VARIABLES en MySQL, y en SQL en general 

	1- Variables locales: Se declaran utilizando la palabra reservada DECLARE dentro de un SP, una funcion, un 
	Trigger, un Cursor, etc. La sintaxis es la siguiente: 
    
		DECLARE total INT UNSIGNED DEFAULT 10;
        
        IMPORTANTE!!! El alcance, ambito (scope) de validez de una variable local es el bloque (BEGIN .. END)
        donde se declara.
        
    2- Variables definidas por el usuario en el ambito de la sesion: Se declaran precedidas por el caracte @
       y tienen validez, alcance, ambito (scope), durante la sesion y, evidentemente, cuando se cierra la sesion
       pierden su valor.
		
    3- Variables del sistema: Se utilizan para la configuracion de MySQL, y se declaran precedidas de @@. No se 
    recomienda utilizar estos caracteres para declarar una variable de sesion. Ejemplo de variable del Sistema,
    seria la siguiente, que hemos utilizado ya para establecer el idioma
    
    set @@GLOBAL.lc_time_names = 'es_ES';
    
*/

/* Ejemplo de uso de variable LOCAL */

DELIMITER $$
CREATE DEFINER=`root`@`%` PROCEDURE `contar_productos_variante_3_con_variable_local`(in gama varchar(50), out total int)
BEGIN
	-- Ejemplo de declaracion de una variable local
    declare temporal int unsigned default 0;
	set temporal = (select count(*) from producto p where p.gama = gama);
    
    set total = temporal;
END$$
DELIMITER ;

/* 
	CREACION DE NUESTRA PRIMER FUNCION.

	La sintaxis de la sentencia CREATE FUNCTION la podemos ver en la documentacion oficial:
    
    https://dev.mysql.com/doc/refman/8.4/en/create-procedure.html 
    
    Concretamente:
    
    Funcion que devuelve el total de productos de una gama que se recibe como parametro
*/

DELIMITER $$
CREATE DEFINER=`root`@`%` FUNCTION `contar_productos`(gama varchar(50)) RETURNS int
    DETERMINISTIC
BEGIN
	declare resultado int unsigned default 0;
    set resultado = (select count(*) from producto p where p.gama = gama);
	
    RETURN resultado;
END$$
DELIMITER ;


/* Para invocar la funcion NO se utiliza la sentencia CALL */

set @xx = `jardineria`.`contar_productos`("Frutales");

select concat("El resultado de la llamada a la funcion es: ", @xx);

/* Recordando: Un funcion se puede invocar dentro de un sentencia SELECT y evaluarse
en una expresion tambien */

select contar_productos("Ornamentales");

select concat("El total de productos de la gama es: ", contar_productos("Ornamentales"));

/* 
	CARACTERISTICAS DE LA FUNCION 
	
    Despues de la definicion del tipo de dato que devolverá la funcion (RETURNS), tenemos que indicar las 
    caracteristicas de la funcion. Las opciones disponibles son las siguientes:
    
    DETERMINISTIC: Una funcion es determinista si y solo si devuelve siempre el mismo resultado cuando se utilizan
    los mismos parametros de entrada.
    
    NOT DETERMINISTIC: Una funcion es NO determinista si NO siempre devuelve el mismo resultado, aunque
    se utilicen los mismos parametros de entrada. En muchos sistemas de Gestion de Base de Datos, es la
    caracteristica que se selecciona por defecto si no se establece una caracteristica concreta, pero en
    MySQL NO, hay que explicitamente establecer una caracteristica
    
    CONTAINS SQL: Indica que la funcion contiene sentencias de SQL, pero no contiene sentencias de Manipulacion
    de datos (DML) (Data Modification Language) y tambien existe el grupo DDL (Data Definition Language)
    
    NO SQL: La funcion NO contiene sentencias de SQL
    
    READS SQL DATA: Indica que la funcion NO modifica los datos de la base de datos y que contiene sentencias de 
    lectura de datos como la sentencia SELECT.
    
    MODIFIES SQL DATA: Indica que la funcion SI puede modificar los datos de las tablas de la base de datos,
    puesto que contiene sentencias INSERT, DELETE, UPDATE
*/

















