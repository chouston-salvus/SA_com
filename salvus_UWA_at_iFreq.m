function uwa = salvus_UWA_at_iFreq(fringeMat, iFreq)

F = fft(fringeMat,[],2);
F_iFreq = F(:,iFreq);
uwa = -unwrap(angle(F_iFreq));

end