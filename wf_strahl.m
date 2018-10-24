function[time2, kw_o2]=wf_strahl()
clear all

%---------read edited data file (must start at 0000, end at 2350 HHMM.
 filename = 'Z:\Daten\Projekte\pluSnow\Daten\edited\Weissfluh\weissfluh_strahl.csv' ;

 x=fopen(filename);
 C=textscan(x, '%f %f %f %f %f %f ' , 'delimiter', ';', 'headerlines',1);
 fclose(x); 

%assign variables, file contains datum, stdmin, kw_o, kwflag, lw_o, lw_flag
datum=C{1}; stdmin=C{2};
data(:,1)=C{3}; data(:,2)=C{4}; data(:,3)=C{5}; data(:,6)=C{6}; 

%%check for gaps, create vector of datenums called 'time'
size(datum);
a=datenum('201310010000', 'yyyymmddHHMM'); %Start date/time from file
b=datenum('201509302358', 'yyyymmddHHMM'); %End date/time from file
time=[a:1/(24*30):b];      %2 minute steps                  
size(time);

%replace -9999 with NaNs and set data to NaN if flag not zero
no=find(data(:,:)==-9999);
data(no)=NaN;

% flag=find(data(:,2)~=0);
% data(flag,1)=NaN;

%assign parameter arrays
kw_o=data(:,1); 
kw_o=kw_o./10;

lw_o=data(:,3); 
lw_o=lw_o./10;

%pick half hour values from 5 minute rad values.
time2=[a:1/(24*2):b]; %timestamp for half hourly values
kw_o2=hourly(kw_o);


function[valueHourly]=hourly(valueIn);
value=reshape(valueIn,15, length(valueIn)/15);
valueHourly=value(1,:);
end
end
