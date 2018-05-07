#!/usr/bin/octave -qf

% http://audiograins.com/blog/2012/04/autocorrelation-for-tempo-estimation/

pkg load signal;
format long;

arg_list = argv();
filename = arg_list{1};
min_bpm = str2num(arg_list{2});
max_bpm = str2num(arg_list{3});

% constants
cutoff = 220; % no business over above this
% [b, a] = butter(9, (220/(44100/2)))
b = [5.21587348910267e-17 4.69428614019241e-16 1.87771445607696e-15 4.38133373084625e-15 6.57200059626937e-15 6.57200059626937e-15 4.38133373084625e-15 1.87771445607696e-15 4.69428614019241e-16 5.21587348910267e-17];
a = [1.000000000000000 -8.819493751378667 34.572210470407313 -79.058694104204278 116.227434873338126 -113.919565426721988 74.442078699170949 -31.273375546978357 7.664243680050069 -0.834838893683127];

% load and preprocess audio
[audio, fs] = audioread(filename);
audio = audio(:, 1); % left if stereo
audio = abs(audio); % rectifying seems to fix some double-tempo errors - why?
audio = filter(b, a, audio);
ds_factor = floor(fs/(2*cutoff)); % rather to little than too much
audio = downsample(audio, ds_factor);
fs = round(fs/ds_factor); % circa

% calc and process autocorr
maxlag = round(fs*(60/min_bpm)); % min 80 bpm
minlag = round(fs*(60/max_bpm)); % max 160 bpm
ax = xcorr(audio, maxlag); % no minlag?
axstart = length(ax)/2 + 1; % symmetric
ax = ax(floor(axstart + minlag):end); % rather too much than too little

% find tempo
[~, idx] = max(ax);
bpm = (60*fs)./(idx+minlag)

% analysis: watch autocorr grow by the samples
% maxlag
% minlag
% idx
% fs
% ax = zeros(1, maxlag);
% stepsamples = 50; % plot step size samples
% steptime = 0.01; % plot step size seconds
% for i=1:length(audio)
%     for j=1:maxlag
%         ax(j) += audio(i + j)*audio(i);
%     end
%     if (mod(i, stepsamples) == 0)
%         figure(1);
%         plot(ax);
%         figure(2);
%         plot([1:i], audio(1:i), 'Color', 'r');
%         pause(steptime);
%     end
% end
