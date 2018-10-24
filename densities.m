function [d_hedstrom, d_diamond, d_laChap, d_crocus, d_jordan, d_schmucki, d_lehning ]=densities(T, wind, RH);


d_hedstrom=67.92+51.25.*exp(T./2.59); %eq. 2 mair paper, Hedstrom-Pomeroy (1998)

d_diamond=119+6.48.*T; %eq.3 mair paper, Diamond-Lowry (1954)

d_laChap=50+1.7.*(T+15).^1.5 ;  %eq.4 mair paper, LaChapelle (1962) 
d_laChap=real(d_laChap); %NOTE this turns into a complex number if T < 15 --> use only real part

% d_fassnacht= 85.* ((1 - 0.03.* cos(0.33 .*T + 0.418)) + 0.15.* cos(0.662.* T + 0.418) - 0.029.* cos(0.993.* T + 0.418) + 0.123.* sin(0.331.*T + 0.418) +...
%     0.009.*sin(0.662 .*T + 0.418) - 0.026.* sin(0.993 .*T + 0.418)).*(1.75) + 1; %eq.5 mair paper, Fassnacht-Soulis (2002)  %CHECK SIGNAGE; +/- PROBLEM should be *-1.75 at the end but makes results negative
% 

%jordan 1999:
Tk=(T+273.15);
A=find (Tk>260.15 & Tk<=275.65);
Tk(A);
B=find (Tk<=260.15);
C=find (Tk>275.65);

d_jordan=ones(size(T)).*NaN;

d_jordan(A)=500.*(1-0.951.*exp(-1.4.*(278.15-Tk(A)).^-1.15)-0.008.*wind(A).^1.7);

d_jordan(B)=500.*(1-0.904.*exp(-0.008.*wind(B).^1.7));

d_jordan(C)=NaN;


%Schmucki

AA=find (T>=-14);
BB=find (T<-14);

CC=find(RH>100);
RH(CC)=NaN;

d_schmucki=ones(size(T)).*NaN;
d_schmucki(AA)= 10.^(3.28 + 0.03 .*T(AA) - 0.36 -0.75.*asin(sqrt(RH(AA)./100)) + 0.3.* log10(wind(AA)));
d_schmucki(BB)= 10.^(3.28 + 0.03 .*T(BB) -0.75.*asin(sqrt(RH(BB))./100) + 0.3.* log10(wind(BB)));


%Lehning
Tss=T; %Tss müsste eigentlich T der Schneeoberfläche sein, hier als Annäherung gleich gesetzt mit Lufttemperatur!!

d_lehning=70 + 6.5.*T + 7.5.*Tss  + 0.26.*RH + 13.*wind -4.5.*T.*Tss - 0.65.*T.*wind - 0.17.*RH.*wind + 0.06.*T.*Tss.*RH;


%CROCUS
a1=109; %kg m-3
b1=6; %kg m-3 K-1
c1= 26; %kg m-7/2 s-1/2
Tfus=0;

d_crocus=ones(size(T)).*NaN;
d_crocus = a1 + b1.*(T - Tfus)+c1.* wind.* 1/2;


% The density of freshly fallen snow is expressed as a function of wind speed, U, and air temperature, Ta, as : ?new = a? +b?(Ta ?Tfus)+c?U1/2
%  where Tfus is the temperature of the melting point for water, a? = 109 kgm?3, b? = 6 kgm?3 K?1 and c? = 26 kgm?7/2 s?1/2. The minimum snow density is 50 kgm?3.
% Parameters  in Eq. (1) originate from a study carried out by Pahaut (1976) at Col de Porte (1325m altitude, French Alps).
% 

% % %Figure plots densities
% figure ('name', 'densities')
% 
%   plot(T, d_hedstrom, 'b*')
%   hold on
%   plot(T, d_diamond, 'k*')
%     hold on
%   plot(T, d_laChap, 'g*')
%     hold on
%   plot(T, d_crocus, 'm*')
%    hold on
%   plot(T, d_jordan, 'r*')  
%      hold on
%   plot(T, d_schmucki, 'y*')  
%        hold on
%   plot(T, d_lehning, 'b^')  
% axis 'tight'
%  %xlim([timenr(1) timenr(end)])
%  legend( 'hedstrom', 'diamond', 'la chap', 'crocus', 'jordan', 'schmucki', 'lehning');
%  ylabel('dichte');
%  xlabel('temp in °C');