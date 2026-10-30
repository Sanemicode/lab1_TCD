-- Перевірка результатів dbt (виконати в psql / DBeaver)

-- 1. Кількість рядків у вітринах (очікується 100 / 1000 / 1000 / 20000 / 3000)
SELECT 'dim_artists' t, COUNT(*) FROM analytics.dim_artists
UNION ALL SELECT 'dim_tracks', COUNT(*) FROM analytics.dim_tracks
UNION ALL SELECT 'dim_listeners', COUNT(*) FROM analytics.dim_listeners
UNION ALL SELECT 'fct_streams', COUNT(*) FROM analytics.fct_streams
UNION ALL SELECT 'fct_subscriptions', COUNT(*) FROM analytics.fct_subscriptions;

-- 2. Дублікати слухачів усунено (очікується 0 рядків)
SELECT listener_id, COUNT(*) FROM analytics.dim_listeners GROUP BY 1 HAVING COUNT(*) > 1;

-- 3. NULL в email замінено (очікується 0)
SELECT COUNT(*) FROM analytics.dim_listeners WHERE email IS NULL;

-- 4. Приклад аналітичного запиту по схемі «Зірка»: топ-5 виконавців за прослуховуваннями
SELECT a.artist_name, COUNT(*) AS plays
FROM analytics.fct_streams f
JOIN analytics.dim_artists a ON a.artist_id = f.artist_id
GROUP BY a.artist_name
ORDER BY plays DESC
LIMIT 5;
