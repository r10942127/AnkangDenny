% Core: 在完全未知的參數下，僅靠著資料特性來估算fc與頻寬，並決定要挑幾個channel
% Hyperparameters: step, total_level, min_BW
% Numbers of plotting: 1
function [BW,fc] = find_BW_fc_blind(data,Ts_USRP,ch_num)
    N = length(data);
    step = 5e5;
    final_step = floor(N/step);
    fft_data = zeros(final_step,step);
    for s=1:final_step
        data1 = data(((s-1)*step+1):(s*step));
        fft_data(s,:) = fftshift(abs(fft(data1)));
    end
    
    variance_f_dB = 20*log(var(fft_data,0,1));
    f_axis=(ceil(-step/2):ceil(step/2)-1)/(Ts_USRP*step);
    figure()
    plot(f_axis,variance_f_dB)
    title('Bandwidth estimation')
    grid on

    total_level=100;            % 切100條線出來
    ff = f_axis(3)-f_axis(2);   
    gap = max(variance_f_dB)-min(variance_f_dB);
    step = gap/total_level;
    record = [];                % 紀錄100條線當中最大連續0的數量
    for level = 1:total_level   % 掃這100條線當中最大連續0的數量
        level_temp = min(variance_f_dB)+level*step;
        len = 0;
        max_len = 0;
        for i=1:length(variance_f_dB)
            len = len+1;
            if variance_f_dB(i)<level_temp
                if len>max_len
                    max_len = len;
                end
                len = 0;
            end
        end
        record = [record max_len*ff];
    end
%     figure()
%     plot(record)
    
    %% noise最大的頻寬
    min_BW = 5000; % noise最大的頻寬(adaptive)
    flag = 1;
    while(flag)
        record_valid = record(record>min_BW); 
        record_diff = diff(record_valid);
        [min_value,min_index] = min(record_diff);
        if length(record_diff)-min_index>=5
            flag = 0;
        else
            min_BW = min_BW-500;
        end
    end
    result = -inf;
    for m=min_index:length(record_diff)-5
       if result < sum(record_diff(m:m+5))
           result = sum(record_diff(m:m+5));
           result_index = m;
       end
    end
    result_level = min(variance_f_dB)+(result_index+2)*step;
    
%     figure()
%     plot(record_diff)
%     grid on
    
%     len = 0;
%     max_len = 0;
%     f1 = 0;
%     f2 = 0;
%     for i=1:length(variance_f_dB)
%         len = len+1;
%         f2_temp = f_axis(i);
%         if variance_f_dB(i)<result_level
%             if len>max_len
%                 f1 = f2_temp-len*ff;
%                 f2 = f2_temp;
%                 max_len = len;
%             end
%             len = 0;
%         end
%     end
%     f_cc = (f1+f2)/2;
%     BW = f2-f1;

    %% 找其他channel
    len = 0;
    f11 = [];
    f22 = [];
    for i=1:length(variance_f_dB)
        f2_temp = f_axis(i);
        len = len+1;
        if variance_f_dB(i)<result_level
            f11 = [f11 f2_temp-len*ff];
            f22 = [f22 f2_temp];
            len = 0;
        end
    end
    len_record = f22 - f11;
    fcc = (f22+f11)/2;
    BW = [];
    fc = [];
    for ch = 1:ch_num
        [val,index] = max(len_record);
        BW = [BW val];
        fc = [fc fcc(index)];
        len_record(index) = 0;
    end
end