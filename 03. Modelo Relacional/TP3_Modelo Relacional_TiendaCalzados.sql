CREATE DATABASE TiendaCalzados;

-- Usar la base de datos
USE TiendaCalzados;

-- 1. Tabla VENDEDOR
CREATE TABLE Vendedor (
    ID_Vendedor         INT             PRIMARY KEY AUTO_INCREMENT,
    Nombre              VARCHAR(50)     NOT NULL,
    Apellido            VARCHAR(50)     NOT NULL,
    DNI                 VARCHAR(10)     UNIQUE NOT NULL,
    Fecha_Contratacion  DATE            NOT NULL,
    Telefono            VARCHAR(15),
    Email               VARCHAR(100)    UNIQUE
);

-- 2. Tabla CLIENTE
CREATE TABLE Cliente (
    ID_Cliente          INT             PRIMARY KEY AUTO_INCREMENT,
    Nombre              VARCHAR(50)     NOT NULL,
    Apellido            VARCHAR(50)     NOT NULL,
    Direccion           VARCHAR(255),
    Telefono            VARCHAR(15),
    Email               VARCHAR(100)    UNIQUE
);

-- 3. Tabla CALZADO
CREATE TABLE Calzado (
    ID_Calzado          VARCHAR(10)     PRIMARY KEY,
    Nombre              VARCHAR(100)    NOT NULL,
    Marca               VARCHAR(50)     NOT NULL,
    Talla               DECIMAL(4,1)    NOT NULL CHECK (Talla > 0),
    Color               VARCHAR(30)     NOT NULL,
    Precio_Unitario     DECIMAL(10, 2)  NOT NULL CHECK (Precio_Unitario >= 0),
    Stock               INT             NOT NULL CHECK (Stock >= 0)
);

-- 4. Tabla VENTA
CREATE TABLE Venta (
    ID_Venta            INT             PRIMARY KEY AUTO_INCREMENT,
    Fecha_Venta         DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Total_Venta         DECIMAL(10, 2)  NOT NULL CHECK (Total_Venta >= 0),
    ID_Vendedor         INT             NOT NULL,
    ID_Cliente          INT,

    CONSTRAINT fk_venta_vendedor FOREIGN KEY (ID_Vendedor) REFERENCES Vendedor(ID_Vendedor)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_venta_cliente FOREIGN KEY (ID_Cliente) REFERENCES Cliente(ID_Cliente)
        ON DELETE SET NULL ON UPDATE CASCADE
);

-- 5. Tabla DETALLE_VENTA
CREATE TABLE Detalle_Venta (
    ID_Detalle          INT             PRIMARY KEY AUTO_INCREMENT,
    ID_Venta            INT             NOT NULL,
    ID_Calzado          VARCHAR(10)     NOT NULL,
    Cantidad            INT             NOT NULL CHECK (Cantidad > 0),
    Precio_Linea        DECIMAL(10, 2)  NOT NULL CHECK (Precio_Linea >= 0),

    CONSTRAINT fk_detalle_venta FOREIGN KEY (ID_Venta) REFERENCES Venta(ID_Venta)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_detalle_calzado FOREIGN KEY (ID_Calzado) REFERENCES Calzado(ID_Calzado)
        ON DELETE RESTRICT ON UPDATE CASCADE,

    UNIQUE (ID_Venta, ID_Calzado)
);