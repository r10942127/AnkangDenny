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
        step_record(s) = sum((abs_rsmooth>=fr)&(abs_rsmooth<ce))/area;
    end
    figure()
    plot(step_record)
    title('thre_noise_thre')
    step_record = step_record(step_record>700);
    diff_record = step_record(4:end)-step_record(1:end-3);
    [aaaa,index1] = min(diff_record);
    record1 = diff_record(index1:end);
    [aaaa,index2] = max(diff_record);
    index3 =3 + index1 + index2*2/3;
    disp('thre:')
    disp(index3)
    thre = (index3)*step_size + min_level;
end