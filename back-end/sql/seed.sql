-- ============================================================
-- QuetzalShop - DML (Datos de Prueba)
-- DBMS: PostgreSQL
-- ============================================================

-- ============================================================
-- ROLES
-- ============================================================
INSERT INTO roles (nombre, descripcion) VALUES
('Admin',       'Acceso total al sistema. Puede gestionar empleados, productos, ventas y compras.'),
('Cajero',      'Puede registrar ventas y clientes. No puede gestionar empleados ni compras.'),
('Bodeguero',   'Puede registrar compras y gestionar inventario. No puede registrar ventas.'),
('Gerente',     'Acceso de solo lectura a todo el sistema mas reportes. No puede modificar datos.'),
('Auditor',     'Acceso de solo lectura al historial de ventas, compras y reportes.');

-- ============================================================
-- METODOS_PAGO
-- ============================================================
INSERT INTO metodos_pago (metodo) VALUES
('Efectivo'),
('Tarjeta de credito'),
('Tarjeta de debito'),
('Transferencia bancaria');

-- ============================================================
-- CATEGORIAS
-- ============================================================
INSERT INTO categorias (nombre, descripcion) VALUES
('Electronica',         'Dispositivos electronicos, computadoras, accesorios tecnologicos'),
('Bebidas',             'Refrescos, agua, jugos y bebidas en general'),
('Ropa',                'Prendas de vestir para hombre, mujer y nino'),
('Alimentos',           'Productos alimenticios no perecederos'),
('Utiles de oficina',   'Articulos de papeleria y oficina'),
('Hogar',               'Articulos para el hogar y decoracion'),
('Deportes',            'Articulos deportivos y de recreacion'),
('Salud',               'Productos farmaceuticos y de cuidado personal');

-- ============================================================
-- PROVEEDORES
-- ============================================================
INSERT INTO proveedores (nombre, telefono, email, direccion) VALUES
('Tech Guatemala S.A.',                 '2222-1111', 'ventas@techgt.com',            'Zona 10, Ciudad de Guatemala'),
('Distribuidora Central S.A.',          '2222-2222', 'info@distcentral.com',         'Zona 1, Ciudad de Guatemala'),
('Importaciones GT',                    '2222-3333', 'compras@impgt.com',            'Zona 4, Ciudad de Guatemala'),
('Bebidas y Mas S.A.',                  '2222-4444', 'pedidos@bebidasmas.com',       'Zona 7, Ciudad de Guatemala'),
('Textiles del Norte S.A.',             '2222-5555', 'ventas@texnorte.com',          'Zona 18, Ciudad de Guatemala'),
('Alimentos Frescos del Campo S.A.',    '2222-6001', 'ventas@alimentosfrescos.com',  'Zona 3, Ciudad de Guatemala'),
('Ferreteria y Construccion Nacional',  '2222-6002', 'info@ferrconacional.com',      'Zona 6, Ciudad de Guatemala'),
('Farmacenter Guatemala S.A.',          '2222-6003', 'pedidos@farmacentergt.com',    'Zona 9, Ciudad de Guatemala'),
('Licores y Bebidas Premium S.A.',      '2222-6004', 'ventas@licorespremium.com',    'Zona 2, Ciudad de Guatemala'),
('Lacteos La Vaca S.A.',                '2222-6005', 'contacto@lacteosvaca.com',     'Zona 5, Ciudad de Guatemala'),
('Panaderia Industrial Guatemala',      '2222-6006', 'pedidos@pangtq.com',           'Zona 8, Ciudad de Guatemala'),
('Distribuidora del Pacifico S.A.',     '2222-6007', 'info@distpacifico.com',        'Zona 11, Ciudad de Guatemala'),
('Mayoreo Chapalteca S.A.',             '2222-6008', 'ventas@mayoreochap.com',       'Zona 12, Ciudad de Guatemala'),
('Importadora Pacific Rim GT',          '2222-6009', 'compras@pacificrimgt.com',     'Zona 13, Ciudad de Guatemala'),
('Verduras y Frutas El Campo',          '2222-6010', 'pedidos@elcampogt.com',        'Zona 14, Ciudad de Guatemala'),
('Confecciones Moda Guatemala S.A.',    '2222-6011', 'ventas@modagt.com',            'Zona 15, Ciudad de Guatemala'),
('Papeleria y Arte El Estudiante',      '2222-6012', 'info@estudiante.com',          'Zona 16, Ciudad de Guatemala'),
('Electrodomesticos del Istmo S.A.',    '2222-6013', 'ventas@electristmo.com',       'Zona 17, Ciudad de Guatemala'),
('Cosmeticos Bella Guatemala S.A.',     '2222-6014', 'contacto@bellagt.com',         'Zona 19, Ciudad de Guatemala'),
('Suplementos y Salud Pro S.A.',        '2222-6015', 'ventas@saludpro.com',          'Zona 21, Ciudad de Guatemala'),
('Calzado Chapincito S.A.',             '2222-6016', 'pedidos@calzadochap.com',      'Zona 1, Mixco'),
('Muebles y Decoracion del Hogar',      '2222-6017', 'info@muebleshogar.com',        'Zona 4, Mixco'),
('Jugueteria Infantil GT S.A.',         '2222-6018', 'ventas@jugueteriagt.com',      'Zona 1, Villa Nueva'),
('Herramientas y Maquinaria GT',        '2222-6019', 'contacto@herramientasgt.com',  'Zona 2, San Miguel Petapa'),
('Distribuidora Norte S.A.',            '2222-6020', 'ventas@distnorte.com',         'Zona 1, Quetzaltenango');

-- ============================================================
-- USUARIOS
-- ============================================================
INSERT INTO usuarios (email, password_hash, rol_id, creado) VALUES
('admin@quetzalshop.com',       '$2b$12$SIvkj1HLtieNh2bh8lU8VuJLEuOxmARbIlKaam1lY2E.khYX.A7Qi', 1, '2025-01-10 08:00:00'),
('cajero1@quetzalshop.com',     '$2b$12$Ff7M.J/Sf9chtcXzXwSa1Oaj6Nd61DhYv83vkHFFmy1tkpqF/fwwO', 2, '2025-01-10 08:05:00'),
('cajero2@quetzalshop.com',     '$2b$12$Ff7M.J/Sf9chtcXzXwSa1Oaj6Nd61DhYv83vkHFFmy1tkpqF/fwwO', 2, '2025-01-10 08:10:00'),
('cajero3@quetzalshop.com',     '$2b$12$Ff7M.J/Sf9chtcXzXwSa1Oaj6Nd61DhYv83vkHFFmy1tkpqF/fwwO', 2, '2025-02-01 09:00:00'),
('bodeguero1@quetzalshop.com',  '$2b$12$EKzkgNfPIff5eMz020oxveGozoDmDGL/tJXGLXzfwuwahucPAKMoq', 3, '2025-01-10 08:15:00'),
('bodeguero2@quetzalshop.com',  '$2b$12$EKzkgNfPIff5eMz020oxveGozoDmDGL/tJXGLXzfwuwahucPAKMoq', 3, '2025-01-10 08:20:00'),
('cajero4@quetzalshop.com',     '$2b$12$Ff7M.J/Sf9chtcXzXwSa1Oaj6Nd61DhYv83vkHFFmy1tkpqF/fwwO', 2, '2025-03-01 09:00:00'),
('cajero5@quetzalshop.com',     '$2b$12$Ff7M.J/Sf9chtcXzXwSa1Oaj6Nd61DhYv83vkHFFmy1tkpqF/fwwO', 2, '2025-03-15 09:00:00'),
('bodeguero3@quetzalshop.com',  '$2b$12$EKzkgNfPIff5eMz020oxveGozoDmDGL/tJXGLXzfwuwahucPAKMoq', 3, '2025-04-01 09:00:00'),
('admin2@quetzalshop.com',      '$2b$12$SIvkj1HLtieNh2bh8lU8VuJLEuOxmARbIlKaam1lY2E.khYX.A7Qi', 1, '2025-04-15 09:00:00'),
('cajero6@quetzalshop.com',     '$2b$12$Ff7M.J/Sf9chtcXzXwSa1Oaj6Nd61DhYv83vkHFFmy1tkpqF/fwwO', 2, '2025-05-01 09:00:00'),
('cajero7@quetzalshop.com',     '$2b$12$Ff7M.J/Sf9chtcXzXwSa1Oaj6Nd61DhYv83vkHFFmy1tkpqF/fwwO', 2, '2025-05-15 09:00:00'),
('cajero8@quetzalshop.com',     '$2b$12$Ff7M.J/Sf9chtcXzXwSa1Oaj6Nd61DhYv83vkHFFmy1tkpqF/fwwO', 2, '2025-06-01 09:00:00'),
('cajero9@quetzalshop.com',     '$2b$12$Ff7M.J/Sf9chtcXzXwSa1Oaj6Nd61DhYv83vkHFFmy1tkpqF/fwwO', 2, '2025-06-15 09:00:00'),
('cajero10@quetzalshop.com',    '$2b$12$Ff7M.J/Sf9chtcXzXwSa1Oaj6Nd61DhYv83vkHFFmy1tkpqF/fwwO', 2, '2025-07-01 09:00:00'),
('cajero11@quetzalshop.com',    '$2b$12$Ff7M.J/Sf9chtcXzXwSa1Oaj6Nd61DhYv83vkHFFmy1tkpqF/fwwO', 2, '2025-07-15 09:00:00'),
('cajero12@quetzalshop.com',    '$2b$12$Ff7M.J/Sf9chtcXzXwSa1Oaj6Nd61DhYv83vkHFFmy1tkpqF/fwwO', 2, '2025-08-01 09:00:00'),
('cajero13@quetzalshop.com',    '$2b$12$Ff7M.J/Sf9chtcXzXwSa1Oaj6Nd61DhYv83vkHFFmy1tkpqF/fwwO', 2, '2025-08-15 09:00:00'),
('bodeguero4@quetzalshop.com',  '$2b$12$EKzkgNfPIff5eMz020oxveGozoDmDGL/tJXGLXzfwuwahucPAKMoq', 3, '2025-05-01 09:00:00'),
('bodeguero5@quetzalshop.com',  '$2b$12$EKzkgNfPIff5eMz020oxveGozoDmDGL/tJXGLXzfwuwahucPAKMoq', 3, '2025-05-15 09:00:00'),
('bodeguero6@quetzalshop.com',  '$2b$12$EKzkgNfPIff5eMz020oxveGozoDmDGL/tJXGLXzfwuwahucPAKMoq', 3, '2025-06-01 09:00:00'),
('bodeguero7@quetzalshop.com',  '$2b$12$EKzkgNfPIff5eMz020oxveGozoDmDGL/tJXGLXzfwuwahucPAKMoq', 3, '2025-06-15 09:00:00'),
('bodeguero8@quetzalshop.com',  '$2b$12$EKzkgNfPIff5eMz020oxveGozoDmDGL/tJXGLXzfwuwahucPAKMoq', 3, '2025-07-01 09:00:00'),
('bodeguero9@quetzalshop.com',  '$2b$12$EKzkgNfPIff5eMz020oxveGozoDmDGL/tJXGLXzfwuwahucPAKMoq', 3, '2025-07-15 09:00:00'),
('admin3@quetzalshop.com',      '$2b$12$SIvkj1HLtieNh2bh8lU8VuJLEuOxmARbIlKaam1lY2E.khYX.A7Qi', 1, '2025-08-01 09:00:00'),
('gerente@quetzalshop.com',    '$2b$12$PXHaVANaS1wV40K4Gkc1..p6l6sv.sHUMcuquPHkl.sUEJb6lz/ei', 4, '2025-01-10 08:00:00'),
('auditor@quetzalshop.com',    '$2b$12$InQdAvLU8oFHIkXJt7JZNut7VwnBHZlQU57SUWwpFIZH8YYbnqf1i', 5, '2025-01-10 08:00:00');

-- ============================================================
-- EMPLEADOS
-- ============================================================
INSERT INTO empleados (usuario_id, dpi, nombre, telefono, cargo, fecha_contrato, estado) VALUES
(1,  '1234567890101', 'Carlos Mendoza Lopez',     '5555-0001', 'Gerente General',      '2024-01-15', 'activo'),
(2,  '2345678901202', 'Maria Lopez Garcia',       '5555-0002', 'Cajera Principal',     '2024-03-01', 'activo'),
(3,  '3456789012303', 'Jose Ramirez Cruz',        '5555-0003', 'Cajero',               '2024-06-15', 'activo'),
(4,  '4567890123404', 'Ana Gonzalez Perez',       '5555-0004', 'Cajera',               '2025-02-01', 'activo'),
(5,  '5678901234505', 'Luis Perez Morales',       '5555-0005', 'Bodeguero Principal',  '2024-02-20', 'activo'),
(6,  '6789012345606', 'Sofia Martinez Ruiz',      '5555-0006', 'Bodeguera',            '2024-07-01', 'activo'),
(7,  '7890123456707', 'Diego Torres Soto',        '5555-0007', 'Cajero',               '2025-03-01', 'activo'),
(8,  '8901234567808', 'Elena Flores Mendez',      '5555-0008', 'Cajera',               '2025-03-15', 'activo'),
(9,  '9012345678909', 'Roberto Diaz Castillo',    '5555-0009', 'Bodeguero',            '2025-04-01', 'activo'),
(10, '0123456789010', 'Patricia Ruiz Vasquez',    '5555-0010', 'Administradora',       '2025-04-15', 'activo'),
(11, '1122334455601', 'Marcos Antonio Aju Coy',   '5555-0011', 'Cajero',               '2025-05-01', 'activo'),
(12, '2233445566702', 'Daniela Xiomara Pop Tut',  '5555-0012', 'Cajera',               '2025-05-15', 'activo'),
(13, '3344556677803', 'William Eduardo Cux Xol',  '5555-0013', 'Cajero',               '2025-06-01', 'activo'),
(14, '4455667788904', 'Flor de Maria Tahay Ixim', '5555-0014', 'Cajera',               '2025-06-15', 'activo'),
(15, '5566778899005', 'Christian Rafael Caal Tec','5555-0015', 'Cajero',               '2025-07-01', 'activo'),
(16, '6677889900106', 'Wendy Paola Choc Cucul',   '5555-0016', 'Cajera',               '2025-07-15', 'activo'),
(17, '7788990011207', 'Kevin Estuardo Batz Soc',  '5555-0017', 'Cajero',               '2025-08-01', 'activo'),
(18, '8899001122308', 'Brenda Liseth Quej Sam',   '5555-0018', 'Cajera',               '2025-08-15', 'activo'),
(19, '9900112233409', 'Erick Fernando Maquin Pol','5555-0019', 'Bodeguero',            '2025-05-01', 'activo'),
(20, '0011223344510', 'Yesenia Maribel Tzul Mux', '5555-0020', 'Bodeguera',            '2025-05-15', 'activo'),
(21, '1122334455611', 'Jonathan David Gomez Caal','5555-0021', 'Bodeguero',            '2025-06-01', 'activo'),
(22, '2233445566712', 'Sandra Maricela Cucul Pop','5555-0022', 'Bodeguera',            '2025-06-15', 'activo'),
(23, '3344556677813', 'Hector Ernesto Coyote Tun','5555-0023', 'Bodeguero',            '2025-07-01', 'activo'),
(24, '4455667788914', 'Lorena Beatriz Tux Choc',  '5555-0024', 'Bodeguera',            '2025-07-15', 'activo'),
(25, '5566778899015', 'Miguel Angel Puac Xo',     '5555-0025', 'Administrador',        '2025-08-01', 'activo'),
(26, '6677889900201', 'Ricardo Estrada Molina',   '5555-0026', 'Gerente de Operaciones','2024-01-10', 'activo'),
(27, '7788990011302', 'Claudia Barrios Solano',   '5555-0027', 'Auditora Interna',      '2024-01-10', 'activo');

-- ============================================================
-- PRODUCTOS
-- ============================================================
INSERT INTO productos (nombre, descripcion, precio, stock, stock_minimo, categoria_id) VALUES
('Laptop Dell Inspiron 15',     'Laptop 15 pulgadas, Intel Core i5, 8GB RAM, 256GB SSD, color negro',  4500.00, 15,  3,  1),
('Monitor Samsung 24',          'Monitor Full HD, 24 pulgadas, panel IPS, color negro',                 1800.00, 10,  2,  1),
('Mouse Logitech Inalambrico',  'Mouse ergonomico inalambrico, receptor USB nano, color negro',         250.00,  50,  10, 1),
('Teclado Mecanico Redragon',   'Teclado mecanico RGB, switches rojos, layout espanol',                 450.00,  30,  5,  1),
('Audifonos Sony WH1000XM4',    'Audifonos over-ear, cancelacion de ruido, Bluetooth 5.0',             1800.00, 12,  3,  1),
('Agua Pura Fuente Pura 500ml', 'Agua purificada natural, presentacion 500ml',                         5.00,    500, 50, 2),
('Coca Cola 350ml',             'Refresco de cola, lata 350ml',                                        7.00,    300, 50, 2),
('Jugo Del Valle Naranja 1L',   'Jugo de naranja natural, botella 1 litro',                            18.00,   150, 30, 2),
('Red Bull 250ml',              'Bebida energizante, lata 250ml',                                      22.00,   100, 20, 2),
('Camisa Polo Ralph Lauren',    'Camisa polo de algodon 100%, talla M, color azul marino',             350.00,  40,  8,  3),
('Pantalon Jeans 501',          'Pantalon de mezclilla, corte recto, talla 32x30',                     480.00,  35,  5,  3),
('Arroz Diana 1kg',             'Arroz blanco grano largo, bolsa 1 kilogramo',                         12.00,   200, 30, 4),
('Frijoles Ducal 1kg',          'Frijoles negros seleccionados, bolsa 1 kilogramo',                    15.00,   180, 25, 4),
('Aceite Mazola 1L',            'Aceite vegetal de maiz, botella 1 litro',                             28.00,   120, 20, 4),
('Lapicero BIC Azul',           'Lapicero de tinta azul, punta fina 0.5mm',                            3.00,    600, 50, 5),
('Cuaderno Universitario 100h', 'Cuaderno cuadriculado 100 hojas, pasta dura',                         25.00,   200, 30, 5),
('Folder Manila Carta',         'Folder de manila color beige, tamano carta',                          2.00,    400, 50, 5),
('Lampara LED de Escritorio',   'Lampara LED con brazo flexible, 3 niveles de brillo, USB',            180.00,  25,  5,  6),
('Silla Ejecutiva Ergonomica',  'Silla de oficina con altura ajustable, apoyabrazos, color negro',     1200.00, 8,   2,  6),
('Balon de Futbol Adidas',      'Balon oficial tamano 5, material sintetico premium',                  150.00,  20,  5,  7),
('Pesas de Hierro 5kg par',     'Par de pesas de hierro fundido, 5 kilogramos cada una',               200.00,  15,  3,  7),
('Acetaminofen 500mg',          'Analgesico y antipiretico, caja 20 tabletas, 500mg',                  45.00,   80,  15, 8),
('Alcohol Isopropilico 70%',    'Alcohol antiseptico 70%, frasco 500ml',                               32.00,   60,  10, 8),
('Jabon Antibacterial Dettol',  'Jabon liquido antibacterial, botella 500ml',                          38.00,   90,  15, 8),
('Cable HDMI 2m',               'Cable HDMI 4K ultra HD, 2 metros, conectores dorados',                65.00,   45,  10, 1);

-- ============================================================
-- PRODUCTO_PROVEEDOR
-- ============================================================
INSERT INTO producto_proveedor (producto_id, proveedor_id, precio_costo) VALUES
(1,  1, 3500.00),
(2,  1, 1400.00),
(3,  1, 150.00),
(4,  1, 320.00),
(5,  1, 1400.00),
(6,  4, 2.50),
(7,  4, 4.00),
(8,  4, 12.00),
(9,  4, 16.00),
(10, 5, 200.00),
(11, 5, 280.00),
(12, 2, 8.00),
(13, 2, 10.00),
(14, 2, 20.00),
(15, 3, 1.50),
(16, 3, 16.00),
(17, 3, 1.00),
(18, 1, 120.00),
(19, 2, 800.00),
(20, 5, 90.00),
(21, 2, 120.00),
(22, 2, 28.00),
(23, 2, 20.00),
(24, 2, 24.00),
(25, 1, 45.00);

-- ============================================================
-- CLIENTES
-- ============================================================
INSERT INTO clientes (nombre, nit, telefono, direccion) VALUES
('Juan Carlos Morales',     '1234567-8', '5555-1001', 'Zona 1, Ciudad de Guatemala'),
('Maria Fernanda Garcia',   '2345678-9', '5555-1002', 'Zona 10, Ciudad de Guatemala'),
('Roberto Alvarez Soto',    '3456789-0', '5555-1003', 'Zona 7, Ciudad de Guatemala'),
('Claudia Herrera Lopez',   '4567890-1', '5555-1004', 'Zona 14, Ciudad de Guatemala'),
('Pedro Pablo Ruiz',        '5678901-2', '5555-1005', 'Zona 11, Ciudad de Guatemala'),
('Lucia Mendoza Castro',    '6789012-3', '5555-1006', 'Zona 6, Ciudad de Guatemala'),
('Andres Castillo Diaz',    '7890123-4', '5555-1007', 'Zona 15, Ciudad de Guatemala'),
('Gabriela Torres Cruz',    '8901234-5', '5555-1008', 'Zona 3, Ciudad de Guatemala'),
('Fernando Lopez Paz',      '9012345-6', '5555-1009', 'Zona 12, Ciudad de Guatemala'),
('Valeria Sanchez Mora',    '0123456-7', '5555-1010', 'Zona 18, Ciudad de Guatemala'),
('Marco Antonio Diaz',      '1234567-9', '5555-1011', 'Zona 4, Ciudad de Guatemala'),
('Isabella Flores Reyes',   '2345678-0', '5555-1012', 'Zona 9, Ciudad de Guatemala'),
('Daniel Reyes Martinez',   '3456789-1', '5555-1013', 'Zona 2, Ciudad de Guatemala'),
('Camila Vasquez Perez',    '4567890-2', '5555-1014', 'Zona 16, Ciudad de Guatemala'),
('Hector Juarez Mendez',    '5678901-3', '5555-1015', 'Zona 5, Ciudad de Guatemala'),
('Natalia Cifuentes Ruiz',  '6789012-4', '5555-1016', 'Zona 13, Ciudad de Guatemala'),
('Emilio Aguilar Soto',     '7890123-5', '5555-1017', 'Zona 8, Ciudad de Guatemala'),
('Alejandra Moreno Lopez',  '8901234-6', '5555-1018', 'Zona 17, Ciudad de Guatemala'),
('Sebastian Ramos Diaz',    '9012345-7', '5555-1019', 'Zona 19, Ciudad de Guatemala'),
('Veronica Chavez Garcia',  '0123456-8', '5555-1020', 'Zona 21, Ciudad de Guatemala'),
('Oscar Hernandez Cruz',    'CF',        '5555-1021', 'Zona 1, Ciudad de Guatemala'),
('Paola Estrada Mendez',    '1234560-1', '5555-1022', 'Zona 10, Ciudad de Guatemala'),
('Javier Lemus Castillo',   '2345671-2', '5555-1023', 'Zona 7, Ciudad de Guatemala'),
('Karla Aju Lopez',         '3456782-3', '5555-1024', 'Zona 14, Ciudad de Guatemala'),
('Rodrigo Samayoa Perez',   '4567893-4', '5555-1025', 'Zona 11, Ciudad de Guatemala');

-- ============================================================
-- VENTAS
-- ============================================================
INSERT INTO ventas (cliente_id, empleado_id, metodo_pago_id, fecha, total, descuento) VALUES
(1,  2, 1, '2026-04-01 09:15:00', 4750.00, 0.00),
(2,  2, 2, '2026-04-01 10:30:00', 25.00,   0.00),
(3,  3, 1, '2026-04-02 11:00:00', 1800.00, 0.00),
(4,  2, 3, '2026-04-02 14:00:00', 700.00,  0.00),
(5,  3, 1, '2026-04-03 09:00:00', 335.00,  15.00),
(6,  2, 4, '2026-04-03 11:30:00', 350.00,  0.00),
(7,  3, 1, '2026-04-04 10:00:00', 4500.00, 0.00),
(8,  4, 2, '2026-04-04 15:00:00', 63.00,   0.00),
(9,  3, 1, '2026-04-05 09:30:00', 480.00,  0.00),
(10, 2, 3, '2026-04-05 12:00:00', 1200.00, 0.00),
(11, 4, 1, '2026-04-06 10:00:00', 55.00,   0.00),
(12, 3, 2, '2026-04-07 14:30:00', 1800.00, 0.00),
(13, 2, 1, '2026-04-07 09:00:00', 350.00,  0.00),
(14, 4, 3, '2026-04-08 11:00:00', 180.00,  0.00),
(15, 3, 1, '2026-04-08 10:30:00', 2050.00, 0.00),
(16, 2, 4, '2026-04-09 14:00:00', 150.00,  0.00),
(17, 4, 1, '2026-04-09 09:00:00', 575.00,  0.00),
(18, 3, 2, '2026-04-10 11:30:00', 38.00,   0.00),
(19, 2, 1, '2026-04-10 10:00:00', 4565.00, 0.00),
(20, 4, 3, '2026-04-11 15:00:00', 66.00,   0.00),
(21, 3, 1, '2026-04-12 09:30:00', 200.00,  0.00),
(22, 2, 2, '2026-04-12 12:00:00', 450.00,  0.00),
(23, 4, 1, '2026-04-13 10:00:00', 199.00,  0.00),
(24, 3, 3, '2026-04-14 14:30:00', 65.00,   0.00),
(25, 2, 1, '2026-04-15 09:00:00', 750.00,  50.00);

-- ============================================================
-- ITEMS_VENTA
-- ============================================================
INSERT INTO items_venta (venta_id, producto_id, cantidad, precio_unitario_historico, subtotal) VALUES
(1,  1,  1, 4500.00, 4500.00),
(1,  3,  1, 250.00,  250.00),
(2,  6,  5, 5.00,    25.00),
(3,  2,  1, 1800.00, 1800.00),
(4,  4,  1, 450.00,  450.00),
(4,  3,  1, 250.00,  250.00),
(5,  10, 1, 350.00,  350.00),
(6,  10, 1, 350.00,  350.00),
(7,  1,  1, 4500.00, 4500.00),
(8,  7,  5, 7.00,    35.00),
(8,  6,  4, 5.00,    20.00),
(9,  11, 1, 480.00,  480.00),
(10, 19, 1, 1200.00, 1200.00),
(11, 15, 5, 3.00,    15.00),
(11, 17, 20, 2.00,   40.00),
(12, 5,  1, 1800.00, 1800.00),
(13, 20, 1, 150.00,  150.00),
(13, 21, 1, 200.00,  200.00),
(14, 18, 1, 180.00,  180.00),
(15, 2,  1, 1800.00, 1800.00),
(15, 3,  1, 250.00,  250.00),
(16, 20, 1, 150.00,  150.00),
(17, 4,  1, 450.00,  450.00),
(17, 16, 5, 25.00,   125.00),
(18, 24, 1, 38.00,   38.00),
(19, 1,  1, 4500.00, 4500.00),
(19, 25, 1, 65.00,   65.00),
(20, 12, 3, 12.00,   36.00),
(20, 13, 2, 15.00,   30.00),
(21, 21, 1, 200.00,  200.00),
(22, 4,  1, 450.00,  450.00),
(23, 22, 3, 45.00,   135.00),
(23, 23, 1, 32.00,   32.00),
(24, 25, 1, 65.00,   65.00),
(25, 10, 2, 350.00,  700.00),
(25, 16, 2, 25.00,   50.00),
(8,  9,  1, 8.00,    8.00);

-- ============================================================
-- COMPRAS
-- ============================================================
INSERT INTO compras (empleado_id, fecha, total, numero_factura) VALUES
(5, '2026-03-01 08:00:00', 45000.00, 'FAC-2026-0001'),
(5, '2026-03-05 08:00:00', 2800.00,  'FAC-2026-0002'),
(5, '2026-03-10 08:00:00', 2450.00,  'FAC-2026-0003'),
(6, '2026-03-15 08:00:00', 6800.00,  'FAC-2026-0004'),
(5, '2026-03-20 08:00:00', 2650.00,  'FAC-2026-0005'),
(6, '2026-04-01 08:00:00', 31200.00, 'FAC-2026-0006'),
(5, '2026-04-05 08:00:00', 3200.00,  'FAC-2026-0007'),
(9, '2026-04-08 08:00:00', 2000.00,  'FAC-2026-0008'),
(6, '2026-04-10 08:00:00', 9300.00,  'FAC-2026-0009'),
(5, '2026-04-12 08:00:00', 4400.00,  'FAC-2026-0010'),
(9, '2026-04-14 08:00:00', 900.00,   'FAC-2026-0011'),
(6, '2026-04-15 08:00:00', 3600.00,  'FAC-2026-0012'),
(5, '2026-03-03 08:00:00', 2500.00,  'FAC-2026-0013'),
(9, '2026-03-08 08:00:00', 1600.00,  'FAC-2026-0014'),
(6, '2026-03-12 08:00:00', 4000.00,  'FAC-2026-0015'),
(5, '2026-03-18 08:00:00', 2800.00,  'FAC-2026-0016'),
(9, '2026-03-22 08:00:00', 3200.00,  'FAC-2026-0017'),
(6, '2026-03-25 08:00:00', 1400.00,  'FAC-2026-0018'),
(5, '2026-03-28 08:00:00', 2000.00,  'FAC-2026-0019'),
(9, '2026-04-02 08:00:00', 900.00,   'FAC-2026-0020'),
(6, '2026-04-04 08:00:00', 1200.00,  'FAC-2026-0021'),
(5, '2026-04-06 08:00:00', 3800.00,  'FAC-2026-0022'),
(9, '2026-04-09 08:00:00', 2100.00,  'FAC-2026-0023'),
(6, '2026-04-11 08:00:00', 4400.00,  'FAC-2026-0024'),
(5, '2026-04-13 08:00:00', 1500.00,  'FAC-2026-0025');

-- ============================================================
-- ITEMS_COMPRA
-- ============================================================
INSERT INTO items_compra (compra_id, producto_id, proveedor_id, cantidad, precio_costo_historico, subtotal) VALUES
(1,  1,  1, 10,  3500.00, 35000.00),
(1,  2,  1, 5,   1400.00, 7000.00),
(1,  3,  1, 20,  150.00,  3000.00),
(2,  12, 2, 100, 8.00,    800.00),
(2,  13, 2, 100, 10.00,   1000.00),
(2,  14, 2, 50,  20.00,   1000.00),
(3,  6,  4, 500, 2.50,    1250.00),
(3,  7,  4, 300, 4.00,    1200.00),
(4,  10, 5, 20,  200.00,  4000.00),
(4,  11, 5, 10,  280.00,  2800.00),
(5,  15, 3, 500, 1.50,    750.00),
(5,  16, 3, 100, 16.00,   1600.00),
(5,  17, 3, 300, 1.00,    300.00),
(6,  1,  1, 8,   3500.00, 28000.00),
(6,  4,  1, 10,  320.00,  3200.00),
(7,  22, 2, 50,  28.00,   1400.00),
(7,  23, 2, 30,  20.00,   600.00),
(7,  24, 2, 50,  24.00,   1200.00),
(8,  8,  4, 100, 12.00,   1200.00),
(8,  9,  4, 50,  16.00,   800.00),
(9,  5,  1, 6,   1400.00, 8400.00),
(9,  25, 1, 20,  45.00,   900.00),
(10, 19, 2, 4,   800.00,  3200.00),
(10, 18, 1, 10,  120.00,  1200.00),
(11, 20, 5, 10,  90.00,   900.00);

-- ============================================================
-- PRODUCTOS ADICIONALES
-- ============================================================
INSERT INTO productos (nombre, descripcion, precio, stock, stock_minimo, categoria_id) VALUES
('Disco Duro SSD Kingston 512GB', 'SSD SATA 2.5 pulgadas, 512GB, lectura 550MB/s, escritura 500MB/s', 650.00, 2,  5, 1),
('Webcam Logitech C920',          'Camara web Full HD 1080p, microfono integrado, USB',               480.00, 9,  4, 1);
-- producto_id 26: stock=2, stock_minimo=5 → STOCK BAJO
-- producto_id 27: stock=9, stock_minimo=4 → ok

INSERT INTO producto_proveedor (producto_id, proveedor_id, precio_costo) VALUES
(26, 1, 480.00),
(27, 1, 350.00);

-- ============================================================
-- COMPRAS DE MAYO 2026
-- ============================================================
INSERT INTO compras (empleado_id, fecha, total, numero_factura) VALUES
(5, '2026-05-02 08:30:00', 2850.00, 'FAC-2026-0026'),
(6, '2026-05-06 09:00:00', 2400.00, 'FAC-2026-0027'),
(9, '2026-05-09 08:00:00', 6235.00, 'FAC-2026-0028'),
(5, '2026-05-13 08:00:00', 2320.00, 'FAC-2026-0029'),
(6, '2026-05-16 09:30:00', 1450.00, 'FAC-2026-0030');

INSERT INTO items_compra (compra_id, producto_id, proveedor_id, cantidad, precio_costo_historico, subtotal) VALUES
-- Compra 26: restock bebidas
(26, 6,  4, 500, 2.50,    1250.00),
(26, 7,  4, 200, 4.00,     800.00),
(26, 9,  4, 50,  16.00,    800.00),
-- Compra 27: restock alimentos
(27, 12, 2, 100, 8.00,     800.00),
(27, 13, 2, 80,  10.00,    800.00),
(27, 14, 2, 40,  20.00,    800.00),
-- Compra 28: restock electronica
(28, 3,  1, 20,  150.00,  3000.00),
(28, 4,  1, 8,   320.00,  2560.00),
(28, 25, 1, 15,  45.00,    675.00),
-- Compra 29: restock salud
(29, 22, 2, 40,  28.00,   1120.00),
(29, 23, 2, 30,  20.00,    600.00),
(29, 24, 2, 25,  24.00,    600.00),
-- Compra 30: restock papeleria
(30, 15, 3, 300, 1.50,     450.00),
(30, 16, 3, 50,  16.00,    800.00),
(30, 17, 3, 200, 1.00,     200.00);
