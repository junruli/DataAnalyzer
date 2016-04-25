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

for imgToDisp = 20:30%1:basisSize
    toImg = reshape(pwa(imgToDisp,:,:),1024*1024,1);
    c = zeros(size(eigenImages,2),1);
    
    for i = 1:length(c)
        c(i) = (toImg-meanImg)'*eigenImages(:,i);
    end
    
    absPCA = toImg./(eigenImages*c+meanImg);
    figure('units','normalized','outerposition',[0 0 1 1]);
    subplot(1,2,1);
    imagesc(reshape(absPCA,1024,1024));
    load('MyColormaps','mycmap')
    colormap(mycmap);
    caxis([0 1.2]);
    title('PCA');
    
    subplot(1,2,2);
    imagesc(reshape(absNoPCA(imgToDisp,:,:),1024,1024));
    load('MyColormaps','mycmap')
    colormap(mycmap);
    caxis([0 1.2]);
    title('No PCA');
    
end