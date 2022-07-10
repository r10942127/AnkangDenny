clc
clear all
close all
%%  Data Paremeters
% USRP info.
fs_USRP = 5e5;               % Sampling frequency(rate) 
Ts_USRP = 1/fs_USRP;         % Sampling period
%% Part1. 讀檔
disp('Read data...')
file_name = 'C:\Users\Doraemon\Desktop\安康data\2022安康data\s1';
[fid,message] = fopen(file_name, 'r');
Data_from_file = fread(fid , inf , 'uint16');%1e6 inf
fclose(fid);
% Convert Unsigned Interger to Signed Interger
a = floor(Data_from_file/256); % 2^8 = 256
b = mod(Data_from_file, 256);
aa = b.*(16^2) + a;
for i = 1:length(aa)
    if aa(i) > 32768           % 2^15 = 32768
        aa(i) = aa(i) - 2^16;
    end
end
% Convert Data into Complex Form 
c = reshape(aa,2,length(aa)/2);
data = c(1,:) + 1j * c(2,:);
clear c; clear aa; clear b; clear Data_from_file

%% Part2. 盲測bandwidth與fc
disp('BW & fc estimation...')
[BW,fc] = find_BW_fc_blind(data,Ts_USRP,2); % 最後一個para是指要抓多少channel出來
% decide SR with selective options
fsy = 16e3;
Tsy = 1/fsy;

%% Part3. down converter, down sample(1), resample, match filter

% Down converter
data_origin = data;
data = data_origin;%(2.2e8:2.21e8);
f_c = fc(1);
%f_c = -99640;
%f_c = -78103.5;
Baseband_data = data .* exp(-1i * 2 * pi * f_c * (1:length(data)) * Ts_USRP);

% Down sample(down M)
M = 20;
new_fs = fs_USRP/M;
rr = resample(Baseband_data,new_fs,fs_USRP);

% Resample(not integer)
IPOINT = ceil(new_fs/fsy);
new_Ts = 1/new_fs;
intfac=IPOINT/(Tsy/new_Ts);
cpu=4;
d_sum_all=zeros(cpu,fix(length(rr)*intfac));
parfor id=0:cpu-1
    [d_sum_all(id+1,:),const]=dataresample(rr,Tsy/new_Ts,1/new_Ts,IPOINT,id,cpu);
end
rsmooth=sum(d_sum_all);
nfs=intfac * new_fs;

% Shaping Filter initialization
L=6;   
rolloff=0.3;                          
rcpul=rcosdesign(rolloff,L,IPOINT,'sqrt');

%% Part 4. 1st interval detection, 1st CFO, 2nd interval detection
CFO = first_CFO(rsmooth,rcpul,IPOINT,Tsy);
disp('hi')
%%
close all 
rsmooth = rsmooth.* exp(-1i * 2 * pi * CFO * (1:length(rsmooth)) * Tsy / IPOINT);
figure()
plot(abs(rsmooth))
PilotType = 1;
switch PilotType
    case 1
        FACCH(rsmooth,IPOINT,Tsy,rcpul);
end
disp('end')
