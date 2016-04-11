function [r] = data_evaluation(a, imgmode, framenum)
    if imgmode == 1
        a_1=a(:,:,1); %PWA
        a_2=a(:,:,2); %PWOA
        a_3=a(:,:,3); %DF
    elseif imgmode == 2
        a_1=a(:,1:length(a)/2,1); %PWA
        a_2=a(:,length(a)/2:length(a),1); %PWOA
        a_3=a(:,1:length(a)/2,2); %DF
    end
    [m,n]=size(a_1);
% To determine and correct value of pixels
    for i=1:m
        for j=1:n
            if a_1(i,j) > 65535
                a_1(i,j)=65535;
            elseif a_1(i,j) < a_3(i,j)
                a_1(i,j)= a_3(i,j);
            end
        end
    end
    a_up=a_1-a_3;
    a_down=a_2-a_3;
    for i=1:m
        for j=1:n
            if a_down(i,j) > 65535
                a_down(i,j)=65535;
            elseif a_down(i,j) < 1
                a_down(i,j) = 1;
            end
        end
    end
    a_up=double(a_up);
    a_down=double(a_down);
    switch framenum
        case 1
            r=a_up./a_down;
            for i=1:m
                for j=1:n
                    if r(i,j) > 2
                        r(i,j)=2;
                    elseif r(i,j) < 0.01
                        r(i,j) = 0.01;
                    end
                end
            end
        case 2
            r=a_1;
        case 3
            r=a_2;
        case 4
            r=a_3;
        case 5
            r=a_3;
    end
end
