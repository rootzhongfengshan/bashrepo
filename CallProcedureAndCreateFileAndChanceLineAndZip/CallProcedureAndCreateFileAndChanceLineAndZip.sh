. /issdata/application/appiss/.profile
echo "get begging"
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
rm -rf $1
mkdir $1
cd $1
echo "get begging" >> $1.log
date >> $1.log
sqlplus zh/zh10g-0607@zh10g @/issdata/application/appiss/workforzhongfs/jfSent/spoll_file.sql $1 >> $1.log
for file in CMBFY*
	do
	sed 's/[[:space:]][[:space:]]*$//g' $file>$file-sed
	awk '{ print $0"\r" }'<$file-sed > $file-fs
	echo $file >> $1.log
done
mkdir afterdeal
mv *.000-fs afterdeal/
cd afterdeal
for i in `ls`
	do 
	filename=`echo ${i} |cut -f 1 -d "."`
	mv -f $i `echo $filename".000"`
done
zip $1.zip *

