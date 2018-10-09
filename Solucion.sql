--
---- Parcial 1. Parte Practica. Sergio Alejandro Gonzalez Aguirre.
--

-- 1. CREATE A TABLESPACE MID_TERM WITH ONE DATAFILE OF 50Mb (For the datafile don't put the path, just the name of the datafile)
CREATE TABLESPACE MID_TERM DATAFILE 'MID_TERM.dbf' SIZE 50M;

-- 2. CREATE AN USER WITH 20Mb ASSIGNED TO THE TABLESPACE MID_TERM
CREATE USER usuario
	IDENTIFIED BY usuario
	DEFAULT TABLESPACE MID_TERM
	QUOTA 20M ON MID_TERM;

-- 3. GIVE THE DBA ROLE TO THE USER, ALSO SHOULD BE ABLE TO LOG IN.
GRANT DBA TO usuario;
GRANT CONNECT TO usuario;

-- 4. CREATE TWO SEQUENCES:
	-- 4.1 COMUNAS_SEQ SHOULD START IN 50 WITH INCREMENTS OF 3
	-- 4.2 COLEGIOS_SEQ SHOULD START IN 100 WITH INCREMENTS OF 1
CREATE SEQUENCE COMUNAS_SEQ START WITH 50 INCREMENT BY 3;
CREATE SEQUENCE COLEGIOS_SEQ START WITH 100 INCREMENT BY 1;

-- 5. CREATE THE NEXT TABLES:

CREATE TABLE COMUNAS (
	ID INTEGER PRIMARY KEY,
	NOMBRE VARCHAR2(255)
);

INSERT INTO COMUNAS VALUES (1,	'POPULAR');
INSERT INTO COMUNAS VALUES (10,	'LA CANDELARIA');
INSERT INTO COMUNAS VALUES (11,	'LAURELES ESTADIO');
INSERT INTO COMUNAS VALUES (12,	'LA AMERICA');
INSERT INTO COMUNAS VALUES (13,	'SAN JAVIER');
INSERT INTO COMUNAS VALUES (14,	'POBLADO');
INSERT INTO COMUNAS VALUES (15,	'GUAYABAL');
INSERT INTO COMUNAS VALUES (16,	'BELÉN');
INSERT INTO COMUNAS VALUES (2,	'SANTA CRUZ');
INSERT INTO COMUNAS VALUES (3,	'MANRIQUE');
INSERT INTO COMUNAS VALUES (4,	'ARANJUEZ');
INSERT INTO COMUNAS VALUES (5,	'CASTILLA');
INSERT INTO COMUNAS VALUES (50,	'PALMITAS');
INSERT INTO COMUNAS VALUES (6,	'DOCE DE OCTUBRE');
INSERT INTO COMUNAS VALUES (60,	'SAN CRISTOBAL');
INSERT INTO COMUNAS VALUES (7,	'ROBLEDO');
INSERT INTO COMUNAS VALUES (70,	'ALTAVISTA');
INSERT INTO COMUNAS VALUES (8,	'VILLA HERMOSA');
INSERT INTO COMUNAS VALUES (80,	'SAN ANTONIO DE PRADO');
INSERT INTO COMUNAS VALUES (9,	'BUENOS AIRES');
INSERT INTO COMUNAS VALUES (90,	'SANTA ELENA');


-- FOR THE NEXT TABLE YOU SHOULD: 	
---- * ADD THE PRIMARY KEY "ID" COLUMN TO THE COLEGIOS TABLE, ALSO ADD THE FOREIGN KEY WITH COMUNAS TABLE. 
---- THE NAME OF THE FOREIGN KEY SHOULD BE "COMUNA_FK"

create table colegios (
    id integer primary key,
	consecutivo_dane VARCHAR2(255),
	nombre_sede VARCHAR2(255),
	tipo_sede VARCHAR2(255),
	comuna_id INTEGER,
	prestacion_servicio VARCHAR2(255),
	zona VARCHAR2(255),
	barrio VARCHAR2(255),
	sector VARCHAR2(255),
	direccion_sede VARCHAR2(255),
	telefono_sede VARCHAR2(255),
	rector VARCHAR2(255),
	contador_prejardin_jardin INTEGER,
	contador_transicion INTEGER,
	contador_primaria INTEGER,
	contador_secundaria INTEGER,
	contador_media INTEGER,
	contador_adultos INTEGER,
	jornada_completa VARCHAR(8),
	jornada_manana VARCHAR(8),
	jornada_tarde VARCHAR(8),
	jornada_nocturna VARCHAR(8),
	jornada_fin_de_semana VARCHAR(8),
	jornada_unica VARCHAR(8),
	clasificacion_icfes VARCHAR(8),
    
    CONSTRAINT COMUNA_FK FOREIGN KEY (comuna_id) REFERENCES COMUNAS(ID)
);

-- 6. Import the data: https://gist.github.com/amartinezg/035524e3cb6ec719bb839dd97018c098
-- Done

-- 7. Queries (DO NOT CHANGE THE NAME OF THE COLUMNS):

-- 7.1: Traiga el nombre del barrio y el número de colegios ubicados en cada barrio de aquellas instituciones ubicadas en la 
    -- comuna de buenos aires ordenado por el número de colegios de mayor a menor.
    -- Columnas: barrio, numero_colegios
SELECT DISTINCT colegios.barrio, COUNT (*) OVER (PARTITION BY colegios.barrio) AS numero_colegios    
    FROM comunas INNER JOIN colegios ON comunas.id = colegios.comuna_id
    WHERE comunas.nombre = 'BUENOS AIRES'
    ORDER BY numero_colegios DESC;

-- 7.2: Traiga los registros junto con el nombre de su comuna, para cada registro deberá calcularse el total 
    -- de los estudiantes según los contadores. También deberá traer el total de estudiantes agrupados por comuna.
--	 Columnas: ID, NOMBRE_SEDE, COMUNA_ID, NOMBRE_COMUNA, TOTAL_GENERAL, TOTAL_POR COMUNA
SELECT 
    colegios.ID, 
    colegios.NOMBRE_SEDE, 
    colegios.COMUNA_ID, 
    comunas.NOMBRE AS NOMBRE_COMUNA, 
    SUM(colegios.contador_prejardin_jardin + colegios.contador_transicion + colegios.contador_primaria + colegios.contador_secundaria + colegios.contador_media + colegios.contador_adultos) OVER (PARTITION BY colegios.id) AS TOTAL_GENERAL,
    SUM(colegios.contador_prejardin_jardin + colegios.contador_transicion + colegios.contador_primaria + colegios.contador_secundaria + colegios.contador_media + colegios.contador_adultos) OVER (PARTITION BY comunas.id) AS TOTAL_POR_COMUNA
    FROM colegios INNER JOIN comunas ON colegios.comuna_id = comunas.id;

-- 7.3: Traiga los colegios que dicten clases a estudiantes de prejardin-jardin y que en la prestación 
    --de su servicio sean no oficiales para las comunas ARANJUEZ, CASTILLA y DOCE DE OCTUBRE. 
    --Deberá incluir el contador de estudiantes de secundaria y deberá calcular el promedio de estudiantes de secundaria 
    --agrupados por comuna redondeado a 2 decimales.
--	 Columnas: ID, NOMBRE_SEDE, COMUNA_ID, NOMBRE_COMUNA, CONTADOR_SECUNDARIA, PROMEDIO_SECUNDARIA_COMUNA
SELECT
    colegios.ID, 
    colegios.NOMBRE_SEDE, 
    colegios.COMUNA_ID, 
    comunas.NOMBRE AS NOMBRE_COMUNA, 
    SUM(colegios.CONTADOR_SECUNDARIA) OVER (PARTITION BY colegios.id) AS CONTADOR_SECUNDARIA,
    AVG(colegios.CONTADOR_SECUNDARIA) OVER (PARTITION BY comunas.id) AS PROMEDIO_SECUNDARIA_COMUNA
    FROM colegios INNER JOIN comunas ON colegios.comuna_id = comunas.id;


-- 7.4 Traiga el nombre de los rectores y el número de colegios encargados para cada rector de aquellos rectores que estén encargados de más de 2 colegios. 
--	Los registros deberán estar ordenados alfabéticamente
--	Nota: NO se deberán incluir aquellos registros que tengan un correo electrónico registrado y tampoco aquellos que registran como nombre "s/d"
--	Columnas: rector, numero_colegios

-- 7.5 Muestre el nombre del colegio, el barrio, la dirección de aquellos colegios que estén ubicados en la zona rural y tengan algún tipo de clasificación en el ICFES. Además deberá traer aquellos colegios que enseñan a más de 200 estudiantes adultos
--	Columnas: barrio, numero_colegios

