# 🧠 PROMPT MAESTRO DE INGENIERÍA: SISTEMA DE INVENTARIO .NET MAUI + SQL SERVER + DASHBOARD BI + QUESTPDF

> **Instrucciones para el usuario:**  
> Copia y pega el bloque completo a continuación en cualquier Inteligencia Artificial de frontera (Gemini 3.8 Flash, Gemini 4 Argon, Gemini 4 Hydrogen, Claude Sonnet 5.5, Claude Opus 5.5 o GPT-OSS). Este prompt contiene todas las especificaciones de arquitectura, base de datos, código C#/XAML, prevención de errores en tiempo de ejecución y diseño industrial para que la IA genere el proyecto completo, funcional y listo para producción sin omitir nada.

---

```markdown
Actúa como un **Arquitecto de Software Senior y Lead Developer en .NET MAUI (.NET 11 / 10 / 9), Administrador de Base de Datos SQL Server (DBA) y Diseñador UX/UI de Grado Industrial**.

Tu objetivo es guiarme y generar el código fuente completo, listo para producción y libre de errores de un **Sistema de Gestión de Inventario Multiplataforma (Windows y Android)** desarrollado en **.NET MAUI** con conexión directa por red TCP/IP (puerto 1433) a **Microsoft SQL Server**, que incluya:
1. Base de datos relacional normalizada con script T-SQL canónico, datos semilla y vista analítica.
2. Pantalla operativa CRUD completa (`MainPage`) con navegación táctil, búsqueda reactiva y selector de servidor por IP.
3. Pantalla de Dashboard Analítico de Business Intelligence (`ReportePage`) con 4 KPIs ejecutivos, barras de progreso por categoría y ranking de mayor a menor con semáforo condicional (🟢 Óptimo, 🟡 Bajo, 🔴 Agotado).
4. Generador vectorial de Reportes en PDF formal A4 con **QuestPDF**, apertura automática y soporte de impresión directa.

---

### 🏛️ REGLAS DE ORO DE INGENIERÍA Y BLINDAJE TÉCNICO

1. **Cero Omisiones de Código:** No resumas código, no uses `// ... resto del código ...`, no omitas namespaces ni clases auxiliares. Todo el código debe estar 100% completo, compilable y funcional.
2. **Aislamiento de Identidad (Identity PK):** Todas las llaves primarias deben ser `INT IDENTITY(1,1) PRIMARY KEY`. Queda terminantemente prohibido usar `MAX(id) + 1`.
3. **Seguridad SQL:** Todas las consultas de escritura (INSERT, UPDATE, DELETE) deben usar consultas parametrizadas con `SqlCommand.Parameters.AddWithValue` para prevenir inyección SQL.
4. **Driver Oficial de Conexión:** Utilizar exclusivamente `Microsoft.Data.SqlClient` (versión 7.1.2 o superior) con la cadena de conexión optimizada para redes locales:
   `Server={serverIp},1433;Database=InventarioDB4;User Id=JUANCITO;Password=123456;TrustServerCertificate=True;Encrypt=False;Connect Timeout=15;`
5. **Permisos en Android:** Configurar `AndroidManifest.xml` con permisos de red (`INTERNET`, `ACCESS_NETWORK_STATE`) y `android:usesCleartextTraffic="true"` para permitir tráfico TCP directo hacia la IP del host sin bloqueo HTTP/SSL de Android.
6. **Configuración QuestPDF 2026:**
   - En `MauiProgram.cs` se debe declarar obligatoriamente antes de `builder.Build()`:
     `QuestPDF.Settings.License = LicenseType.Community;`
     `QuestPDF.Settings.UseSystemFonts = true;`
     `QuestPDF.Settings.ThrowOnMissingFontFamilies = false;`
   - En aplicaciones Windows sin paquete MSIX (`WindowsPackageType=None`), `FileSystem.CacheDirectory` falla con error de *package identity*. El servicio de PDF debe usar `Path.GetTempPath()`.
7. **Thread-Safety y Concurrencia:** En `ReportePage.xaml.cs`, antes de pasar los datos a QuestPDF, extraer snapshots estáticos desconectados con `.ToList()` (`productosSnapshot` y `categoriasSnapshot`) para erradicar la excepción `Collection was modified; enumeration operation may not execute`.
8. **Despacho Seguro en UI:** Utilizar `await MainThread.InvokeOnMainThreadAsync(...)` para actualizar controles visuales desde tareas asíncronas.

---

### 📋 ENTREGABLES DETALLADOS REQUERIDOS:

---

#### 1. SCRIPT T-SQL CANÓNICO (SQL SERVER)
Genera el script SQL completo y transaccional para crear la base de datos `InventarioDB4`:
- Verificación previa si la BD ya existe y creación limpia (`CREATE DATABASE InventarioDB4;`).
- Tabla `Categorias`: `CategoriaID INT IDENTITY(1,1) PRIMARY KEY`, `Nombre NVARCHAR(50) NOT NULL UNIQUE`.
- Tabla `Productos`: `ProductoID INT IDENTITY(1,1) PRIMARY KEY`, `CodigoBarras NVARCHAR(30) NULL UNIQUE`, `Nombre NVARCHAR(100) NOT NULL`, `CategoriaID INT NOT NULL (FK)`, `Precio DECIMAL(10,2) NOT NULL (CHECK > 0)`, `Stock INT NOT NULL DEFAULT 0 (CHECK >= 0)`, `FechaRegistro DATETIME DEFAULT GETDATE()`.
- Datos semilla representativos (mínimo 6 categorías y 8 productos con variedad de existencias).
- Vista Analítica `vw_ReporteInventario`:
  - Debe calcular en tiempo real: `ValorInventario = Stock * Precio`.
  - Debe clasificar el estado mediante CASE:
    `CASE WHEN Stock = 0 THEN 'AGOTADO' WHEN Stock <= 5 THEN 'STOCK BAJO' ELSE 'OPTIMO' END AS EstadoStock`.
- Consulta de prueba ejecutiva ordenada estrictamente de mayor a menor existencia (`ORDER BY Stock DESC, ValorInventario DESC`).

---

#### 2. CONFIGURACIÓN DEL PROYECTO .NET MAUI (.csproj y AndroidManifest)
- **`InventarioMauiApp5.csproj`**: Muestra el bloque `<ItemGroup>` con los paquetes NuGet requeridos:
  - `Microsoft.Data.SqlClient` (v7.1.2)
  - `QuestPDF` (v2026.9.2)
  - `Microsoft.Maui.Controls`
- **`Platforms/Android/AndroidManifest.xml`**: Con los permisos de red y el atributo `android:usesCleartextTraffic="true"` en la etiqueta `<application>`.
- **`MauiProgram.cs`**: Con la inicialización de la licencia comunitaria de QuestPDF y la política de tolerancia de fuentes del sistema.

---

#### 3. PANTALLA OPERATIVA: `MainPage.xaml` y `MainPage.xaml.cs` (CRUD COMPLETO)
- **Diseño XAML (`MainPage.xaml`):**
  - Tema oscuro industrial (`#0F172A`), tarjetas elevadas (`#1E293B`) y tipografía de alto contraste.
  - Barra de conexión con campo de texto para la IP del servidor (por defecto `192.168.2.68` o la IP de red local) y botón "Conectar".
  - Botón de acceso directo al Dashboard: `📊 Reporte`.
  - Formulario de captura: Picker de categorías (muestra Nombre, captura ID), Código de barras, Nombre del producto, Precio (Entry numérico con teclado decimal) y Stock (Entry numérico).
  - Botones de acción: "Guardar" (Verde esmeralda) y "Limpiar / Cancelar" (Gris neutro).
  - Barra de búsqueda reactiva dinámica con evento `TextChanged="OnBuscarTextChanged"`.
  - `CollectionView` con plantilla de tarjetas individuales (`Border` con esquinas redondeadas): muestra nombre en negrita, categoría, código, cálculo de unidades x precio, botón "Editar" (Azul cian) y botón "Eliminar" (Rojo alerta).
- **Lógica Code-Behind (`MainPage.xaml.cs`):**
  - Manejo de estado: modo inserción vs modo edición mediante variable `_productoIdSeleccionado`.
  - Métodos asíncronos completos: `CargarCategoriasAsync()`, `CargarProductosAsync(filtro)`, `GuardarProductoAsync()`, `EliminarProductoAsync(id)`.
  - Búsqueda reactiva filtrando en memoria o consultando con cláusula `LIKE %filtro%`.
  - Navegación al Dashboard pasando la IP configurada: `await Navigation.PushAsync(new ReportePage(_serverIp));`.
  - Alertas interactivas de confirmación y validación de campos obligatorios.

---

#### 4. PANTALLA ANALÍTICA: `ReportePage.xaml` y `ReportePage.xaml.cs` (DASHBOARD BI CON SEMÁFORO)
- **Diseño XAML (`ReportePage.xaml`):**
  - Encabezado con 3 columnas (`ColumnDefinitions="*, Auto, Auto"`): Título del Dashboard con IP activa, botón `🔄 Actualizar` (Azul) y botón `🖨️ Imprimir PDF` (Verde esmeralda `#059669`).
  - Cuadrícula 2x2 de tarjetas KPI Bento:
    1. **Valor Total en Almacén** (`LblValorTotal`): Formato moneda `RD$ #,##0.00` en verde vivo.
    2. **Stock Físico Total** (`LblTotalUnidades`): Total de unidades disponibles en azul cian.
    3. **Variedad de SKUs** (`LblTotalProductos`): Cantidad de artículos registrados.
    4. **Alertas Semáforo** (`LblStockBajo`): Conteo de productos en estado crítico (Stock <= 5) en rojo claro.
  - Sección de Gráfico de Barras Nativo: `CollectionView` que muestra cada categoría, su valor monetario, el porcentaje de participación y una barra de progreso `ProgressBar` (`ProgressColor="#38BDF8"`).
  - Sección de Ranking de Inventario: `CollectionView` con los productos ordenados de mayor a menor existencia. Cada tarjeta tiene un borde reactivo (`Stroke="{Binding ColorEstadoBorde}"`), badge semafórico con fondo temático (`ColorEstadoFondo`), texto en alto contraste (`ColorEstadoTexto`) e icono contextual:
    - 🟢 `ÓPTIMO` (> 5 uds)
    - 🟡 `STOCK BAJO` (1 a 5 uds)
    - 🔴 `AGOTADO` (0 uds)
- **Lógica Code-Behind (`ReportePage.xaml.cs`):**
  - Constructor que recibe `serverIp`.
  - Consulta directa sobre `vw_ReporteInventario` con `ORDER BY Stock DESC, ValorInventario DESC`.
  - Modelos analíticos desacoplados: `CategoriaResumenModel` y `ReporteProductoItem` con getters computados (`CalculoDetalle`, `ValorTotalFormateado`, `SemaforoIcono`, `TextoEstado`, `ColorEstadoFondo`, `ColorEstadoTexto`, `ColorEstadoBorde`).
  - Manejador `OnImprimirPdfClicked`: extrae copias estáticas desconectadas con `.ToList()`, calcula totales e invoca `ReportePdfService.GenerarYVisualizarPdfAsync(...)`.

---

#### 5. MOTOR DE REPORTE VECTORIAL: `Services/ReportePdfService.cs` (QUESTPDF)
- Clase estática desacoplada en el namespace `InventarioMauiApp5.Services`.
- Método maestro:
  `public static async Task<string> GenerarYVisualizarPdfAsync(string serverIp, string baseDatos, decimal valorTotal, int totalUnidades, int totalProductos, int productosCriticos, IEnumerable<CategoriaResumenModel> categorias, IEnumerable<ReporteProductoItem> productos)`
- Especificación del maquetado con la API fluida de QuestPDF:
  1. Página A4 vertical, márgenes ejecutivos de 25 puntos, tipografía `Lato` o fuentes seguras del sistema.
  2. **Encabezado Institucional:** Título en azul corporativo (`#0284C7`), subtítulo en negro carbón (`#0F172A`), metadatos del servidor, base de datos activa, vista SQL de origen, fecha y hora de emisión.
  3. **Cuadrícula de 4 KPIs:** 4 cajas ejecutivas con fondos suaves (Verde `#F0FDF4`, Azul `#F0F9FF`, Morado `#FAF5FF`, Rojo `#FEF2F2`), etiquetas en negrita y valores financieros.
  4. **Tabla de Resumen por Categorías:** Columnas para Categoría, Detalle de Artículos, Valor Monetario y % de Participación con fila de cabecera oscura (`#1E293B`) y filas alternas cebradas.
  5. **Tabla de Detalle General (Auditoría de Stock):** Ranking estricto de mayor a menor existencia con columnas para `#`, `Cód. Barras`, `Producto`, `Categoría`, `Precio`, `Stock`, `Valor Total` y badge semafórico con color temático según el nivel de existencia (🟢 ÓPTIMO, 🟡 BAJO, 🔴 AGOTADO).
  6. **Pie de Página Institucional:** Texto de procedencia y paginación formal dinámica ("Página X de Y").
  7. **Ruta de Guardado Segura:** Generación del archivo en `Path.GetTempPath()` con nombre único timestamp (`Reporte_Inventario_yyyyMMdd_HHmmssfff.pdf`).
  8. **Rutina de Lanzamiento e Impresión:** Abre automáticamente el PDF usando `Process.Start` con `UseShellExecute = true` en Windows, fallback a `msedge.exe` y `Launcher.Default.OpenAsync` en móvil para que el usuario pueda imprimir directamente con <kbd>Ctrl + P</kbd>.

---

Por favor, entrega cada archivo en su correspondiente bloque de código, con explicaciones claras, sin recortar ninguna sección, asegurando que el proyecto quede completamente listo para abrir en Visual Studio, compilar y ejecutar en Windows o Android.
```
