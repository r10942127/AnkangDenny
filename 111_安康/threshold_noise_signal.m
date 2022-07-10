function thre = threshold_noise_signal(rsmooth)
    abs_rsmooth = abs(rsmooth);
    max_level = max(abs_rsmooth);
    min_level = min(abs_rsmooth);
    total_step = 100;
    step_size = (max_level-min_level)/total_step;
    step_record = zeros(1,total_step);
    for s=1:total_step
        fr = min_level+(s-1)*step_size;
        ce = min_level+s*step_size;
        area = ce^2-fr^2;
        step_record(s) = sum((abs_rsmooth>=fr)&(abs_rsmooth<ce))/1;
    end
    figure()
    plot(step_record)
    [val0,index0] = max(step_record);
    step_record = step_record(index0:end);
    flag = 1;
    i=1;
    while(flag && (i<length(step_record)-4))
        if (step_record(i)<step_record(i+1))&&(step_record(i)<step_record(i+2))&&(step_record(i)<step_record(i+3))&&(step_record(i)<step_record(i+4))&&(step_record(i)<step_record(i+5))
            index1 = i;
            flag=0;
        end
        i = i+1;
    end
    thre = (index0+index1)*step_size + min_level;
end