conn = database('becivdatabase', 'root', 'w0lfg4ng', 'Server', '18.62.27.134', 'Vendor', 'MySQL');

% sqlquery2=['SELECT pcadata FROM images WHERE imageID = ', num2str(1200)];
% curs2=exec(conn, sqlquery2);
% curs2=fetch(curs2);
% bdata=curs2.Data;
% close(curs2);
% if strcmp('null',cell2mat(bdata))
%     disp('nulllllll');
% end
% blobdata=typecast(cell2mat(bdata),'int16');
% 
% s=[1024 1024 3];
% a=Blob2Matlab(blobdata,s);
% figure;
% imagesc(a(:,:,1))
% 

sqlquery2=['UPDATE images SET pcadata = null'];
curs2=exec(conn, sqlquery2);
close(curs2);


% sqlquery2=['SELECT data FROM images WHERE imageID = ', num2str(1200)];
% curs2=exec(conn, sqlquery2);
% curs2=fetch(curs2);
% bdata=curs2.Data;
% close(curs2);
% blobdata=typecast(cell2mat(bdata),'int16');
% s=[1024 1024 3];
% a=Blob2Matlab(blobdata,s);
% figure;
% imagesc(a(:,:,1))
% 
% image = a(:,:,2);
% 
% tableName = 'images';
% colName = {'pcadata'};
% % % data = {typecast(reshape(int16(image),1,1024*1024),'int8')};
% data = {'null'};
% % whereClause = ['WHERE imageID = ', num2str(1200)];
% whereClause = ['WHERE imageID = *'];
% 
% update(conn,tableName,colName,data,whereClause);
% 
sqlquery2=['SELECT pcadata FROM images WHERE imageID = ', num2str(4732)];
curs2=exec(conn, sqlquery2);
curs2=fetch(curs2);
bdata=curs2.Data;
close(curs2);
blobdata=typecast(cell2mat(bdata),'double');
s=[1024 1024 1];
a=Blob2Matlab(blobdata,s);
figure;
imagesc(a(:,:,1))
load('MyColormaps','mycmap')
colormap(mycmap);
caxis([0 1.2]);


% out1 = cell2mat(bdata);
% % out2 = reshape(out1,200,1);
% out = typecast(out1,'int16');