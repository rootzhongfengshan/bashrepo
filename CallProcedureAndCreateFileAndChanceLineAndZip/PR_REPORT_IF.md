```plsql
CREATE OR REPLACE PROCEDURE PR_REPORT_IF(ifmonth VARCHAR2,
                                         strrtn  OUT VARCHAR2) AS
  start_date VARCHAR2(12) := ifmonth || '04';
  end_date   VARCHAR2(12) := to_char(add_months(to_date(ifmonth, 'yyyy-mm'),
                                                1),
                                     'yyyymm') || '04';
  --scmd1      VARCHAR2(4096) := '';
BEGIN
  /*
  56客户信息报表：（全量）CMBFYDWAL01001AYYYYMM0001001.XXX t_report_if_carrier
  57账龄报告：（增量）    CMBFYDWAL06001AYYYYMM0001001.XXX t_report_if_datadetail
  58回款报告：（增量）    CMBFYDWAL06002AYYYYMM0001001.XXX t_report_if_recpay
  59销账报告：（增量）    CMBFYDWAL06003AYYYYMM0001001.XXX
  60销账明细：（增量）    CMBFYDWAL06004AYYYYMM0001001.XXX t_report_if_destroys
  61预存款报告：（全量）  CMBFYDWAL06005AYYYYMM0001001.XXX t_report_if_advance
  62保证金报告：（全量）  CMBFYDWAL06006AYYYYMM0001001.XXX t_report_if_bail
  63当月收入报告：（增量）CMBFYDWAL06007AYYYYMM0001001.XXX t_report_if_rp
  */
  --001

  insert into t_report_if_carrier
    select '国际语音' data_type,
           carrier_name,
           englishname,
           carrier_id,
           '' account_code,
           '' account_name,
           contact_person,
           telephone_no,
           email_address,
           beneficiary_name,
           '',
           '',
           '',
           '',
           ifmonth,
           '1'
      from t_carrier;
  --002

  insert into t_report_if_datadetail
    Select carrier_name,
           carrier_no,
           center_name,
           destroybill_no,
           rec_pay,
           buy_property,
           service_no,
           map_name,
           load_date,
           jf_cyc_begin || '-' || jf_cyc_end,
           settlestartdate || '-' || settleenddate,
           end_date,
           exchange_name,
           settle_amount,
           settle_amount_rmb,
           current_amount,
           amount_1 + amount_30 + amount_60,
           amount_90,
           amount_180,
           amount_360,
           AMOUNT_720,
           AMOUNT_1080,
           AMOUNT_1440,
           AMOUNT_1800,
           ifmonth,
           '0'
      From t_report_datadetail
     where operation_id = 5
       and banlance_amount != 0
       AND replace(report_month, '-', '') = ifmonth
       AND bill_cycle_flag = '集团国际部'
     Order By carrier_name,
              center_name,
              rec_pay desc,
              Buy_property,
              map_name;
  --003

  insert into t_report_if_recpay
    select bank_warrant_no,
           rec_pay_date,
           c.bank_name,
           decode(record_flag, 0, '收款', 1, '付款'),
           --e.exchange_name,
           --a.pay_carrier_id,
           --descript,
           b.carrier_name,
           b.carrier_id,
           a.descript,
           decode(a.amount_bill, null, 0, a.amount_bill),
           d.exchange_name,
           decode(a.rate_bill, null, 0, a.rate_bill),
           amount,
           d.exchange_name,
           decode(a.rate, null, 0, a.rate),
           decode(a.amount_rmb, null, 0, a.amount_rmb),
           bank_fee,
           ' ',
           ifmonth,
           '1'
      from t_rec_pay_record a
      left join t_carrier b
        on (a.pay_carrier_id = b.carrier_id)
      left join t_bank_info c
        on (a.bank_id = c.bank_id)
      left join t_exchange d
        on (a.exchange_id = d.exchange_id)
      left join t_exchange e
        on (a.exchange_id_bill = e.exchange_id)
      left join t_spec_system f
        on (a.operation_id = f.system_id)
     WHERE b.bill_cycle_flag = '集团国际部'
       AND a.operation_id = 5
       and to_char(to_date(a.rec_pay_date, 'yyyy-mm-dd'), 'yyyymm') =
           ifmonth
     order by 1;
  --004

  --005

  insert into t_report_if_destroys
    Select h.carrier_name,
           destroybill_no,
           decode(settle_flag, 0, '收入', 1, '成本'),
           service_name,
           to_char(a.load_date, 'yyyy-mm-dd'),
           startbilldate || '-' || endbilldate,
           settlestartdate || '-' || settleenddate,
           exchange_name,
           settle_amount,
           settle_amount_new,
           ifmonth,
           '0'
      From (select t1.bill_no,
                   calling_entity_id,
                   calling_account_id,
                   calling_carrier_id,
                   billing_entity_id,
                   billing_account_id,
                   billing_carrier_id,
                   settletype,
                   service_id,
                   service_flag,
                   settdate_id,
                   startbilldate,
                   endbilldate,
                   system_id,
                   settlestartdate,
                   settleenddate,
                   settle_flag,
                   count,
                   duration,
                   byte,
                   settle_amount,
                   adjust_amount,
                   exchange_id,
                   t2.destroy_flag,
                   balance_amount,
                   record_staff,
                   record_time,
                   audit_staff,
                   audit_time,
                   audit_flag,
                   destroybill_no,
                   customer_address,
                   customer_number,
                   rp_month,
                   load_date,
                   settle_amount_new,
                   load_staff,
                   counteract_date,
                   counteract_date_rmb,
                   balance_amount_rmb,
                   t2.amount            back_amount,
                   t2.amount_jf         back_amount_rmb,
                   descript,
                   finance_settle_start,
                   finance_settle_end,
                   sett_amount_rmb,
                   balance_amount_new
              from t_destroybill t1
             inner join t_bill_destroy_record t2
                on t1.destroybill_no = t2.bill_no
             where t2.record_id in
                   (select record_id
                      from t_destroy_record
                     where operation_id = 5
                       and to_char(to_date(substr(record_time, 1, 10),
                                           'yyyy-MM-dd'),
                                   'yyyyMMdd') between start_date and
                           end_date)) a
      left join t_spec_system b
        on (a.system_id = b.system_id)
      left join t_carrier g
        on (a.calling_carrier_id = g.carrier_id)
      left join t_carrier h
        on (a.billing_carrier_id = h.carrier_id)
      left join t_sett_service k
        on (a.service_id = k.service_id)
      left join t_exchange n
        on (a.exchange_id = n.exchange_id)
     Order By a.settle_flag,
              k.service_no,
              k.service_name,
              k.serviceattri,
              a.endbilldate;

  --006

  insert into t_report_if_advance
    select a.ADVANCE_NO,
           d.carrier_name,
           case
             when a.WARRANT_NO_TEMP is null then
              b.BANK_WARRANT_NO
             else
              a.WARRANT_NO_TEMP
           end,
           a.REC_DATE,
           c.EXCHANGE_NAME,
           a.AMOUNT,
           a.AMOUNT_RMB,
           a.BALANCE,
           a.BALANCE_RMB,
           ifmonth,
           '1'
      from t_advance_detail a
      left join t_rec_pay_record b
        on (a.rec_pay_id = b.record_id)
      left join t_exchange c
        on (a.exchange_id = c.exchange_id)
      left join t_carrier d
        on (a.carrier_id = d.carrier_id)
      left join t_spec_system f
        on (a.operation_id = f.system_id)
     where 1 = 1
       and d.carrier_name not like '%(原割接)'
       AND d.bill_cycle_flag = '集团国际部'
     Order By a.advance_no;
  --007

  insert into t_report_if_bail
    select a.BAIL_NO,
           d.carrier_name,
           case
             when a.warrant_no_temp is null then
              b.bank_warrant_no
             else
              a.warrant_no_temp
           end,
           a.REC_DATE,
           c.EXCHANGE_NAME,
           a.AMOUNT,
           a.AMOUNT_RMB,
           a.BALANCE,
           a.BALANCE_RMB,
           ifmonth,
           '1'
      from t_bail_detail a
      left join t_rec_pay_record b
        on (a.rec_pay_id = b.record_id)
      left join t_exchange c
        on (a.exchange_id = c.exchange_id)
      left join t_carrier d
        on (a.carrier_id = d.carrier_id)
      left join t_spec_system f
        on (a.operation_id = f.system_id)
     where 1 = 1
       and d.carrier_name not like '%(原割接)'
       and a.operation_id = 5
       AND d.bill_cycle_flag = '集团国际部'
     Order By a.bail_no;
  --008

  insert into t_report_if_rp
    select report_month,
           center,
           period,
           types,
           property,
           carrier_name,
           customer_number,
           currency,
           duration,
           amount,
           round(basiccurrency, 2),
           reference_no,
           ifmonth,
           '0'
      from (select mra.report_month,
                   o.center,
                   mra.period,
                   bi.types,
                   bi.property,
                   c.carrier_name as carrier_name,
                   c.customer_number,
                   c.sales_person,
                   c.location,
                   mra.currency,
                   sum(mra.duration) duration,
                   sum(mra.amount) amount,
                   case mra.currency
                     when 'RMB' then
                      sum(mra.amount)
                     when 'USD' then
                      sum(mra.amount) * ter.exchange_rate
                     else
                      sum(mra.amount) * ter.exchange_rate *
                      ter2.exchange_rate
                   end basiccurrency,
                   reference_no,
                   note,
                   case nvl(r.review_flag, 0)
                     when 1 then
                      '审核'
                     else
                      '未审核'
                   end review_flag,
                   r.review_staff,
                   r.review_date,
                   case mra.oa
                     when 0 then
                      'OA'
                     else
                      '已签署'
                   end oa
              from t_month_rp_account mra
              left join t_business_info bi
                on mra.business_id = bi.id
              left join t_carrier c
                on c.carrier_id = mra.carrier_id
              left join t_organ o
                on o.organ_id = c.organ_id
              left join (select distinct report_month,
                                        carrier_id,
                                        review_flag,
                                        data_type,
                                        review_staff,
                                        review_date
                          from t_month_rp_review) r
                on r.carrier_id = mra.carrier_id
               and mra.report_month = r.report_month
               and r.data_type = 1
              left join t_exchange_rate ter
                on ter.exchange_month = mra.report_month
               and ter.change_currency = 0
               and ter.currency = 1
               and ter.audit_flag = 1
              left join t_exchange_rate ter2
                on ter2.exchange_month = mra.report_month
               and ter2.change_currency = 1
               and ter2.currency = 2
               and ter2.audit_flag = 1
             where rownum >= 0
               and ((mra.duration - mra.amount) != 0)
               AND mra.report_month = ifmonth
             group by mra.report_month,
                      o.center,
                      mra.period,
                      bi.types,
                      bi.property,
                      c.carrier_name,
                      c.customer_number,
                      c.sales_person,
                      c.location,
                      mra.currency,
                      reference_no,
                      note,
                      r.review_flag,
                      r.review_staff,
                      r.review_date,
                      mra.oa,
                      ter.exchange_rate,
                      ter2.exchange_rate,
                      mra.amount
             order by mra.report_month,
                      c.carrier_name,
                      mra.period,
                      bi.property desc,
                      bi.types,
                      mra.period);
  strrtn := 'ok';
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    strrtn := 'error';
    RAISE;
  
END PR_REPORT_IF;

```

