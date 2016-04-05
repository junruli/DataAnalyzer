function [n] = NormN_Count(a, eachplot)
    q1=a(1,:);
    q2=a(end,:);
    q3=a(:,1);
    q4=a(:,end);
    m=[q1(:);q2(:);q3(:);q4(:)];
    s=mean(m);
    u2=-log(a);
    s2=-log(s);
    u=u2-s2;
    l=sum(u(:));
    v=real(l);
    n=round(v);
end