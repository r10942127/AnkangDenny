function CFO = first_CFO(rsmooth,Tsy)
    
    abs_rsmooth = abs(rsmooth);
    window = 1*10^4;
    max_value = 0;
    for i=1:length(rsmooth)-window
        value = sum(abs_rsmooth(i:i+window-1));
        if value>max_value
            test_interval = rsmooth(i:i+window-1);
            max_value = value;
        end
    end
    thre = threshold_noise_signal(test_interval);
    test_interval = test_interval(abs(test_interval)>thre);
    var_rsmoothh = zeros(1,601);
    for ii = 1:601 % 每1Hz為間隔掃fc
        rsmoothh = test_interval.*exp(-1i * 2 * pi * (ii-301) * (1:length(test_interval)) * Tsy);
        rsmooth = rsmoothh(abs(rsmoothh)>thre);
        rsmoothhh = abs(rsmooth).*power(exp(1i*angle(rsmooth)),8);
        var_rsmoothh(ii) = var(rsmoothhh);
    end
    
    figure()
    plot(var_rsmoothh)
    title('first CFO')
    [~,indexxx] = min(var_rsmoothh);
    
    rsmooth_1 = test_interval .* exp(-1i * 2 * pi * 1 * (indexxx-301) * (1:length(test_interval)) * Tsy);
    var_rsmoothh = zeros(1,201);
    for ii = 1:201 % 每0.1Hz為間隔掃fc
        rsmoothh = rsmooth_1.*exp(-1i * 2 * pi * 0.1 * (ii-101) * (1:length(rsmooth_1)) * Tsy);
        rsmooth = rsmoothh(abs(rsmoothh)>thre);
        rsmoothhh = abs(rsmooth).*power(exp(1i*angle(rsmooth)),8);
        var_rsmoothh(ii) = var(rsmoothhh);
    end
    figure()
    plot(var_rsmoothh)
    title('first CFO 0.1Hz')
    [~,indexxxx] = min(var_rsmoothh);
    CFO = indexxx-301 + 0.1*(indexxxx-101);
end