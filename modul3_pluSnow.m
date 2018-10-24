%Third part of pluSnow scripts.

function[]=modul3_pluSnow();

%loops through files in folder 'data'
%files contain: 'date', 'density', 'hedstrom', 'diamond', 'laChapelle',
%'fassnacht', 'jordan', 'schmucki', 'Tw [°C]', 'Tair [°C]', 'rel hum [%]',
%'windsp [m/s]', 'density corrected'
%this is setup to work with three data files of different length. for more
%files the code has to be adjusted. output figures are saved to the same
%folder ('data')
%---------read data file----------------------------------------------

cd data %folder data: time period Oct 2013 - May 2015 all 4 stations. folder data1: complete timeseries kühtai (1987-2015) and Oct 2011 - Oct 2013 for kühtai, kühroint and wattner lizum

[status, list] = system( 'dir /B /S *.mat' );
result = textscan( list, '%s', 'delimiter', '\n' );
fileList = result{1};

for i=1:length(fileList)
[pathstr,name,ext] = fileparts(fileList{i}) ;
nm{i}=(matlab.lang.makeValidName(name));
c{i}=name(1);
a{i}=name(3:10);
b{i}=name(12:19);
location{i}=name(33:end);
filename =fileList{i};
S=load(filename);
var.(matlab.lang.makeValidName(name))=S;
end



a=datenum(a, 'yyyymmdd');
b=datenum(b, 'yyyymmdd');

a_s=datestr(a, 'yyyy mmm dd ');
b_s=datestr(b, 'yyyy mmm dd');

%%



%Boxplot1
X=var.(nm{1}).dichte_corr./10;
groups=ones(size(X));

for i=2:length(fileList)
X=vertcat(X, var.(nm{i}).dichte_corr./10);
groups=vertcat(groups, ones(size(var.(nm{i}).wet)).*i);
end

for j=1:length(fileList)
X=vertcat(X, var.(nm{j}).wet);
end

for k=1:length(fileList)
X=vertcat(X, var.(nm{k}).ff);
end

%add groups + 9 for additional variable. like this it expects 3 (i.e.
%density, temp and wind).
groups1=vertcat(groups, groups+length(fileList), groups+length(fileList)*2);

positions=[1:1:length(fileList)*3];

%Make legend
 ll{1}=[location{1}];% ': ' a_s(1,:) ' - ' b_s(1, :)];
 for n=2:length(fileList)
 ll{n}=[location{n}];% ': ' a_s(n,:) ' - ' b_s(n, :)];
 end

% %make colour map ("hsv" is a predefined matlab colourmap.)
% %CM=winter(length(fileList));
CM1(1,:)=[1, 0, 0];
CM1(2,:)=[0, 0, 1];
CM1(3,:)=[0, 0, 0];
CM1(4,:)=[0.2, 0.6, 0.2];

% % for plot with 5 station/periods
% CM1(1,:)=[0, 0, 0];
% CM1(2,:)=[1, 0, 0];
% CM1(3,:)=[0, 0, 0.8];
% CM1(4,:)=[0.2, 0.6, 0.8];
% CM1(5,:)=[0, 0.8, 1];

ff=figure('name', 'box');
h=boxplot(X,groups1, 'positions', positions, 'color',CM1, 'symbol', '+');

h = findobj(gca,'Tag','Box');

for j =1:4;
    for k = 1:length(CM1);
        color((j-1)*length(CM1)+k,:) = CM1(k,:);
    end
end

 for j=1:length(h)
    patch(get(h(j),'XData'),get(h(j),'YData'),color(length(color)-j+1,:),'FaceAlpha',.5,'LineStyle','none');
 end
 
boxes=findobj(gca,'Tag','Box');
[~, ind] = sort(cellfun(@mean, get(boxes, 'XData')));
l=legend(boxes(ind(1:length(fileList))), ll,'Box','off','Location','southoutside','Orientation','horizontal');

set(gca,'TickLabelInterpreter', 'tex');
set(gca,'xtick',length(fileList)/2:   length(positions)/3:    length(positions)-1.5);
set(gca,'xticklabel',{'NSD', 'T_{w}', 'U'})
ylabel('[10^{1} kgm^{-3}, °C, ms^{-1}]')
set(gca, 'Fontsize', 14, 'Fontweight', 'bold');
pos = get(ff,'position');
set(ff,'position',[pos(1:2)/4 pos(3:4)*2]);
%title('Comparison of stations')
set(gca,'YGrid','on','GridLineStyle','--')


saveas(gcf,'compareStations.fig')
saveas(gcf,'compareStations.jpg')

%%
%Boxplot2
Y=var.(nm{1}).dichte_corr;
groups=ones(size(Y));

for i=2:length(fileList)
Y=vertcat(Y, var.(nm{i}).dichte_corr);
groups=vertcat(groups, ones(size(var.(nm{i}).wet)).*i);
end
% 
% for j=1:length(fileList)
% Y=vertcat(Y, var.(nm{j}).dichte_pred);
% end

for k=1:length(fileList)
Y=vertcat(Y, var.(nm{k}).d_hedstrom);
end

for k=1:length(fileList)
Y=vertcat(Y, var.(nm{k}).d_diamond);
end

for k=1:length(fileList)
Y=vertcat(Y, var.(nm{k}).d_laChap);
end

for k=1:length(fileList)
Y=vertcat(Y, var.(nm{k}).d_crocus);
end

for k=1:length(fileList)
Y=vertcat(Y, var.(nm{k}).d_jordan);
end

for k=1:length(fileList)
Y=vertcat(Y, var.(nm{k}).d_schmucki);
end

for k=1:length(fileList)
Y=vertcat(Y, var.(nm{k}).d_lehning);
end

%add groups for additional variable. like this it expects 9 (i.e.
%all density variables).
groups11=vertcat(groups, groups+length(fileList), groups+length(fileList)*2, groups+length(fileList)*4, groups+length(fileList)*8, groups+length(fileList)*16, groups+length(fileList)*32, groups+length(fileList)*64);%, groups+length(fileList)*128);
positions1=[1:1:length(fileList)*8];

%%
f=figure('name', 'box');
% boxplot(Y,groups11, 'positions', positions1,'color',CM1,'symbol', '+');
h=boxplot(Y,groups11, 'positions', positions1,'color',CM1, 'symbol', '+');

h = findobj(gca,'Tag','Box');

for j =1:8;
    for k = 1:length(CM1);
        color((j-1)*length(CM1)+k,:) = CM1(k,:);
    end
end

 for j=1:length(h)
    patch(get(h(j),'XData'),get(h(j),'YData'),color(length(color)-j+1,:),'FaceAlpha',.4,'LineStyle','none');
 end

boxes=findobj(gca,'Tag','Box');
[~, ind] = sort(cellfun(@mean, get(boxes, 'XData')));
l=legend(boxes(ind(1:length(fileList))), ll,'Box','off','Location','southoutside','Orientation','horizontal');

 set(gca,'TickLabelInterpreter', 'tex');
 set(gca,'xtick',length(fileList)/2:   length(positions1)/8:    length(positions1)-1.5)
 set(gca,'xticklabel',{'NSD_{obs}', '\rho_{H}', '\rho_{D}', '\rho_{LC}', '\rho_{V}', '\rho_{J}', '\rho_{S}', '\rho_{L}'},'Fontsize', 10, 'Fontweight', 'bold')
 ylim([0 200]);
 %l=legend(findobj(gca,'Tag','Box'), ll);
 set(l,'Fontsize', 10, 'Fontweight', 'bold', 'Location','southoutside');
 set(gca, 'Fontsize', 14, 'Fontweight', 'bold');
 ylabel('Density [kgm^{-3}]')
 pos = get(f,'position');
 set(f,'position',[pos(1:2)/4 pos(3:4)*2]);
% title('Density parametrisations [kg m^{-3}]')
set(gca,'YGrid','on','GridLineStyle','--')

saveas(gcf,'compareDensities.fig')
saveas(gcf,'compareDensities.jpg')

