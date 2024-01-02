%==========================================================================
% Read GTSPP data (at data)
%
% (https://www.nodc.noaa.gov/GTSPP/document/codetbls/gtsppcode.html)
% Variable   Discription                   Unit
% TEMP       Temperature                   degree C
% PSAL       Salinity                      PSU
%
% input  :
% 
% output :
%
% Siqi Li, Lu Wang, and Changsheng Chen
% SMAST
% 2021-09-18
%
% Updates:
%
%==========================================================================
function nodc = read_gtspp(fin, varargin)

read_varargin(varargin, {'xlims'}, {[]});
read_varargin(varargin, {'ylims'}, {[]});
read_varargin(varargin, {'polygon'}, {[]});
read_varargin(varargin, {'tlims'}, {[]});
read_varargin2(varargin, {'Log'});
read_varargin2(varargin, {'Original'});


if ~isempty(xlims)
    k = find(xlims>180);
    xlims(k) = xlims(k) - 360;
end

if ~isempty(polygon)
    dim = size(polygon);
    if dim(1)<=dim(2)
        polygon = polygon';
    end
    if size(polygon,2)~=2
        error('Wrong size of polygon')
    end
end

nodc0 = [];

% fin='./at201210';
% file='at199001';
% file='test';

% % Get the file name.
% tmp1=strfind(fin,'\');
% tmp2=strfind(fin,'/');
% filename=fin;
% if (isempty(tmp1) && ~isempty(tmp2))
%     filename=fin(tmp2(end)+1:end);
% end
% if (~isempty(tmp1) && isempty(tmp2))
%     filename=fin(tmp1(end)+1:end);
% end

fid=fopen(fin);

n=0;        % Observation #
% n1=0;       % start line
n2=0;       % end line
ii = 0;     % Observation for output
while (~feof(fid))
    
    if mod(n, 10000)==0 && n>0
        disp(['----' num2str(n)])
    end
    
    % 1----------- Header record
    line=fgetl(fid);
    n=n+1;
    n1=n2+1;
    n2=n1;
    if_TEMP=false;
    if_PSAL=false;
%     if_HCDT=false;
%     if_HCSP=false;
    
    
    % Location
    lat=str2double(line(63:70));
    lon=-str2double(line(71:79));  
    
    % Date
    year=str2num(line(27:30));
    month=str2num(line(31:32));
    day=str2num(line(33:34));
    hour=str2num(line(35:36));
    minute=str2num(line(37:38));
    
    % Profile header
    clear prof_type
    n_prof=str2num(line(122:123));
    n_segg=zeros(n_prof,1);
    prof_type(1:n_prof,1:4)='-';
    for i=1:n_prof
        val_header=line(14*i+117:14*i+130);
        n_segg(i)=str2num(val_header(1:2));
        prof_type(i,:)=val_header(3:6);
        
        if (strcmp(prof_type(i,:),'TEMP'))
            if_TEMP=true;
            nz_TEMP=zeros(n_segg(i),1);
            temp=[];
        elseif (strcmp(prof_type(i,:),'PSAL'))
            if_PSAL=true;
            nz_PSAL=zeros(n_segg(i),1);
            psal=[];
%         elseif (strcmp(prof_type(i,:),'HCDT'))
%             if_HCDT=true;
%             nz_HCDT=zeros(n_segg(i),1);
%             hcdt=[];
%         elseif (strcmp(prof_type(i,:),'HCSP'))
%             if_HCSP=true;
%             nz_HCSP=zeros(n_segg(i),1);
%             hcsp=[];
%         elseif (strcmp(prof_type(i,:),'DOXY'))
%             % DISSOLVED OXYGEN (mmol/m**3)
%         elseif (strcmp(prof_type(i,:),'SVEL'))
%             % SOUND VELOCITY (m/s)
%         elseif (strcmp(prof_type(i,:),'PHOS'))
%             % PHOSPHATE (P04-P) CONTENT (mmol/m**3)
%         elseif (strcmp(prof_type(i,:),'PHPH'))
%             % HYDROGEN ION CONCENTRATION (pH)
%         elseif (strcmp(prof_type(i,:),'USAL'))
%             % UNDEFINED SALINITY (Prac. Salin or parts/thousand)
%         elseif (strcmp(prof_type(i,:),'OSI$'))
%             % Originator's sample identifier
%         elseif (strcmp(prof_type(i,:),'FLU1'))
%             % Chemistry Chlorophyll concentration measured by fluorometer (mg/m**3)
%         elseif (strcmp(prof_type(i,:),'SLCA'))
%             % SILICATE(SIO4-SI) CONTENT (mmol/m**3)
%         elseif (strcmp(prof_type(i,:),'DIC$'))
% %             disp('9999')
% %             if_DIC=true;
% %             nz_DIC=zeros(n_segg(i),1);
% %             dic=[];          
%         elseif (strcmp(prof_type(i,:),'NTRZ'))
%             % NITRATE NITRITE CONTENT (mmol/m**3)
%             %         else
%             %             disp(['Un-known variable: ' prof_type(i,:)])
        end
    end
    
    % 2-----------Profile record
    for i=1:n_prof
        for j=1:n_segg(i)
            line=fgetl(fid);
            n2=n2+1;
            
            profile_type=line(53:56);
            nz=str2num(line(59:62));
            
            data=nan(nz,2);
            for k=1:nz
                s0=63+(k-1)*17+1;
                data(k,1)=str2double(line(s0:s0+5));
                data(k,2)=str2double(line(s0+7:s0+15));
            end
            
            if (strcmp(profile_type,'TEMP'))
                nz_TEMP(j)=nz_TEMP(j)+nz;
                temp=[temp;data];
            elseif (strcmp(profile_type,'PSAL'))
                nz_PSAL(j)=nz_PSAL(j)+nz;
                psal=[psal;data];
%             elseif (strcmp(profile_type,'HCDT'))
%                 nz_HCDT(j)=nz_HCDT(j)+nz;
%                 hcdt=[hcdt;data];
%             elseif (strcmp(profile_type,'HCSP'))
%                 nz_HCSP(j)=nz_HCSP(j)+nz;
%                 hcsp=[hcsp;data];
%             elseif (strcmp(profile_type,'DIC$'))
%                 nz_DIC(j)=nz_DIC(j)+nz;
%                 dic=[dic;data];                
                %             else
                %                 disp(['Un-known variable: ' profile_type])
            end
        end
    end
    
%     % Output
%     sta{n}.lon=lon;
%     sta{n}.lat=lat;
%     sta{n}.mjd=datenum(year,month,day,hour,minute,0)-datenum(1858,11,17,0,0,0);
%     sta{n}.if_TEMP=if_TEMP;
%     sta{n}.if_PSAL=if_PSAL;
%     sta{n}.if_HCDT=if_HCDT;
%     sta{n}.if_HCSP=if_HCSP;
%     
%     if (if_TEMP)
%         sta{n}.TEMP=temp;
%     end
%     if (if_PSAL)
%         sta{n}.PSAL=psal;
%     end
    % Output
    % Check the xlims
    if ~isempty(xlims)
        if xlims(1) <= xlims(2)
            if lon<xlims(1) || lon>xlims(2)
                continue
            end
        else
            if lon>xlims(2) && lon<xlims(1)
                continue
            end
        end
    end
    % Check the ylims
    if ~isempty(ylims)
        if lat>ylims(2) || lat<ylims(1)
            continue
        end
    end
    % Check the polygon (not support pacific ocean now)
    if ~isempty(polygon)
        in = inpolygon(lon, lat, polygon(:,1), polygon(:,2));
        if ~in
            continue
        end
    end
    % Check the tlims
    tt = datenum(year,month,day,hour,minute,0);
    if ~isempty(tlims)
        if tt<tlims(1) || tt>tlims(2)
            continue
        end
    end
        
    if ~if_TEMP && ~if_PSAL
        continue
    end
    
    if all(isnan(temp(:,2))) && all(isnan(psal(:,2)))
        continue
    end
    
    
    ii = ii + 1;
    nodc0(ii).lon=lon;
    nodc0(ii).lat=lat;
    nodc0(ii).time=tt;
    nodc0(ii).TimeStr=[num2str(year) '-' num2str(month,'%2.2d') '-' num2str(day,'%2.2d') '_' num2str(hour,'%2.2d') ':' num2str(minute,'%2.2d') ':00'];
    
%     nodc(ii).mjd=datenum(year,month,day,hour,minute,0)-datenum(1858,11,17,0,0,0);
%     nodc(ii).if_TEMP=if_TEMP;
%     nodc(ii).if_PSAL=if_PSAL;
%     nodc(ii).if_HCDT=if_HCDT;
%     nodc(ii).if_HCSP=if_HCSP;
    
    
    if (if_TEMP)
        [~, I] = sort(temp(:,1));
        nodc0(ii).dep_t=temp(I,1)';
        nodc0(ii).T=temp(I,2)';
    else
        nodc0(ii).dep_t=nan;
        nodc0(ii).T=nan;
    end
    if (if_PSAL)
        [~, I] = sort(psal(:,1));
        nodc0(ii).dep_s=psal(I,1)';
        nodc0(ii).S=psal(I,2)';
    else
        nodc0(ii).dep_s=nan;
        nodc0(ii).S=nan;
    end
%     [u,v] = calc_current2uv(hcsp(:,2), hcdt(:,2));
%     if (if_HCDT && if_HCSP)
%         nodc(ii).dep_uv=hcdt(:,1)';
%         nodc(ii).u=u';
%         nodc(ii).v=v';
%     else
%         nodc(ii).dep_uv=nan;
%         nodc(ii).u=nan;
%         nodc(ii).v=nan;
%     end
%     if (if_HCDT)
%         nodc(ii).HCDT=hcdt;
%     else
%         nodc(ii).HCDT=nan;
%     end
%     if (if_HCSP)
%         nodc(ii).HCSP=hcsp;
%     else
%         nodc(ii).HCSP=nan;
%     end
    
%     lon_fig(n)=lon;
%     lat_fig(n)=lat;
    
    % Log
    if Log
        disp(['=======================' num2str(ii,'%6.6d') '========================='])
        disp(['  Line :' num2str(n1) ' to ' num2str(n2)])
        fprintf('%s%10.4f%s%10.4f\n','  Longtidue : ',lon,'    Latitude : ',lat)
        disp(['  Date : ' datestr(tt,'yyyy-mm-dd_HH:MM')])
        disp( ' | Var  |  NZ  |  Zmin  |  Zmax  |  min   |  max   |' )
        disp( ' ---------------------------------------------------' )
        if (if_TEMP)
            fprintf('%s%4d%s%6.1f%s%6.1f%s%6.1f%s%6.1f%s\n',' | TEMP | ',size(temp,1),' | ',min(temp(:,1)),' | ',max(temp(:,1)),' | ',min(temp(:,2)),' | ',max(temp(:,2)),' |')
        end
        if (if_PSAL)
            fprintf('%s%4d%s%6.1f%s%6.1f%s%6.1f%s%6.1f%s\n',' | PSAL | ',size(psal,1),' | ',min(psal(:,1)),' | ',max(psal(:,1)),' | ',min(psal(:,2)),' | ',max(psal(:,2)),' |')
        end
%         if (if_HCDT)
%             fprintf('%s%4d%s%6.1f%s%6.1f%s%6.1f%s%6.1f%s\n',' | HCDT | ',size(hcdt,1),' | ',min(hcdt(:,1)),' | ',max(hcdt(:,1)),' | ',min(hcdt(:,2)),' | ',max(hcdt(:,2)),' |')
%         end
%         if (if_HCSP)
%             fprintf('%s%4d%s%6.1f%s%6.1f%s%6.1f%s%6.1f%s\n',' | HCSP | ',size(temp,1),' | ',min(hcsp(:,1)),' | ',max(hcsp(:,1)),' | ',min(hcsp(:,2)),' | ',max(hcsp(:,2)),' |')
%         end
    end
    
end

disp('=====================================')
disp(['Total records  : ' num2str(n)])
disp(['Output records : ' num2str(ii)])

% % Figure
% figure
% m_proj('miller','lat',89.9);
% hold on
% [CS,CH]=m_etopo2('contourf',[-9000:500:0 250:250:3000],'edgecolor','none');
% m_plot(-lon_fig,lat_fig,'r.')
% m_grid('linestyle','none','tickdir','out','linewidth',3);
% colormap([ m_colmap('blues',144); m_colmap('gland',48)]);
% brighten(.5);
% ax=m_contfbar([.2 .8],0,CS,CH);
% % a=title(ax,{'Level/m',''}); % Move up by inserting a blank line
% set(gcf,'position',[35    75   998   846])
% print('./1.png','-dpng','-r300')



    
    

if ~Original
% Merge
lon0 = [nodc0(:).lon]';
lat0 = [nodc0(:).lat]';
lonlat = unique([lon0 lat0], 'rows');

for i = 1 : size(lonlat,1)
    nodc(i).lon = lonlat(i,1);
    nodc(i).lat = lonlat(i,2);
    
    k = find(sqrt((lon0-lonlat(i,1)).^2 + (lat0-lonlat(i,2)).^2) < 1e-5);
    depth = unique([nodc0(k).dep_t nodc0(k).dep_s]);
    time = unique([nodc0(k).time]);
    nodc(i).depth = depth;
    nodc(i).time = time;
    
    nz = length(depth);
    nt = length(time);
    T = nan(nz, nt);
    S = nan(nz, nt);
    for j = 1 : length(k)
        
        itime = nodc0(k(j)).time;
        it = find(time==itime);
        
        idepth = nodc0(k(j)).dep_t;
        iz = find(ismember(depth, idepth));
        T(sub2ind([nz,nt], iz, repmat(it,1,length(iz)))) = nodc0(k(j)).T;
        
        idepth = nodc0(k(j)).dep_s;
        iz = find(ismember(depth, idepth));
        S(sub2ind([nz,nt], iz, repmat(it,1,length(iz)))) = nodc0(k(j)).S;
        
    end
    nodc(i).T = T;
    nodc(i).S = S;
    
end       



disp(['Output stations  : ' num2str(i)])

end
        