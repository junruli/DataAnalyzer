function resy = KapitzaDiracV1_0(a,eachplot)
    X = a;
    row=size(X,2);
    s=floor(row/5);
    C1 = X(:,1:s);
    C2 = X(:,s+1:2*s);
    C3 = X(:,2*s+1:3*s);
    C4 = X(:,3*s+1:4*s);
    C5 = X(:,4*s+1:row);
    if eachplot == 1
        figure
        subplot(1,5,1);
        imagesc(C1);
        subplot(1,5,2);
        imagesc(C2);
        subplot(1,5,3);
        imagesc(C3);
        subplot(1,5,4);
        imagesc(C4);
        subplot(1,5,5);
        imagesc(C5);
    end
    border1=X(1,:);
    border2=X(end,:);
    border3=X(:,1);
    border4=X(:,end);
    tot_border=[border1(:);border2(:);border3(:);border4(:)];
    s=mean(tot_border);
    border_corr=-log(s);
    %N Count 1
    tot2_1=-log(C1);
    tot_1=tot2_1-border_corr;
    l1=sum(tot_1(:));
    v1=real(l1);
    n1=round(v1);
    %N Count 2
    tot2_2=-log(C2);
    tot_2=tot2_2-border_corr;
    l2=sum(tot_2(:));
    v2=real(l2);
    n2=round(v2);
    %N Count 3
    tot2_3=-log(C3);
    tot_3=tot2_3-border_corr;
    l3=sum(tot_3(:));
    v3=real(l3);
    n3=round(v3);
    %N Count 4
    tot2_4=-log(C4);
    tot_4=tot2_4-border_corr;
    l4=sum(tot_4(:));
    v4=real(l4);
    n4=round(v4);
    %N Count 5
    tot2_5=-log(C5);
    tot_5=tot2_5-border_corr;
    l5=sum(tot_5(:));
    v5=real(l5);
    n5=round(v5);
    n_tot=NormN_Count(X, eachplot);
%    n_tot=n1+n2+n3+n4+n5;
    n_cen=n3/n_tot;
    n_near=(n2+n4)/(2*n_tot);
    n_nn=(n1+n5)/(2*n_tot);
    resy(1)=n_cen;
    resy(2)=n_near;
    resy(3)=n_nn;
end

%celldisp(C)