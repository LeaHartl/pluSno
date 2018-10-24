function[a, b, step, datum, schnee, rf, tl, kissen, ff, glow, rr]=kuehroint(location)
%---------read edited data file. file must contain full days and hours, i.e. start at
%0000, end at 2350 HHMM if data is collected every 10 minutes.


%ENTER TIME STEP HERE. FOR THIS FILE: 10 minutes between data points.
step=10; %Kühroint

%Kühroint
a=datenum('201101010000', 'yyyymmddHHMM');%Kühroint
b=datenum('201512022350', 'yyyymmddHHMM');%Kühroint

filename = 'Z:\Daten\Projekte\pluSnow\Daten\edited\kühroint\daten_kuehroint_173822_ed2.csv' ;
x=fopen(filename);
C=textscan(x, '%f %f %f %f %f %f %f %f %f %f ' , 'delimiter', ';', 'headerlines',1);
fclose(x);
 
%assign variables, file contains datum, stdmin, gs_o, schnee, rf, tl, rr, ff, ws_gr, qflag_plsnw1
datum=C{1}; stdmin=C{2};
data(:,1)=C{1}; data(:,2)=C{2}; data(:,3)=C{3}; data(:,4)=C{4}; data(:,5)=C{5}; data(:,6)=C{6}; data(:,7)=C{7}; data(:,8)=C{8}; data(:,9)=C{9}; data(:,10)=C{10} ;

%replace -9999 with NaNs and set data to NaN if flag not zero
no=find(data(:,:)==-9999);
data(no)=NaN;

flag=find(data(:,10)~=0);
data(flag,1:9)=NaN;

%assign parameter arrays
glow=data(:,3); schnee=data(:,4); rf=data(:,5); tl=data(:,6); rr=data(:,7); ff=data(:,8); kissen=data(:,9); 

end
%--------------------------------------------------------------------