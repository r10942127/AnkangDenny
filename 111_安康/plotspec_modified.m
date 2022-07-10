% plotspec_modified(x,Ts,sign) plots the spectrum of the signal x
% Ts = time (in seconds) between adjacent samples in x
% sign decides whether plotting: 1=plot; 0=not plot
function [ssf,fxs] = plotspec_modified(x,Ts,sign)
    N=length(x);                               % length of the signal x
    ssf=(ceil(-N/2):ceil(N/2)-1)/(Ts*N);       % frequency vector
    fx=abs(fft(x(1:N)));                            % do DFT/FFT
    fxs=fftshift(fx);                          % shift it for plotting
    
    if sign
        figure()
        plot(ssf,fxs)         % plot magnitude spectrum
        xlabel('frequency (Hz)'); ylabel('magnitude')   % label the axes
    end
            


