function [CFO,threshold,threshold2] = second_CFO(rsmooth,IPOINT,Tsy,rcpul)
    sc = 0.02*(1:50)*(max(abs(rsmooth))-min(abs(rsmooth)))+min(abs(rsmooth));
    ttt=[];
    tttt = zeros(1,50);
    for tt = 1:50
        ttt = [ttt length(find(abs(rsmooth)<=sc(tt)))];
    end
    ttt(2:end)=ttt(2:end)-ttt(1:end-1);
    tttt(1) = ttt(1);
    tttt(2:end)=ttt(2:end)-ttt(1:end-1);

    [~,index] = min(tttt);
    threshold = sc(index+2);
    [~,index2] = max(ttt(index+3:end));
    % threshold2 = sc(index+index2+3);
    threshold2 = 2;   
    rsmooth = rsmooth(abs(rsmooth)>threshold2);
    for ii = 1:201
        rsmoothh = rsmooth .* exp(-1i * 2 * pi * 0.1 * (ii-101) * (1:length(rsmooth)) * Tsy / IPOINT);
        rsmoothh = conv(rsmoothh,rcpul,'same');
        rsmoothh = rsmoothh(1:end-mod(length(rsmoothh),IPOINT));
        rsmoothhh = reshape(rsmoothh,IPOINT,[]);
        [maxx,indexx] = max(mean(abs(rsmoothhh),2));
        rsmoothh = rsmoothhh(indexx,:);
        rsmoothhh = abs(rsmoothh).*power(exp(1i*angle(rsmoothh)),8);
        var_rsmoothh(ii) = var(rsmoothhh);
    end
    [~,indexxx] = min(var_rsmoothh);
    CFO = 0.1 * (indexxx-301);
end