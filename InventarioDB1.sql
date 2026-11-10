-- =============================================================================
-- SISTEMA DE INVENTARIO - SCRIPT COMPLETO DE BASE DE DATOS
-- Autor: Ing. Juancito Peña
-- Motor: Microsoft SQL Server
-- Base de Datos: InventarioDB1
-- Descripción: Creación de BD, tablas relacionales con integridad referencial,
--              carga de datos iniciales clasificados y vista analítica de stock.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. CREACIÓN Y POSICIONAMIENTO EN LA BASE DE DATOS
-- -----------------------------------------------------------------------------
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'InventarioDB1')
BEGIN
    CREATE DATABASE InventarioDB1;
END
GO

USE InventarioDB1;
GO

-- -----------------------------------------------------------------------------
-- 2. LIMPIEZA DE OBJETOS PREVIOS (Evita conflictos al re-ejecutar)
-- -----------------------------------------------------------------------------
IF OBJECT_ID('dbo.vw_ReporteInventario', 'V') IS NOT NULL
    DROP VIEW dbo.vw_ReporteInventario;
GO

IF OBJECT_ID('dbo.Productos', 'U') IS NOT NULL
    DROP TABLE dbo.Productos;
GO

IF OBJECT_ID('dbo.Categorias', 'U') IS NOT NULL
    DROP TABLE dbo.Categorias;
GO

-- -----------------------------------------------------------------------------
-- 3. CREACIÓN DE TABLAS
-- -----------------------------------------------------------------------------

-- TABLA PADRE: Categorías de productos
CREATE TABLE Categorias (
    CategoriaID INT IDENTITY(1,1) PRIMARY KEY,     -- Clave primaria auto-incremental
    Nombre NVARCHAR(100) NOT NULL,                 -- Nombre descriptivo de la categoría
    Descripcion NVARCHAR(250) NULL                 -- Detalle opcional del tipo de productos
);
GO

-- TABLA RELACIONADA (CRUD Objetivo): Catálogo de Productos
CREATE TABLE Productos (
    ProductoID INT IDENTITY(1,1) PRIMARY KEY,      -- Clave primaria auto-incremental
    CategoriaID INT NOT NULL,                      -- Clave foránea referenciando Categorias
    CodigoBarras NVARCHAR(50) NOT NULL UNIQUE,     -- Identificador único para lectura de escáner
    Nombre NVARCHAR(120) NOT NULL,                 -- Descripción comercial del artículo
    Precio DECIMAL(18,2) NOT NULL DEFAULT 0.00,    -- Precio unitario de venta
    Stock INT NOT NULL DEFAULT 0,                  -- Cantidad física disponible en almacén
    
    -- Integridad referencial con borrado en cascada
    CONSTRAINT FK_Productos_Categorias FOREIGN KEY (CategoriaID)
        REFERENCES Categorias(CategoriaID) 
        ON DELETE CASCADE
);
GO

-- -----------------------------------------------------------------------------
-- 4. POBLACIÓN DE DATOS: CATEGORÍAS
-- -----------------------------------------------------------------------------

-- Bloque 1: Categorías iniciales (IDs generados: 1, 2, 3)
INSERT INTO Categorias (Nombre, Descripcion) 
VALUES
    ('Bebidas', 'Refrescos, maltas y cervezas'),
    ('Snacks', 'Papas, galletas y frituras'),
    ('Lácteos', 'Quesos y leches');

-- Bloque 2: Nuevas categorías operativas (IDs generados: 4, 5, 6)
INSERT INTO Categorias (Nombre, Descripcion) 
VALUES
    ('Limpieza', 'Productos para higiene y limpieza del hogar'),
    ('Panadería', 'Panes, bizcochos y repostería'),
    ('Enlatados', 'Productos conservados en latas');
GO


-- -----------------------------------------------------------------------------
-- 5. POBLACIÓN DE DATOS: PRODUCTOS ASOCIADOS
-- -----------------------------------------------------------------------------
INSERT INTO Productos (CategoriaID, CodigoBarras, Nombre, Precio, Stock) 
VALUES
    -- Grupo 1: Bebidas (CategoriaID = 1)
    (1, '746001001', 'Cerveza Extra 355ml', 150.00, 48),
    (1, '746001002', 'Malta 200ml', 45.00, 100),

    -- Grupo 2: Snacks (CategoriaID = 2)
    (2, '746002001', 'Platanitos Salados', 35.00, 60),

    -- Grupo 4: Limpieza (CategoriaID = 4)
    (4, '746004001', 'Detergente Líquido 1L', 185.00, 40),
    (4, '746004002', 'Cloro Galón', 120.00, 30),

    -- Grupo 5: Panadería (CategoriaID = 5)
    (5, '746005001', 'Pan Integral', 75.00, 25),
    (5, '746005002', 'Bizcocho Vainilla', 250.00, 12),

    -- Grupo 6: Enlatados (CategoriaID = 6)
    (6, '746006001', 'Maíz Dulce Enlatado', 95.00, 50),
    (6, '746006002', 'Habichuelas Rojas Enlatadas', 85.00, 45);
GO


-- -----------------------------------------------------------------------------
-- 6.  VISTA ANALÍTICA Y REPORTE DE VALORIZACIÓN
-- -----------------------------------------------------------------------------
-- Permite consultar el inventario consolidado, valor económico y semáforo de existencias
CREATE VIEW vw_ReporteInventario
AS
SELECT
    P.ProductoID,
    P.CodigoBarras,
    P.Nombre AS Producto,
    C.CategoriaID,
    C.Nombre AS Categoria,
    P.Precio,
    P.Stock,
    (P.Precio * P.Stock) AS ValorInventario,         -- Total valorizado por producto en almacén
    CASE
        WHEN P.Stock = 0 THEN 'Agotado'
        WHEN P.Stock <= 20 THEN 'Stock Bajo'
        WHEN P.Stock <= 50 THEN 'Stock Medio'
        ELSE 'Stock Disponible'
    END AS EstadoStock,                              -- Semáforo operativo de reposición
    C.Descripcion AS DescripcionCategoria
FROM Productos P
INNER JOIN Categorias C
    ON P.CategoriaID = C.CategoriaID;
GO

-- -----------------------------------------------------------------------------
-- 7. VERIFICACIÓN Y CONSULTA FINAL DEL REPORTE
-- -----------------------------------------------------------------------------
SELECT 
    ProductoID,
    CodigoBarras,
    Producto,
    Categoria,
    Precio,
    Stock,
    ValorInventario,
    EstadoStock
FROM vw_ReporteInventario
ORDER BY Categoria ASC, Producto ASC;
GO


