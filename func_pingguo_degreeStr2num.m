%==========================================================================
% NECOFS TS Toolbox
%
%
% Siqi Li, Lu Wang, and Changsheng Chen
% SMAST
% 2022-03-02
%
% Updates:
%
%==========================================================================
function num = func_pingguo_degreeStr2num(degreeStr)

n = length(degreeStr);

num = nan(n, 1);

for i = 1 : n

    str = degreeStr{i};

    k = findstr(str, '⁰');
   
    while strcmp(str(k+1), '.') || strcmp(str(k+1), ' ') 
        str(k+1) =[];
    end
    num(i) = str2num(str(3:k-1)) + str2num(str(k+1:end))/60;

    if strcmp(str(1), 'S') || strcmp(str(1), 'W')
        num(i) = -num(i);
    end


end
