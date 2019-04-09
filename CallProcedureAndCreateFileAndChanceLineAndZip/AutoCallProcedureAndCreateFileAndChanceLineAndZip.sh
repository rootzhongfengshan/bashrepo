. /issdata/application/appiss/.profile
echo "get begging"
month=`date +%m |sed 's/$/b12a01a02a03a04a05a06a07a08a09a10a11a12/;
s/^\(..\)b.*\(..\)a\1.*/\2/'`
year=`date +%Y`
report_month="$year$month"
date
sqlplus zh/zh10g-0607@zh10g << sql
declare
    imonth varchar2(6);
    strrtn varchar2(8);
    countnum NUMBER;
    begin   
  select to_char(add_months(sysdate,-1),'YYYYMM') into imonth from dual;
  SELECT count(*) INTO countnum FROM t_report_if_carrier WHERE bill_cycle=imonth;
  IF (countnum=0) THEN
  Dbms_Output.put_line(imonth+':'+countnum);
  PR_REPORT_IF(imonth,strrtn);
   END IF;
    end;
	  /
sql
cd /issdata/application/appiss/workforzhongfs/jffile/
rm -rf $report_month
mkdir $report_month
cd $report_month
echo "get begging" >> $report_month.log
date >> $report_month.log
sqlplus zh/zh10g-0607@zh10g @/issdata/application/appiss/workforzhongfs/jfSent/spoll_file.sql $report_month >> $report_month.log
for file in CMBFY*
	do
	sed 's/[[:space:]][[:space:]]*$//g' $file>$file-sed
	awk '{ print $0"\r" }'<$file-sed > $file-fs
	echo $file >> $report_month.log
done
mkdir afterdeal
mv *.000-fs afterdeal/
cd afterdeal
for i in `ls`
	do 
	filename=`echo ${i} |cut -f 1 -d "."`
	mv -f $i `echo $filename".000"`
done
zip $report_month.zip *

