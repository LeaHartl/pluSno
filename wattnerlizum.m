function[a, b, step, datum, schnee, rf, tl, kissen, ff, glow, rr]=wattnerlizum(location)


step=10; %time step in data

load 'Y:\Daten\Projekte\pluSnow\Daten\edited\WattnerLizum\BFW_all_ed.mat'
%-----------------------assign variables.----------------------------- 
%the file used here contains: datum, ff, gr, rh, rr, sd, swe, tair, tdew
% 
% filename = 'Z:\Daten\Projekte\pluSnow\Daten\edited\WattnerLizum\BFW_all_2.txt' ;
% x=fopen(filename);
% C=textscan(x, '%f %f %f %f %f %f %f %f ' , 'delimiter', ';', 'headerlines',1);
% fclose(x);
%  
% %assign variables, he file used here contains: datum, ff, gr, rh, rr, sd, swe, tair, tdew
% datum=C{1};
% a=datum(1);
% b=datum(end);
% 
% data(:,1)=C{1}; data(:,2)=C{2}; data(:,3)=C{3}; data(:,4)=C{4}; data(:,5)=C{5}; data(:,6)=C{6}; data(:,7)=C{7}; data(:,8)=C{8}; 
% 
% %replace -9999 with NaNs and set data to NaN if flag not zero
% no=find(data(:,:)<-9999);
% data(no)=NaN;
% 
% %assign parameter arrays
% ff=data(:,2); glow=data(:,3); rf=data(:,4); rr=data(:,5); schnee=data(:,6); kissen=data(:,7); tl=data(:,8); 
% 
% %replace -9999 with NaNs, delete last value of file (file needs to end at
% %23:50 not 00:00
% 
no=find(ff<-9999);
ff(no)=NaN;

no=find(glow<-9999);
glow(no)=NaN;

no=find(rf <-9999);
rf(no)=NaN;

no=find(schnee<-9999);
schnee(no)=NaN;

no=find(kissen<-9999);
kissen(no)=NaN;

no=find(tl<-9999);
tl(no)=NaN;

no=find(rr<-9999);
rr(no)=NaN;
% 
% % 
a=datum(1);
b=datum(end);
% 
% % 
%  %plot(datum, kissen)