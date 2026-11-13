// =========================================================
    // 1. RESALTADO AUTOMÁTICO DE SECCIÓN ACTIVA EN EL MENÚ FIJO
    // =========================================================
    const sections = document.querySelectorAll('section[id]');
    const navLinks = document.querySelectorAll('#nav-links a[href^="#sec-"]');

    function actualizarMenuActivo() {
      let currentId = '';
      const scrollPos = window.scrollY + 150;

      sections.forEach(sec => {
        if (scrollPos >= sec.offsetTop) {
          currentId = sec.getAttribute('id');
        }
      });

      navLinks.forEach(link => {
        link.classList.remove('active');
        if (link.getAttribute('href') === `#${currentId}`) {
          link.classList.add('active');
        }
      });
    }

    window.addEventListener('scroll', actualizarMenuActivo);
    actualizarMenuActivo();

    // =========================================================
    // 2. COPIADO AL PORTAPAPELES
    // =========================================================
    function copiarCodigo(id) {
      const codeElement = document.getElementById(id);
      const text = codeElement.innerText;
      navigator.clipboard.writeText(text).then(() => {
        mostrarToast("📋 ¡CÓDIGO COPIADO AL PORTAPAPELES!");
      });
    }

    function mostrarToast(msg) {
      const alertBox = document.getElementById('sim-alert');
      alertBox.innerText = msg;
      alertBox.style.display = 'block';
      setTimeout(() => {
        alertBox.style.display = 'none';
      }, 2500);
    }

    function simularAlerta(titulo, msg) {
      mostrarToast(`${titulo}: ${msg}`);
    }

    // =========================================================
    // 3. MOTOR DEL EMULADOR INTERACTIVO (CRUD + REPORTE BI)
    // =========================================================
    const categoriasDB = {
      1: "Bebidas",
      2: "Snacks",
      3: "Lácteos",
      4: "Limpieza",
      5: "Panadería",
      6: "Enlatados"
    };

    let productosDB = [
      { id: 1, catId: 1, codigo: "746001001", nombre: "Cerveza Extra 355ml", precio: 150.00, stock: 48 },
      { id: 2, catId: 1, codigo: "746001002", nombre: "Malta 200ml", precio: 45.00, stock: 100 },
      { id: 3, catId: 2, codigo: "746002001", nombre: "Platanitos Salados", precio: 35.00, stock: 60 },
      { id: 4, catId: 4, codigo: "746004001", nombre: "Detergente Líquido 1L", precio: 185.00, stock: 40 },
      { id: 5, catId: 5, codigo: "746005001", nombre: "Pan Integral", precio: 75.00, stock: 5 },
      { id: 6, catId: 6, codigo: "746006002", nombre: "Habichuelas Rojas Enlatadas", precio: 85.00, stock: 0 }
    ];

    let editandoId = 0;

    function renderizarLista(items) {
      const contenedor = document.getElementById('sim-lista');
      contenedor.innerHTML = "";

      if (items.length === 0) {
        contenedor.innerHTML = `<div style="text-align:center; padding:20px; color:#64748b; font-size:15px;">No se encontraron productos coincidentes.</div>`;
        return;
      }

      items.forEach(prod => {
        const catNombre = categoriasDB[prod.catId] || "Desconocida";
        const div = document.createElement('div');
        div.className = "sim-item";
        div.innerHTML = `
          <div class="sim-item-info">
            <strong>${prod.nombre}</strong>
            <span>Categoría: ${catNombre} (ID: ${prod.catId})</span>
            <span>Código: ${prod.codigo}</span>
            <div style="margin-top:4px;">
              <span class="sim-item-price" style="display:inline;">RD$ ${prod.precio.toFixed(2)}</span>
              <span class="sim-item-stock" style="display:inline;">Stock: ${prod.stock}</span>
            </div>
          </div>
          <div class="sim-actions">
            <button class="sim-act-btn sim-act-edit" onclick="simEditar(${prod.id})">✏️</button>
            <button class="sim-act-btn sim-act-del" onclick="simEliminar(${prod.id})">🗑️</button>
          </div>
        `;
        contenedor.appendChild(div);
      });
    }

    function simFiltrar() {
      const q = document.getElementById('sim-buscar').value.trim().toLowerCase();
      if (!q) {
        renderizarLista(productosDB);
        return;
      }

      const filtrados = productosDB.filter(p => {
        const catNombre = (categoriasDB[p.catId] || "").toLowerCase();
        return p.nombre.toLowerCase().includes(q) ||
               p.codigo.toLowerCase().includes(q) ||
               catNombre.includes(q) ||
               p.catId.toString() === q;
      });

      renderizarLista(filtrados);
    }

    function simGuardar() {
      const picker = document.getElementById('sim-picker');
      const catId = parseInt(picker.value);
      const codigo = document.getElementById('sim-barras').value.trim();
      const nombre = document.getElementById('sim-nombre').value.trim();
      const precio = parseFloat(document.getElementById('sim-precio').value);
      const stock = parseInt(document.getElementById('sim-stock').value);

      if (!catId) {
        simularAlerta("⚠️ Validación", "Debe seleccionar una categoría.");
        return;
      }
      if (!codigo) {
        simularAlerta("⚠️ Campo Requerido", "El código de barras no puede estar vacío.");
        return;
      }
      if (!nombre) {
        simularAlerta("⚠️ Campo Requerido", "El nombre del producto es obligatorio.");
        return;
      }
      if (isNaN(precio) || precio < 0) {
        simularAlerta("⚠️ Valor Inválido", "Ingrese un precio válido mayor o igual a 0.");
        return;
      }
      if (isNaN(stock) || stock < 0) {
        simularAlerta("⚠️ Valor Inválido", "Ingrese un stock entero y positivo.");
        return;
      }

      const duplicado = productosDB.find(p => p.codigo === codigo && p.id !== editandoId);
      if (duplicado) {
        simularAlerta("⚠️ Código Duplicado", `El código '${codigo}' ya pertenece a otro producto.`);
        return;
      }

      if (editandoId === 0) {
        const nuevoId = productosDB.length > 0 ? Math.max(...productosDB.map(p => p.id)) + 1 : 1;
        productosDB.unshift({ id: nuevoId, catId, codigo, nombre, precio, stock });
        simularAlerta("✅ Inserción Exitosa", `El producto '${nombre}' se registró correctamente.`);
      } else {
        const index = productosDB.findIndex(p => p.id === editandoId);
        if (index !== -1) {
          productosDB[index] = { id: editandoId, catId, codigo, nombre, precio, stock };
          simularAlerta("✅ Actualización Exitosa", `El producto #${editandoId} fue actualizado.`);
        }
      }

      simLimpiar();
      simFiltrar();
    }

    function simEditar(id) {
      const prod = productosDB.find(p => p.id === id);
      if (!prod) return;

      editandoId = prod.id;
      document.getElementById('sim-picker').value = prod.catId;
      document.getElementById('sim-barras').value = prod.codigo;
      document.getElementById('sim-nombre').value = prod.nombre;
      document.getElementById('sim-precio').value = prod.precio;
      document.getElementById('sim-stock').value = prod.stock;

      const lblModo = document.getElementById('sim-lbl-modo');
      lblModo.innerText = `✏️ Editando Producto #${prod.id}`;
      lblModo.style.color = "#f59e0b";

      const btnGuardar = document.getElementById('sim-btn-guardar');
      btnGuardar.innerText = "Actualizar Cambios";
      btnGuardar.style.background = "#f59e0b";
    }

    function simEliminar(id) {
      const prod = productosDB.find(p => p.id === id);
      if (!prod) return;

      if (confirm(`🗑️ ¿Seguro que deseas eliminar '${prod.nombre}' del inventario?`)) {
        productosDB = productosDB.filter(p => p.id !== id);
        simularAlerta("✅ Eliminado", `El producto '${prod.nombre}' ha sido removido.`);
        if (editandoId === id) simLimpiar();
        simFiltrar();
      }
    }

    function simLimpiar() {
      editandoId = 0;
      document.getElementById('sim-picker').value = "";
      document.getElementById('sim-barras').value = "";
      document.getElementById('sim-nombre').value = "";
      document.getElementById('sim-precio').value = "";
      document.getElementById('sim-stock').value = "";

      const lblModo = document.getElementById('sim-lbl-modo');
      lblModo.innerText = "Nuevo Producto";
      lblModo.style.color = "#94a3b8";

      const btnGuardar = document.getElementById('sim-btn-guardar');
      btnGuardar.innerText = "Guardar";
      btnGuardar.style.background = "#10b981";
    }

    // =========================================================
    // 4. NAVEGACIÓN Y CÁLCULO EN VIVO DEL DASHBOARD (REPORTEPAGE)
    // =========================================================
    function simAbrirReporte() {
      const ip = document.getElementById('sim-ip').value.trim() || "10.0.0.15";
      document.getElementById('sim-rep-server').innerText = `Servidor: ${ip}`;
      document.getElementById('sim-view-main').style.display = "none";
      document.getElementById('sim-view-reporte').style.display = "block";
      simActualizarReporte(false);
    }

    function simVolverMain() {
      document.getElementById('sim-view-reporte').style.display = "none";
      document.getElementById('sim-view-main').style.display = "block";
    }

    function simActualizarReporte(notificar = true) {
      // 1. Mapear productos con valor y ORDENAR ESTRICTAMENTE DE MAYOR A MENOR EXISTENCIA (Stock DESC)
      const itemsConValor = productosDB.map(p => ({
        ...p,
        catNombre: categoriasDB[p.catId] || "Sin categoría",
        valorTotal: p.precio * p.stock
      })).sort((a, b) => {
        if (b.stock !== a.stock) {
          return b.stock - a.stock; // De mayor a menor existencia física
        }
        return b.valorTotal - a.valorTotal; // Desempate por valor total
      });

      const valorTotalInventario = itemsConValor.reduce((acc, x) => acc + x.valorTotal, 0);
      const totalUnidades = itemsConValor.reduce((acc, x) => acc + x.stock, 0);
      const totalSkus = itemsConValor.length;
      const criticos = itemsConValor.filter(x => x.stock <= 5).length;

      document.getElementById('sim-kpi-valor').innerText = `RD$ ${valorTotalInventario.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;
      document.getElementById('sim-kpi-unidades').innerText = `${totalUnidades} uds`;
      document.getElementById('sim-kpi-skus').innerText = totalSkus;
      document.getElementById('sim-kpi-criticos').innerText = `${criticos} críticos`;

      // 2. Gráfico de barras por Categoría
      const mapaCat = {};
      itemsConValor.forEach(item => {
        if (!mapaCat[item.catNombre]) {
          mapaCat[item.catNombre] = { nombre: item.catNombre, valor: 0, unidades: 0, productos: 0 };
        }
        mapaCat[item.catNombre].valor += item.valorTotal;
        mapaCat[item.catNombre].unidades += item.stock;
        mapaCat[item.catNombre].productos += 1;
      });

      const grupos = Object.values(mapaCat).sort((a, b) => b.valor - a.valor);
      const contCat = document.getElementById('sim-rep-categorias');
      contCat.innerHTML = "";

      grupos.forEach(g => {
        const pct = valorTotalInventario > 0 ? (g.valor / valorTotalInventario) * 100 : 0;
        contCat.innerHTML += `
          <div>
            <div style="display:flex; justify-content:space-between; font-size:13px;">
              <strong style="color:#f8fafc;">${g.nombre}</strong>
              <strong style="color:#34d399;">RD$ ${g.valor.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })} (${pct.toFixed(0)}%)</strong>
            </div>
            <div class="sim-bar-track">
              <div class="sim-bar-fill" style="width:${pct.toFixed(1)}%;"></div>
            </div>
            <div style="font-size:11px; color:#64748b;">${g.productos} productos • ${g.unidades} unidades en stock</div>
          </div>
        `;
      });

      // 3. Tabla de Ranking de Inventario con Semáforo (Verde, Amarillo, Rojo) de Mayor a Menor
      const contRank = document.getElementById('sim-rep-ranking');
      contRank.innerHTML = "";

      itemsConValor.forEach(item => {
        let estadoTxt = "🟢 ÓPTIMO";
        let bg = "#064e3b"; // Verde oscuro
        let fg = "#10b981"; // Verde vivo
        let border = "#10b981";

        if (item.stock === 0) {
          estadoTxt = "🔴 AGOTADO";
          bg = "#450a0a"; // Rojo oscuro
          fg = "#ef4444"; // Rojo vivo
          border = "#ef4444";
        } else if (item.stock <= 5) {
          estadoTxt = "🟡 STOCK BAJO";
          bg = "#451a03"; // Ámbar oscuro
          fg = "#f59e0b"; // Amarillo vivo
          border = "#f59e0b";
        }

        contRank.innerHTML += `
          <div class="sim-item" style="flex-direction:column; align-items:stretch; border:1.5px solid ${border}; margin-bottom:8px; background:#1e293b; border-radius:10px; padding:12px;">
            <div style="display:flex; justify-content:space-between; align-items:flex-start;">
              <div>
                <strong style="color:#f8fafc; font-size:15px; display:block;">${item.nombre}</strong>
                <span style="color:#94a3b8; font-size:12px;">${item.catNombre}</span>
              </div>
              <span class="sim-badge" style="background:${bg}; color:${fg}; border:1px solid ${border}; font-weight:800; font-size:11px; padding:4px 8px; border-radius:6px;">
                ${estadoTxt}
              </span>
            </div>
            <div style="display:flex; justify-content:space-between; align-items:center; margin-top:8px; border-top:1px dashed #334155; padding-top:6px;">
              <span style="color:#94a3b8; font-size:12px;">📦 Stock: <strong style="color:${fg}; font-size:13px;">${item.stock} uds</strong> × RD$ ${item.precio.toFixed(2)}</span>
              <strong style="color:#34d399; font-size:14px;">RD$ ${item.valorTotal.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}</strong>
            </div>
          </div>
        `;
      });

      if (notificar) {
        simularAlerta("🔄 Dashboard Actualizado", "Vista vw_ReporteInventario sincronizada de mayor a menor con semáforo.");
      }
    }

    // Inicialización del simulador
    renderizarLista(productosDB);
