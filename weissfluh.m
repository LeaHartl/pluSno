%function to read data from Weissfluh files. Radiation and precipitation
%are in separate files and have different time steps and start/end dates.
%weissfluh.mat calls wf_strahl.mat and wf_rr.mat to deal with this and
%incorporate radiation and precipitation into the rest of the data.

function[a, b, step, datum, schnee, rf, tl, kissen, ff, glow, rr]=weissfluh(location);


step=30; %time step in data


%Weissfluh
a=datenum('201310010000', 'yyyymmddHHMM'); %Start date/time from file
b=datenum('201509292330', 'yyyymmddHHMM'); %End date/time from file


%---------read edited data file (must start at 0000, end at 2350 HHMM.
 filename = 'Z:\Daten\Projekte\pluSnow\Daten\edited\Weissfluh\weissfluh_rest.csv' ;

 x=fopen(filename);
 C=textscan(x, '%f %f %f %f %f %f %f %f %f %f ' , 'delimiter', ';', 'headerlines',1);
 fclose(x); 

%assign variables, file contains statnr, datum, stdmin, schnee, rf, tl, schneekissen, ff, dd, qflag_plsnw1
datum=C{2}; stdmin=C{3};
data(:,1)=C{2}; data(:,2)=C{3}; data(:,3)=C{4}; data(:,4)=C{5}; data(:,5)=C{6}; data(:,6)=C{7}; data(:,7)=C{8}; data(:,8)=C{9}; data(:,9)=C{10}; 

%%check for gaps, create vector of datenums called 'time'
time=[a:1/(24*2):b];      %30 minute steps                  


%replace -9999 with NaNs and set data to NaN if flag not zero
no=find(data(:,:)==-9999);
data(no)=NaN;

flag=find(data(:,9)~=0);
data(flag,1:8)=NaN;

%assign parameter arrays
schnee=data(:,3); rf=data(:,4); tl=data(:,5); kissen=data(:,6); ff=data(:,7); 

%convert to full units
rf=rf./10;
tl=tl./10;
ff=ff./10;

%call function that reads radiation and picks 30min value from original data
%(saved in 2min intervals)
[t_strahl, glow]=wf_strahl();

%cut rad to match other parameters
stcut=find(t_strahl==a);
stcut2=find(t_strahl==b);

glow(1:(stcut-1))=[];
glow((stcut2+1):end)=[];
glow=glow';

%call function that reads precipitation and makes 30min sum from original data
%(saved in 10min intervals)
[t_rr, rr]=wf_rr();

%cut rr to match other parameters
rrcut=find(t_rr==a);
rrcut2=find(t_rr==b);

rr(1:(rrcut-1))=[];
rr((rrcut2+1):end)=[];
rr=rr';

end
