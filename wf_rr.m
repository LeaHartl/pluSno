function[time2, rr_2]=wf_rr();
clear all

%---------read edited data file (must start at 0000, end at 2350 HHMM.
 filename = 'Z:\Daten\Projekte\pluSnow\Daten\edited\Weissfluh\weissfluh_rr.csv' ;

 x=fopen(filename);
 C=textscan(x, '%f %f %f %f %f %f ' , 'delimiter', ';', 'headerlines',1);
 fclose(x); 

%assign variables, file contains statnr, datum, stdmin, datumsec, rr, rr_f
datum=C{2}; stdmin=C{3};
 
%%check for gaps, create vector of datenums called 'time'
size(datum);
a=datenum('201310010000', 'yyyymmddHHMM'); %Start date/time from file
b=datenum('201509302350', 'yyyymmddHHMM'); %End date/time from file
time=[a:1/(24*6):b];      %ten minute steps                  
size(time);

%assign parameter arrays
rr= C{5};

%replace -9999 with NaNs and set data to NaN if flag not zero
no=find(rr==-9999);
rr(no)=NaN;
%full units 
rr=rr./10;

%make half hour sums from 10 minute rr values.
time2=[a:1/(24*2):b]; %timestamp for half hourly values


rr(1)=[];
rr=[rr; NaN];
rr_2=hourlySum(rr);

rr_2=[NaN rr_2];
rr_2(end)=[];

function[valueHourly]=hourlySum(valueIn);
value=reshape(valueIn,3, length(valueIn)/3);
valueHourly=sum(value);
end


end