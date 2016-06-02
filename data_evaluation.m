function [r] = data_evaluation(a, imgmode, framenum)
if imgmode == 1
    a_1=a(:,:,1); %PWA
    if size(a,3) < 2
        a_2 = 1;
        warning('Not enough frames.');
    else
        a_2=a(:,:,2); %PWOA
    end
    if size(a,3) < 3
        a_3 = 0;
        warning('Not enough frames.');
    else
        a_3=a(:,:,3); %DF
    end
    a_4 = a_3;    
elseif imgmode == 2
    framesize = floor(size(a,2)/2);
    a_1=a(1:framesize,:,1); %PWA
    a_2=a(framesize:2*framesize,:,1); %PWOA
    if size(a,3) < 2
        a_3 = 0;
        a_4 = 0;
        warning('Not enough frames.');
    else
        a_3=a(1:framesize,:,2); %DF
        a_4=a(framesize+1:2*framesize,:,2); %DF for PWOA
    end
elseif imgmode == 3
    framesize = floor(size(a,2)/3);
    a_1=a(1:framesize,:,1); %PWA
    a_2=a(framesize+1:2*framesize,:,1); %PWOA
    a_3=a(2*framesize+1:3*framesize,:,1); %DF
    a_4 = a_3;    
end

a_1 = min(a_1,65535);
a_2 = min(a_2,65535);
a_3 = min(a_3,65535);
a_up=a_1-a_3;
a_down=a_2-a_3;

a_up = min(a_up,65535);
a_down = min(a_down,65535);
a_down = max(a_down, 1);

a_up=double(a_up);
a_down=double(a_down);
switch framenum
    case 1
        r=a_up./a_down;
        r = max(r,0.01);
        r = min(r,2); % Why is this one here?
    case 2
        r=a_1;
    case 3
        r=a_2;
    case 4
        r=a_3;
    case 5
        r=a_4;
end
end
