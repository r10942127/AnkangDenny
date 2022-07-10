% Core: 知道BW與中心頻後，利用這兩個資訊判斷每一小段時間點裡有無傳訊息
% Hyperparameters: window_size, window
% Numbers of plotting: 2
function [start_point,end_point,max_point] = message_span(BW,f_cc,data,fs_USRP)
    f1 = f_cc-(BW/2);
    f2 = f_cc+(BW/2);
    window_size = 1e4;   % hyper
    final_step = floor(length(data)/window_size);
    result = zeros(1,final_step);
    %% 將整筆資料切小段，找每段時間內的fft的平均值
    f_start = ceil(window_size*(f1/fs_USRP) + window_size/2)+1;
    f_end = floor(window_size*(f2/fs_USRP) + window_size/2)+1;
    for s=1:final_step
        freq_data = fftshift(abs(fft(data((s-1)*window_size+1:s*window_size))));
        result(s) = mean(freq_data(f_start:f_end));
    end
    figure()
    plot(result)
    % 對抗nonstationary noise
    result1 = [0 abs(diff(result))];
    figure()
    plot(result1)
    check_range = 20;
    result2 = result1;
    for i=1:length(result1)
        if i<=check_range
            result2(i) = max(result1(1:i));
        else
            result2(i) = max(result1(i-check_range:i));
        end
    end
    max_value = max(result2);
    min_value = min(result2);
    step = (max_value-min_value)/100;
    record = zeros(1,100);
    for s = 1:100
        record(s) = sum((result2>((s-1)*step+1)) & (result2<=(s*step)));
    end
    [val,index] = max(record);
    thr = min_value + (index-1)*step;
    result2(result2<=thr) = thr;
    figure()
    plot(record)
    grid on

    % Nothing to do with deciding message intervals 
    [value,max_point] = max(result);   
    max_point = max_point*window_size; 
    %

    figure()
    plot(result2)
    title('possible time steps')
    grid on
    %% 轉dB，消除太大amplitude的影響
    result_dB = log10(result2);
    middle = (max(result_dB)+min(result_dB))/2;
    result_dB(result_dB<middle)=0;
    figure()
    plot(result_dB)
    title('possible time steps (after dB)')
    grid on
    %% 找start_point與end_point
    start_flag = 0;
    start = [];
    End = [];
    window = 20; % 容錯空間
    for r=(1-(window/2)):final_step+(window/2)
        if r<=window/2
            average = sum(result_dB(1:r+(window/2)));
        elseif r>=final_step-(window/2)
            average = sum(result_dB(r-(window/2):end));
        else
            average = sum(result_dB(r-(window/2):r+(window/2)));
        end
        if start_flag==0
            if average>0
                start_flag=1;
                start = [start r+window/2];
            end
        else
            if r==final_step+(window/2)
                End = [End final_step];
            else
                if average==0
                    start_flag=0;
                    End = [End r-window/2];
                end
            end
        end
    end
    start_point = (start-1)*window_size+1;
    end_point = End*window_size;
end