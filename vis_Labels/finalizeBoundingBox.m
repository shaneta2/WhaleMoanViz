function finalizeBoundingBox(~,~)
    global REMORA PARAMS HANDLES
    
    % Disable the motion function to stop updating the rectangle
    set(HANDLES.fig.main, 'WindowButtonMotionFcn', '');

     % Prompt for label selection
    labelOptions = {'A', 'B', 'D', '20Hz', '40Hz'};  % Modify with actual labels
    [labelIdx, ok] = listdlg('PromptString', 'Select Label:', ...
                             'SelectionMode', 'single', ...
                             'ListString', labelOptions);
    if ok
        label = labelOptions{labelIdx};
        disp(['Label selected: ', label]);
        
         % Save the new detection
        pos = REMORA.tempRect.Position;
                         
        startWV = PARAMS.plot.dnum;  % Spectrogram window start time in datenum format

        % Convert seconds to datenum and calculate absolute start and end times
        startTimeDays = startWV + pos(1) / (24 * 3600);  % Convert seconds offset to days
        endTimeDays = startWV + (pos(1) + pos(3)) / (24 * 3600);  % Duration in days
        % Convert days since epoch (datenum) to datetime
        excelEpoch = datetime(2000, 1, 0);  % Reference epoch for Triton format
        startTime = excelEpoch + days(startTimeDays);
        endTime = excelEpoch + days(endTimeDays);
        minFreq = pos(2);
        maxFreq = pos(2) + pos(4);
    
        % Convert the WAV start time to datetime format
        wav_start_time_days = PARAMS.raw.dnumStart(1);  % Start time in datenum format
        wav_start_datetime = excelEpoch + days(wav_start_time_days);  % Convert to datetime

        % Calculate start time in seconds relative to the WAV file start
        start_time_sec = seconds(startTime - wav_start_datetime);  % Time difference in seconds
        end_time_sec = seconds(endTime - wav_start_datetime);  % Time difference in seconds

        % Retrieve necessary fields for new detection row
        wav_file_path = fullfile(PARAMS.inpath, PARAMS.infile);
        score = NaN;  % Default score, adjust if needed
        pr = 3;  % Default to false negative for new detections

        % Append new detection to REMORA data table with missing columns as NaN
        newDetection = table({wav_file_path}, NaN, {NaN}, {label}, score, start_time_sec, end_time_sec, ...
                         startTime, endTime, minFreq, maxFreq, NaN, NaN, NaN, NaN, pr, ...
                         'VariableNames', {'wav_file_path', 'model_no', 'image_file_path', 'label', ...
                                           'score', 'start_time_sec', 'end_time_sec', 'start_time', ...
                                           'end_time', 'min_frequency', 'max_frequency', 'box_x1', ...
                                           'box_x2', 'box_y1', 'box_y2', 'pr'});
        REMORA.lt.lVis_det.dataTable = [REMORA.lt.lVis_det.dataTable; newDetection];

        % Sort by start_time to keep order consistent
        REMORA.lt.lVis_det.dataTable = sortrows(REMORA.lt.lVis_det.dataTable, 'start_time');

        % Update detection fields
        initializeDetectionFields(REMORA.lt.lVis_det.dataTable);

        % Clear the temporary rectangle used for drawing
        delete(REMORA.tempRect);
        REMORA.tempRect = [];
        
        % Reset callback functions to exit "Add Detection" mode
        set(HANDLES.fig.main, 'WindowButtonDownFcn', '');
        set(HANDLES.fig.main, 'WindowButtonMotionFcn', '');
        set(HANDLES.fig.main, 'WindowButtonUpFcn', '');
        set(HANDLES.fig.main, 'WindowKeyPressFcn', '');

    else 
        % If canceled, remove the temporary rectangle
        disp('Label selection canceled.');
        delete(REMORA.tempRect);
        REMORA.tempRect = [];
        
         % Clear the temporary rectangle used for drawing
        delete(REMORA.tempRect);
        REMORA.tempRect = [];
        
        % Reset callback functions to exit "Add Detection" mode
        set(HANDLES.fig.main, 'WindowButtonDownFcn', '');
        set(HANDLES.fig.main, 'WindowButtonMotionFcn', '');
        set(HANDLES.fig.main, 'WindowButtonUpFcn', '');
        set(HANDLES.fig.main, 'WindowKeyPressFcn', '');
    end 
     lt_lVis_plot_WAV_labels();
end
