select
       p.name_full_formatted
     , pa.alias as MRN
     , e.person_id
     , e.encntr_id
     , e.reg_dt_tm
     , e.disch_dt_tm
     , encntrtypecd.display as EncounterType
     , encntrtypeclasscd.display as EncounterTypeClass
     , encntrclasscd.display as EncounterClass
     , encntrstatuscd.display as EncounterStatus
from bostonchildrens_prod.person p

join bostonchildrens_prod.encounter e on e.person_id = p.person_id 
 and e.active_ind = 1
 and e.end_effective_dt_tm > now()
 /* Get encounter info for auditing purposes */
 /* Just be careful that we don't get dupes */
 /* Comment out for now since test patients may not always have FIN NBR 
join bostonchildrens_prod.encntr_alias on encntr_alias.encntr_id = e.encntr_id
 and encntr_alias.active_ind = 1
 and encntr_alias.end_effective_dt_tm > now()
join bostonchildrens_prod.code_value encntraliastypecd  on encntraliastypecd.code_value =  encntr_alias.encntr_alias_type_cd
 and encntraliastypecd.cdf_meaning in ('FIN NBR','MRN')
 and encntraliastypecd.code_set = 319
 and encntraliastypecd.active_ind = 1
*/
/* We left join here in case test/malformed encounter */
left join bostonchildrens_prod.code_value encntrtypecd on encntrtypecd.code_value = e.encntr_type_cd
 and encntrtypecd.code_set = 71
 and encntrtypecd.active_ind = 1
left join bostonchildrens_prod.code_value encntrtypeclasscd on encntrtypeclasscd.code_value = e.encntr_type_class_cd
 and encntrtypeclasscd.code_set = 69
 and encntrtypeclasscd.active_ind = 1
left join bostonchildrens_prod.code_value encntrclasscd on encntrclasscd.code_value = e.encntr_class_cd
 and encntrclasscd.code_set = 321
 and encntrclasscd.active_ind = 1
left join bostonchildrens_prod.code_value encntrstatuscd on encntrstatuscd.code_value = e.encntr_status_cd
 and encntrstatuscd.active_ind = 1

/* Get patient info for auditing purposes */
join bostonchildrens_prod.person_alias pa on pa.person_id = e.person_id
 and pa.end_effective_dt_tm > now()
 and pa.active_ind = 1
join bostonchildrens_prod.code_value aliaspoolcd on aliaspoolcd.code_value = pa.alias_pool_cd
 and aliaspoolcd.display = 'CHB_MRN' -- 3110551
 and aliaspoolcd.code_set = 263
 and aliaspoolcd.active_ind = 1
 
where p.active_ind = 1
and p.end_effective_dt_tm > now()
and p.name_last_key like '%SYSTEM%'
