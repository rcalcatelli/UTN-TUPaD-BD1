# 🔷 TFI – Bases de Datos I (Java + SQL)

<div align="center">
  
![Java](https://img.shields.io/badge/Java-ED8B00?style=for-the-badge&logo=openjdk&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-005C84?style=for-the-badge&logo=mysql&logoColor=white)
![JDBC](https://img.shields.io/badge/JDBC-Database%20Connectivity-2ECC71?style=for-the-badge)
![UTN](https://img.shields.io/badge/UTN-TUPaD-0066CC?style=for-the-badge)

</div>

---

## 📖 Descripción

Este repositorio contiene el **Trabajo Final Integrador** de la materia **Bases de Datos I**, perteneciente a la **Tecnicatura Universitaria en Programación a Distancia (UTN)**.  

El proyecto combina **Java y SQL** para demostrar el uso práctico de **transacciones, restricciones, vistas y niveles de aislamiento** en una base de datos relacional, junto con una **aplicación Java** que gestiona la conexión y operaciones mediante **JDBC**.

---

## 🎯 Objetivo general

* Aplicar los conceptos fundamentales del **modelo relacional** y **control de transacciones**.  
* Conectar una aplicación **Java** a una base de datos utilizando **JDBC**.  
* Evaluar el comportamiento de **niveles de aislamiento** mediante múltiples conexiones simultáneas.  
* Implementar **restricciones (UNIQUE, FK, CHECK)** y observar sus violaciones controladas.  
* Generar y consultar **vistas y permisos** según roles de usuario.  
* Consolidar una visión integral del ciclo completo: **diseño, implementación y prueba** de bases de datos relacionales.

---

## 📚 Contenido del trabajo final

El TFI se divide en dos grandes componentes: **implementación SQL** y **aplicación Java**.

### 🗄️ **Parte 1: Base de Datos (SQL)**

Incluye scripts para la creación, carga y prueba de la base de datos.

#### **1. Creación y carga inicial**
- `01_seed_core.sql`  
- `01-2_seed_vendedor_tx.sql`  
- `01-3_seed_cliente_tx.sql`  
- `01-4.1_seed_ventas_tx.sql`  
- `01-4.2_seed_ventas_tx.sql`  
- `01-5_seed_pagos_tx.sql`  
- `02_seed_tx.sql`

#### **2. Pruebas de transacciones y niveles de aislamiento**
- `CONEXIÓN 1 (VENTANA A).sql`  
- `CONEXIÓN 2 (VENTANA B).sql`  
- `conexion1_rr_vs_rc_lab.sql`  
- `conexion2_rr_vs_rc_lab.sql`

#### **3. Validaciones y restricciones**
- `prueba1_violacion_unique.sql`  
- `prueba2_violacion_fk.sql`  
- `prueba3_violacion_check.sql`

#### **4. Roles, vistas y permisos**
- `vistas_usuarios_permisos.sql`  
- `vista_1.sql`  
- `vista_2.sql`  
- `test_admin.sql`  
- `test_gerente.sql`  
- `test_vendedor.sql`

#### **5. Consultas de validación**
- `consultas_test.sql`

#### **6. Diagramas visuales**
- `Caratula Base de Datos I TFI.png`  
- `DER.png` → Diagrama Entidad-Relación  
- `UML.png` → Diagrama de Clases Java

---

### 💻 **Parte 2: Aplicación Java (tpfinaldb/)**

#### **Clases principales**
| Archivo | Descripción |
|----------|--------------|
| `App.java` | Clase principal. Ejecuta las pruebas y control de flujo. |
| `DB.java` | Configura y gestiona la conexión con la base de datos. |
| `PagoDAO.java` | Implementa operaciones de acceso a datos (pagos). |
| `TransaccionesEjemplo.java` | Muestra ejemplos prácticos de transacciones y control de errores. |

---

## 🔍 Conceptos clave aplicados

| Concepto | Archivo / Ejemplo | Descripción |
|-----------|------------------|--------------|
| **Transacciones (COMMIT/ROLLBACK)** | TransaccionesEjemplo.java / SQL | Control de operaciones atómicas |
| **Niveles de aislamiento** | conexion1_rr_vs_rc_lab.sql | Comparación entre READ COMMITTED y REPEATABLE READ |
| **Restricciones** | prueba1_violacion_*.sql | Validación de reglas de integridad |
| **DAO Pattern (Java)** | PagoDAO.java | Separación de lógica de negocio y acceso a datos |
| **JDBC** | DB.java | Conexión directa a la base de datos |
| **Vistas y permisos** | vistas_usuarios_permisos.sql | Control de acceso por roles |

---

## 🧩 Tecnologías Utilizadas

- **Java SE 17**
- **MySQL / MariaDB**
- **JDBC (Java Database Connectivity)**
- **MySQL Workbench** (entorno de ejecución SQL)

---

## 🚀 Ejecución del proyecto

1. **Importar los scripts SQL** en el orden indicado (desde `01_seed_core.sql` hasta `02_seed_tx.sql`).  
2. Configurar los parámetros de conexión en `DB.java` (usuario, contraseña, URL).  
3. Compilar y ejecutar la clase `App.java` para correr las pruebas.  
4. Ejecutar en paralelo los archivos `CONEXIÓN 1` y `CONEXIÓN 2` para analizar los efectos de las transacciones simultáneas.  
5. Verificar los resultados de las restricciones y niveles de aislamiento.

---

## ✅ Conclusiones

Este trabajo permitió integrar de forma práctica los conceptos teóricos vistos en la materia, reforzando:

- El **diseño relacional** y la **normalización** de datos.  
- El manejo de **transacciones concurrentes** y **niveles de aislamiento**.  
- La interacción entre **Java y SQL** mediante **JDBC**.  
- Las **buenas prácticas** en documentación, organización y pruebas.  

El proyecto demuestra la capacidad de **construir, gestionar y manipular una base de datos relacional real**, garantizando la integridad, coherencia y eficiencia en los procesos de acceso a datos.

---

## 📚 Bibliografía y referencias

- *Elmasri & Navathe* – “Fundamentals of Database Systems”  
- *Oracle MySQL Documentation* – [https://dev.mysql.com/doc/](https://dev.mysql.com/doc/)  
- *Java JDBC Guide* – [Oracle Docs](https://docs.oracle.com/javase/tutorial/jdbc/)  
- Material de **Bases de Datos I – UTN TUPaD**

---

<div align="center">

**Bases de Datos I – 2025**  
*Universidad Tecnológica Nacional - TUPaD*  
📘 *Estudiante: Renzo Calcatelli – Comisión M2025-1*

</div>
