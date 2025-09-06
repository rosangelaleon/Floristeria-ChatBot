-- =====================================================
-- INFORMACIÓN DE LA TIENDA
-- =====================================================
INSERT INTO tienda_info (nombre_tienda, direccion, telefono, email, horario, whatsapp) VALUES
('Flores del Jardín', 'Alejo Garcia, Centro, Villarrica', '+595 541 123456', 'contacto@floresdeljardin.com', 'Lunes a Sábado: 8:00 - 18:00', '+595 981 654 321');

-- =====================================================
-- CATEGORÍAS DE PRODUCTOS
-- =====================================================
INSERT INTO categorias (nombre, descripcion, activa) VALUES
('Ramos de Rosas', 'Elegantes ramos de rosas en diferentes colores y tamaños', true),
('Bouquets Mixtos', 'Combinaciones hermosas de diferentes tipos de flores', true),
('Arreglos Florales', 'Arreglos en bases, jarrones y canastas decorativas', true),
('Plantas Decorativas', 'Plantas naturales para interior y exterior', true),
('Flores de Temporada', 'Flores frescas según la época del año', true),
('Coronas y Condolencias', 'Arreglos especiales para momentos de duelo', true);

-- =====================================================
-- OCASIONES ESPECIALES
-- =====================================================
INSERT INTO ocasiones (nombre, descripcion, precio_promedio, popularidad) VALUES
('Día de los Enamorados', 'Arreglos románticos para San Valentín', 85000, 10),
('Día de la Madre', 'Flores especiales para mamá', 65000, 9),
('Cumpleaños', 'Arreglos festivos para celebrar', 45000, 8),
('Aniversario', 'Flores para celebrar el amor duradero', 75000, 7),
('Graduación', 'Bouquets para celebrar logros académicos', 55000, 6),
('Nacimiento', 'Arreglos tiernos para dar la bienvenida', 50000, 6),
('Condolencias', 'Arreglos respetuosos para el duelo', 95000, 5),
('Día de la Mujer', 'Flores especiales para el 8 de marzo', 40000, 8),
('Bodas', 'Arreglos elegantes para ceremonias', 120000, 9),
('Solo porque sí', 'Flores para sorprender sin ocasión especial', 35000, 7);

-- =====================================================
-- ZONAS DE DELIVERY
-- =====================================================
INSERT INTO zonas_delivery (nombre_zona, descripcion, precio_envio, tiempo_entrega_minutos, activa) VALUES
('Centro de Villarrica', 'Zona céntrica de la ciudad', 8000, 30, true),
('Barrio San Miguel', 'Barrio de la ciudad', 12000, 45, true),
('Barrio Santa Lucia', 'Barrio de la ciudad', 12000, 45, true),
('Mbocayaty', 'Distrito cercano', 18000, 60, true),
('Felix Perez Cardozo', 'Distrito cercano', 20000, 75, true),
('Itapé', 'Distrito alejado', 25000, 90, true);

-- =====================================================
-- PRODUCTOS
-- =====================================================
INSERT INTO productos (nombre, descripcion, categoria_id, ocasion_id) VALUES
-- Ramos de Rosas (categoria_id = 1)
('Ramo de 12 Rosas Rojas', 'Clásico ramo de una docena de rosas rojas frescas con papel decorativo', 1, 1),
('Ramo de 6 Rosas Blancas', 'Elegante ramo de rosas blancas, símbolo de pureza y amor sincero', 1, 4),
('Ramo de 24 Rosas Rosadas', 'Impresionante ramo de dos docenas de rosas rosadas', 1, 2),
('Ramo de 3 Rosas Premium', 'Ramo íntimo de rosas de primera calidad', 1, 10),

-- Bouquets Mixtos (categoria_id = 2)
('Bouquet Primaveral', 'Mezcla de flores de temporada', 2, 3),
('Bouquet Tropical', 'Flores exóticas con colores vibrantes', 2, 3),
('Bouquet Clásico', 'Combinación tradicional de flores blancas y verdes', 2, 4),
('Bouquet Campestre', 'Flores silvestres', 2, 10),

-- Arreglos Florales (categoria_id = 3)
('Arreglo en Canasta Mediana', 'Hermoso arreglo en canasta de mimbre natural', 3, 2),
('Arreglo en Jarrón Cristal', 'Elegante arreglo en jarrón de cristal transparente', 3, 4),
('Arreglo Circular Mesa', 'Centro de mesa circular para celebraciones', 3, 9),
('Arreglo Alto Decorativo', 'Arreglo vertical para espacios amplios', 3, 5),

-- Plantas Decorativas (categoria_id = 4)
('Planta de Interior Pequeña', 'Planta decorativa para espacios internos', 4, 6),
('Planta Colgante', 'Planta en maceta colgante con soporte', 4, 10),
('Conjunto de Suculentas', 'Set de 3 suculentas en macetas decorativas', 4, 6),

-- Flores de Temporada (categoria_id = 5)
('Flores de Verano', 'Selección especial de flores de verano', 5, 10),
('Flores de Invierno', 'Arreglo con flores disponibles en invierno', 5, 8),

-- Coronas y Condolencias (categoria_id = 6)
('Corona Fúnebre Grande', 'Corona elegante para servicios fúnebres', 6, 7),
('Arreglo de Condolencias', 'Arreglo respetuoso en tonos blancos', 6, 7);

-- =====================================================
-- DETALLES DE PRODUCTOS
-- =====================================================
INSERT INTO producto_detalle (producto_id, stock_disponible, tiempo_preparacion_minutos, disponible, popularidad, veces_recomendado) VALUES
-- Ramos de Rosas
(1, 15, 20, true, 10, 45),  -- 12 Rosas Rojas
(2, 8, 15, true, 7, 23),    -- 6 Rosas Blancas
(3, 5, 30, true, 8, 18),    -- 24 Rosas Rosadas
(4, 20, 10, true, 6, 31),   -- 3 Rosas Premium

-- Bouquets Mixtos
(5, 12, 25, true, 8, 27),   -- Bouquet Primaveral
(6, 6, 30, true, 7, 15),    -- Bouquet Tropical
(7, 10, 20, true, 9, 33),   -- Bouquet Clásico
(8, 8, 25, true, 6, 12),    -- Bouquet Campestre

-- Arreglos Florales
(9, 7, 40, true, 8, 29),    -- Arreglo Canasta
(10, 4, 35, true, 9, 21),   -- Arreglo Jarrón
(11, 3, 45, true, 7, 8),    -- Arreglo Mesa
(12, 2, 50, true, 6, 5),    -- Arreglo Alto

-- Plantas Decorativas
(13, 15, 15, true, 5, 19),  -- Planta Interior
(14, 8, 20, true, 6, 11),   -- Planta Colgante
(15, 12, 10, true, 7, 16),  -- Suculentas

-- Flores de Temporada
(16, 10, 30, true, 7, 14),  -- Flores Verano
(17, 6, 35, false, 5, 7),   -- Flores Invierno (no disponible)

-- Coronas y Condolencias
(18, 3, 60, true, 4, 8),    -- Corona Fúnebre
(19, 5, 45, true, 5, 12);   -- Arreglo Condolencias

-- =====================================================
-- PRECIOS BASE
-- =====================================================
INSERT INTO precios (producto_id, precio_base, fecha_inicio, fecha_fin, activo) VALUES
-- Ramos de Rosas
(1, 75000, '2024-01-01', NULL, true),   -- 12 Rosas Rojas
(2, 45000, '2024-01-01', NULL, true),   -- 6 Rosas Blancas
(3, 140000, '2024-01-01', NULL, true),  -- 24 Rosas Rosadas
(4, 28000, '2024-01-01', NULL, true),   -- 3 Rosas Premium

-- Bouquets Mixtos
(5, 55000, '2024-01-01', NULL, true),   -- Bouquet Primaveral
(6, 68000, '2024-01-01', NULL, true),   -- Bouquet Tropical
(7, 62000, '2024-01-01', NULL, true),   -- Bouquet Clásico
(8, 48000, '2024-01-01', NULL, true),   -- Bouquet Campestre

-- Arreglos Florales
(9, 85000, '2024-01-01', NULL, true),   -- Arreglo Canasta
(10, 95000, '2024-01-01', NULL, true),  -- Arreglo Jarrón
(11, 120000, '2024-01-01', NULL, true), -- Arreglo Mesa
(12, 150000, '2024-01-01', NULL, true), -- Arreglo Alto

-- Plantas Decorativas
(13, 25000, '2024-01-01', NULL, true),  -- Planta Interior
(14, 35000, '2024-01-01', NULL, true),  -- Planta Colgante
(15, 42000, '2024-01-01', NULL, true),  -- Suculentas

-- Flores de Temporada
(16, 38000, '2024-01-01', NULL, true),  -- Flores Verano
(17, 42000, '2024-01-01', NULL, true),  -- Flores Invierno

-- Coronas y Condolencias
(18, 180000, '2024-01-01', NULL, true), -- Corona Fúnebre
(19, 95000, '2024-01-01', NULL, true);  -- Arreglo Condolencias

-- =====================================================
-- DETALLES DE PRECIOS POR CANTIDAD
-- =====================================================
INSERT INTO precio_detalle (precio_id, cantidad_minima, cantidad_maxima, precio_unitario, descuento_porcentaje, activo) VALUES
-- Para productos que se venden por unidad (la mayoría)
-- Ramo 12 Rosas Rojas
(1, 1, 1, 75000, 0, true),
(1, 2, 3, 72000, 4, true),    -- 4% descuento por 2-3 unidades
(1, 4, NULL, 68000, 9.3, true), -- 9.3% descuento por 4 o más

-- Ramo 6 Rosas Blancas
(2, 1, 1, 45000, 0, true),
(2, 2, 3, 43000, 4.4, true),
(2, 4, NULL, 40000, 11.1, true),

-- Ramo 24 Rosas Rosadas
(3, 1, 1, 140000, 0, true),
(3, 2, NULL, 130000, 7.1, true),

-- 3 Rosas Premium (producto económico)
(4, 1, 2, 28000, 0, true),
(4, 3, 5, 25000, 10.7, true),
(4, 6, NULL, 22000, 21.4, true),

-- Bouquet Primaveral
(5, 1, 1, 55000, 0, true),
(5, 2, NULL, 52000, 5.5, true),

-- Bouquet Tropical
(6, 1, 1, 68000, 0, true),
(6, 2, NULL, 64000, 5.9, true),

-- Bouquet Clásico
(7, 1, 1, 62000, 0, true),
(7, 2, NULL, 58000, 6.5, true),

-- Bouquet Campestre
(8, 1, 1, 48000, 0, true),
(8, 2, NULL, 45000, 6.3, true),

-- Arreglo Canasta
(9, 1, 1, 85000, 0, true),
(9, 2, NULL, 80000, 5.9, true),

-- Arreglo Jarrón
(10, 1, 1, 95000, 0, true),

-- Arreglo Mesa
(11, 1, 1, 120000, 0, true),

-- Arreglo Alto
(12, 1, 1, 150000, 0, true),

-- Planta Interior (producto que se puede vender en cantidad)
(13, 1, 2, 25000, 0, true),
(13, 3, 5, 22000, 12, true),
(13, 6, NULL, 20000, 20, true),

-- Planta Colgante
(14, 1, 1, 35000, 0, true),
(14, 2, NULL, 32000, 8.6, true),

-- Conjunto Suculentas
(15, 1, 1, 42000, 0, true),
(15, 2, NULL, 38000, 9.5, true),

-- Flores de Temporada
(16, 1, 1, 38000, 0, true),
(17, 1, 1, 42000, 0, true),

-- Corona y Condolencias (generalmente una unidad)
(18, 1, 1, 180000, 0, true),
(19, 1, 1, 95000, 0, true);

-- =====================================================
-- REGLAS DE RECOMENDACIÓN
-- =====================================================
INSERT INTO reglas_recomendacion (ocasion_id, precio_minimo, precio_maximo, productos_recomendados, score_algoritmo, activa) VALUES
-- Día de los Enamorados (ocasion_id = 1)
(1, 0, 50000, '{1,4}', 0.85, true),        -- Rosas rojas económicas
(1, 50000, 100000, '{1,2,7}', 0.92, true), -- Rango medio
(1, 100000, 999999, '{3,1,10}', 0.88, true), -- Rango alto

-- Día de la Madre (ocasion_id = 2)
(2, 0, 60000, '{5,8,13}', 0.90, true),     -- Económico
(2, 60000, 120000, '{9,7,6}', 0.95, true), -- Medio
(2, 120000, 999999, '{11,10,12}', 0.87, true), -- Alto

-- Cumpleaños (ocasion_id = 3)
(3, 0, 50000, '{4,5,8}', 0.88, true),      -- Económico
(3, 50000, 100000, '{1,6,7,9}', 0.91, true), -- Medio
(3, 100000, 999999, '{3,11,12}', 0.85, true), -- Alto

-- Aniversario (ocasion_id = 4)
(4, 0, 70000, '{2,7,4}', 0.87, true),      -- Económico
(4, 70000, 120000, '{1,10,9}', 0.93, true), -- Medio
(4, 120000, 999999, '{3,11,12}', 0.89, true), -- Alto

-- Graduación (ocasion_id = 5)
(5, 0, 60000, '{5,8,12}', 0.86, true),     -- Económico
(5, 60000, 999999, '{6,9,12}', 0.89, true), -- Medio-Alto

-- Nacimiento (ocasion_id = 6)
(6, 0, 50000, '{13,15,5}', 0.91, true),    -- Plantas y flores suaves
(6, 50000, 999999, '{2,7,9}', 0.88, true), -- Rango alto

-- Condolencias (ocasion_id = 7)
(7, 0, 120000, '{19}', 0.95, true),        -- Arreglo condolencias
(7, 120000, 999999, '{18,19}', 0.92, true), -- Corona + arreglo

-- Solo porque sí (ocasion_id = 10)
(10, 0, 40000, '{4,8,13}', 0.89, true),    -- Económico
(10, 40000, 80000, '{1,5,7}', 0.87, true), -- Medio
(10, 80000, 999999, '{9,10,6}', 0.84, true); -- Alto

-- =====================================================
-- PREGUNTAS FRECUENTES
-- =====================================================
INSERT INTO preguntas_frecuentes (categoria, pregunta, respuesta, palabras_clave, veces_consultada, activa) VALUES
('horario', '¿Cuáles son los horarios de atención?', 'Atendemos de Lunes a Sábado de 8:00 a 18:00 horas, y los Domingos de 9:00 a 15:00 horas.', '{horario,horarios,atencion,abren,cierran,domingo,lunes,sabado}', 15, true),

('horario', '¿Atienden los domingos?', 'No, los domingos nos tomamos un descanso.', '{domingo,domingos,atienden,abren}', 8, true),

('ubicacion', '¿Dónde están ubicados?', 'Nos encontramos en la calle Alejo Garcia, en el centro de Villarrica.', '{ubicacion,direccion,donde,estan,encuentran,centro}', 12, true),

('delivery', '¿Hacen delivery?', 'Sí, realizamos delivery a toda la zona de Villarrica y alrededores. El costo varía según la zona, desde 8.000 Gs.', '{delivery,envio,entregan,domicilio,llevan}', 20, true),

('delivery', '¿Cuánto cuesta el envío?', 'El costo del envío varía según la zona: Centro 8.000 Gs, barrios cercanos 12.000 Gs, y zonas más alejadas hasta 25.000 Gs.', '{costo,precio,envio,delivery,cuanto}', 18, true),

('delivery', '¿Cuánto tiempo demora la entrega?', 'El tiempo de entrega varía entre 30 y 90 minutos según la zona y el producto. Productos simples están listos en 15-30 minutos.', '{tiempo,demora,entrega,minutos,rapido}', 14, true),

('precios', '¿Cuáles son los precios de los ramos?', 'Nuestros ramos van desde 28.000 Gs (3 rosas) hasta 180.000 Gs (arreglos premium). Ramos populares rondan entre 45.000 y 85.000 Gs.', '{precios,precio,ramos,cuesta,cuestan,guaranies}', 25, true),

('precios', '¿Hay descuentos por cantidad?', 'Sí, ofrecemos descuentos del 4% al 21% cuando compras múltiples unidades del mismo producto.', '{descuento,descuentos,cantidad,multiple,varios}', 9, true),

('productos', '¿Qué tipos de flores tienen?', 'Tenemos rosas, bouquets mixtos, arreglos florales, plantas decorativas y flores de temporada. Especializados en rosas rojas, blancas y rosadas.', '{tipos,flores,tienen,que,productos,rosas}', 16, true),

('productos', '¿Tienen plantas además de flores?', 'Sí, también vendemos plantas decorativas para interior, plantas colgantes y conjuntos de suculentas.', '{plantas,suculentas,interior,decorativas}', 7, true),

('ocasiones', '¿Qué recomiendan para San Valentín?', 'Para San Valentín recomendamos nuestros ramos de rosas rojas de 12 o 24 unidades, y bouquets románticos clásicos.', '{san,valentin,enamorados,14,febrero,romantico}', 11, true),

('ocasiones', '¿Qué es bueno para el Día de la Madre?', 'Para el Día de la Madre sugerimos bouquets primaverales, arreglos en canasta, o combinaciones de flores con plantas.', '{dia,madre,mayo,mama}', 13, true),

('pagos', '¿Qué formas de pago aceptan?', 'Aceptamos efectivo, transferencias bancarias, tarjetas de débito y crédito. Para delivery, también pago contra entrega.', '{pago,pagos,efectivo,tarjeta,transferencia}', 10, true),

('contacto', '¿Cuál es el número de WhatsApp?', 'Nuestro WhatsApp es +595 981 654321. Por ahí pueden hacer pedidos y consultas directamente.', '{whatsapp,numero,telefono,contacto}', 17, true),

('stock', '¿Siempre tienen stock disponible?', 'Manejamos stock dinámico. Para productos específicos en cantidad, recomendamos consultar disponibilidad por WhatsApp.', '{stock,disponible,hay,tienen}', 6, true);

-- =====================================================
-- DATOS HISTÓRICOS DE CONVERSACIONES (EJEMPLOS)
-- =====================================================
INSERT INTO conversaciones (session_id, pregunta, respuesta, tipo_consulta, tiempo_respuesta_ms, productos_mencionados, usuario_satisfecho, fecha) VALUES
('sess_001', '¿Cuánto cuesta un ramo de 12 rosas rojas?', 'Un ramo de 12 rosas rojas cuesta 75.000 Gs. Si compras 2 o 3 ramos, el precio baja a 72.000 Gs por unidad.', 'precio', 450, '{1}', true, '2025-08-15 10:30:00'),

('sess_002', '¿Qué me recomiendan para un cumpleaños con presupuesto de 60.000?', 'Para cumpleaños con ese presupuesto te recomiendo el Bouquet Clásico (62.000 Gs) o el ramo de 12 rosas rojas (75.000 Gs, pero con descuento queda en 72.000 Gs si compras 2).', 'recomendacion', 680, '{7,1}', true, '2025-08-15 14:20:00'),

('sess_003', '¿Atienden los domingos?', 'No, los domingos nos tomamos un descanso para estar con nuestras familias.', 'horario', 320, NULL, true, '2025-08-16 09:15:00'),

('sess_004', '¿Hacen delivery a Mbocayaty?', 'Sí, hacemos delivery a Mbocayaty. El costo es de 18.000 Gs y demora aproximadamente 60 minutos.', 'delivery', 510, NULL, true, '2025-08-16 11:45:00'),

('sess_005', '¿Qué tienen para condolencias?', 'Para condolencias tenemos coronas fúnebres grandes (180.000 Gs) y arreglos especiales en tonos blancos (95.000 Gs).', 'recomendacion', 590, '{18,19}', true, '2025-08-16 16:30:00'),

('sess_006', '¿El bouquet tropical está disponible?', 'Sí, el Bouquet Tropical está disponible. Cuesta 68.000 Gs y tenemos 6 unidades en stock. Se prepara en 30 minutos.', 'stock', 410, '{6}', true, '2025-08-17 08:20:00');

-- =====================================================
-- MÉTRICAS INICIALES
-- =====================================================
INSERT INTO metricas_chatbot (fecha, total_conversaciones, tiempo_promedio_respuesta, tipo_consulta_frecuente, productos_mas_consultados, hora_pico, satisfaccion_promedio) VALUES
('2025-08-15', 15, 485.50, 'precio', '{1,7,6}', 14, 0.87),
('2025-08-16', 22, 450.20, 'recomendacion', '{1,18,19,6}', 11, 0.91),
('2025-08-17', 8, 420.10, 'stock', '{6,1,5}', 8, 0.95);
