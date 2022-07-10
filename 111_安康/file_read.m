function [rsmooth,sps] = file_read(file_name, fs, fc)
    fprintf('Data conversion:\n');
    tic
    [fid,message]=fopen(file_name,'r');
    A =fread(fid,inf, 'uint16');
    fclose(fid);
    AA=A;
    a=floor(AA/256);
    b=mod(AA,256);
    clear A; clear AA; 
    aa=b.*(16^2)+a;
    clear b;
    clear a;
    for i=1:length(aa)
        if aa(i)>32768
            aa(i)=aa(i)-2^16;
        end
    end
    b=reshape(aa,2,length(aa)/2);
    clear aa;
    data=b(1,:)+1j*b(2,:);
    clear b;
    toc
    
    subBW_database = 10e3*[125 156.25 31.25 62.5];
    sr_database = 10e3*[93.6 117 23.4 46.8];
    rsmooth = [];
    sps = zeros(1,4);
    for num = 1:4
        %% Downconvertion
        fprintf('Down conversion:\n');
        Ts = 1/fs;
        subBW = subBW_database(num);
        subTs = 1/subBW;
    
        n = 0:length(data)-1;
        Tsy = 1/(sr_database(num)*(fs/subBW_database(num))); % symbol rate = 23.4kHz * 320
        ri = data.*cos(2*pi*fc*n*Ts);%convert to baseband
        rq = -data.*sin(2*pi*fc*n*Ts);%convert to baseband
        clear data;clear n;
        rr = ri + 1j*rq;
        clear ri;clear rq;
        toc
    
        %% Down sample(down 320)
        fprintf('Down sample:\n');
        tic
        rr_downsample = resample(rr,subBW,fs);
        clear rr;
        toc
    
        %  Resample(not integer)
        fprintf('Resample:\n');
        tic
        sps_new = ceil(sr_database(num)/subBW_database(num));
        intfac = sps_new/(Tsy/Ts);
        cpu = 2;
        d_sum_all = zeros(cpu,fix(length(rr_downsample)*intfac));
        parfor id = 0:cpu-1
            [d_sum_all(id+1,:),const] = dataresample(rr_downsample,Tsy/Ts,1/subTs,2,id,cpu);
        end
        rsmooth = [rsmooth;sum(d_sum_all)];
        sps(num) = sps_new;
    end
end