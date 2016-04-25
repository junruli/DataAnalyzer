function [ ] = makeImgBasis( imageIDSpace )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

conn = database('becivdatabase', 'root', 'w0lfg4ng', 'Server', '18.62.27.134', 'Vendor', 'MySQL');

dataOut = zeros(length(imageIDSpace),1024,1024,3);
batchSize = 10;
start = 1;

while start <= length(imageIDSpace)
    stop = min(start+batchSize,length(imageIDSpace));
    sqlquery2=['SELECT data FROM images WHERE imageID IN (', strjoin(cellstr(strsplit(num2str(imageIDSpace(start:stop)))),','),') ORDER BY imageID DESC'];
    curs2=exec(conn, sqlquery2);
    curs2=fetch(curs2);
    bdata=curs2.Data;
    close(curs2);
    for i = 1:length(bdata)
        blobdata=typecast(cell2mat(bdata(i)),'int16');
        s=[1024,1024,3];            %Size of the data
        dataOut(i+start-1,:,:,:)=double(Blob2Matlab(blobdata,s));
    end
    
    start = stop+1;
end

pwa = squeeze(double(max(min(dataOut(:,:,:,1) - dataOut(:,:,:,3),65535),1)));
pwoa = squeeze(double(max(min(dataOut(:,:,:,2) - dataOut(:,:,:,3),65535),1)));
absNoPCA = max(min(pwa./pwoa,2),0.01);

save('pwaSave','pwa');
save('pwoaSave','pwoa');
save('absSave','absNoPCA');

end

