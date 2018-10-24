%This subfunction sorts the densities into wetbulb temperature and wind bins, bin
%size 1°C and 0.5m/s respectively, and plots resulting denisties against wetbulb temperature/wind.


function[]=sort_in_bins(timenr, tl, ff, wet, dichte95, location, fname, a, b)


dichte95_n1=dichte95(~isnan(dichte95));
wet_n1=wet(~isnan(dichte95));
dichte95_nn=dichte95_n1;
wet_nn=wet_n1;

%set bin ranges
binrangesW=[min(floor(wet)):1:0];

%make bins

[bincountsW,indW] = histc(wet_nn,binrangesW);

for ii=1:length(binrangesW)-1;
    ind2=find(indW==ii);
    d_mn_W(ii)=nanmean(dichte95_nn(ind2));
    d_md_W(ii)=nanmedian(dichte95_nn(ind2));
end

yW=min(floor(wet))+1:0;
Twc=ceil(wet);

%%
dichte95_n11=dichte95(~isnan(dichte95));
ff_n1=ff(~isnan(dichte95));
dichte95_nn1=dichte95_n11;
ff_nn=ff_n1;

%set bin ranges
binrangesW1=[0:0.5:5];

%make bins

[bincountsW1,indW1] = histc(ff_nn,binrangesW1);

for ii=1:length(binrangesW1)-1;
    ind21=find(indW1==ii);
    d_mn_W1(ii)=nanmean(dichte95_nn1(ind21));
    d_md_W1(ii)=nanmedian(dichte95_nn1(ind21));
end

yW1=0.5:0.5:5;
ffc=ceil(ff);


%find ls line equations, p and r2, write to file.
%Temp
Good1 = ~(isnan(wet) | isnan(dichte95)) ;
p_all_T=polyfit(wet(Good1),dichte95(Good1),1); 


[r1, p1]=corrcoef(wet, dichte95, 'rows', 'pairwise');
r2_1=r1(1,2)^2;
p1=p1(1,2);

Good2 = ~(isnan(yW) | isnan(d_md_W)) ;
p_md_T=polyfit(yW(Good2), d_md_W(Good2), 1);


[r2, p2]=corrcoef(yW, d_md_W, 'rows', 'pairwise');
r2_2=r2(1,2)^2;
p2=p2(1,2);




%Wind
Good3 = ~(isnan(ff) | isnan(dichte95)) ;
p_all_W=polyfit(ff(Good3), dichte95(Good3),1);

[r3, p3]=corrcoef(ff, dichte95, 'rows', 'pairwise');
r2_3=r3(1,2)^2;
p3=p3(1,2);
Good4 = ~(isnan(yW1) | isnan(d_md_W1)) ;
p_md_W=polyfit(yW1(Good4), d_md_W1(Good4), 1);

[r4, p4]=corrcoef(yW1, d_md_W1, 'rows', 'pairwise');
r2_4=r4(1,2)^2;
p4=p4(1,2);

dat(1,:)=[round(p_all_T(2), 2) round(p_all_T(1), 2) round(r2_1, 2) round(p1, 2)];
dat(2,:)=[round(p_md_T(2), 2) round(p_md_T(1), 2) round(r2_2, 2) round(p2, 2)];
dat(3,:)=[round(p_all_W(2), 2) round(p_all_W(1), 2) round(r2_3, 2) round(p3, 2)];
dat(4,:)=[round(p_md_W(2), 2) round(p_md_W(1), 2) round(r2_4, 2) round(p4, 2)];



%write dat to file

filename11 =[fname,'\bin_stats.txt'];
header1= {'intercept', 'slope','r2', 'p'};
fid=fopen(filename11, 'wt');
fprintf(fid, '%s\t', header1{:});
fprintf(fid, '\n');
fclose(fid);
%write file
dlmwrite(filename11, dat,'delimiter','\t', 'newline', 'pc', 'precision',18, '-append');

%%

f=figure ('name', 'test11');

subplot(1,2,1)
 plot(wet,dichte95, 'o','MarkerEdgeColor','b','MarkerFaceColor','none', 'Markersize', 4);
 hold on
 plot(yW, d_mn_W,'diamond', 'MarkerEdgeColor','r','MarkerFaceColor','r', 'Markersize', 6);
 hold on
 plot(yW, d_md_W,'square', 'MarkerEdgeColor','k','MarkerFaceColor','k', 'Markersize', 6);
 

legend({'All', 'Mean', 'Median'}, 'Location','southeast', 'FontSize',14,'FontWeight','bold');
h=lsline;
set(h(1),'color','b', 'lineWidth', 2, 'LineStyle','-.')
set(h(2),'color','r', 'lineWidth', 2, 'LineStyle',':')
set(h(3),'color','k', 'lineWidth', 2)



xlabel('Tw [°C]', 'FontSize', 14)
ylabel('Density [kg m^{-3}]', 'FontSize', 14)
%title(['Density in 1°C bins with least squares lines, ' location], 'FontSize',12);
title([location, ' ', datestr(a, 'dd mmm yyyy'), '-', datestr(b, 'dd mmm yyyy') ], 'FontSize', 12);
xlim([-15 0])
ylim([30 130])
set(gca, 'FontSize', 12)
grid on

subplot(1,2,2)

 plot(ff,dichte95, 'o','MarkerEdgeColor','b','MarkerFaceColor','none', 'Markersize', 4);
 hold on
 plot(yW1, d_mn_W1,'diamond', 'MarkerEdgeColor','r','MarkerFaceColor','r', 'Markersize', 6);
 hold on
 plot(yW1, d_md_W1,'square', 'MarkerEdgeColor','k','MarkerFaceColor','k', 'Markersize', 6);

legend({'All', 'Mean', 'Median'}, 'Location','southeast', 'FontSize',14,'FontWeight','bold' );
h=lsline;
set(h(1),'color','b', 'lineWidth', 2, 'LineStyle','-.')
set(h(2),'color','r', 'lineWidth', 2, 'LineStyle',':')
set(h(3),'color','k', 'lineWidth', 2)
xlabel('Wind [m s^{-1}]', 'FontSize', 14)
ylabel('Density [kg m^{-3}]', 'FontSize', 14)
%title(['Density in 1°C bins with least squares lines, ' location], 'FontSize',12);
%title([location, ' ', datestr(a, 'dd mmm yyyy'), '-', datestr(b, 'dd mmm yyyy') ], 'FontSize', 12);
set(gca, 'FontSize', 12)
xlim([0 4])
ylim([30 130])
grid on

 pos = get(f,'position');
 set(f,'position',[pos(1:2)/4 pos(3:4)*2]);

saveas(gcf,[fname,'/Bins_Fig.fig'])
saveas(gcf,[fname,'/Bins_Fig.jpg'])
saveas(gcf,[fname,'/Bins_Fig.eps'])
end