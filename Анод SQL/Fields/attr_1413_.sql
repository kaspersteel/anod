   SELECT -->>
          CASE
                    WHEN o.attr_1458_ IS NULL THEN NULL
                    ELSE nomenclature.attr_362_
          END
     FROM registry.object__ o -->>
    WHERE o.is_deleted IS FALSE -->>
 GROUP BY -->>