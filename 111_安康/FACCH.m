function frame = FACCH(rsmooth,Tsy)
    frame = 0;
    figure()
    plot(abs(rsmooth))
    title('FACCH')
    rsmooth_0 = rsmooth;
    [start_point_set,end_point_set] = decide_message_span(abs(rsmooth));
    disp(start_point_set)
    disp(end_point_set)
    interval_length = 5e4;
    for point=1:length(start_point_set)
        rsmooth = rsmooth_0;
        data = rsmooth(start_point_set(point):end_point_set(point));
        total_length = (end_point_set(point)-start_point_set(point));
        final_step = floor(total_length/interval_length);
        for step=1:final_step
            if step==final_step
                short_rsmooth = data((step-1)*interval_length+1:end);
            else
                short_rsmooth = data((step-1)*interval_length+1:step*interval_length);
            end

            [CFO,threshold,threshold2] = second_CFO(short_rsmooth,Tsy);
            rsmooth = short_rsmooth.* exp(-1i * 2 * pi * CFO * (1:length(short_rsmooth)) * Tsy);
            
            rsmoothhhh = rsmooth(abs(rsmooth)>threshold2);
            rsmoothhhh = abs(rsmoothhhh).*power(exp(1i*angle(rsmoothhhh)),8);
            center = mean(real(rsmoothhhh)) + 1i*mean(imag(rsmoothhhh));
            PHO = angle(center)/8;
            rsmooth = rsmooth*exp(-1i*PHO); 
            
            tmp = rsmooth;
            tmp(abs(rsmooth)<threshold) = 0;
            tmp(tmp~=0) = 1;
            tmp = [tmp 0 0 0 0] + [0 tmp 0 0 0] + [0 0 tmp 0 0] + [0 0 0 tmp 0] + [0 0 0 0 tmp];
            tmp = tmp(3:end-2);
            tmp(tmp~=0) = 1;
            tmp = [0 tmp];
            tmp2 = tmp(2:end)-tmp(1:end-1);
            
            start_point = find(tmp2 == 1);
            stop_point = find(tmp2 == -1);
            if length(start_point) > length(stop_point)
                start_point = start_point(1:end-1);
            end
            
            find_burst = stop_point - start_point;
            start_point = start_point(find_burst>=192);
            stop_point = stop_point(find_burst>=192);
            
            clear tmp tmp2
            
            pilot_1 = [-1 -1 1 1 1 1 1 -1 1 1 1 -1]; % 001111101110
            pilot_2 = [-1 -1 -1 1 -1 -1 1 1 1 -1 -1 -1]; % 000100111000
            pilot_3 = [-1 -1 1 1 1 1 1 -1 1 1]; % 0011111011
            
            pilot = [zeros(1,56) pilot_1 zeros(1,118) pilot_2 zeros(1,118) pilot_3 zeros(1,58)];
            
            result = [];
            for i = 1:length(start_point)
                tmp = rsmooth(start_point(i):stop_point(i));
                tmp2 = label_code_7(tmp,pilot);
               
                result = [result tmp2];
            end
            if (length(result)>0)
                check = conv(fliplr(pilot),result);
                figure()
                plot(check);
                title(point)
            end
        end
    end
end