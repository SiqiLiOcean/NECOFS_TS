%==========================================================================
% NECOFS TS Toolbox
%
% Quality control for T/S observation
%   --- merge the stations that are closed
%   --- rarefy the vertical observed depths
%   --- rarefy the observed time
%   --- check the water depth from the grid and the observed depth
%   --- remove the 'empty sta' (full of NaN)
%
% input  :
%   sta0 
%     --- lon
%     --- lat
%     --- x
%     --- y
%     --- h
%     --- cell
%     --- source
%     --- depth
%     --- time
%     --- nt
%     --- nz
%     --- T
%     --- S
%    
% 
% output :
%
% Lu Wang, Siqi Li, and Changsheng Chen
% SMAST
% 2022-11-01
%
% Updates:
%
%==========================================================================
function sta = ts_quality_control(sta0, varargin)


read_varargin(varargin, {'twin'}, {1/24/2});        % half hour
read_varargin(varargin, {'zwin3'}, {5});
read_varargin(varargin, {'zwin2'}, {2});
read_varargin(varargin, {'zwin1'}, {1});
read_varargin(varargin, {'zwin0'}, {0.5});
read_varargin(varargin, {'depth3'}, {200});
read_varargin(varargin, {'depth2'}, {100});
read_varargin(varargin, {'depth1'}, {45});


% remove the record without either temp and salt obs at the same time
for i = 1 : length(sta0)
    
   k = isnan(sta0(i).T) & isnan(sta0(i).S);
   
   % Remove useless depth
   kz = find(all(k, 2));
   sta0(i).depth(kz) = [];
   sta0(i).nz = length(sta0(i).depth);
   sta0(i).T(kz, :) = [];
   sta0(i).S(kz, :) = [];
   
   
   % Remove useless time
   kt = (all(k, 1));
   sta0(i).time(kt) = [];
   sta0(i).nt = length(sta0(i).time);
   sta0(i).T(:, kt) = [];
   sta0(i).S(:, kt) = [];
       
end

cell0=[sta0.cell];
% k_nan = find(isnan(cell0));
% maxval = max(cell0);
% for i = 1 : length(k_nan)
%     cell0(k_nan(i)) = maxval+1;
% end
cell=unique(cell0);
nsta=length(cell);

% combine the observations in the same cell
for i=1:nsta
    id=find(cell0==cell(i));
    if length(id)>1
        sta1=sta0(id);
        dd1 = [];
        for j = 1 : length(id)
            dd1 = [dd1; sta1(j).depth];
        end
        dd1 = dd1(:);
%         dd1=[sta1.depth];
        dd=sort(unique(dd1));
        nz=length(dd);
        for j=1:length(sta1)
            dep=sta1(j).depth;
            nt0=sta1(j).nt;
            sta2(j).T(1:nz,1:nt0)=nan;
            sta2(j).S(1:nz,1:nt0)=nan;
            [~,iz]=ismember(dep,dd);
            sta2(j).T(iz,:)=sta1(j).T;
            sta2(j).S(iz,:)=sta1(j).S;
        end
        tt1 = [];
        for j = 1 : length(id)
            tt1 = [tt1; sta1(j).time(:)];
        end
        tt1 = tt1(:)';
%         tt1=[sta1.time];
        temp=[sta2.T];
        salt=[sta2.S];
        sta(i).x=sta1(1).x;
        sta(i).y=sta1(1).y;
        sta(i).lon=sta1(1).lon;
        sta(i).lat=sta1(1).lat;
        sta(i).h=sta1(1).h;
        sta(i).nz=nz;
        sta(i).cell=cell(i);
        sta(i).source=sta1(1).source;
        sta(i).depth=dd;
        % time window
        tt=sort(unique(tt1));
        k = 1;
        t0 = tt(1);
        for it = 2 : length(tt)
            dt = tt(it) - t0;
            if dt > twin
                k = [k it];
                t0 = tt(it);
            end
        end
        time=tt(k);
        temp1=temp(:,k);    
        salt1=salt(:,k);      
        nt=length(time);
        sta(i).nt=nt;
        sta(i).time=time;
        sta(i).T=temp1;
        sta(i).S=salt1;
        clear sta2 sta1 temp1 salt1 temp2 salt2 tt2
    else
        sta(i)=sta0(id);
    end
end
% do the depth sparse
for i=1:nsta
    depth0=sta(i).depth;
    h=sta(i).h;
    if h>=depth3
        zwin=zwin3;
    elseif h>=depth2 && h<depth3
        zwin=zwin2;
    elseif h>=depth1 && h<depth2
        zwin=zwin1;
    else
	    zwin=zwin0;
    end

    k=1;
    d0=depth0(1);
    for ik=2:length(depth0)
        dk=depth0(ik)-d0;
        if dk>zwin
            k=[k ik];
            d0=depth0(ik);
        end
    end
    nz=length(k);
    sta(i).depth=depth0(k);
    sta(i).nz=nz;
    sta(i).T=sta(i).T(k,:);
    sta(i).S=sta(i).S(k,:);
end

% Check the maximum observed depth (depth) and the grid water depth(h)
% All depth deeper than h are adjusted.
%   --- the closest one are adjusted to the h-0.01
%   --- the rest are removed.
%
%
% depth(4)------------            depth(4)------------
%    h    ------------               h    ------------ depth(5)
%                         =>   
% depth(5)------------
%
% depth(6)------------
%
for i = 1 : nsta
    h = sta(i).h;
    depth = sta(i).depth;

    iz = find(depth >=h);
    
    if ~isempty(iz)
        sta(i).depth(iz(1)) = h - 0.01;
        if length(iz) > 1
            sta(i).depth(iz(2:end)) = [];
            sta(i).T(iz(2:end), :) = [];
            sta(i).S(iz(2:end), :) = [];
        end
        sta(i).nz = length(sta(i).depth);
    end
end

% remove the record without both temp and salt obs at the same time
for i = 1 : nsta
    
   k = isnan(sta(i).T) & isnan(sta(i).S);
   
   % Remove useless depth
   kz = find(all(k, 2));
   sta(i).depth(kz) = [];
   sta(i).nz = length(sta(i).depth);
   sta(i).T(kz, :) = [];
   sta(i).S(kz, :) = [];
   
   
   % Remove useless time
   kt = (all(k, 1));
   sta(i).time(kt) = [];
   sta(i).nt = length(sta(i).time);
   sta(i).T(:, kt) = [];
   sta(i).S(:, kt) = [];
       
end



end
