-- =============================================================================
-- PROYECTO: SISTEMA DE INVENTARIO .NET MAUI + SQL SERVER + DASHBOARD ANALÍTICO
-- AUTOR: ING. JUANCITO PEÑA VIZCAÍNO & DATAIADEV PRO
-- DESCRIPCIÓN: CREACIÓN DE BASE DE DATOS, TABLAS RELACIONADAS, INTEGRIDAD
--              REFERENCIAL, DATOS SEMILLA, VISTA DE KPIS Y PRUEBAS CRUD.
-- =============================================================================

-- =============================================================================
-- FASE 1: CREACIÓN DE LA BASE DE DATOS (CON COMPROBACIÓN DE EXISTENCIA)
-- =============================================================================
USE [master];
GO

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'InventarioDB1')
BEGIN
    PRINT 'Creando la base de datos InventarioDB1...';
    CREATE DATABASE InventarioDB1;
END
ELSE
BEGIN
    PRINT 'La base de datos InventarioDB1 ya existe en el servidor.';
END
GO

-- Conectar el contexto de ejecución a la base de datos InventarioDB1
USE InventarioDB1;
GO

-- =============================================================================
-- FASE 2: CREACIÓN DE TABLAS CON CLAVES PRIMARIAS Y FORÁNEAS (MODELO RELACIONAL)
-- =============================================================================

-- 2.1 Tabla Maestra: Categorías de Productos
--     Contiene la clasificación general de los productos.
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = N'Categorias')
BEGIN
    CREATE TABLE Categorias (
        CategoriaID INT IDENTITY(1,1) NOT NULL, -- Clave Primaria Auto-incremental
        Nombre NVARCHAR(100) NOT NULL,          -- Nombre descriptivo de la categoría
        Descripcion NVARCHAR(250) NULL,         -- Detalle opcional
        CONSTRAINT PK_Categorias PRIMARY KEY CLUSTERED (CategoriaID)
    );
    PRINT 'Tabla Categorias creada con éxito.';
END
GO

-- 2.2 Tabla Detalle: Productos (Entidad Principal para Operaciones CRUD)
--     Vinculada con Categorias mediante Clave Foránea con eliminación en cascada.
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = N'Productos')
BEGIN
    CREATE TABLE Productos (
        ProductoID INT IDENTITY(1,1) NOT NULL,       -- Clave Primaria Auto-incremental
        CategoriaID INT NOT NULL,                    -- Clave Foránea hacia Categorias
        CodigoBarras NVARCHAR(50) NOT NULL UNIQUE,   -- Código único para escáner/búsqueda rápida
        Nombre NVARCHAR(120) NOT NULL,               -- Nombre comercial del producto
        Precio DECIMAL(18,2) NOT NULL DEFAULT 0.00,  -- Precio unitario (dos decimales)
        Stock INT NOT NULL DEFAULT 0,                -- Existencia actual en almacén
        CONSTRAINT PK_Productos PRIMARY KEY CLUSTERED (ProductoID),
        CONSTRAINT FK_Productos_Categorias FOREIGN KEY (CategoriaID)
            REFERENCES Categorias(CategoriaID)
            ON DELETE CASCADE                       -- Si se elimina la categoría, se eliminan sus productos
            ON UPDATE CASCADE
    );
    PRINT 'Tabla Productos creada con éxito.';
END
GO

-- =============================================================================
-- FASE 3: INSERCIÓN DE DATOS INICIALES (SEMILLAS DE PRUEBA REALISTAS)
-- =============================================================================

-- 3.1 Poblar Categorías (solo si la tabla está vacía)
IF NOT EXISTS (SELECT TOP 1 1 FROM Categorias)
BEGIN
    INSERT INTO Categorias (Nombre, Descripcion) VALUES
    ('Bebidas', 'Refrescos, maltas, jugos y cervezas nacionales'),
    ('Snacks', 'Papas fritas, galletas, platanitos y frutos secos'),
    ('Lácteos', 'Leches pasteurizadas, quesos crema y yogures'),
    ('Limpieza', 'Detergentes líquidos, cloro, desinfectantes y jabones'),
    ('Panadería', 'Panes de agua, pan sobao, bizcochos y repostería'),
    ('Enlatados', 'Maíz dulce, habichuelas, sardinas y atún en conserva');
    PRINT 'Semillas de Categorias insertadas.';
END
GO

-- 3.2 Poblar Productos iniciales con diversidad de precios y niveles de stock
IF NOT EXISTS (SELECT TOP 1 1 FROM Productos)
BEGIN
    INSERT INTO Productos (CategoriaID, CodigoBarras, Nombre, Precio, Stock) VALUES
    (1, '746001001', 'Cerveza Extra 355ml', 150.00, 48),
    (1, '746001002', 'Malta Morena 200ml', 45.00, 100),
    (1, '746001003', 'Refresco Cola 500ml', 50.00, 75),
    (2, '746002001', 'Platanitos Salados 45g', 35.00, 60),
    (2, '746002002', 'Galletas Dulces Vainilla', 40.00, 25),
    (3, '746003001', 'Queso Cheddar 1lb', 280.00, 15),
    (4, '746004001', 'Detergente Líquido 1L', 185.00, 40),
    (4, '746004002', 'Cloro Concentrado Galón', 120.00, 30),
    (5, '746005001', 'Pan Integral de Molde', 75.00, 5),   -- Alerta: Stock Bajo (<= 5)
    (5, '746005002', 'Bizcocho Vainilla Mini', 250.00, 12),
    (6, '746006001', 'Maíz Dulce Enlatado 400g', 95.00, 50),
    (6, '746006002', 'Habichuelas Rojas 400g', 85.00, 0);    -- Alerta: Agotado (= 0)
    PRINT 'Semillas de Productos insertadas.';
END
GO

-- =============================================================================
-- FASE 4: VISTA ANALÍTICA PARA DASHBOARDS Y REPORTES (.NET MAUI & POWER BI)
-- =============================================================================
-- Esta vista une las tablas mediante INNER JOIN y calcula en tiempo real:
-- 1. ValorInventario = Precio * Stock
-- 2. EstadoStock = Alerta semafórica ('Agotado', 'Stock Bajo', 'Óptimo')
CREATE OR ALTER VIEW vw_ReporteInventario
AS
SELECT
    P.ProductoID,
    P.CodigoBarras,
    P.Nombre AS Producto,
    C.CategoriaID,
    C.Nombre AS Categoria,
    P.Precio,
    P.Stock,
    CAST((P.Precio * P.Stock) AS DECIMAL(18,2)) AS ValorInventario,
    CASE
        WHEN P.Stock = 0 THEN 'Agotado'
        WHEN P.Stock <= 5 THEN 'Stock Bajo'
        ELSE 'Óptimo'
    END AS EstadoStock,
    C.Descripcion AS DescripcionCategoria
FROM Productos P
INNER JOIN Categorias C
    ON P.CategoriaID = C.CategoriaID;
GO

PRINT 'Vista vw_ReporteInventario compilada con éxito.';
GO

-- =============================================================================
-- FASE 5: CONFIGURACIÓN DE SEGURIDAD Y PERMISOS DEL USUARIO JUANCITO
-- =============================================================================
USE [master];
GO
IF NOT EXISTS (SELECT name FROM sys.server_principals WHERE name = N'JUANCITO')
BEGIN
    CREATE LOGIN [JUANCITO] WITH PASSWORD = N'123456',
        DEFAULT_DATABASE = [master],
        CHECK_EXPIRATION = OFF,
        CHECK_POLICY = OFF;
END
GO
ALTER SERVER ROLE [sysadmin] ADD MEMBER [JUANCITO];
ALTER SERVER ROLE [dbcreator] ADD MEMBER [JUANCITO];
ALTER LOGIN [JUANCITO] ENABLE;
GRANT CONNECT SQL TO [JUANCITO];
GO

USE [InventarioDB1];
GO
IF NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = N'JUANCITO')
BEGIN
    CREATE USER [JUANCITO] FOR LOGIN [JUANCITO];
END
GO
ALTER ROLE [db_owner] ADD MEMBER [JUANCITO];
GO

-- =============================================================================
-- FASE 6: PRUEBAS Y VALIDACIÓN DEL CICLO CRUD (EJEMPLOS COMENTADOS)
-- =============================================================================

-- [TEST CRUD - 1. CREATE / INSERT]: Registrar un nuevo producto
-- INSERT INTO Productos (CategoriaID, CodigoBarras, Nombre, Precio, Stock)
-- VALUES (1, '746001999', 'Jugo Naranja Natural 1L', 110.00, 20);

-- [TEST CRUD - 2. READ / SELECT]: Consultar todos los productos ordenados por Stock
-- SELECT * FROM Productos ORDER BY Stock DESC;

-- [TEST CRUD - 3. UPDATE]: Actualizar precio y reponer stock de un producto
-- UPDATE Productos 
-- SET Precio = 90.00, Stock = 35 
-- WHERE CodigoBarras = '746006002';

-- [TEST CRUD - 4. DELETE]: Eliminar un producto específico por su ID
-- DELETE FROM Productos WHERE CodigoBarras = '746001999';

-- [TEST ANALÍTICO]: Consultar la Vista de Reporte Ejecutivo ordenada de mayor a menor stock
SELECT * FROM vw_ReporteInventario ORDER BY Stock DESC, ValorInventario DESC;
GO
