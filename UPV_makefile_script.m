clc;
clear all;
close all;

log_base = 10;
q        = 10;

if ((log_base == 1) || (log_base<=0))
    fprintf('log_base must be larger than 0, and not 1\n');
    return;
end
if (((round(q) ~= q)) || (q<2))
   fprintf('q must be an int larger than or equal to 2\n');
   return; 
end
mul_base    = log(2)/log(log_base);
base_file   = fopen('C:\Users\Tafkal\Desktop\log_base_file.mif', 'w');

if (base_file)     
    % Write the data
    fprintf(base_file,'WIDTH = %d;\n', 32);
    fprintf(base_file,'DEPTH = %d;\n\n', 1);
    fprintf(base_file,'ADDRESS_RADIX = BIN;\n');
    fprintf(base_file,'DATA_RADIX = HEX;\n\n');
    fprintf(base_file,'CONTENT\nBEGIN\n\n');
    fprintf(base_file,'%x : ',0);
    fprintf(base_file,'%s;\n', num2hex(single(mul_base)));   
    fprintf(base_file,'END;\n');
    fclose(base_file);
    t = 0; % successful
else
    t = 1; % error
end


a = fi(1, 0, q+1, q);
b = fi(2^-q, 0, q+1, q);
i = 1;
single p;
while (a<2)
    p(i) = log(single(a))/log(log_base) ;
    a = a + b;
    if (a.WordLength > 32000)
        a = fi(a, 0, q+1, q);
    end;
    i = i+1;
end
k = num2hex(p);

man_file = fopen('C:\Users\Tafkal\Desktop\man_file.mif', 'w');

if (man_file)     
    % Write the data
    fprintf(man_file,'WIDTH = %d;\n', 32);
    fprintf(man_file,'DEPTH = %d;\n\n', 2^q);
    fprintf(man_file,'ADDRESS_RADIX = HEX;\n');
    fprintf(man_file,'DATA_RADIX = HEX;\n\n');
    fprintf(man_file,'CONTENT\nBEGIN\n\n');
    for n = 0:1:i-2
        fprintf(man_file,'%x : ',n);
        fprintf(man_file,'%s;\n', (k(n+1, :))); 
    end   
    fprintf(man_file,'END;\n');
    fclose(man_file);
    t = 0; % successful
else
    t = 1; % error
end

Q_file = fopen('C:\Users\Tafkal\Desktop\Q_val.vhd', 'w');

if(Q_file)
    fprintf(Q_file,'LIBRARY ieee;\nUSE ieee.std_logic_1164.all;\n\npackage Q_val is\n\tconstant Q : integer := %d;\nend Q_val;', q);
    fclose(Q_file);
    t = 0;
else
    t = 1;
end