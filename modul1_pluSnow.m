%First part of pluSnow scripts. Reads input data, computes hourly and 
%daily values for the variables and writes these into output files. Snow 
%pillow and snow height values are smoother with a centered moving average.
%Radiation correction applied to snow height. This function calls the file 
%'fixgaps.mat', which should be in the same directory. All other 
%subfunctions are at the end of this file. 

function[]=modul1_pluSnow()

%choose whether to make daily or hourly means
mm='h'; %mm=h for hours, mm=d for daily.
events=1; %if events = 1, extra output file is written containing data for single precipation events, based on hourly values.

%enter location name. A subfunction is called where the data file for the
%location is read and variables are assigned. The subfunctions must have
%the same name as the string entered for location. case sensitive! e.g.:
%location: 'kuehtai', subfunction: kuehtai.m
  

%Uncomment desired station.

location='wattnerlizum';
%location='kuehtai';
%location='kuehroint';
%location='weissfluh';

subf = str2func(location);
[a, b, step, datum, schnee, rf, tl, kissen, ff, glow, rr]=subf(location);

fname =sprintf('module1_out');
if exist(fname, 'file')==0
mkdir(fname)
end

%--------check for gaps, make time vector-----------------------------
step_h=60/step;
time=[a:1/(24*step_h):b];  
%display error and quit function if there are problems with the number of
%data points

if (length(datum)~=length(time))
    disp('Gaps in data or start/end time not correct.');
    return
end
%--------------------------------------------------------------------
%snow pillow value: smooth data with moving average.
kissen22= movingAverage(kissen, 5); %centered, window size 5 (=>for 15min timesteps this is slighty more than 1 hour)
%snow height: correct radiation spikes. if rad > 30 set to NaN, linearly
%interpolate gap. (calls 'fixgaps.mat')
radcor=find(glow>30);
schnee_c=schnee;
schnee_c(radcor)=NaN;
schnee_c=fixgaps(schnee_c);

%smooth corrected snow height data with same moving average as snow pillow
schnee_c_smoo=movingAverage(schnee_c, 5);



%%
if mm=='h';
%-----------------hourly means---------------------------------------
timeH=[a:1/24:b]; %time vector for hourly values

%call subfunction to make hourly means
glow_H=hourlyMean(glow, step_h); %radiation
rf_H=hourlyMean(rf, step_h);     %relative humidity   
tl_H=hourlyMean(tl, step_h);     %air temp
ff_H=hourlyMean(ff, step_h);     %wind speed   

%call subfunction to make hourly sums
rr_H=hourlySum(rr, step_h);     %precip
 
%call subfunction to pick full-hour value
kissen_H=hourly(kissen22, step_h);

%call subfunction to pick full-hour value
schnee_H=hourly(schnee_c_smoo, step_h);
%schnee2_H=hourly(schnee2, step_h);
%uncorrected hourly snowheight:
schnee_H0=hourly(schnee, step_h);


% % -----------------write output---------------------------------------

datnum=str2num(datestr(timeH, 'yyyymmddHH'));
%Save as .mat file
water_H=kissen_H;
folder=[pwd '\' fname '\'];
filename_m =[folder 'h_' datestr(a, 'yyyymmdd') '_' datestr(b,'yyyymmdd') location '.mat'];
save(filename_m, 'datnum', 'timeH', 'glow_H', 'rf_H', 'tl_H', 'ff_H', 'rr_H', 'water_H', 'schnee_H')


%write hourlies to file (round values to 2 decimals)
data_merged_H(:,1)=datnum;
data_merged_H(:,2)=timeH;
data_merged_H(:,3)=round(glow_H, 2);
data_merged_H(:,4)=round(rf_H, 2);
data_merged_H(:,5)=round(tl_H, 2);
data_merged_H(:,6)=round(ff_H, 2);
data_merged_H(:,7)=round(rr_H, 2);
data_merged_H(:,8)=round(kissen_H, 2);
data_merged_H(:,9)=round(schnee_H, 2);


%make file name (hours_kuehtai_start_ende.out), write to folder module1_out

filename1 =[folder 'h_' datestr(a, 'yyyymmdd') '_' datestr(b,'yyyymmdd') location '.txt'];
header1= {'date', 'datenr', 'rad [w/m2]', 'relhum [%]', 'airtemp [°C]', 'windsp [m/s]', 'prec [mm]', 'pillow [mm]', 'snow [cm]' };
fid=fopen(filename1, 'wt');
fprintf(fid, '%s\t', header1{:});
fprintf(fid, '\n');
fclose(fid);
%write file
dlmwrite(filename1,data_merged_H,'delimiter','\t', 'newline', 'pc', 'precision',18, '-append');



%%
if events==1;

tw_max = 24; %window to the left and right of max HS
HNrate = 0.5; %minimum HN rate [cm/h]

[event_start_index, event_end_index,snowSum, SWESum, duration]=find_events(schnee_H, kissen_H, tw_max, HNrate, timeH);


%mean values / sums of climate parameters during events
for j=1:length(event_end_index);
tl_ev(j)=nanmean(tl_H(event_start_index(j):event_end_index(j)));
glow_ev(j)=nanmean(glow_H(event_start_index(j):event_end_index(j)));
rf_ev(j)=nanmean(rf_H(event_start_index(j):event_end_index(j)));
ff_ev(j)=nanmean(ff_H(event_start_index(j):event_end_index(j)));
rr_ev(j)=nansum(ff_H(event_start_index(j):event_end_index(j)));
end
datnum_ev=str2num(datestr(timeH(event_start_index), 'yyyymmddHH'));

%Save as .mat file

folder=[pwd '\' fname '\'];
filename_m =[folder 'e_' datestr(a, 'yyyymmdd') '_' datestr(b,'yyyymmdd') location '.mat'];
save(filename_m, 'datnum_ev', 'duration', 'glow_ev', 'rf_ev', 'tl_ev', 'ff_ev', 'rr_ev', 'SWESum', 'snowSum')

% % -----------------write output---------------------------------------
%write dailies to file (round values to 2 decimals)
data_merged_D(:,1)=datnum_ev;
data_merged_D(:,2)=duration;
data_merged_D(:,3)=round(glow_ev, 2);
data_merged_D(:,4)=round(rf_ev, 2);
data_merged_D(:,5)=round(tl_ev, 2);
data_merged_D(:,6)=round(ff_ev, 2);
data_merged_D(:,7)=round(rr_ev, 2);
data_merged_D(:,8)=round(SWESum, 2);
data_merged_D(:,9)=round(snowSum, 2);



%make file name (events_kuehtai_start_ende.out), write to folder module1_out
folder=[pwd '\' fname '\'];
filename2 =[folder 'e_' datestr(a, 'yyyymmdd') '_' datestr(b,'yyyymmdd') location '.txt'];
header2= {'start of event', 'duration (h)', 'rad [w/m2]', 'relhum [%]', 'airtemp [°C]', 'windsp [m/s]', 'prec [mm]', 'SWE increase [mm]', 'snow increase [cm]'};
fid2=fopen(filename2, 'wt');
fprintf(fid2, '%s\t', header2{:});
fprintf(fid2, '\n');
fclose(fid2);

%write file
dlmwrite(filename2,data_merged_D,'delimiter','\t', 'newline', 'pc', 'precision',12, '-append');

end
end



%%
if mm=='d';
%-----------------daily means----------------------------------------

timeD=[a:1:b]; %time vector for daily values (this makes datenumbers corresponding to 00:00 oclock. to shift to 23:00: [a+23/24:1:b+23/24]

%call subfunction to make daily means
glow_D=dailyMean(glow, step_h); %radiation
rf_D=dailyMean(rf, step_h);     %relative humidity   
tl_D=dailyMean(tl, step_h);     %air temp
ff_D=dailyMean(ff, step_h);     %wind speed   

%call subfunction to make daily sums
rr_D=dailySum(rr, step_h);     %precip

%call subfunction to pick full-hour values
kissen_D=daily(kissen22, step_h);
schnee_D=daily(schnee_c_smoo, step_h);
%schnee2_D=daily(schnee2, step_h);

datnumD=str2num(datestr(timeD, 'yyyymmddHH'));
%Save as .mat file
water_D=kissen_D;
folder=[pwd '\' fname '\'];
filename_m =[folder 'd_' datestr(a, 'yyyymmdd') '_' datestr(b,'yyyymmdd') location '.mat'];
save(filename_m, 'datnumD', 'timeD', 'glow_D', 'rf_D', 'tl_D', 'ff_D', 'rr_D', 'water_D', 'schnee_D')

% % -----------------write output---------------------------------------
%write dailies to file (round values to 2 decimals)
data_merged_D(:,1)=str2num(datestr(timeD, 'yyyymmdd'));
data_merged_D(:,2)=timeD;
data_merged_D(:,3)=round(glow_D, 2);
data_merged_D(:,4)=round(rf_D, 2);
data_merged_D(:,5)=round(tl_D, 2);
data_merged_D(:,6)=round(ff_D, 2);
data_merged_D(:,7)=round(rr_D, 2);
data_merged_D(:,8)=round(kissen_D, 2);
data_merged_D(:,9)=round(schnee_D, 2);


%make file name (days_kuehtai_start_ende.out), write to folder module1_out
folder=[pwd '\' fname '\'];
filename2 =[folder 'd_' datestr(a, 'yyyymmdd') '_' datestr(b,'yyyymmdd') location '.txt'];
header2= {'date', 'datenr', 'rad [w/m2]', 'relhum [%]', 'airtemp [°C]', 'windsp [m/s]', 'prec [mm]', 'pillow [mm]', 'snow [cm]'};
fid2=fopen(filename2, 'wt');
fprintf(fid2, '%s\t', header2{:});
fprintf(fid2, '\n');
fclose(fid2);

%write file
dlmwrite(filename2,data_merged_D,'delimiter','\t', 'newline', 'pc', 'precision',12, '-append');

end
end


%--------------------------------------------------------------------
%--------------------------------------------------------------------
%--------------------------------------------------------------------
%------------subfunctions---------------

%daily

function[valueDaily]=daily(valueIn,step_h) %daily value=value at last time step of the day, e.g. 23:45
value=reshape(valueIn,step_h*24, length(valueIn)/(24*step_h));
valueDaily=value((24*step_h),:);
end

function[valueDaily]=dailyMean(valueIn,step_h) %daily mean= mean of values between 00:00 and 23:45
value=reshape(valueIn,step_h*24, length(valueIn)/(24*step_h));
valueDaily=mean(value);
end

function[valueDaily]=dailySum(valueIn,step_h) %daily sum= sum of values between 00:00 and 23:45
value=reshape(valueIn,step_h*24, length(valueIn)/(24*step_h));
valueDaily=sum(value);
end

%hourly

function[valueHourly]=hourly(valueIn,step_h) %hourly value=value at the full hour.
%delete first 00:00 value so sums are 12:10 to 1:00, i.e. hourly value of 1:00 is for 12:10-1:00. 
valueIn(1)=[];
valueIn=[valueIn; NaN];
value=reshape(valueIn,step_h, length(valueIn)/step_h);
valueHourly=value(step_h,:);
%add extra entry to match sum of hour before time step with correct time step
valueHourly=[NaN valueHourly];
valueHourly(end)=[];
end

function[valueHourly]=hourlyMean(valueIn, step_h) %hourly value=mean of previous hour.
    
%delete first 00:00 value so sums are 12:10 to 1:00, i.e. hourly value of 1:00 is for 12:10-1:00. 
valueIn(1)=[];
valueIn=[valueIn; NaN];
value=reshape(valueIn,step_h, length(valueIn)/step_h);
valueHourly=mean(value);
%add extra entry to match sum of hour before time step with correct time step
valueHourly=[NaN valueHourly];
valueHourly(end)=[];
end

function[valueHourly]=hourlySum(valueIn, step_h) %hourly value=sum of previous hour.
    
%delete first 00:00 value so sums are 12:10 to 1:00, i.e. hourly value of 1:00 is for 12:10-1:00. 
valueIn(1)=[];
valueIn=[valueIn; NaN];
value=reshape(valueIn,step_h, length(valueIn)/step_h);
valueHourly=sum(value);
%add extra entry to match sum of hour before time step with correct time step
valueHourly=[NaN valueHourly];
valueHourly(end)=[];
end

%moving average

function y = movingAverage(x, w)
   k = ones(1, w) / w;
   y = conv(x, k, 'same');
end

