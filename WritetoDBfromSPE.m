% Write to Database

dbh=NET.addAssembly(fullfile('Z:\LAB\Samarth\Zeus\databasehelper3\databasehelper3\bin\Debug','DatabaseHelper.dll'));
%abc=NET.addAssembly(fullfile('C:\Users\Wild Western Burrito\Documents\Visual Studio 2015\Projects\ClassLibrary1\ClassLibrary1\bin\Debug','ClassLibrary1.dll'));

%instance = ClassLibrary1.Class1;


pathname1 = 'Z:\LAB\BEC 4 (rubidium)\By Date\2016\16-03-23\reference shots\tool kd';
d = dir([pathname1 '/*.mat']);
cameraID=1;
seqID=7;
runID=4;
% a=importdata([pathname1 '\' d(3).name]);
% s=size(a)

for i=1:4
    instance = DatabaseHelper.DatabaseHelper('18.62.9.117', '18.62.9.117', 'root', 'w0lfg4ng', 'BECIVDatabase');
    a=importdata([pathname1 '\' d(i).name]);
    a=a(:,:,2:4);
    s=size(a);
    width=s(1);
    height=s(2);
    depth=s(3);
%     width=1;
%     height=2;
%     depth=3;
    bdata=reshape(a,[],1);
    bdata1=int16(bdata);
%    bdata1=1:12;
%    class(bdata)
    instance.writeImageDataToDB(bdata1, depth, width, height, cameraID, runID, seqID);
    instance.closeConnection();
end
%instance.closeConnection();

%c=instance.squera(4)


