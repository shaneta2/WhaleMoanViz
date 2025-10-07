function plotTimeSeries

% plotTimeSeries: Plots points for each detection on the time series
%
% This function is called to plot points on the time series.
% It pulls the information for each bounding box occuring within the
% currently shown time series, and calls a helper function to actually plot.
%
% Adapted from lt_lVis_plot_TS_labels by Michaela Alksne and Shane Andres

    global REMORA PARAMS HANDLES
    
    colors = [
        0.0 0.0 0.0
        0.8 0.4 0.8
        1.0 0.6 0.0
        0.8 0.6 1.0
        0.8 1.0 1.0
        1.0 0.0 0.4
        1.0 0.6 0.6
        1.0 0.6 0.2
        ];
    
    
    % determine start and end times of plot window
    startWV = PARAMS.plot.dnum;
    winLength = HANDLES.subplt.timeseries.XLim(2); %get length of window in seconds, used to compute end limit
    endWV = startWV + datenum(0,0,0,0,0,winLength);
    
    plotMin = HANDLES.subplt.timeseries.YLim(1);
    plotMax = HANDLES.subplt.timeseries.YLim(2);
    plotCen = (plotMax+plotMin)./2;
    ybuff = (plotMax-plotCen)./7;
    
    yPos = plotCen + 3*ybuff;
    labelPos = plotCen + ybuff*3.5;
    
    % skip plotting if no detections exist
    if isempty(REMORA.lt.lVis_det.detection.labels)
        return;
    end
    
    if REMORA.lt.lVis_det.detection.PlotLabels
        % Get all labels for this detection group
        allLabels = REMORA.lt.lVis_det.detection.labels;
    
        % Find detections within the timeseries window
        [Lo, Hi] = getDetectionRange(startWV, endWV, ...
            REMORA.lt.lVis_det.detection.starts, ...
            REMORA.lt.lVis_det.detection.stops);
    
        % Get final detection end for plotting a dotted line if needed
        finalDet = REMORA.lt.lVis_det.detection.stops(end);
    
        if ~isempty(Lo)
            % Pass all relevant labels for the detections within the range
            plot_labels_ts(allLabels(Lo:Hi), labelPos, ...
                REMORA.lt.lVis_det.detection.starts(Lo:Hi), ...
                REMORA.lt.lVis_det.detection.stops(Lo:Hi), ...
                yPos, colors(1, :), startWV, endWV, finalDet);
        end
      
    end

end

    


function plot_labels_ts(label, labelPos, startL, stopL, yPos, color, startWV, endWV, finalDet)

% plot_labels_ts: Helper function to plot points on the triton time series
%
% This function is called to plot points on the time seires.
% Inputs:
% - label: list of the labels for each detection
% - labelPos: the y-position of the label to be drawn with each detection
% - startL: list of the start times for each detection
% - stopL: list of the stop times for each detection
% - yPos: the y-position of the point to be drawn with each detection
% - color: the color to be used
% - startWV: start time of window
% - endWV: end time of window
% - finalDet: final detection end time

    global PARAMS HANDLES
    lablFull = [startL,stopL];
    winLength = HANDLES.subplt.timeseries.XLim(2);
    
    %just look for start time for plotting at click level
    inWin = find(lablFull(:,1)>= startWV & lablFull(:,1)<=endWV);
    
    winDets = lablFull(inWin,:);
    detstartOff = winDets(:,1) - startWV;
    detXstart = lt_convertDatenum(detstartOff,'seconds'); %convert from datenum to time in SECONDS
    
    detendOff = winDets(:,2) - startWV;
    detXend = lt_convertDatenum(detendOff,'seconds');
    
    hold(HANDLES.subplt.timeseries, 'on')
    
    
    % Iterate over detections to plot each label and detection range
    for iPlot = 1:length(inWin)

        thislabel = label{iPlot};  % Retrieve the corresponding label

        % Plot point for short detection range
        plot(HANDLES.subplt.timeseries, detXstart(iPlot), yPos, '*', 'Color', color);
        text(HANDLES.subplt.timeseries, detXstart(iPlot), labelPos, thislabel, 'Color', color, 'FontWeight', 'normal');

    end

    % Plot final dotted line for the last detection
    if ~isempty(winDets) && isequal(stopL(end), finalDet)
        plot(HANDLES.subplt.timeseries, [detXend(end), detXend(end)], ...
            [HANDLES.subplt.timeseries.YLim(1), HANDLES.subplt.timeseries.YLim(2)], ...
            ':', 'LineWidth', 2, 'Color', color);
    end
    
     hold(HANDLES.subplt.timeseries, 'off');

end


