% c=zeros(3,2)
% c(1,:)=random()
% a=c(:,1)


%leastsquare=cell(2,1);
%ls=@(theta)str2func(leastsquare(1,:))(theta)+str2func(leastsquare(2,:))(theta)
% 
% a=rand(5)
% size(a,1)
% size(a,2)
% xRegion = 1+(0:round(size(a,1)))
% yRegion = 1:round(size(a,2))
% X = reshape(repmat(xRegion',1,numel(yRegion))',1,[])    
% Y = repmat(yRegion,1,numel(xRegion))
% Z = reshape(a,1,[])
    
conn = database('becivdatabase', 'root', 'w0lfg4ng', 'Server', 'spicythaitofu', 'Vendor', 'MySQL'); %Specify name of database here

    sqlquery='SELECT COLUMN_NAME FROM information_schema.columns WHERE table_name="ciceroOut"';
    curs1=exec(conn, sqlquery);
    curs1=fetch(curs1);
    columndata = curs1.Data;
    close(curs1);