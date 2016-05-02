load('pwaSave','pwa');
load('pwoaSave','pwoa');
load('absSave','absNoPCA');

basisSize = size(pwoa,1);

X = reshape(pwoa,basisSize,1024*1024);
eigenImages = pca(X);
meanImg = mean(X,1)';

for imgToDisp = 1:10
    toImg = reshape(pwa(imgToDisp,:,:),1024*1024,1);
    
    c = (toImg-meanImg)'*eigenImages;
    estPWOA1 = (eigenImages*c'+meanImg);
        
    absPCA1 = toImg./estPWOA1;
    figure('units','normalized','outerposition',[0 0 1 1]);
    subplot(1,2,1);
    imagesc(reshape(absPCA1,1024,1024));
    load('MyColormaps','mycmap')
    colormap(mycmap);
    caxis([0 1.2]);
    title('PCA Mine');

    subplot(1,2,2);
    imagesc(squeeze(absNoPCA(imgToDisp,:,:)));
    load('MyColormaps','mycmap')
    colormap(mycmap);
    caxis([0 1.2]);
    title('No PCA');
    
end