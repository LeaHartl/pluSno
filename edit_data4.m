function[dichte_corr, dichte1, dichte, glow2, rf2, tl2, ff2, rr2, water2, snow2, wet2, newsnow2, newwater2, timenr]=edit_data4(c,location, data, wet, cut_water, cut_snow, cut_wet, cut_wind, make_fig, a1, b1, fname);

datum=data(:,1); timenr=data(:,2); glow=data(:,3); rf=data(:,4); tl=data(:,5); ff=data(:,6); rr=data(:,7); water=data(:,8); snow=data(:,9); 

%compute difference in snow height and water equivalent between time steps (=new
%snow)
newsnow=diff(snow);
newwater=diff(water);

%add NaN value at the beginning of these arrays so the number of data
%points matches 
newsnow=[NaN newsnow'];
newwater=[NaN newwater'];

%make new data array containing all variables
data1=[data(:,3:end) wet newsnow' newwater' ];

%find and delete instances where difference is negative, i.e. snow depth or
%water eq. decreases or snow increase is v. large
nono=find(newsnow<0);
nono1=find(newsnow>100);
nono2=find(newwater<0);

%find and delete data where no precipitation signal is present
dry=find(rr<=0);
%find data gaps in precip signal
norr=isnan(rr);


data1(nono, :)=NaN;
data1(nono1, :)=NaN;
data1(nono2, :)=NaN;
data1(dry, :)=NaN;
data1(norr, :)=NaN;
glow1=data1(:,1); rf1=data1(:,2); tl1=data1(:,3); ff1=data1(:,4); rr1=data1(:,5); water1=data1(:,6); snow1=data1(:,7); wet1=data1(:,8); newsnow1=data1(:,9); newwater1=data1(:,10); 


data2=data1;
%thershold for snow water equivalent
ww_c=find(data2(:,10)<cut_water); 
nr_ww=length(ww_c);

warm=find(data2(:,8)>cut_wet); 
nr_warm=length(warm);

sno=find(data2(:,9)<cut_snow); 
nr_sno=length(sno);

ff_c=find(data2(:,4)>cut_wind);
nr_ff=length(ff_c);

%test density w/out threshholds 
dichte1=data2(:,10)./(data2(:,9)./100);


%nmbrs=[sum(~isnan(data2(:,10))) nr_ww nr_warm nr_sno nr_ff]

%delete data that does not fulfill threshold criteria for temp, snow, swe and
%wind

data2(ww_c, :)=NaN;
data2(warm, :)=NaN; 
data2(sno, :)=NaN; 
data2(ff_c, :)=NaN;




glow2=data2(:,1); rf2=data2(:,2); tl2=data2(:,3); ff2=data2(:,4); rr2=data2(:,5); water2=data2(:,6); snow2=data2(:,7); wet2=data2(:,8); newsnow2=data2(:,9); newwater2=data2(:,10); 
 
%calulate density: dichte= (dichte Wasser (1000kg/m3) * ww in m) / Neuschnee in m
dichte=newwater2./(newsnow2./100);


%delete extreme outliers not elminated by thresholds if any exist
dichte(dichte>1000)=NaN;

%%
%Setzungskorrektur
%Neuschnee HN: 
HN = newsnow2;
SWE_HN = newwater2;
rho_HN = dichte;

%destructive:
set_destr=ones(size(rho_HN));
set_destr = -0.000002777 * exp(0.04 .* tl2);

%adjust for rho_HN greater than 150
high=find(rho_HN>150);
set_destr(high) = set_destr(high) .* exp(-0.046 .* (rho_HN(high) - 150));

%equation is for settling per second, multiply with 60sec * 60min for
%hourly values. uncomment option to adjust for different 'c' if desired
%if strcmp('h', c)==1
    time_inc = 60*60;
%end

% if strcmp('d', c)==1
%     time_inc = 60*60*24;
% end

    
%factor for destructive settling of newsnow per hour. factor is negative percentage.
set_destr = time_inc .* set_destr;

%correctted new snow depth in cm
HN_corr = HN ./(1+set_destr); 

%NO WEIGHT SETTLING FOR NEW SNOW.

%%
%Altschnee HS:
%compute density of entire snowpack one time step before the time step that is to be
%corrected
%rho_HS = 100 * SWE(t-1) / HS(t-1);

rho_HS=zeros(size(rho_HN)).*NaN; %initialize as vector of NaNs
%make density
rho_HS=water./(snow./100);
%shift by one time step
rho_HS=[NaN rho_HS(1:end-1)'];
rho_HS=rho_HS';


%destructive:
set_destr_HS=ones(size(rho_HS));
high_HS=find(rho_HS>150);


set_destr_HS = -0.000002777 * exp(0.04 .* tl2);   
set_destr_HS(high_HS) = set_destr_HS(high_HS) .* exp(-0.046 .* (rho_HS(high_HS) - 150));

%factor for destructive settling of newsnow per hour. factor is negative percentage.
set_destr_HS = time_inc * set_destr_HS;

%correction to be applied to snow depth at time t in cm (use snow depth of t-1 for calculation.
%shift by one time step

snow3=[NaN snow(1:end-1)'];
snow3=snow3';
set_destr_HS = set_destr_HS .* snow3;



%%
%weight:
set_weight = (-248.976.*SWE_HN./3600000 .* exp(0.08 .* tl) .* exp(-0.021 .* rho_HS)); %this uses rho of previous time step but SWE and tl of current time step. (??)

%factor for weight settling of oldsnow per hour. factor is negative percentage (?).
set_weight = time_inc .* set_weight;

set_weight = set_weight .* snow3;


%add the destructive and weight settling of old snow to corrected new snow
%depth
HN_corr2 = HN_corr - set_destr_HS - set_weight; % %SOLLTE DAS HIER NICHT set_destr_HS sein?
HN_corr2;

dichte_corr=(newwater2)./(HN_corr2./100);

%%

%--------------------------------figures-------------------------------
%check whether to make figures, make if var = 1, jump to end if var = 2

if make_fig==1;    
    
%for histogram plots

newsnow_pos=newsnow;
newsnow_pos(nono)=NaN;
newwater_pos=newwater;
newwater_pos(nono2)=NaN;

binsNS=ceil((nanmax(newsnow_pos)-nanmin(newsnow_pos))/0.5);
[counts_NS, centers_NS]=hist(newsnow_pos, binsNS);

binswet=ceil((nanmax(wet)-nanmin(wet))/0.5);
[counts_wet, centers_wet]=hist(wet, binswet);

binsWW=ceil((nanmax(newwater_pos)-nanmin(newwater_pos))/0.1);
[counts_WW, centers_WW]=hist(newwater_pos, binsWW);

binsWind=ceil((nanmax(ff)-nanmin(ff))/0.5);
[counts_ff, centers_ff]=hist(ff, binsWind);

%number of values not NaN
NS_nr=nansum(~isnan(newsnow_pos));
wet_nr=nansum(~isnan(wet));
WW_nr=nansum(~isnan(newwater_pos));
wind_nr=nansum(~isnan(ff));

%Make and save histogramplots showing all available data and threshold
%values for wetbulb temp., new snow and corresponding snow pillow value,
%wind.

figure('name', 'hist2')

subplot(2,2,1)
bar(centers_NS, counts_NS./NS_nr)
xlabel(sprintf('%s %s', 'HN [cm]; cut off:', num2str(cut_snow)));
ylabel('probability density')
ylim([0 1])
%axis tight;
%line([cut_snow cut_snow], [0 max(counts_NS./NS_nr)], 'LineWidth', 2, 'Color', 'r');
line([cut_snow cut_snow], [0 1], 'LineWidth', 2, 'Color', 'r');
grid on

subplot(2,2,2)
%only showing subsection of histogram where bin centers are less than two
%so that threshold is visible (otherwise single very high values scew the
%figure).
bar(centers_WW(centers_WW<=2), counts_WW(centers_WW<=2)./WW_nr)
xlabel(sprintf('%s %s', 'HNW [mm w.e.]; cut off:', num2str(cut_water)));
ylabel('probability density')
ylim([0 1])
%axis tight;
%line([cut_water cut_water], [0 max(counts_WW./WW_nr)], 'LineWidth', 2, 'Color', 'r');
line([cut_water cut_water], [0 1], 'LineWidth', 2, 'Color', 'r');
grid on


subplot(2,2,3)
bar(centers_wet, counts_wet./wet_nr)
xlabel(sprintf('%s %s', 'Tw [°C]; cut off:', num2str(cut_wet)));
ylabel('probability density')
ylim([0 0.05])
%axis tight;
%line([cut_wet cut_wet], [0 max(counts_wet./wet_nr)], 'LineWidth', 2, 'Color', 'r');
line([cut_wet cut_wet], [0 0.05], 'LineWidth', 2, 'Color', 'r');
grid on

subplot(2,2,4)
bar(centers_ff, counts_ff./wind_nr)
xlabel(sprintf('%s %s', 'wind [m s^{-1}]; cut off:', num2str(cut_wind)));
ylabel('probability density')
ylim([0 0.45])
%axis tight;
%line([cut_wind cut_wind], [0 max(counts_ff./wind_nr)], 'LineWidth', 2, 'Color', 'r');
line([cut_wind cut_wind], [0 0.45], 'LineWidth', 2, 'Color', 'r');
grid on

annotation('textbox', [0 0.9 1 0.1], 'String', [location,' ',datestr(a1, 'dd mmm yyyy'),'-',datestr(b1,'dd mmm yyyy')], 'EdgeColor', 'none','HorizontalAlignment', 'center')

saveas(gcf,[fname,'/', c,' histogram_Fig.fig'])
saveas(gcf,[fname,'/', c,' histogram_Fig.jpg'])
saveas(gcf,[fname,'/', c,' histogram_Fig.eps'])

%-------------------------------------------------------------------------

f=figure('name', 'hist3')

binsNS=0:0.5:ceil(max(newsnow1));
[counts_NS]=histc(newsnow1, binsNS);
[counts_NS2]=histc(newsnow2, binsNS);

centersNS=binsNS+0.25;

binswet=floor(min(wet)):0.5:ceil(max(wet1));
[counts_wet, centers_wet]=histc(wet1, binswet);
[counts_wet2, centers_wet2]=histc(wet2, binswet);

centerswet=binswet+0.25;

binsWW=0:0.5:ceil(max(newwater1));
[counts_WW]=histc(newwater1, binsWW);
[counts_WW2]=histc(newwater2, binsWW);

centersWW=binsWW+0.25;

binsWind=0:0.5:ceil(max(ff1));
[counts_ff]=histc(ff1, binsWind);
[counts_ff2]=histc(ff2, binsWind);

centersWind=binsWind+0.25;

titletext =sprintf('%s %s %s %s%s%s%s', location, datestr(a1, 'mmm. yyyy'), datestr(b1,'mmm. yyyy'), '. Thresholds: Tw=<', num2str(cut_wet), '°C, HN =>', num2str(cut_snow), 'cm, HNW=>',  num2str(cut_water), 'mm, wind=>', num2str(cut_wind), 'm/s');

w1=0.7;%width of first bar
w2=1;%width of second bar
col=[0.8 0.8 0.8]; %Facecolour of first bar


subplot(2,2,3)
bar(centerswet, counts_wet, w1,'FaceColor',col)
hold on
bar(centerswet, counts_wet2, w2,'FaceColor', 'k')
hold off
ylim([0 max(counts_wet)+(max(counts_wet)*5)/100]);
xlim([-18 15]);
xlabel('Tw [°C]', 'FontSize',18,'FontWeight','bold');
set(gca, 'Fontsize', 16, 'Fontweight', 'bold');
grid on

subplot(2,2,1)
bar(centersNS, counts_NS, w1,'FaceColor',col)
hold on
bar(centersNS, counts_NS2, w2,'FaceColor', 'k')
hold off
ylim([0 max(counts_NS)+(max(counts_NS)*5)/100]);
xlim([0 9]);
legend({'all data', 'filtered'});
xlabel('HN [cm]', 'FontSize',18,'FontWeight','bold');
set(gca, 'Fontsize', 16, 'Fontweight', 'bold');
grid on

subplot(2,2,2)
bar(centersWW, counts_WW, w1,'FaceColor',col)
hold on
bar(centersWW, counts_WW2, w2,'FaceColor', 'k')
hold off
ylim([0 max(counts_WW)+(max(counts_WW)*5)/100]);
xlim([0 18]);
xlabel('HNW [mm]', 'FontSize',18,'FontWeight','bold');
set(gca, 'Fontsize', 16, 'Fontweight', 'bold');
grid on

subplot(2,2,4)
bar(centersWind, counts_ff, w1,'FaceColor',col)
hold on
bar(centersWind, counts_ff2, w2,'FaceColor', 'k')
hold off
ylim([0 max(counts_ff)+(max(counts_ff)*5)/100]);
xlim([0 12]);
xlabel('wind [m/s]', 'FontSize',18,'FontWeight','bold');
set(gca, 'Fontsize', 16, 'Fontweight', 'bold');

grid on

ha = axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');

text(0.5, 1, titletext ,'HorizontalAlignment' ,'center','VerticalAlignment', 'top', 'FontSize', 18)

 pos = get(f,'position');
 set(f,'position',[pos(1:2)/4 pos(3:4)*2]);

saveas(gcf,[fname,'/', c,' histogram3_Fig.fig'])
saveas(gcf,[fname,'/', c,' histogram3_Fig.jpg'])
saveas(gcf,[fname,'/', c,' histogram3_Fig.eps'])

%-------------------------------------------------------------------------
%make and save scatter plots of density versus wetbulb temperature and wind
figure('name', 'scatter')
subplot(2,1,1)
 scatter(wet2, dichte, 'k*');
 %ylim([nanmin(dichte) nanmax(dichte)])
 %xlim([nanmin(wet2) nanmax(wet2)])
 lsline
 ylabel('Density [kg m^{-3}]', 'FontSize', 12);
 xlabel('Tw [°C]', 'FontSize', 12);
 set(gca, 'FontSize', 12); 
 title([location, ' ', datestr(a1, 'dd mmm yyyy'), '-', datestr(b1, 'dd mmm yyyy') ], 'FontSize', 12);
grid on

subplot(2,1,2)
 scatter(ff2, dichte, 'k*');
 ylim([nanmin(dichte) nanmax(dichte)])
 xlim([nanmin(ff2) nanmax(ff2)])
 lsline
 ylabel('Density [kg m^{-3}]', 'FontSize', 12);
 xlabel('Wind [m s^{-1}]', 'FontSize', 12);
 set(gca, 'FontSize', 12); 
 
 grid on
 
saveas(gcf,[fname,'/', c,' Scatter_density_wind_Tw_Fig.fig'])
saveas(gcf,[fname,'/', c,' Scatter_density_wind_Tw_Fig.jpg'])
saveas(gcf,[fname,'/', c,' Scatter_density_wind_Tw_Fig.eps'])



else end






end