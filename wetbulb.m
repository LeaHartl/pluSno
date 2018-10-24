function[tw2]=wetbulb(tl, rh, press);



%Feuchttemperatur zum Abschätzen des Schneipotentials Kunstschnee aud T und
        %RH von Daten 
        a=9.5;
        b=265.5;
        %dampfdruck e aus es und RH berechnen

        %erst es errechnen abhängig (Sättigung über Wasser oder Eis abh. von Tl)
        [m,n]=size(tl);
        es=zeros(m,1);
        for i=1:m
            if tl(i)>0
            es(i)=6.10780.*exp((17.08085.*tl(i))./(234.175+tl(i)));
            else
                es(i)=6.10714.*exp((22.44294.*tl(i))./(272.440+tl(i)));
            end
        end
        
           
        %Dann dampfdruck anhand von es und rf rechnen
        e=(rh./100).*es;
        
        

        %Dann Taupunkt rechnen
        td=b./((a./(0.4343.*log(e./6.107)))-1);
      

        
        %Preallocation of variables for speed
        es_w=zeros(size(es,1),1);
        e2=zeros(size(es,1),1);
        tw2=zeros(size(es,1),1);
        %tw iterativ lösen mit psychrometergleichungen
        for i=1:size(e)
            tw_test=td(i):0.01:tl(i);
            tw_test=tw_test';
            
            if isempty(tw_test)==1
            tw_test=tl(i);
            end
            
         for j=1:size(tw_test)
           if tw_test(j)>0
            es_w(j)=6.10780.*exp((17.08085.*tw_test(j))./(234.175+tw_test(j)));
            else
                es_w(j)=6.10714.*exp((22.44294.*tw_test(j))./(272.440+tw_test(j)));
           end
           if tw_test(j)>0
               e2(j)=es_w(j)-0.662.*(press./1006.7).*(tl(i)-tw_test(j));
           else
           e2(j)=es_w(j)-0.57.*(tl(i)-tw_test(j));
           end 
         end
        diff_e=e2-e(i);
        [m,n]=min(abs(diff_e));
        tw2(i)=tw_test(n);
        clear es_w e2
        end