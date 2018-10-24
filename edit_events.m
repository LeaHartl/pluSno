function[]=edit_events(fname, a,a1,  b,b1, c, location, alti, cut_water, cut_snow, cut_wet, cut_wind);
    %---------read data file----------------------------------------------
folder_data='module1_out';
folder1=[pwd '\' folder_data '\'];
filename =[folder1 c '_' datestr(a, 'yyyymmdd') '_' datestr(b,'yyyymmdd') location '.txt'];
x=fopen(filename);
C=textscan(x, '%f %f %f %f %f %f %f %f %f %f' , 'delimiter', 'tab', 'headerlines',1);
fclose(x); 
%assign data array with all variables for easier handling
data(:,1)=C{1}; data(:,2)=C{2}; data(:,3)=C{3}; data(:,4)=C{4}; data(:,5)=C{5}; data(:,6)=C{6}; data(:,7)=C{7}; data(:,8)=C{8}; data(:,9)=C{9};data(:,10)=C{10}; 

startD=data(:,1);
timenr=datenum(num2str(startD), 'yyyymmddHH');
%cut off time range that as desired (start a1, end b1).
aa=find(timenr<a1);
bb=find(timenr>b1);

data(bb+1:end,:)=[];
data(1:aa-1,:)=[];

%assign variables
startD=data(:,1); duration=data(:,2); glow=data(:,3); rf=data(:,4); tl=data(:,5); ff=data(:,6); rr=data(:,7); water_N=data(:,8); snow_N=data(:,9);  snow_N_C=data(:,10); 

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
%%
%startD=data(:,1); duration=data(:,2); glow=data(:,3); rf=data(:,4); tl=data(:,5); ff=data(:,6); rr=data(:,7); water_N=data(:,8); snow_N=data(:,9); 

%find and delete instances where SWE increase is 0 (snow increase is never
%0 due to minimum snow rate criterium defining events
% nono=find(water_N==0);
% 
% %find and delete data where no precipitation signal is present
% dry=find(rr<=0);
% ww_c=find(water_N<cut_water); 
% 
% 
% data(dry, :)=NaN;
% data(ww_c, :)=NaN;
% wet(dry)=NaN;
% wet(ww_c)=NaN;
% % %find and delete data that does not fulfill threshold criteria
% % warm=find(wet>cut_wet); 
% % sno=find(newsnow<cut_snow); 
% ff_c=find(ff>cut_wind);
%  
% %delete
% data(nono, :)=NaN;
% data(ff_c, :)=NaN;
% 
% for i=1:length(data);
%  if sum(isnan(data(i,:)))>0;
%     data(i,:)=NaN
%  end
% end
% 
% wet(ff_c)=NaN;
% wet(nono)=NaN;


startD=data(:,1); duration=data(:,2); glow=data(:,3); rf=data(:,4); tl=data(:,5); ff=data(:,6); rr=data(:,7); water_N=data(:,8); snow_N=data(:,9); 

%calulate density: dichte= (dichte Wasser (1000kg/m3) * ww in m) / Neuschnee in m
dichte=(water_N)./(snow_N./100);
[mx, ind]=max(dichte);

bugs=find(dichte>1000);
dichte(bugs)=NaN;


[d_hedstrom, d_diamond, d_laChap, d_fassnacht, d_jordan, d_schmucki, d_lehning ]=densities(tl, ff, rf);

%if make_fig==1;    
%-------------------------------------------------------------------------
%make and save scatter plots of density versus wetbulb temperature and wind
figure('name', 'scatter')
subplot(2,1,1)
 scatter(wet, dichte, 'k*');
 %ylim([nanmin(dichte) nanmax(dichte)])
 %xlim([nanmin(wet2) nanmax(wet2)])
 lsline
 ylabel('Density [kg m^{-3}]', 'FontSize', 12);
 xlabel('Tw [°C]', 'FontSize', 12);
 set(gca, 'FontSize', 12); 
 title([location, ' ', datestr(a, 'dd mmm yyyy'), '-', datestr(b, 'dd mmm yyyy') ], 'FontSize', 12);
grid on

subplot(2,1,2)
 scatter(duration, dichte, 'k*');
 ylim([nanmin(dichte) nanmax(dichte)])
 xlim([nanmin(0) nanmax(duration)])
 lsline
 ylabel('Density [kg m^{-3}]', 'FontSize', 12);
 xlabel('Duration [h]', 'FontSize', 12);
 set(gca, 'FontSize', 12); 
 
 grid on
 
saveas(gcf,[fname,'/', c,' Scatter_density_duration_Tw.fig'])
saveas(gcf,[fname,'/', c,' Scatter_density_duration_Tw.jpg'])


dichte95=dichte;
%else end
folder=[pwd '\' fname '\'];
%%%%write output
% % % -----------------write output---------------------------------------
% %write data to file (round values to 2 decimals)

data_merged_H(:,1)=startD;
data_merged_H(:,2)=duration;
data_merged_H(:,3)=dichte95;
data_merged_H(:,4)=d_hedstrom;
data_merged_H(:,5)=d_diamond;
data_merged_H(:,6)=d_laChap;
data_merged_H(:,7)=d_fassnacht;
data_merged_H(:,8)=d_jordan;
data_merged_H(:,9)=d_schmucki;
data_merged_H(:,10)=d_lehning;
data_merged_H(:,11)=wet;
data_merged_H(:,12)=tl;
data_merged_H(:,13)=rf;
data_merged_H(:,14)=ff;
%data_merged_H(:,15)=dichte_corr;

% %make file name (kuehtai_start_ende.out), write to folder module2_out

filename11 =[folder c '_' datestr(a1, 'yyyymmdd') '_' datestr(b1,'yyyymmdd') '_' num2str(cut_water) '_' num2str(cut_snow) '_' num2str(cut_wet) '_' num2str(cut_wind) '_' location '.txt'];
header1= {'Start', 'duration','density', 'hedstrom', 'diamond', 'laChapelle', 'fassnacht', 'jordan', 'schmucki', 'lehning', 'Tw [°C]', 'Tair [°C]', 'rel hum [%]', 'windsp [m/s]'};
fid=fopen(filename11, 'wt');
fprintf(fid, '%s\t', header1{:});
fprintf(fid, '\n');
fclose(fid);
%write file
dlmwrite(filename11,data_merged_H,'delimiter','\t', 'newline', 'pc', 'precision',18, '-append');

%MAT FILES - create variable names that contain location string

filename_mat=[folder c '_' datestr(a1, 'yyyymmdd') '_' datestr(b1,'yyyymmdd') '_' num2str(cut_water) '_' num2str(cut_snow) '_' num2str(cut_wet) '_' num2str(cut_wind) '_' location '.mat'];
save(filename_mat, 'timenr', 'duration', 'dichte95', 'd_hedstrom', 'd_diamond', 'd_laChap', 'd_fassnacht', 'd_jordan', 'd_schmucki', 'd_lehning', 'wet', 'tl', 'rf', 'ff')


end