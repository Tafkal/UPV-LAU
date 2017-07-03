clc;
clear all;
close all;

br = 115200;      %%%BaudRate
databits = 8;   %%%DataBits
seriallist

while (1)
    prompt = 'What port do you want to connect? : ';
    str = input(prompt, 's');
    if isempty(str)
        fprintf('\nDid you slip?\n ');
        continue;
    end
    com_port = serial(str, 'BaudRate', br, 'DataBits', databits);
    fopen(com_port)
    break;
end

while(1)
    prompt = '\nx? : ';
    str = input(prompt, 's');
    if isempty(str)
       fprintf('\nOkay, bye!\n ');
       fclose(com_port);
       break; 
    end
    x = single(str2num(str));
    s = num2hex(x);

    %%Kondicioniranje sa char na bitski da bude tacno....
    isit = isletter(s);
    for i = 0:1:length(s)-1
       if isit(i+1)
          s(i+1) = s(i+1) - 'a' + 10;
       else
          s(i+1) = s(i+1) - '0'; 
       end
    end
    s = uint8(s);
    f(1) = bitor(bitsll(s(1), 4), s(2));
    f(2) = bitor(bitsll(s(3), 4), s(4));
    f(3) = bitor(bitsll(s(5), 4), s(6));
    f(4) = bitor(bitsll(s(1), 7), s(8));
    f = char(f);
    fprintf(com_port, '%s', f);

    A = fread(com_port, 1, 'single');
    A_str = num2hex(single(A));
    A1_str(1) = A_str(7);
    A1_str(2) = A_str(8);
    A1_str(3) = A_str(5);
    A1_str(4) = A_str(6);
    A1_str(5) = A_str(3);
    A1_str(6) = A_str(4);
    A1_str(7) = A_str(1);
    A1_str(8) = A_str(2);
    A = uint32(hex2dec(A1_str));
    A = typecast(A,'single');
    fprintf('\nlog(x) = %f\n', A);
end

fclose(com_port);