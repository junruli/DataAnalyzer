function fitresult = BEC5Fit(a, eachplot)
%{
fitresult details:
1: Condensate fraction
2: N Total
3: BEC X Width
4: BEC Y Width
5: Thermal X Width
6: Thermal Y Width
7: X Peak Height
8: Y Peak Height
%}

    OD=-log(a);
    roi=[0, 0, size(OD,1), size(OD,2)];
    xRegion = round(roi(1))+(1:round(roi(3)));
    yRegion = round(roi(2))+(1:round(roi(4)));
    X = reshape(repmat(xRegion',1,numel(yRegion))',1,[]);    
    Y = repmat(yRegion,1,numel(xRegion));
    Z = reshape(OD,1,[]);
    
    
%    OD=OD(yRegion,xRegion);
    xProjection = sum(OD,1);
    yProjection = sum(OD,2)';
    [m,xpeak]=max(xProjection);
    xpeak=xRegion(xpeak);
    ind=find(xProjection<=m/2);
    xFWHM=max(diff(ind));
    if isempty(xFWHM)
        xFWHM=xpeak;
    end
    [m,ypeak]=max(yProjection);
    ypeak=yRegion(ypeak);
    ind=find(yProjection<=m/2);
    yFWHM=max(diff(ind));
    if isempty(yFWHM)
        yFWHM=ypeak;
    end
    
    
    % Sum total number
    nTotal=abs(sum(xProjection));

    % Clean up data
    [xData, yData, zData] = prepareSurfaceData( X, Y, Z ); 
%     size(xData)
%     size(yData)
%     size(zData)
    
    % Set up fittype and options.
    %gbec is http://mathworld.wolfram.com/Polylogarithm.html
    ft = fittype( 'nTotal*(1-cf)/(2*pi*sx*sy)/1.202*gbec(2,exp(-((x-x0)^2/sx^2+(y-y0)^2/sy^2)/2),3)+nTotal*cf*5/(2*pi*rx*ry)*max((1-(x-x0)^2/rx^2-(y-y0)^2/ry^2),0)^(3/2)', 'independent', {'x', 'y'}, 'dependent', 'z' );
    opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
    
    opts.Lower =        [0     0.7*nTotal   xFWHM/10    yFWHM/10   xFWHM/2.0   yFWHM/2.0  xpeak-30     ypeak-30];
    opts.StartPoint =   [0.5    nTotal      xFWHM/2     yFWHM/2    10*xFWHM	   10*yFWHM	  xpeak        ypeak];
    opts.Upper =        [1      1.3*nTotal  xFWHM       yFWHM      Inf         Inf        xpeak+30     ypeak+30];
    
    opts.MaxFunEvals = 800;
    opts.MaxIter = 600;
    opts.TolX = 1e-6;
    opts.TolFun = 1e-6;
    opts.DiffMinChange = 1e-8;
    opts.DiffMaxChange = 1e-2;
    
    opts.Display = 'Off';
    
    % Fit model to data.
    [result, gof] = fit( [xData, yData], zData, ft, opts );
    fitresult=coeffvalues(result);
end