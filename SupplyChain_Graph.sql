-- ============================================================
-- ГРАФОВАЯ БАЗА ДАННЫХ: ЦЕПОЧКА ПОСТАВОК (ВАРИАНТ 30)
-- Узлы:  Factory, Distributor, Store
-- Рёбра: Supplies, Distributes, Sells, PartnerWith
-- ============================================================

USE master;
GO
DROP DATABASE IF EXISTS SupplyChain;
GO
CREATE DATABASE SupplyChain;
GO
USE SupplyChain;
GO

-- ============================================================
-- ПУНКТ 1. СОЗДАНИЕ ТАБЛИЦ УЗЛОВ (не менее 3)
-- ============================================================

-- Таблица узлов: Заводы
CREATE TABLE Factory
(
    id           INT           NOT NULL PRIMARY KEY,
    name         NVARCHAR(100) NOT NULL,
    country      NVARCHAR(50)  NOT NULL,
    city         NVARCHAR(50)  NOT NULL,
    product_type NVARCHAR(100) NOT NULL,
    capacity     INT           NOT NULL
) AS NODE;
GO

-- Таблица узлов: Дистрибьюторы
CREATE TABLE Distributor
(
    id             INT           NOT NULL PRIMARY KEY,
    name           NVARCHAR(100) NOT NULL,
    country        NVARCHAR(50)  NOT NULL,
    city           NVARCHAR(50)  NOT NULL,
    warehouse_area INT           NOT NULL
) AS NODE;
GO

-- Таблица узлов: Магазины
CREATE TABLE Store
(
    id            INT           NOT NULL PRIMARY KEY,
    name          NVARCHAR(100) NOT NULL,
    country       NVARCHAR(50)  NOT NULL,
    city          NVARCHAR(50)  NOT NULL,
    store_type    NVARCHAR(50)  NOT NULL,
    monthly_sales INT           NOT NULL
) AS NODE;
GO

-- ============================================================
-- ПУНКТ 2. СОЗДАНИЕ ТАБЛИЦ РЁБЕР (не менее 3) + CONNECTION CONSTRAINT
-- ============================================================

-- Ребро: Завод ПОСТАВЛЯЕТ товары Дистрибьютору
CREATE TABLE Supplies
(
    contract_date DATE          NOT NULL,
    annual_volume INT           NOT NULL,
    unit_price    DECIMAL(10,2) NOT NULL,
    status        NVARCHAR(20)  NOT NULL
) AS EDGE;
GO
ALTER TABLE Supplies
    ADD CONSTRAINT EC_Supplies CONNECTION (Factory TO Distributor);
GO

-- Ребро: Дистрибьютор РАСПРЕДЕЛЯЕТ товары Магазину
CREATE TABLE Distributes
(
    start_date    DATE          NOT NULL,
    weekly_volume INT           NOT NULL,
    delivery_days INT           NOT NULL,
    discount_pct  DECIMAL(5,2)  NOT NULL
) AS EDGE;
GO
ALTER TABLE Distributes
    ADD CONSTRAINT EC_Distributes CONNECTION (Distributor TO Store);
GO

-- Ребро: Магазин ПРОДАЁТ продукцию Завода (предпочтения)
CREATE TABLE Sells
(
    shelf_share DECIMAL(5,2) NOT NULL,
    avg_rating  DECIMAL(3,1) NOT NULL,
    since_year  INT          NOT NULL
) AS EDGE;
GO
ALTER TABLE Sells
    ADD CONSTRAINT EC_Sells CONNECTION (Store TO Factory);
GO

-- Ребро: Дистрибьютор СОТРУДНИЧАЕТ с другим Дистрибьютором (партнёрская сеть)
-- Самореферентное ребро (Distributor -> Distributor) — нужно для SHORTEST_PATH
CREATE TABLE PartnerWith
(
    partnership_date DATE         NOT NULL,
    trust_level      INT          NOT NULL,   -- 1..10
    commission_pct   DECIMAL(5,2) NOT NULL    -- комиссия за перевалку (%)
) AS EDGE;
GO
ALTER TABLE PartnerWith
    ADD CONSTRAINT EC_PartnerWith CONNECTION (Distributor TO Distributor);
GO

-- ============================================================
-- ПУНКТ 3. ЗАПОЛНЕНИЕ ТАБЛИЦ УЗЛОВ (не менее 10 строк в каждой)
-- ============================================================

-- 10 заводов
INSERT INTO Factory (id, name, country, city, product_type, capacity)
VALUES
    (1,  N'ЭлектроПром',     N'Россия',       N'Москва',    N'Электроника',       500),
    (2,  N'АвтоДеталь',      N'Германия',     N'Штутгарт',  N'Автозапчасти',      300),
    (3,  N'ТекстильМастер',  N'Китай',        N'Шанхай',    N'Одежда и текстиль', 1200),
    (4,  N'ПродФабрика',     N'Беларусь',     N'Минск',     N'Продукты питания',  800),
    (5,  N'КосмоХим',        N'Франция',      N'Лион',      N'Косметика',         250),
    (6,  N'МебельПлюс',      N'Польша',       N'Варшава',   N'Мебель',            150),
    (7,  N'СпортТех',        N'США',          N'Орегон',    N'Спортинвентарь',    400),
    (8,  N'ФармаГрупп',      N'Индия',        N'Мумбаи',    N'Фармацевтика',      600),
    (9,  N'ПакетоПрофи',     N'Чехия',        N'Прага',     N'Упаковочные мат.',  350),
    (10, N'БытТехника',      N'Южная Корея',  N'Сеул',      N'Бытовая техника',   700);
GO

-- 10 дистрибьюторов
INSERT INTO Distributor (id, name, country, city, warehouse_area)
VALUES
    (1,  N'ЛогистикПро',     N'Россия',       N'Москва',     15000),
    (2,  N'ЕвроДистриб',     N'Германия',     N'Франкфурт',  22000),
    (3,  N'АзияТрейд',       N'Китай',        N'Гуанчжоу',   50000),
    (4,  N'БелДистрибуция',  N'Беларусь',     N'Минск',      8000),
    (5,  N'ФранкоСуплай',    N'Франция',      N'Париж',      18000),
    (6,  N'Политекс',        N'Польша',       N'Лодзь',      12000),
    (7,  N'АмериДист',       N'США',          N'Чикаго',     35000),
    (8,  N'МедиФарм',        N'Индия',        N'Дели',       20000),
    (9,  N'ЦентрЕвроДист',   N'Австрия',      N'Вена',       16000),
    (10, N'КорВост',         N'Южная Корея',  N'Инчхон',     28000);
GO

-- 10 магазинов
INSERT INTO Store (id, name, country, city, store_type, monthly_sales)
VALUES
    (1,  N'МегаМолл',         N'Россия',       N'Москва',     N'Гипермаркет', 120),
    (2,  N'РитейлЦентр',      N'Германия',     N'Берлин',     N'Супермаркет', 80),
    (3,  N'ТрендШоп',         N'Франция',      N'Париж',      N'Бутик',       40),
    (4,  N'МинскПлаза',       N'Беларусь',     N'Минск',      N'Гипермаркет', 90),
    (5,  N'GlobalOnline',     N'США',          N'Нью-Йорк',   N'Онлайн',      300),
    (6,  N'ВаршаваМолл',      N'Польша',       N'Варшава',    N'Супермаркет', 70),
    (7,  N'СеулСтор',         N'Южная Корея',  N'Сеул',       N'Электроника', 150),
    (8,  N'МумбаиМаркет',     N'Индия',        N'Мумбаи',     N'Супермаркет', 95),
    (9,  N'ВенаЭлит',         N'Австрия',      N'Вена',       N'Бутик',       35),
    (10, N'ШанхайМегастор',   N'Китай',        N'Шанхай',     N'Гипермаркет', 200);
GO

-- ============================================================
-- ПУНКТ 4. ЗАПОЛНЕНИЕ ТАБЛИЦ РЁБЕР
-- ============================================================

-- Supplies (Factory -> Distributor)
INSERT INTO Supplies ($from_id, $to_id, contract_date, annual_volume, unit_price, status)
VALUES
((SELECT $node_id FROM Factory WHERE id=1),  (SELECT $node_id FROM Distributor WHERE id=1),  '2021-03-15', 200, 45.50, N'Active'),
((SELECT $node_id FROM Factory WHERE id=1),  (SELECT $node_id FROM Distributor WHERE id=2),  '2020-07-01', 150, 48.00, N'Active'),
((SELECT $node_id FROM Factory WHERE id=2),  (SELECT $node_id FROM Distributor WHERE id=2),  '2019-11-20', 100, 120.00, N'Active'),
((SELECT $node_id FROM Factory WHERE id=3),  (SELECT $node_id FROM Distributor WHERE id=3),  '2022-01-10', 600, 12.75, N'Active'),
((SELECT $node_id FROM Factory WHERE id=4),  (SELECT $node_id FROM Distributor WHERE id=4),  '2020-05-01', 350, 5.20,  N'Active'),
((SELECT $node_id FROM Factory WHERE id=5),  (SELECT $node_id FROM Distributor WHERE id=5),  '2021-08-15', 80,  25.00, N'Active'),
((SELECT $node_id FROM Factory WHERE id=6),  (SELECT $node_id FROM Distributor WHERE id=6),  '2018-04-22', 60,  200.00,N'Suspended'),
((SELECT $node_id FROM Factory WHERE id=7),  (SELECT $node_id FROM Distributor WHERE id=7),  '2022-09-01', 180, 55.00, N'Active'),
((SELECT $node_id FROM Factory WHERE id=8),  (SELECT $node_id FROM Distributor WHERE id=8),  '2021-12-01', 300, 8.90,  N'Active'),
((SELECT $node_id FROM Factory WHERE id=10), (SELECT $node_id FROM Distributor WHERE id=10), '2020-02-28', 400, 95.00, N'Active'),
((SELECT $node_id FROM Factory WHERE id=1),  (SELECT $node_id FROM Distributor WHERE id=10), '2023-01-15', 100, 46.00, N'Active'),
((SELECT $node_id FROM Factory WHERE id=3),  (SELECT $node_id FROM Distributor WHERE id=9),  '2022-06-01', 120, 13.00, N'Active');
GO

-- Distributes (Distributor -> Store)
INSERT INTO Distributes ($from_id, $to_id, start_date, weekly_volume, delivery_days, discount_pct)
VALUES
((SELECT $node_id FROM Distributor WHERE id=1),  (SELECT $node_id FROM Store WHERE id=1),  '2021-04-01', 40, 2, 5.00),
((SELECT $node_id FROM Distributor WHERE id=2),  (SELECT $node_id FROM Store WHERE id=2),  '2020-08-01', 25, 3, 7.50),
((SELECT $node_id FROM Distributor WHERE id=3),  (SELECT $node_id FROM Store WHERE id=10), '2022-02-01', 80, 1, 10.00),
((SELECT $node_id FROM Distributor WHERE id=3),  (SELECT $node_id FROM Store WHERE id=5),  '2022-03-15', 60, 7, 8.00),
((SELECT $node_id FROM Distributor WHERE id=4),  (SELECT $node_id FROM Store WHERE id=4),  '2020-06-01', 35, 1, 3.00),
((SELECT $node_id FROM Distributor WHERE id=5),  (SELECT $node_id FROM Store WHERE id=3),  '2021-09-01', 15, 2, 4.50),
((SELECT $node_id FROM Distributor WHERE id=6),  (SELECT $node_id FROM Store WHERE id=6),  '2018-05-01', 20, 2, 6.00),
((SELECT $node_id FROM Distributor WHERE id=7),  (SELECT $node_id FROM Store WHERE id=5),  '2022-10-01', 50, 5, 9.00),
((SELECT $node_id FROM Distributor WHERE id=8),  (SELECT $node_id FROM Store WHERE id=8),  '2022-01-01', 30, 2, 5.00),
((SELECT $node_id FROM Distributor WHERE id=10), (SELECT $node_id FROM Store WHERE id=7),  '2020-03-01', 55, 1, 12.00),
((SELECT $node_id FROM Distributor WHERE id=9),  (SELECT $node_id FROM Store WHERE id=9),  '2022-07-01', 10, 2, 3.50),
((SELECT $node_id FROM Distributor WHERE id=2),  (SELECT $node_id FROM Store WHERE id=9),  '2021-01-01', 8,  4, 6.00);
GO

-- Sells (Store -> Factory)
INSERT INTO Sells ($from_id, $to_id, shelf_share, avg_rating, since_year)
VALUES
((SELECT $node_id FROM Store WHERE id=1),  (SELECT $node_id FROM Factory WHERE id=1),  25.00, 8.5, 2021),
((SELECT $node_id FROM Store WHERE id=1),  (SELECT $node_id FROM Factory WHERE id=4),  35.00, 9.0, 2020),
((SELECT $node_id FROM Store WHERE id=2),  (SELECT $node_id FROM Factory WHERE id=2),  40.00, 9.2, 2019),
((SELECT $node_id FROM Store WHERE id=3),  (SELECT $node_id FROM Factory WHERE id=5),  60.00, 9.5, 2021),
((SELECT $node_id FROM Store WHERE id=4),  (SELECT $node_id FROM Factory WHERE id=4),  50.00, 8.8, 2020),
((SELECT $node_id FROM Store WHERE id=5),  (SELECT $node_id FROM Factory WHERE id=3),  20.00, 7.5, 2022),
((SELECT $node_id FROM Store WHERE id=5),  (SELECT $node_id FROM Factory WHERE id=7),  30.00, 8.7, 2022),
((SELECT $node_id FROM Store WHERE id=6),  (SELECT $node_id FROM Factory WHERE id=6),  45.00, 8.0, 2018),
((SELECT $node_id FROM Store WHERE id=7),  (SELECT $node_id FROM Factory WHERE id=10), 70.00, 9.4, 2020),
((SELECT $node_id FROM Store WHERE id=8),  (SELECT $node_id FROM Factory WHERE id=8),  55.00, 8.6, 2022),
((SELECT $node_id FROM Store WHERE id=9),  (SELECT $node_id FROM Factory WHERE id=5),  65.00, 9.3, 2021),
((SELECT $node_id FROM Store WHERE id=10), (SELECT $node_id FROM Factory WHERE id=3),  40.00, 8.1, 2022);
GO

-- PartnerWith (Distributor -> Distributor)
-- цепочка партнёрств для демонстрации SHORTEST_PATH:
--  1 -> 2 -> 3 -> 4 -> 5 -> 6 -> 7 -> 8 -> 9 -> 10
--  плюс альтернативные «короткие пути»:  2 -> 5,   1 -> 4,   7 -> 10
INSERT INTO PartnerWith ($from_id, $to_id, partnership_date, trust_level, commission_pct)
VALUES
((SELECT $node_id FROM Distributor WHERE id=1),  (SELECT $node_id FROM Distributor WHERE id=2),  '2020-01-01', 9, 2.50),
((SELECT $node_id FROM Distributor WHERE id=2),  (SELECT $node_id FROM Distributor WHERE id=3),  '2020-03-15', 8, 3.00),
((SELECT $node_id FROM Distributor WHERE id=3),  (SELECT $node_id FROM Distributor WHERE id=4),  '2021-06-01', 7, 3.50),
((SELECT $node_id FROM Distributor WHERE id=4),  (SELECT $node_id FROM Distributor WHERE id=5),  '2021-11-15', 8, 2.75),
((SELECT $node_id FROM Distributor WHERE id=5),  (SELECT $node_id FROM Distributor WHERE id=6),  '2022-02-01', 7, 3.00),
((SELECT $node_id FROM Distributor WHERE id=6),  (SELECT $node_id FROM Distributor WHERE id=7),  '2022-04-15', 9, 2.50),
((SELECT $node_id FROM Distributor WHERE id=7),  (SELECT $node_id FROM Distributor WHERE id=8),  '2022-10-01', 8, 3.00),
((SELECT $node_id FROM Distributor WHERE id=8),  (SELECT $node_id FROM Distributor WHERE id=9),  '2023-01-15', 9, 2.50),
((SELECT $node_id FROM Distributor WHERE id=9),  (SELECT $node_id FROM Distributor WHERE id=10), '2023-03-01', 8, 3.25),
-- альтернативные сокращения
((SELECT $node_id FROM Distributor WHERE id=2),  (SELECT $node_id FROM Distributor WHERE id=5),  '2021-09-01', 6, 4.00),
((SELECT $node_id FROM Distributor WHERE id=1),  (SELECT $node_id FROM Distributor WHERE id=4),  '2022-05-10', 7, 3.50),
((SELECT $node_id FROM Distributor WHERE id=7),  (SELECT $node_id FROM Distributor WHERE id=10), '2023-07-01', 8, 2.80);
GO

-- ============================================================
-- ПУНКТ 5. ЗАПРОСЫ С ФУНКЦИЕЙ MATCH (не менее 5, цепочки из 3+ узлов)
-- ============================================================

-- 5.1. Полная цепочка Завод -> Дистрибьютор -> Магазин
PRINT N'--- 5.1. Полная цепочка поставки: Завод -> Дистрибьютор -> Магазин ---';
SELECT
    f.name             AS [Завод],
    d.name             AS [Дистрибьютор],
    s.name             AS [Магазин],
    sup.annual_volume  AS [Годовой объём поставки],
    dis.weekly_volume  AS [Недельный объём],
    dis.delivery_days  AS [Срок доставки (дн.)]
FROM Factory     AS f
   , Supplies    AS sup
   , Distributor AS d
   , Distributes AS dis
   , Store       AS s
WHERE MATCH(f-(sup)->d-(dis)->s)
ORDER BY f.name, d.name, s.name;
GO

-- 5.2. Цепочка Завод -> Дистрибьютор -> Магазин с фильтром по странам
PRINT N'--- 5.2. Цепочки, где завод и магазин в разных странах ---';
SELECT
    f.name         AS [Завод],
    f.country      AS [Страна завода],
    d.name         AS [Дистрибьютор],
    s.name         AS [Магазин],
    s.country      AS [Страна магазина],
    sup.unit_price AS [Цена за ед. (USD)]
FROM Factory     AS f
   , Supplies    AS sup
   , Distributor AS d
   , Distributes AS dis
   , Store       AS s
WHERE MATCH(f-(sup)->d-(dis)->s)
  AND f.country <> s.country
ORDER BY f.country, s.country;
GO

-- 5.3. Магазин -> Завод по «предпочтению» (через Sells)
PRINT N'--- 5.3. Магазины, предпочитающие продукцию с рейтингом >= 8.5 ---';
SELECT
    st.name         AS [Магазин],
    st.country      AS [Страна магазина],
    f.name          AS [Предпочитаемый завод],
    f.country       AS [Страна завода],
    f.product_type  AS [Тип продукции],
    sel.avg_rating  AS [Средний рейтинг],
    sel.shelf_share AS [Доля полки (%)]
FROM Store   AS st
   , Sells   AS sel
   , Factory AS f
WHERE MATCH(st-(sel)->f)
  AND sel.avg_rating >= 8.5
ORDER BY sel.avg_rating DESC;
GO

-- 5.4. Цепочка из 4-х узлов: Завод -> Дистрибьютор -> Магазин -> Завод (предпочтения)
PRINT N'--- 5.4. Поставщик vs предпочтения магазина (4 узла в цепочке) ---';
SELECT DISTINCT
    f1.name AS [Завод-поставщик],
    d.name  AS [Дистрибьютор],
    st.name AS [Магазин],
    f2.name AS [Предпочитаемый завод магазина],
    CASE WHEN f1.id = f2.id THEN N'Совпадает' ELSE N'Другой завод' END AS [Предпочтение]
FROM Factory     AS f1
   , Supplies    AS sup
   , Distributor AS d
   , Distributes AS dis
   , Store       AS st
   , Sells       AS sel
   , Factory     AS f2
WHERE MATCH(f1-(sup)->d-(dis)->st-(sel)->f2)
ORDER BY st.name;
GO

-- 5.5. Агрегирование по цепочке: ведущие дистрибьюторы
PRINT N'--- 5.5. Дистрибьюторы с суммарным объёмом поставок > 200 тыс. ед. ---';
SELECT
    d.name                 AS [Дистрибьютор],
    d.city                 AS [Город дистрибьютора],
    SUM(sup.annual_volume) AS [Суммарный годовой объём],
    COUNT(DISTINCT st.id)  AS [Кол-во обслуживаемых магазинов],
    STRING_AGG(st.name, N', ') AS [Магазины]
FROM Factory     AS f
   , Supplies    AS sup
   , Distributor AS d
   , Distributes AS dis
   , Store       AS st
WHERE MATCH(f-(sup)->d-(dis)->st)
GROUP BY d.id, d.name, d.city
HAVING SUM(sup.annual_volume) > 200
ORDER BY SUM(sup.annual_volume) DESC;
GO

-- 5.6. Активные контракты + скидки магазина
PRINT N'--- 5.6. Активные цепочки поставок со скидками ---';
SELECT
    f.name           AS [Завод],
    f.product_type   AS [Тип продукции],
    d.name           AS [Дистрибьютор],
    s.name           AS [Магазин],
    s.store_type     AS [Тип магазина],
    sup.status       AS [Статус контракта],
    dis.discount_pct AS [Скидка (%)]
FROM Factory     AS f
   , Supplies    AS sup
   , Distributor AS d
   , Distributes AS dis
   , Store       AS s
WHERE MATCH(f-(sup)->d-(dis)->s)
  AND sup.status = N'Active'
ORDER BY dis.discount_pct DESC;
GO

-- ============================================================
-- ПУНКТ 6. ЗАПРОСЫ С ФУНКЦИЕЙ SHORTEST_PATH (не менее 2)
-- Используем самореферентное ребро PartnerWith (Distributor -> Distributor)
-- ============================================================

-- 6.1. SHORTEST_PATH с шаблоном "+":
-- Все кратчайшие пути по партнёрской сети от заданного дистрибьютора.
-- LAST_VALUE — конечный узел, STRING_AGG — путь, COUNT — длина пути.
PRINT N'--- 6.1. Кратчайшие пути партнёрств от ЛогистикПро (шаблон "+") ---';
SELECT
    d1.name                                                AS [Стартовый дистрибьютор],
    STRING_AGG(d2.name, N' -> ') WITHIN GROUP (GRAPH PATH) AS [Путь партнёрств],
    LAST_VALUE(d2.name)          WITHIN GROUP (GRAPH PATH) AS [Конечный дистрибьютор],
    COUNT(d2.id)                 WITHIN GROUP (GRAPH PATH) AS [Длина пути (шагов)]
FROM Distributor              AS d1,
     PartnerWith FOR PATH     AS pw,
     Distributor FOR PATH     AS d2
WHERE MATCH(SHORTEST_PATH(d1(-(pw)->d2)+))
  AND d1.name = N'ЛогистикПро';
GO

-- 6.2. SHORTEST_PATH с шаблоном "{1,n}":
-- Пути партнёрств длиной от 1 до 3 шагов от каждого дистрибьютора.
PRINT N'--- 6.2. Пути партнёрств длиной 1..3 шага (шаблон "{1,3}") ---';
SELECT
    d1.name                                                AS [Стартовый дистрибьютор],
    STRING_AGG(d2.name, N' -> ') WITHIN GROUP (GRAPH PATH) AS [Путь длиной 1..3],
    LAST_VALUE(d2.name)          WITHIN GROUP (GRAPH PATH) AS [Конечный дистрибьютор],
    COUNT(d2.id)                 WITHIN GROUP (GRAPH PATH) AS [Длина пути]
FROM Distributor          AS d1,
     PartnerWith FOR PATH AS pw,
     Distributor FOR PATH AS d2
WHERE MATCH(SHORTEST_PATH(d1(-(pw)->d2){1,3}))
ORDER BY d1.name, [Длина пути];
GO

-- 6.3. Кратчайший путь между ДВУМЯ конкретными дистрибьюторами
-- (используем CTE + фильтр по LAST_VALUE)
PRINT N'--- 6.3. Кратчайший путь между ЛогистикПро и КорВост ---';
DECLARE @DistFrom NVARCHAR(100) = N'ЛогистикПро';
DECLARE @DistTo   NVARCHAR(100) = N'КорВост';

WITH Paths AS
(
    SELECT
        d1.name                                                AS StartName,
        STRING_AGG(d2.name, N' -> ') WITHIN GROUP (GRAPH PATH) AS PartnerPath,
        LAST_VALUE(d2.name)          WITHIN GROUP (GRAPH PATH) AS LastDist,
        COUNT(d2.id)                 WITHIN GROUP (GRAPH PATH) AS Steps
    FROM Distributor          AS d1,
         PartnerWith FOR PATH AS pw,
         Distributor FOR PATH AS d2
    WHERE MATCH(SHORTEST_PATH(d1(-(pw)->d2)+))
      AND d1.name = @DistFrom
)
SELECT
    StartName    AS [От],
    PartnerPath  AS [Путь],
    LastDist     AS [Конечный],
    Steps        AS [Шагов]
FROM Paths
WHERE LastDist = @DistTo;
GO

-- ============================================================
-- Проверочные SELECT'ы: содержимое таблиц
-- ============================================================
SELECT * FROM Factory;
SELECT * FROM Distributor;
SELECT * FROM Store;
SELECT * FROM Supplies;
SELECT * FROM Distributes;
SELECT * FROM Sells;
SELECT * FROM PartnerWith;
GO
