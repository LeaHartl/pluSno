%Second part of pluSnow scripts.

function[]=modul22_pluSnow();

make_fig=2; %enter 1 to make figures and save. enter 2 to skip figures.
c='h';  %enter 'd' for evalutaion of daily values, enter 'h' for evaluation of hours, 'e' for events

%-----------------------------------------------------------------
%set thresholds
cut_water= 1;   %minimum required change in water eq. (snow pillow) [mm]
cut_snow= 1.5; %minimum required change in snow depth [cm]
cut_wet= 0;   %maximum allowed wet bulb temperature  [°C]
cut_wind= 5;  %maximum allowed wind speed [m/s]
%----------------------------------------------------------------
%Choose station and date range. 
%uncomment the desired station or add new one.

%Kühtai
location='kuehtai'; %enter station name
alti=1970; %altitude of station (Kühtai)
a=datenum('1987022700', 'yyyymmddHH'); %ENTER Start date/time from file
b=datenum('2015052023', 'yyyymmddHH'); %ENTER End date/time from file

%if complete time series is to be used, uncomment this:
% a1=a;
% b1=b;

%otherwise uncomment desired date range or add new one.

a1=datenum('1987022700', 'yyyymmddHH'); %ENTER Start date/time from file
b1=datenum('1999093023', 'yyyymmddHH'); %ENTER End date/time from file

% a1=datenum('1999011000', 'yyyymmddHH'); %ENTER Start date/time from file
% b1=datenum('2011093023', 'yyyymmddHH'); %ENTER End date/time from file

% a1=datenum('2013100100', 'yyyymmddHH'); %ENTER Start date/time from file
% b1=datenum('2015052023', 'yyyymmddHH'); %ENTER End date/time from file
% 
% a1=datenum('2011100100', 'yyyymmddHH'); %ENTER Start date/time from file
% b1=datenum('2013093023', 'yyyymmddHH'); %ENTER End date/time from file

%------------------------------------------------------------------------
% %Weissfluh
% location='weissfluh';
% alti=2690; %WF
% a=datenum('2013100100', 'yyyymmddHH'); %ENTER Start date/time from file
% b=datenum('2015092923', 'yyyymmddHH'); %ENTER End date/time from file
% 
% % a1=a;
% % b1=b;
% 
% a1=datenum('2013100100', 'yyyymmddHH'); %ENTER Start date/time from file
% b1=datenum('2015052023', 'yyyymmddHH'); %ENTER End date/time from file

%------------------------------------------------------------------------
% %Kühroint
% location='kuehroint';
% alti=1420; %KR
%  a=datenum('2011010100', 'yyyymmddHH'); %ENTER Start date/time from file
%  b=datenum('2015120223', 'yyyymmddHH'); %ENTER End date/time from file
% % 
% % a1=datenum('2013100100', 'yyyymmddHH'); %ENTER Start date/time from file
% % b1=datenum('2015052023', 'yyyymmddHH'); %ENTER End date/time from file
% % 
% % 
% a1=datenum('2011100100', 'yyyymmddHH'); %ENTER Start date/time from file
% b1=datenum('2013093023', 'yyyymmddHH'); %ENTER End date/time from file

% a1=a;
% b1=b;


%-------------------------------------------------------------------------
%Wattner Lizum
% location='wattnerlizum';
% alti=2041; %WL
% 
%  a=datenum('2010100100', 'yyyymmddHH'); %ENTER Start date/time from file
%  b=datenum('2016123023', 'yyyymmddHH'); %ENTER End date/time from file
% % 
% a1=a;
% b1=b;
% % 
% % a1=datenum('2013100100', 'yyyymmddHH'); %ENTER Start date/time from file
% % b1=datenum('2015052023', 'yyyymmddHH'); %ENTER End date/time from file
% % % % % 
% a1=datenum('2011100100', 'yyyymmddHH'); %ENTER Start date/time from file
% b1=datenum('2013093023', 'yyyymmddHH'); %ENTER End date/time from file
% % % % 

if a1<a || b1>b
  error('ERROR. desired date range not available.');
  %uiwait(msgbox(warningMessage));
end
  

%-----------------------------MAIN FILE, DON'T CHANGE--------------------

%create subfolder for the location in current folder if it does not exist
%already. Name of subfolder: location_startdate_enddate_threshholds

fname =sprintf('%s_%s_%s_%s_%s%s%s%s', c, location, datestr(a1, 'yyyymmdd'), datestr(b1,'yyyymmdd'), num2str(cut_water), num2str(cut_snow), num2str(cut_wet), num2str(cut_wind));
if exist(fname, 'file')==0
mkdir(fname)
end

if strcmp(c, 'e')==1;
    edit_events(fname, a,a1,  b,b1, c, location, alti, cut_water, cut_snow, cut_wet, cut_wind)

    return
end


%---------read data file----------------------------------------------
folder_data='module1_out';
folder1=[pwd '\' folder_data '\'];
filename =[folder1 c '_' datestr(a, 'yyyymmdd') '_' datestr(b,'yyyymmdd') location '.txt'];
x=fopen(filename);
C=textscan(x, '%f %f %f %f %f %f %f %f %f %f' , 'delimiter', 'tab', 'headerlines',1);
fclose(x); 
timenr=C{2};
%assign data array with all variables for easier handling
data(:,1)=C{1}; data(:,2)=C{2}; data(:,3)=C{3}; data(:,4)=C{4}; data(:,5)=C{5}; data(:,6)=C{6}; data(:,7)=C{7}; data(:,8)=C{8}; data(:,9)=C{9};

%cut off time range that as desired (start a1, end b1).
aa=find(timenr==a1);
bb=find(timenr==b1);

data(bb+1:end,:)=[];
data(1:aa-1,:)=[];

%assign variables
datum=data(:,1); timenr=data(:,2); glow=data(:,3); rf=data(:,4); tl=data(:,5); ff=data(:,6); rr=data(:,7); water=data(:,8); snow=data(:,9);

%--------------------------------------------------------------------- 


%------------wetbulb temperature--------------------------------------
%calculate mean air pressure using simple barometric formula with altitude (for psychrometric formula) 
press=1013.25.*exp((alti.*(-1))./7290);

%wetbulb T calculated in subfunction wetbulb.mat (old script by marc
%olefs). this is very slow, avoid if possible. Check if wetbulb T already
%exists, if so use existing wetbulb T. If not, call wetbulb.mat and write
%output to file, which can be used in the future. 

filename22 =['wet_', c, datestr(a1, 'yyyymmdd'),'_', datestr(b1, 'yyyymmdd'), '_', location, '.out'] ;
if exist(filename22, 'file')==2
 %file with wetbulb T already exists, use this.   
 file3=fopen(filename22);
 E=textscan(file3, '%f', 'headerlines',0);
 fclose(file3);
 wet=E{1};
else
  % File does not exist. print warning.
  warningMessage = sprintf('Warning: cannot find wetbulb file, calling wetbulb sub');
  uiwait(msgbox(warningMessage));
  %call wetbulb subfunction
  wet=wetbulb(tl, rf, press);
  datawet(:,1)=wet;
  %write file with wetbulb T for future use
  dlmwrite(filename22,datawet,' ');
end
%---------------------------------------------------------------------

%call edit_data.mat to delete unwanted values, calculate density from new snow height and snow pillow, assign
%variables etc. dichte1 is density with just precipitation signal filter, dichte is density
%with all filters applies

[dichte_corr, dichte1, dichte, glow, rf, tl, ff, rr, water, snow, wet, newsnow, newwater, timenr]=edit_data4(c, location, data, wet, cut_water, cut_snow, cut_wet, cut_wind, make_fig, a1, b1, fname);

%call densities.mat to compute density using approximations from
%literature.

[d_hedstrom, d_diamond, d_laChap, d_crocus, d_jordan, d_schmucki, d_lehning]=densities(tl, ff, rf);


%remove extreme density values at 5 and 95%------------------------------
percntiles = prctile(dichte,[5 95]); %5th and 95th percentile
outlierIndex = dichte < percntiles(1) | dichte > percntiles(2);
%remove percentile outlier values
dichte95=dichte;
dichte95(outlierIndex) = NaN;

dichte_corr95=dichte_corr;
dichte_corr95(outlierIndex) = NaN;

% %-------------------------------Linear Regression-----------------------
%create linear model fit using wet bulb temp., wind speed, and radiation.density is the response variable.

%create table structure X to use for model
X=table(wet, ff, glow, dichte95, 'VariableNames', {'wetbulb', 'wind', 'rad', 'dichte'}); 

%run stepwiselm and write output to text file (plain text!, filename: linearfit_StartDate_EndDate_location.txt) using diary
%function. Turn diary off after stepwise is finished. If output display of
%stepwiselm is supressed with a semicolon, diary does not capture
%everything so do not use ; in line 133. diary does not overwrite if run
%multiple times on the same file name, it adds to the file.
folder=[pwd '\' fname '\'];
diary_name=[folder c 'linearFit_' datestr(a1, 'yyyymmdd') '_' datestr(b1,'yyyymmdd') location '.txt'];
diary(diary_name);
mdl = stepwiselm(X,'constant','ResponseVar', 'dichte', 'upper', 'linear', 'verbose', 2)
diary 'off'


%predict response of 'mdl' linear regression with 'predict' function.
%create table structure XX to use with predict
XX =table(wet, ff, glow, 'VariableNames', {'wetbulb', 'wind', 'rad'}); 
dichte_pred = predict(mdl,XX); 


%----------------------------make stats-----------------------------------
%call makestats.mat to calculate some statistics and write to textfiles.
makestats(c, location, a1, b1, timenr, d_hedstrom, d_diamond, d_laChap, d_crocus, d_jordan, d_schmucki, d_lehning, dichte, dichte_corr95, dichte95, dichte_pred, glow, rf, tl, ff, rr, water, snow, newsnow, newwater, wet, fname);


nrevents=sum(~isnan(dichte95));
nrgrey=sum(~isnan(dichte1));

%---------------------Check whether to make figures------------------------
%calls subfunction sort_in_bins to sort densities into 1° wetbulb temperatur bins. Makes and saves figure "Bins_Fig".     
sort_in_bins_Jan2018(timenr, tl, ff, wet, dichte_corr95, location, fname, a1, b1); 
if make_fig==1;     

%calls subfunction sort_in_bins to sort densities into 1° wetbulb temperatur bins. Makes and saves figure "Bins_Fig".     
sort_in_bins(timenr, tl, ff, wet, dichte_corr95, location, fname, a1, b1);     
    
%make triple  plot
edges=nanmin(round(dichte95,-1)):10:nanmax(dichte95);
%figure('name', 'histogram density')
f=figure('name', 'triple');
%title([location, ' ', datestr(a1, 'dd mmm yyyy'), '-', datestr(b1, 'dd mmm yyyy') ], 'FontSize', 12);
%subplot(1,3,1)
axes1 = axes('Parent',f,...
    'Position',[0.108172689954926 0.107361477572559 0.4921875 0.815]);
hold(axes1,'on');

plot(timenr, dichte1, 'o', 'MarkerEdgeColor',[.6 .6 .6],'MarkerFaceColor',[.6 .6 .6],'MarkerSize',6);
hold on
plot(timenr, dichte, 'o', 'MarkerEdgeColor','k','MarkerFaceColor','k','MarkerSize',6);
hold on
plot(timenr, dichte95, 'o', 'MarkerEdgeColor','r','MarkerFaceColor','r','MarkerSize',6);
%xlim([timenr(1) timenr(end)])
datetick('x','yyyy')
grid on
xlabel('Date')
box(axes1,'on');

%xlabel (['Date: ', datestr(a1, 'dd mmm yyyy'), '-', datestr(b1, 'dd mmm yyyy') ], 'FontSize', 10);
ylabel ('Density [kg m^{-3}]', 'Fontsize', 12);
ylim([0 500])
xlim([a1 b1])
set(gca, 'Fontsize', 12)
l=legend({['All data (' num2str(nrgrey) ' points)'], ['Filtered data '] , ['Outliers at 5 and 95% removed (' num2str(nrevents) ' points)']},'Location','northwest', 'FontSize',10,'FontWeight','bold');
%l=legend({'All data', 'Filtered data ', 'Outliers at 5 and 95% removed ' num2str(nrevents) 'events'}, 'Location','southoutside', 'FontSize',10,'FontWeight','bold');
%title([location, ' ', datestr(a1, 'dd mmm yyyy'), '-', datestr(b1, 'dd mmm yyyy') ], 'FontSize', 12);
%ha = axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');

% saveas(gcf,[fname,'/', c,'Show_removed_densities_Fig.fig'])
% saveas(gcf,[fname,'/', c,'Show_removed_densities_Fig.jpg'])

%s1=subplot(1,3,2);
axes2 = axes('Parent',f,...
    'Position',[0.64375 0.11 0.136979166666667 0.815]);

h=histogram(dichte95,edges);


h.FaceColor = 'k';
xlabel('Density [kg m^{-3}]');
ylabel('Number of events');
xlim([0 200])
ylim([0 max(h.Values)+2])

set(gca, 'Fontsize', 12)
%title([location, ' ', datestr(a1, 'dd mmm yyyy'), '-', datestr(b1, 'dd mmm yyyy'),', ',num2str(nrevents), ' events.' ], 'FontSize', 12);
grid on

%saveas(gcf,[fname,'/', c,'densityHistogram.fig'])
%saveas(gcf,[fname,'/', c,'densityHistogram.jpg'])
%--------------------------------------------------------------------------
%Make a plot showing all densities before threshholds and outlier removal
%is applied, as well as remaining densities. Save as
%"Show_removed_densities_Fig"



   %compaction comparison. plot only for hourly data
    %if strcmp(c, 'h')==1
%f=figure('name', 'compaction');

%subplot(1,3,3)
X=[dichte95, dichte_corr95];
axes3 = axes('Parent',f,...
    'Position',[0.825382401405275 0.104571826783171 0.148859678758149 0.815243599124739]);
boxplot(X, 'symbol', '+');
set(gca,'xticklabel',{'Uncorrected', 'Corrected'},'Fontsize', 12)
set(gca, 'FontSize', 12); 
ylabel('Density [kg m^{-3}]')
grid on    

set(axes3,'FontSize',12,'TickLabelInterpreter','none','XTick',[1 2],...
    'XTickLabel',{'Uncorrected','Corrected'});
 pos = get(f,'position');
 set(f,'position',[pos(1:2)/4 pos(3:4)*2]);

% saveas(gcf,[fname,'/', c, 'CompactionCorr.fig'])
% saveas(gcf,[fname,'/', c, 'CompactionCorr.jpg'])

saveas(gcf,[fname,'/', c, 'Triple.fig'])
saveas(gcf,[fname,'/', c, 'Triple.jpg'])
saveas(gcf,[fname,'/', c, 'Triple.eps'])
  %  end
    
 

else end



% % % -----------------write output---------------------------------------

% %make file name (kuehtai_start_ende.out), write to folder module2_out
nmbrs=[sum(~isnan(dichte1)) sum(~isnan(dichte95))];

folder=[pwd '\' fname '\'];
filename11 =[folder c '_' datestr(a1, 'yyyymmdd') '_' datestr(b1,'yyyymmdd') '_numbers_' location '.txt'];
header1= {'grau', 'rot'};
fid=fopen(filename11, 'wt');
fprintf(fid, '%s\t', header1{:});
fprintf(fid, '\n');
fclose(fid);
%write file
dlmwrite(filename11,nmbrs,'delimiter','\t', 'newline', 'pc', 'precision',18, '-append');
%%




% %write data to file (round values to 2 decimals)
data_merged_H(:,1)=timenr;
data_merged_H(:,2)=dichte95;
data_merged_H(:,3)=dichte_pred;
data_merged_H(:,4)=d_hedstrom;
data_merged_H(:,5)=d_diamond;
data_merged_H(:,6)=d_laChap;
data_merged_H(:,7)=d_crocus;
data_merged_H(:,8)=d_jordan;
data_merged_H(:,9)=d_schmucki;
data_merged_H(:,10)=d_lehning;
data_merged_H(:,11)=wet;
data_merged_H(:,12)=tl;
data_merged_H(:,13)=rf;
data_merged_H(:,14)=ff;
data_merged_H(:,15)=dichte_corr;

% %make file name (kuehtai_start_ende.out), write to folder module2_out

filename11 =[folder c '_' datestr(a1, 'yyyymmdd') '_' datestr(b1,'yyyymmdd') '_' num2str(cut_water) '_' num2str(cut_snow) '_' num2str(cut_wet) '_' num2str(cut_wind) '_' location '.txt'];
header1= {'date', 'density','density_predicted', 'hedstrom', 'diamond', 'laChapelle', 'crocus', 'jordan', 'schmucki', 'lehning', 'Tw [°C]', 'Tair [°C]', 'rel hum [%]', 'windsp [m/s]', 'density_corrected'};
fid=fopen(filename11, 'wt');
fprintf(fid, '%s\t', header1{:});
fprintf(fid, '\n');
fclose(fid);
%write file
dlmwrite(filename11,data_merged_H,'delimiter','\t', 'newline', 'pc', 'precision',18, '-append');

%MAT FILES - create variable names that contain location string

filename_mat=[folder c '_' datestr(a1, 'yyyymmdd') '_' datestr(b1,'yyyymmdd') '_' num2str(cut_water) '_' num2str(cut_snow) '_' num2str(cut_wet) '_' num2str(cut_wind) '_' location '.mat'];
save(filename_mat, 'timenr', 'dichte95', 'dichte_pred', 'd_hedstrom', 'd_diamond', 'd_laChap', 'd_crocus', 'd_jordan', 'd_schmucki', 'd_lehning', 'wet', 'tl', 'rf', 'ff', 'dichte_corr')

end
