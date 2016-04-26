% load('ImgBasis','dataOut');
% basisSize = size(dataOut,1);

% pwa = squeeze(double(max(min(dataOut(:,:,:,1) - dataOut(:,:,:,3),65535),1)));
% pwoa = squeeze(double(max(min(dataOut(:,:,:,2) - dataOut(:,:,:,3),65535),1)));
% absNoPCA = max(min(pwa./pwoa,2),0.01);

load('pwaSave','pwa');
load('pwoaSave','pwoa');
load('absSave','absNoPCA');

basisSize = size(pwoa,1);

X = reshape(pwoa,basisSize,1024*1024);
eigenImages = pca(X);
meanImg = mean(X,1)';

corner1x = 400;
corner1y = 550;
corner2x = 650;
corner2y = 750;
maskx = [corner1x corner1x corner2x corner2x];
masky = [corner1y corner2y corner2y corner1y];
mask = poly2mask(maskx,masky,1024,1024); % Mask is 1 on the inside of the ROI, 0 outside.
maskLin = reshape(mask,1024*1024,1);

for imgToDisp = 1:10
    toImg = reshape(pwa(imgToDisp,:,:),1024*1024,1);
    
    % My method
    c = zeros(size(eigenImages,2),1);
    
    for i = 1:length(c)
        c(i) = (toImg-meanImg)'*eigenImages(:,i);
    end
    
    estPWOA1 = (eigenImages*c+meanImg);
    
%     % Hiro's method
%     Iminus = ~maskLin.*(toImg-meanImg);
%     for i = 1:length(c)
%         c(i) = Iminus'*eigenImages(:,i)./sqrt(1-(maskLin.*eigenImages(:,i))'*eigenImages(:,i));
%     end
%     estPWOA2 = (eigenImages*c+meanImg);
    
%     % Medley Method
%     Iminus = ~maskLin.*(toImg-meanImg);
%     for i = 1:length(c)
%         c(i) = Iminus'*eigenImages(:,i)./(1-(maskLin.*eigenImages(:,i))'*eigenImages(:,i));
%     end
%     estPWOA3 = (eigenImages*c+meanImg);

%     
    % BEC 5 Method
    estPWOA4 = meanImg+eigenImages*((toImg-meanImg)'*eigenImages)';
    estPWOA4 = (toImg'*(~maskLin))./(estPWOA4'*(~maskLin))*estPWOA4;
    
    absPCA1 = toImg./estPWOA1;
    figure('units','normalized','outerposition',[0 0 1 1]);
    subplot(1,2,1);
    imagesc(reshape(absPCA1,1024,1024));
    load('MyColormaps','mycmap')
    colormap(mycmap);
    caxis([0 1.2]);
    title('PCA Mine');
    
%     absPCA2 = toImg./estPWOA2;
%     subplot(1,2,2);
%     imagesc(reshape(absPCA2,1024,1024));
%     load('MyColormaps','mycmap')
%     colormap(mycmap);
%     caxis([0 1.2]);
%     title('PCA Hiro');
    
%     absPCA3 = toImg./estPWOA3;
%     subplot(1,2,2);
%     imagesc(reshape(absPCA3,1024,1024));
%     load('MyColormaps','mycmap')
%     colormap(mycmap);
%     caxis([0 1.2]);
%     title('PCA Medley');
%     
    absPCA4 = toImg./estPWOA4;
    subplot(1,2,2);
    imagesc(reshape(absPCA4,1024,1024));
    load('MyColormaps','mycmap')
    colormap(mycmap);
    caxis([0 1.2]);
    title('PCA BEC 5');
    
    
%     subplot(1,2,2);
%     imagesc(squeeze(absNoPCA(imgToDisp,:,:)));
%     load('MyColormaps','mycmap')
%     colormap(mycmap);
%     caxis([0 1.2]);
%     title('No PCA');
    
end