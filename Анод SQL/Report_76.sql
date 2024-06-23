select

o.date_work,
o.sector_num,
o.fio_master, 
o.fio_employee, 
o.accep_list_tp_id, 
o.n_acceptance_list, 
n_ords, 
o.designation_article, 
o.designation_nomenclature,
o.name_nomenclature, 
o.name_tech_op,
sum(o.count_accapted) as sum_accapted, 
o.count_accapted_otk,
n_t.norm_time,
n_t.norm_time*sum(o.count_accapted) as sum_norm_time,
sum(o.another_time) as sum_another_time,
o.name_main_boss,
o.name_main_peo

from (
select 
to_char(gs, 'DD.MM.YY') as date_work,
sector.attr_3405_ sector_num,
master.attr_205_ as fio_master,
employee.attr_205_ as fio_employee,
acceptance_list.attr_2155_ as n_acceptance_list,
acceptance_list_table_part.id as accep_list_tp_id,
array_to_string(array_agg(distinct(ord.attr_607_)), ', ') as n_ords,
array_to_string(array_agg(distinct(parent_article.attr_376_)), ',') as designation_article,
nomenclature.id as nomenclature_id,
nomenclature.attr_1494_ as designation_nomenclature, 
nomenclature.attr_362_ as name_nomenclature,
tech_operation.attr_547_ as name_tech_op,
acceptance.attr_3280_ as count_accapted,
acceptance.attr_3283_ as another_time,
acceptance_list_table_part.attr_3208_ as n_step,
acceptance_list_table_part.attr_2149_ as id_to,
acceptance_list.attr_2226_ as id_work_task,
acceptance_list.attr_2167_ as id_ed_hran,
acceptance_list.attr_3193_ as id_position_work_task,
acceptance_list_table_part.attr_2609_ as count_accapted_otk,
(select j.attr_205_ from registry.object_17_ j where j.attr_25_ = 6) name_main_boss,
(select j1.attr_205_ from registry.object_17_ j1 where j1.attr_25_ = 85) name_main_peo

/*для теста в СУБД
from  generate_series(to_date('11/05/2023','DD.MM.YYYY'), to_date('24/05/2023','DD.MM.YYYY') , interval '1 day') as gs
*/

from generate_series(to_date('{Период.FromDate}','DD.MM.YYYY'), to_date('{Период.ToDate}','DD.MM.YYYY') , interval '1 day') as gs

left join registry.object_3273_ acceptance on acceptance.attr_3275_::date =  gs::date  and acceptance.attr_3284_ is false and acceptance.is_deleted<>true
left join registry.object_3404_ sector on acceptance.attr_3494_ = sector.id and sector.is_deleted<>true
left join registry.object_17_ master on acceptance.attr_3278_ = master.id  and master.is_deleted<> true
left join registry.object_17_ employee on acceptance.attr_3279_ = employee.id and  employee.is_deleted<>true
left join registry.object_2137_ acceptance_list on acceptance.attr_3276_ = acceptance_list.id and acceptance_list.is_deleted<> true
/*код убран из-за некорректной работы с полем acceptance_list.attr_2675_ в конструкторе
left join registry.xref_2675_ mass_order on mass_order.from_id = acceptance_list.id
left join registry.object_606_ ord on mass_order.to_id = ord.id
left join registry.xref_3264_ mass_article on mass_article.from_id = acceptance_list.id
left join registry.object_301_ parent_article on mass_article.to_id = parent_article.id and parent_article.is_deleted<>true*/
left join registry.object_606_ ord  on ord.id = ANY (acceptance_list.attr_2675_) and ord.is_deleted<>true
left join registry.object_301_ parent_article on parent_article.id = ANY (acceptance_list.attr_3264_) and parent_article.is_deleted<>true
left join registry.object_301_ nomenclature on acceptance_list.attr_2632_ = nomenclature.id and nomenclature.is_deleted<>true
left join registry.object_2138_ acceptance_list_table_part on acceptance.attr_3277_ = acceptance_list_table_part.id and  acceptance_list_table_part.is_deleted<>true
left join registry.object_545_ tech_operation on  acceptance_list_table_part.attr_2149_ = tech_operation.id and tech_operation.is_deleted<>true

group by 
to_char(gs, 'DD.MM.YY'),
sector.attr_3405_,
master.id, 
employee.id, 
acceptance_list.id, 
tech_operation.id, 
acceptance_list_table_part.id, 
acceptance.id, 
nomenclature.id

order by 
employee.attr_205_, 
to_char(gs, 'DD.MM.YY') desc) o


left join (
select
o.attr_3203_ as nom_ed,
o.attr_3204_ as tech_card,
o.attr_2173_,
o.attr_3175_,
o.attr_2203_ as ed_hran,
o.attr_2104_ as mat,
o.attr_2105_ as sort,
o.attr_2106_ as tr,
sum(o.attr_2103_ )

from registry.object_2094_ o 

where o.is_deleted <> true

group by
o.attr_3203_,
o.attr_3204_,
o.attr_2173_,
o.attr_2203_,
o.attr_2104_,
o.attr_2105_,
o.attr_2106_,
o.attr_3175_ 

order by 
o.attr_3203_,
o.attr_3204_,
o.attr_2203_) mass on mass.nom_ed = o.nomenclature_id and mass.attr_2173_ = o.id_work_task and mass.ed_hran= o.id_ed_hran and mass.attr_3175_ = o.id_position_work_task

left join (
select
o.attr_538_ as id_tech_card,
o.attr_586_ as id_to,
o.attr_613_ as n_step,
o.attr_1443_ as norm_time

from registry.object_527_ o where o.is_deleted<>true) n_t on mass.tech_card = n_t.id_tech_card and o.id_to = n_t.id_to and o.n_step = n_t.n_step


/*where o.fio_master is not null or o.fio_employee is not null*/

group by 
o.date_work,
o.sector_num,
o.fio_master,
o.fio_employee,
o.accep_list_tp_id,
o.n_acceptance_list,
n_ords,
o.designation_article,
o.designation_nomenclature,
o.name_nomenclature,
o.name_tech_op,
n_t.norm_time,
o.count_accapted_otk,
o.name_main_boss,
o.name_main_peo

order by 
o.date_work::date,
o.fio_employee
