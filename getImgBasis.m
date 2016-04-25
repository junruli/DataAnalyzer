conn = database('becivdatabase', 'root', 'w0lfg4ng', 'Server', '18.62.27.134', 'Vendor', 'MySQL');

imageIDSpace = 1200:1220; %

sqlquery2=['SELECT data FROM images WHERE imageID IN (', strjoin(cellstr(strsplit(num2str(imageIDSpace))),','),') ORDER BY imageID DESC'];
curs2=exec(conn, sqlquery2);
curs2=fetch(curs2);
bdata=curs2.Data;
close(curs2);
dataOut = zeros(length(imageIDSpace),1024,1024,3);
for i = 1:length(imageIDSpace)
    blobdata=typecast(cell2mat(bdata(i)),'int16');
    s=[1024,1024,3];            %Size of the data
    dataOut(i,:,:,:)=double(Blob2Matlab(blobdata,s));
end

pwa = squeeze(double(max(min(dataOut(:,:,:,1) - dataOut(:,:,:,3),65535),1)));
pwoa = squeeze(double(max(min(dataOut(:,:,:,2) - dataOut(:,:,:,3),65535),1)));
absNoPCA = max(min(pwa./pwoa,2),0.01);

save('pwaSave','pwa');
save('pwoaSave','pwoa');
save('absSave','absNoPCA');