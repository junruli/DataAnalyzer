function resy = KapitzaDiracV1_0(a,eachplot)
    X = a;
    row=size(X,2);
    s=floor(row/5);
    C1 = X(:,1:s);
    C2 = X(:,s+1:2*s);
    C3 = X(:,2*s+1:3*s);
    C4 = X(:,3*s+1:4*s);
    C5 = X(:,4*s+1:row);
    n1=NormN_Count(C1,eachplot);
    n2=NormN_Count(C2,eachplot);
    n3=NormN_Count(C3,eachplot);
    n4=NormN_Count(C4,eachplot);
    n5=NormN_Count(C5,eachplot);
    n_tot=NormN_Count(X, eachplot);
    n_cen=n3/n_tot;
    n_near=(n2+n4)/(2*n_tot);
    n_nn=(n1+n5)/(2*n_tot);
    resy(1)=n_cen;
    resy(2)=n_near;
    resy(3)=n_nn;
end

%celldisp(C)