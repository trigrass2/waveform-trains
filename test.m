% demonstration of the 2007 version of the algorithm for Barret


disp 'reading EEG ...'
filename = 'data/KT_7.edf';
hdr = edfopen(filename);
signal = edfread(hdr,0,hdr.nsamples);
channelsToUse = [2:5 7:25];   % selected a subset of channels 
fs = hdr.samples_per_second;
signal = signal(channelsToUse,:);

disp 'filtering...'
% notch filter
[b,a] = iirnotch(60/(fs/2),0.5/fs);
signal = filtfilt(b,a,signal')';

% high-pass filter
cutoff = 2; % Hz
k = hamming(round(fs/cutoff)*2+1);
k = k/sum(k);
signal = signal - convmirr(signal',k)';


disp 'plotting raw data...'
t = (0:size(signal,2)-1)/fs;
yticks = 1e4*(1:size(signal,1));
plot(t,bsxfun(@plus,signal',yticks))
set(gca,'YTick',yticks,'YTickLabel',arrayfun(@(i) strtrim(hdr.channelnames(i,:)),channelsToUse, 'uni', false))
xlabel 'time (s)'


% algorithm paramaters (all units are in samples)
startTime =270; % (s)
epoch = 1800;  
epochStep = 1000;
margin = 200;
widths = [7 25 41 71 91];  % widths of waveforms to look at each iteration
ntrains = 2;
colors = hsv(ntrains);

useNewAlgorithm = true;

for i=floor(epochStep/2)+round(startTime*fs):epochStep:size(signal,2)-epoch
    segment = signal(:,i+(1:epoch));
    if useNewAlgorithm
        [u,w] = choo3(segment',ntrains,71);
    else
        trains = processSegment(segment, ntrains, widths, margin);
    end
%     % plot results
%     plot(t(i+(1:epoch)),bsxfun(@plus,segment',yticks),'k')
%     set(gca,'YTick',yticks,'YTickLabel',arrayfun(@(i) strtrim(hdr.channelnames(i,:)),channelsToUse, 'uni', false))
%     xlabel 'time (s)'
%     
%     hold on
%     for iTrain = 1:length(trains)        
%         w = size(trains(iTrain).waveform,2);
%         trains(iTrain).waveform(trains(iTrain).waveform == 0)=nan;  % suppress plotting
%         ix = floor(margin/2)-floor(w/2)+(0:w-1);
%         for iWave = 1:length(trains(iTrain).idx)
%             plot(t(i+ix+trains(iTrain).idx(iWave)), bsxfun(@plus, trains(iTrain).waveform', yticks),...
%                 'Color',colors(iTrain,:),'LineWidth',3)
%         end
%     end
%     plot(t(i+(1:epoch)),bsxfun(@plus,segment',yticks),'k')
%     hold off
%     drawnow
end