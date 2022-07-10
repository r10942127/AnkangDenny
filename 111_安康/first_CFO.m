function CFO = first_CFO(rsmooth,rcpul,IPOINT,Tsy)
    
    abs_rsmooth = abs(rsmooth);
    rsmooth_all = rsmooth;
    window = 1*10^5;
    max_value = 0;
     for i=1:length(rsmooth)-window
        value = sum(abs_rsmooth(i:i+window-1));
        if value>max_value
            test_interval = rsmooth(i:i+window-1);
            max_value = value;
            pp = i;
        end
    end
    thre = threshold_noise_signal(test_interval);
    test_interval = test_interval(abs(test_interval)>thre);
    var_rsmoothh = zeros(1,2001);
    for ii = 1:201 % 每1Hz為間隔掃fc
        rsmoothh = test_interval.*exp(-1i * 2 * pi * (ii-101) * (1:length(test_interval)) * Tsy / IPOINT);
        rsmooth0 = conv(rsmoothh,rcpul,'same');
        rsmooth0 = rsmooth0(1:end-mod(length(rsmooth0),IPOINT));
        rsmooth = reshape(rsmooth0,IPOINT,[]);
        [maxx,indexx] = max(mean(abs(rsmooth),2));
        rsmooth = rsmooth(indexx,:);
        clear maxx indexx;
        rsmoothhh = abs(rsmooth).*power(exp(1i*angle(rsmooth)),8);
        var_rsmoothh(ii) = var(rsmoothhh);
    end
    disp('begin 0.1Hz')
    [~,indexxx] = min(var_rsmoothh);
    rsmooth_1 = test_interval .* exp(-1i * 2 * pi * 1 * (indexxx-101) * (1:length(test_interval)) * Tsy / IPOINT);
    for ii = 1:201 % 每0.1Hz為間隔掃fc
        rsmoothh = rsmooth_1.*exp(-1i * 2 * pi * (ii-101) * (1:length(rsmooth_1)) * Tsy / IPOINT);
        rsmooth00 = conv(rsmoothh,rcpul,'same');
        rsmooth00 = rsmooth00(1:end-mod(length(rsmooth00),IPOINT));
        rsmooth = reshape(rsmooth00,IPOINT,[]);
        [maxx,indexx] = max(mean(abs(rsmooth),2));
        rsmooth = rsmooth(indexx,:);
        clear maxx indexx;
        rsmoothhh = abs(rsmooth).*power(exp(1i*angle(rsmooth)),8);
        var_rsmoothh(ii) = var(rsmoothhh);
    end
    [~,indexxxx] = min(var_rsmoothh);
    CFO = indexxx-1001 + 0.1*(indexxxx-101);
end