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



/* Invocar el SP contar_productos */
set @resultado = 0;
call contar_productos(@x, @resultado);

CALL `jardineria`.`contar_productos`(@x, @resultado);


/* ¿Como consultar el parametro de salida o el resultado del SP anterior? */

select @resultado `Total de Productos`;

select concat("El total de productos de la gama: ", @x, ", es: ", @resultado);















