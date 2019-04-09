SET NEWPAGE 0
SET SPACE 0
SET LINESIZE 2500 
SET PAGESIZE 0
SET ECHO OFF
SET FEEDBACK OFF
SET VERIFY OFF
SET HEADING OFF
SET MARKUP HTML OFF SPOOL OFF
SET COLSEP ' '
SET TRIMSPOOL ON
SET TERMOUT OFF
COL report_name FORMAT a35
COL report_name NEW_VALUE rpt_name
select 'CMBFYDWAL06002A'||&1||'0000000.000' as report_name from dual;
SPOOL &rpt_name
select bank_warrant_no || CHR(9)|| rec_pay_date || CHR(9)|| bank_name || CHR(9)||
       record_flag || CHR(9)|| carrier_name || CHR(9)|| carrier_id || CHR(9)||
       descript || CHR(9)|| amount_bill || CHR(9)|| exchange_name2 || CHR(9)||
       rate_bill || CHR(9)|| amount || CHR(9)|| exchange_name || CHR(9)|| rate || CHR(9)||
       amount_rmb || CHR(9)|| bank_fee || CHR(9)|| remark || CHR(9)|| bill_cycle || CHR(9)||
       erp_def_code as data
  from t_report_if_recpay a
 WHERE 1 = 1
 and bill_cycle=&1   order by erp_def_code asc;
SPOOL OFF
select 'CMBFYDWAL06005A'||&1||'0000000.000' as report_name from dual;
SPOOL &rpt_name
select ADVANCE_NO || CHR(9)|| carrier_name || CHR(9)|| WARRANT_NO || CHR(9)||
       REC_DATE || CHR(9)|| EXCHANGE_NAME || CHR(9)|| AMOUNT || CHR(9)||
       AMOUNT_RMB || CHR(9)|| BALANCE || CHR(9)|| BALANCE_RMB as data
  from t_report_if_advance
 WHERE 1 = 1
and bill_cycle=&1   order by erp_def_code asc;
SPOOL OFF
select 'CMBFYDWAL06006A'||&1||'0000000.000' as report_name from dual;
SPOOL &rpt_name
select BAIL_NO || CHR(9)|| carrier_name || CHR(9)|| warrant_no || CHR(9)||
       REC_DATE || CHR(9)|| EXCHANGE_NAME || CHR(9)|| AMOUNT || CHR(9)||
       AMOUNT_RMB || CHR(9)|| BALANCE || CHR(9)|| BALANCE_RMB || CHR(9)||
       bill_cycle || CHR(9)|| erp_def_code as data
  from t_report_if_bail
 WHERE 1 = 1
 and bill_cycle=&1   order by erp_def_code asc;
SPOOL OFF
select 'CMBFYDWAL06007A'||&1||'0000000.000' as report_name from dual;
SPOOL &rpt_name
select report_month || CHR(9)|| center || CHR(9)|| period || CHR(9)|| types || CHR(9)||
       property || CHR(9)|| carrier_name || CHR(9)|| customer_number || CHR(9)||
       currency || CHR(9)|| duration || CHR(9)|| amount || CHR(9)|| basiccurrency || CHR(9)||
       reference_no || CHR(9)|| bill_cycle || CHR(9)|| erp_def_code as data
  from t_report_if_rp
 WHERE 1 = 1
 and bill_cycle=&1   order by erp_def_code asc;
 SPOOL OFF
select 'CMBFYDWAL01001A'||&1||'0000000.000' as report_name from dual;
SPOOL &rpt_name
select DATA_TYPE|| CHR(9) ||CHINESENAME|| CHR(9) ||
  CARRIER_NAME|| CHR(9) ||CARRIER_ID|| CHR(9) ||ACCOUNT_CODE|| CHR(9) ||
  ACCOUNT_NAME|| CHR(9) ||CONTACT_PERSON|| CHR(9) ||
  TELEPHONE_NO|| CHR(9) ||EMAIL_ADDRESS|| CHR(9) ||
  BENEFICIARY_NAME|| CHR(9) ||ACCO_LINKMAN_PHONE|| CHR(9) ||
  ACCO_LINKMAN_EMAIL|| CHR(9) ||BUSI_MANA_NAME|| CHR(9) ||
  ACCO_MANA_NAME as data
  from t_report_if_carrier
 WHERE 1 = 1
and bill_cycle=&1   order by erp_def_code asc;
SPOOL OFF
select 'CMBFYDWAL06004A'||&1||'0000000.000' as report_name from dual;
SPOOL &rpt_name
select carrier_name || CHR(9)|| destroybill_no || CHR(9)|| settle_flag || CHR(9)||
       service_name || CHR(9)|| load_date || CHR(9)|| jfdate || CHR(9)|| settdate || CHR(9)||
       exchange_name || CHR(9)|| settle_amount || CHR(9)|| settle_amount_new || CHR(9)||
       bill_cycle || CHR(9)|| erp_def_code as data
  From t_report_if_destroys
 WHERE 1 = 1
 and bill_cycle=&1   order by erp_def_code asc;
 SPOOL OFF
select 'CMBFYDWAL06001A'||&1||'0000000.000' as report_name from dual;
SPOOL &rpt_name
select carrier_name || CHR(9)|| carrier_no || CHR(9)|| center_name || CHR(9)||
       destroybill_no || CHR(9)|| rec_pay || CHR(9)|| buy_property || CHR(9)||
       service_no || CHR(9)|| map_name || CHR(9)|| load_date || CHR(9)|| jfdate || CHR(9)||
       settdate || CHR(9)|| end_date || CHR(9)|| exchange_name || CHR(9)||
       settle_amount || CHR(9)|| settle_amount_rmb || CHR(9)|| current_amount || CHR(9)||
       amount_30 || CHR(9)|| amount_90 || CHR(9)|| amount_180 || CHR(9)||
       amount_360 || CHR(9)|| AMOUNT_720 || CHR(9)|| AMOUNT_1080 || CHR(9)||
       AMOUNT_1440 || CHR(9)|| AMOUNT_1800 as data
  From t_report_if_datadetail
 WHERE 1 = 1
and bill_cycle=&1   order by erp_def_code asc;
 SPOOL OFF
QUIT