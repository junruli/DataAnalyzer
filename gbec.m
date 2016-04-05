function gbec=gbec(n,x,imax)
    gbec=zeros(size(x));
   for i=1:imax
       gbec=gbec+x.^i./(i^n);
   end
end