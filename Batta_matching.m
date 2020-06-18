function [rotate ,matched] = Batta_matching(AOI_sift, Distor_sift)
N = 0;
for m = 1: size( AOI_sift, 1)
    for n = 1: size( Distor_sift, 1)
       Batta(m, n) = sqrt(1- sum(sqrt(AOI_sift(m, :).*Distor_sift(n,:))./...
                        sqrt(sum(AOI_sift(m, :))*sum(Distor_sift(n,:))) ));
        
    end 
    
       [val, indx] = min(Batta(m, :));
       
       if val<0.4
       N = N+1;
       rotate(N, :) = AOI_sift(m, :);
       matched(N, :) = Distor_sift(indx, :);
       end 
end 
end 