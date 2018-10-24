function[]=makestats(c, location, a, b, timenr, d_hedstrom, d_diamond, d_laChap, d_crocus, d_jordan, d_schmucki, d_lehning, dichte, dichte_corr95, dichte95, dichte_pred, glow, rf, tl, ff, rr, water, snow, newsnow, newwater, wet, fname);

%Compute mean, median, standard deviation for single years
if strcmp(c, 'h')==1
[Y M D H]=datevec(timenr);

%Define end of season cut off date: August 31st, 23:00
Y1=find(M==8 & D==31 & H== 23);

else [Y M D]=datevec(timenr);
%Define end of season cut off date: August 31st
Y1=find(M==8 & D==31 );
end

%Find appropriate year to write in file later
YY=Y(Y1);


%Matrix of all variables of which stats will be calculated
A=[dichte, dichte95, dichte_corr95, dichte_pred, d_hedstrom, d_diamond, d_laChap, d_crocus, d_jordan, d_schmucki, d_lehning, glow, rf, tl, ff, rr, newsnow, newwater, wet];

%compute mean, median, standard deviation and count values, per year.
mittl(1, :)=nanmean(A(1:Y1(1), :));
for i=2:length(Y1);
mittl(i, :)=nanmean(A(Y1(i-1)+1:Y1(i), :));
end

medi(1, :)=nanmedian(A(1:Y1(1), :));
for i=2:length(Y1);
medi(i, :)=nanmedian(A(Y1(i-1)+1:Y1(i), :));
end

std(1, :)=nanstd(A(1:Y1(1), :));
for i=2:length(Y1);
std(i, :)=nanstd(A(Y1(i-1)+1:Y1(i), :));
end

%count number of values after threshold cuts.
nr_data(1, :)=sum(~isnan(A(1:Y1(1), :)));
for i=2:length(Y1);
nr_data(i, :)=sum(~isnan(A(Y1(i-1)+1:Y1(i), :)));
end

mittl=round(mittl,2);
medi=round(medi,2);
std=round(std,2);

year=YY-1;
mtt=[year'; mittl'];
med=[year'; medi'];
std=[year'; std'];
nr=[year'; nr_data'];

%pearson correlation
AA=[dichte95 dichte_corr95 dichte_pred d_hedstrom d_diamond d_laChap d_crocus d_jordan d_schmucki d_lehning];
[R,P]=corrcoef(AA,'rows','complete') ;
R=round(R,2);
P=round(P,2);


%summary
all(1,:)=nanmean(A);
all(2,:)=nanmedian(A);
all=round(all,2);

%Create tables from P and R arrays to write to file
% RR=array2table(R, 'VariableNames', {'dichte_95',  'dichte_pred', 'd_hedstrom', 'd_diamond', 'd_laChap', 'd_fassnacht', 'd_jordan', 'd_schmucki'});
% RR.var={'dichte_95',  'dichte_pred', 'd_hedstrom', 'd_diamond', 'd_laChap', 'd_fassnacht', 'd_jordan', 'd_schmucki'}';
% RR = [RR(:,end) RR(:,1:end-1)];
% 
% PP=array2table(P, 'VariableNames', {'dichte_95',  'dichte_pred', 'd_hedstrom', 'd_diamond', 'd_laChap', 'd_fassnacht', 'd_jordan', 'd_schmucki'});
% PP.var={'dichte_95',  'dichte_pred', 'd_hedstrom', 'd_diamond', 'd_laChap', 'd_fassnacht', 'd_jordan', 'd_schmucki'}';
% PP = [PP(:,end) PP(:,1:end-1)];

%----------------------------------------------------
%write files
%pearson correlation: 
folder=[pwd '\' fname '\'];
filename11 =[folder 'pearsonCorr_' datestr(a, 'yyyymmdd') '_' datestr(b,'yyyymmdd') location '.txt'];
header= {'dichte_95', 'd_corr95',  'dichte_pred', 'd_hedstrom', 'd_diamond', 'd_laChap', 'd_crocus', 'd_jordan', 'd_schmucki', 'd_lehning'};
fid=fopen(filename11, 'wt');
fprintf(fid, '%-12.11s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s \n', header{:});
fprintf(fid, '%-12.5g  %-12.5g  %-12.5g  %-12.5g  %-12.5g  %-12.5g  %-12.5g  %-12.5g  %-12.5g  %-12.5g \n', R');
fclose(fid);
% writetable(RR, filename11,'delimiter','\t');

%p-value correlation: 
folder=[pwd '\' fname '\'];
filename111 =[folder 'pValueCorr_' datestr(a, 'yyyymmdd') '_' datestr(b,'yyyymmdd') location '.txt'];
header= {'dichte_95',  'd_corr95', 'dichte_pred', 'd_hedstrom', 'd_diamond', 'd_laChap', 'd_crocus', 'd_jordan', 'd_schmucki', 'd_lehning'};
fid=fopen(filename111, 'wt');
fprintf(fid, '%-12.11s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s \n', header{:});
fprintf(fid, '%-12.5g  %-12.5g  %-12.5g  %-12.5g  %-12.5g  %-12.5g  %-12.5g  %-12.5g  %-12.5g  %-12.5g \n', P');
fclose(fid);
%writetable(PP, filename111,'delimiter','\t');

%Mittelwerte 
folder=[pwd '\' fname '\'];
filename1 =[folder 'mittelwerte_' datestr(a, 'yyyymmdd') '_' datestr(b,'yyyymmdd') location '.txt'];
header= {'year', 'dichte', 'dichte_95', 'd_corr95',  'dichte_pred', 'd_hedstrom', 'd_diamond', 'd_laChap', 'd_crocus', 'd_jordan', 'd_schmucki', 'd_lehning', 'glow', 'rf', 'tl', 'ff', 'rr', 'newsnow', 'newwater', 'wet'};
fid=fopen(filename1, 'wt');
fprintf(fid, '%-12.4s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s \n', header{:});
fprintf(fid, '%-12.2d %-12.5g  %-12.5g  %-12.5g  %-12.5g  %-12.5g  %-12.5g  %-12.5g  %-12.5g  %-12.5g  %-12.5g  %-12.5g  %-12.5g  %-12.5g  %-12.5g  %-12.5g  %-12.5g  %-12.5g  %-12.5g %-12.5g \n', mtt);
fclose(fid);
%dlmwrite(filename1,mtt,'delimiter',' ', 'newline', 'pc','-append');

%Median
filename2 =[folder 'median_' datestr(a, 'yyyymmdd') '_' datestr(b,'yyyymmdd') location '.txt'];
header= {'year', 'dichte', 'dichte_95', 'd_corr95', 'dichte_pred', 'd_hedstrom', 'd_diamond', 'd_laChap', 'd_crocus', 'd_jordan', 'd_schmucki', 'd_lehning', 'glow', 'rf', 'tl', 'ff', 'rr', 'newsnow', 'newwater', 'wet'};
fid=fopen(filename2, 'wt');
fprintf(fid, '%-12.4s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s \n', header{:});
fprintf(fid, '%-12.2d %-12.5g  %-12.5g  %-12.5g  %-12.5g  %-12.5g  %-12.5g  %-12.5g  %-12.5g  %-12.5g  %-12.5g  %-12.5g  %-12.5g  %-12.5g  %-12.5g  %-12.5g  %-12.5g  %-12.5g  %-12.5g %-12.5g \n', med);
fclose(fid);
%dlmwrite(filename2,med,'delimiter','\t', 'newline', 'pc', 'precision', 5, '-append');

%STBW
filename3 =[folder 'stanardabw_' datestr(a, 'yyyymmdd') '_' datestr(b,'yyyymmdd') location '.txt'];
header= {'year', 'dichte', 'dichte_95', 'd_corr95', 'dichte_pred', 'd_hedstrom', 'd_diamond', 'd_laChap', 'd_crocus', 'd_jordan', 'd_schmucki', 'd_lehning', 'glow', 'rf', 'tl', 'ff', 'rr', 'newsnow', 'newwater', 'wet'};
fid=fopen(filename3, 'wt');
fprintf(fid, '%-12.4s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s \n', header{:});
fprintf(fid, '%-12.2d %-12.5g  %-12.5g  %-12.5g  %-12.5g  %-12.5g  %-12.5g  %-12.5g  %-12.5g  %-12.5g  %-12.5g  %-12.5g  %-12.5g  %-12.5g  %-12.5g  %-12.5g  %-12.5g  %-12.5g  %-12.5g %-12.5g \n', std);
fclose(fid);
%dlmwrite(filename3,std,'delimiter','\t', 'newline', 'pc', 'precision', 5, '-append');

%Anzahl d. Werte
filename4 =[folder 'number_of_values_' datestr(a, 'yyyymmdd') '_' datestr(b,'yyyymmdd') location '.txt'];
header= {'year', 'dichte', 'dichte_95', 'd_corr95', 'dichte_pred', 'd_hedstrom', 'd_diamond', 'd_laChap', 'd_crocus', 'd_jordan', 'd_schmucki', 'd_lehning', 'glow', 'rf', 'tl', 'ff', 'rr', 'newsnow', 'newwater', 'wet'};
fid=fopen(filename4, 'wt');
fprintf(fid, '%-12.4s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s \n', header{:});
fprintf(fid, '%-12.2d %-12.5g  %-12.5g  %-12.5g  %-12.5g  %-12.5g  %-12.5g  %-12.5g  %-12.5g  %-12.5g  %-12.5g  %-12.5g  %-12.5g  %-12.5g  %-12.5g  %-12.5g  %-12.5g  %-12.5g  %-12.5g %-12.5g \n', nr);
fclose(fid);
%dlmwrite(filename4,nr,'delimiter','\t', 'newline', 'pc', 'precision', 5, '-append');


%summary
filename2 =[folder 'summary_' datestr(a, 'yyyymmdd') '_' datestr(b,'yyyymmdd') location '.txt'];
header= {'dichte', 'dichte_95', 'd_corr95', 'dichte_pred', 'd_hedstrom', 'd_diamond', 'd_laChap', 'd_crocus', 'd_jordan', 'd_schmucki', 'd_lehning', 'glow', 'rf', 'tl', 'ff', 'rr', 'newsnow', 'newwater', 'wet'};
fid=fopen(filename2, 'wt');
fprintf(fid, '%-12.11s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s %-12.11s \n', header{:});
fprintf(fid, '%-12.11g %-12.11g %-12.11g %-12.11g %-12.11g %-12.11g %-12.11g %-12.11g %-12.11g %-12.11g %-12.11g %-12.11g %-12.11g %-12.11g %-12.11g %-12.11g %-12.11g %-12.11g %-12.11g \n', all');
fclose(fid);
%dlmwrite(filename2,med,'delimiter','\t', 'newline', 'pc', 'precision', 5, '-append');