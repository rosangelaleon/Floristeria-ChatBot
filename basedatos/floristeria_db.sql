-- =====================================================
-- INFORMACIÓN DE LA TIENDA
-- =====================================================
CREATE TABLE tienda_info (
    id SERIAL PRIMARY KEY,
    nombre_tienda VARCHAR(100) NOT NULL,           -- Nombre de la floristería
    direccion TEXT NOT NULL,                       -- Dirección completa
    telefono VARCHAR(20),                          -- Teléfono principal
    email VARCHAR(100),                            -- Email de contacto
    horario VARCHAR(200),                          -- Horarios de atención
    whatsapp VARCHAR(20),                          -- Número de WhatsApp
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- Fecha de creación
);
-- =====================================================
-- CATEGORÍAS DE PRODUCTOS
-- =====================================================
CREATE TABLE categorias (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,                   -- Nombre de la categoría
    descripcion TEXT,                              -- Descripción detallada
    activa BOOLEAN DEFAULT TRUE                    -- Si está disponible
);
-- =====================================================
-- OCASIONES ESPECIALES
-- =====================================================
CREATE TABLE ocasiones (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,                   -- Nombre de la ocasión
    descripcion TEXT,                              -- Descripción de la ocasión
    precio_promedio DECIMAL(10,2),                 -- Precio promedio sugerido
    popularidad INTEGER DEFAULT 1                  -- Nivel de popularidad (1-10)
);
-- =====================================================
-- ZONAS DE DELIVERY
-- =====================================================
CREATE TABLE zonas_delivery (
    id SERIAL PRIMARY KEY,
    nombre_zona VARCHAR(100) NOT NULL,             -- Nombre de la zona (ej: "Centro", "Barrio San Miguel")
    descripcion TEXT,                              -- Descripción de la zona
    precio_envio DECIMAL(10,2) NOT NULL,           -- Costo del envío a esta zona
    tiempo_entrega_minutos INTEGER DEFAULT 60,     -- Tiempo estimado de entrega
    activa BOOLEAN DEFAULT TRUE,                   -- Si está disponible para delivery
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- Fecha de creación
);
-- =====================================================
-- PRODUCTOS (INFORMACIÓN BÁSICA)
-- =====================================================
CREATE TABLE productos (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,                  -- Nombre del producto
    descripcion TEXT,                              -- Descripción del producto
    categoria_id INTEGER REFERENCES categorias(id), -- Categoría del producto
    ocasion_id INTEGER REFERENCES ocasiones(id),   -- Ocasión recomendada
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- Fecha de creación
);
-- =====================================================
-- DETALLES DE PRODUCTOS
-- =====================================================
CREATE TABLE producto_detalle (
    id SERIAL PRIMARY KEY,
    producto_id INTEGER REFERENCES productos(id),  -- Producto al que pertenece
    stock_disponible INTEGER DEFAULT 0,            -- Cantidad en stock
    tiempo_preparacion_minutos INTEGER DEFAULT 60, -- Tiempo para preparar (en minutos)
    disponible BOOLEAN DEFAULT TRUE,               -- Si está disponible
    popularidad INTEGER DEFAULT 1,                 -- Popularidad (1-10)
    veces_recomendado INTEGER DEFAULT 0,           -- Contador de recomendaciones
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- Última actualización
);
-- =====================================================
-- PRECIOS DE PRODUCTOS
-- =====================================================
CREATE TABLE precios (
    id SERIAL PRIMARY KEY,
    producto_id INTEGER REFERENCES productos(id),  -- Producto al que aplica
    precio_base DECIMAL(10,2) NOT NULL,            -- Precio base del producto
    fecha_inicio DATE DEFAULT CURRENT_DATE,        -- Desde cuándo (fecha) es válido este precio
    fecha_fin DATE,                                -- Hasta cuándo es válido (NULL = sin fin)
    activo BOOLEAN DEFAULT TRUE,                   -- Si está activo este precio
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- Fecha de creación
);
-- =====================================================
-- DETALLES DE PRECIOS POR CANTIDAD
-- =====================================================
CREATE TABLE precio_detalle (
    id SERIAL PRIMARY KEY,
    precio_id INTEGER REFERENCES precios(id),      -- Precio al que pertenece
    cantidad_minima INTEGER NOT NULL,              -- Cantidad mínima (ej: 1, 3, 6)
    cantidad_maxima INTEGER,                       -- Cantidad máxima (ej: 2, 5, 11, NULL=sin límite)
    precio_unitario DECIMAL(10,2) NOT NULL,        -- Precio por unidad en este rango
    descuento_porcentaje DECIMAL(5,2) DEFAULT 0,   -- Descuento adicional por cantidad
    activo BOOLEAN DEFAULT TRUE,                   -- Si está activo este detalle
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- Fecha de creación
);
-- =====================================================
-- REGLAS DE RECOMENDACIÓN
-- =====================================================
CREATE TABLE reglas_recomendacion (
    id SERIAL PRIMARY KEY,
    ocasion_id INTEGER REFERENCES ocasiones(id),   -- Para qué ocasión
    precio_minimo DECIMAL(10,2),                   -- Precio mínimo del presupuesto
    precio_maximo DECIMAL(10,2),                   -- Precio máximo del presupuesto
    productos_recomendados INTEGER[],              -- IDs de productos a recomendar
    score_algoritmo DECIMAL(3,2),                  -- Puntuación del algoritmo
    activa BOOLEAN DEFAULT TRUE,                   -- Si la regla está activa
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- Fecha de creación
);
-- =====================================================
-- CONVERSACIONES DEL CHATBOT
-- =====================================================
CREATE TABLE conversaciones (
    id SERIAL PRIMARY KEY,
    session_id VARCHAR(100),                       -- ID de la sesión del usuario
    pregunta TEXT NOT NULL,                        -- Pregunta del usuario
    respuesta TEXT NOT NULL,                       -- Respuesta del bot
    tipo_consulta VARCHAR(50),                     -- Tipo: precio, horario, recomendacion
    tiempo_respuesta_ms INTEGER,                   -- Tiempo de respuesta en ms
    productos_mencionados INTEGER[],               -- IDs de productos mencionados
    usuario_satisfecho BOOLEAN,                    -- Si el usuario quedó satisfecho
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP      -- Fecha y hora de la conversación
);
-- =====================================================
-- PREGUNTAS FRECUENTES
-- =====================================================
CREATE TABLE preguntas_frecuentes (
    id SERIAL PRIMARY KEY,
    categoria VARCHAR(30),                         -- Categoría: horario, precios, ubicacion
    pregunta TEXT NOT NULL,                        -- La pregunta
    respuesta TEXT NOT NULL,                       -- La respuesta
    palabras_clave TEXT[],                         -- Palabras clave para buscar
    veces_consultada INTEGER DEFAULT 0,            -- Cuántas veces se usó
    activa BOOLEAN DEFAULT TRUE                    -- Si está activa
);
-- =====================================================
-- MÉTRICAS DEL CHATBOT
-- =====================================================
CREATE TABLE metricas_chatbot (
    id SERIAL PRIMARY KEY,
    fecha DATE DEFAULT CURRENT_DATE,               -- Fecha de las métricas
    total_conversaciones INTEGER DEFAULT 0,        -- Total de conversaciones
    tiempo_promedio_respuesta DECIMAL(8,2),        -- Tiempo promedio de respuesta
    tipo_consulta_frecuente VARCHAR(50),           -- Tipo de consulta más frecuente
    productos_mas_consultados INTEGER[],           -- Productos más consultados
    hora_pico INTEGER,                             -- Hora con más actividad (0-23)
    satisfaccion_promedio DECIMAL(3,2),            -- Satisfacción promedio del usuario
    UNIQUE(fecha)                                  -- Una fila por día
);
-- =====================================================
-- ÍNDICES PARA MEJORAR RENDIMIENTO
-- =====================================================

-- Índices para categorías y ocasiones
CREATE INDEX idx_categorias_activa ON categorias(activa);
CREATE INDEX idx_ocasiones_popularidad ON ocasiones(popularidad);

-- Índices para zonas de delivery
CREATE INDEX idx_zonas_activa ON zonas_delivery(activa);
CREATE INDEX idx_zonas_precio ON zonas_delivery(precio_envio);

-- Índices para productos
CREATE INDEX idx_productos_categoria ON productos(categoria_id);
CREATE INDEX idx_productos_ocasion ON productos(ocasion_id);

-- Índices para detalles de productos
CREATE INDEX idx_producto_detalle_producto ON producto_detalle(producto_id);
CREATE INDEX idx_producto_detalle_disponible ON producto_detalle(disponible);
CREATE INDEX idx_producto_detalle_stock ON producto_detalle(stock_disponible);
CREATE INDEX idx_producto_detalle_popularidad ON producto_detalle(popularidad);

-- Índices para precios
CREATE INDEX idx_precios_producto ON precios(producto_id);
CREATE INDEX idx_precios_activo ON precios(activo);
CREATE INDEX idx_precios_fechas ON precios(fecha_inicio, fecha_fin);

-- Índices para detalles de precios
CREATE INDEX idx_precio_detalle_precio ON precio_detalle(precio_id);
CREATE INDEX idx_precio_detalle_cantidad ON precio_detalle(cantidad_minima, cantidad_maxima);
CREATE INDEX idx_precio_detalle_activo ON precio_detalle(activo);

-- Índices para conversaciones
CREATE INDEX idx_conversaciones_session ON conversaciones(session_id);
CREATE INDEX idx_conversaciones_tipo ON conversaciones(tipo_consulta);
CREATE INDEX idx_conversaciones_fecha ON conversaciones(fecha);

-- Índices para preguntas frecuentes
CREATE INDEX idx_faqs_categoria ON preguntas_frecuentes(categoria);
CREATE INDEX idx_faqs_activa ON preguntas_frecuentes(activa);

-- Índice para métricas
CREATE INDEX idx_metricas_fecha ON metricas_chatbot(fecha);

-- Índices para búsqueda de texto
CREATE INDEX idx_productos_busqueda ON productos USING gin(to_tsvector('spanish', nombre || ' ' || COALESCE(descripcion, '')));
CREATE INDEX idx_faqs_palabras_clave ON preguntas_frecuentes USING gin(palabras_clave);
-- =====================================================
-- FUNCIONES PARA GESTIÓN DE STOCK Y DELIVERY
-- =====================================================

-- Función para verificar disponibilidad de stock
CREATE OR REPLACE FUNCTION verificar_stock(producto_id_param INTEGER, cantidad_solicitada INTEGER)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN (
        SELECT pd.stock_disponible >= cantidad_solicitada 
        FROM producto_detalle pd
        WHERE pd.producto_id = producto_id_param AND pd.disponible = true
    );
END;
$$ LANGUAGE plpgsql;

-- Función para obtener precio según cantidad
CREATE OR REPLACE FUNCTION obtener_precio_por_cantidad(producto_id_param INTEGER, cantidad INTEGER)
RETURNS TABLE(
    precio_unitario DECIMAL(10,2),
    descuento_porcentaje DECIMAL(5,2),
    precio_total DECIMAL(10,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        pde.precio_unitario,
        pde.descuento_porcentaje,
        (pde.precio_unitario * cantidad * (1 - pde.descuento_porcentaje/100)) as precio_total
    FROM precios p
    JOIN precio_detalle pde ON p.id = pde.precio_id
    WHERE p.producto_id = producto_id_param 
    AND p.activo = true
    AND pde.activo = true
    AND (p.fecha_fin IS NULL OR p.fecha_fin >= CURRENT_DATE)
    AND p.fecha_inicio <= CURRENT_DATE
    AND cantidad >= pde.cantidad_minima 
    AND (pde.cantidad_maxima IS NULL OR cantidad <= pde.cantidad_maxima)
    ORDER BY pde.cantidad_minima DESC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- Función para verificar si hay delivery disponible
CREATE OR REPLACE FUNCTION verificar_delivery_disponible(zona_nombre VARCHAR)
RETURNS TABLE(
    disponible BOOLEAN,
    precio_envio DECIMAL(10,2),
    tiempo_entrega INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        TRUE as disponible,
        z.precio_envio,
        z.tiempo_entrega_minutos
    FROM zonas_delivery z
    WHERE LOWER(z.nombre_zona) = LOWER(zona_nombre) 
    AND z.activa = true;
    
    -- Si no encuentra nada, devolver que no hay cobertura
    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, NULL::DECIMAL(10,2), NULL::INTEGER;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Función para calcular tiempo total (preparación + entrega)
CREATE OR REPLACE FUNCTION calcular_tiempo_total(producto_id_param INTEGER, zona_id_param INTEGER)
RETURNS INTEGER AS $$
BEGIN
    RETURN (
        SELECT pd.tiempo_preparacion_minutos + z.tiempo_entrega_minutos
        FROM producto_detalle pd, zonas_delivery z
        WHERE pd.producto_id = producto_id_param AND z.id = zona_id_param
    );
END;
$$ LANGUAGE plpgsql;

-- Función para actualizar contador de recomendaciones
CREATE OR REPLACE FUNCTION actualizar_recomendaciones()
RETURNS TRIGGER AS $$
BEGIN
    -- Si se mencionaron productos, actualizar su contador
    IF NEW.productos_mencionados IS NOT NULL AND array_length(NEW.productos_mencionados, 1) > 0 THEN
        UPDATE producto_detalle 
        SET veces_recomendado = veces_recomendado + 1 
        WHERE producto_id = ANY(NEW.productos_mencionados);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger que se ejecuta automáticamente
CREATE TRIGGER trigger_actualizar_recomendaciones
    AFTER INSERT ON conversaciones
    FOR EACH ROW
    EXECUTE FUNCTION actualizar_recomendaciones();
-- =====================================================
-- VISTAS PARA REPORTES Y ANÁLISIS
-- =====================================================

-- Vista: Productos completos con toda la información
CREATE VIEW productos_completos AS
SELECT 
    p.id,
    p.nombre,
    p.descripcion,
    c.nombre as categoria,
    o.nombre as ocasion,
    pd.stock_disponible,
    pd.tiempo_preparacion_minutos,
    pd.disponible,
    pd.popularidad,
    pd.veces_recomendado,
    pr.precio_base,
    pr.fecha_inicio as precio_desde,
    pr.fecha_fin as precio_hasta
FROM productos p
LEFT JOIN categorias c ON p.categoria_id = c.id
LEFT JOIN ocasiones o ON p.ocasion_id = o.id
LEFT JOIN producto_detalle pd ON p.id = pd.producto_id
LEFT JOIN precios pr ON p.id = pr.producto_id AND pr.activo = true
WHERE (pr.fecha_fin IS NULL OR pr.fecha_fin >= CURRENT_DATE)
AND pr.fecha_inicio <= CURRENT_DATE;

-- Vista: Productos disponibles en stock
CREATE VIEW productos_en_stock AS
SELECT 
    p.id,
    p.nombre,
    p.descripcion,
    c.nombre as categoria,
    o.nombre as ocasion,
    pd.stock_disponible,
    pd.tiempo_preparacion_minutos,
    pr.precio_base
FROM productos p
LEFT JOIN categorias c ON p.categoria_id = c.id
LEFT JOIN ocasiones o ON p.ocasion_id = o.id
LEFT JOIN producto_detalle pd ON p.id = pd.producto_id
LEFT JOIN precios pr ON p.id = pr.producto_id AND pr.activo = true
WHERE pd.disponible = true 
AND pd.stock_disponible > 0
AND (pr.fecha_fin IS NULL OR pr.fecha_fin >= CURRENT_DATE)
AND pr.fecha_inicio <= CURRENT_DATE
ORDER BY pd.popularidad DESC;

-- Vista: Precios con descuentos por cantidad
CREATE VIEW precios_con_descuentos AS
SELECT 
    p.nombre as producto,
    pr.precio_base,
    pde.cantidad_minima,
    pde.cantidad_maxima,
    pde.precio_unitario,
    pde.descuento_porcentaje,
    ROUND((pr.precio_base - pde.precio_unitario) * 100.0 / pr.precio_base, 2) as ahorro_porcentaje
FROM productos p
JOIN precios pr ON p.id = pr.producto_id
JOIN precio_detalle pde ON pr.id = pde.precio_id
WHERE pr.activo = true AND pde.activo = true
AND (pr.fecha_fin IS NULL OR pr.fecha_fin >= CURRENT_DATE)
AND pr.fecha_inicio <= CURRENT_DATE
ORDER BY p.nombre, pde.cantidad_minima;

-- Vista: Zonas de delivery disponibles
CREATE VIEW zonas_delivery_activas AS
SELECT 
    id,
    nombre_zona,
    descripcion,
    precio_envio,
    tiempo_entrega_minutos,
    CASE 
        WHEN tiempo_entrega_minutos <= 30 THEN 'Rápida'
        WHEN tiempo_entrega_minutos <= 60 THEN 'Normal'
        ELSE 'Lenta'
    END as velocidad_entrega
FROM zonas_delivery
WHERE activa = true
ORDER BY precio_envio;

-- Vista: Productos más populares
CREATE VIEW productos_populares AS
SELECT 
    p.id,
    p.nombre,
    pr.precio_base,
    pd.veces_recomendado,
    c.nombre as categoria,
    o.nombre as ocasion,
    pd.disponible
FROM productos p
LEFT JOIN categorias c ON p.categoria_id = c.id
LEFT JOIN ocasiones o ON p.ocasion_id = o.id
LEFT JOIN producto_detalle pd ON p.id = pd.producto_id
LEFT JOIN precios pr ON p.id = pr.producto_id AND pr.activo = true
WHERE (pr.fecha_fin IS NULL OR pr.fecha_fin >= CURRENT_DATE)
AND pr.fecha_inicio <= CURRENT_DATE
ORDER BY pd.veces_recomendado DESC;

-- Vista: Estadísticas diarias
CREATE VIEW estadisticas_diarias AS
SELECT 
    DATE(fecha) as dia,
    COUNT(*) as total_consultas,
    AVG(tiempo_respuesta_ms) as tiempo_promedio,
    COUNT(CASE WHEN usuario_satisfecho = true THEN 1 END) as usuarios_satisfechos,
    ROUND(COUNT(CASE WHEN usuario_satisfecho = true THEN 1 END) * 100.0 / COUNT(*), 2) as porcentaje_satisfaccion
FROM conversaciones
WHERE fecha >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY DATE(fecha)
ORDER BY dia DESC;

-- Vista: Tipos de consultas más frecuentes
CREATE VIEW consultas_frecuentes AS
SELECT 
    tipo_consulta,
    COUNT(*) as veces_consultada,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM conversaciones), 2) as porcentaje
FROM conversaciones
WHERE tipo_consulta IS NOT NULL
GROUP BY tipo_consulta
ORDER BY veces_consultada DESC;

-- =====================================================
-- COMENTARIOS PARA DOCUMENTACIÓN
-- =====================================================
COMMENT ON TABLE productos IS 'Información básica de productos';
COMMENT ON TABLE producto_detalle IS 'Detalles específicos de stock, tiempos y disponibilidad';
COMMENT ON TABLE precios IS 'Precios base de productos con validez temporal';
COMMENT ON TABLE precio_detalle IS 'Precios según cantidad comprada (descuentos por volumen)';
COMMENT ON TABLE zonas_delivery IS 'Zonas donde se realiza delivery con precios y tiempos';
COMMENT ON TABLE conversaciones IS 'Guarda todas las conversaciones del chatbot para análisis';
COMMENT ON TABLE reglas_recomendacion IS 'Reglas para recomendar productos según ocasión y presupuesto';
COMMENT ON TABLE metricas_chatbot IS 'Estadísticas diarias del rendimiento del chatbot';
COMMENT ON TABLE preguntas_frecuentes IS 'Respuestas automáticas para preguntas comunes';
