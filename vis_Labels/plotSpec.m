function plotSpec

% plotSpec: Plots TP / FP / FN bounding boxes on the Triton spectrogram
%
% This function is called to plot bounding boxes on the spectrogram window.
% It pulls the information for each bounding box occuring within the
% currently shown spectrogram, and calls a helper function to actually plot.
%
% Adapted from lt_lVis_plot_WAV_labels by Michaela Alksne and Shane Andres

    global REMORA PARAMS HANDLES
    
    
    % create start and end times of window
    startWV = PARAMS.plot.dnum;
    winLength = HANDLES.subplt.specgram.XLim(2); % get length of window in seconds, used to compute end limit
    endWV = startWV + datenum(0,0,0,0,0,winLength);
    
    plotFreq = PARAMS.freq1 *.9;
     
    colors = [
        1.0 1.0 1.0;  % white for label 1
        1.0 0.0 0.5;  % red for label 2
        0.0 1.0 0.0];  % green for label 3
    
    % y position for points
    yPos = plotFreq;

    % skip plotting if no detections exist
    if isempty(REMORA.lt.lVis_det.detection.labels)
        return;
    end
    
    if REMORA.lt.lVis_det.detection.PlotLabels
        % find detections within the spectrogram window
        [Lo, Hi] = getDetectionRange(startWV, endWV, ...
            REMORA.lt.lVis_det.detection.starts, ...
            REMORA.lt.lVis_det.detection.stops);
        
        % filter to only plot detections with pr = 1, 2, or 3
        validIdx = find(REMORA.lt.lVis_det.detection.pr(Lo:Hi) == 1 | REMORA.lt.lVis_det.detection.pr(Lo:Hi) == 2 | REMORA.lt.lVis_det.detection.pr(Lo:Hi) == 3);
        plotIdx = Lo - 1 + validIdx;  % Adjust indices to match original array indexing
    
        % get the final detection end time for dotted line plotting
        finalDet = REMORA.lt.lVis_det.detection.stops(end);
    
        % call plot_labels_wav only if there are valid detections to plot
        if ~isempty(plotIdx)
            plot_labels_wav(plotIdx, yPos, colors, startWV, endWV, finalDet);
        end
    end
    
end


function plot_labels_wav(plotIdx, yPos, colors, startWV, endWV, finalDet)

% plot_labels_wav: Helper function to plot bounding boxes on the triton spectrogram
%
% This function is called to plot bounding boxes on the spectrogram window.
% Inputs:
% - plotIdx: list of indices if the detections to be plotted
% - yPos: the y-position of the point to be drawn for short detections
% - colors: the colors to be used for TP / FN  / FP detections
% - startWV: start time of window
% - endWV: end time of window
% - finalDet: final detection end time


    global REMORA PARAMS HANDLES
    
    % set up time bounds for detections within the spectrogram window
    lablFull = [REMORA.lt.lVis_det.detection.starts, REMORA.lt.lVis_det.detection.stops];
    winDets = lablFull(plotIdx, :);
    
    % calculate relative times for plotting in seconds (from window start time)
    detXstart = lt_convertDatenum(winDets(:,1) - startWV, 'seconds');
    detXend = lt_convertDatenum(winDets(:,2) - startWV, 'seconds');
    detDur = detXend - detXstart;
    
    hold(HANDLES.subplt.specgram, 'on');
    % bounding boxes are plotted as points if they are shorter than
    % LineTresh seconds long. Note that only bounding boxes can be
    % edited currently.
    LineThresh = 0;

    
    % loop through each detection to plot with label, frequency range, and score
    for iPlot = 1:length(plotIdx)
        absIdx = plotIdx(iPlot);  % absolute index for this detection
    
        % retrieve detection metadata
        minFreq = REMORA.lt.lVis_det.detection.min_freq(absIdx);
        maxFreq = REMORA.lt.lVis_det.detection.max_freq(absIdx);
        score = REMORA.lt.lVis_det.detection.score(absIdx);
        thislabel = REMORA.lt.lVis_det.detection.labels{absIdx};
        pr_label = REMORA.lt.lVis_det.detection.pr(absIdx);  % get label type
        % choose click menu based on pr label
        clickMenu = wmvClickMenu('GetMenu', absIdx);
        % choose color based on pr label
        color = colors(pr_label, :);
        % plot detection based on duration
        if detDur(iPlot) < LineThresh
            % plot a point for short detection range
            plot(HANDLES.subplt.specgram, detXstart(iPlot), yPos, '*', 'Color', color);
        else           
            % plot rectangle with ButtonDownFcn for edit mode
            rectHandle = rectangle(HANDLES.subplt.specgram, ...
                'Position', [detXstart(iPlot), minFreq, detDur(iPlot), maxFreq - minFreq], ...
                'EdgeColor', color, ...
                'LineStyle', '--',  ...
                'LineWidth', 1.5, ...
                'EdgeColor', color);
            rectHandle.ButtonDownFcn = @(src, ~) editBoundingBox(src, absIdx, ...
                detXstart(iPlot), detXend(iPlot), ...
                minFreq, maxFreq, thislabel, score, color);
            rectHandle.UIContextMenu = clickMenu;

            % overlay a clickable transparent patch (allows user to select
            % rectangle by clicking inside)
            x = [detXstart(iPlot), detXend(iPlot), detXend(iPlot), detXstart(iPlot)];
            y = [minFreq, minFreq, maxFreq, maxFreq];
            
            clickPatch = patch('XData', x, 'YData', y, ...
                'FaceColor', 'none', ...
                'EdgeColor', 'none', ...
                'Parent', HANDLES.subplt.specgram, ...
                'HitTest', 'on', ...
                'PickableParts', 'all');
            clickPatch.ButtonDownFcn = @(src, ~) editBoundingBox(src, absIdx, ...
                detXstart(iPlot), detXend(iPlot), ...
                minFreq, maxFreq, thislabel, score, color);
            clickPatch.UIContextMenu = clickMenu;

        end
    
        % display the label and score at the start of each detection
        text(HANDLES.subplt.specgram, detXstart(iPlot), maxFreq + 9, thislabel, 'Color', color, 'FontWeight', 'normal');
        text(HANDLES.subplt.specgram, detXstart(iPlot), maxFreq + 3, sprintf('%.2f', score), ...
             'Color', color, 'FontWeight', 'bold');
    end
    
    % plot a line at the end of the detection file if applicable
    if ~isempty(winDets) && isequal(plotIdx(end), finalDet)
        plot(HANDLES.subplt.specgram, [detXend(end), detXend(end)], ...
            [PARAMS.freq0, PARAMS.freq1], ':', 'LineWidth', 2, 'Color', color);
    end
    
    hold(HANDLES.subplt.specgram, 'off');

end