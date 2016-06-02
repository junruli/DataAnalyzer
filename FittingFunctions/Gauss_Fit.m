function [ fitParams ] = Gauss_Fit( a, eachplot )
%
% fitParams(1) = amplitude
% fitParams(2) = center
% fitParams(3) = sigma

    a = double(a);
    q1=a(1,:);
    q2=a(end,:);
    q3=a(:,1);
    q4=a(:,end);
    m=[q1(:);q2(:);q3(:);q4(:)];
    s=mean(m);
    u2=-log(a);
    s2=-log(s);
    u=u2-s2;

    r = sum(u)';
    x = (1:length(r))';
    
    fout = fit(x,double(r),'gauss1');
    coeffs = coeffvalues(fout);
    
    if eachplot
        figure;
        plot(fout,x,r);
    end
    
    fitParams = coeffs;
    fitParams(3) = fitParams(3)/sqrt(2);
    
end

