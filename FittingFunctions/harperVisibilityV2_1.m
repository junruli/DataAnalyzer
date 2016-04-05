function [ave_vis] = harperVisibilityV2_1(a, eachplot)

% rescaling of the figure
% F = -log(double(a(670:850,320:520,1)));
% G = -log(double(a(670:850,320:520,1)))';
% figure;imagesc(F)
%a=-log(u);
F = a;
G = a';

%finding the center and subtracting background
r = size(F(:,1),1); % the y-image size
s = size(G(:,1),1); % the x-image size

indexy = (1:r)'; % a column vector enumerating the pixels of the lineout
indexx = (1:s)';

COMx = zeros(1,s); % Preallocating space for ycom
COMy = zeros(1,r); % for xcom

for n=1:r;
    COMx(n) = round(sum(F(n,:).*indexx')/sum(F(n,:),2));
end
for n=1:s;
    COMy(n) = round(sum(F(:,n).*indexy)/sum(F(:,n),1));
end

centerx = round(sum(COMx(1,(round(s/2)-3):(round(s/2)+3)))/size(COMx(1,(round(s/2)-3):(round(s/2)+3)),2));
centery = round(sum(COMy(1,(round(r/2)-3):(round(r/2)+3)))/size(COMy(1,(round(r/2)-3):(round(r/2)+3)),2));

% disp(centerx)
% disp(centery)

background = (sum(F(1,:))+sum(F(:,1))+sum(F(size(F,1),:))+sum(F(:,size(F,2))))/(2*size(F,2)+2*size(F,1)); % sum of all the edge pixels to estimate the image background offset
F = F - background; %Subtracting the average background
G = G - background;

% Taking a lineout to use as the main fitting data
lineouty = sum(F(:,max(1,(centerx-4)):(centerx+4)),2)/9; % 1D lineout of the center 5 pixels in a column vector format for both x and y directions
lineoutx = sum(G(:,max(1,(centery-4)):(centery+4)),2)/9; % 1D lineout of the center 5 pixels in a column vector format for both x and y directions

% Moving to fourier space for instituting some pre-fitting and cuts
fouriery = fft(lineouty); % fourier transform
fourierx = fft(lineoutx);

%Low pass filtering for thermal fit
filter = 50; % filter order, the higher the number the sharper the cutoff is, 12 seems acceptable I wouldn't play with this number
lowpassy = 2*real(ifft(fouriery.*(1-exp(-((indexy-r/2)./(r/2)).^filter)))); % low pass filtering the lineout
lowpassx = 2*real(ifft(fourierx.*(1-exp(-((indexx-s/2)./(s/2)).^filter)))); % low pass filtering the lineout

[lowpassvaluey,lowpasscentery] = max(lowpassy); % finding the amplitude and center for inital guesses for the fitter
[lowpassvaluex,lowpasscenterx] = max(lowpassx); % finding the amplitude and center for inital guesses for the fitter

ycount = sum(lowpassy,1); % counting the atom number in our lineout, will be used as a cut for visibility data where no atom number = 0 visibility
xcount = sum(lowpassx,1); % counting the atom number in our lineout, will be used as a cut for visibility data where no atom number = 0 visibility

expectedcounty = background*r*10; % how many atoms we expect to see just from background noise, is the comparison point for the atom number cut
expectedcountx = background*s*10;




% Now thermal peak fitting for the first guess in the y direction
[xData0, yData0] = prepareCurveData(indexy,lowpassy);

% Set up fittype and options for the thermal fraction
f0t = fittype('(a*exp(-(1/2)*((x-b)/c)^2))+d','independent','x','dependent','y');
opts = fitoptions(f0t);
opts.Display = 'Off';
opts.Lower = [0 0 0 -100];
% fitting paramaters format, alphabetical: [a b c d]
opts.StartPoint = [lowpassvaluey lowpasscentery r/4 0];
opts.Upper = [2*max(max(F)) r 10*r 100];
% Fit model to data.
[peakfit0,~] = fit(xData0,yData0,f0t,opts);
fitcoeff0 = coeffvalues(peakfit0); % coefficients used as initial guesses for the final fitter
% curve that will serve as an initial thermal component guess
peaks0 = feval(peakfit0,indexy);

%now using a lowpass filtered lineout to take derivatives and find the peak positions
smoothedy = 2*real(ifft(fouriery.*(1-exp(-((indexy-r/2)./(6*r/16)).^filter))));
smoothdiffy = diff(smoothedy);

peakguessy = find(smoothdiffy(1:r-2).*smoothdiffy(2:r-1) < 0); % finding all zero crossings

valleyguessy = zeros(length(peakguessy),1); %preallocating the sive of the valleyguess vector
% loop to filter all maxima from minima
for iter = 1:length(peakguessy);
    if smoothedy(max(1,peakguessy(iter)-1))>smoothedy(peakguessy(iter)+1)
        valleyguessy(iter) = peakguessy(iter);
        peakguessy(iter) = 1;
    elseif smoothedy(max(1,peakguessy(iter)-1))<smoothedy(peakguessy(iter)+1)
        valleyguessy(iter) = 1;
    end
end
% peakguess = peakguess(peakguess~=0); % vector of peak postions
% valleyguess = valleyguess(valleyguess~=0); % vector of valley positions
[~, peakindexy] = sort(lineouty(peakguessy),'descend'); % sorted list of values and indicies of peaks in the peakguesses list


% Now thermal peak fitting for the first guess in the x direction
[xData00, yData00] = prepareCurveData(indexx,lowpassx);

% Set up fittype and options for the thermal fraction
f00t = fittype('(a*exp(-(1/2)*((x-b)/c)^2))+d','independent','x','dependent','y');
opts = fitoptions(f00t);
opts.Display = 'Off';
opts.Lower = [0 0 0 -100];
% fitting paramaters format, alphabetical: [a b c d]
opts.StartPoint = [lowpassvaluex lowpasscenterx r/4 0];
opts.Upper = [2*max(max(G)) s 10*s 100];
% Fit model to data.
[peakfit00,~] = fit(xData00,yData00,f00t,opts);
fitcoeff00 = coeffvalues(peakfit00); % coefficients used as initial guesses for the final fitter
% curve that will serve as an initial thermal component guess
peaks00 = feval(peakfit00,indexx);

%now using a lowpass filtered lineout to take derivatives and find the peak positions
smoothedx = 2*real(ifft(fourierx.*(1-exp(-((indexx-s/2)./(6*s/16)).^filter))));
smoothdiffx = diff(smoothedx);

peakguessx = find(smoothdiffx(1:s-2).*smoothdiffx(2:s-1) < 0); % finding all zero crossings

valleyguessx = zeros(length(peakguessx),1); %preallocating the sive of the valleyguess vector
% loop to filter all maxima from minima
for iter = 1:length(peakguessx);
    if smoothedx(max(1,peakguessx(iter)-1))>smoothedx(peakguessx(iter)+1)
        valleyguessx(iter) = peakguessx(iter);
        peakguessx(iter) = 1;
    elseif smoothedx(max(1,peakguessx(iter)-1))<smoothedx(peakguessx(iter)+1)
        valleyguessx(iter) = 1;
    end
end
% peakguess = peakguess(peakguess~=0); % vector of peak postions
% valleyguess = valleyguess(valleyguess~=0); % vector of valley positions
[~, peakindexx] = sort(lineoutx(peakguessx),'descend'); % sorted list of values and indicies of peaks in the peakguesses list



% inital guesses for the fittter based on what we've done so far
Athermaly = fitcoeff0(1);
Cthermaly = fitcoeff0(2);
Wthermaly = fitcoeff0(3);
Othermaly = fitcoeff0(4);
Asf2y = lineouty(peakguessy(peakindexy(2))) - 0.8.*peaks0(peakguessy(peakindexy(2)));
Asf3y = lineouty(peakguessy(peakindexy(3))) - 0.8.*peaks0(peakguessy(peakindexy(3)));
Asf4y = lineouty(peakguessy(peakindexy(4))) - 0.8.*peaks0(peakguessy(peakindexy(4)));
Asf5y = lineouty(peakguessy(peakindexy(5))) - 0.8.*peaks0(peakguessy(peakindexy(5)));
Asf1y = lineouty(peakguessy(peakindexy(1))) - 0.8.*peaks0(peakguessy(peakindexy(1)));
Csfdiffy = sum(diff(sort(peakguessy(peakindexy(1:5)))))/4;
Csf1y = peakguessy(peakindexy(1));
Wsf2y = 3; %sum(diff(sort(peakguess(peakindex(1:5)))))/25;
Wsf1y = 3; %sum(diff(sort(peakguess(peakindex(1:5)))))/25;

% Now full SF peak fitting
[xData1, yData1] = prepareCurveData(indexy,lineouty);

% Set up fittype and options for the sf peaks
f1t = fittype('(a*exp(-(1/2)*((x-b)/c)^2))+d+(a1*exp(-(1/2)*((x-(b3+b1))/c1)^2))+(a2*exp(-(1/2)*((x-(b3-b1))/c1)^2))+(a3*exp(-(1/2)*((x-(b3+2*b1))/c5)^2))+(a4*exp(-(1/2)*((x-(b3-2*b1))/c5)^2))+(a5*exp(-(1/2)*((x-b3)/c5)^2))','independent','x','dependent','y');
opts = fitoptions(f1t);
opts.Display = 'Off';
% format: [a a1 a2 a3 a4 a5 b b1 b3 c c1 c5 d]
opts.Lower = [0 0 0 0 0 0 3*Cthermaly/4 Csfdiffy/2 0.8*Csf1y Wthermaly/3 Wsf2y/3 Wsf1y/3 -1];
opts.StartPoint = [Athermaly Asf2y Asf3y Asf4y Asf5y Asf1y Cthermaly Csfdiffy Csf1y Wthermaly Wsf2y Wsf1y Othermaly];
opts.Upper = [200 200 200 200 200 200 5*Cthermaly/4 2*Csfdiffy 1.2*Csf1y 3*Wthermaly 1.5*Wsf2y 1.5*Wsf1y 1];
% Fit model to data.
[peakfit1,~] = fit(xData1,yData1,f1t,opts);
fitcoeff1 = coeffvalues(peakfit1);

peaksy = feval(peakfit1,indexy); % the fitted thermal plus sf fraction
residualy = (lineouty-peaksy); % fitting residual

amplitudey = fitcoeff1(1:6);
centery = fitcoeff1(7:9);
widthy = fitcoeff1(10:12);
offsety = fitcoeff1(13);

thermal2y = amplitudey(1)*exp(-(1/2)*((indexy-centery(1))./widthy(1)).^2)+offsety;
SFPeaks1y = amplitudey(2)*exp(-(1/2)*((indexy-(centery(3)+centery(2)))./widthy(2)).^2)+amplitudey(3)*exp(-(1/2)*((indexy-(centery(3)-centery(2)))./widthy(2)).^2);
SFPeaks2y = amplitudey(4)*exp(-(1/2)*((indexy-(centery(3)+2*centery(2)))./widthy(3)).^2)+amplitudey(5)*exp(-(1/2)*((indexy-(centery(3)-2*centery(2)))./widthy(3)).^2);
SFPeaks3y = amplitudey(6)*exp(-(1/2)*((indexy-centery(3))./widthy(3)).^2);





% inital guesses for the x - fittter based on what we've done so far
Athermalx = fitcoeff00(1);
Cthermalx = fitcoeff00(2);
Wthermalx = fitcoeff00(3);
Othermalx = fitcoeff00(4);
Asf2x = lineoutx(peakguessx(peakindexx(2))) - 0.8.*peaks00(peakguessx(peakindexx(2)));
Asf3x = lineoutx(peakguessx(peakindexx(3))) - 0.8.*peaks00(peakguessx(peakindexx(3)));
Asf4x = lineoutx(peakguessx(peakindexx(4))) - 0.8.*peaks00(peakguessx(peakindexx(4)));
Asf5x = lineoutx(peakguessx(peakindexx(5))) - 0.8.*peaks00(peakguessx(peakindexx(5)));
Asf1x = lineoutx(peakguessx(peakindexx(1))) - 0.8.*peaks00(peakguessx(peakindexx(1)));
Csfdiffx = sum(diff(sort(peakguessx(peakindexx(1:5)))))/4;
Csf1x = peakguessx(peakindexx(1));
Wsf2x = 3; %sum(diff(sort(peakguess(peakindex(1:5)))))/25;
Wsf1x = 3; %sum(diff(sort(peakguess(peakindex(1:5)))))/25;

% Now full SF peak fitting
[xData11, yData11] = prepareCurveData(indexx,lineoutx);

% Set up fittype and options for the sf peaks
f11t = fittype('(a*exp(-(1/2)*((x-b)/c)^2))+d+(a1*exp(-(1/2)*((x-(b3+b1))/c1)^2))+(a2*exp(-(1/2)*((x-(b3-b1))/c1)^2))+(a3*exp(-(1/2)*((x-(b3+2*b1))/c5)^2))+(a4*exp(-(1/2)*((x-(b3-2*b1))/c5)^2))+(a5*exp(-(1/2)*((x-b3)/c5)^2))','independent','x','dependent','y');
opts = fitoptions(f11t);
opts.Display = 'Off';
% format: [a a1 a2 a3 a4 a5 b b1 b3 c c1 c5 d]
opts.Lower = [0 0 0 0 0 0 3*Cthermalx/4 Csfdiffx/2 0.8*Csf1x Wthermalx/3 Wsf2x/3 Wsf1x/3 -1];
opts.StartPoint = [Athermalx Asf2x Asf3x Asf4x Asf5x Asf1x Cthermalx Csfdiffx Csf1x Wthermalx Wsf2x Wsf1x Othermalx];
opts.Upper = [200 200 200 200 200 200 5*Cthermalx/4 2*Csfdiffx 1.2*Csf1x 3*Wthermalx 1.5*Wsf2x 1.5*Wsf1x 1];
% Fit model to data.
[peakfit11,~] = fit(xData11,yData11,f11t,opts);
fitcoeff11 = coeffvalues(peakfit11);

% initialguess = Athermal*exp(-(1/2)*((index-Cthermal)./Wthermal).^2)+Othermal+Asf2*exp(-(1/2)*((index-(Csf1+Csfdiff))./Wsf2).^2)+Asf3*exp(-(1/2)*((index-(Csf1-Csfdiff))./Wsf2).^2)+Asf4*exp(-(1/2)*((index-(Csf1+2*Csfdiff))./Wsf2).^2)+Asf5*exp(-(1/2)*((index-(Csf1-2*Csfdiff))./Wsf2).^2)+Asf1*exp(-(1/2)*((index-Csf1)./Wsf1).^2);

peaksx = feval(peakfit11,indexx); % the fitted thermal plus sf fraction
residualx = (lineoutx-peaksx); % fitting residual

amplitudex = fitcoeff11(1:6);
centerx = fitcoeff11(7:9);
widthx = fitcoeff11(10:12);
offsetx = fitcoeff11(13);

thermal2x = amplitudex(1)*exp(-(1/2)*((indexx-centerx(1))./widthx(1)).^2)+offsetx;
SFPeaks1x = amplitudex(2)*exp(-(1/2)*((indexx-(centerx(3)+centerx(2)))./widthx(2)).^2)+amplitudex(3)*exp(-(1/2)*((indexx-(centerx(3)-centerx(2)))./widthx(2)).^2);
SFPeaks2x = amplitudex(4)*exp(-(1/2)*((indexx-(centerx(3)+2*centerx(2)))./widthx(3)).^2)+amplitudex(5)*exp(-(1/2)*((indexx-(centerx(3)-2*centerx(2)))./widthx(3)).^2);
SFPeaks3x = amplitudex(6)*exp(-(1/2)*((indexx-centerx(3))./widthx(3)).^2);





%close all
if eachplot == 1
    figure
    % subplot(2,2,1);
    % imagesc(F)
    subplot(1,2,1);
    plot(indexy,peaksy,indexy,lineouty,indexy,thermal2y,indexy,SFPeaks1y,indexy,SFPeaks2y,indexy,SFPeaks3y,indexy,residualy-0.1)
    axis tight
    subplot(1,2,2);
    plot(indexx,peaksx,indexx,lineoutx,indexx,thermal2x,indexx,SFPeaks1x,indexx,SFPeaks2x,indexx,SFPeaks3x,indexx,residualx-0.1)
    axis tight
end


if ycount<expectedcounty
    visibility = 0;
elseif amplitudey(1)>200*amplitudey(2)
    visibility = 0;
elseif amplitudey(1)>200*amplitudey(3)
    visibility = 0;
elseif amplitudey(1)>200*amplitudey(4)
    visibility = 0;
elseif amplitudey(1)>200*amplitudey(5)
    visibility = 0;
elseif amplitudey(1)>200*amplitudey(6)
    visibility = 0;
elseif centery(3)>(centery(1)+1.5*widthy(1))
    visibility = 0;
elseif centery(3)<(centery(1)-1.5*widthy(1))
    visibility = 0;
else visibility = (sum(amplitudey(2:6),2))/(sum(amplitudey(1:6),2));
end


if xcount<expectedcountx
    visibilitx = 0;
elseif amplitudex(1)>200*amplitudex(2)
    visibilitx = 0;
elseif amplitudex(1)>200*amplitudex(3)
    visibilitx = 0;
elseif amplitudex(1)>200*amplitudex(4)
    visibilitx = 0;
elseif amplitudex(1)>200*amplitudex(5)
    visibilitx = 0;
elseif amplitudex(1)>200*amplitudex(6)
    visibilitx = 0;
elseif centerx(3)>(centerx(1)+1.5*widthx(1))
    visibilitx = 0;
elseif centerx(3)<(centerx(1)-1.5*widthx(1))
    visibilitx = 0;
else visibilitx = (sum(amplitudex(2:6),2))/(sum(amplitudex(1:6),2));
end

ave_vis = (visibility+visibilitx)/2;

end






