function[a, b, step, datum, schnee, rf, tl, kissen, ff, glow, rr]=kuehtai(location)
%---------read edited data file. file must contain full days and hours, i.e. start at
%0000, end at 2350 HHMM if data is collected every 10 minutes.


step=15; %time step in data

%Kühtai
a=datenum('198702270000', 'yyyymmddHHMM'); %ENTER Start date/time from file
b=datenum('201505202345', 'yyyymmddHHMM'); %ENTER End date/time from file


%the file used here contains variables and quality flags for each variable.
%%Kühtai
filename = 'Z:\Daten\Projekte\pluSnow\Daten\edited\Kühtai\kühtai_edited_lang_new.csv' ;
%filename = 'kuehtai_all2.csv';
x=fopen(filename);
C=textscan(x, '%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f ' , 'delimiter', ';', 'headerlines',1);
fclose(x); 

%--------------------------------------------------------------------- 

%-----------------------assign variables.----------------------------- 
%the file used here contains: st_nr, datum, schnee, rf, rf_f, tl, tl_f, rr, rr_f, glow, glow_f, kissen, kissen_f, ff, ff_f
%_f variables are quality flags. 
datum=C{2}; %Date. Date format: yyyymmdd (e.g. 20131101)
stdmin=C{3}; %Time. Time format: HHMM (e.g. 2300)



%assign array 'data' containing all variables, may not be necessary
%depending on NaN values and flags in data. If flags are always the same,
%data could be used to delete bad values in one step, rather than for each
%variable. 
data(:,1)=C{1}; data(:,2)=C{2}; data(:,3)=C{3}; data(:,4)=C{4}; data(:,5)=C{5}; data(:,6)=C{6}; data(:,7)=C{7};
data(:,8)=C{8}; data(:,9)=C{9}; data(:,10)=C{10}; data(:,11)=C{11}; data(:,12)=C{12}; data(:,13)=C{13}; data(:,14)=C{14}; 
data(:,15)=C{15}; data(:,16)=C{16}; 





%----------------NaNs and quality flags------------------------------
%replace -9999 with NaNs
no=find(data(:,:)==-9999);
data(no)=NaN;

%assign single arrays for each variable
schnee=data(:,4); rf=data(:,5); rf_f=data(:,6); tl=data(:,7); tl_f=data(:,8); rr=data(:,9); rr_f=data(:,10); 
glow=data(:,11); glow_f=data(:,12); kissen=data(:,13); kissen_f=data(:,14); ff=data(:,15); ff_f=data(:,16);
%---------------------------------------------------------------------
%schnee from mm to cm
schnee=schnee./100;
plot([1:length(schnee)], schnee)

%set data to NaN if flag not zero. (This has to be adjusted depending on
%the flags!)
% flags=find(schnee_f~=0);
% schnee(flags)=NaN;

flags2=find(rf_f~=0);
rf(flags2)=NaN;

flags3=find(tl_f~=0);
tl(flags3)=NaN;

flags4=find(rr_f~=0);
rr(flags4)=NaN;

flags5=find(glow_f~=0);
glow(flags5)=NaN;

flags6=find(kissen_f~=0);
kissen(flags6)=NaN;

%wind flag is ignored in example file (Kühtai), because most wind data is
%flagged as interpolated from somewhere else. All wind data is used. 

end
%--------------------------------------------------------------------