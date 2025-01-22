function lt_lVis_plot_TS_labels

global REMORA PARAMS HANDLES

colF = [1 0 0];
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
ydelta = ybuff;  % Lower plot line/labels for each group by this amount

% detection groups
labels = {'', '2', '3', '4', '5', '6', '7', '8'};

for labidx = 1:length(labels)
        detfld = sprintf('detection%s', labels{labidx});
        if REMORA.lt.lVis_det.(detfld).PlotLabels
            % Get all labels for this detection group
            allLabels = REMORA.lt.lVis_det.(detfld).labels;

            % Find detections within the timeseries window
            [Lo, Hi] = lt_lVis_get_range(startWV, endWV, ...
                REMORA.lt.lVis_det.(detfld).starts, ...
                REMORA.lt.lVis_det.(detfld).stops);

            % Get final detection end for plotting a dotted line if needed
            finalDet = REMORA.lt.lVis_det.(detfld).stops(end);

            if ~isempty(Lo)
                % Pass all relevant labels for the detections within the range
                plot_labels_wav(allLabels(Lo:Hi), labelPos, ...
                    REMORA.lt.lVis_det.(detfld).starts(Lo:Hi), ...
                    REMORA.lt.lVis_det.(detfld).stops(Lo:Hi), ...
                    yPos, colors(labidx, :), startWV, endWV, finalDet);
            
            %plot changed labels
            changedLab = REMORA.lt.lEdit.(detfld);
            for cidx = 0:8
                ch = changedLab(changedLab(:,3) == cidx, :);
                if ~ isempty(ch)
                    if cidx == 0
                        % special case not in colors matrix
                        plot_chLab_wav(startWV, endWV, ch, colF, yPos);
                    else
                        plot_chLab_wav(startWV, endWV, ch, colors(cidx,:), yPos);
                    end
                end
            end
        end
        
    end
    yPos = yPos - ydelta;
    labelPos = labelPos - ydelta;
    
end

function plot_labels_wav(label,labelPos,startL, stopL, yPos, color,startWV,endWV,finalDet)

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

%%%what kind of plotting are we going to do? Just plot a point if detection
%%%range is shorter than 1 min... using this as a proxy for tlab where
%%%detections are at click level

LineThresh = 1*60;

 % Iterate over detections to plot each label and detection range
    for iPlot = 1:length(inWin)
        detDur = detXend(iPlot) - detXstart(iPlot);
        thislabel = label{iPlot};  % Retrieve the corresponding label

        % Decide on label positioning based on gaps
        if detDur < LineThresh
            % Plot point for short detection range
            plot(HANDLES.subplt.timeseries, detXstart(iPlot), yPos, '*', 'Color', color);
            text(HANDLES.subplt.timeseries, detXstart(iPlot), labelPos, thislabel, 'Color', color, 'FontWeight', 'normal');
        else
            % Plot line for longer detection range
            plot(HANDLES.subplt.timeseries, ...
                [detXstart(iPlot), detXend(iPlot)], [yPos, yPos], ...
                '-', 'Marker', '*', 'MarkerSize', 2, 'Color', color);
            text(HANDLES.subplt.timeseries, detXstart(iPlot), labelPos, label, 'Color', color, 'FontWeight', 'normal');
        end
    end

    % Plot final dotted line for the last detection
    if ~isempty(winDets) && isequal(stopL(end), finalDet)
        plot(HANDLES.subplt.timeseries, [detXend(end), detXend(end)], ...
            [HANDLES.subplt.timeseries.YLim(1), HANDLES.subplt.timeseries.YLim(2)], ...
            ':', 'LineWidth', 2, 'Color', color);
    end

 hold(HANDLES.subplt.timeseries, 'off');




function plot_chLab_wav(startWV,endWV,chLab,col,yPos)

global PARAMS HANDLES REMORA

lablFull = chLab(:,1:2);

%just look for starts for click-level detections
inWin = find(lablFull(:,1)>= startWV & lablFull(:,1)<=endWV);

winDets = lablFull(inWin,:);
detstartOff = winDets(:,1) - startWV;
detXstart = lt_convertDatenum(detstartOff,'seconds'); %convert from datenum to time in SECONDS

detendOff = winDets(:,2) - startWV;
detXend = lt_convertDatenum(detendOff,'seconds');

hold(HANDLES.subplt.timeseries, 'on');

%%%what kind of plotting are we going to do? Just plot a point if detection
%%%range is shorter than 1 min... using this as a proxy for tlab where
%%%detections are at click level

LineThresh = 1*60;

for iPlot = 1:size(detXstart,1)
    detDur = detXend - detXstart;
    if detDur < LineThresh
        %just plot the start of a given detection
        plot(HANDLES.subplt.timeseries, detXstart(iPlot), yPos,'*','Color',col)
    else
        plot(HANDLES.subplt.timeseries, ...
            [detXstart(iPlot) detXend(iPlot)],[yPos yPos],...
            '--','Marker','*','MarkerSize',2,'Color',col)
    end
end

hold(HANDLES.subplt.timeseries, 'off')


