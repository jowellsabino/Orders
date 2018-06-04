/* Active nontemplate orders */
select
o.orig_order_dt_tm as Anchor_Dt_Tm
, o.order_id /* cannot name yet as template_order_id since will be ambiguous */
, case when catalogtypecd.definition in ('cer_exe:generic_shrorder','cer_exe:rx_shrorder')
then 'Direct Update of Child'
else ''
end as Update_Child
, catalogtypecd.display as Catalog_Type
, activitytypecd.display as Activity_Type
, parentorderstatus.display as Parent_Order_Status
, o.ordered_as_mnemonic
, o.clinical_display_line
, o.catalog_cd
, o.catalog_type_cd
, o.activity_type_cd
, o.order_status_cd
, o.encntr_id
, o.person_id

from bostonchildrens_prod.orders o
/* Order attrinuytes */
join bostonchildrens_prod.code_value catalogtypecd on catalogtypecd.code_value = o.catalog_type_cd
and catalogtypecd.code_set = 6000
and catalogtypecd.active_ind = 1
join bostonchildrens_prod.code_value activitytypecd on activitytypecd.code_value = o.activity_type_cd
and activitytypecd.code_set = 106
and activitytypecd.active_ind = 1
join bostonchildrens_prod.code_value parentorderstatus on parentorderstatus.code_value = o.order_status_cd
and parentorderstatus.code_set = 6004

where o.active_ind = 1
and o.template_order_id = 0.0 /* parent order */
and o.template_order_flag = 0.0 /* non-templated order */
/* Use the orig_ord_as_flag to disqualify prescriptions and home meds
0-Normal order, 1-Prescription/Discharge Order, 2-Recorded/Home Meds, 4-Pharmacy Charge Only 5-Satellite (Super Bill). */
and o.orig_ord_as_flag not in (1,2)
and o.order_status_cd in (select code_value from bostonchildrens_prod.code_value where code_set = 6004 and cdf_meaning in ('ORDERED'))
order by o.orig_order_dt_tm asc
