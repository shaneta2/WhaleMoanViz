function lt_lVis_plot_WAV_labels

global REMORA PARAMS HANDLES


%create start and end times of window
startWV = PARAMS.plot.dnum;
winLength = HANDLES.subplt.specgram.XLim(2); %get length of window in seconds, used to compute end limit
endWV = startWV + datenum(0,0,0,0,0,winLength);

plotFreq = PARAMS.freq1 *.9;
colF = [1 0 0];


colors = [
    1.0 1.0 1.0;  % White for label 1
    1.0 0.0 0.5;  % Hot pink for label 2
    0.0 1.0 0.0];  % Lime green for label 3
% colors = [
%     1.0 1.0 1.0
%     0.8 0.4 0.8
%     1.0 0.6 0.0
%     0.8 0.6 1.0
%     0.8 1.0 1.0
%     1.0 0.0 0.4
%     1.0 0.6 0.6
%     1.0 0.6 0.2
%     ];

% detection groups
labels = {''};

% position for lines and labels
yPos = plotFreq;
labelPos = yPos*1.05;
ydelta = plotFreq * .10;  % Move plot down for each group
for labidx = 1:length(labels)
    detfld = sprintf('detection%s', labels{labidx});
    if REMORA.lt.lVis_det.(detfld).PlotLabels
        % Find detections within the spectrogram window
        [Lo, Hi] = lt_lVis_get_range(startWV, endWV, ...
            REMORA.lt.lVis_det.(detfld).starts, ...
            REMORA.lt.lVis_det.(detfld).stops);
        
        % Filter to only plot detections with pr = 1
        validIdx = find(REMORA.lt.lVis_det.detection.pr(Lo:Hi) == 1 | REMORA.lt.lVis_det.detection.pr(Lo:Hi) == 2 | REMORA.lt.lVis_det.detection.pr(Lo:Hi) == 3);

        plotIdx = Lo - 1 + validIdx;  % Adjust indices to match original array indexing

        % Get the final detection end time for dotted line plotting
        finalDet = REMORA.lt.lVis_det.(detfld).stops(end);

        % Call plot_labels_wav only if there are valid detections to plot
        if ~isempty(plotIdx)
            plot_labels_wav(plotIdx, yPos, colors, startWV, endWV, finalDet);
        end
    end
    yPos = yPos - ydelta;
    labelPos = labelPos - ydelta;
end


function plot_labels_wav(plotIdx, yPos, colors, startWV, endWV, finalDet)

global REMORA PARAMS HANDLES

% Set up time bounds for detections within the spectrogram window
lablFull = [REMORA.lt.lVis_det.detection.starts, REMORA.lt.lVis_det.detection.stops];
winDets = lablFull(plotIdx, :);

% Calculate relative times for plotting in seconds (from window start time)
detXstart = lt_convertDatenum(winDets(:,1) - startWV, 'seconds');
detXend = lt_convertDatenum(winDets(:,2) - startWV, 'seconds');
detDur = detXend - detXstart;

hold(HANDLES.subplt.specgram, 'on');
LineThresh = 1;  % Threshold for plotting short detections as points

% Loop through each detection to plot with label, frequency range, and score
for iPlot = 1:length(plotIdx)
    absIdx = plotIdx(iPlot);  % Absolute index for this detection

    % Retrieve detection metadata
    minFreq = REMORA.lt.lVis_det.detection.min_freq(absIdx);
    maxFreq = REMORA.lt.lVis_det.detection.max_freq(absIdx);
    score = REMORA.lt.lVis_det.detection.score(absIdx);
    thislabel = REMORA.lt.lVis_det.detection.labels{absIdx};
    pr_label = REMORA.lt.lVis_det.detection.pr(absIdx);  % Get label type
    % Choose color based on pr label
    color = colors(pr_label, :);
    % Plot detection based on duration
    if detDur(iPlot) < LineThresh
        % Plot a point for short detection range
        plot(HANDLES.subplt.specgram, detXstart(iPlot), yPos, '*', 'Color', color);
    else
        % Plot rectangle with ButtonDownFcn for edit mode
        rectHandle = rectangle(HANDLES.subplt.specgram, 'Position', [detXstart(iPlot), minFreq, detDur(iPlot), maxFreq - minFreq], ...
                               'EdgeColor', color, 'LineStyle', '--', 'LineWidth', 1.5);
        rectHandle.ButtonDownFcn = @(src, ~) editBoundingBox(src, absIdx, ...
                                                             detXstart(iPlot), detXend(iPlot), ...
                                                             minFreq, maxFreq, thislabel, score, color);
    end

    % Display the label and score at the start of each detection
    text(HANDLES.subplt.specgram, detXstart(iPlot), maxFreq + 3, thislabel, 'Color', color, 'FontWeight', 'normal');
    text(HANDLES.subplt.specgram, detXstart(iPlot)+2, maxFreq + 3, sprintf('%.2f', score), ...
         'Color', color, 'FontWeight', 'bold');
end

% Plot a line at the end of the detection file if applicable
if ~isempty(winDets) && isequal(plotIdx(end), finalDet)
    plot(HANDLES.subplt.specgram, [detXend(end), detXend(end)], ...
        [PARAMS.freq0, PARAMS.freq1], ':', 'LineWidth', 2, 'Color', color);
end

hold(HANDLES.subplt.specgram, 'off');
