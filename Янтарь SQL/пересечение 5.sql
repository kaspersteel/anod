SELECT
proc3."record",
string_agg (DISTINCT proc3."intersect", '\n' ) AS _output /*собираем уникальные значения пересечений*/

FROM registry.object_4000_ o
LEFT JOIN (
WITH proc AS (
		SELECT
		o.id as "record",
		proc.*
		FROM
		registry.object_4000_ o
		LEFT JOIN  LATERAL (
		VALUES
			( 'ЛФК 1', o.attr_4007_, 1 ),
			( 'ЛФК 2', o.attr_4009_, 2 ),
			( 'Бассейн', o.attr_4011_, 3 ),
			( 'Гидромассаж', o.attr_4013_, 4 ),
			( 'Эрготерапия', o.attr_4015_, 5 ),
			( 'Занятие с логопедом', o.attr_4017_, 6 ),
			( 'Занятие с психологом', o.attr_4019_, 7 ),
			( 'ИРТ', o.attr_4021_, 8 ),
			( 'Массаж', o.attr_4023_, 9 ),
			( 'ФТ', o.attr_4025_, 10 ),
			( 'Грязетерапия', o.attr_4027_, 11 ),
			( 'Соляная пещера', o.attr_4029_, 12 ),
			( 'Гирудотерапия', o.attr_4251_, 13 )
		) AS proc ( "name", "interval", "id" )  on o.is_deleted=false WHERE o.is_deleted=false) /*собираем таблицу интервалов из строки, LATERAL позволяет обратиться из подзапроса к таблице, вызванной вне */
		SELECT DISTINCT
                proc."record" as record,
		concat (
		CASE
			WHEN proc."id" < proc2."id" THEN
			proc."name" ELSE proc2."name" 
			END,
			' || ',
		CASE
			WHEN proc."id" > proc2."id" THEN
			proc."name" ELSE proc2."name" 
			END 
			) AS "intersect" /*разворачиваем зеркальные пары, чтобы исключить их при агрегации*/
		FROM
			proc /*к таблице интервалов цепляем по условию пересечения интервалов строки из неё же, исключая одинаковые строки*/
			LEFT JOIN proc proc2 ON proc."name" != proc2."name" and proc."record"=proc2."record"
			AND proc."interval" && proc2."interval" 
			AND ( proc."interval" && ARRAY [ 1 ] OR proc2."interval" && ARRAY [ 1 ] ) <> TRUE 
		WHERE
			proc2."name" IS NOT NULL /*очищаем от строк, куда не прикрепилось ни одной записи*/
		) proc3 on proc3."record"=o.id
WHERE o.is_deleted=false
GROUP BY proc3."record"