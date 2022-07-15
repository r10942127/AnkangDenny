function [start_point,end_point] = decide_message_span(result)
    window_size = 10;   % hypers
    %result1 = result;
    result1 = [0 abs(diff(result))];
    figure()
    plot(result1)
    title('FACCH0')
    check_range = 200;
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
        record(s) = sum((result2>((s-1)*step) + min_value) & (min_value + result2<=(s*step)));

    end
    figure()
    plot(record)
    title("hi")
    [val,index] = max(record);
    thr = min_value + (index+20)*step;
    result2(result2<=thr) = thr;
    figure()
    plot(record)
    grid on
    title("record")

    figure()
    plot(result2)
    title('possible time steps')
    grid on
    %% 轉dB，消除太大amplitude的影響
    final_step = floor(length(result)/window_size);
    result_dB = log10(result2);
    middle = (max(result_dB)+min(result_dB))/2.5;
    result_dB(result_dB<middle)=0;
    result_dB = result_dB(1:window_size:end);
    figure()
    plot(result_dB)
    title('possible time steps (after dB)')
    grid on
    %% 找start_point與end_point
    
    start_flag = 0;
    start = [];
    End = [];
    window = 1000; % 容錯空間
    for r=(1-(window/2)):length(result_dB)-(window/2)
        if r<=window/2
            average = sum(result_dB(1:r+(window/2)));
        elseif r>=length(result_dB)-(window/2)
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
            if r==(length(result_dB)+(window/2))
                End = [End final_step];
            else
                if average==0
                    start_flag=0;
                    End = [End r+window/2];
                end
            end
        end
    end
    
    start_point = (start-1)*window_size+1;
    
    end_point = End*window_size;
end