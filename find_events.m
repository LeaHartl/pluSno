function[event_start_index, event_end_index,snowSum, SWESum, duration]=find_events(schnee_H, kissen_H, tw_max, HNrate, timeH);
%new snow per time step
newsnow_all=[0 diff(schnee_H)];
newsnow_all=newsnow_all';

%new swe per time step
newSWE_all=[0 diff(kissen_H)];
newSWE_all=newSWE_all';

%vector containing only positive new snow values (snow height increases), otherwise NaN
newPos=ones(size(newsnow_all)).*NaN;
newPos(newsnow_all>0)=newsnow_all(newsnow_all>0);

newPosSWE=ones(size(newSWE_all)).*NaN;
newPosSWE(newSWE_all>0)=newSWE_all(newSWE_all>0);
%%
%for corrected snow height
%new snow per time step
% newsnow2_all=[0 diff(schnee2_H)];
% newsnow2_all=newsnow2_all';

%vector containing only positive new snow values (snow height increases), otherwise NaN
newPos2=ones(size(newsnow_all)).*NaN;
% newPos2(newsnow2_all>0)=newsnow2_all(newsnow2_all>0);
%%

x = schnee_H';
n = length(x);

maxbf = zeros(n,1);
maxaf = zeros(n,1);
event_start = zeros(n,1);
event_end = zeros(n,1);

%% find maximum HS in +/- 24h
for i1 = 1+tw_max:n-tw_max;
    maxbf(i1) = max(x(i1-tw_max:i1-1));
    maxaf(i1) = max(x(i1+1:i1+tw_max));
end

event_end(x > maxbf  &  x >= maxaf) = 1;
event_end(1:1+tw_max) = 0;
event_end(n-tw_max:n) = 0;

%find index points of ends
event_end_index=find(event_end==1);

%find index pints of starts
index_bf=event_end_index-tw_max;
for i2=1:length(event_end_index);  
   [minbf(i2), indmin(i2)] = min(x(index_bf(i2):event_end_index(i2)));
end
event_start_index=index_bf+indmin'-1;

%find instances where event starts more than window size before event end
long=find(schnee_H(event_start_index-1) < schnee_H(event_start_index));

%find closest sign change before end of window size and use that as start of event
S=sign(newsnow_all); S(S==0)=1;
Sign_Changes = [0 abs(diff(S)'==2)];
signs_index=find(Sign_Changes==1)';

for jjj=1:length(long)
    val=event_start_index(long(jjj));
    tmp = abs(signs_index-val);
    [idx idx] = min(tmp); %index of closest value
    closest = signs_index(idx); %closest value
    event_start_index(long(jjj))=closest-1;
end

%duration of events
duration=event_end_index-event_start_index;

%sum of snowfall during events
for j=1:length(event_end_index);
snowSum(j)=nansum(newPos(event_start_index(j):event_end_index(j)));
%snowSum2(j)=nansum(newPos2(event_start_index(j):event_end_index(j)));
end


%desired sum of snowfall
snowThresh=duration'.*HNrate;

%delete events where minimum snow fall is not reached
event_start_index(snowSum < snowThresh)=[];
event_end_index(snowSum < snowThresh)=[];
duration(snowSum < snowThresh)=[];
index_bf(snowSum < snowThresh)=[];
% snowSum2(snowSum < snowThresh)=[];
snowSum(snowSum < snowThresh)=[];

bug=find(duration<0);
event_start_index(bug)=[];
event_end_index(bug)=[];
duration(bug)=[];
snowSum(bug)=[];

%sum of positive SWE change during events
for j=1:length(event_end_index);
SWESum(j)=nansum(newPosSWE(event_start_index(j):event_end_index(j)));
end

% figure ('name', 'check events')
plot(timeH, schnee_H, 'g')
hold on
plot(timeH(event_start_index), schnee_H(event_start_index), 'r*')
hold on
plot(timeH(event_end_index), schnee_H(event_end_index), 'b*')


end